*** Settings ***
Documentation          This testsuite validates the Dead Sensor Guard feature of AI Engine
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
...                    Created by Greeshma on 28th July 2021
...                    This testsuite consist of 5 different types Dead Sensor Guard testcase
...                    It has to be running in parallel with staleStatePrevention program
...                     For all the tests , 25% of the sensors will be in stale via staleStatePrevention program
...                     Thresold and Hysteresis calculations are done w.r.t to this 25%
...     If the Hysteresis is not set,then 12.5% is considered as the default Hysteresis
...      for the Alarm Clearence Threshold value calculation
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Resource    ${EXECDIR}/Resources/deadSensorGuardResources.robot
Resource    ${EXECDIR}/Resources/apiresources.robot
Variables   ${EXECDIR}/Inputs/deadSensorGuardInputs.py


*** Variables ***


*** Test Cases ***
DeadSensorGuardTestSetupSteps
    [Setup]    deadSensorGuardResources.deadSensorGuardTestSetup
    #1)Start system 10.252.9.91 … this has the FTB database on it with the SADC group
    #Only vx_server, facs_launcher, facs_trends, and facs_sift should be running    (facs_dash also)
    deadSensorGuardResources.startVx_serverFacs_launcherFacs_siftFacs_dashAndFacs_trend
    #2)Ensure (manually) that the following group properties are Null for SADC :-     #Abhijit code to be merged here
           ##ControlDeadSensorThreshold
           ##AlarmDeadSensorHysteresis
           #AlarmDeadSensorThreshold
    deadSensorGuardResources.setDeadSensorGuardGroupPropertiesToEmpty
    #3)Load the DASHAM_MIX template in the CX configs (with overwrite) (UI)
    deadSensorGuardResources.reloadDefaultDASHMTemplateFromUI
    #4)Set SYSTEM::NumMinutesPast=2
    #5)Set DASHM::PercentDeadSensorThreshold = 30%, NumMinutesGuardTimer=2, NumGuardUnits=1
    deadSensorGuardResources.setIntialCxConfigParameters  ${ds_num_minutes_past_value}    ${ds_percent_deadsensor_threshold_default_value}   ${ds_num_minutes_guard_timer_value}    ${ds_num_guard_units_value}
    #6)Set ALARM::GrpDeadSensorHysteresis=10%
    apiresources.setConfigAlarmGroupDeadSensorHysteresis    ${grp_dead_sensor_hysteresis_value_default_value}
    #7)In the SADC group, write out all rack temperature sensor points every minute at say 66 F
    apiresources.setCoolingTemperatureForAllSensorPoints    ${dead_sensor_test_temp}
    #8)Wait 2 minutes then stop updating the temperatures of one rack (ie 2 temp points)
    #Currently managed within staleState Prevention-Now implemented with Flag value
    apiresources.waitForTwoMinutes
    apiresources.stopUpdatingTemperatureToLastRack    ${dead_sensor_test_temp}
    #9)Wait 2 minutes for the 2 points to go stale
    apiresources.waitForTwoMinutes
    #10)Test1_PercentDeadSensorThreshold_SingleSensorHysteresis
Test1_PercentDeadSensorThreshold_SingleSensorHysteresis
    #a)Set DASHM::PercentDeadSensorThreshold=24.9% … wait one minute - the group enters guard and the GroupDeadSensor alarm is raised
   deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForPerecntDeadSensorThreshold    24.9    ${guard_on}    ${group_dead_sensor_alarm_on}
    #b)Set DASHM::PercentDeadSensorThreshold=25.1% … wait one minute - the group exits guard and the GroupDeadSensor alarm is still raised
   deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForPerecntDeadSensorThreshold    25.1    ${guard_off}    ${group_dead_sensor_alarm_on}
    #c)Set DASHM::PercentDeadSensorThreshold=37.4% … wait one minute - the group is not in guard but the GroupDeadSensor alarm is still raised
   deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForPerecntDeadSensorThreshold    37.4    ${guard_off}    ${group_dead_sensor_alarm_on}
    #d)Set DASHM::PercentDeadSensorThreshold=37.5% … wait one minute - the group is not in guard and now the alarm clears
   deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForPerecntDeadSensorThreshold    37.5    ${guard_off}    ${group_dead_sensor_alarm_off}
    #11)Test 2 … testing group property ControlDeadSensorThreshold and single sensor hysteresis
