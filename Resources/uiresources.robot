*** Settings ***
Library    SeleniumLibrary
Variables    ${EXECDIR}/PageObjects/loginPage.py
Variables    ${EXECDIR}/Configurations/${environment}.py
Resource    ${EXECDIR}/Inputs/testInputs.robot
Variables    ${EXECDIR}/PageObjects/siteEditorHomePage.py
Variables   ${EXECDIR}/PageObjects/toolsConfigsPage.py
Resource    apiresources.robot
Variables    ${EXECDIR}/PageObjects/vxEquipmentTab.py


*** Variables ***
${url_cx}    ${url_cx}


*** Keywords ***
startBrowserAndAccessAIEngineCXWebUI
        #[Arguments]    ${url}    ${browser}    ${expectedTitle}
        open browser    ${url_cx}    ${browser}    options=add_argument("--disable-popup-blocking"); add_argument("--ignore-certificate-errors"); add_argument("--no-sandbox"); add_argument("--disable-extensions"); add_argument("--disable-dev-shm-usage"); add_argument("--window-size=1200,1100"); add_argument("--allow-running-insecure-content")
        maximize browser window
        set browser implicit wait    ${short_wait_time}
        log to console    Accessed AI Engine

verifyTitle
        title should be    ${page_title}
        log to console    Title verified---!

loginByEnteringUsernameAndPassword
    #[Arguments]    ${username}    ${password}
    log to console    Entering user name and password
    input text    ${uname}    ${ui_username}
    input text    ${upwd}    ${ui_password}
    takeScreenshot  InputUserNameAndPwd
    click element    ${login_button}
    wait until page contains element   ${banner}
    wait until element is enabled    ${tools_button}
    takeScreenshot  SiteEditorHomePage
    log to console    Logged in successfully

startBrowserAndLoginToAIEngine
    startBrowserAndAccessAIEngineCXWebUI
    loginByEnteringUsernameAndPassword

resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    apiresources.setConfigAlarmGroupDeadSensorHysteresis    11
    startBrowserAndLoginToAIEngine
    set selenium timeout    ${long_wait_time}
    wait until element is visible	${tools_button}
    wait until element is enabled	${tools_button}
    click element    ${tools_button}
    wait until element is visible	 ${configs_option_in_tools}
    wait until element is enabled	 ${configs_option_in_tools}
    click element    ${configs_option_in_tools}
    sleep    ${load_time}
    wait until element is visible    ${load_template_in_config_popup}
    wait until element is enabled    ${load_template_in_config_popup}
    click element    ${load_template_in_config_popup}
    click element    ${template_dropbox_picker}
    IF    "${groupname}"=="RSP-test"
        click element    ${template_option_RSP}
    ELSE
        click element    ${template_option}
    END
    click element    ${temperature_scale_dropbox_picker}
    click element    ${temperature_scale_option}
    select checkbox    ${overwrite_checkbox}
    click element    ${apply_button_load_template}
    click element    ${save_button}
    log to console    Loaded default template succesfully
    sleep    ${load_time}
    wait until element is visible    ${close_button}
    click element    ${close_button}
    wait until element is not visible    ${close_button}
    log to console    !-----------Closed config popup------------------!
    set selenium timeout    ${short_wait_time}
    close browser

# Select and click Group Name and click on 'All Properties' button to display all properties
selectAndClickGroupName
    log to console  '${group_name}' group selection
    set selenium timeout    ${long_wait_time}
    sleep  ${short_wait_time}
    click element  ${group_dropdown_list}
    sleep  ${short_wait_time}
    ${select_group}=  set variable  xpath=//li[contains(text(),'${group_name}')]
    click element  ${select_group}
    sleep  ${short_wait_time}
    ${select_and_click_group}=  set variable  xpath=//span[contains(.,'${group_name}')]
    click element  ${select_and_click_group}
    sleep  ${load_time}
    set selenium timeout    ${short_wait_time}

# Click 'All Properties' button to display all properties
clickAllPropertiesButton
    click element  ${all_properties_button}
    sleep  ${short_wait_time}

# Set Group Property to empty
setGroupPropertyToEmpty
    [Arguments]    ${property}
    ${group_property}=  set variable  //div[contains(text(),'${property}')]/following::td[1]
    sleep  ${short_wait_time}
    set selenium timeout    ${long_wait_time}
    ${property_value}=  get text  ${group_property}
    log to console  ${property} property value is currently ${property_value}, set through api
    ${IsElementVisible}=  Run Keyword And Return Status    Element Should Be Visible   ${group_property}
    sleep  ${short_wait_time}
    IF  ${IsElementVisible}
        press keys  ${group_property}  CTRL+a+BACKSPACE+DELETE+ENTER
        ${property_empty_value}=  get text  ${group_property}
        log to console  ${property} property value is set to ${property_empty_value}EMPTY
        sleep  ${short_wait_time}
    ELSE
        log to console  ${property} property is not visible
    END
    set selenium timeout    ${short_wait_time}

