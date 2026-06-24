import { spawn } from 'node:child_process';

/**
 * @param {string} command
 * @param {string[]} args
 * @param {{ cwd?: string, env?: NodeJS.ProcessEnv, dryRun?: boolean, shell?: boolean }} [options]
 * @returns {Promise<{ stdout: string, stderr: string, code: number }>}
 */
export function run(command, args = [], options = {}) {
  const { cwd, env, dryRun = false, shell = false } = options;
  const printable = shell
    ? command
    : [command, ...args].join(' ');

  if (dryRun) {
    console.log(`[dry-run] ${printable}`);
    return Promise.resolve({ stdout: '', stderr: '', code: 0 });
  }

  console.log(`> ${printable}`);

  return new Promise((resolvePromise, reject) => {
    const child = shell
      ? spawn(command, { cwd, env, shell: true, stdio: ['ignore', 'pipe', 'pipe'] })
      : spawn(command, args, { cwd, env, shell: false, stdio: ['ignore', 'pipe', 'pipe'] });

    let stdout = '';
    let stderr = '';

    child.stdout?.on('data', (chunk) => {
      const text = chunk.toString();
      stdout += text;
      process.stdout.write(text);
    });

    child.stderr?.on('data', (chunk) => {
      const text = chunk.toString();
      stderr += text;
      process.stderr.write(text);
    });

    child.on('error', reject);

    child.on('close', (code) => {
      resolvePromise({ stdout, stderr, code: code ?? 1 });
    });
  });
}

/**
 * @param {string} command
 * @param {{ cwd?: string, dryRun?: boolean }} [options]
 */
export async function runShell(command, options = {}) {
  const result = await run(command, [], { ...options, shell: true });
  if (result.code !== 0) {
    throw new Error(`Command failed (exit ${result.code}): ${command}`);
  }
  return result;
}

/**
 * @param {string} url
 * @param {{ dryRun?: boolean }} [options]
 */
export async function healthCheck(url, options = {}) {
  const { dryRun = false } = options;
  if (dryRun) {
    console.log(`[dry-run] curl -sf ${url}`);
    return true;
  }

  console.log(`> curl -sf ${url}`);
  const response = await fetch(url, { signal: AbortSignal.timeout(30_000) });
  if (!response.ok) {
    throw new Error(`Health check failed: ${url} → HTTP ${response.status}`);
  }
  const body = await response.text();
  console.log(`Health OK: ${body.slice(0, 200)}`);
  return true;
}

/**
 * @param {string} webhookUrl
 * @param {{ dryRun?: boolean }} [options]
 */
export async function triggerCoolifyWebhook(webhookUrl, options = {}) {
  const { dryRun = false } = options;
  if (dryRun) {
    console.log(`[dry-run] POST ${webhookUrl}`);
    return;
  }

  console.log(`> POST ${webhookUrl}`);
  const response = await fetch(webhookUrl, {
    method: 'POST',
    signal: AbortSignal.timeout(120_000),
  });

  if (!response.ok) {
    throw new Error(`Coolify webhook failed: HTTP ${response.status}`);
  }

  console.log('Coolify webhook accepted.');
}
