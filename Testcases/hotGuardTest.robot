*** Settings ***
Documentation          This testcase validates the Hot Guard mode feature of AI Engine
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created by Greeshma on 20th August 2021
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/hotGuardTestResources.robot
Variables    ${EXECDIR}/Inputs/hotGuardTestInputs.py


*** Test Cases ***
HotGuardTestSetup
    [Setup]    hotGuardTestResources.hotGuardTestPreconditionSetup
    #1.Start system with the AuQa Db on it (eg 10.252.9.118)
    #2.Use the General-test group.Only vx_server, facs_launcher, facs_trends and facs_sift should be running
    #facs_dash should NOT be running
    connection.establishConnectionAndStartProcessesVx_serverFacs_launcherFacs_siftAndFacs_trends
    #3.Load the DASHAM_MIX template in the CX configs (with overwrite)
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    #4.Confirm config DASH_M::AllowNumExceedencesGuard=1 and CATGuardBandRange=4
    hotGuardTestResources.setConfigAllowNumExceedencesGuardAndCATGuardBAndRange    ${config_allow_num_exceedences_guard_initial}    ${config_CAT_guard_band_range_initial}
    #5.Confirm group AllowNumExceedencesGuard, GuardHotAbsTemp, AlmHotAbsTemp are null
    hotGuardTestResources.setHotGuardGroupPropertiesToEmpty
    #6.Set all Setpoint to  80.6/64.4
    apiresources.setAllHighAndLowSetPointLimits    ${high_set_point_limit}    ${low_set_point_limit}
    #7.set all rack temperature sensor points every minute at say 66 F
    apiresources.setCoolingTemperatureForAllSensorPoints    ${hot_guard_intial_temp_all_racks}
    #8.start facs_dash (Cooling Control)
    connection.establishConnectionAndStartCoolingControlProcess
    #9.Wait 4 minutes
    common.waitForMinutes   4
    #10.Write User event “Starting Test 1 - testing NumGuardUnits, NumMinutesGuardTimer and AllowNumExceedencesGuard”
    apiresources.writeUserEventsEntryToNotificationEventLog    ${group_name}->Hot Guard test->Starting Test 1 - testing NumGuardUnits,NumMinutesGuardTimer and AllowNumExceedencesGuard
    #11.Test 1 - configs NumGuardUnits and NumMinutesGuardTimer and AllowNumExceedencesGuard
Test1_configsNumGuardUnitsAndNumMinutesGuardTimerAndAllowNumExceedencesGuard
    #12.Set config DASH_M::NumGuardUnits=2 NumMinutesGuardTimer=4 and GuardHysteresisBand=2
    hotGuardTestResources.setconfigNumGuardUnitsNumMinutesGuardTimerAndGuardHysteresisBand    ${config_num_guard_units_value2}    ${config_num_minutes_guard_timer_value4}    ${config_guard_hysteresis_band_value2}
    #13.Confirm that the group is not in guard
    apiresources.checkingGuardModeOfGroup    ${guard_off}
    #14.For one rack, set both CTOP and CBOT temps to 84.6F - Expect no guard or alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.6    ${guard_off}    ${group_hot_alarm_off}
    #15.Set the temps to 84.7->Expect guard and alarm … and 2 Ahus to go into guard
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.7    ${guard_on}    ${group_hot_alarm_on}
    #16.Wait 4 minutes--->expect another 2 Ahus to go into guard
    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilExpectedNoOfAHUsIntoGuard    4    ${config_num_guard_units_value2}    ${config_num_minutes_guard_timer_value4}
    #17.Set config DASH_M::AllowNumExceedencesGuard=2-Expect exit guard and clear alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForConfigAllowNumExceedencesGuardValueChange    ${config_allow_num_exceedences_guard_value2}    ${guard_off}    ${group_hot_alarm_off}
    #18.Set  config DASH_M::NumGuardUnits=1 NumMinutesGuardTimer=2
    apiresources.setConfigNumGuardUnits    ${config_num_guard_units_value1}
    apiresources.setConfigNumMinutesGuardTimer    ${config_num_minutes_guard_timer_value2}
    #19.Set config DASH_M::AllowNumExceedencesGuard=1 -Expect guard and alarm … expect 1 ahu to go into guard
    hotGuardTestResources.checkGuardAndGroupHotAlarmForConfigAllowNumExceedencesGuardValueChange    ${config_allow_num_exceedences_guard_initial}    ${guard_on}    ${group_hot_alarm_on}
    #20.Wait 2 minutes-xpect another 1 Ahu to go into guard
    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilExpectedNoOfAHUsIntoGuard    2    ${config_num_guard_units_value1}    ${config_num_minutes_guard_timer_value2}
    #21.Set config DASH_M::AllowNumExceedencesGuard=2 -Expect exit guard and clear alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForConfigAllowNumExceedencesGuardValueChange    ${config_allow_num_exceedences_guard_value2}    ${guard_off}    ${group_hot_alarm_off}
