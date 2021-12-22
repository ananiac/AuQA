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

    #Checks the given message in the alarm message of the specified alarm type
verifyAllAlarmMessageOfSpecifiedAlarmType
    [Arguments]  ${alarm_type}  ${alarm_message}
    @{alarmraisedforallAhu}=    apiresources.getAllAlarmMessagesOfSpecifiedAlarmType    ${alarm_type}
    #fetch the count of messages
    ${total}=    get length   ${alarmraisedforallAhu}
    log to console     ================Comparing the actuall Alarm message to contain expected message=================
    FOR    ${i}    IN RANGE   ${total}
        should contain   ${alarmraisedforallAhu[${i}]}    ${alarm_message}
        log to console  actual message ${alarmraisedforallAhu[${i}]} contains the expected AHU NB-AHU ${alarm_message}
    END

verifyAllAHUInGroupInMismatchState
    #creating the expected list of messages for the AHU
    @{ahu_list}=    apiresources.getAHUNamesListOfGroup
    @{alarmismatchforallAhu}=    apiresources.getAllAHUInGroupInMismatchState
    #fetch the count of messages for Ahu
    ${total}=    get length   ${alarmismatchforallAhu}
    log to console     ================verify the Ahu's go into the mismatch state=================
    FOR    ${i}    IN RANGE   ${total}
        should contain   ${alarmismatchforallAhu[${i}]}    NoBindings / ${ahu_list}[${i}] / SyncFaultStatus
        log to console  actual ahu with mismatch ${alarmismatchforallAhu[${i}]} matches with expected NoBindings / ${ahu_list}[${i}] / SyncFaultStatus
    END

verifyAhuStateForAHUInGroup
    [Arguments]   ${expected_ahu_state}
    @{ahustate_list}=    apiresources.getAhuStateOfAllAhuInGroupInList
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
            apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->AHUFailedToTurnOFFAlarmTest->AHUFailedtoTurnOFF Alarms is Unsuccessfull to Clear
            #Checking the status to be true to make keyword be marked as fail in case of mismatch
            ${ahu_state_check}  should be true
            exit for loop
        END
    END
    IF  ${ahu_state_check}
        apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->AHUFailedToTurnOFFAlarmTest->AHUFailedtoTurnOFF Alarms Cleared Successfully
    END
