#Automation setup configuration
url_vx="https://10.252.9.118/vems/vx.php"
url_cx="https://10.252.9.118/vems/cx.php"
graphql_base_url="https://10.252.9.118/api"


#use headlessmode to run in ubuntu
browser="headlesschrome"
#use this to run on windows
#browser="chrome"


#Credentials to login
ui_username="ideavat"
ui_password="Crick3t!"
#Other username and password is vx/vx,admin/admin


#API Headers
content_type="application/json"
write_api_token="psmY4cNdE7mMEQnrSQ4NGXpr"
query_api_token="EnT4yUynyr2ckUMPfHaSzzwK"


#Terminal Configuration
host_ip="10.252.9.118"
ssh_username="fc"
ssh_password="Id3aV@tAcc3ss" #Id3aV@tAcc3ss

#Expected duration Of test
duration_of_test="0 hours 20 minutes"
#1 hours

#Group Name
group_name= "${groupname}"



#Execution command
#robot --variable environment:config91 -v groupname:General-test Testcases/basicHotAbsoluteGuardTest.robot