startBrowserAndLoginToAIEngineVX
    startBrowserAndAccessVXWebUI
    loginByEnteringUsernameAndPasswordVX

startBrowserAndAccessVXWebUI
    #[Arguments]    ${url}    ${browser}    ${expectedTitle}
    open browser    ${url_vx}    ${browser}    options=add_argument("--disable-popup-blocking"); add_argument("--ignore-certificate-errors"); add_argument("--no-sandbox"); add_argument("--disable-extensions"); add_argument("--disable-dev-shm-usage"); add_argument("--window-size=1200,1100"); add_argument("--allow-running-insecure-content")
    maximize browser window
    set browser implicit wait    ${short_wait_time}
    log to console    Accessed VX Web UI

loginByEnteringUsernameAndPasswordVX
    #[Arguments]    ${username}    ${password}
    log to console    Entering user name and password
    input text    ${uname}    ${ui_username}
    input text    ${upwd}    ${ui_password}
    takeScreenshot  InputUserNameAndPwd
    click element    ${login_button}
    wait until page contains element   ${banner}
    log to console    Logged in successfully

selectGroupUnderTestInVx
    sleep  ${load_time}
    checkWebElementIsVisibleAndIsEnabled  ${group_dropdown_list_vx}
    click element  ${group_dropdown_list_vx}
    ${select_group}=  set variable  xpath=//li[contains(text(),'${group_name}')]
    checkWebElementIsVisibleAndIsEnabled  ${select_group}
    click element  ${select_group}
    log to console  '${group_name}' group selected

gotoEquipmentTabInVx
    sleep  ${load_time}
    checkWebElementIsVisibleAndIsEnabled  ${equipment_tab}
    click element  ${equipment_tab}
    sleep  ${load_time}

setOverrideValueOfSingleAHU
    [Arguments]    ${ahu}  ${on_off_auto_value}  ${supply_fan_control_value}
    ${ahu_record}=  set variable  xpath=//div[contains(text(),'${ahu}')]
    checkWebElementIsVisibleAndIsEnabled  ${ahu_record}
    press keys  ${ahu_record}  SHIFT
    checkWebElementIsVisibleAndIsEnabled  ${set_overrides_button}
    click element  ${set_overrides_button}
    checkWebElementIsVisibleAndIsEnabled  ${on_off_auto_dropdown_list}
    click element  ${on_off_auto_dropdown_list}
    ${on_off_auto_current_value}=  set variable  xpath=//li[contains(text(),'${on_off_auto_value}')]
    checkWebElementIsVisibleAndIsEnabled  ${on_off_auto_current_value}
    click element  ${on_off_auto_current_value}
    checkWebElementIsVisibleAndIsEnabled  ${supply_fan_control_textbox}
    press keys  ${supply_fan_control_textbox}  ${supply_fan_control_value}
    checkWebElementIsVisibleAndIsEnabled  ${supply_fan_control_textbox}
    takeScreenshot  SetAHUToOverride-${ahu}
    press keys  ${supply_fan_control_textbox}  TAB
    checkWebElementIsVisibleAndIsEnabled  ${set_overrides_save_button}
    click element  ${set_overrides_save_button}
    log to console  !---AHU->${ahu} is overridden from UI with ON/OFF=${on_off_auto_value} ,Supply Fan Control=${supply_fan_control_value}--!

checkWebElementIsVisibleAndIsEnabled
    [Arguments]    ${webElement}
    set selenium timeout  ${long_wait_time}
    wait until element is visible  ${webElement}
    wait until element is enabled  ${webElement}
    set selenium timeout  ${short_wait_time}

overrideNamedAHUWithSpecifiedBOPAndSFCValuesFromUI
    [Arguments]    ${ahu_name}    ${bop_value}    ${sfc_value}
    startBrowserAndLoginToAIEngineVX
    selectGroupUnderTestInVx
    gotoEquipmentTabInVx
    setOverrideValueOfSingleAHU  ${ahu_name}  ${bop_value}  ${sfc_value}
    set selenium timeout  ${short_wait_time}
    close browser

    #Created by Greeshma on 3rd Nov 2021
setListedGroupPropertiesToEmpty
    [Arguments]    @{properties_list}
    sleep  ${load_time}
    uiresources.startBrowserAndLoginToAIEngine
    sleep  ${load_time}
    uiresources.selectAndClickGroupName
    uiresources.clickAllPropertiesButton
    FOR    ${property}    IN    @{properties_list}
        uiresources.setGroupPropertyToEmpty  ${property}
    END
    close browser