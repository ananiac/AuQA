*** Settings ***
Documentation           To confirm that the AHUS go into guard in the correct order on a DASHAM_MIX site
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/guardOrderMIXResources.robot
#Variables    ${EXECDIR}/Inputs/hotGuardTestInputs.py
Variables    ${EXECDIR}/Inputs/guardOrderMIXInputs.PY


*** Test Cases ***
GuardOrderMIXTestSetup
#    [Setup]    guardOrderMIXResources.guardOrderMIXTestPreconditionSetup
    log to console  GuardOrderMIXTest
#    # 1.Start system with the AuQa Db on it (eg 10.252.9.118)
#    # 2.Use the General-test group
#    # 3.Use the General-test group
#        # 1.facs_dash should NOT be running
#        # 2.Only vx_server, facs_launcher and facs_trends should be running
#    # [Setup]  consists of 1-3 steps
#    # 4.Load the DASHAM_MIX template in the CX configs (with overwrite) … or DASHAM_RSP_RESET template if using RSP-test group
#    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
#    # 5.Confirm group property AllowNumExceedencesGuard, GuardHotAbsTemp are null
#    guardOrderMIXResources.setGuardOrderMIXGroupPropertiesToEmpty
#    # 6.Set group property AllowNumExceedencesControl=10,
#    guardOrderMIXResources.setGroupPropertyAllowNumExceedencesControl  10
#    # 7.Write user event “set config DASHM::NumGuardUnits=1, NumMinutesGuardTimer=2 and SYSTEM::NumMinutesPast=20”
#    # 8.Set config DASHM::NumGuardUnits=1, NumMinutesGuardTimer=2 and SYSTEM::NumMinutesPast=20
#    guardOrderMIXResources.setconfigNumGuardUnitsNumMinutesGuardTimerAndNumMinutesPast    ${guardOrderMIXInputs}[config_num_guard_units_value1]    ${guardOrderMIXInputs}[config_num_minutes_guard_timer_value2]    ${guardOrderMIXInputs}[config_system_num_minutes_past]
#    # 9.Set all rack Setpoints to  80.6/64.4
#    apiresources.setAllHighAndLowSetPointLimits    ${guardOrderMIXInputs}[high_set_point_limit]    ${guardOrderMIXInputs}[low_set_point_limit]
#    # 10.set all rack temperature sensor points every minute at say 66 F
#    apiresources.setCoolingTemperatureForAllSensorPoints    ${guardOrderMIXInputs}[rack_temp]
#    # 11.start facs_dash (Cooling Control) and facs_sift (Application Metrics)
#    connection.establishConnectionAndStartRequiredProcesses    facs_dash    facs_sift
#    # 12.Write User event “Starting Test - Guard AHU turn-On order”
#    apiresources.writeUserEventsEntryToNotificationEventLog    Starting Test - Guard AHU turn-On order
#    # 13.Wait 4 minutes
#    common.waitForMinutes    4
#    # 14.Override the AHUs as follows
#    guardOrderMIXResources.overrideAllAHUInGroup
    guardOrderMIXResources.overrideAllAHUInGroupCHECKORDER
    # 15.Wait 3 minutes
#    common.waitForMinutes    3
#    # 16.Confirm that this gives the CoolEffortEstimates of the AHUs as follows
#    guardOrderMIXResources.getCoolEffortEstimatesValuesListOfAllAHU
#    # 17.Screenshot - no coding is required
#    # 18.Now set the group into guard by setting the group property GuardHotAbsTemp=9
#    guardOrderMIXResources.setGroupPropertyGuardHotAbsTemp  9
#    # 19.immediately release all AHU overrides - this must be done without delay
#    guardOrderMIXResources.releaseAllAHUOverrides
#    # 20..Wait until all AHUs are in guard and confirm the guard order was (this is in reverse)
#    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilAllAHUsIntoGuard    8    ${guardOrderMIXInputs}[config_num_guard_units_value1]    ${guardOrderMIXInputs}[config_num_minutes_guard_timer_value2]
#    apiresources.checkForAHUToBeInGuardAtRegularIntervalUntilExpectedNoOfAHUsIntoGuard    8    ${guardOrderMIXInputs}[config_num_guard_units_value1]    ${guardOrderMIXInputs}[config_num_minutes_guard_timer_value2]
######################################################################################################    # 11.Now set the group into guard by setting the group property GuardHotAbsTemp=9
#    # 20.Screenshot - no coding is required
#    # 21.end test - no coding is required
#   # 22.Stop all processes except vx_server, facs_launcher and facs_trend
#    connection.establishConnectionAndStopAllProcessesExcept
#   #23.cleanup
#    [Teardown]   apiresources.setTestExitTemperatureToAllSensorPoints
#    #group properties to null-allow_num_exceedences of group
#    #set point default values.
#    guardOrderMIXResources.setHotGuardGroupPropertiesToEmpty
#    apiresources.setAllHighAndLowSetPointLimits    ${high_set_point_limit_cleanup}    ${low_set_point_limit_cleanup}


