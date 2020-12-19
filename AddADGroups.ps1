$GROUPNAME= "CfgMgr_Architects_Store1", "CfgMgr_Architects_Server1", "CfgMgr_Architects_POS", "CfgMgr_Architects_Client", "CfgMgr_Architects", "CfgMgr_Admins_Store", "CfgMgr_Admins_Server", "CfgMgr_Admins_POS", "CfgMgr_Admins_Clients", "CfgMgr_Servers", "CfgMgr_Operators_Server", "CfgMgr_Operators_POS", "CfgMgr_Operators_Client"
foreach ($USERNAME in $GROUPNAME){
New-ADGroup -Name $USERNAME -GroupScope Global -GroupCategory Security -Path "OU=Administrative,OU=Support,DC=dus,DC=meijer,DC=com"
}