Test2_ControlDeadSensorThreshold_SingleSensorHysteresis
    #a)Set group property ControlDeadSensorThreshold=30% … wait one minute - the group does not enter  guard and the GroupDeadSensor alarm is not raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForControlDeadSensorThreshold    30    ${guard_off}    ${group_dead_sensor_alarm_off}
    #b)Set group property ControlDeadSensorThreshold=24.9% … wait one minute - the group enters guard and the GroupDeadSensor alarm is raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForControlDeadSensorThreshold    24.9    ${guard_on}    ${group_dead_sensor_alarm_on}
    #c)Set group property ControlDeadSensorThreshold=25.1% … wait one minute - the group exits guard and the GroupDeadSensor alarm is still raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForControlDeadSensorThreshold    25.1    ${guard_off}    ${group_dead_sensor_alarm_on}
    #d)Set group property ControlDeadSensorThreshold=37.4% … wait one minute - the group is not in guard but the GroupDeadSensor alarm is still raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForControlDeadSensorThreshold    37.4    ${guard_off}    ${group_dead_sensor_alarm_on}
    #e)Set group property ControlDeadSensorThreshold=37.5% … wait one minute - the group is not in guard and now the GroupDeadSensor alarm clears
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForControlDeadSensorThreshold    37.5    ${guard_off}    ${group_dead_sensor_alarm_off}
    #12)Test 3 …. testing ALARM::GrpDeadSensorThreshold
Test3_CxConfigALARM_GrpDeadSensorThreshold
    #a)Set config DASHM::PercentDeadSensorThreshold=100%
    apiresources.setPercentDeadSensorThresholdInDASHMConfig    100
    #b)Set group property ControlDeadSensorThreshold=100%
    deadSensorGuardResources.setControlDeadSensorThresholdOfGroupProperties    100
    #c)Set config ALARM::GrpDeadSensorThreshold=20% … wait one minute - no guard and GroupDeadSensor alarm is raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold    20    ${guard_off}    ${group_dead_sensor_alarm_on}
    #d)Set config ALARM::GrpDeadSensorThreshold=37.4% … wait one minute -  no guard but GroupDeadSensor alarm is still raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold    37.4    ${guard_off}    ${group_dead_sensor_alarm_on}
    #e)Set config ALARM::GrpDeadSensorThreshold=37.5% … wait one minute - no guard and GroupDeadSensor alarm is cleared
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold    37.5    ${guard_off}    ${group_dead_sensor_alarm_off}
    #13)Test 4 … testing ALARM::GrpDeadSensorHysteresis
Test4_CxConfigALARM_GrpDeadSensorHysteresis
    #a)Set config ALARM::GrpDeadSensorHysteresis=20%
    apiresources.setConfigAlarmGroupDeadSensorHysteresis    20
    #b)Set config ALARM::GrpDeadSensorThreshold=20% … wait one minute - no guard and GroupDeadSensor alarm is raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold    20    ${guard_off}    ${group_dead_sensor_alarm_on}
    #c)Set config ALARM::GrpDeadSensorThreshold=37.5% … wait one minute -  no guard but GroupDeadSensor alarm is still raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold    37.5    ${guard_off}    ${group_dead_sensor_alarm_on}
    #d)Set config ALARM::GrpDeadSensorThreshold=44.9% … wait one minute - no guard but GroupDeadSensor alarm is still raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold    44.9    ${guard_off}    ${group_dead_sensor_alarm_on}
    #e)Set config ALARM::GrpDeadSensorThreshold=45% … wait one minute - no guard and GroupDeadSensor alarm is cleared
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold    45    ${guard_off}    ${group_dead_sensor_alarm_off}
    #14)Test 5 … testing group property AlarmDeadSensorThreshold
