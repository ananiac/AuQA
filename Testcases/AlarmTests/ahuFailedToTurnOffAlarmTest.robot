*** Settings ***
Documentation          This testcase validates Alarm-01 AHU Failed to Turn OFF Alarm Automated Test Steps
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created on 20th Dec 2021 by Anania
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/AlarmTestsResources/alarmResources.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot
Resource    ${EXECDIR}/Resources/common.robot


*** Test Cases ***
AHUFailedToTurnOFFAlarm
    #1)Start system with the AuQa DB on it (e.g., 10.252.9.118)
    #2)Stop all processes including the API Server (vx_server) and Script Launcher
    #3)Wait 2 minutes
    alarmResources.ahuFailedToTurnOffAlarmTestPreconditionSetup
    #4)Start BACnet commplug, facs_dash (Cooling Control), and facs_sift (Application Metrics) processes Start the API Server (vx_server) and Script Launcher Application Metrics, Cooling Control
    #5)Use the NoBinding group
    connection.establishConnectionAndStartRequiredProcesses    vx_server  facs_launcher     vems-plugin-bacnet     facs_dash   facs_sift
    #6)Load the DASHAM_MIX template in the CX configs (with overwrite)
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    #7)Confirm config DASHM::AllowNumExceedencesGuard=1 and CATGuardBandRange=4 and for first Ahu in the group set the OnPwrLvl property to 0.5
    alarmResources.setAllowNumExceedencesGuardCATGuardBandRangeOnPwrLvl
    #8)Write User event - “confirmed config DASHM::AllowNumExceedencesGuard=1, CATGuardBandRange=4 first AHU OnPwrLvl =0.5”
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->AHUFailedToTurnOFFAlarmTest-> confirmed config DASHM::AllowNumExceedencesGuard=1, CATGuardBandRange=4 first AHU OnPwrLvl =0.5
    #9)Set all rack temperature sensor points every minute at say 80.6 F
    #10)Set AHU PWR to 0.1kW
    #11)Set AHUs PWR to 0.1kW RAT=86F and DAT=76F
    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_tempF]  ${test_input}[rat_tempF]    ${test_input}[dat_tempF]      ${test_input}[power_monitor_pwr1_kW]
    #12)Set all Setpoint to 80.6/64.4
    apiresources.setAllHighAndLowSetPointLimits    ${test_input}[high_set_point_limit]    ${test_input}[low_set_point_limit]
    #13)Override all AHUs in NoBindings Group to OFF
    apiresources.overrideAllAHUsWithBOPValueOFF
    #14)Wait 2 minutes
    common.waitForMinutes    2
    #15)Clear Overrides
    apiresources.releaseOverrideOfAllAHUs
    #16)Run for 3 minutes the data that will cause no alarms to occur. The values that are in step 7. Set the RAT to 86F and the DAT 76F ad the PWR to 0.1. This should allow alarms to clear.
    common.waitForMinutes    2
    #17)Run The PublicAPI call to check for alarms
    #a)Ensure there are no Failed to Turn Off Alarms
    apiresources.checkAlarmStatusForAllAHUsInGroup  ${test_input}[alarm_ahu_failed_toturnoff]  ${test_input}[alarm_status]
    #18)Set the all AHU to 10kW
    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_tempF]  ${test_input}[rat_tempF]    ${test_input}[dat_tempF]  ${test_input}[power_monitor_pwr2_kW]
    #a)Wait 3 minutes
    common.waitForMinutes    2
    #b)Expect all AHU  to go into Mismatch on the Equipment Tab and Failed to Turn OFF alarm is produced
    alarmResources.verifyAllAHUInGroupInMismatchState
    #19)Run The PublicAPI call to check for alarms
    #a)Ensure there are a Failed to Turn OFF Alarm
    #20)Write User event whether or not the Failed to Turn OFF alarm is raised
    alarmResources.verifyAllAlarmMessageOfSpecifiedAlarmType   ${test_input}[alarm_ahu_failed_toturnoff]    ${test_input}[ahu_failed_to_turnoFF_alarm_message]
    #21)Set all the AHU PWR to 0.1kW and wait for 3 minutes
    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_tempF]  ${test_input}[rat_tempF]    ${test_input}[dat_tempF]      ${test_input}[power_monitor_pwr1_kW]
    #a)Wait 3 minutes
    common.waitForMinutes    2
    #22)Run The PublicAPI call to check for alarms
    #a)Ensure there are no Failed to Turn OFF Alarms
    apiresources.checkAlarmStatusForAllAHUsInGroup  ${test_input}[alarm_ahu_failed_toturnoff]  ${test_input}[alarm_status]
    #23)Expect 'Mismatch' in the State Column of the Equipment Tab Changes to 'off' and Failed to Turn OFF ends
    #24)Write User event “Failed to Turn OFF Alarms Cleared Successfully” or Unsuccessfully, whichever is the case.
    alarmResources.verifyAhuStateForAHUInGroup  ${test_input}[expected_ahu_state_off]
    #25)Write User event “Ending Failed to turn OFF test”
    #26)End test
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->AHUFailedToTurnOFFAlarmTest->Ending AHUFailedtoturnOFF test
    #27)Clean up
CleanUp
    #Set OnPwrLvl to 0.4kW
    alarmResources.setAhuPropertyOnPwrLvlOfFirstAhu  ${test_input}[ahu_property_onpwrlvl_default]
    #Stop all processes except vx_server, facs_launcher, and facs_trend
    connection.establishConnectionAndStopAllProcessesExcept    vx_server    facs_launcher    facs_trend
    [Teardown]   apiresources.setTestExitTemperatureToAllSensorPoints
