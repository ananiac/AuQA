*** Settings ***
Documentation          This resource file provides the keyword definition specific to Alram testcases
#...                    Created on 8th Dec 2021 by Anania
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
    alarmResources.setAhuPropertyOnPwrLvlOfFirstAhu     ${test_input}[ahu_property_onpwrlvl]

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
    log to console     ================Comparing the actuall AHU state with expected for all AHU=================
    FOR    ${i}    IN RANGE   ${total}
        ${ahu_state_check}=    Run Keyword And Return Status   should be equal as strings  ${ahustate_list[${i}]}   ${expected_ahu_state}
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

setAhuPropertyOnPwrLvlOfFirstAhu
    [Arguments]   ${property_value}
    @{ahu_list}=    apiresources.getAHUNamesListOfGroup
    log to console  ==================setting the OnPwrLvl value of first Ahu(${ahu_list}) in the group to: ${property_value}
    ${ahuoid}=    apiresources.getOidOfComponentUsingComponentName   ${ahu_list}[0]
    apiresources.setComponentPropertyValue   ${ahuoid}     OnPwrLvl    float       ${property_value}

#-------------GroupColdAlarm---------------#
    #Created by Greeshma on 27th Dec 2021
groupColdAlarmTestPreconditionSetup
    [Documentation]        Make sure no VEMS processes are running except vx_server, facs_launcher, and facs_trends
    ...                    Make sure the simulator is NOT running
    ...                    Also write test entry temperature for the parallel staleStatePrevention program
    log to console    !-----Reading the inputs from the excel and storing in dictionary------!
    testInputs.readingInputsFromExcel  alarmTest  D  E
    common.setFlagValue    ${test_entry_flag}
    log to console    !-----PreCondition for the Alarm-8 GroupColdAlarm test is been executed------!
    connection.establishConnectionAndStopAllProcessesExcept
    common.waitForMinutes    2
    apiresources.writeTestEntryTemperatureToSensorsAfterVXServerStarted

    #Created by Greeshma on 27th Dec 2021
setAllowNumExceedencesGuardAndCATGuardBandRange
    [Arguments]  ${allow_num_exceedences_guard_value}  ${cat_guard_band_range_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  AllowNumExceedencesGuard  ${allow_num_exceedences_guard_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  CATGuardBandRange  ${cat_guard_band_range_value}

#-------------GroupDeadSensorAlarm---------------#
    #Created by Greeshma on 28th Dec 2021
groupDeadSensorAlarmTestPreconditionSetup
    [Documentation]        Make sure no VEMS processes are running except vx_server, facs_launcher, and facs_trends facs_dash, facs_sift should be running
    ...                    Make sure the simulator is NOT running
    ...                    Also write test entry temperature for the parallel staleStatePrevention program
    log to console    !-----Reading the inputs from the excel and storing in dictionary------!
    testInputs.readingInputsFromExcel  alarmTest  G  H
    common.setFlagValue    ${test_entry_flag}
    log to console    !-----PreCondition for the Alarm-9 GroupDeadSensor test is been executed------!
    connection.establishConnectionAndStopAllProcessesExcept
    common.waitForMinutes    1
    apiresources.writeTestEntryTemperatureToSensorsAfterVXServerStarted
    connection.establishConnectionAndStartRequiredProcesses    vx_server  facs_launcher  facs_trend  facs_sift  facs_dash
    common.waitForMinutes    1

    #Created by Greeshma on 28th Dec 2021
setAllowNumExceedencesGuardCATGuardBandRangeAndNumMinutesPast
    [Arguments]  ${allow_num_exceedences_guard_value}  ${cat_guard_band_range_value}  ${num_minutes_past_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  AllowNumExceedencesGuard  ${allow_num_exceedences_guard_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  CATGuardBandRange  ${cat_guard_band_range_value}
    apiresources.changeCxConfigsTabModuleFieldValues  SYSTEM  NumMinutesPast  ${num_minutes_past_value}

    #Created by Greeshma on 28th Dec 2021 .
checkAlarmStatusForGroup
    [Arguments]    ${alarm_name}    ${exepected_alarm_status}
    log to console    !--------Checking for the ${alarm_name} Alarm status to be:${exepected_alarm_status}-------!
    ${json_response}=    apiresources.queryToFetchJsonResponseForSpecificAlarmType    ${alarm_name}
    IF  '${exepected_alarm_status}'=='ALARM_ON'
        ${no_of_alarms}    apiresources.fetchTheNumberOfItemsInDictionary   ${json_response}    $.data.alarms
        should be equal as integers  ${no_of_alarms}  1
        apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->${alarm_name} alarm is raised successfully.
        log to console    =================${alarm_name} Alarm raised=======================
    ELSE
        ${actual_value}    apiresources.fetchValueOfFieldFromJsonDictionary   ${json_response}  $.data
        ${alarm_check_status}=  run keyword and return status  should be equal as strings   ${actual_value}  None
        IF  ${alarm_check_status}
            apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->${alarm_name} alarm is cleared successfully.
            log to console    ===============${alarm_name} Alarm Cleared====================
        ELSE
            apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->${alarm_name} alarm is unsuccessful to clear-->test fails.
            log to console    ===============${alarm_name} Alarm not Cleared as expected-test fails====================
            should be true  ${alarm_check_status}
        END
    END