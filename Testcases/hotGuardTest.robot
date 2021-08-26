*** Settings ***
Documentation          This testcase validates the Hot Guard mode feature of AI Engine
...                    Created by Greeshma on 20th August 2021
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/hotGuardTestResources.robot
Variables    ${EXECDIR}/Inputs/hotGuardTestInputs.py


*** Test Cases ***
HotGuardTestSetup
    [Setup]    hotGuardTestResources.hotGuardTestPreconditionSetup
    #1.Start system with the AuQa Db on it (eg 10.252.9.118)
    #2.Use the General-test group.Only vx_server, facs_launcher, facs_trends, facs_dash and facs_sift should be running
    connection.establishConnectionAndStartProcessesVx_serverFacs_launcherFacs_siftFacs_dashAndFacs_trends
    #3.Load the DASHAM_MIX template in the CX configs (with overwrite)
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    #4.Confirm config DASH_M::AllowNumExceedencesGuard=1 and CATGuardBandRange=4
    hotGuardTestResources.setConfigAllowNumExceedencesGuardAndCATGuardBAndRange    ${config_allow_num_exceedences_guard_initial}    ${config_CAT_guard_band_range_initial}
    #5.Confirm group AllowNumExceedencesGuard, GuardHotAbsTemp, AlmHotAbsTemp are null
    #-Abhijit's code here---!
    #6.Test 1 - configs NumGuardUnits and NumMinutesGuardTimer and AllowNumExceedencesGuard
Test1_configsNumGuardUnitsAndNumMinutesGuardTimerAndAllowNumExceedencesGuard
    #7.Set config DASH_M::NumGuardUnits=2 NumMinutesGuardTimer=4 and GuardHysteresisBand=2
    hotGuardTestResources.setconfigNumGuardUnitsNumMinutesGuardTimerAndGuardHysteresisBand    ${config_num_guard_units_value2}    ${config_num_minutes_guard_timer_value4}    ${config_guard_hysteresis_band_value2}
    #8.Set all Setpoint to  80.6/64.4
    apiresources.setAllHighAndLowSetPointLimits    ${high_set_point_limit}    ${low_set_point_limit}
    #9.For one rack, set both CTOP and CBOT temps to 84.6F - Expect no guard or alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.6    ${guard_off}    ${group_hot_alarm_off}
    #10.Set the temps to 84.7->Expect guard and alarm … and 2 Ahus to go into guard
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.7    ${guard_on}    ${group_hot_alarm_on}
    #11.Wait 4 minutes--->expect another 2 Ahus to go into guard
    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilExpectedNoOfAHUsIntoGuard    4    ${config_num_guard_units_value2}    ${config_num_minutes_guard_timer_value4}
    #12.Set config DASH_M::AllowNumExceedencesGuard=2-Expect exit guard and clear alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForConfigAllowNumExceedencesGuardValueChange    ${config_allow_num_exceedences_guard_value2}    ${guard_off}    ${group_hot_alarm_off}
    #13.Set  config DASH_M::NumGuardUnits=1 NumMinutesGuardTimer=2
    apiresources.setConfigNumGuardUnits    ${config_num_guard_units_value1}
    apiresources.setConfigNumMinutesGuardTimer    ${config_num_minutes_guard_timer_value2}
    #14.Set config DASH_M::AllowNumExceedencesGuard=1 -Expect guard and alarm … expect 1 ahu to go into guard
    hotGuardTestResources.checkGuardAndGroupHotAlarmForConfigAllowNumExceedencesGuardValueChange    ${config_allow_num_exceedences_guard_initial}    ${guard_on}    ${group_hot_alarm_on}
    #15.Wait 2 minutes-xpect another 1 Ahu to go into guard
    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilExpectedNoOfAHUsIntoGuard    2    ${config_num_guard_units_value1}    ${config_num_minutes_guard_timer_value2}
    #16.Set config DASH_M::AllowNumExceedencesGuard=2 -Expect exit guard and clear alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForConfigAllowNumExceedencesGuardValueChange    ${config_allow_num_exceedences_guard_value2}    ${guard_off}    ${group_hot_alarm_off}
    #17.Test 2 - group AllowNumExceedencesGuard
Test2_groupAllowNumExceedencesGuard
    #18.Set group AllowNumExceedencesGuard=0 - Expect guard and alarm … 1 ahu after 2 mins
    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${group_allow_num_exceedences_guard_value0}    ${guard_on}    ${group_hot_alarm_on}
    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilExpectedNoOfAHUsIntoGuard    2    ${config_num_guard_units_value1}    ${config_num_minutes_guard_timer_value2}
    #19.Set group AllowNumExceedencesGuard=1 - Expect still guard and alarm
    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${group_allow_num_exceedences_guard_value1}    ${guard_on}    ${group_hot_alarm_on}
    #20.Set group AllowNumExceedencesGuard=2 - Expect exit guard and clear alarm
    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${group_allow_num_exceedences_guard_value2}    ${guard_off}    ${group_hot_alarm_off}
    #21.Test 3 - GuardHysteresisBand
Test3_configGuardHysteresisBand
    #22.Set group AllowNumExceedencesGuard=1 - Expect still guard and alarm
    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${group_allow_num_exceedences_guard_value1}    ${guard_on}    ${group_hot_alarm_on}
    #23.Set temps to 84.6-Expect still guard and alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.6    ${guard_on}    ${group_hot_alarm_on}
    #24.Set temps to 84.5 - Expect still guard and alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.5    ${guard_on}    ${group_hot_alarm_on}
    #25.Set temps to 82.6 -Expect exit guard and clear alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    82.6    ${guard_off}    ${group_hot_alarm_off}
    #26.Set config DASH_M:: GuardHysteresisBand=1 and  CATGuardBandRange=5
    hotGuardTestResources.setConfigGuardHysteresisBandAndCATGuardBandRange    ${config_guard_hysteresis_band_value1}    ${config_CAT_guard_band_range_value5}
    #27.Set temps 84.7- Expect no guard or alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.7    ${guard_off}    ${group_hot_alarm_off}
    #28.Set temps 85.6-Expect no guard or alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    85.6    ${guard_off}    ${group_hot_alarm_off}
    #29.Set temps 85.7 - Expect guard and alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    85.7    ${guard_on}    ${group_hot_alarm_on}
    #30.Set temps 85.6 - Expect still guard and alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    85.6    ${guard_on}    ${group_hot_alarm_on}
    #31.Set temps 84.7- Expect still guard and alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.7    ${guard_on}    ${group_hot_alarm_on}
    #32.Set temps 84.6 - Expect exit guard and clear alarm
    hotGuardTestResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.6    ${guard_off}    ${group_hot_alarm_off}
    #33.End Test
    #34.Clean up
CleanUp
    [Teardown]   apiresources.setTestExitTemperatureToFirstSensorPoint
    #Load default config template
    #group properties to null-allow_num_exceedences of group
    #set point default values.
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    apiresources.setAllHighAndLowSetPointLimits    ${high_set_point_limit_cleanup}    ${low_set_point_limit_cleanup}

