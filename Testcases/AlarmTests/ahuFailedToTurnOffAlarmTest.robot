*** Settings ***
Documentation          This testcase validates Alarm-01 AHU Failed to Turn OFF Alarm Automated Test Steps
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/AlarmTestsResources/ahuFailedToTurnOffAlarmResources.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot
Resource    ${EXECDIR}/Resources/common.robot
Resource    ${EXECDIR}/Resources/OverrideTestResources/minOnTestResources.robot

*** Test Cases ***
AHUFailedToTurnOFFAlarm
#        log to console  Alarm1
#        apiresources.queryToFetchAlarmMsgAHUFailToTurOff
    #1)Start system with the AuQa DB on it (e.g., 10.252.9.118)
    #2)Stop all processes including the API Server (vx_server) and Script Launcher
    #3)Wait 2 minutes
    ahuFailedToTurnOffAlarmResources.ahuFailedToTurnOffAlarmTestPreconditionSetup
    #4)Start API Server (vx_server), BACnet commplug, facs_dash (Cooling Control), and facs_sift (Application Metrics) processes
    #5)Use the NoBinding group
    #scripting Note: Group name is sent as the varaible from the command line while executing the testcases
    #6)Start the Script Launcher Application Metrics, Cooling Control and Bacnet
    connection.establishConnectionAndStartRequiredProcesses    vx_server  facs_launcher     vems-plugin-bacnet     facs_dash   facs_sift
    #7)Load the DASHAM_MIX template in the CX configs (with overwrite)
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    #8)Confirm config DASHM::AllowNumExceedencesGuard=1 and CATGuardBandRange=4 and for AHU NB-AHU-13 set the OnPwrLvl property to 0.5
    ahuFailedToTurnOffAlarmResources.setAllowNumExceedencesGuardCATGuardBandRangeOnPwrLvl
    #9)Write User event - “confirmed config DASHM::AllowNumExceedencesGuard=1, CATGuardBandRange=4 AHU NB-AHU-13 OnPwrLvl =0.5”
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->AHUFailedToTurnOFFAlarmTest-> confirmed config DASHM::AllowNumExceedencesGuard=1, CATGuardBandRange=4 AHU NB-AHU-13 OnPwrLvl =0.5
    #10)Set all Setpoint to 80.6/64.4
    apiresources.setAllHighAndLowSetPointLimits    ${test_input}[high_set_point_limit]    ${test_input}[low_set_point_limit]
    #11)Override all AHUs in NoBindings Group to OFF
    minOnTestResources.overrideAllAHUsWithBOPValueOFF
    #12)Wait 2 minutes
    common.waitForMinutes    2
    #13)Set all rack temperature sensor points every minute at say 80.6 F
    #14)Set AHU PWR to 0.1kW
    #15)Set AHUs PWR to 0.1kW RAT=86F and DAT=76F
        #apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  80.6  86     76      0.1
    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_tempF]  ${test_input}[rat_tempF]    ${test_input}[dat_tempF]      ${test_input}[power_monitor_pwr1_kW]
    #16)Clear Overrides
    apiresources.releaseOverrideOfAllAHUs
    #17)Run for 3 minutes the data that will cause no alarms to occur. The values that are in step 7. Set the RAT to 86F and the DAT 76F ad the PWR to 0.1. This should allow alarms to clear.
    common.waitForMinutes    3
    #18)Run The PublicAPI call to check for alarms
    apiresources.queryToFetchJsonResponseAlarmMsgAHUFailToTurOff
    #a)Ensure there are no Failed to Turn Off Alarms
    ahuFailedToTurnOffAlarmResources.noFailedToTurnOffAlarms
    #19)Set the all AHU to 10kW
        ##common.setFlagValue    6
        ##apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  80.6  86     76      10
    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_tempF]  ${test_input}[rat_tempF]    ${test_input}[dat_tempF]      ${test_input}[power_monitor_pwr2_kW]
    #21)Wait 2 minutes
    common.waitForMinutes    2
    #20)Expect AHU NB-AHU-13 to go into Mismatch on the Equipment Tab and Failed to Turn OFF alarm is produced
    ##apiresources.queryToFetchAHUMismatchForAHUFailToTurOffAlarm
    ahuFailedToTurnOffAlarmResources.verifyAHUMismatchForAHUFailToTurOffAlarm
    #22)Run The PublicAPI call to check for alarms
    apiresources.queryToFetchAlarmMsgAHUFailToTurOff
    #23)Ensure there are a Failed to Turn OFF Alarm
    #24)Write User event whether or not the Failed to Turn OFF alarm is raised
    ahuFailedToTurnOffAlarmResources.failedToTurnOffAlarmsRaised

    #n)Set all the AHU NB-AHU-13 PWR to 0.1kW
    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_tempF]  ${test_input}[rat_tempF]    ${test_input}[dat_tempF]      ${test_input}[power_monitor_pwr1_kW]
    common.waitForMinutes    2
    #n)Expect 'Mismatch' in the State Column of the Equipment Tab Changes to 'off' and Failed to Turn OFF ends
    ahuFailedToTurnOffAlarmResources.verifyAhuStateForAHUFailToTurOffAlarm
    #n)Run The PublicAPI call to check for alarms
    apiresources.queryToFetchJsonResponseAlarmMsgAHUFailToTurOff
    #n)Ensure there are no Failed to Turn OFF Alarms
    ahuFailedToTurnOffAlarmResources.noFailedToTurnOffAlarms
    #n)Write User event “Failed to Turn OFF Alarms Cleared Successfully” or Unsuccessfully, whichever is the case.
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->AHUFailedToTurnOFFAlarmTest->Failed to Turn OFF Alarms Cleared Successfully
    #n)Write User event “Ending Failed to turn OFF test”
    #n)End test
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->AHUFailedToTurnOFFAlarmTest->Ending Failed to turn OFF test
    #n)Clean up
CleanUp
    #n)Stop all processes except vx_server, facs_launcher, and facs_trend
    connection.establishConnectionAndStopAllProcessesExcept    vx_server    facs_launcher    facs_trend
    [Teardown]   apiresources.setTestExitTemperatureToAllSensorPoints
