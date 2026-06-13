# .NET MAUI

Mobile and desktop app development: environment setup, diagnostics, lifecycle, navigation, data binding, DI, and theming.

## Environment Check

```bash
dotnet maui-doctor          # Diagnose MAUI development environment
dotnet workload list         # Verify MAUI workload installed

# If missing:
dotnet workload install maui
```

Common `maui-doctor` issues:
- Android SDK missing → install via Android Studio or `dotnet workload install maui-android`
- iOS/Xcode missing (macOS only) → install Xcode
- Windows SDK missing → install via Visual Studio Installer

## App Lifecycle

```csharp
public partial class App : Application
{
    public App()
    {
        InitializeComponent();
    }

    protected override Window CreateWindow(IActivationState? activationState)
    {
        return new Window(new MainPage());
    }
}
```

Lifecycle events on `Window`:
- `Created`, `Activated`, `Deactivated`, `Stopped`, `Resumed`, `Destroying`

## Navigation (Shell)

```xml
<!-- AppShell.xaml -->
<Shell>
    <TabBar>
        <ShellContent Title="Home" ContentTemplate="{DataTemplate local:HomePage}" Route="home" />
        <ShellContent Title="Settings" ContentTemplate="{DataTemplate local:SettingsPage}" Route="settings" />
    </TabBar>
</Shell>
```

```csharp
// Navigate programmatically
await Shell.Current.GoToAsync("//home");
await Shell.Current.GoToAsync("details?id=42");
```

### Dependency Injection

```csharp
// MauiProgram.cs
builder.Services.AddSingleton<MainViewModel>();
builder.Services.AddTransient<DetailsPage>();
builder.Services.AddTransient<DetailsViewModel>();
```

## Data Binding

```xml
<Label Text="{Binding UserName}" />
<Entry Text="{Binding UserName, Mode=TwoWay}" />
<ListView ItemsSource="{Binding Items}" />
```

```csharp
public class MainViewModel : INotifyPropertyChanged
{
    private string _userName = "";
    public string UserName
    {
        get => _userName;
        set { _userName = value; OnPropertyChanged(); }
    }
}
```

Use `[ObservableProperty]` from CommunityToolkit.Mvvm for automatic INPC generation.

## Safe Area (notch/inset handling)

```xml
<ContentPage>
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="{OnIdiom Phone=Auto, Default=0}" />
            <RowDefinition Height="*" />
        </Grid.RowDefinitions>
    </Grid>
</ContentPage>
```

Use `On<iOS>().SetUseSafeArea(true)` or handle via `Shell` for built-in support.

## CollectionView

```xml
<CollectionView ItemsSource="{Binding Items}">
    <CollectionView.ItemTemplate>
        <DataTemplate>
            <Label Text="{Binding Name}" />
        </DataTemplate>
    </CollectionView.ItemTemplate>
</CollectionView>
```

## Theming

```xml
<!-- Light/Dark theme via App.xaml -->
<Application.Resources>
    <ResourceDictionary>
        <Color x:Key="PrimaryColor">#512BD4</Color>
        <Style TargetType="Label">
            <Setter Property="TextColor" Value="{AppThemeBinding Light=Black, Dark=White}" />
        </Style>
    </ResourceDictionary>
</Application.Resources>
```

## Common Issues

| Issue | Fix |
|-------|-----|
| `maui-doctor` fails | Run as admin, check workload list |
| Build hangs | Clear `bin`/`obj`, check NuGet cache |
| Hot reload not working | Ensure Debug config, check VS version |
| Android emulator slow | Use x86_64 image with HAXM/WHPX |
| iOS build fails on Windows | Requires Mac build host (paired) |
| CollectionView empty | Check `ItemsSource` binding, `DataContext` |
| Navigation throws | Check route registration in `AppShell` |

## Validation
- [ ] `dotnet maui-doctor` passes all checks
- [ ] App builds for target platform(s)
- [ ] DI registrations match constructor parameters
- [ ] Bindings have correct `BindingContext`
