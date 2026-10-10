// Prints all npm commands of this repo with a short explanation (npm run help).
// The texts live in package.json under "scriptsHelp", next to the scripts themselves.
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const root = join(dirname(fileURLToPath(import.meta.url)), "..", "..");
const pkg = JSON.parse(readFileSync(join(root, "package.json"), "utf8"));
const help = pkg.scriptsHelp ?? {};

const names = Object.keys(pkg.scripts);
const width = Math.max(...names.map((name) => name.length)) + 2;

console.log("\nBallUp – npm run <command>\n");
for (const [group, commands] of Object.entries(help)) {
  console.log(group);
  for (const [name, text] of Object.entries(commands)) {
    console.log(`  ${name.padEnd(width)}${text}`);
  }
  console.log();
}

const undocumented = names.filter((name) => !Object.values(help).some((commands) => name in commands));
if (undocumented.length > 0) {
  console.log(`Ohne Beschreibung: ${undocumented.join(", ")}\n`);
}

console.log("Weitere Befehle");
console.log("  Backend:  cd backend && uv run fastapi dev src/ballup/main.py   (lokal starten)");
console.log("            cd backend && uv run ruff check . && uv run mypy && uv run pytest");
console.log("  Android:  cd mobile && ./gradlew :androidApp:app:assembleDebug | spotlessApply | check");
console.log("  iOS:      cd mobile/iosApp && xcodegen generate && open BallUp.xcodeproj   (nur Mac)");
console.log("  Doku:     docs/README.md · Deploy: docs/runbooks/deploy.md · Mac: docs/guides/mac-mini-setup.md\n");