Test2_groupAllowNumExceedencesGuard
    #22.Write User event “Starting Test 2- testing group AllowNumExceedencesGuard”
    apiresources.writeUserEventsEntryToNotificationEventLog    Starting Test 2- testing group AllowNumExceedencesGuard
    #23.Test 2 - group AllowNumExceedencesGuard
    #24.Set group AllowNumExceedencesGuard=0 - Expect guard and alarm … 1 ahu after 2 mins
    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${group_allow_num_exceedences_guard_value0}    ${guard_on}    ${group_hot_alarm_on}
    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilExpectedNoOfAHUsIntoGuard    2    ${config_num_guard_units_value1}    ${config_num_minutes_guard_timer_value2}
    #25.Set group AllowNumExceedencesGuard=1 - Expect still guard and alarm
    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${group_allow_num_exceedences_guard_value1}    ${guard_on}    ${group_hot_alarm_on}
    #26.Set group AllowNumExceedencesGuard=2 - Expect exit guard and clear alarm
    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${group_allow_num_exceedences_guard_value2}    ${guard_off}    ${group_hot_alarm_off}
Test3_configGuardHysteresisBand
    #27.Write User event “Starting Test 2- testing GuardHysteresisBand ”
    apiresources.writeUserEventsEntryToNotificationEventLog    Starting Test 3- testing GuardHysteresisBand
    #28.Test 3 - GuardHysteresisBand
    #29.Set group AllowNumExceedencesGuard=1 - Expect still guard and alarm
    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${group_allow_num_exceedences_guard_value1}    ${guard_on}    ${group_hot_alarm_on}
    #30.Set temps to 84.6-Expect still guard and alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.6    ${guard_on}    ${group_hot_alarm_on}
    #31.Set temps to 84.5 - Expect still guard and alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.5    ${guard_on}    ${group_hot_alarm_on}
    #32.Set temps to 82.6 -Expect exit guard and clear alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    82.6    ${guard_off}    ${group_hot_alarm_off}
    #33.Set config DASH_M:: GuardHysteresisBand=1 and  CATGuardBandRange=5
    hotGuardTestResources.setConfigGuardHysteresisBandAndCATGuardBandRange    ${config_guard_hysteresis_band_value1}    ${config_CAT_guard_band_range_value5}
    #34.Set temps 84.7- Expect no guard or alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.7    ${guard_off}    ${group_hot_alarm_off}
    #35.Set temps 85.6-Expect no guard or alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    85.6    ${guard_off}    ${group_hot_alarm_off}
    #36.Set temps 85.7 - Expect guard and alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    85.7    ${guard_on}    ${group_hot_alarm_on}
    #37.Set temps 85.6 - Expect still guard and alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    85.6    ${guard_on}    ${group_hot_alarm_on}
    #38.Set temps 84.7- Expect still guard and alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.7    ${guard_on}    ${group_hot_alarm_on}
    #39.Set temps 84.6 - Expect exit guard and clear alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.6    ${guard_off}    ${group_hot_alarm_off}
CleanUp
    #40.Write User event “Ending Hot Guard test”
    apiresources.writeUserEventsEntryToNotificationEventLog    ${group_name}->Ending Hot Guard test
    #41.End Test
    #42.Clean up
    #group properties to null-allow_num_exceedences of group
    #Load default config template
    #set point default values.
    hotGuardTestResources.setHotGuardGroupPropertiesToEmpty
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    apiresources.setAllHighAndLowSetPointLimits    ${high_set_point_limit_cleanup}    ${low_set_point_limit_cleanup}
    [Teardown]   apiresources.setTestExitTemperatureToAllSensorPoints


