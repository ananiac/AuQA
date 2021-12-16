#Automation setup configuration
url_vx="https://10.252.9.37/vems/vx.php"
url_cx="https://10.252.9.37/vems/cx.php"
graphql_base_url="https://10.252.9.37/api"


#use headlessmode to run in ubuntu
browser="headlesschrome"
#use this to run on windows
#browser="chrome"


#Credentials to login
ui_username="crypt:PivxJYkx5umkvqnPiMh/xS5pn5Q5EmQ3/ck3NKZeBkY4mCG9hhFSAbup8pJxPSkVZvPb4C4yAA=="
ui_password="crypt:RpB9EdeyivijyVeDqJk8EpDp50ZrnZsQxFTRW/WUPRM5CCcgUYPU00x9vhp0+Bfixb2hp4QIAfs="
# ui_username="ideavat"
# ui_password="Crick3t!"
#Other username and password is vx/vx,admin/admin


#API Headers
content_type="application/json"
write_api_token="psmY4cNdE7mMEQnrSQ4NGXpr"
query_api_token="EnT4yUynyr2ckUMPfHaSzzwK"


#Terminal Configuration
host_ip="10.252.9.37"
ssh_username="crypt:bq+rmd3qe/Nx07amLAQZKhSzV0SlfDVjIUm3sq7IACuPqgdm/sDZ2PkdsDWO8jcqDKY="
ssh_password="crypt:d8ykbAczunPwNqXg4ZWFuz+rPcl2Bkef10xaEK6/MxbzaPH3ke7yJ+2y4dw2axmTUAZpiwMZtR5vSHZZlg==" #Id3aV@tAcc3ss
# ssh_username="fc"
# ssh_password="Id3aV@tAcc3ss" #Id3aV@tAcc3ss

#Expected duration Of test
duration_of_test="0 hours 20 minutes"
#1 hours

group_name= "${groupname}"

#Execution command
#robot --variable environment:config37  -v groupname:General-test Testcases/basicHotAbsoluteGuardTest.robot