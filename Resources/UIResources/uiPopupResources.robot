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

*** Keywords ***
popupTestSetup
    [Documentation]    As a setup read all popup titles and messages/popup contents through excel sheet
    log to console    !-----Reading the inputs from the excel and storing in dictionary------!
    testInputs.readingInputsFromExcel  uitest  A  B
    log to console    !-----PreCondition for the popup verification------!

suppressAlarmPopup
    startBrowserAndLoginToAIEngineVX
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
    log to console  Verifying title & message of 'Suppress Alarm' popup  after selecting first record
    click element  ${first_alarm_to_suppress}
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
    startBrowserAndLoginToAIEngineVX
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
    startBrowserAndLoginToAIEngineVX
    log to console  Verifying title & message of 'Set Overrides' popup
    gotoEquipmentTabInVx
    checkWebElementIsVisibleAndIsEnabled  ${set_overrides_button}
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
    startBrowserAndLoginToAIEngineVX
    log to console  Verifying title & message of 'Clear Overrides' popup
    gotoEquipmentTabInVx
    checkWebElementIsVisibleAndIsEnabled  ${clear_overrides_button}
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
    startBrowserAndLoginToAIEngineVX
    log to console  Verifying title & message of 'Show Trends' popup
    gotoEquipmentTabInVx
    checkWebElementIsVisibleAndIsEnabled  ${show_trends_button}
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
    startBrowserAndLoginToAIEngineVX
    log to console  Verifying title & message of 'Bypass' popup
    gotoEquipmentTabInVx
    log to console  'Equipment' tab clicked
    checkWebElementIsVisibleAndIsEnabled  ${bypass_button}
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
