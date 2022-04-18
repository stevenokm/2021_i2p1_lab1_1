$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
$prefix = "lab1_1"
$oc = ("grade_" + $prefix + ".csv")
# remember to change both run.bash and CMakeList.txt files to the correct lab name
$testbench = "testbench"
$build_dir = "build"
$jplag_dir = "jplag"
$jplag_result_dir = "jplag_result"
$timeout_sec = "10"
$src_dir = "src"

Set-Location ($testbench)
$if1_list = Get-childitem `
    -Include ($prefix + "_*.in") `
    -Name `
    *
$if1_count = $if1_list.Count
Write-Output $if1_list $if1_count.ToString()
Set-Location ("..")

$dir_list = Get-childitem `
    -Depth 0 `
    -Directory `
    -Name `
    -Exclude $testbench, $build_dir, $jplag_dir, $jplag_result_dir, ".*", $src_dir `
    "."
$dir_count = $dir_list.Count
Write-Output $dir_list $dir_count.ToString()

Write-Output "copy source files"
if (!(Test-Path $src_dir)) {
    New-Item -ItemType Directory -Force -Path $src_dir
}
foreach ($i in $dir_list) {
    $i_list = $i.Split(" ")
    $student_id = $i_list[0]
    $student_dir = ($src_dir + "\" + $student_id)
    if (!(test-path $student_dir)) {
        New-Item -ItemType Directory -Force -Path $student_dir
    }
    Copy-Item -Path "$i\*" -Destination $student_dir -Recurse -Force
}

Write-Output "build cpp"
if (!(Test-Path $build_dir)) {
    New-Item -ItemType Directory -Force -Path $build_dir
}
Set-Location ($build_dir)
cmake .. -G "MinGW Makefiles"
make -k
Set-Location ("..")

# Create CSV file
# Ref: https://mcpmag.com/articles/2017/06/08/creating-csv-files-with-powershell.aspx

if (Test-Path $oc) {
    Remove-Item -Force -Path $oc
}
Add-Content -Path ($oc) -Value 'SID, Correctness'
foreach ($i in $dir_list) {
    $i_list = $i.Split(" ")
    $student_id = $i_list[0]
    $p1_1c = 0
    $p1_ca = 0
    $error_list = @()
    $student_exe = ($build_dir + "\" + $prefix + "_" + $student_id + ".exe")
    Write-Output "eval $student_exe"
    if (!(Test-Path $student_exe)) {
        Write-Output "$student_exe not exist, skip."
        foreach ($file in $if1_list) {
            $error_list = "$error_list" + ", $file"
        }
    }
    else {
        foreach ($file in $if1_list) {
            $if1 = $file
            $of1 = $i + "\" + $if1.Split(".")[0] + ".out"
            $log1 = $i + "\" + $if1.Split(".")[0] + ".log"
            $golden_of1 = $testbench + "\" + $if1.Split(".")[0] + ".out"
            $if1 = $testbench + "\" + $if1
            Write-Output ("$student_exe < $if1 | tr -d \n > $of1; cat ${log1} >> ${of1};" `
                    + " diff -w -B -i $golden_of1 $of1 > $log1")
            # Spawn a child process:
            # Ref: https://stackoverflow.com/a/36934083
            # $student_exe < $if1 > $of1
            $student_exe_proc = Start-Process -FilePath $student_exe `
                -RedirectStandardInput $if1 `
                -RedirectStandardOutput $of1 `
                -RedirectStandardError $log1 `
                -Passthru
            $timeouted = $null
            $student_exe_proc | Wait-Process `
                -Timeout $timeout_sec `
                -ErrorAction SilentlyContinue `
                -ErrorVariable timeouted
            if ($timeouted) {
                Write-Output "timeout"
                $student_exe_proc | Stop-Process -Force
            }
            # | tr -d \n > $of1
            $tmpfile = New-TemporaryFile
            (Get-Content $of1) | Set-Content $tmpfile -NoNewline
            Copy-Item $tmpfile $of1
            Remove-Item $tmpfile
            # cat ${log1} >> ${of1};
            (Get-Content $log1) | Out-File -Append -NoNewline $of1
            # diff -w -B -i $golden_of1 $of1 > $log1
            # Note: remove '\n', ' ', '\t' and '\r' to ingore line and space changes
            # and change to upper case to ignore case changes
            $of1_content = ((Get-Content $of1) -replace '\n| |\t|\r', '').ToUpper()
            $golden_of1_content = ((Get-Content $golden_of1) -replace '\n| |\t|\r', '').ToUpper()
            if ($of1_content -and $golden_of1_content) {
                $result = Compare-Object $golden_of1_content $of1_content
            }
            # if the output file is empty, it will be considered as wrong
            # and use '-1' to indicate wrong
            else {
                $result = -1
            }
            Set-Content -Path $log1 -Value $result
            if ($result -ne -1 -and $result.Count -eq 0) {
                $p1_1c = 100;
                $p1_ca = ($p1_ca + $p1_1c)
            }
            else {
                $error_list = "$error_list" + ", $file"
            }
        }
    }
    $p1_ca = $p1_ca / $if1_count
    Add-Content -Path ($oc) -Value ($i + ", " + $p1_ca + $error_list)
}
# pause
Read-Host -Prompt "Press Enter to Continue"
