*** Settings ***
Documentation          This testcase validates the Guard mode feature of AI Engine
...                    Created by Greeshma on 5th July 2021
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Resource    ../Resources/apiresources.robot
Resource    ../Resources/connection.robot


*** Variables ***

*** Test Cases ***
TestAbsoluteHotGuardTemperature
#1).Start vx_server,fac_dash and facs_trend
    establishConnectionAndStartProcesses
#2).Set Guard Units and Guard timer under CX->Tools->Config->DASHM->Timer 3minutes,GuardUnits 1
# 1    3
   changeNumGuardUnitsAndNumMinutesGuardTimer    2   5
#3).Set the Group properties values->Grp GRP00->Properties->AllowNumExceedencesGuard = 10 AllowNumExceedencesControl = 10
    #AlmHotAbsTemp = 200(degree F) GuardHotAbsTemp = 90 (degrees F)
    # 10  10  200.00  90.00
    #Note 200dF set ALmHotAbsGuard will act same as blank as the alarms wont be triggered
    setGroupPropertiesGuardHotAbsTempAllowNumExceedencesGuardAndControl    11  11  212.00  91.00
#4 write to the sensors 65F
    setRackPointsTemperature    65.50
#5)Start facs_dash process (ie Cooling Control)
    establishConnectionAndStartCoolingControlProcess
#6)Wait 2 minutes
    waitForTwoMinutes
#7)Validation for GroupStatus Control value not to be 2 (Guard=2)
    #checkGroupControlStatusValueNotInGuard
#10)Validation for Group Status Control value is in guard(value should be 2)
    #checkGroupControlStausValueInGuard
#11-12)Validate the number of AHUs in guard every 3 minutes (first 3minutes)
    #checkAHUToBeInGuard



