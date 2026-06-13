using SkillCreator.Cli.Tools;

namespace SkillCreator.Cli.Tests;

public class PackagerTests
{
    private string CreateTempSkill()
    {
        var dir = Path.Combine(Path.GetTempPath(), $"skill-test-{Guid.NewGuid():N}");
        Directory.CreateDirectory(dir);
        File.WriteAllText(Path.Combine(dir, "SKILL.md"),
            "---\nname: test-skill\ndescription: A package test skill\n---\n\n# Test Skill\n\nBody content.");
        // Create a reference file
        Directory.CreateDirectory(Path.Combine(dir, "references"));
        File.WriteAllText(Path.Combine(dir, "references", "guide.md"), "# Reference Guide");
        // Create a bin directory (should be excluded)
        Directory.CreateDirectory(Path.Combine(dir, "bin"));
        File.WriteAllText(Path.Combine(dir, "bin", "output.dll"), "binary");
        // Create an obj directory (should be excluded)
        Directory.CreateDirectory(Path.Combine(dir, "obj"));
        File.WriteAllText(Path.Combine(dir, "obj", "temp.json"), "{}");
        return dir;
    }

    private void CleanupDir(string dir)
    {
        if (Directory.Exists(dir))
            Directory.Delete(dir, true);
    }

    [Fact]
    public async Task Package_Contains_SkillMd()
    {
        var dir = CreateTempSkill();
        try
        {
            var packager = new Packager(dir);
            var outputPath = await packager.PackageAsync();

            Assert.True(File.Exists(outputPath));
            Assert.EndsWith(".zip", outputPath);

            using var zip = System.IO.Compression.ZipFile.OpenRead(outputPath);
            Assert.Contains(zip.Entries, e => e.Name == "SKILL.md");
        }
        finally
        {
            CleanupDir(dir);
        }
    }

    [Fact]
    public async Task Package_Excludes_Bin_Obj()
    {
        var dir = CreateTempSkill();
        try
        {
            var packager = new Packager(dir);
            var outputPath = await packager.PackageAsync();

            using var zip = System.IO.Compression.ZipFile.OpenRead(outputPath);
            Assert.DoesNotContain(zip.Entries, e => e.FullName.Contains("bin/"));
            Assert.DoesNotContain(zip.Entries, e => e.FullName.Contains("obj/"));
        }
        finally
        {
            CleanupDir(dir);
        }
    }

    [Fact]
    public async Task Package_Includes_References()
    {
        var dir = CreateTempSkill();
        try
        {
            var packager = new Packager(dir);
            var outputPath = await packager.PackageAsync();

            using var zip = System.IO.Compression.ZipFile.OpenRead(outputPath);
            Assert.Contains(zip.Entries, e => e.FullName.Contains("references/guide.md"));
        }
        finally
        {
            CleanupDir(dir);
        }
    }

    [Fact]
    public void Security_Scan_Passed_Returns_False_When_No_Marker()
    {
        var dir = CreateTempSkill();
        try
        {
            var packager = new Packager(dir);
            Assert.False(packager.HasSecurityScanPassed());
        }
        finally
        {
            CleanupDir(dir);
        }
    }

    [Fact]
    public void Security_Scan_Passed_Returns_True_When_Marker_Exists()
    {
        var dir = CreateTempSkill();
        try
        {
            File.WriteAllText(Path.Combine(dir, ".security-scan-passed"), "scanned");
            var packager = new Packager(dir);
            Assert.True(packager.HasSecurityScanPassed());
        }
        finally
        {
            CleanupDir(dir);
        }
    }
}
