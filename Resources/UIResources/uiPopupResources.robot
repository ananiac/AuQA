*** Settings ***
Documentation          This resource file provides the keyword definition specific to Popup messages tests

Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/common.robot
Library    SeleniumLibrary
Variables    ${EXECDIR}/Configurations/${environment}.py
Variables    ${EXECDIR}/PageObjects/systemConsole.py
Resource    ${EXECDIR}/Inputs/testInputs.robot
Variables    ${EXECDIR}/PageObjects/siteEditorHomePage.py

*** Keywords ***
popupTestSetup
    [Documentation]    As a setup read all popup titles and messages/popup contents through excel sheet
    log to console    !-----Reading the inputs from the excel and storing in dictionary------!
    testInputs.readingInputsFromExcel  uitest  A  B

suppressAlarmPopup
    uiresources.startBrowserAndLoginToAIEngineVX
    sleep  ${load_time}
    log to console  Verifying title & message of 'Suppress Alarm' popup
    click element   ${notifications_tab}
    log to console  'Notifications' tab clicked
    sleep  ${load_time}
    click element  ${suppress_alarm_button}
    log to console  'Suppress Alarm' button clicked
    sleep  ${load_time}
    ${expected_title}=  set variable  ${test_input}[suppress_alarm_popup_title]
    verifyPopupTitle  ${popup_title}  ${expected_title}
    ${expected_message}=  set variable  ${test_input}[suppress_alarm_popup_message]
    verifyPopupMessage  ${popup_message}  ${expected_message}
    click element  ${ok_button}
    log to console  'OK' button clicked
    sleep  ${load_time}
    selectAlarm
    sleep  ${load_time}
    log to console  Title & message of 'Suppress Alarm' popup verified successfully
    close browser

selectAlarm
    log to console  Verifying title & message of 'Suppress Alarm' popup after selecting first record
    click element  ${first_alarm_to_suppress}
    sleep  ${load_time}
    ${expected_title1}=  set variable  ${test_input}[suppress_alarm_popup_title]
    ${expected_title2}=  set variable  ${test_input}[dustmotelinepower_popup_title]
    verifySupressAlramPopupTitleOfFirstRecord  ${expected_title1}  ${expected_title2}  ${popup_title}
    ${expected_message1}=  set variable  ${test_input}[suppress_alarm_popup_message]
    ${expected_message2}=  set variable  ${test_input}[dustmotelinepower_popup_message]
    verifySupressAlramPopupMessageOfFirstRecord  ${expected_message1}  ${expected_message2}  ${popup_message}
    sleep  ${load_time}
    click element  ${suppress_alarm_button}
    log to console  'Suppress Alarm' button clicked
    sleep  ${load_time}
    ${expected_title}=  set variable  ${test_input}[suppress_alarm_popup_title]
    verifyPopupTitle  ${popup_title}  ${expected_title}
    ${expected_message}=  set variable  ${test_input}[selected_suppress_alarm_popup_message]
    verifyPopupMessage  ${popup_message}  ${expected_message}
    sleep  ${load_time}
    click element  ${no_button}
    log to console  'No' button clicked

suppressedAlarmsPopup
    uiresources.startBrowserAndLoginToAIEngineVX
    sleep  ${load_time}
    log to console  Verifying title & message of 'Suppressed Alarms' popup
    click element   ${notifications_tab}
    log to console  'Notifications' tab clicked
    sleep  ${load_time}
    click element  ${suppressed_alarms_button}
    log to console  'Suppressed Alarms' button clicked
    sleep  ${load_time}
    ${expected_title}=  set variable  ${test_input}[suppressed_alarm_popup_title]
    verifyPopupTitle  ${suppressed_alarms_popup_title}  ${expected_title}
    click element  ${unsuppress_button}
    log to console  'Unsuppressed' button clicked
    click element  ${ok_button}
    sleep  ${load_time}
    click element  ${unsuppress_all_button}
    log to console  'Unsuppress All' button clicked
    click element  ${no_button}
    log to console  'No' button clicked
    click element  ${close_button}
    log to console  'Close' button clicked
    log to console  Title & message of 'Suppressed Alarms' popup verified successfully
    close browser

setOverridesPopup
    uiresources.startBrowserAndLoginToAIEngineVX
    log to console  Verifying title & message of 'Set Overrides' popup
    uiresources.gotoEquipmentTabInVx
    click element  ${set_overrides_button}
    sleep  ${load_time}
    ${expected_title}=  set variable  ${test_input}[set_overrides_popup_title]
    verifyPopupTitle  ${popup_title}  ${expected_title}
    ${expected_message}=  set variable  ${test_input}[set_overrides_popup_message]
    verifyPopupMessage  ${popup_message}  ${expected_message}
    click element  ${ok_button}
    sleep  ${load_time}
    log to console  Title & message of 'Set Overrides' popup verified successfully
    close browser

