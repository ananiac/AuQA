*** Settings ***
Documentation           To confirm that the AHUS go into guard in the correct order on a DASHAM_MIX site
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/guardOrderMIXResources.robot
Variables    ${EXECDIR}/Inputs/hotGuardTestInputs.py


*** Test Cases ***
GuardOrderMIXTestSetup
#    [Setup]    guardOrderMIXResources.guardOrderMIXTestPreconditionSetup
#    # 1.Start system with the AuQa Db on it (eg 10.252.9.118)
#    # 2.Use the General-test group
#    # 3.Only vx_server, facs_launcher, facs_trend, facs_dash and facs_sift should be running
#    connection.establishConnectionAndStartProcessesVx_serverFacs_launcherFacs_siftFacs_dashAndFacs_trends
#    # 4.Load the DASHAM_MIX template in the CX configs (with overwrite)
#    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
#    # 5.Confirm group property AllowNumExceedencesGuard, GuardHotAbsTemp are null
#    guardOrderMIXResources.setGuardOrderMIXGroupPropertiesToEmpty
######################################################################################################

#    # 6.Set group property AllowNumExceedencesControl=10
#    guardOrderMIXResources.setGroupPropertyAllowNumExceedencesControl  10
#
#    # 7.Set  config DASH_AM::NumGuardUnits=1, NumMinutesGuardTimer=2
#    guardOrderMIXResources.setconfigNumGuardUnitsNumMinutesGuardTimerAndGuardHysteresisBand    ${config_num_guard_units_value2}    ${config_num_minutes_guard_timer_value4}

    # 8.Override the AHUs as follows
    guardOrderMIXResources.overrideAHUs
    # 9.this should give the CoolEffortEstimates of the AHUs as follows

    # 10.wait 2 minutes
#    common.waitForMinutes   2
    # 11.Now set the group into guard by setting the group property GuardHotAbsTemp=9
    # 12.immediately release all AHU overrides - this must be done without delay
    # 13.Wait until all AHUs are in guard and confirm the guard order was (this is in reverse)

   #4.Confirm config DASH_M::AllowNumExceedencesGuard=1 and CATGuardBandRange=4
#    hotGuardTestResources.setConfigAllowNumExceedencesGuardAndCATGuardBAndRange    ${config_allow_num_exceedences_guard_initial}    ${config_CAT_guard_band_range_initial}
    #6.Test 1 - configs NumGuardUnits and NumMinutesGuardTimer and AllowNumExceedencesGuard
