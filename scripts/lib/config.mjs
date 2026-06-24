import { readFileSync, existsSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(__dirname, '../..');

const VALID_MODES = ['local', 'ssh', 'coolify-webhook'];

/**
 * @typedef {Object} DeployConfig
 * @property {'local'|'ssh'|'coolify-webhook'} mode
 * @property {string} repoUrl
 * @property {string} branch
 * @property {string} deployPath
 * @property {string} composeFile
 * @property {string} healthUrl
 * @property {{ host: string, user: string, keyPath?: string }} [ssh]
 * @property {{ webhookUrl: string }} [coolify]
 */

/**
 * @param {string} configPath
 * @returns {DeployConfig}
 */
export function loadDeployConfig(configPath) {
  const absolutePath = resolve(repoRoot, configPath);
  if (!existsSync(absolutePath)) {
    throw new Error(
      `Config not found: ${absolutePath}\nCopy scripts/config/deploy.example.json to scripts/config/deploy.json`,
    );
  }

  const raw = JSON.parse(readFileSync(absolutePath, 'utf8'));
  const mode = raw.mode ?? 'local';

  if (!VALID_MODES.includes(mode)) {
    throw new Error(`Invalid mode "${mode}". Use: ${VALID_MODES.join(', ')}`);
  }

  if (mode === 'ssh' && (!raw.ssh?.host || !raw.ssh?.user)) {
    throw new Error('ssh.host and ssh.user required when mode is "ssh"');
  }

  if (mode === 'coolify-webhook' && !raw.coolify?.webhookUrl) {
    throw new Error('coolify.webhookUrl required when mode is "coolify-webhook"');
  }

  return {
    mode,
    repoUrl: raw.repoUrl ?? 'https://github.com/FreeOnur/BallerApp.git',
    branch: raw.branch ?? 'main',
    deployPath: raw.deployPath ?? repoRoot,
    composeFile: raw.composeFile ?? 'docker-compose.yml',
    healthUrl: raw.healthUrl ?? 'http://localhost:8000/health',
    ssh: raw.ssh,
    coolify: raw.coolify,
  };
}

export { repoRoot };