clearOverridesPopup
    uiresources.startBrowserAndLoginToAIEngineVX
    log to console  Verifying title & message of 'Clear Overrides' popup
    uiresources.gotoEquipmentTabInVx
    click element  ${clear_overrides_button}
    sleep  ${load_time}
    ${expected_title}=  set variable  ${test_input}[clear_overrides_popup_title]
    verifyPopupTitle  ${popup_title}  ${expected_title}
    ${expected_message}=  set variable  ${test_input}[clear_overrides_popup_message]
    verifyPopupMessage  ${popup_message}  ${expected_message}
    click element  ${ok_button}
    sleep  ${load_time}
    log to console  Title & message of 'Clear Overrides' popup verified successfully
    close browser

verifyPopupTitle
    [Arguments]    ${popup_title}  ${expected_title}
    ${verify_popup_title}=  get text  ${popup_title}
    should be equal	 ${verify_popup_title}  ${expected_title}
    log to console  Popup title is "${verify_popup_title}"
    sleep  ${load_time}

verifyPopupMessage
    [Arguments]    ${popup_message}  ${expected_message}
    ${verify_popup_message}=  get text  ${popup_message}
    should be equal	 ${verify_popup_message}  ${expected_message}
    log to console  Popup message is "${verify_popup_message}"
    sleep  ${load_time}

showTrendsPopup
    uiresources.startBrowserAndLoginToAIEngineVX
    log to console  Verifying title & message of 'Show Trends' popup
    uiresources.gotoEquipmentTabInVx
    click element  ${show_trends_button}
    sleep  ${load_time}
    ${expected_title}=  set variable  ${test_input}[show_trends_popup_title]
    verifyPopupTitle  ${popup_title}  ${expected_title}
    ${expected_message}=  set variable  ${test_input}[show_trends_popup_message]
    verifyPopupMessage  ${popup_message}  ${expected_message}
    click element  ${ok_button}
    sleep  ${load_time}
    log to console  Title & message of 'Show Trends' popup verified successfully
    close browser

bypassPopup
    uiresources.startBrowserAndLoginToAIEngineVX
    log to console  Verifying title & message of 'Bypass' popup
    uiresources.gotoEquipmentTabInVx
    log to console  'Equipment' tab clicked
    click element  ${bypass_button}
    log to console  'Bypass' button clicked
    sleep  ${load_time}
    ${expected_title}=  set variable  ${test_input}[bypass_popup_title]
    verifyPopupTitle  ${popup_title}  ${expected_title}
    ${expected_message}=  set variable  ${test_input}[bypass_popup_message]
    verifyPopupMessage  ${popup_message}  ${expected_message}
    click element  ${no_button}
    sleep  ${load_time}
    log to console  Title & message of 'Bypass' popup verified successfully
    close browser

verifySupressAlramPopupTitleOfFirstRecord
    [Arguments]      ${expected_title1}  ${expected_title2}  ${popup_title}
    ${verify_popup_title}=  get text  ${popup_title}
    ${expected_title1}=  convert to string  ${expected_title1}
    ${expected_title2}=  convert to string  ${expected_title2}
    IF  """${verify_popup_title}""" == ""
        log to console  Normal alarm
    ELSE
        log to console  Dust alarm
        click element  ${ok_button}
        log to console  'OK' button clicked
    END

verifySupressAlramPopupMessageOfFirstRecord
    [Arguments]      ${expected_message1}  ${expected_message2}  ${popup_message}
    ${verify_popup_message}=  get text  ${popup_message}
    ${expected_message1}=  convert to string  ${expected_message1}
    ${expected_message2}=  convert to string  ${expected_message2}
    IF  """${verify_popup_message}""" == ""
        log to console  Normal alarm
    ELSE
        log to console  Dust alarm
        click element  ${ok_button}
        log to console  'OK' button clicked
    END

