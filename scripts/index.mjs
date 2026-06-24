#!/usr/bin/env node
import { spawn } from 'node:child_process';

const [, , command, ...rest] = process.argv;

const commands = {
  deploy: ['node', 'scripts/deploy/pull-and-redeploy.mjs', ...rest],
  help: null,
};

if (!command || command === 'help' || command === '--help') {
  console.log(`BallerApp scripts CLI

Usage:
  node scripts/index.mjs deploy [--check-only] [--dry-run] [--mode local|ssh|coolify-webhook]

Or use npm scripts:
  npm run deploy
  npm run deploy:check
  npm run deploy:dry
`);
  process.exit(0);
}

const spec = commands[command];
if (!spec) {
  console.error(`Unknown command: ${command}`);
  process.exit(1);
}

const child = spawn(spec[0], spec.slice(1), { stdio: 'inherit', shell: process.platform === 'win32' });
child.on('close', (code) => process.exit(code ?? 1));
