*** Settings ***
Documentation          This resource file provides the keyword definition specific to Alram1-1 testsuite
#...                    Created on 8th Dec 2021
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library     String
Library    SeleniumLibrary
Library    ${EXECDIR}/ExternalKeywords/common.py
Variables    ${EXECDIR}/Configurations/${environment}.py
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/common.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot
Resource    ${EXECDIR}/Inputs/GraphQL/gqlQueries.robot


*** Keywords ***
ahuFailedToTurnOffAlarmTestPreconditionSetup
    [Documentation]    Stop all VEM processes and wait for 2 minutes
    ...                Also write test entry temperature for the parallel staleStatePrevention program
    log to console    !-----Reading the inputs from the excel and storing in dictionary------!
    testInputs.readingInputsFromExcel  alarmTest  A  B
    common.setFlagValue    ${test_entry_flag}
    log to console    !-----PreCondition for the Alarm-1 test is been executed------!
    connection.establishConnectionAndStopAllProcessesExcept
    common.waitForMinutes    2
    apiresources.writeTestEntryTemperatureToSensorsAfterVXServerStarted

setAllowNumExceedencesGuardCATGuardBandRangeOnPwrLvl
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  AllowNumExceedencesGuard  ${test_input}[allow_num_exceedences_guard]
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  CATGuardBandRange  ${test_input}[cat_guard_band_range]
    ${ahuoid}=    apiresources.getOidOfComponentUsingComponentName   ${test_input}[ahu_change_onpwrlvl]
    log to console     ${ahuoid}
    apiresources.setComponentPropertyValue   ${ahuoid}     OnPwrLvl    float      ${test_input}[ahu_property_onpwrlvl]

verifyNoAlarmAHUFailedToTurnOffRaised
    ${query}=    gqlQueries.getAlarmMsgAHUFailToTurOff
    ${json_dictionary}=  gqlFetchJsonResponseFromQuery     ${query}
    log to console  verify no alarm is raised i.e no message ${json_dictionary}
    should be equal as strings  ${json_dictionary["data"]}  None
    log to console  ================No Alarm-AHUFailedToTurnOff- found===========================


ahuFailedToTurnOffAlarmsRaised
    @{alarmraisedforallAhu}=    apiresources.queryToFetchAlarmMsgAHUFailToTurOff
    #fetch the count of messages for Ahu
    ${total}=    get length   ${alarmraisedforallAhu}
    log to console     ================Comaparing the actuall Alarm message with expected=================
    FOR    ${i}    IN RANGE   ${total}
        should contain   ${alarmraisedforallAhu[${i}]}    in Control Group NoBindings is not turning OFF when commanded.
        log to console  actual message ${alarmraisedforallAhu[${i}]} contains the expected AHU NB-AHU in Control Group NoBindings is not turning OFF when commanded.
    END

verifyAHUMismatchForAHUFailToTurOffAlarm
    #creating the expected list of messages for the AHU
    @{alarm_mismatch_list_expected}=    Create List      10  11  12  13  14  15  16  17
    @{alarmismatchforallAhu}=    apiresources.queryToFetchAHUMismatchForAHUFailToTurOffAlarm
    #fetch the count of messages for Ahu
    ${total}=    get length   ${alarmismatchforallAhu}
    log to console     ================verify the Ahu sate to be Mismatch=================
    FOR    ${i}    IN RANGE   ${total}
        should be equal as strings  ${alarmismatchforallAhu[${i}]}   NoBindings / NB-AHU-${alarm_mismatch_list_expected[${i}]}
        log to console  actual ahu with mismatch ${alarmismatchforallAhu[${i}]} matches with expected ahu NoBindings / NB-AHU-${alarm_mismatch_list_expected[${i}]}
    END

verifyAhuStateForAHUInGroup
    [Arguments]  ${group_name}  ${expected_ahu_state}
    @{ahustate_list}=    apiresources.getAhuStateOfAllAhuInGroupInList  ${group_name}
    #fetch the count of messages for Ahu
    ${total}=    get length   ${ahustate_list}
    log to console     ================Comaparing the actuall ahu state with expected=================
    FOR    ${i}    IN RANGE   ${total}
        ${ahu_state_check}=    Run Keyword And Return Status   should be equal as strings  ${ahustate_list[${i}]}   ${expected_ahu_state}
        log to console   ${ahu_state_check}
        IF  ${ahu_state_check}
           log to console  actual ahu state ${ahustate_list[${i}]} matches with expected ${expected_ahu_state}
        ELSE
            log to console  actual ahu state ${ahustate_list[${i}]} does not matches with expected ${expected_ahu_state}
            apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->AHUFailedToTurnOFFAlarmTest->Failed to Turn OFF Alarms is not Cleared Successfully
            exit for loop
        END
    END
    IF  ${ahu_state_check}
        apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->AHUFailedToTurnOFFAlarmTest->Failed to Turn OFF Alarms Cleared Successfully
    END