Test5_AlarmDeadSensorThreshold
    #a)Set config ALARM::GrpDeadSensorThreshold=100%
    apiresources.setConfigAlarmGroupDeadSensorThreshold    100
    #b)Set config ALARM::GrpDeadSensorHysteresis=10%
    apiresources.setConfigAlarmGroupDeadSensorHysteresis    10
    #c)Set  group property AlarmDeadSensorThreshold=30% … wait one minute - no guard and no GroupDeadSensor alarm
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    30    ${guard_off}    ${group_dead_sensor_alarm_off}
    #d)Set  group property AlarmDeadSensorThreshold=24% … wait one minute -  no guard and the GroupDeadSensor alarm is raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    24    ${guard_off}    ${group_dead_sensor_alarm_on}
    #e)Set group property AlarmDeadSensorThreshold=37.4% … wait one minute -  no guard but GroupDeadSensor alarm is still raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    37.4    ${guard_off}    ${group_dead_sensor_alarm_on}
    #f)Set group property AlarmDeadSensorThreshold=37.5% … wait one minute -  no guard but GroupDeadSensor alarm clears
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    37.5    ${guard_off}    ${group_dead_sensor_alarm_off}
   #15)Test 6 … testing group property AlarmDeadSensorHysteresis (0% means ignore)
Test6_AlarmDeadSensorHysteresis
    #a)Set group property AlarmDeadSensorHysteresis=20%
    deadSensorGuardResources.setAlarmDeadSensorHysteresisOfGroupProperties    20
    #b)Set config ALARM::GrpDeadSensorHysteresis=25%
    apiresources.setConfigAlarmGroupDeadSensorHysteresis    25
    #c)Set  group property AlarmDeadSensorThreshold=24% … wait one minute -  no guard and the GroupDeadSensor alarm is raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    24    ${guard_off}    ${group_dead_sensor_alarm_on}
   #d)Set group property AlarmDeadSensorThreshold=45% … wait one minute -  no guard but GroupDeadSensor alarm clears
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    45    ${guard_off}    ${group_dead_sensor_alarm_off}
    #e)Set config ALARM::GrpDeadSensorHysteresis=15%
    apiresources.setConfigAlarmGroupDeadSensorHysteresis    15
    #f)Set group property AlarmDeadSensorThreshold=24% … wait one minute -  no guard and the GroupDeadSensor alarm is raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    24    ${guard_off}    ${group_dead_sensor_alarm_on}
    #g)Set group property AlarmDeadSensorThreshold=40.1% … wait one minute -  no guard but GroupDeadSensor alarm is still raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    40.1    ${guard_off}    ${group_dead_sensor_alarm_on}
    #h)Set group property AlarmDeadSensorThreshold=45% … the group is not in guard and now the GroupDeadSensor alarm clears
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    45    ${guard_off}    ${group_dead_sensor_alarm_off}
    #i)Set group property AlarmDeadSensorHysteresis=0%
    deadSensorGuardResources.setAlarmDeadSensorHysteresisOfGroupProperties    0
    #j)Set  group property AlarmDeadSensorThreshold=24% … wait one minute -  no guard and the GroupDeadSensor alarm is raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    24    ${guard_off}    ${group_dead_sensor_alarm_on}
    #k)Set group property AlarmDeadSensorThreshold=37.5% … wait one minute -  no guard but GroupDeadSensor alarm clears
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    37.5    ${guard_off}    ${group_dead_sensor_alarm_off}
    #16)End Test
    #17)Cleanup
Cleanup
    [Teardown]   apiresources.setTestExitTemperatureToFirstSensorPoint
    #a)In the CX UI, open the Configs and load the DASHAM template (with overwrite) and hit Save button then close    #confirm this steps
    deadSensorGuardResources.reloadDefaultDASHMTemplateFromUI
    #b)Set group property ControlDeadSensorThreshold=0
    #c)Set group property AlarmDeadSensorHysteresis=0
    #d)Set group property AlarmDeadSensorThreshold=0
    deadSensorGuardResources.setDeadSensorGuardGroupPropertiesToEmpty
    #18)Exit test




















