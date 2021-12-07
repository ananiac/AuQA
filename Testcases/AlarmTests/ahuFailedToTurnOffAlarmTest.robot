*** Settings ***
Documentation          This testcase validates the Hot Guard mode feature of AI Engine
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/AlarmTestsResources/ahuFailedToTurnOffAlarmResources.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot
Resource    ${EXECDIR}/Resources/common.robot


*** Test Cases ***
AHUFailedToTurnOFFAlarm
    log to console  Alarm1
    #1)Start system with the AuQa DB on it (e.g., 10.252.9.118)
        #2)Stop all processes including the API Server (vx_server) and Script Launcher
        #3)Wait 2 minutes
#    ahuFailedToTurnOffAlarmResources.robot.ahuFailedToTurnOffAlarmTestPreconditionSetup
    #2)Use the NoBinding group
    #3)Load the DASHAM_MIX template in the CX configs (with overwrite)
#    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
#    common.setFlagValue 2

#    apiresources.setCoolingTemperatureForAllSensorPoints    ${test_input}[hot_guard_intial_temp_all_racks]



    #4)Confirm config DASHM::AllowNumExceedencesGuard=1 and CATGuardBandRange=4 and for AHU NB-AHU-13 set the OnPwrLvl property to 0.5
    #5)Write User event - “confirmed config DASHM::AllowNumExceedencesGuard=1, CATGuardBandRange=4 AHU NB-AHU-13 OnPwrLvl =0.5”
    #6)Set all Setpoint to 80.6/64.4
#    common.setFlagValue     2
    #7)Set all rack temperature sensor points every minute at say 80.6 F
#    apiresources.setCoolingTemperatureForAllSensorPoints    80.6
    #8)Override all AHUs in NoBindings Group to OFF
    #9)Wait 2 minutes
    #10)Set AHU PWR to 0.1kW
    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  80.6  86     76      0.1
#    common.setFlagValue    6
    #11)Clear Overrides
    #12)Run for 5 minutes
    #13)Run The PublicAPI call to check for alarms
    #14)Ensure there are no Failed to Turn Off Alarms
    #15)Set the AHU NB-AHU-13 PWR to 10kW
    #16)Expect AHU NB-AHU-13 to go into Mismatch on the Equipment Tab and Failed to Turn OFF alarm is produced
    #17)Wait 2 minutes
    #18)Run The PublicAPI call to check for alarms
    #19)Ensure there are a Failed to Turn OFF Alarm
    #20)Write User event whether or not the Failed to Turn OFF alarm is raised
    #21)Set the AHU NB-AHU-13 PWR to 0.1kW
    #22)Expect 'Mismatch' in the State Column of the Equipment Tab Changes to 'Cooling' and Failed to Turn OFF ends
    #23)Run The PublicAPI call to check for alarms
    #24)Ensure there are no Failed to Turn OFF Alarms
    #25)Write User event “Failed to Turn OFF Alarms Cleared Successfully” or Unsuccessfully, whichever is the case.
    #26)Write User event “Ending Failed to turn OFF test”
    #27)End test
    #28)Stop all processes except vx_server, facs_launcher, and facs_trend
    #29)Clean up


