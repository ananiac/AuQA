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
Variables    ${EXECDIR}/PageObjects/vxAIEngine.py
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
    # verifyPopupTitle
    ${verify_suppress_alarm_popup_title}=  get text  ${suppress_alarm_title}
    should be equal	 ${verify_suppress_alarm_popup_title}  ${test_input}[suppress_alarm_popup_title]
    log to console  Popup title is "${verify_suppress_alarm_popup_title}"
    set selenium timeout  ${short_wait_time}
    sleep  ${load_time}
    # verifyPopupMessage
    ${popup_message}=  get text  ${suppress_alarm_popup_message}
    should be equal	 ${popup_message}  ${test_input}[suppress_alarm_popup_message]
    log to console  Popup message is "${popup_message}"
    click element  ${suppress_alarm_ok_button}
    sleep  ${load_time}
    close browser

#suppressedAlarmPopup
#    startBrowserAndLoginToAIEngineVX
#    set selenium timeout  ${short_wait_time}
#    sleep  ${load_time}
#    click element   ${notifications_tab}
#    set selenium timeout  ${short_wait_time}
#    sleep  ${load_time}
#    click element  ${suppressed_alarm_button}
#    # verifyPopupTitle
#    ${verify_suppress_alarm_popup_title}=  get text  ${suppressed_alarm_title}
#    should be equal	 ${verify_suppressed_alarm_popup_title}  ${test_input}[suppress_alarm_popup_title]
#    log to console  Popup title is "${verify_suppressed_alarm_popup_title}"
#    set selenium timeout  ${short_wait_time}
#    sleep  ${load_time}
#    # verifyPopupMessage
#    ${popup_message}=  get text  ${suppressed_alarm_popup_message}
#    should be equal	 ${popup_message}  ${test_input}[suppress_alarm_popup_message]
#    log to console  Popup message is "${popup_message}"
#    click element  ${suppressed_alarm_ok_button}
#    sleep  ${load_time}
#    close browser
#
#overridesPopup
#    startBrowserAndLoginToAIEngineVX
#    set selenium timeout  ${short_wait_time}
#    sleep  ${load_time}
#    click element   ${notifications_tab}
#    set selenium timeout  ${short_wait_time}
#    sleep  ${load_time}
#    click element  ${overrides_popup_button}
#    # verifyPopupTitle
#    ${verify_suppress_alarm_popup_title}=  get text  ${overrides_popup_title}
#    should be equal	 ${verify_overrides_popup_title}  ${test_input}[suppress_alarm_popup_title]
#    log to console  Popup title is "${verify_overrides_popup_title}"
#    set selenium timeout  ${short_wait_time}
#    sleep  ${load_time}
#    # verifyPopupMessage
#    ${popup_message}=  get text  ${overrides_popup_message}
#    should be equal	 ${popup_message}  ${test_input}[suppress_alarm_popup_message]
#    log to console  Popup message is "${popup_message}"
#    click element  ${overrides_ok_button}
#    sleep  ${load_time}
#    close browser
#
#claerOverridePopup
#    startBrowserAndLoginToAIEngineVX
#    set selenium timeout  ${short_wait_time}
#    sleep  ${load_time}
#    click element   ${notifications_tab}
#    set selenium timeout  ${short_wait_time}
#    sleep  ${load_time}
#    click element  ${clearOverride_popup_button}
#    # verifyPopupTitle
#    ${verify_suppress_alarm_popup_title}=  get text  ${clearOverrides_popup_title}
#    should be equal	 ${verify_clearOverride_popup_title}  ${test_input}[suppress_alarm_popup_title]
#    log to console  Popup title is "${verify_clearOverride_popup_title}"
#    set selenium timeout  ${short_wait_time}
#    sleep  ${load_time}
#    # verifyPopupMessage
#    ${popup_message}=  get text  ${clearOverride_popup_message}
#    should be equal	 ${popup_message}  ${test_input}[suppress_alarm_popup_message]
#    log to console  Popup message is "${popup_message}"
#    click element  ${clearOverride_ok_button}
#    sleep  ${load_time}
#    close browser