// Runs a deploy script with bash on every OS (used by the npm scripts in package.json).
// On Windows `bash` in PATH is usually WSL, so Git Bash is used explicitly (override with BALLUP_BASH).
//   node deploy/scripts/run.mjs <script> [args...]   e.g. run.mjs deploy api
import { spawnSync } from "node:child_process";
import { existsSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const [script, ...args] = process.argv.slice(2);
const scriptsDir = join(dirname(fileURLToPath(import.meta.url)), "deploy");

function findBash() {
  if (process.env.BALLUP_BASH) return process.env.BALLUP_BASH;
  if (process.platform !== "win32") return "bash";
  const candidates = [
    join(process.env.ProgramFiles ?? "C:\\Program Files", "Git", "bin", "bash.exe"),
    join(process.env.LOCALAPPDATA ?? "", "Programs", "Git", "bin", "bash.exe"),
  ];
  const found = candidates.find((path) => existsSync(path));
  if (!found) {
    console.error("Git Bash not found. Install Git for Windows or set BALLUP_BASH.");
    process.exit(1);
  }
  return found;
}

const scriptPath = join(scriptsDir, `${script}.sh`);
if (!script || !existsSync(scriptPath)) {
  console.error(`unknown script "${script ?? ""}"`);
  process.exit(1);
}

const result = spawnSync(findBash(), [scriptPath, ...args], { stdio: "inherit" });
process.exit(result.status ?? 1);
