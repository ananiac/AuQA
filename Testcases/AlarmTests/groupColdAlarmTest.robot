*** Settings ***
Documentation          This testcase validates Alarm-08 GroupCold Alarm.
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created on 27th Dec 2021 by Greeshma
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/AlarmTestsResources/alarmResources.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot
Resource    ${EXECDIR}/Resources/common.robot


*** Test Cases ***
GroupColdAlarmTest
    log to console  test10
#    #1. Start system with the AuQa DB on it (e.g., 10.252.9.118)
#    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Group Cold alarm test started.
#    #2. Use the NoBinding group
#    alarmResources.groupColdAlarmTestPreconditionSetup
#    #Only vx_server, facs_launcher, and facs_trends facs_dash, facs_sift should be running
#    connection.establishConnectionAndStartRequiredProcesses    vx_server  facs_launcher  facs_trend  facs_sift  facs_dash
#    #3. Load the DASHAM_MIX template in the CX configs (with overwrite)
#    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
#    #4. Confirm config DASHM::AllowNumExceedencesGuard=1 and CATGuardBandRange=4
#    #5. Write User event - “confirmed config DASHM::AllowNumExceedencesGuard=1 and CATGuardBandRange=4”
#    alarmResources.setAllowNumExceedencesGuardAndCATGuardBandRange    ${test_input}[allow_num_exceedences_guard]  ${test_input}[cat_guard_band_range]
#    #6. Set all Setpoint to 80.6/64.4
#    apiresources.setAllHighAndLowSetPointLimits    ${test_input}[high_set_point_limit]    ${test_input}[low_set_point_limit]
#    #7. Set all rack temperature sensor points every minute at say 80.6 F
#    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_intial_tempF]  ${test_input}[rat_tempF]    ${test_input}[dat_tempF]      ${test_input}[power_monitor_on_pwr_kW]
#    #8. Run for 5 minutes
#    common.waitForMinutes    5
#    #9. Run The PublicAPI call to check for alarms
#    #a. Ensure there are no GroupCold Alarms
#    alarmResources.checkAlarmStatusForGroup    ${test_input}[group_cold_alarm]    ${test_input}[alarm_off]
#    #10. Make sure no AHUs are in Guard or Overridden
#    apiresources.releaseOverrideOfAllAHUsAndConfirmAHUsAreGuardCleared
#    #11. Set the temps to 34.0
#    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_cold_tempF]  ${test_input}[rat_tempF]    ${test_input}[dat_tempF]      ${test_input}[power_monitor_on_pwr_kW]
#    #Group Cold alarm
#    #Wait 2 minutes
#    common.waitForMinutes    2
#    #12. Run The PublicAPI call to check for GroupCold alarms
#    #13. Write User event whether or not the Group Cold alarm is raised
#    alarmResources.checkAlarmStatusForGroup    ${test_input}[group_cold_alarm]    ${test_input}[alarm_on]
#    #14. Set temps 80.6
#    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_intial_tempF]  ${test_input}[rat_tempF]    ${test_input}[dat_tempF]      ${test_input}[power_monitor_on_pwr_kW]
#    #Wait 5 Minutes
#    common.waitForMinutes    5
#    #Expect the GroupCold alarm to clear
#    #15. Run The PublicAPI call to check for alarms
#    #Ensure there are no group cold
#    #16. Write User event “Alarms Cleared Successfully” or Unsuccessfully, whichever is the case.
#    alarmResources.checkAlarmStatusForGroup    ${test_input}[group_cold_alarm]    ${test_input}[alarm_off]
#Cleanup
#    #17. Write User event “Ending Group Cold test”
#    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Ending Group Cold alarm test
#    #18. End test
#    #19. Stop all processes except vx_server, facs_launcher, and facs_trend
#    #20. Clean up
#    connection.establishConnectionAndStopAllProcessesExcept    vx_server    facs_launcher    facs_trend
#    [Teardown]   apiresources.setTestExitTemperatureToAllSensorPoints
