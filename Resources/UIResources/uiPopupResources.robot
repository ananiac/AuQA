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

    selectAlarm

    sleep  ${load_time}
    close browser

selectAlarm
    click element  xpath=//table[3]/tbody/tr/td[3]/div
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
    should be equal	 ${popup_message}  ${test_input}[selected_suppress_alarm_popup_message]
    log to console  Popup message is "${popup_message}"
    sleep  ${load_time}
    click element  ${suppress_alarm_no_button}
    log to console  Clicked on No button
    #${suppress_alarm_no_button}

suppressedAlarmPopup
    startBrowserAndLoginToAIEngineVX
    set selenium timeout  ${short_wait_time}
    sleep  ${load_time}
    click element   ${notifications_tab}
    log to console  Notifications tab clicked
    set selenium timeout  ${short_wait_time}
    sleep  ${load_time}

    # 'Suppressed Alarms' button
    click element  ${suppressed_alarms_button}
    log to console  'Suppressed Alarms' button clicked

    # verify 'Suppressed Alarms' popup title
    ${verify_suppressed_alarms_popup_title}=  get text  ${suppressed_alarms_title}
    should be equal	 ${verify_suppressed_alarms_popup_title}  ${test_input}[suppressed_alarm_popup_title]
    log to console  Popup title is "${verify_suppressed_alarms_popup_title}"
    set selenium timeout  ${short_wait_time}
    sleep  ${load_time}

    # 'Unsuppressed' button
    click element  ${unsuppress_button}
    log to console  'Unsuppressed' button clicked

    verifyTitleOfPopUp  ${restore_suppressed_alarm_title}  ${test_input}[restore_all_suppressed_alarms_title]
#    # verify 'Restore Suppressed Alarm' popup title
#    ${verify_restore_suppressed_alarm_title}=  get text  ${restore_suppressed_alarm_title}
#    should be equal	 ${verify_restore_suppressed_alarm_title}  ${test_input}[restore_suppressed_alarm_title]
#    log to console  Popup title is "${verify_restore_suppressed_alarm_title}"
#    set selenium timeout  ${short_wait_time}
#    sleep  ${load_time}

    # verify 'Restore Suppressed Alarm' popup message
    ${popup_message}=  get text  ${suppressed_alarm_popup_message}
    should be equal	 ${popup_message}  ${test_input}[suppress_alarm_popup_message]
    log to console  Popup message is "${popup_message}"
    click element  ${suppressed_alarm_ok_button}
    sleep  ${load_time}

    # 'Unsuppress All' button
    click element  ${unsuppress_all_button}
    log to console  'Unsuppress All' button clicked

#    # verify 'Restore All Suppressed Alarms' popup title
#    ${verify_restore_all_suppressed_alarms_title}=  get text  ${restore_all_suppressed_alarms_title}
#    should be equal	 ${verify_restore_all_suppressed_alarms_title}  ${test_input}[restore_all_suppressed_alarms_title]
#    log to console  Popup title is "${verify_restore_all_suppressed_alarms_title}"
#    set selenium timeout  ${short_wait_time}
#    sleep  ${load_time}
#
#    # verify 'Restore All Suppressed Alarms' popup message
#    ${popup_message}=  get text  ${restore_all_suppressed_alarms_message}
#    should be equal	 ${popup_message}  ${test_input}[restore_all_suppressed_alarms_message]
#    log to console  Popup message is "${popup_message}"
#    click element  ${restore_all_suppress_alarm_button}
#    log to console  restore_all_suppress_alarm_button clicked
#    sleep  ${load_time}

verifyTitleOfPopUp
    [Arguments]    ${restore_suppressed_alarm_title}  ${test_input}[restore_all_suppressed_alarms_title]
    ${verify_popup_title}=  get text  ${restore_suppressed_alarm_title}
    should be equal	 ${verify_popup_title}  ${test_input}[restore_suppressed_alarm_title]
    log to console  Popup title is "${verify_popup_title}"
    sleep  ${load_time}

#    ${verify_restore_suppressed_alarm_title}=  get text  ${restore_suppressed_alarm_title}
#    should be equal	 ${verify_restore_suppressed_alarm_title}  ${test_input}[restore_suppressed_alarm_title]
#    log to console  Popup title is "${verify_restore_suppressed_alarm_title}"
#    set selenium timeout  ${short_wait_time}
#    sleep  ${load_time}

verifyMsgOfSavePopUp
    ${message}=  get text  xpath=/html/body/div[13]/div[2]/div[1]/div/div/div[1]/div/div/div[2]/div/div/div[1]
    should be equal	 ${message}  Nothing to save.
    log to console  Save popup message is "${message}"

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