*** Settings ***
Library    SeleniumLibrary
Variables    ${EXECDIR}/PageObjects/loginPage.py
Variables    ${EXECDIR}/Configurations/${environment}.py
Variables    ${EXECDIR}/Resources/ResourceVariables/globalVariables.py
Variables    ${EXECDIR}/PageObjects/siteEditorHomePage.py
Variables    ${EXECDIR}/Inputs/basicHotAbsoluteGuardInputs.py
Variables   ${EXECDIR}/PageObjects/toolsConfigsPage.py
Resource    apiresources.robot

*** Variables ***
${url_cx}    ${url_cx}
*** Keywords ***
startBrowserAndAccessAIEngineCXWebUI
        #[Arguments]    ${url}    ${browser}    ${expectedTitle}
        open browser    ${url_cx}    ${browser}    options=add_argument("--disable-popup-blocking"); add_argument("--ignore-certificate-errors"); add_argument("--no-sandbox"); add_argument("--disable-extensions"); add_argument("--disable-dev-shm-usage"); add_argument("--window-size=1200,1100"); add_argument("--allow-running-insecure-content")
        maximize browser window
        set browser implicit wait    ${high_speed}
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
    sleep    1 minutes
    wait until element is visible	${tools_button}
    wait until element is enabled	${tools_button}
    click element    ${tools_button}
    sleep    1 minutes
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
    close browser

# Select and click Group Name and click on 'All Properties' button to display all properties
selectAndClickGroupName
    log to console  '${group_name}' group selected
    sleep  ${high_speed}
    # Group drop down list
    click element  ${group_dropdown_list}
    sleep  ${high_speed}

    # Select a Group from drop down list
    ${select_group}=  set variable  xpath=//li[contains(text(),'${group_name}')]

    click element  ${select_group}
    sleep  ${high_speed}
    # Click a Group Name
    ${select_and_click_group}=  set variable  xpath=//span[contains(.,'${group_name}')]
    click element  ${select_and_click_group}
    sleep  ${load_time}

# Click 'All Properties' button to display all properties
clickAllPropertiesButton
    click element  ${all_properties_button}
    sleep  ${high_speed}

# Set Group Property to empty
setGroupPropertyToEmpty
    [Arguments]    ${property}
    ${group_property}=  set variable  //div[contains(text(),'${property}')]/following::td[1]
    sleep  ${high_speed}
    ${property_value}=  get text  ${group_property}
    log to console  ${property} property value is ${property_value}, set through api
    ${IsElementVisible}=  Run Keyword And Return Status    Element Should Be Visible   ${group_property}
    sleep  ${high_speed}
    IF  ${IsElementVisible}
        press keys  ${group_property}  CTRL+a+BACKSPACE+DELETE+ENTER
        ${property_empty_value}=  get text  ${group_property}
        log to console  ${property} property value is ${property_empty_value}empty after setting to empty
        sleep  ${high_speed}
    ELSE
        log to console  ${property} property is not visible
    END
