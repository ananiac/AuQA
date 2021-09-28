*** Settings ***
Documentation          This testsuite validates the Dead Sensor Guard feature of AI Engine
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created by Greeshma on 28th July 2021
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
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/common.robot
Resource    ${EXECDIR}/Resources/connection.robot


*** Variables ***


*** Test Cases ***
DeadSensorGuardTestSetupSteps
    [Setup]    deadSensorGuardResources.deadSensorGuardTestSetup
    #1)Start system 10.252.9.91 … this has the FTB database on it with the Imputes-test group
    #Only vx_server, facs_launcher, facs_trends should be running
    connection.establishConnectionAndStartRequiredProcesses    vx_server  facs_launcher  facs_trend
    #2)Ensure (manually) that the following group properties are Null for SADC
           ##ControlDeadSensorThreshold
           ##AlarmDeadSensorHysteresis
           #AlarmDeadSensorThreshold
    deadSensorGuardResources.setDeadSensorGuardGroupPropertiesToEmpty
    #3)Load the DASHAM_MIX template in the CX configs (with overwrite) (UI) or DASHAM_RSP_RESET if using the RSP-test group
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    #4)Set SYSTEM::NumMinutesPast=2
    #5)Set DASHM::PercentDeadSensorThreshold = 30%, NumMinutesGuardTimer=2, NumGuardUnits=1
    log to console  FROM EXCEL ${test_input}[ds_num_guard_units_value]
    deadSensorGuardResources.setIntialCxConfigParameters  ${test_input}[ds_num_minutes_past_value]    ${test_input}[ds_percent_dead_sensor_threshold_default_value]   ${test_input}[ds_num_minutes_guard_timer_value]    ${test_input}[ds_num_guard_units_value]
    #6)Set ALARM::GrpDeadSensorHysteresis=10%
    apiresources.setConfigAlarmGroupDeadSensorHysteresis    ${test_input}[grp_dead_sensor_hysteresis_value_default_value]
    #7)Start facs_dash and and facs_sift
    connection.establishConnectionAndStartRequiredProcesses    facs_dash    facs_sift
    #8)In the Imputes-test group, write out all rack temperature sensor points every minute at say 66 F
    apiresources.setCoolingTemperatureForAllSensorPoints    ${test_input}[dead_sensor_test_temp]
    #9)Wait 2 minutes then stop updating the temperatures of one rack (ie 2 temp points)
    #Currently managed within staleState Prevention-implemented with Flag value
    common.waitForMinutes   2
    apiresources.stopUpdatingTemperatureToLastRack    ${test_input}[dead_sensor_test_temp]
    #10)Wait 2 minutes for the 2 points to go stale
    common.waitForMinutes   2
Test1_PercentDeadSensorThreshold_SingleSensorHysteresis
    #11)Write User event “Starting Test 1 … testing DASHM::PercentDeadSensorThreshold and single sensor hysteresis”
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->DeadSensorGuardTest->Starting Test 1->testing DASHM::PercentDeadSensorThreshold and single sensor hysteresis
    #12)Test 1 … testing DASHM::PercentDeadSensorThreshold and single sensor hysteresis
    #a)Set DASHM::PercentDeadSensorThreshold=24.9% … wait one minute - the group enters guard and the GroupDeadSensor alarm is raised
   deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForPerecntDeadSensorThreshold    24.9    ${guard_switch}[guard_on]    ${test_input}[group_dead_sensor_alarm_on]
    #b)Set DASHM::PercentDeadSensorThreshold=25.1% … wait one minute - the group exits guard and the GroupDeadSensor alarm is still raised
   deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForPerecntDeadSensorThreshold    25.1    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_on]
    #c)Set DASHM::PercentDeadSensorThreshold=37.4% … wait one minute - the group is not in guard but the GroupDeadSensor alarm is still raised
   deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForPerecntDeadSensorThreshold    37.4    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_on]
    #d)Set DASHM::PercentDeadSensorThreshold=37.5% … wait one minute - the group is not in guard and now the alarm clears
   deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForPerecntDeadSensorThreshold    37.5    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_off]