verifySystemPropertySFCMinSetToBlank
    uiresources.startBrowserAndLoginToAIEngine
    toolsDropDownListClick
    configsOptionInToolsClick
    systemOptionInConfigsOptionInToolsClick
    press keys  ${sfc_min}  CTRL+a+BACKSPACE+DELETE+ENTER
    log to console  Set 'SFCMin' system property to blank
    sleep    ${load_time}
    ${expected_title}=  set variable  ${test_input}[validation_error_popup_title]
    verifyPopupTitle  ${popup_title}  ${expected_title}
    ${expected_message}=  set variable  ${test_input}[sfcmin_popup_message]
    verifyPopupMessage  ${popup_message}  ${expected_message}
    click element  ${ok_button}
    log to console  'OK' button clicked of 'Validation Error' popup
    sleep  ${load_time}
    log to console  Title & message of 'Validation Error' popup verified successfully
    close browser

savePopup
    uiresources.startBrowserAndLoginToAIEngine
    toolsDropDownListClick
    configsOptionInToolsClick
    systemOptionInConfigsOptionInToolsClick
    press keys  ${sfc_min}  ENTER
    saveButtonClick
    ${expected_title}=  set variable  ${test_input}[save_popup_title]
    verifyPopupTitle  ${popup_title}  ${expected_title}
    ${expected_message}=  set variable  ${test_input}[save_popup_message]
    verifyPopupMessage  ${popup_message}  ${expected_message}
    okButtonClick
    log to console  Title & message of 'Save' popup verified successfully
    close browser

validationErrorForTurnOffLimit24Hr
    uiresources.startBrowserAndLoginToAIEngine
    toolsDropDownListClick
    configsOptionInToolsClick
    dashmOptionInConfigsOptionInToolsClick
    press keys  ${turn_off_limit_24_hr}  CTRL+a+BACKSPACE+DELETE
    press keys  ${turn_off_limit_24_hr}  -2+TAB
    log to console  Set 'TurnOffLimit24Hr' system property to -2
    sleep    ${load_time}
    ${expected_title}=  set variable  ${test_input}[validation_error_popup_title]
    verifyPopupTitle  ${popup_title}  ${expected_title}
    ${expected_message}=  set variable  ${test_input}[turn_off_limit_24_hr_popup_message]
    verifyPopupMessage  ${popup_message}  ${expected_message}
    okButtonClick
    log to console  Title & message of 'Validation Error' (for 'TurnOffLimit24Hr' field) popup verified successfully
    close browser

unsavedChanges
    uiresources.startBrowserAndLoginToAIEngine
    toolsDropDownListClick
    configsOptionInToolsClick
    dashmOptionInConfigsOptionInToolsClick
    press keys  ${turn_off_limit_24_hr}  CTRL+a+2
    press keys  ${turn_off_limit_24_hr}  2
    log to console  Set 'TurnOffLimit24Hr' system property to 2
    closeButtonClick
    ${expected_title}=  set variable  ${test_input}[unsaved_changes_popup_title]
    verifyPopupTitle  ${popup_title}  ${expected_title}
    ${expected_message}=  set variable  ${test_input}[unsaved_changes_popup_message]
    verifyPopupMessage  ${popup_message}  ${expected_message}
    yesButtonClick
    log to console  Title & message of 'Validation Error' (for 'TurnOffLimit24Hr' field) popup verified successfully
    close browser

toolsDropDownListClick
    sleep    ${load_time}
    wait until element is visible	${tools_button}
    wait until element is enabled	${tools_button}
    click element    ${tools_button}
    log to console  'Tools' drop down list clicked

configsOptionInToolsClick
    sleep    ${load_time}
    wait until element is visible	 ${configs_option_in_tools}
    wait until element is enabled	 ${configs_option_in_tools}
    click element    ${configs_option_in_tools}
    log to console  'Configs' option clicked

systemOptionInConfigsOptionInToolsClick
    sleep    ${load_time}
    wait until element is visible	 ${tools_configs_system}
    wait until element is enabled	 ${tools_configs_system}
    click element  ${tools_configs_system}
    log to console  'SYSTEM' option clicked

dashmOptionInConfigsOptionInToolsClick
    sleep    ${load_time}
    wait until element is visible	 ${tools_configs_dashm}
    wait until element is enabled	 ${tools_configs_dashm}
    click element  ${tools_configs_dashm}
    log to console  'DASHM' option clicked

okButtonClick
    sleep    ${load_time}
    click element  ${ok_button}
    log to console  'OK' button clicked

closeButtonClick
    sleep    ${load_time}
    click element  ${close_button}
    log to console  'Close' button clicked

saveButtonClick
    sleep  ${load_time}
    click element  ${save_button}
    log to console  'Save' button clicked

yesButtonClick
    sleep  ${load_time}
    click element  ${yes_button}
    log to console  'Yes' button clicked