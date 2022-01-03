*** Settings ***
Documentation          This testcase validates Alarm-09 GroupDeadSensor Alarm.
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created on 28th Dec 2021 by Greeshma
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/AlarmTestsResources/alarmResources.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot
Resource    ${EXECDIR}/Resources/common.robot


*** Test Cases ***
GroupDeadSensorAlarmTest
    #1. Start system with the AuQa DB on it (e.g., 10.252.9.118)
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Group Dead Sensor alarm test started.
    #2. Use the NoBinding group
    alarmResources.groupDeadSensorAlarmTestPreconditionSetup
    #3. Load the DASHAM_MIX template in the CX configs (with overwrite)
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    #4. Confirm config DASHM::AllowNumExceedencesGuard=1 and CATGuardBandRange=4 and SYSTEM::NumMinutesPast=3
    #5. Write User event - “confirmed config DASHM::AllowNumExceedencesGuard=1, CATGuardBandRange=4 NumMinutesPast=3 ”
    alarmResources.setAllowNumExceedencesGuardCATGuardBandRangeAndNumMinutesPast    ${test_input}[allow_num_exceedences_guard]  ${test_input}[cat_guard_band_range]  ${test_input}[num_minutes_past]
    #6. Set all Setpoint to 80.6/64.4
    apiresources.setAllHighAndLowSetPointLimits    ${test_input}[high_set_point_limit]    ${test_input}[low_set_point_limit]
    #7. Set all rack temperature sensor points every minute at say 80.6 F
    #8. Set AHU RAT to 86.2 and DAT to 76.2 and PWR to 10 kW
    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_tempF]  ${test_input}[rat_tempF]    ${test_input}[dat_tempF]      ${test_input}[power_monitor_on_pwr_kW]
    common.waitForMinutes    1
    #9. Override all AHUs in NoBindings Group to ON
    apiresources.overrideAllAHUsWithBOPValueON
    #10. Wait 2 minutes
    common.waitForMinutes    2
    #11. Clear Overrides
    apiresources.releaseOverrideOfAllAHUs
    #12. Run for 5 minutes
    common.waitForMinutes    3
    #13. Run The PublicAPI call to check for alarms
    #Ensure there are no GroupDeadSensor Alarms
    alarmResources.checkAlarmStatusForGroup    ${test_input}[group_dead_sensor_alarm]    ${test_input}[alarm_off]
    #14. Set the Stop sending values to the sensor points in NoBinding Group
    apiresources.stopWritingToAllSensorPoints
    #Wait 5 minutes
    common.waitForMinutes    5
    #Expect GroupDeadSensor alarm is produced for NoBindings Group
    #15. Run The PublicAPI call to check for alarms
    #a. Ensure there are a GroupDeadSensor Alarm
    #16. Write User event whether or not the GroupDeadSensor alarm is raised
    alarmResources.checkAlarmStatusForGroup    ${test_input}[group_dead_sensor_alarm]    ${test_input}[alarm_on]
    #17. Start writing data to the sensor 80.6 F
    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_tempF]  ${test_input}[rat_tempF]    ${test_input}[dat_tempF]      ${test_input}[power_monitor_on_pwr_kW]
    #Wait 5 minutes
    common.waitForMinutes    5
    #GroupDeadSensor Alarm ends
    #18. Run The PublicAPI call to check for alarms
    #a. Ensure there are no GroupDeadSensor Alarms
    #19. Write User event “GroupDeadSensorAlarms Cleared Successfully” or Unsuccessfully, whichever is the case.
    alarmResources.checkAlarmStatusForGroup    ${test_input}[group_dead_sensor_alarm]    ${test_input}[alarm_off]
    #20. Write User event “Ending GroupDeadSensor test”
    #21. End test
    #22. Stop all processes except vx_server, facs_launcher, and facs_trend
    #23. Clean up
Cleanup
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Group Dead Sensor alarm test finished.
    alarmResources.setAllowNumExceedencesGuardCATGuardBandRangeAndNumMinutesPast    ${test_input}[allow_num_exceedences_guard]  ${test_input}[cat_guard_band_range]  ${test_input}[num_minutes_past_default]
    connection.establishConnectionAndStopAllProcessesExcept    vx_server    facs_launcher    facs_trend
    [Teardown]   apiresources.setTestExitTemperatureToAllSensorPoints
