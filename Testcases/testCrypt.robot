*** Settings ***
Documentation         This is test the encrypt and decrypt function
Library    SeleniumLibrary
#Library    SSHLibrary
#Library     CryptoLibrary    %{private_key_password}    variable_decryption=True
#Library     CryptoLibrary  variable_decryption=True  key_path=C:\\home\\fc\\automation\\AuQA\\venv\\Lib\\site-packages\\CryptoLibrary\\keys
Library    CryptoLibrary  variable_decryption=True  key_path=${EXECDIR}/Inputs/keys
Variables    ../PageObjects/loginPage.py                #${EXECDIR}
Resource    ../Resources/connection.robot



*** Variables ***
${url_cx}   https://10.252.9.64/vems/vx.php
${browser}  headlesschrome
${ui_username}  crypt:PivxJYkx5umkvqnPiMh/xS5pn5Q5EmQ3/ck3NKZeBkY4mCG9hhFSAbup8pJxPSkVZvPb4C4yAA==
${ui_password}  crypt:RpB9EdeyivijyVeDqJk8EpDp50ZrnZsQxFTRW/WUPRM5CCcgUYPU00x9vhp0+Bfixb2hp4QIAfs=
${host}               10.252.9.64
${username}            crypt:bq+rmd3qe/Nx07amLAQZKhSzV0SlfDVjIUm3sq7IACuPqgdm/sDZ2PkdsDWO8jcqDKY=
${password}            crypt:d8ykbAczunPwNqXg4ZWFuz+rPcl2Bkef10xaEK6/MxbzaPH3ke7yJ+2y4dw2axmTUAZpiwMZtR5vSHZZlg==

*** Test Cases ***
TestLogin
    open browser    ${url_cx}    ${browser}    options=add_argument("--disable-popup-blocking"); add_argument("--ignore-certificate-errors"); add_argument("--no-sandbox"); add_argument("--disable-extensions"); add_argument("--disable-dev-shm-usage"); add_argument("--window-size=1200,1100"); add_argument("--allow-running-insecure-content")
    maximize browser window
    set browser implicit wait    6
    log to console    Accessed AI Engine
    log to console    Entering user name and password
    input text    ${uname}    ${ui_username}
    input text    ${upwd}    ${ui_password}
    click element    ${login_button}
    close browser

TestSSH
    log to console    !--------Opening SSH Connection----------!
    open connection     ${host}
    login               ${username}        ${password}
    ${current_status}=  executeCommandToCheckProcessStatus  vx_server
    connection.closeAllConnections
    log to console    ${current_status}
    closeAllConnections
