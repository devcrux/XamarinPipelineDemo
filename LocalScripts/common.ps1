function CmdExists {
    param (
        [Parameter(Mandatory)]
        [string]
        $Cmd
    )
    Get-Command $Cmd -ErrorAction SilentlyContinue
}

function ChooseCmd {
    param (
        [Parameter(Mandatory)]
        [string[]]
        $Cmds
    )
    foreach($cmd in $Cmds) {
        if(CmdExists($cmd)) {
            return $cmd
        }
    }
    return $Cmds[0]
}

function MsbuildPath {
    param (
        [string] $Edition,
        [string] $Year = "2019"
    )
    "C:\Program Files (x86)\Microsoft Visual Studio\$Year\$Edition\MSBuild\Current\Bin\MSBuild.exe"
}

function BuildApkAndUiTest {
    [string] $msbuild = ChooseCmd(@(
        "msbuild",
        (MsbuildPath("Enterprise")),
        (MsbuildPath("Professional")),
        (MsbuildPath("Community"))))

    & $msbuild ../$appName.Android/$appName.Android.csproj `
        /p:Configuration=$BuildConfiguration `
        /t:SignAndroidPackage
    & $msbuild ../$uiTestProjName/$uiTestProjName.csproj `
        /p:Configuration=$BuildConfiguration
}

# END OF FUNCTIONS #############################################################

if(!$env:ANDROID_HOME) {
    $env:ANDROID_HOME = "C:\Program Files (x86)\Android\android-sdk"
}

if(!$env:JAVA_HOME) {
    $env:JAVA_HOME = (Get-ChildItem 'C:\Program Files\Android\jdk\*jdk*')[0].FullName
}

[string] $appName = "XamarinPipelineDemo"
[string] $appPackageName = "com.demo.$appName"
[string] $uiTestProjName = "$appName.UITest"
[string] $adb = ChooseCmd(@("adb", "C:\Program Files (x86)\Android\android-sdk\platform-tools\adb.exe"))

$env:UITEST_APK_PATH = "../$appName.Android/bin/$BuildConfiguration/$appPackageName-Signed.apk"

