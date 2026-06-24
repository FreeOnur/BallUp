import { homedir } from 'node:os';
import { resolve } from 'node:path';
import { runShell } from './exec.mjs';

/**
 * @param {string} keyPath
 */
function expandKeyPath(keyPath) {
  if (keyPath.startsWith('~/')) {
    return resolve(homedir(), keyPath.slice(2));
  }
  return resolve(keyPath);
}

/**
 * @param {import('./config.mjs').DeployConfig['ssh']} ssh
 * @param {string} remoteCommand
 * @param {{ dryRun?: boolean }} [options]
 */
export async function runSsh(ssh, remoteCommand, options = {}) {
  if (!ssh?.host || !ssh?.user) {
    throw new Error('SSH config requires host and user');
  }

  const keyArg = ssh.keyPath ? `-i "${expandKeyPath(ssh.keyPath)}" ` : '';
  const escaped = remoteCommand.replace(/"/g, '\\"');
  const command = `ssh ${keyArg}-o StrictHostKeyChecking=accept-new ${ssh.user}@${ssh.host} "${escaped}"`;

  return runShell(command, options);
}

/**
 * @param {import('./config.mjs').DeployConfig} config
 * @param {string} remoteCommand
 * @param {{ dryRun?: boolean }} [options]
 */
export async function runOnTarget(config, remoteCommand, options = {}) {
  if (config.mode === 'ssh') {
    return runSsh(config.ssh, remoteCommand, options);
  }

  return runShell(remoteCommand, { ...options, cwd: config.deployPath });
}
