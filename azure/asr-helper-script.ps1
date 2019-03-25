# create VM list
ise .\vmlist.txt

# Discover Hyper-V hosts and VMs
.\ASRDeploymentPlanner.exe -Operation GetVMlist -ServerListFile ".\vmlist.txt" -Virtualization Hyper-V -User "company\tim" -OutputFile "C:\ASR\VMListFileOutput2.txt"
ise .\VMListFileOutput.txt

# Profile for 60 minutes
.\ASRDeploymentPlanner.exe -Operation StartProfiling -Virtualization Hyper-V -Directory "C:\ASR\ProfiledData" -VMListFile "C:\ASR\VMListFileOutput.txt"  -NoOfMinutesToProfile 60 -User "company\tim"

# Generate the report
.\ASRDeploymentPlanner.exe -Operation GenerateReport -Virtualization Hyper-V -Directory "C:\ASR\ProfiledData" -VMListFile "C:\ASR\VMListFileOutput.txt"





