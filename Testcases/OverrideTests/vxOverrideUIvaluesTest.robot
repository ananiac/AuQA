*** Settings ***
Documentation          To verify the abillity to override individual AHUs with the constraints of Group properties SFCMin and SFCMax.
...                    Also to verify the VX > Equipment UI displays the correct values when manually overrided and when returned to system control
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created by Greeshma on 29th Oct 2021
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/OverrideTestResources/vxOverrideUIvaluesResources.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot


*** Variables ***


*** Test Cases ***
OverrideCombinationCheck
    #1)Start system with the AuQa DB on it (e.g., 10.252.9.118)
    #2)Stop all processes including the API Server (vx_server) and Script Launcher
    #3)Wait 2 minutes
    vxOverrideUIvaluesResources.vxOverrideUIvaluesTestPreconditionSetup
    #4)Use the General-test group
    #5)Start the API Server (vx_server) and Script Launcher processes
    connection.establishConnectionAndStartRequiredProcesses    vx_server  facs_launcher
    #6)Load the DASHAM_MIX template template in the CX configs (with overwrite) … or DASHAM_RSP_RESET template if using RSP-test group
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    #7)Start all Plugins (Bacnet, Dust, Smartmesh)
    #8)Start all other processes except Calibration (facs_cp), Learning (facs_cl), and Simulation (dcsim)
    connection.establishConnectionAndStartRequiredProcesses    vems-plugin-smart-mesh-ip  vems-plugin-dust  vems-plugin-modbus  vems-plugin-bacnet    facs_dash    facs_sift    facs_trend  facs_cleanup  vems-snmp
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Started Test->Override-1 test
    #9)Set group property GuardHotAbsTemp=99
    apiresources.setGroupPropertyGuardHotAbsTemp     ${test_input}[guard_hot_abs_temp_intial]
    #10)Set AHU Properties FanCtrlMin = 50% and FanCtrlMax = 100%
    apiresources.setFanCtrlMinMaxValueOfAllAHUs    ${test_input}[fan_ctlr_min_value]    ${test_input}[fan_ctrl_max_value]
    #11)Write user event “Set config DASHM::NumGuardUnits=1, NumMinutesGuardTimer=1, and SYSTEM::NumMinutesPast=20”
    #12)Set config DASHM::NumGuardUnits=1, NumMinutesGuardTimer=1, and SYSTEM::NumMinutesPast=20
    apiresources.setconfigNumGuardUnitsNumMinutesGuardTimerAndNumMinutesPast    ${test_input}[config_num_guard_units_value]    ${test_input}[config_num_minutes_guard_timer_value]  ${test_input}[config_system_num_minutes_past]
    #13)Set all rack setpoints to 80.6/64.4
    apiresources.setAllHighAndLowSetPointLimits    ${test_input}[high_set_point_limit]    ${test_input}[low_set_point_limit]
    #14)Set all rack temperature sensor points every minute to 66 F
    #15)Set all RAT sensors to 68.0
    #16)Set all DAT sensors to 53.0
    #17)Set all RAT/DAT sensor points every minute to 68.0/53.0
    apiresources.setTemperatureForAllRacksRATandDATSensorPointsEveryMinute     ${test_input}[rack_temp]    ${test_input}[rat_tempF]    ${test_input}[dat_tempF]
    #18)Go to CX > Tools > Configs
    #19)Set Configs > System::SFCMin = 72% and SFCMax = 88%
    vxOverrideUIvaluesResources.setConfigSFCMinAndSFCMaxValues    ${test_input}[SFCMinValue]    ${test_input}[SFCMaxValue]
    #20)Wait 3 minutes
    common.waitForMinutes    3
    #21)Make sure no AHUs are in Guard or Overridden
    apiresources.releaseOverrideOfAllAHUsAndConfirmAHUsAreGuardCleared
    #22)Go to VX > Equipment tab    [UI part]
    #23)Override AHU CAC_10 ON and 77%
    uiresources.overrideNamedAHUWithSpecifiedBOPAndSFCValuesFromUI  ${test_input}[ahu_1]    ${test_input}[ahu_1_bop_value]    ${test_input}[ahu_1_sfc_value]
    #24)Verify On/Off Override = ON
    apiresources.verifyOverrideValueOfSpecificControlInOverriddenAHU    ${test_input}[ahu_1]    BOP    ${test_input}[on_value]
    #25)Verify On/Off Origin = MANUAL
    apiresources.verifyOriginOfSpecificControlInOverriddenAHU    ${test_input}[ahu_1]    BOP   MANUAL
    #26)Verify Supply Fan Override = 77.0% for AHU CAC_10
    apiresources.verifyOverrideValueOfSpecificControlInOverriddenAHU     ${test_input}[ahu_1]    SFC    ${test_input}[ahu_1_sfc_value]
    #27)Verify Supply Fan Origin = MANUAL
    apiresources.verifyOriginOfSpecificControlInOverriddenAHU    ${test_input}[ahu_1]    SFC    MANUAL
    #28)Wait 4 minutes
    common.waitForMinutes    4
    #29)Verify Supply Fan Value = 77.0% for AHU CAC_10
    apiresources.verifyValueOfSpecificControlofNamedAHU    ${test_input}[ahu_1]    SFC    ${test_input}[ahu_1_sfc_value]
    #30)Verify On/Off Value = ON
    apiresources.verifyValueOfSpecificControlofNamedAHU    ${test_input}[ahu_1]    BOP    ${test_input}[on_value]
    #31)Override AHU CAC_13 AUTO and 79%
    uiresources.overrideNamedAHUWithSpecifiedBOPAndSFCValuesFromUI  ${test_input}[ahu_2]    ${test_input}[ahu_2_bop_value]    ${test_input}[ahu_2_sfc_value]
    #32)Verify Supply Fan Override = 79.0% for AHU CAC_13
    apiresources.verifyOverrideValueOfSpecificControlInOverriddenAHU     ${test_input}[ahu_2]    SFC    ${test_input}[ahu_2_sfc_value]
    #33)Verify Supply Fan Origin = MANUAL
    apiresources.verifyOriginOfSpecificControlInOverriddenAHU    ${test_input}[ahu_2]    SFC    MANUAL
    #34)Verify On/Off Override = blank
    apiresources.verifyOverrideValueOfSpecificControlInOverriddenAHU    ${test_input}[ahu_2]    BOP    blank
    #35)Verify On/Off Origin = CONTROL
    apiresources.verifyOriginOfSpecificControlInOverriddenAHU    ${test_input}[ahu_2]    BOP    CONTROL
    #36)Wait 3 minutes
    common.waitForMinutes    3
    #37)Verify Supply Fan Value = 79.0% for AHU CAC_13
    apiresources.verifyValueOfSpecificControlofNamedAHU    ${test_input}[ahu_2]    SFC    ${test_input}[ahu_2_sfc_value]
    #38)Verify On/Off Value = ON
    apiresources.verifyValueOfSpecificControlofNamedAHU    ${test_input}[ahu_2]    BOP    ${test_input}[on_value]
    #39)Override AHU CAC_15 OFF and 81%
    uiresources.overrideNamedAHUWithSpecifiedBOPAndSFCValuesFromUI  ${test_input}[ahu_3]    ${test_input}[ahu_3_bop_value]    ${test_input}[ahu_3_sfc_value]
    #40)Verify Supply Fan Override = 81.0% for AHU CAC_15
    apiresources.verifyOverrideValueOfSpecificControlInOverriddenAHU     ${test_input}[ahu_3]    SFC    ${test_input}[ahu_3_sfc_value]
    #41)Verify Supply Fan Origin = MANUAL
    apiresources.verifyOriginOfSpecificControlInOverriddenAHU    ${test_input}[ahu_3]    SFC    MANUAL
    #42)Verify On/Off Override = OFF
    apiresources.verifyOverrideValueOfSpecificControlInOverriddenAHU     ${test_input}[ahu_3]    BOP    ${test_input}[off_value]
    #43)Verify On/Off Origin = MANUAL
    apiresources.verifyOriginOfSpecificControlInOverriddenAHU    ${test_input}[ahu_3]    BOP    MANUAL
    #44)Wait 2 minutes
    common.waitForMinutes    2
    #45)Verify Supply Fan Value = 81.0% for AHU CAC_15
    apiresources.verifyValueOfSpecificControlofNamedAHU    ${test_input}[ahu_3]    SFC    ${test_input}[ahu_3_sfc_value]
    #46)Verify On/Off Value = OFF
    apiresources.verifyValueOfSpecificControlofNamedAHU    ${test_input}[ahu_3]    BOP    ${test_input}[off_value]
    #47)Select CAC_10, CAC_13, and CAC_15
    #48)Select Clear Overrides button
    #49)The Clear Overrides popup appears
    #50)Select Yes
    releaseOverrideOfNamedAHUs  ${test_input}[ahu_1]  ${test_input}[ahu_2]  ${test_input}[ahu_3]
    #51)Wait 1 minute
    common.waitForMinutes    1
    #52)Verify Supply Fan Override is blank for AHUs CAC_10, CAC_13, and CAC_15
    apiresources.verifySupplyFanOverrideValueOfListedAHUsAreBlank  ${test_input}[ahu_1]  ${test_input}[ahu_2]  ${test_input}[ahu_3]
    #53)Verify On/Off Override is blank for AHUs CAC_10, CAC_13, and CAC_15
    apiresources.verifyBOPOverrideValueOfListedAHUsAreBlank  ${test_input}[ahu_1]  ${test_input}[ahu_2]  ${test_input}[ahu_3]
    #54)Verify On/Off Origin = CONTROL for AHUs CAC_10, CAC_13, and CAC_15
    apiresources.verifyBOPOriginOfListedAHUsAreControl  ${test_input}[ahu_1]  ${test_input}[ahu_2]  ${test_input}[ahu_3]
    #55)Verify On/Off Value = ON for AHUs CAC_10, CAC_13, and CAC_15
    apiresources.verifyBOPValueOfListedAHUsAreON  ${test_input}[ahu_1]  ${test_input}[ahu_2]  ${test_input}[ahu_3]
    #56)Wait 5 minutes <Post the decision on 9 Nov 2021 meeting the step has been removed from testcases and Strikethrough in Confluence>
    #common.waitForMinutes    5
    #57)Verify Supply Fan Value = 72.0% for AHUs CAC_10, CAC_13, and CAC_15 <Post the decision on 9 Nov 2021 meeting the step has been removed from testcases and Strikethrough in Confluence>
    #override1TestResources.verifySupplyFanValueOfListedAHUsAreSFCMinValue  ${test_input}[ahu_1]  ${test_input}[ahu_2]  ${test_input}[ahu_3]
    #58)(Clean up)
CleanUp
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Finished Test->Override-1 test
    #59)Load default template
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    #60)Clear all RAT & DAT settings (they will go stale)
    [Teardown]   apiresources.setTestExitTemperatureToAllSensorPoints
    #61)Set Group > GuardHotAbsTemp to blank
    uiresources.setListedGroupPropertiesToEmpty    GuardHotAbsTemp