#Test1_configsNumGuardUnitsAndNumMinutesGuardTimerAndAllowNumExceedencesGuard
#    #7.Set config DASH_M::NumGuardUnits=2 NumMinutesGuardTimer=4 and GuardHysteresisBand=2
#    guardOrderMIXResources.setconfigNumGuardUnitsNumMinutesGuardTimerAndGuardHysteresisBand    ${config_num_guard_units_value2}    ${config_num_minutes_guard_timer_value4}    ${config_guard_hysteresis_band_value2}
#    #8.Set all Setpoint to  80.6/64.4
#    apiresources.setAllHighAndLowSetPointLimits    ${high_set_point_limit}    ${low_set_point_limit}
#    #9.For one rack, set both CTOP and CBOT temps to 84.6F - Expect no guard or alarm
#    guardOrderMIXResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.6    ${guard_off}    ${group_hot_alarm_off}
#    #10.Set the temps to 84.7->Expect guard and alarm … and 2 Ahus to go into guard
#    guardOrderMIXResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.7    ${guard_on}    ${group_hot_alarm_on}
#    #11.Wait 4 minutes--->expect another 2 Ahus to go into guard
#    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilExpectedNoOfAHUsIntoGuard    4    ${config_num_guard_units_value2}    ${config_num_minutes_guard_timer_value4}
#    #12.Set config DASH_M::AllowNumExceedencesGuard=2-Expect exit guard and clear alarm
#    guardOrderMIXResources.checkGuardAndGroupHotAlarmForConfigAllowNumExceedencesGuardValueChange    ${config_allow_num_exceedences_guard_value2}    ${guard_off}    ${group_hot_alarm_off}
#    #13.Set  config DASH_M::NumGuardUnits=1 NumMinutesGuardTimer=2
#    apiresources.setConfigNumGuardUnits    ${config_num_guard_units_value1}
#    apiresources.setConfigNumMinutesGuardTimer    ${config_num_minutes_guard_timer_value2}
#    #14.Set config DASH_M::AllowNumExceedencesGuard=1 -Expect guard and alarm … expect 1 ahu to go into guard
#    guardOrderMIXResources.checkGuardAndGroupHotAlarmForConfigAllowNumExceedencesGuardValueChange    ${config_allow_num_exceedences_guard_initial}    ${guard_on}    ${group_hot_alarm_on}
#    #15.Wait 2 minutes-xpect another 1 Ahu to go into guard
#    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilExpectedNoOfAHUsIntoGuard    2    ${config_num_guard_units_value1}    ${config_num_minutes_guard_timer_value2}
#    #16.Set config DASH_M::AllowNumExceedencesGuard=2 -Expect exit guard and clear alarm
#    guardOrderMIXResources.checkGuardAndGroupHotAlarmForConfigAllowNumExceedencesGuardValueChange    ${config_allow_num_exceedences_guard_value2}    ${guard_off}    ${group_hot_alarm_off}
#    #17.Test 2 - group AllowNumExceedencesGuard
#Test2_groupAllowNumExceedencesGuard
#    #18.Set group AllowNumExceedencesGuard=0 - Expect guard and alarm … 1 ahu after 2 mins
#    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${group_allow_num_exceedences_guard_value0}    ${guard_on}    ${group_hot_alarm_on}
#    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilExpectedNoOfAHUsIntoGuard    2    ${config_num_guard_units_value1}    ${config_num_minutes_guard_timer_value2}
#    #19.Set group AllowNumExceedencesGuard=1 - Expect still guard and alarm
#    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${group_allow_num_exceedences_guard_value1}    ${guard_on}    ${group_hot_alarm_on}
#    #20.Set group AllowNumExceedencesGuard=2 - Expect exit guard and clear alarm
#    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${group_allow_num_exceedences_guard_value2}    ${guard_off}    ${group_hot_alarm_off}
#    #21.Test 3 - GuardHysteresisBand
#Test3_configGuardHysteresisBand
#    #22.Set group AllowNumExceedencesGuard=1 - Expect still guard and alarm
#    checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange    ${group_allow_num_exceedences_guard_value1}    ${guard_on}    ${group_hot_alarm_on}
#    #23.Set temps to 84.6-Expect still guard and alarm
#    guardOrderMIXResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.6    ${guard_on}    ${group_hot_alarm_on}
#    #24.Set temps to 84.5 - Expect still guard and alarm
#    guardOrderMIXResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.5    ${guard_on}    ${group_hot_alarm_on}
#    #25.Set temps to 82.6 -Expect exit guard and clear alarm
#    guardOrderMIXResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    82.6    ${guard_off}    ${group_hot_alarm_off}
#    #26.Set config DASH_M:: GuardHysteresisBand=1 and  CATGuardBandRange=5
#    guardOrderMIXResources.setConfigGuardHysteresisBandAndCATGuardBandRange    ${config_guard_hysteresis_band_value1}    ${config_CAT_guard_band_range_value5}
#    #27.Set temps 84.7- Expect no guard or alarm
#    guardOrderMIXResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.7    ${guard_off}    ${group_hot_alarm_off}
#    #28.Set temps 85.6-Expect no guard or alarm
#    guardOrderMIXResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    85.6    ${guard_off}    ${group_hot_alarm_off}
#    #29.Set temps 85.7 - Expect guard and alarm
#    guardOrderMIXResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    85.7    ${guard_on}    ${group_hot_alarm_on}
#    #30.Set temps 85.6 - Expect still guard and alarm
#    guardOrderMIXResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    85.6    ${guard_on}    ${group_hot_alarm_on}
#    #31.Set temps 84.7- Expect still guard and alarm
#    guardOrderMIXResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.7    ${guard_on}    ${group_hot_alarm_on}
#    #32.Set temps 84.6 - Expect exit guard and clear alarm
#    guardOrderMIXResources.checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack    84.6    ${guard_off}    ${group_hot_alarm_off}
#    #33.End Test
#    #34.Clean up
#CleanUp
#    [Teardown]   apiresources.setTestExitTemperatureToAllSensorPoints
#    #group properties to null-allow_num_exceedences of group
#    #Load default config template
#    #set point default values.
#    guardOrderMIXResources.setHotGuardGroupPropertiesToEmpty
#    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
#    apiresources.setAllHighAndLowSetPointLimits    ${high_set_point_limit_cleanup}    ${low_set_point_limit_cleanup}


