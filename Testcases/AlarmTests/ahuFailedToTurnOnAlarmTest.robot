*** Settings ***
Documentation          This testcase validates Alarm-02 AHU Failed to Turn ON Alarm Automated Test Steps
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created on 4th jan 2022 by Anania
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/AlarmTestsResources/alarmResources.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot
Resource    ${EXECDIR}/Resources/common.robot


*** Test Cases ***
AHUFailedToTurnONAlarm
    #1)Start system with the AuQa DB on it (e.g., 10.252.9.118)
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->AHUFailedToTurnON Alarm test started.
    #2)Use the NoBinding group
    alarmResources.ahuFailedToTurnOnAlarmTestPreconditionSetup
    #3)Load the DASHAM_MIX template in the CX configs (with overwrite)
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    #4)Confirm config DASHM::AllowNumExceedencesGuard=1 and CATGuardBandRange=4 and for first Ahu in the group set the OnPwrLvl property to 0.5
    alarmResources.setAllowNumExceedencesGuardCATGuardBandRangeOnPwrLvl
    #5)Write User event - “confirmed config DASHM::AllowNumExceedencesGuard=1, CATGuardBandRange=4 first AHU OnPwrLvl =0.5”
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->AHUFailedToTurnOFFAlarmTest-> confirmed config DASHM::AllowNumExceedencesGuard=1, CATGuardBandRange=4 first AHU OnPwrLvl =0.5
    #6)Set all rack temperature sensor points every minute at say 80.6 F
    #7)Set AHU PWR to 10kW and RAT=86F and DAT=76F
    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_tempF]  ${test_input}[rat_tempF]    ${test_input}[dat_tempF]      ${test_input}[power_monitor_pwr1_kW]
    #8)Set all Setpoint to 80.6/64.4
    apiresources.setAllHighAndLowSetPointLimits    ${test_input}[high_set_point_limit]    ${test_input}[low_set_point_limit]
    #9)Override all AHUs in NoBindings Group to ON
    apiresources.overrideAllAHUsWithBOPValueON
    #10)Wait 2 minutes
    common.waitForMinutes    2
    #11)Clear Overrides
    apiresources.releaseOverrideOfAllAHUs
    #12)Run for 2 minutes
    common.waitForMinutes    2
    #13)Run The PublicAPI call to check for alarms
    #a)Ensure there are no Failed to Turn ON Alarms
    apiresources.checkAlarmStatusForAllAHUsInGroup  ${test_input}[alarm_ahu_failed_toturnon]  ${test_input}[alarm_status]
    #14)Set the all AHU to 0.1kW
    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_tempF]  ${test_input}[rat_tempF]    ${test_input}[dat_tempF]  ${test_input}[power_monitor_pwr2_kW]
    #a)Wait 3 minutes
    common.waitForMinutes    3
    #b)Expect all AHU  to go into Mismatch on the Equipment Tab and Failed to Turn ON alarm is produced
    alarmResources.verifyAllAHUInGroupInMismatchState
    #15)Run The PublicAPI call to check for alarms
    #a)Ensure there are a Failed to Turn ON Alarm
    #16)Write User event whether or not the Failed to Turn ON alarm is raised
    alarmResources.verifyAllAlarmMessageOfSpecifiedAlarmType   ${test_input}[alarm_ahu_failed_toturnon]    ${test_input}[ahu_failed_to_turnon_alarm_message]
    #17)Set all the AHU PWR to 10kW and wait for 3 minutes
    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_tempF]  ${test_input}[rat_tempF]    ${test_input}[dat_tempF]      ${test_input}[power_monitor_pwr1_kW]
    #a)Wait 3 minutes
    common.waitForMinutes    3
    #18)Run The PublicAPI call to check for alarms
    #a)Ensure there are no Failed to Turn ON Alarms
    apiresources.checkAlarmStatusForAllAHUsInGroup  ${test_input}[alarm_ahu_failed_toturnon]  ${test_input}[alarm_status]
    #19)Expect 'Mismatch' in the State Column of the Equipment Tab Changes to 'Cooling' and Failed to Turn ON ends
    #20)Write User event “Failed to Turn ON Alarms Cleared Successfully” or Unsuccessfully, whichever is the case.
    alarmResources.verifyAhuStateForAHUInGroup  ${test_input}[expected_ahu_state]   ${test_input}[alarm_ahu_failed_toturnon]
    #21)Write User event “Ending Failed to turn ON test”
    #22)End test
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Ending AHUFailedToTurnON Alarm test
    #23)Clean up
CleanUp
    #Set the Pwr to 10.0kW
    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_tempF]  ${test_input}[rat_tempF]  ${test_input}[dat_tempF]  ${test_input}[power_monitor_pwr1_kW]
    #Set OnPwrLvl to 0.4kW
    alarmResources.setAhuPropertyOnPwrLvlOfFirstAhu  ${test_input}[ahu_property_onpwrlvl_default]
    #Stop all processes except vx_server, facs_launcher, and facs_trend
    connection.establishConnectionAndStopAllProcessesExcept    vx_server    facs_launcher    facs_trend
    [Teardown]   apiresources.setTestExitTemperatureToAllSensorPoints
