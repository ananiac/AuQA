*** Settings ***
Documentation          This testcase validates the Hot Guard mode feature of AI Engine
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created by Greeshma on 20th August 2021.Modified on 5th Oct 2021 as per changes in Wiki page.
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/GuardTestResources/hotGuardTestResources.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot


*** Test Cases ***
HotGuardTestSetup
    log to console  test3
#    [Setup]    hotGuardTestResources.hotGuardTestPreconditionSetup
#    #1.Start system with the AuQa Db on it (eg 10.252.9.118)
#    #2.Use the General-test group.Only vx_server, facs_launcher and facs_trends should be running
#    #facs_dash should NOT be running
#    connection.establishConnectionAndStartRequiredProcesses    vx_server  facs_launcher  facs_trend
#    #3.Load the DASHAM_MIX template in the CX configs (with overwrite),DASHAM_RSP_RESET template if using RSP-test group
#    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
#    #4.Confirm config DASH_M::AllowNumExceedencesGuard=1 and CATGuardBandRange=4
#    hotGuardTestResources.setConfigAllowNumExceedencesGuardAndCATGuardBAndRange    ${test_input}[config_allow_num_exceedences_guard_initial]    ${test_input}[config_CAT_guard_band_range_initial]
#    #5.Write User event - “confirmed config DASHM::AllowNumExceedencesGuard=1 and CATGuardBandRange=4”
#    #User event log entry is added from apiresources.changeCxConfigsTabModuleFieldValues, which is part of the keyword definition in step 4
#    #6.Confirm group AllowNumExceedencesGuard, GuardHotAbsTemp, AlmHotAbsTemp are null
#    hotGuardTestResources.setHotGuardGroupPropertiesToEmpty
#    #7.Set all Setpoint to  80.6/64.4
#    apiresources.setAllHighAndLowSetPointLimits    ${test_input}[high_set_point_limit]    ${test_input}[low_set_point_limit]
#    #8.set all rack temperature sensor points every minute at say 66 F
#    apiresources.setCoolingTemperatureForAllSensorPoints    ${test_input}[hot_guard_intial_temp_all_racks]
#    #9.start facs_dash (Cooling Control) and facs_sift (Application Metrics)
#    connection.establishConnectionAndStartRequiredProcesses    facs_dash    facs_sift
#    #10.Wait 4 minutes
#    common.waitForMinutes   4
#    #11.Make sure no AHUs are in Guard or Overridden
#    apiresources.releaseOverrideOfAllAHUsAndConfirmAHUsAreGuardCleared
#    #12.Write User event “Starting Test 1 - testing NumGuardUnits, NumMinutesGuardTimer and AllowNumExceedencesGuard”
#    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Hot Guard test->Starting Test 1 - testing NumGuardUnits,NumMinutesGuardTimer and AllowNumExceedencesGuard
#    #13.Test 1 - configs NumGuardUnits and NumMinutesGuardTimer and AllowNumExceedencesGuard
#Test1_configsNumGuardUnitsAndNumMinutesGuardTimerAndAllowNumExceedencesGuard
#    #14.Write User event - “Set config DASHM::NumGuardUnits=2 NumMinutesGuardTimer=4 and GuardHysteresisBand=2”
#    #User event log entry is added from apiresources.changeCxConfigsTabModuleFieldValues, which is part of the keyword definition in step 14
#    #15.Set config DASH_M::NumGuardUnits=2 NumMinutesGuardTimer=4 and GuardHysteresisBand=2
#    hotGuardTestResources.setconfigNumGuardUnitsNumMinutesGuardTimerAndGuardHysteresisBand    ${test_input}[config_num_guard_units_value2]    ${test_input}[config_num_minutes_guard_timer_value4]    ${test_input}[config_guard_hysteresis_band_value2]
#    #16.Confirm that the group is not in guard
#    apiresources.checkingGuardModeOfGroup    ${guard_switch}[guard_off]
#    #17.For one rack, set both CTOP and CBOT temps to 84.6F - Expect no guard or alarm
#    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.6    ${guard_switch}[guard_off]    ${test_input}[group_hot_alarm_off]
#    #18.Set the temps to 84.7->Expect guard and alarm … and 2 Ahus to go into guard
#    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.7    ${guard_switch}[guard_on]    ${test_input}[group_hot_alarm_on]
#    #19.Wait 4 minutes--->expect another 2 Ahus to go into guard
#    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilExpectedNoOfAHUsIntoGuard    4    ${test_input}[config_num_guard_units_value2]    ${test_input}[config_num_minutes_guard_timer_value4]
#    #20.Write User event - “Set config DASHM::AllowNumExceedencesGuard=2”
#    #User event log entry is added from apiresources.changeCxConfigsTabModuleFieldValues, which is part of the keyword definition in step 20
#    #21.Set config DASH_M::AllowNumExceedencesGuard=2-Expect exit guard and clear alarm
#    hotGuardTestResources.checkGuardAndGroupHotAlarmForConfigAllowNumExceedencesGuardValueChange    ${test_input}[config_allow_num_exceedences_guard_value2]    ${guard_switch}[guard_off]    ${test_input}[group_hot_alarm_off]
#    #22.Write User event - “Set config DASHM::NumGuardUnits=1 NumMinutesGuardTimer=2”
#    #User event log entry is added from apiresources.changeCxConfigsTabModuleFieldValues, which is part of the keyword definition in step 22
#    #23.Set  config DASH_M::NumGuardUnits=1 NumMinutesGuardTimer=2
#    apiresources.setConfigNumGuardUnits    ${test_input}[config_num_guard_units_value1]
#    apiresources.setConfigNumMinutesGuardTimer    ${test_input}[config_num_minutes_guard_timer_value2]
#    #24.Write User event - “Set config DASHM::AllowNumExceedencesGuard=1”
#    #User event log entry is added from apiresources.changeCxConfigsTabModuleFieldValues, which is part of the keyword definition in step 24
#    #25.Set config DASH_M::AllowNumExceedencesGuard=1 -Expect guard and alarm … expect 1 ahu to go into guard
#    hotGuardTestResources.checkGuardAndGroupHotAlarmForConfigAllowNumExceedencesGuardValueChange    ${test_input}[config_allow_num_exceedences_guard_initial]    ${guard_switch}[guard_on]    ${test_input}[group_hot_alarm_on]
#    #26.Wait 2 minutes-xpect another 1 Ahu to go into guard
#    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilExpectedNoOfAHUsIntoGuard    2    ${test_input}[config_num_guard_units_value1]    ${test_input}[config_num_minutes_guard_timer_value2]
#    #27.Write User event - “Set config DASHM::AllowNumExceedencesGuard=2”
#    #User event log entry is added from apiresources.changeCxConfigsTabModuleFieldValues, which is part of the keyword definition in step 27
#    #28.Set config DASH_M::AllowNumExceedencesGuard=2 -Expect exit guard and clear alarm
#    hotGuardTestResources.checkGuardAndGroupHotAlarmForConfigAllowNumExceedencesGuardValueChange    ${test_input}[config_allow_num_exceedences_guard_value2]    ${guard_switch}[guard_off]    ${test_input}[group_hot_alarm_off]
#Test2_groupAllowNumExceedencesGuard
#    #29.Write User event “Starting Test 2- testing group AllowNumExceedencesGuard”
#    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Starting Test 2->testing group AllowNumExceedencesGuard
#    #30.Test 2 - group AllowNumExceedencesGuard
#    #31.Set group AllowNumExceedencesGuard=0 - Expect guard and alarm … 1 ahu after 2 mins
#    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${test_input}[group_allow_num_exceedences_guard_value0]    ${guard_switch}[guard_on]    ${test_input}[group_hot_alarm_on]
#    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilExpectedNoOfAHUsIntoGuard    2    ${test_input}[config_num_guard_units_value1]    ${test_input}[config_num_minutes_guard_timer_value2]
#    #32.Set group AllowNumExceedencesGuard=1 - Expect still guard and alarm
#    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${test_input}[group_allow_num_exceedences_guard_value1]    ${guard_switch}[guard_on]    ${test_input}[group_hot_alarm_on]
#    #33.Set group AllowNumExceedencesGuard=2 - Expect exit guard and clear alarm
#    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${test_input}[group_allow_num_exceedences_guard_value2]    ${guard_switch}[guard_off]    ${test_input}[group_hot_alarm_off]
#Test3_configGuardHysteresisBand
#    #34.Write User event “Starting Test 2- testing GuardHysteresisBand ”
#    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Starting Test 3->testing GuardHysteresisBand
#    #35.Test 3 - GuardHysteresisBand
#    #36.Set group AllowNumExceedencesGuard=1 - Expect still guard and alarm
#    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${test_input}[group_allow_num_exceedences_guard_value1]    ${guard_switch}[guard_on]    ${test_input}[group_hot_alarm_on]
#    #37.Set temps to 84.6-Expect still guard and alarm
#    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.6    ${guard_switch}[guard_on]    ${test_input}[group_hot_alarm_on]
#    #38.Set temps to 84.5 - Expect still guard and alarm
#    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.5    ${guard_switch}[guard_on]    ${test_input}[group_hot_alarm_on]
#    #39.Set temps to 82.6 -Expect exit guard and clear alarm
#    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    82.6    ${guard_switch}[guard_off]   ${test_input}[group_hot_alarm_off]
#    #40.Write User event - “Set config DASHM:: GuardHysteresisBand=1 and  CATGuardBandRange=5”
#    #User event log entry is added from apiresources.changeCxConfigsTabModuleFieldValues, which is part of the keyword definition in step 40
#    #41.Set config DASH_M:: GuardHysteresisBand=1 and  CATGuardBandRange=5
#    hotGuardTestResources.setConfigGuardHysteresisBandAndCATGuardBandRange    ${test_input}[config_guard_hysteresis_band_value1]    ${test_input}[config_CAT_guard_band_range_value5]
#    #42.Set temps 84.7- Expect no guard or alarm
#    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.7    ${guard_switch}[guard_off]    ${test_input}[group_hot_alarm_off]
#    #43.Set temps 85.6-Expect no guard or alarm
#    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    85.6    ${guard_switch}[guard_off]    ${test_input}[group_hot_alarm_off]
#    #44.Set temps 85.7 - Expect guard and alarm
#    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    85.7    ${guard_switch}[guard_on]    ${test_input}[group_hot_alarm_on]
#    #45.Set temps 85.6 - Expect still guard and alarm
#    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    85.6    ${guard_switch}[guard_on]    ${test_input}[group_hot_alarm_on]
#    #46.Set temps 84.7- Expect still guard and alarm
#    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.7    ${guard_switch}[guard_on]    ${test_input}[group_hot_alarm_on]
#    #47.Set temps 84.6 - Expect exit guard and clear alarm
#    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.6    ${guard_switch}[guard_off]    ${test_input}[group_hot_alarm_off]
#CleanUp
#    #48.Write User event “Ending Hot Guard test”
#    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Ending Hot Guard test<<<<
#    #49.End Test
#    #50.Stop all processes except vx_server, facs_launcher and facs_trend
#    connection.establishConnectionAndStopAllProcessesExcept    vx_server    facs_launcher    facs_trend
#    #51.Clean up
#    #group properties to null-allow_num_exceedences of group
#    #Load default config template
#    #set point default values.
#    hotGuardTestResources.setHotGuardGroupPropertiesToEmpty
#    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
#    apiresources.setAllHighAndLowSetPointLimits    ${test_input}[high_set_point_limit_cleanup]    ${test_input}[low_set_point_limit_cleanup]
#    [Teardown]   apiresources.setTestExitTemperatureToAllSensorPoints
