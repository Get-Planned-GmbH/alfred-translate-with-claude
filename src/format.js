// Converts Claude's JSON response (environment variable RAW) into Alfred Script Filter JSON.
// Valid responses are written to CACHE_FILE.
ObjC.import("Foundation");

function run() {
  const env = $.NSProcessInfo.processInfo.environment;
  const get = (k) => ObjC.unwrap(env.objectForKey(k)) || "";
  const raw = get("RAW");

  let data;
  try {
    const json = raw.slice(raw.indexOf("{"), raw.lastIndexOf("}") + 1);
    data = JSON.parse(json);
    if (!Array.isArray(data.translations) || data.translations.length === 0) throw new Error();
  } catch (e) {
    return JSON.stringify({ items: [{ title: "Couldn’t read Claude’s response", subtitle: "Please try again or change the text slightly", valid: false }] });
  }

  $(raw).writeToFileAtomicallyEncodingError(get("CACHE_FILE"), true, $.NSUTF8StringEncoding, null);

  // Each translation has its own direction: ambiguous words (e.g. "bank") are translated both ways
  const seen = new Set();
  const items = data.translations
    .filter((t) => t && t.text && !seen.has(t.text) && seen.add(t.text))
    .map((t) => {
      const direction = [t.source || data.source, t.target || data.target].filter(Boolean).join(" → ");
      return item(t.text, [direction, t.note].filter(Boolean).join(" · "), t.text);
    });
  return JSON.stringify({ items });
}

function item(title, subtitle, text) {
  // Show multi-line translations on a single line in the result list
  const singleLine = title.replace(/\s*\n\s*/g, " ⏎ ");
  return {
    title: singleLine,
    subtitle: subtitle,
    arg: text,
    mods: { cmd: { subtitle: "Paste into the frontmost app", arg: text, valid: true } },
    text: { copy: text, largetype: text },
    valid: true,
  };
}
