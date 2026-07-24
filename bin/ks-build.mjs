#!/usr/bin/env node
// ks-build — emit killer-saas tooling for a given target CLI from the canonical src/.
// Zero external dependencies. Produces a staging tree that install.sh copies into place.
//
//   node bin/ks-build.mjs --target codex --src ./src --out /tmp/ks-stg
//
// Targets:
//   claude  identity: commands/, skills/, agents/ copied as-is (parity with the bash path)
//   codex   commands -> Codex skills (SKILL.md + agents/openai.yaml), methodology skills
//           verbatim, agents -> skills with a model note. AGENTS.md is native (handled by install.sh).
//
// The canonical source stays Claude-shaped; only two body macros are rewritten: `@path` file
// injection (Claude-only) becomes a plain path reference, and `$ARGUMENTS` is kept (Codex-native).

import { readdirSync, readFileSync, mkdirSync, writeFileSync, statSync, cpSync } from "node:fs";
import { join, basename } from "node:path";

function parseArgs(argv) {
  const a = {};
  for (let i = 0; i < argv.length; i++) {
    if (argv[i].startsWith("--")) a[argv[i].slice(2)] = argv[i + 1];
  }
  return a;
}

// Minimal frontmatter split. Returns { fm: rawYamlString, body }.
function splitFrontmatter(text) {
  if (!text.startsWith("---")) return { fm: "", body: text };
  const end = text.indexOf("\n---", 3);
  if (end === -1) return { fm: "", body: text };
  const fm = text.slice(3, end).replace(/^\n/, "");
  const body = text.slice(end + 4).replace(/^\n/, "");
  return { fm, body };
}

// Read a single scalar key from a raw frontmatter string (top-level `key: value`).
function fmScalar(fm, key) {
  const m = fm.match(new RegExp(`^${key}:[ \\t]*(.+?)[ \\t]*$`, "m"));
  return m ? m[1].trim() : "";
}

// Claude-only `@path` injection -> plain path reference; keep $ARGUMENTS (Codex-native).
function derefInjections(body) {
  return body
    .replace(/@templates\//g, "templates/")
    .replace(/@AGENTS\.md/g, "AGENTS.md");
}

function ensureDir(p) { mkdirSync(p, { recursive: true }); }

function listFiles(dir) {
  try { return readdirSync(dir); } catch { return []; }
}
function isDir(p) { try { return statSync(p).isDirectory(); } catch { return false; } }

// ---- CODEX EMISSION -------------------------------------------------------

function codexSkillFromCommand(name, text, outSkillsDir) {
  const { fm, body } = splitFrontmatter(text);
  const description = fmScalar(fm, "description") || `killer-saas command ${name}`;
  const argHint = fmScalar(fm, "argument-hint");
  const skillDir = join(outSkillsDir, name);
  ensureDir(join(skillDir, "agents"));

  // SKILL.md: open-standard frontmatter (name + description) + transformed body.
  const skillFm = `---\nname: ${name}\ndescription: ${description}\n---\n`;
  const preamble =
    `> killer-saas command, emitted for Codex. Run it explicitly. ` +
    `Delegation ("the Agent tool" / "subagent_type: X") maps to your Codex subagent ` +
    `mechanism (/agent) using the X skill; file/grep gates and the git hooks are unchanged.\n\n`;
  writeFileSync(join(skillDir, "SKILL.md"), skillFm + preamble + derefInjections(body));

  // agents/openai.yaml: the /ks-* interface.
  const defaultPrompt = argHint
    ? `Run ${name} ${argHint}`
    : `Run the ${name} step of the killer-saas pipeline.`;
  const yaml =
    `interface:\n` +
    `  display_name: "/${name}"\n` +
    `  short_description: ${JSON.stringify(description)}\n` +
    `  default_prompt: ${JSON.stringify(defaultPrompt)}\n`;
  writeFileSync(join(skillDir, "agents", "openai.yaml"), yaml);
}

function codexSkillFromAgent(name, text, outSkillsDir) {
  const { fm, body } = splitFrontmatter(text);
  const description = fmScalar(fm, "description") || `killer-saas ${name}`;
  const model = fmScalar(fm, "model");
  const skillDir = join(outSkillsDir, name);
  ensureDir(skillDir);
  const modelNote = model
    ? `> Run this in an isolated subagent. On Claude this pins model \`${model}\`; ` +
      `on Codex choose an equivalent (fast coder for implementer, strong reviewer for reviewer). ` +
      `Read-only / tool restrictions are advisory here — the git hooks hold the gate.\n\n`
    : "";
  const skillFm = `---\nname: ${name}\ndescription: ${description}\n---\n`;
  writeFileSync(join(skillDir, "SKILL.md"), skillFm + modelNote + derefInjections(body));
}

function emitCodex(src, out) {
  const skillsOut = join(out, "skills");
  ensureDir(skillsOut);
  // Commands -> command-skills (explicit, with openai.yaml interface).
  for (const f of listFiles(join(src, "commands")).filter((f) => f.endsWith(".md"))) {
    const name = basename(f, ".md");
    codexSkillFromCommand(name, readFileSync(join(src, "commands", f), "utf8"), skillsOut);
  }
  // Methodology skills -> verbatim (implicit invocation, same open standard).
  for (const d of listFiles(join(src, "skills")).filter((d) => isDir(join(src, "skills", d)))) {
    cpSync(join(src, "skills", d), join(skillsOut, d), { recursive: true });
  }
  // Agents -> agent-skills with a model note.
  for (const f of listFiles(join(src, "agents")).filter((f) => f.endsWith(".md"))) {
    const name = basename(f, ".md");
    codexSkillFromAgent(name, readFileSync(join(src, "agents", f), "utf8"), skillsOut);
  }
}

// ---- CLAUDE EMISSION (identity, for --target all / parity testing) --------

function emitClaude(src, out) {
  for (const kind of ["commands", "skills", "agents"]) {
    const from = join(src, kind);
    if (!isDir(from)) continue;
    ensureDir(join(out, kind));
    cpSync(from, join(out, kind), { recursive: true });
  }
}

// ---- MAIN -----------------------------------------------------------------

const args = parseArgs(process.argv.slice(2));
const target = args.target;
const src = args.src;
const out = args.out;
if (!target || !src || !out) {
  console.error("usage: ks-build.mjs --target claude|codex --src <dir> --out <dir>");
  process.exit(2);
}
ensureDir(out);
if (target === "codex") emitCodex(src, out);
else if (target === "claude") emitClaude(src, out);
else { console.error(`unknown target: ${target}`); process.exit(2); }
console.log(`ks-build: emitted ${target} into ${out}`);
