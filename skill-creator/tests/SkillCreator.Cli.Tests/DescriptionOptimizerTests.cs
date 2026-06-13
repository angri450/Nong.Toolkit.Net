using SkillCreator.Cli.Tools;

namespace SkillCreator.Cli.Tests;

public class DescriptionOptimizerTests
{
    private string CreateTempSkill(string frontmatter)
    {
        var dir = Path.Combine(Path.GetTempPath(), $"skill-test-{Guid.NewGuid():N}");
        Directory.CreateDirectory(dir);
        File.WriteAllText(Path.Combine(dir, "SKILL.md"), frontmatter);
        return dir;
    }

    private void CleanupDir(string dir) { if (Directory.Exists(dir)) Directory.Delete(dir, true); }

    [Fact]
    public async Task DryRun_Does_Not_Modify_File()
    {
        var dir = CreateTempSkill("---\nname: test-skill\ndescription: Creates PDF files and processes spreadsheets\n---\n\n# Test\nCreate PDFs with this skill.");
        try
        {
            var optimizer = new DescriptionOptimizer(dir, apply: false);
            var result = await optimizer.OptimizeAsync();
            Assert.False(result.Applied);
            Assert.Contains("Dry-run", result.ApplyNote);
            var content = await File.ReadAllTextAsync(Path.Combine(dir, "SKILL.md"));
            Assert.Contains("Creates PDF files and processes spreadsheets", content); // unchanged
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public async Task Detects_False_Capability_Claim()
    {
        var dir = CreateTempSkill("---\nname: pdf-tools\ndescription: Handles all PDF operations including OCR and digital signatures\n---\n\n# PDF Tools\nExtract text and rotate pages only.");
        Directory.CreateDirectory(Path.Combine(dir, "references"));
        try
        {
            var optimizer = new DescriptionOptimizer(dir, apply: false);
            var result = await optimizer.OptimizeAsync();
            Assert.Contains(result.Risks, r => r.StartsWith("FALSE_CAPABILITY"));
            Assert.Contains(result.Risks, r => r.Contains("OCR", StringComparison.OrdinalIgnoreCase) || r.Contains("ocr"));
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public async Task Detects_UnderTrigger_Risk()
    {
        var dir = CreateTempSkill("---\nname: short-skill\ndescription: Helps with stuff\n---\n\n# Short");
        try
        {
            var optimizer = new DescriptionOptimizer(dir, apply: false);
            var result = await optimizer.OptimizeAsync();
            Assert.Contains(result.Risks, r => r.Contains("UNDER_TRIGGER"));
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public async Task Detects_OverTrigger_Risk()
    {
        var dir = CreateTempSkill("---\nname: broad-skill\ndescription: Handles all document formats for any conversion or editing task. Use for all file operations, any data processing, and whenever the user mentions any kind of file or document or data.\n---\n\n# Broad");
        try
        {
            var optimizer = new DescriptionOptimizer(dir, apply: false);
            var result = await optimizer.OptimizeAsync();
            Assert.Contains(result.Risks, r => r.Contains("OVER_TRIGGER"));
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public async Task Skill_Not_Found_Returns_Error()
    {
        var dir = Path.Combine(Path.GetTempPath(), $"skill-test-{Guid.NewGuid():N}");
        Directory.CreateDirectory(dir);
        try
        {
            var optimizer = new DescriptionOptimizer(dir, apply: false);
            var result = await optimizer.OptimizeAsync();
            Assert.NotEmpty(result.Errors);
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public async Task Skips_Vs_Pattern_As_NonClaim()
    {
        var dir = CreateTempSkill("---\nname: test-skill\ndescription: Needs tool-selection guidance (Bash vs Glob/Grep/Read/Edit) and creates reports\n---\n\n# Test\nCreates reports from data.\n\n## Tool Selection\nUse Glob, Grep, Read, Edit before Bash.");
        try
        {
            var optimizer = new DescriptionOptimizer(dir, apply: false);
            var result = await optimizer.OptimizeAsync();
            // "bash vs glob/grep/read/edit" should NOT be extracted as a claim
            Assert.DoesNotContain(result.ClaimChecks, c => c.Claim.Contains("vs"));
            Assert.DoesNotContain(result.Risks, r => r.Contains("FALSE_CAPABILITY") && r.Contains("bash"));
        }
        finally { CleanupDir(dir); }
    }
}
