*** Settings ***
Library    SeleniumLibrary
Variables    ${EXECDIR}/PageObjects/loginPage.py
Variables    ${EXECDIR}/Configurations/${environment}.py
Variables    ${EXECDIR}/Resources/ResourceVariables/globalVariables.py

*** Variables ***


*** Keywords ***
startBrowserAndAccessAIEngineWebUI
        #[Arguments]    ${url_vx}    ${browser}    ${expectedTitle}
        open browser    ${url_vx}    ${browser}    options=add_argument("--disable-popup-blocking"); add_argument("--ignore-certificate-errors"); add_argument("--no-sandbox"); add_argument("--disable-extensions"); add_argument("--disable-dev-shm-usage")
        maximize browser window
        set browser implicit wait    ${high_speed}
        log to console    Accessed AI Engine
verifyTitle
        title should be    ${page_title}
        log to console    Title verified---!
loginByEnteringUsernameAndPassword
    #[Arguments]    ${username}    ${password}
    log to console    Entering user name and password
    input text    ${uname}    ${ui_password}
    input text    ${upwd}    ${ui_password}
    capture page screenshot    ./Reports/Screenshots/inputUserNameAndPwd_1.png
    click element    ${login_button}
    set selenium timeout    ${low_speed}
    wait until page contains    All Groups in Control
    capture page screenshot    ./Reports/Screenshots/systemConsoleHomePage_2.png
    log to console    Logged in succesfully
startBrowserAndLoginToAIEngine
    startBrowserAndAccessAIEngineWebUI
    loginByEnteringUsernameAndPassword
openEquipmentTabToCheckTheCoolingUnitStatus
    set selenium timeout    ${medium_speed}
    wait until element is enabled    css:span#tab-1311-btnInnerEl
    click element    css:span#tab-1311-btnInnerEl
    wait until page contains    CONTROL
    capture page screenshot    ./Reports/Screenshots/systemConsoleEquipmentTab_3.png
    page should not contain element    xpath://div[contains(text(),'GUARD')]
openSystemConsoleEquipmentTabToCheckGuardModeONForCoolingUnits
    gotoSystemConsolePage
    openEquipmentTab
    reload page
    wait until page contains    Cooling
    set selenium timeout    ${low_speed}
    ${status}=    run keyword and ignore error    page should not contain   xpath://div[text()='GUARD']
    run keyword if    ${status} == 'PASS'    reload page
    wait until page contains    Cooling
    wait until page contains element    xpath://div[text()='GUARD']
    page should contain element   xpath://div[text()='GUARD']
    sleep    ${high_speed}
    capture page screenshot    ./Reports/Screenshots/GuardMode_5.png
openEquipmentTab
    click link    Equipment
    wait until page contains    CONTROL
    log to console    Equipment tab is open --->

openSiteEditorPage
    click element    css:span#button-1306-btnIconEl
    wait until page contains    Site Model
    wait until page contains    Rack
    capture page screenshot    ./Reports/Screenshots/siteEditor_4.png
    ${urls}    get location
    log to console    ${urls}
    log to console    Site Editor is open --->
gotoSystemConsolePage
    go to    ${url_vx}
    sleep    ${medium_speed}    #Need to check the timing
    log to console    System Console is open
gotoSiteEditorPage
    go to    ${url_cx}
    log to console    Site Editor is open --->
changeAbsoluteHotGuardTemperatureTo3Degree
    click element    xpath://span[@class='x-tree-node-text ' and text()='04B1']
    wait until page contains element    xpath://*[contains(text(),'GuardHotAbsTemp')]/following::td[1]
    double click element    xpath://*[contains(text(),'GuardHotAbsTemp')]/following::td[1]
    press keys    xpath://*[contains(text(),'GuardHotAbsTemp')]/following::td[1]     \ue003
    #press keys    xpath://*[contains(text(),'GuardHotAbsTemp')]/following::td[1]    3
    press keys    xpath://*[contains(text(),'GuardHotAbsTemp')]    \\13
    log to console    Absolute HotGuard temperature to 3 degree------>
changeAbsoluteHotGuardTemperatureTo34Degree
    log to console    Reset the configuration--->
    click element    css:#combo-1023-inputEl
    wait until page contains element    xpath://*[contains(text(),'GuardHotAbsTemp')]/following::td[1]
    double click element    xpath://*[contains(text(),'GuardHotAbsTemp')]/following::td[1]
    press keys    xpath://*[contains(text(),'GuardHotAbsTemp')]/following::td[1]     4
    #press keys    xpath://*[contains(text(),'GuardHotAbsTemp')]/following::td[1]    3
    press keys    xpath://*[contains(text(),'GuardHotAbsTemp')]    \\13
    log to console    Absolute Hot Guard temperature changed to 34 degree------!
    log to console    ***********************************************************




