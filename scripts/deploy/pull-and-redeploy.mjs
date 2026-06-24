#!/usr/bin/env node
/**
 * Pull latest git changes and redeploy docker compose stack.
 *
 * Modes: local | ssh | coolify-webhook
 */
import { loadDeployConfig } from '../lib/config.mjs';
import { healthCheck, triggerCoolifyWebhook } from '../lib/exec.mjs';
import { runOnTarget } from '../lib/ssh.mjs';

function parseArgs(argv) {
  const options = {
    configPath: 'scripts/config/deploy.json',
    mode: undefined,
    checkOnly: false,
    dryRun: false,
  };

  for (let i = 0; i < argv.length; i += 1) {
    const arg = argv[i];
    if (arg === '--check-only') options.checkOnly = true;
    else if (arg === '--dry-run') options.dryRun = true;
    else if (arg === '--config' && argv[i + 1]) {
      options.configPath = argv[++i];
    } else if (arg === '--mode' && argv[i + 1]) {
      options.mode = argv[++i];
    } else if (arg === '--help' || arg === '-h') {
      printHelp();
      process.exit(0);
    }
  }

  return options;
}

function printHelp() {
  console.log(`Usage: node scripts/deploy/pull-and-redeploy.mjs [options]

Options:
  --mode local|ssh|coolify-webhook   Override config mode
  --check-only                     Git fetch + health only, no rebuild
  --dry-run                        Print commands without executing
  --config <path>                  Config file (default: scripts/config/deploy.json)
  -h, --help                       Show this help
`);
}

/**
 * @param {import('../lib/config.mjs').DeployConfig} config
 * @param {{ checkOnly: boolean, dryRun: boolean }} opts
 */
async function deployLocalOrSsh(config, opts) {
  const { checkOnly, dryRun } = opts;
  const { deployPath, branch, repoUrl, composeFile } = config;

  const gitSyncScript = [
    `set -e`,
    `cd "${deployPath}"`,
    `if [ -d .git ]; then`,
    `  git fetch origin`,
    `  git checkout ${branch}`,
    `  LOCAL=$(git rev-parse HEAD)`,
    `  REMOTE=$(git rev-parse origin/${branch})`,
    `  if [ "$LOCAL" = "$REMOTE" ]; then echo "Already up to date ($LOCAL)"; else git pull origin ${branch}; fi`,
    `else`,
    `  git clone --branch ${branch} ${repoUrl} "${deployPath}"`,
    `fi`,
  ].join('\n');

  await runOnTarget(config, gitSyncScript, { dryRun });

  if (checkOnly) {
    console.log('Check-only: skipping docker rebuild.');
    await healthCheck(config.healthUrl, { dryRun });
    return;
  }

  const deployScript = [
    `set -e`,
    `cd "${deployPath}"`,
    `docker compose -f ${composeFile} up -d --build`,
  ].join('\n');

  await runOnTarget(config, deployScript, { dryRun });
  await healthCheck(config.healthUrl, { dryRun });
}

/**
 * @param {import('../lib/config.mjs').DeployConfig} config
 * @param {{ checkOnly: boolean, dryRun: boolean }} opts
 */
async function deployCoolifyWebhook(config, opts) {
  const { checkOnly, dryRun } = opts;

  if (checkOnly) {
    console.log('Check-only with coolify-webhook: health check only.');
    await healthCheck(config.healthUrl, { dryRun });
    return;
  }

  await triggerCoolifyWebhook(config.coolify.webhookUrl, { dryRun });

  if (!dryRun) {
    console.log('Waiting 30s for Coolify to rebuild...');
    await new Promise((r) => setTimeout(r, 30_000));
  }

  await healthCheck(config.healthUrl, { dryRun });
}

async function main() {
  const cli = parseArgs(process.argv.slice(2));
  const config = loadDeployConfig(cli.configPath);

  if (cli.mode) {
    config.mode = cli.mode;
  }

  console.log(`Deploy mode: ${config.mode}`);
  console.log(`Target path: ${config.deployPath}`);
  console.log(`Branch: ${config.branch}`);
  if (cli.checkOnly) console.log('Mode: check-only');
  if (cli.dryRun) console.log('Mode: dry-run');

  const opts = { checkOnly: cli.checkOnly, dryRun: cli.dryRun };

  switch (config.mode) {
    case 'coolify-webhook':
      await deployCoolifyWebhook(config, opts);
      break;
    case 'local':
    case 'ssh':
      await deployLocalOrSsh(config, opts);
      break;
    default:
      throw new Error(`Unknown mode: ${config.mode}`);
  }

  console.log('\nDeploy finished successfully.');
}

main().catch((error) => {
  console.error(`\nDeploy failed: ${error.message}`);
  process.exit(1);
});
