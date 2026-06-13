# Sandbox Decisions

When the runtime executes Bash commands inside a sandbox, the sandbox restricts file/network access by default. The agent can disable it per call (`dangerouslyDisableSandbox: true`), but the parameter is named `dangerously…` for a reason.

## Default

- **Run in the sandbox**, every call. Do not preemptively disable it.
- Disabling is a **per-call** decision. A previous override does NOT carry over — the next call defaults back to sandboxed.

## When to override

Override only when **both** are true:

1. The user explicitly asked, OR there is concrete evidence the failure is sandbox-caused.
2. There is no safer alternative (e.g., narrower allowlist, alternate command).

## Sandbox-failure evidence (vs. unrelated failure)

| Symptom | Likely sandbox? |
|---|---|
| `Operation not permitted` on a file/network op | Yes |
| Access denied to paths outside the allowed dirs | Yes |
| Connection refused / timeout to a non-allowlisted host | Yes |
| Unix-socket connection error | Yes |
| `command not found` | No — missing binary, not sandbox |
| Wrong arguments / nonzero exit from the command itself | No |
| Timeout from a long-running build | No |

If the symptom isn't on the left column, fix the real problem first.

## Allowlist hygiene (when adding paths)

Never add to the sandbox allowlist:

- `~/.bashrc`, `~/.zshrc`, `~/.profile` and similar shell init files.
- `~/.ssh/*` — keys, configs, known_hosts.
- Credential files: `.env`, `.aws/`, `.docker/config.json`, `~/.netrc`.
- Cloud-provider auth dirs (`gcloud`, `azure`, `kube/config`).

## Temp files

- Write to `$TMPDIR` (or `${TMPDIR:-/tmp}`), never hardcode `/tmp` — it bypasses platform conventions and may be outside the sandbox on some platforms.
- Clean up your own temp files when done.
