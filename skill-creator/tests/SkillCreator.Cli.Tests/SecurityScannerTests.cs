using System.Text.RegularExpressions;
using SkillCreator.Cli.Models;
using SkillCreator.Cli.Tools;

namespace SkillCreator.Cli.Tests;

public class SecurityScannerTests
{
    private string CreateTempDir(string content, string fileName = "test.md")
    {
        var dir = Path.Combine(Path.GetTempPath(), $"skill-test-{Guid.NewGuid():N}");
        Directory.CreateDirectory(dir);
        File.WriteAllText(Path.Combine(dir, fileName), content);
        return dir;
    }

    private void CleanupDir(string dir)
    {
        if (Directory.Exists(dir))
            Directory.Delete(dir, true);
    }

    [Fact]
    public void Detects_Email_Address()
    {
        var dir = CreateTempDir("Contact us at admin@example.com for support.");
        try
        {
            var scanner = new SecurityScanner(dir);
            var findings = scanner.Scan();
            Assert.Contains(findings, f => f.Rule == "EMAIL_EXPOSED" && f.Severity == Severity.High);
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Detects_Absolute_Windows_User_Path()
    {
        var dir = CreateTempDir(@"Read from C:\Users\johndoe\Documents\data.json");
        try
        {
            var scanner = new SecurityScanner(dir);
            var findings = scanner.Scan();
            Assert.Contains(findings, f => f.Rule == "ABSOLUTE_USER_PATH");
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Detects_InnerHTML_Risk_In_Html()
    {
        var dir = CreateTempDir("element.innerHTML = userInput;", "test.html");
        try
        {
            var scanner = new SecurityScanner(dir);
            var findings = scanner.Scan();
            Assert.Contains(findings, f => f.Rule == "UNSAFE_INNERHTML");
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Detects_External_CDN()
    {
        var dir = CreateTempDir(@"<script src=""https://cdn.sheetjs.com/xlsx.min.js""></script>", "test.html");
        try
        {
            var scanner = new SecurityScanner(dir);
            var findings = scanner.Scan();
            Assert.Contains(findings, f => f.Rule == "EXTERNAL_CDN" && f.Severity == Severity.High);
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Detects_Google_Fonts_CDN()
    {
        var dir = CreateTempDir(@"<link href=""https://fonts.googleapis.com/css2?family=Roboto"" rel=""stylesheet"">", "test.html");
        try
        {
            var scanner = new SecurityScanner(dir);
            var findings = scanner.Scan();
            Assert.Contains(findings, f => f.Rule == "EXTERNAL_CDN");
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Detects_GitHub_Token()
    {
        var dir = CreateTempDir("export GITHUB_TOKEN=ghp_123456789012345678901234567890123456");
        try
        {
            var scanner = new SecurityScanner(dir);
            var findings = scanner.Scan();
            Assert.Contains(findings, f => f.Rule == "GITHUB_TOKEN");
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Detects_Private_Key()
    {
        var dir = CreateTempDir("-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA...\n-----END RSA PRIVATE KEY-----");
        try
        {
            var scanner = new SecurityScanner(dir);
            var findings = scanner.Scan();
            Assert.Contains(findings, f => f.Rule == "PRIVATE_KEY");
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Detects_API_Key_Assignment()
    {
        var dir = CreateTempDir("api_key = 'sk-1234567890abcdefghijklmnopqrstuv'");
        try
        {
            var scanner = new SecurityScanner(dir);
            var findings = scanner.Scan();
            Assert.Contains(findings, f => f.Rule == "API_KEY");
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Detects_JWT_Token()
    {
        var dir = CreateTempDir("Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIn0.dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk");
        try
        {
            var scanner = new SecurityScanner(dir);
            var findings = scanner.Scan();
            Assert.Contains(findings, f => f.Rule == "JWT_TOKEN");
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Default_Scan_Is_Not_Verbose()
    {
        var dir = CreateTempDir("Safe content without any issues.");
        try
        {
            var scanner = new SecurityScanner(dir, verbose: false);
            var findings = scanner.Scan();
            // Should have zero findings on clean content
            Assert.Empty(findings);
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Detects_Unsafe_Shell_In_Sh_File()
    {
        var dir = CreateTempDir("rm -rf /var/log/app", "cleanup.sh");
        try
        {
            var scanner = new SecurityScanner(dir);
            var findings = scanner.Scan();
            Assert.Contains(findings, f => f.Rule == "DANGEROUS_RM");
        }
        finally { CleanupDir(dir); }
    }
}
