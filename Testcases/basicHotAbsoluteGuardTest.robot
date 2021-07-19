*** Settings ***
Documentation          This testcase validates the Guard mode feature of AI Engine
...                    Created by Greeshma on 5th July 2021
...                    Modified on 6th July 2021 as per testcase update in Vigilent Confluence-Steps 2,3,5,9,15,18,20
...                    New test steps are 3,18 to 21
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Resource    ../Resources/apiresources.robot
Resource    ../Resources/uiresources.robot
Resource    ../Resources/connection.robot
Variables    ../Inputs/basicHotAbsoluteGuardInputs.py


*** Variables ***

*** Test Cases ***
BasicHotAbsoluteGuardTest
    #1).Start vx_server,fac_dash and facs_trend
    connection.establishConnectionAndStartProcesses
    #2)In the CX UI, open the Configs and load the DASHAM template (with overwrite) and hit Save button then close
    uiresources.resetGroupPropertiesUsingLoadTemplateOptionWithOverwrite
    #3)Set System DASHM:: configs NumGuardUnits = 1,NumMinutesGuardTimer = 3, PercentDeadSensorThreshold=20
    #4)Set System SYSTEM::NumMinutesPast=5
    apiresources.changeCxConfigsDashm_NumGuardUnits_NumMinutesGuardTimer_PercentDeadSensorThreshold_AndSystem_NumMinutesPast    ${num_guard_units}    ${num_minutes_guard_timer}   ${percent_deadsensor_threshold}    ${num_minutes_past}
    #5).Set the Group properties values->Grp GRP00->Properties->AllowNumExceedencesGuard = 10 AllowNumExceedencesControl = 10
    #AlmHotAbsTemp = 200(degree F) GuardHotAbsTemp = 90 (degrees F)
    #Note 200dF set ALmHotAbsGuard will act same as blank as the alarms wont be triggered
    apiresources.setGroupPropertiesGuardHotAbsTempAllowNumExceedencesGuardAndControl    ${allow_num_exceedences_control_initial}   ${allow_num_exceedences_guard_initial}   ${alm_hot_abs_temp_initial}  ${guard_hot_abs_temp_intial}
    #6) Set all group temps sensors cool (eg 65 F) …. keep updating them every minute
    apiresources.setRackSensorPointsTemperature    ${sensor_point_cooling_temp}
    #7)Start facs_dash process (ie Cooling Control)
    establishConnectionAndStartCoolingControlProcess
    #8)Wait 2 minutes
    apiresources.waitForTwoMinutes
    #9)Confirm the group GRP00 is not in guard[Validation for GroupStatus Control value not to be 2 (Guard=2)]
    apiresources.checkGroupControlStatusValueNotInGuard
    #10)Set any two temp sensors (call them A & B ) to hot eg to 100 F …
    #pick whichever 2 you want … they should be updated (as hot eg 100 F) every minute a_oid=12010 b_oid=12018
    apiresources.setTemperatureForSensorsAandB   ${sensor_point_hot_temp}
    #11)Wait 2 minutes
    apiresources.waitForTwoMinutes
    #12)Confirm the group GRP00 is in guard now Validation for Group Status Control value is in guard(value should be 2)
    apiresources.checkGroupControlStausValueInGuard
    #13)Confirm that one AHU goes into guard every 3 minutes
    #14)Once 4 AHUs are in guard then
    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilFourAHUsReached    ${num_guard_units}    ${num_minutes_guard_timer}
    #15)Continue updating all the temp sensors to 65 F every minute (including temp sensors A & B)
    apiresources.setRackSensorPointsTemperature    ${sensor_point_cooling_temp}
    #16)wait 2 minutes
    apiresources.waitForTwoMinutes
    #17)Confirm the group GRP00 exits guard
    apiresources.checkGroupControlStatusValueNotInGuard
    #18)Reset Group configs for group  GRP00 AllowNumExceedencesGuard = blank AllowNumExceedencesControl = blank
    #AlmHotAbsTemp = blank
    #GuardHotAbsTemp = blank
    #Set System config DASHM:: PercentDeadSensorThreshold=30
    apiresources.setGroupPropertiesGuardHotAbsTempAllowNumExceedencesGuardAndControl    ${allow_num_exceedences_control_default}   ${allow_num_exceedences_guard_default}   ${alm_hot_abs_temp_default}  ${guard_hot_abs_temp_default}
    setPercentDeadSensorThresholdInDASHMConfig    ${percent_deadsensor_threshold_default}
    #19)Confirm  no AHUs are in guard
    apiresources.checkForAllAHUsToBeGuardCleared
    #20)Stop facs_dash (Cooling Control)
    connection.establishConnectionAndStopCoolingControlProcess
    #21)End Test


