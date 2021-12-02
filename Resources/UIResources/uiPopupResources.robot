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
    testInputs.readingInputsFromExcel  popuptitlesmessages  A  B
    log to console    !-----PreCondition for the popup verification------!

suppressAlarmPopup
    startBrowserAndLoginToAIEngineVX
    set selenium timeout  ${short_wait_time}
    sleep  ${load_time}
    click element   ${notifications_tab}
    set selenium timeout  ${short_wait_time}
    sleep  ${load_time}
    click element  ${suppress_alarm_button}
    ${verify_suppress_alarm_popup_title}=  get text  ${suppress_alarm_title}
    should be equal	 ${verify_suppress_alarm_popup_title}  ${test_input}[suppress_alarm_popup_title]
    log to console  Popup title is "${verify_suppress_alarm_popup_title}"
    set selenium timeout  ${short_wait_time}
    sleep  ${load_time}
    ${popup_message}=  get text  ${suppress_alarm_popup_message}
    should be equal	 ${popup_message}  ${test_input}[suppress_alarm_popup_message]
    log to console  Popup message is "${popup_message}"
    click element  ${suppress_alarm_ok_button}
    selectAlarm
    sleep  ${load_time}
    close browser

selectAlarm
    click element  xpath=//table[3]/tbody/tr/td[3]/div
    sleep  ${load_time}
    click element  ${suppress_alarm_button}
    ${verify_suppress_alarm_popup_title}=  get text  ${suppress_alarm_title}
    should be equal	 ${verify_suppress_alarm_popup_title}  ${test_input}[suppress_alarm_popup_title]
    log to console  Popup title is "${verify_suppress_alarm_popup_title}"
    set selenium timeout  ${short_wait_time}
    sleep  ${load_time}
    ${popup_message}=  get text  ${suppress_alarm_popup_message}
    should be equal	 ${popup_message}  ${test_input}[selected_suppress_alarm_popup_message]
    log to console  Popup message is "${popup_message}"
    sleep  ${load_time}
    click element  ${suppress_alarm_no_button}
    log to console  Clicked on No button

suppressedAlarmPopup
    startBrowserAndLoginToAIEngineVX
    set selenium timeout  ${short_wait_time}
    sleep  ${load_time}
    click element   ${notifications_tab}
    log to console  Notifications tab clicked
    set selenium timeout  ${short_wait_time}
    sleep  ${load_time}
    click element  ${suppressed_alarms_button}
    log to console  'Suppressed Alarms' button clicked
    ${verify_suppressed_alarms_popup_title}=  get text  ${suppressed_alarms_title}
    should be equal	 ${verify_suppressed_alarms_popup_title}  ${test_input}[suppressed_alarm_popup_title]
    log to console  Popup title is "${verify_suppressed_alarms_popup_title}"
    set selenium timeout  ${short_wait_time}
    sleep  ${load_time}
    click element  ${unsuppress_button}
    log to console  'Unsuppressed' button clicked
    ${popup_message}=  get text  ${suppressed_alarm_popup_message}
    should be equal	 ${popup_message}  ${test_input}[suppress_alarm_popup_message]
    log to console  Popup message is "${popup_message}"
    click element  ${suppressed_alarm_ok_button}
    sleep  ${load_time}
    click element  ${unsuppress_all_button}
    log to console  'Unsuppress All' button clicked

