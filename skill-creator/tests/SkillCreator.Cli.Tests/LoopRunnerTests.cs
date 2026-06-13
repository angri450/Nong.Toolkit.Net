using SkillCreator.Cli.Tools;

namespace SkillCreator.Cli.Tests;

public class LoopRunnerTests
{
    private string CreateTempSkill()
    {
        var dir = Path.Combine(Path.GetTempPath(), $"skill-test-{Guid.NewGuid():N}");
        Directory.CreateDirectory(dir);
        File.WriteAllText(Path.Combine(dir, "SKILL.md"),
            "---\nname: test-skill\ndescription: A test skill for loop testing\n---\n\n# Test\nTest body.");
        return dir;
    }

    private void CleanupDir(string dir) { if (Directory.Exists(dir)) Directory.Delete(dir, true); }

    [Fact]
    public async Task RunLoop_Completes_Pipeline()
    {
        var dir = CreateTempSkill();
        try
        {
            var looper = new LoopRunner(dir);
            var result = await looper.RunLoopAsync();
            Assert.False(result.NeedsFixing);
            Assert.True(result.NeedsModelEnvironment); // No model env in tests
            Assert.Contains(result.Steps, s => s.Name == "validate" && s.Status == "passed");
            Assert.Contains(result.Steps, s => s.Name == "security-scan" && s.Status == "passed");
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public async Task RunLoop_Fails_On_Invalid_Skill()
    {
        var dir = Path.Combine(Path.GetTempPath(), $"skill-test-{Guid.NewGuid():N}");
        Directory.CreateDirectory(dir);
        File.WriteAllText(Path.Combine(dir, "SKILL.md"), "# No frontmatter\nJust content.");
        try
        {
            var looper = new LoopRunner(dir);
            var result = await looper.RunLoopAsync();
            Assert.True(result.NeedsFixing);
            Assert.Contains(result.Steps, s => s.Name == "validate" && s.Status == "failed");
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public async Task RunLoop_Skips_Eval_When_No_File()
    {
        var dir = CreateTempSkill();
        try
        {
            var looper = new LoopRunner(dir, "/nonexistent/evals.json");
            var result = await looper.RunLoopAsync();
            Assert.Contains(result.Steps, s => s.Name == "eval-schema" && s.Status == "skipped");
        }
        finally { CleanupDir(dir); }
    }
}
