using SkillCreator.Cli.Tools;

namespace SkillCreator.Cli.Tests;

public class BlindComparisonTests
{
    [Fact]
    public void IsAnonymousLabel_Accepts_SingleLetter()
    {
        Assert.True(BlindAnonymizer.IsAnonymousLabel("A"));
        Assert.True(BlindAnonymizer.IsAnonymousLabel("B"));
        Assert.True(BlindAnonymizer.IsAnonymousLabel("Z"));
    }

    [Fact]
    public void IsAnonymousLabel_Accepts_ArtifactFormat()
    {
        Assert.True(BlindAnonymizer.IsAnonymousLabel("artifact-001"));
        Assert.True(BlindAnonymizer.IsAnonymousLabel("artifact-A"));
    }

    [Fact]
    public void IsAnonymousLabel_Accepts_OutputFormat()
    {
        Assert.True(BlindAnonymizer.IsAnonymousLabel("output-1"));
    }

    [Fact]
    public void IsAnonymousLabel_Rejects_WithSkill()
    {
        Assert.False(BlindAnonymizer.IsAnonymousLabel("with_skill"));
        Assert.False(BlindAnonymizer.IsAnonymousLabel("with-skill"));
    }

    [Fact]
    public void IsAnonymousLabel_Rejects_Baseline()
    {
        Assert.False(BlindAnonymizer.IsAnonymousLabel("baseline"));
        Assert.False(BlindAnonymizer.IsAnonymousLabel("candidate"));
        Assert.False(BlindAnonymizer.IsAnonymousLabel("control"));
    }

    [Fact]
    public void LabelContainsLeakage_Detects_SkillName()
    {
        Assert.True(BlindAnonymizer.LabelContainsLeakage("my-skill-with_skill"));
        Assert.True(BlindAnonymizer.LabelContainsLeakage("baseline_run"));
    }

    [Fact]
    public void LabelContainsLeakage_Allows_Anonymous()
    {
        Assert.False(BlindAnonymizer.LabelContainsLeakage("A"));
        Assert.False(BlindAnonymizer.LabelContainsLeakage("artifact-42"));
    }

    [Fact]
    public void PathContainsLeakage_Detects_WithSkill()
    {
        Assert.True(BlindAnonymizer.PathContainsLeakage("/tmp/eval-0/with_skill/outputs"));
        Assert.True(BlindAnonymizer.PathContainsLeakage(@"C:\workspace\iteration-1\eval-0\old_skill\outputs"));
    }

    [Fact]
    public void PathContainsLeakage_Allows_CleanPath()
    {
        Assert.False(BlindAnonymizer.PathContainsLeakage("/tmp/eval-0/artifact-A/outputs"));
        Assert.False(BlindAnonymizer.PathContainsLeakage(@"C:\workspace\iteration-1\eval-0\A\outputs"));
    }

    [Fact]
    public void ValidateBlindSetup_Rejects_When_Labels_Contain_VersionInfo()
    {
        var (isBlind, issues) = BlindAnonymizer.ValidateBlindSetup("v1", "v2");
        Assert.False(isBlind);
        Assert.Contains(issues, i => i.Contains("not anonymous"));
    }

    [Fact]
    public void ValidateBlindSetup_Passes_With_Clean_Labels()
    {
        var (isBlind, issues) = BlindAnonymizer.ValidateBlindSetup("A", "B");
        Assert.True(isBlind);
        Assert.Empty(issues);
    }

    [Fact]
    public void ValidateBlindSetup_Detects_Leakage_In_Paths()
    {
        var (isBlind, issues) = BlindAnonymizer.ValidateBlindSetup(
            "A", "B",
            artifactAPath: "/workspace/with_skill/outputs",
            artifactBPath: "/workspace/without_skill/outputs");
        Assert.False(isBlind);
        Assert.Contains(issues, i => i.Contains("path") && i.Contains("leakage"));
    }

    [Fact]
    public void ValidateBlindSetup_Detects_Leakage_In_Metadata()
    {
        var metadata = @"{""skill_name"": ""test-skill"", ""configuration"": ""with_skill""}";
        var (isBlind, issues) = BlindAnonymizer.ValidateBlindSetup("A", "B", metadata: metadata);
        Assert.False(isBlind);
        Assert.Contains(issues, i => i.Contains("identity field"));
    }

    [Fact]
    public void StripMetadataIdentity_Removes_Sensitive_Fields()
    {
        var json = @"{""skill_name"": ""test"", ""configuration"": ""with_skill"", ""expectation_count"": 5}";
        var result = BlindAnonymizer.StripMetadataIdentity(json);
        Assert.DoesNotContain("skill_name", result);
        Assert.DoesNotContain("configuration", result);
        Assert.Contains("expectation_count", result);
        Assert.Contains("_blind_anonymized", result);
    }

    [Fact]
    public void StripMetadataIdentity_Survives_Invalid_Json()
    {
        var result = BlindAnonymizer.StripMetadataIdentity("not json at all");
        Assert.Equal("not json at all", result); // Returns original on parse failure
    }
}
