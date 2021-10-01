*** Settings ***
Documentation          This testcase validates the AHUS go into guard in the correct order on a DASHAM_MIX site
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created by Greeshma on 24th Sep 2021
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/guardOrderMIXResource.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot

*** Test Cases ***
GuardOrderMixTest
    #1.Start system with the AuQa Db on it (eg 10.252.9.118
    #2.Stop ALL processes including the API Server (vx_server) and Script Launcher
    [Setup]    guardOrderMIXResource.guardOrderMIXTestPreconditionSetup
    #3.Use the General-test group->
    #4.Start the API Server (vx_server) and Script Launcher processes
    connection.establishConnectionAndStartRequiredProcesses    vx_server  facs_launcher
    #5.Load the DASHAM_MIX template in the CX configs (with overwrite) … or DASHAM_RSP_RESET template if using RSP-test group
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    #6.Set group property GuardHotAbsTemp=99         #AllowNumExceedencesControl removed on 1st oct
    guardOrderMIXResource.setGroupPropertyGuardHotAbsTemp     ${test_input}[guard_hot_abs_temp_intial]
    #7.Write user event “set config DASHM::NumGuardUnits=1, NumMinutesGuardTimer=1 and SYSTEM::NumMinutesPast=20”
    #8.Set config DASHM::NumGuardUnits=1, NumMinutesGuardTimer=1 and SYSTEM::NumMinutesPast=20
    guardOrderMIXResource.setconfigNumGuardUnitsNumMinutesGuardTimerAndNumMinutesPast    ${test_input}[config_num_guard_units_value]    ${test_input}[config_num_minutes_guard_timer_value]  ${test_input}[config_system_num_minutes_past]
    #9.Set all rack Setpoints to  80.6/64.4
    apiresources.setAllHighAndLowSetPointLimits    ${test_input}[high_set_point_limit]    ${test_input}[low_set_point_limit]
    #10.set all rack temperature sensor points every minute at say 66 F
    apiresources.setCoolingTemperatureForAllSensorPoints    ${test_input}[rack_temp]
    #11.start facs_dash (Cooling Control) and facs_sift (Application Metrics)
    connection.establishConnectionAndStartRequiredProcesses    facs_dash    facs_sift
    #12.Wait 3 minutes
    common.waitForMinutes    3
    #13.make sure no AHUs are in Guard or Overridden
    apiresources.releaseOverrideOfAllAHUsAndConfirmAHUsAreGuardCleared
    #14.Write User event “Starting Test - Guard AHU turn-On order”
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Starting Test->Guard AHU turn-On order.
    #15.Override the AHUs as follows->
    #CAC_16=50%,CAC_15=60%,CAC_14=66%,CAC_10=70%,CAC_17=75%,CAC_13=80%,CAC_12=90%,CAC_11=100%
    apiresources.overrideAllAHUsWithSFCValuesAsPerList   ${test_input}
    #16.Wait 4 minutes
    common.waitForMinutes    4
    #17.Confirm that this gives the CoolEffortEstimates of the AHUs as follows
    #18.Picture->vx->Live tabe->CAC_16=50%,CAC_15=60%,CAC_14=66%,CAC_10=70%,CAC_17=75%,CAC_13=80%,CAC_12=90%,CAC_11=100%
    apiresources.confirmTheCoolEffortEstimateValueIsAsPerSFCValuesSet    ${test_input}
    #19.Release all AHU overrides(immediately release all AHU overrides - this must be done without delay)
    apiresources.releaseOverrideOfAllAHUs
    #20.Wait 30 seconds
    common.waitForSeconds    30
    #21.Now set the group into guard by setting the group property GuardHotAbsTemp=9
    guardOrderMIXResource.setGroupPropertyGuardHotAbsTemp    9
    #22.We expect the first AHU that goes into guard should be CAC_16, but it may be CAC_13- this is ok
    #23.Wait until all AHUs have gone onto guard
    #24.The remaining AHUs should enter guard in order of increasing CoolEffortEstimate ie in this order
    #CAC_16,13, 15, 14, 10, 17, 13, 12, 11
    #CAC_13, 16, 15, 14, 10, 17, 13, 12, 11 is also OK
    #25.Confirm the turn on order is correct
    confirmTheOrderOfAHUsGoingIntoGuardIsIncrementalCoolEffortEstimateExceptFirstAHU    ${test_input}
    #26.Stop all processes except vx_server, facs_launcher and facs_trend
    connection.establishConnectionAndStopAllProcessesExcept    vx_server    facs_launcher    facs_trend
    #27.cleanup
CleanUp
    guardOrderMIXResource.setGuardOrderMixPropertiesToEmpty
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Finished Test->Guard AHU turn-On order
    [Teardown]   apiresources.setTestExitTemperatureToAllSensorPoints



