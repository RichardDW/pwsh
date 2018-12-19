$mydir = Get-WmiObject -Class Win32_Volume -Filter "Driveletter = 'D:'" |Select-Object -ExpandProperty Label
#$mydir = Get-Volume -DriveLetter W | Select-Object -ExpandProperty FileSystemLabel
New-Item -Path "E:\$mydir" -ItemType Directory
Copy-Item -Path "D:\*.*" -Destination "E:\$mydir\" 