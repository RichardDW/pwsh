Get-ADGroupMember 
# Get members of of group
Get-ADGroupMember -Identity "eu.gpo.W10DeviceGuard.gs" -Server raboneteu| Select-Object Name 
Get-ADGroupMember -Identity "am.gpo.W10DeviceGuard.gs" -Server rabonetam| Select-Object Name
Get-ADGroupMember -Identity "ap.gpo.W10DeviceGuard.gs" -Server rabonetap| Select-Object Name
Get-ADGroupMember -Identity "oc.gpo.W10DeviceGuard.gs" -Server rabonetoc| Select-Object Name
Get-ADGroupMember -Identity "ap.gpo.workstationsscriptauditingenabled.gs" -Server rabonetap| Select-Object Name |Measure-Object
Get-ADGroupMember -Identity "eur.mgt.W10localAdmins.ls" -Server raboneteu| Select-Object Name
Get-ADGroupMember -Identity "eu.mgt.hpa-EURLocalAdminW10-HSG AdminInControl.gs" -Server raboneteu| Select-Object Name |Sort-Object
Get-ADGroupMember -Identity "eu.mgt.hpa-MemberServers-HSG AdminInControl.us" -Server raboneteu| Select-Object Name |Sort-Object
Get-ADGroupMember -Identity "eu.mgt.TechnicalServerSupport.ls" -Server raboneteu| Select-Object Name |Sort-Object
Get-ADGroupMember -Identity "eu.mgt.hpa-EURV130003-AdminInControl.ls" -Server raboneteu| Select-Object Name |Sort-Object
Get-ADGroupMember -Identity "eu.SvcuCMDBwin" -Server raboneteu| Select-Object Name |Sort-Object
Get-ADGroupMember -Identity "eu.mgt.hpa-memberServers-HSG AdminInControl.us" -Server raboneteu| Select-Object Name |Sort-Object
Get-ADGroupMember -Identity "FUN-WINDOWS10-W-S-Local Admin" -Server rabobank| Select-Object Name 
Get-ADGroupMember -Identity "eur.swd.D_Credentialmanager.gs" -Server raboneteu| Select-Object Name 
Get-ADGroupMember -Identity "eu.mgt.DCTSPerm-EURV199011-RDP.ls" -Server raboneteu| Select-Object Name 
Get-ADGroupMember -Identity "eu.mgt.DCTSPerm-EURV199011-EventLog.ls" -Server raboneteu| Select-Object Name 
Get-ADGroupMember -Identity "eu.mgt.DCTSPerm-EURV199011-Admin.ls" -Server raboneteu| Select-Object Name 
Get-ADGroupMember -Identity "eu.mgt.DCTSPerm-EURV130003-Admin.ls" -Server raboneteu | Select-Object Name