Test2_ControlDeadSensorThreshold_SingleSensorHysteresis
    #13)Write User event “Starting Test2 … testing group property ControlDeadSensorThreshold and single sensor hysteresis
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Starting Test2->testing group property ControlDeadSensorThreshold and single sensor hysteresis
    #14)Test 2 … testing group property ControlDeadSensorThreshold and single sensor hysteresis
    #a)Set group property ControlDeadSensorThreshold=30% … wait one minute - the group does not enter  guard and the GroupDeadSensor alarm is not raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForControlDeadSensorThreshold    30    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_off]
    #b)Set group property ControlDeadSensorThreshold=24.9% … wait one minute - the group enters guard and the GroupDeadSensor alarm is raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForControlDeadSensorThreshold    24.9    ${guard_switch}[guard_on]    ${test_input}[group_dead_sensor_alarm_on]
    #c)Set group property ControlDeadSensorThreshold=25.1% … wait one minute - the group exits guard and the GroupDeadSensor alarm is still raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForControlDeadSensorThreshold    25.1    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_on]
    #d)Set group property ControlDeadSensorThreshold=37.4% … wait one minute - the group is not in guard but the GroupDeadSensor alarm is still raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForControlDeadSensorThreshold    37.4    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_on]
    #e)Set group property ControlDeadSensorThreshold=37.5% … wait one minute - the group is not in guard and now the GroupDeadSensor alarm clears
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForControlDeadSensorThreshold    37.5    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_off]
Test3_CxConfigALARM_GrpDeadSensorThreshold
    #15)Write User event “Test 3 …. testing ALARM::GrpDeadSensorThreshold”
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Test 3->testing ALARM::GrpDeadSensorThreshold
    #16)Test 3 …. testing ALARM::GrpDeadSensorThreshold
    #a)Set config DASHM::PercentDeadSensorThreshold=100%
    apiresources.setPercentDeadSensorThresholdInDASHMConfig    100
    #b)Set group property ControlDeadSensorThreshold=100%
    apiresources.setGroupPropertyFloatValue    ControlDeadSensorThreshold    100
    #c)Set config ALARM::GrpDeadSensorThreshold=20% … wait one minute - no guard and GroupDeadSensor alarm is raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold    20    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_on]
    #d)Set config ALARM::GrpDeadSensorThreshold=37.4% … wait one minute -  no guard but GroupDeadSensor alarm is still raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold    37.4    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_on]
    #e)Set config ALARM::GrpDeadSensorThreshold=37.5% … wait one minute - no guard and GroupDeadSensor alarm is cleared
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold    37.5    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_off]
Test4_CxConfigALARM_GrpDeadSensorHysteresis
    #17)Write User event “Test 4 … testing ALARM::GrpDeadSensorHysteresis”
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Test 4->testing ALARM::GrpDeadSensorHysteresis
    #18)Test 4 … testing ALARM::GrpDeadSensorHysteresis
    #a)Set config ALARM::GrpDeadSensorHysteresis=20%
    apiresources.setConfigAlarmGroupDeadSensorHysteresis    20
    #b)Set config ALARM::GrpDeadSensorThreshold=20% … wait one minute - no guard and GroupDeadSensor alarm is raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold    20    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_on]
    #c)Set config ALARM::GrpDeadSensorThreshold=37.5% … wait one minute -  no guard but GroupDeadSensor alarm is still raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold    37.5    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_on]
    #d)Set config ALARM::GrpDeadSensorThreshold=44.9% … wait one minute - no guard but GroupDeadSensor alarm is still raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold    44.9    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_on]
    #e)Set config ALARM::GrpDeadSensorThreshold=45% … wait one minute - no guard and GroupDeadSensor alarm is cleared
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForGrpDeadSensorThreshold    45    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_off]
Test5_AlarmDeadSensorThreshold
    #19)Write User event “Test 5 … testing group property AlarmDeadSensorThreshold”
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Test 5->testing group property AlarmDeadSensorThreshold
    #20)Test 5 … testing group property AlarmDeadSensorThreshold
    #a)Set config ALARM::GrpDeadSensorThreshold=100%
    apiresources.setConfigAlarmGroupDeadSensorThreshold    100
    #b)Set config ALARM::GrpDeadSensorHysteresis=10%
    apiresources.setConfigAlarmGroupDeadSensorHysteresis    10
    #c)Set  group property AlarmDeadSensorThreshold=30% … wait one minute - no guard and no GroupDeadSensor alarm
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    30    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_off]
    #d)Set  group property AlarmDeadSensorThreshold=24% … wait one minute -  no guard and the GroupDeadSensor alarm is raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    24    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_on]
    #e)Set group property AlarmDeadSensorThreshold=37.4% … wait one minute -  no guard but GroupDeadSensor alarm is still raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    37.4    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_on]
    #f)Set group property AlarmDeadSensorThreshold=37.5% … wait one minute -  no guard but GroupDeadSensor alarm clears
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    37.5    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_off]
Test6_AlarmDeadSensorHysteresis
    #21)Write User event “Test 6 … testing group property AlarmDeadSensorHysteresis”
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Test 6->testing group property AlarmDeadSensorHysteresis
    #22)Test 6 … testing group property AlarmDeadSensorHysteresis (0% means ignore)
    #a)Set group property AlarmDeadSensorHysteresis=20%
    apiresources.setGroupPropertyFloatValue  AlarmDeadSensorHysteresis    20
    #b)Set config ALARM::GrpDeadSensorHysteresis=25%
    apiresources.setConfigAlarmGroupDeadSensorHysteresis    25
    #c)Set  group property AlarmDeadSensorThreshold=24% … wait one minute -  no guard and the GroupDeadSensor alarm is raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    24    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_on]
    #d)Set group property AlarmDeadSensorThreshold=45% … wait one minute -  no guard but GroupDeadSensor alarm clears
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    45    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_off]
    #e)Set config ALARM::GrpDeadSensorHysteresis=15%
    apiresources.setConfigAlarmGroupDeadSensorHysteresis    15
    #f)Set group property AlarmDeadSensorThreshold=24% … wait one minute -  no guard and the GroupDeadSensor alarm is raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    24    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_on]
    #g)Set group property AlarmDeadSensorThreshold=40.1% … wait one minute -  no guard but GroupDeadSensor alarm is still raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    40.1    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_on]
    #h)Set group property AlarmDeadSensorThreshold=45% … the group is not in guard and now the GroupDeadSensor alarm clears
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    45    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_off]
    #i)Set group property AlarmDeadSensorHysteresis=0%
    apiresources.setGroupPropertyFloatValue  AlarmDeadSensorHysteresis    0
    #j)Set  group property AlarmDeadSensorThreshold=24% … wait one minute -  no guard and the GroupDeadSensor alarm is raised
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    24    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_on]
    #k)Set group property AlarmDeadSensorThreshold=37.5% … wait one minute -  no guard but GroupDeadSensor alarm clears
    deadSensorGuardResources.checkGuardAndGroupDeadSensorAlarmStatusForAlarmDeadSensorThreshold    37.5    ${guard_switch}[guard_off]    ${test_input}[group_dead_sensor_alarm_off]
    #23)End Test
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->DeadSensorGuard Test finsihed.
    #24)Cleanup
Cleanup
    [Teardown]   apiresources.setTestExitTemperatureToAllSensorPoints
    #a)In the CX UI, open the Configs and load the DASHAM template (with overwrite) and hit Save button then close    #confirm this steps
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    #b)Set group property ControlDeadSensorThreshold=0
    #c)Set group property AlarmDeadSensorHysteresis=0
    #d)Set group property AlarmDeadSensorThreshold=0
    deadSensorGuardResources.setDeadSensorGuardGroupPropertiesToEmpty
    #25)Stop all processes except vx_server, facs_launcher and facs_trend
    connection.establishConnectionAndStopAllProcessesExcept    vx_server    facs_launcher    facs_trend
    #26)Exit test