*** Settings ***
Documentation          This resource file provides the keyword definition specific to Dead Sensor Guard testsuite
...                    Created by Greeshma on 28th July 2021
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Variables    ${EXECDIR}/Resources/ResourceVariables/globalVariables.py
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot

*** Variables ***
${expected_count_of_dead_sensor_guard_alarm}    1
${expected_alarm_cleared_response}    None



*** Keywords ***
deadSensorGuardTestSetup
    [Documentation]    Make sure no VEMS processes are running except vx_server and facs_trends
    ...                Make sure the simulator is NOT running
    ...                Also write test entry temperature for the parallel staleStatePrevention program
    log to console    !-----PreCondition for the Dead Sensor Guard test is been executed------!
    connection.establishConnectionAndStopAllVEMProcessesExceptVx_serverAndFacs_trends
    apiresources.writeTestEntryTemperatureToSensorsAfterVXServerStarted

startVx_serverFacs_launcherFacs_siftFacs_dashAndFacs_trend
    connection.establishConnectionAndStartProcessesVx_serverFacs_launcherFacs_siftFacs_dashAndFacs_trends

reloadDefaultDASHMTemplateFromUI
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite

setIntialCxConfigParameters
    [Arguments]    ${num_minutes_past_v}    ${percent_deadsensor_threshold_v}    ${num_minutes_guard_timer_v}    ${num_guard_units_v}
    apiresources.changeCxConfigsDashm_NumGuardUnits_NumMinutesGuardTimer_PercentDeadSensorThreshold_AndSystem_NumMinutesPast    ${num_guard_units_v}    ${num_minutes_guard_timer_v}   ${percent_deadsensor_threshold_v}    ${num_minutes_past_v}

setGroupPropertiesForDeadSensorTest
    [Arguments]    ${control_dead_densor_threshold_value}    ${alarm_dead_sensor_hysteresis_value}    ${alarm_dead_sensor_threshold_value}
    apiresources.changeGroupPropertiesFloatParameterValue    ControlDeadSensorThreshold    ${control_dead_densor_threshold_value}
    apiresources.changeGroupPropertiesFloatParameterValue    AlarmDeadSensorHysteresis    ${alarm_dead_sensor_hysteresis_value}
    apiresources.changeGroupPropertiesFloatParameterValue    AlarmDeadSensorThreshold    ${alarm_dead_sensor_threshold_value}

checkDeadSensorAlarmIsRaised
    log to console    !--------Checking for the Dead Sensor Alarm to be Raised-------!
    ${json_response}=    apiresources.queryToFetchJsonResponseForSpecificAlarmType    GroupDeadSensor
#    log to console    ${json_response}
    ${no_of_deade_sensor_alarm}    apiresources.fetchTheNumberOfItemsInDictionary   ${json_response}    $.data.alarms
    log to console    ${no_of_deade_sensor_alarm}
    should be equal as integers  ${no_of_deade_sensor_alarm}  ${expected_count_of_dead_sensor_guard_alarm}    #Confirmed with Client that there will be a single one
    log to console    **************Dead Sensor Alarm raised********************

checkDeadSensorAlarmIsCleared
    log to console    !--------Checking for the Dead Sensor Alarm to be Cleared-------!
    ${json_response}=    apiresources.queryToFetchJsonResponseForSpecificAlarmType    GroupDeadSensor
#    log to console    ${json_response}
    ${actual_value}    apiresources.fetchValueOfFieldFromJsonDictionary   ${json_response}  $.data
#    log to console    ${actual_value}
    should be equal as strings   ${actual_value}  ${expected_alarm_cleared_response}
    log to console    **************Dead Sensor Alarm Cleared**************

checkGuardAndGroupDeadSensorAlarmStatusForPerecntDeadSensorThreshold
    [Arguments]    ${perecentage_dead_sensor_threshold_value}    ${expected_guard_status_value}    ${expected_alarm_status_value}
    apiresources.setPercentDeadSensorThresholdInDASHMConfig    ${perecentage_dead_sensor_threshold_value}    #write
    apiresources.waitForOneMinute
    deadSensorGuardResources.checkingGuardModeOfGroup    ${expected_guard_status_value}                         #query
    deadSensorGuardResources.checkingDeadSensorAlarmForGroup    ${expected_alarm_status_value}                  #query

checkGuardAndGroupDeadSensorAlarmStatusForControlDeadSensorThreshold
    [Arguments]    ${control_dead_sensor_threshold_value}    ${expected_guard_status_value}    ${expected_alarm_status_value}
    deadSensorGuardResources.setControlDeadSensorThresholdOfGroupProperties  ${control_dead_sensor_threshold_value}    #write
    apiresources.waitForOneMinute
    deadSensorGuardResources.checkingGuardModeOfGroup    ${expected_guard_status_value}                         #query
    deadSensorGuardResources.checkingDeadSensorAlarmForGroup    ${expected_alarm_status_value}                  #query

checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold
    [Arguments]    ${grp_dead_sensor_threshold_value}    ${expected_guard_status_value}    ${expected_alarm_status_value}
    apiresources.setConfigAlarmGroupDeadSensorThreshold  ${grp_dead_sensor_threshold_value}    #write
    apiresources.waitForOneMinute
    deadSensorGuardResources.checkingGuardModeOfGroup    ${expected_guard_status_value}                         #query
    deadSensorGuardResources.checkingDeadSensorAlarmForGroup    ${expected_alarm_status_value}                  #query

checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold
    [Arguments]    ${alarm_dead_sensor_threshold_value}    ${expected_guard_status_value}    ${expected_alarm_status_value}
    deadSensorGuardResources.setAlarmDeadSensorThresholdOfGroupProperties  ${alarm_dead_sensor_threshold_value}    #write
    apiresources.waitForOneMinute
    deadSensorGuardResources.checkingGuardModeOfGroup    ${expected_guard_status_value}                         #query
    deadSensorGuardResources.checkingDeadSensorAlarmForGroup    ${expected_alarm_status_value}                  #query

checkingGuardModeOfGroup
    [Arguments]    ${expected_guard_status}
     IF    '${expected_guard_status}'=='GUARD_ON'    #Checking Group is in guard
        apiresources.checkGroupControlStausValueInGuard
     ELSE                                            #Checking Group is in guard
        apiresources.checkGroupControlStatusValueNotInGuard
     END

checkingDeadSensorAlarmForGroup
    [Arguments]    ${exepected_alarm_status}
    IF  '${exepected_alarm_status}'=='ALARM_ON'
        deadSensorGuardResources.checkDeadSensorAlarmIsRaised
    ELSE
        deadSensorGuardResources.checkDeadSensorAlarmIsCleared
    END

setControlDeadSensorThresholdOfGroupProperties
    [Arguments]    ${property_value}
    apiresources.changeGroupPropertiesFloatParameterValue    ControlDeadSensorThreshold  ${property_value}

setAlarmDeadSensorHysteresisOfGroupProperties
    [Arguments]    ${property_value}
    apiresources.changeGroupPropertiesFloatParameterValue    AlarmDeadSensorHysteresis  ${property_value}

setAlarmDeadSensorThresholdOfGroupProperties
    [Arguments]    ${property_value}
    apiresources.changeGroupPropertiesFloatParameterValue    AlarmDeadSensorThreshold  ${property_value}
