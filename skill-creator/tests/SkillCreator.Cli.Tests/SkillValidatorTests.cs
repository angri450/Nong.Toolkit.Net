using SkillCreator.Cli.Tools;

namespace SkillCreator.Cli.Tests;

public class SkillValidatorTests
{
    private string CreateTempSkill(string content, string dirName = null)
    {
        var dir = Path.Combine(Path.GetTempPath(), dirName ?? $"skill-test-{Guid.NewGuid():N}");
        Directory.CreateDirectory(dir);
        File.WriteAllText(Path.Combine(dir, "SKILL.md"), content);
        return dir;
    }

    private void CleanupDir(string dir)
    {
        if (Directory.Exists(dir))
            Directory.Delete(dir, true);
    }

    [Fact]
    public void Detects_Missing_SKILL_md()
    {
        var dir = Path.Combine(Path.GetTempPath(), $"skill-test-{Guid.NewGuid():N}");
        Directory.CreateDirectory(dir);
        try
        {
            var validator = new SkillValidator(dir);
            var result = validator.Validate();
            Assert.False(result.IsValid);
            Assert.Contains(result.Issues, i => i.Message.Contains("not found"));
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Detects_Missing_Frontmatter()
    {
        var dir = CreateTempSkill("# Just a heading\n\nNo frontmatter here.");
        try
        {
            var validator = new SkillValidator(dir);
            var result = validator.Validate();
            Assert.False(result.IsValid);
            Assert.Contains(result.Issues, i => i.Message.Contains("frontmatter"));
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Detects_Missing_Name()
    {
        var dir = CreateTempSkill("---\ndescription: A skill without a name\n---\n\nBody");
        try
        {
            var validator = new SkillValidator(dir);
            var result = validator.Validate();
            Assert.False(result.IsValid);
            Assert.Contains(result.Issues, i => i.Message.Contains("Missing 'name'"));
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Detects_Missing_Description()
    {
        var dir = CreateTempSkill("---\nname: test-skill\n---\n\nBody");
        try
        {
            var validator = new SkillValidator(dir);
            var result = validator.Validate();
            Assert.False(result.IsValid);
            Assert.Contains(result.Issues, i => i.Message.Contains("Missing 'description'"));
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Detects_Description_Not_String()
    {
        var dir = CreateTempSkill("---\nname: test-skill\ndescription:\n  - item1\n  - item2\n---\n\nBody");
        try
        {
            var validator = new SkillValidator(dir);
            var result = validator.Validate();
            Assert.False(result.IsValid);
            Assert.Contains(result.Issues, i => i.Message.Contains("must be a string"));
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Detects_Invalid_Name_Format()
    {
        var dir = CreateTempSkill("---\nname: Test_Skill!\ndescription: A test skill\n---\n\nBody");
        try
        {
            var validator = new SkillValidator(dir);
            var result = validator.Validate();
            Assert.Contains(result.Issues, i => i.Message.Contains("hyphen-case"));
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Detects_Broken_Reference()
    {
        var dir = CreateTempSkill("---\nname: test-skill\ndescription: A test skill\n---\n\nSee `references/nonexistent.md` for details.");
        try
        {
            var validator = new SkillValidator(dir);
            var result = validator.Validate();
            Assert.Contains(result.BrokenReferences, r => r.Contains("nonexistent.md"));
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Valid_Skill_Passes()
    {
        var dir = CreateTempSkill("---\nname: my-valid-skill\ndescription: A properly formed skill that validates correctly\n---\n\n## Overview\n\nThis is a valid skill body.");
        try
        {
            var validator = new SkillValidator(dir);
            var result = validator.Validate();
            Assert.True(result.IsValid);
            Assert.Equal("my-valid-skill", result.SkillName);
            Assert.Equal("A properly formed skill that validates correctly", result.Description);
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Warns_On_Large_SKILL_md()
    {
        var body = new string('x', 1000) + "\n"; // Many lines
        var largeContent = "---\nname: large-skill\ndescription: A very large skill\n---\n\n" +
                           string.Concat(Enumerable.Repeat("Line of content here.\n", 800));
        var dir = CreateTempSkill(largeContent);
        try
        {
            var validator = new SkillValidator(dir);
            var result = validator.Validate();
            Assert.True(result.IsValid); // Large is a warning, not error
            Assert.Contains(result.Issues, i => i.Message.Contains("700 lines"));
        }
        finally { CleanupDir(dir); }
    }

    [Fact]
    public void Validates_With_Context_Fork()
    {
        var dir = CreateTempSkill("---\nname: fork-skill\ndescription: A skill using context fork\ncontext: fork\nagent: Explore\n---\n\n# Fork Skill\n\nRuns in isolated context.");
        try
        {
            var validator = new SkillValidator(dir);
            var result = validator.Validate();
            Assert.True(result.IsValid);
        }
        finally { CleanupDir(dir); }
    }
}
