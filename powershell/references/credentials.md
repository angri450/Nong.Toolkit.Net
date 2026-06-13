# Credential & Secret Handling

```powershell
# Prompt securely — never hardcode
$cred = Get-Credential -Message "Enter service account credentials"

# Read a secret from environment (prefer over in-script literals)
$token = [System.Environment]::GetEnvironmentVariable('MY_API_TOKEN','User')
if (-not $token) { throw 'MY_API_TOKEN environment variable is not set.' }

# Recommended: SecretManagement + SecretStore
# Install-Module Microsoft.PowerShell.SecretManagement
# Install-Module Microsoft.PowerShell.SecretStore
# Register-SecretVault -Name MyLocalVault -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault
# $secret = Get-Secret -Name MyApiKey -Vault MyLocalVault
```

> Microsoft explicitly recommends **avoiding `SecureString` for new development**.
> Use certificates, managed identities, or `SecretManagement` instead.

Never store plain-text passwords, tokens, or connection strings in scripts or version control.
