*** Settings ***
Documentation          This resource file provides the keyword definition specific to Dead Sensor Guard testsuite
#...                    Created by Greeshma on 28th July 2021
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Library    SeleniumLibrary
Variables    ${EXECDIR}/Configurations/${environment}.py
Variables    ${EXECDIR}/PageObjects/siteEditorHomePage.py
Resource    common.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot


*** Variables ***


*** Keywords ***
deadSensorGuardTestSetup
    [Documentation]    Make sure no VEMS processes are running except vx_server, facs_launcher, facs_trends
    ...                Make sure the simulator is NOT running
    ...                Also write test entry temperature for the parallel staleStatePrevention program
    log to console    !-----Reading the inputs from the excel and storing in dictionary------!
    testInputs.readingInputsFromExcel  guardTest  D  E
    log to console    !-----PreCondition for the Dead Sensor Guard test is been executed------!
    connection.establishConnectionAndStopAllProcessesExcept    vx_server  facs_trend    facs_launcher
    apiresources.writeTestEntryTemperatureToSensorsAfterVXServerStarted
    common.waitForMinutes    1

setIntialCxConfigParameters
    [Arguments]    ${num_minutes_past_v}    ${percent_deadsensor_threshold_v}    ${num_minutes_guard_timer_v}    ${num_guard_units_v}
    apiresources.changeCxConfigsDashm_NumGuardUnits_NumMinutesGuardTimer_PercentDeadSensorThreshold_AndSystem_NumMinutesPast    ${num_guard_units_v}    ${num_minutes_guard_timer_v}   ${percent_deadsensor_threshold_v}    ${num_minutes_past_v}

checkGuardAndGroupDeadSensorAlarmStatusForPerecntDeadSensorThreshold
    [Arguments]    ${perecentage_dead_sensor_threshold_value}    ${expected_guard_status_value}    ${expected_alarm_status_value}
    apiresources.setPercentDeadSensorThresholdInDASHMConfig    ${perecentage_dead_sensor_threshold_value}    #write
    common.waitForMinutes   1
    apiresources.checkingGuardModeOfGroup    ${expected_guard_status_value}                         #query
    apiresources.checkingAlarmStatusForGroup  GroupDeadSensor  ${expected_alarm_status_value}                  #query

checkGuardAndGroupDeadSensorAlarmStatusForControlDeadSensorThreshold
    [Arguments]    ${control_dead_sensor_threshold_value}    ${expected_guard_status_value}    ${expected_alarm_status_value}
    apiresources.setGroupPropertyFloatValue    ControlDeadSensorThreshold  ${control_dead_sensor_threshold_value}    #write
    common.waitForMinutes   1
    apiresources.checkingGuardModeOfGroup    ${expected_guard_status_value}                         #query
    apiresources.checkingAlarmStatusForGroup  GroupDeadSensor  ${expected_alarm_status_value}                  #query

checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold
    [Arguments]    ${grp_dead_sensor_threshold_value}    ${expected_guard_status_value}    ${expected_alarm_status_value}
    apiresources.setConfigAlarmGroupDeadSensorThreshold  ${grp_dead_sensor_threshold_value}    #write
    common.waitForMinutes   2
    apiresources.checkingGuardModeOfGroup    ${expected_guard_status_value}                         #query
    apiresources.checkingAlarmStatusForGroup  GroupDeadSensor  ${expected_alarm_status_value}                  #query

checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold
    [Arguments]    ${alarm_dead_sensor_threshold_value}    ${expected_guard_status_value}    ${expected_alarm_status_value}
    apiresources.setGroupPropertyFloatValue  AlarmDeadSensorThreshold    ${alarm_dead_sensor_threshold_value}    #write
    common.waitForMinutes   1
    apiresources.checkingGuardModeOfGroup    ${expected_guard_status_value}                         #query
    apiresources.checkingAlarmStatusForGroup  GroupDeadSensor  ${expected_alarm_status_value}                  #query

setDeadSensorGuardGroupPropertiesToEmpty
    setGroupPropertiesForDeadSensorToZero
    sleep  ${load_time}
    uiresources.startBrowserAndLoginToAIEngine
    sleep  ${load_time}
    uiresources.selectAndClickGroupName
    uiresources.clickAllPropertiesButton
    uiresources.setGroupPropertyToEmpty  ControlDeadSensorThreshold
    uiresources.setGroupPropertyToEmpty  AlarmDeadSensorHysteresis
    uiresources.setGroupPropertyToEmpty  AlarmDeadSensorThreshold
#    reload page
    close browser

setGroupPropertiesForDeadSensorToZero
    apiresources.changeGroupPropertiesParameterValue    ControlDeadSensorThreshold    float    ${test_input}[control_dead_sensor_threshold_cleanup_value]
    apiresources.changeGroupPropertiesParameterValue    AlarmDeadSensorHysteresis    float    ${test_input}[alarm_dead_sensor_hysteresis_cleanup_value]
    apiresources.changeGroupPropertiesParameterValue    AlarmDeadSensorThreshold    float    ${test_input}[alarm_dead_sensor_threshold_cleanup_value]
