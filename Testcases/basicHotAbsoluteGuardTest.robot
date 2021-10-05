*** Settings ***
Documentation          This testcase validates the Guard mode feature of AI Engine
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created by Greeshma on 5th July 2021
#...                    Modified on 6th July 2021 as per testcase update in Vigilent Confluence-Steps 2,3,5,9,15,18,20
#...                    New test steps are 3,18 to 21
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/basicHotAbsoluteGuardTestResources.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot


*** Variables ***


*** Test Cases ***
BasicHotAbsoluteGuardTest
    [Setup]    basicHotAbsoluteGuardTestResources.basicHotAbsoluteGuardTestSetup
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->BasicHotAbsoluteGuardTest started.
    #1).Start only vx_server, facs_launcher and facs_trend should be running
    connection.establishConnectionAndStartRequiredProcesses    vx_server  facs_launcher  facs_trend
    #2).Make sure no AHUs are in Guard or Overridden
    apiresources.releaseOverrideOfAllAHUsAndConfirmAHUsAreGuardCleared
    #3)In the CX UI, open the Configs and load the DASHAM template (with overwrite) and hit Save button then close
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    #4)Set System DASHM:: configs NumGuardUnits = 1,NumMinutesGuardTimer = 3, PercentDeadSensorThreshold=100
    #5)Set System SYSTEM::NumMinutesPast=5
    apiresources.changeCxConfigsDashm_NumGuardUnits_NumMinutesGuardTimer_PercentDeadSensorThreshold_AndSystem_NumMinutesPast    ${test_input}[num_guard_units]    ${test_input}[num_minutes_guard_timer]   ${test_input}[percent_deadsensor_threshold]    ${test_input}[num_minutes_past]
    #6).Set the Group properties values->Grp ->Properties->AllowNumExceedencesGuard = 10 AllowNumExceedencesControl = 10
    #AlmHotAbsTemp = 200(degree F) GuardHotAbsTemp = 90 (degrees F)
    #Note 200dF set ALmHotAbsGuard will act same as blank as the alarms wont be triggered
    basicHotAbsoluteGuardTestResources.setGroupProperties_GuardHotAbsTemp_AlmHotAbsTemp_AllowNumExceedencesGuard_AllowNumExceedencesControl    ${test_input}[allow_num_exceedences_control_initial]   ${test_input}[allow_num_exceedences_guard_initial]   ${test_input}[alm_hot_abs_temp_initial]  ${test_input}[guard_hot_abs_temp_intial]
    #7) Set all group temps sensors cool (eg 65 F) …. keep updating them every minute
    apiresources.setCoolingTemperatureForAllSensorPoints    ${test_input}[sensor_point_cooling_temp]
    #8)Start facs_dash process (ie Cooling Control)
    connection.establishConnectionAndStartRequiredProcesses    facs_dash
    #9)Wait 2 minutes
    common.waitForMinutes   2
    #10)Confirm the group  is not in guard[Validation for GroupStatus Control value not to be 2 (Guard=2)]
    apiresources.checkingGuardModeOfGroup    ${guard_switch}[guard_off]
    #11)Set any two temp sensors (call them A & B ) to hot eg to 100 F …
    #pick whichever 2 you want … they should be updated (as hot eg 100 F) every minute a_oid=12010 b_oid=12018
    apiresources.setTemperatureForSensorsAandB   ${test_input}[sensor_point_hot_temp]
    #12)Wait 2 minutes
    common.waitForMinutes   2
    #13)Confirm the group  is in guard now Validation for Group Status Control value is in guard(value should be 2)
    apiresources.checkingGuardModeOfGroup    ${guard_switch}[guard_on]
    #14)Confirm that one AHU goes into guard every 3 minutes
    #15)Once 4 AHUs are in guard then
    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilExpectedNoOfAHUsIntoGuard    ${test_input}[expected_ahu_to_be_on]   ${test_input}[num_guard_units]    ${test_input}[num_minutes_guard_timer]
    #16)Continue updating all the temp sensors to 65 F every minute (including temp sensors A & B)
    apiresources.setCoolingTemperatureForAllSensorPoints    ${test_input}[sensor_point_cooling_temp]
    #17)wait 2 minutes
    common.waitForMinutes   2
    #18)Confirm the group  exits guard
    apiresources.checkingGuardModeOfGroup    ${guard_switch}[guard_off]
    #19)Reset Group configs AllowNumExceedencesGuard = 1 AllowNumExceedencesControl = 0
    #AlmHotAbsTemp = 90
    #GuardHotAbsTemp = 90
    #Set System config DASHM:: PercentDeadSensorThreshold=30
    basicHotAbsoluteGuardTestResources.setGroupProperties_GuardHotAbsTemp_AlmHotAbsTemp_AllowNumExceedencesGuard_AllowNumExceedencesControl    ${test_input}[allow_num_exceedences_control_default]   ${test_input}[allow_num_exceedences_guard_default]   ${test_input}[alm_hot_abs_temp_default]  ${test_input}[guard_hot_abs_temp_default]
    apiresources.setPercentDeadSensorThresholdInDASHMConfig    ${test_input}[percent_deadsensor_threshold_default]
    #20)Confirm  no AHUs are in guard
    apiresources.checkForAllAHUsToBeGuardCleared
    #21)Stop all processes except vx_server, facs_launcher and facs_trend
    connection.establishConnectionAndStopAllProcessesExcept    vx_server    facs_launcher    facs_trend
    #22)End Test
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->BasicHotAbsoluteGuardTest Finished.
    [Teardown]    apiresources.setTestExitTemperatureToAllSensorPoints