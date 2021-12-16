*** Settings ***
Documentation          This testcase validates the AHUS turning ON order and Group's MinRequiredAhuOn property
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created by Greeshma on 2nd Dec 2021
Library    Collections
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/common.robot
Resource    ${EXECDIR}/Resources/OverrideTestResources/minOnTestResources.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot


*** Test Cases ***
MinONTestOnNoBindingsGroup
    log to console  MinONTestOnNoBindingsGroup
#    #1.Start system with the AuQa DB on it (e.g., 10.252.9.118)
#    #2.Stop ALL processes including the API Server (vx_server) and Script Launcher (facs_launcher)
#    #3.Wait 2 minutes
#    [Setup]  minOnTestResources.minOnTestOnNoBindingsPrecondition
#    #4.Use the NoBindings group
#    #5.Start the API Server (vx_server) and Script Launcher processes
#    #6.Start the simulator (dcsim) and Trend (facs_trends) processes
#    connection.establishConnectionAndStartRequiredProcesses    vx_server  facs_launcher  facs_trend  dcsim
#    #7.Load the DASHAM_MIX template in the CX configs (with overwrite)
#    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
#    #8.Set all rack setpoints to 55/45
#    apiresources.setAllHighAndLowSetPointLimits    ${test_input}[high_set_point_limit]    ${test_input}[low_set_point_limit]
#    #9.Set group properties
#    #a.AllowNumExceedencesGuard = 9
#    apiresources.changeGroupPropertiesParameterValue    AllowNumExceedencesGuard  int  ${test_input}[config_allow_num_exceedences_guard]
#    #b.GuardHotAbsTemp = NULL
#    #c.AlmHotAbsTemp = NULL
#    minOnTestResources.setNullValueForGuardHotAbsTempAndAlmHotAbsTemp
#    #d.AllowNumExceedencesControl = 0
#    apiresources.changeGroupPropertiesParameterValue    AllowNumExceedencesControl  int  ${test_input}[config_allow_num_exceedences_control]
#    #e.AlgName = DASHM_MIX
#    apiresources.changeGroupPropertiesParameterValue    AlgName  string  "${test_input}[grp_property_alg_name]"
#    #10.Set system config property NumMinutesStartTimer = 1
#    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  NumMinutesStartTimer  ${test_input}[config_num_minutes_start_timer]
#    #11.Set all rack temperature sensor points every minute to 50
#    #12.Set RAT sensor points to 68 F every 60 seconds
#    #13.Set DAT sensor points to 53 F every 60 seconds
#    #14.Set Power point to 0.4 kw every 60 seconds
#    apiresources.setTemperatureForAllRacksRATandDATAndPowerForPWRMonitorPointsEveryMinute  ${test_input}[rack_tempF]  ${test_input}[rat_tempF]  ${test_input}[dat_tempF]  ${test_input}[power_monitor_pwr_kW]
#    #15.Start facs_dash (Cooling Control) and facs_sift (Application Metrics)
#    connection.establishConnectionAndStartRequiredProcesses    facs_dash    facs_sift
#    #16.Wait 3 minutes
#    common.waitForMinutes    3
#    #17.Make sure no AHUs are in Guard or Overridden
#    apiresources.releaseOverrideOfAllAHUsAndConfirmAHUsAreGuardCleared
#    #18.Write User event “Starting Test - Minimum AHU On – Test 1: Cold room AHUs remain off if MinOn = 0”
#    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Starting Test->Minimum AHU On–Test-1->Cold room AHUs remain off if MinOn=0
#    #19.Set Group property MinRequiredAHUOn = 0
#    apiresources.changeGroupPropertiesParameterValue    MinRequiredAhuOn  int  ${test_input}[min_required_ahu_on_0]
#    #20.Override all AHUs OFF
#    apiresources.overrideAllAHUsWithBOPValueOFF
#    #21.Wait 2 minutes
#    common.waitForMinutes    2
#    #22.Release overrides
#    apiresources.releaseOverrideOfAllAHUs
#    #23.Wait 2 minutes
#    common.waitForMinutes    2
#    #24.No AHUs should turn ON (all should remain OFF)
#    apiresources.checkBOPValueOfAllAHUsAreOFF
#    #25.Write User event “Test 2: MinOn AHU turn on order”
#    apiresources.writeUserEventsEntryToNotificationEventLog  AuQA test->${group_name}->Test 2:MinOn AHU turn on order
#    #26.Set Group property MinRequiredAhuOn = 9
#    apiresources.changeGroupPropertiesParameterValue    MinRequiredAhuOn  int  ${test_input}[min_required_ahu_on_9]
#    #27.AHU CAC_14 should turn ON in 60-90 seconds
#    #28.Wait 60 seconds
#    #29.AHU CAC_13 should turn on
#    #30.Wait 60 seconds
#    #31.AHU CAC_15 should turn on
#    #32.The rest of the AHUs should turn on in 1 minutes intervals in the following order: CAC_17, CAC_16, CAC_12, CAC_11, CAC10
#    #['NB-AHU-14', 'NB-AHU-13', 'NB-AHU-15', 'NB-AHU-17', 'NB-AHU-16', 'NB-AHU-12', 'NB-AHU-11', 'NB-AHU-10']
#    minOnTestResources.checkTheOrderOfAHUsTurningON  ${test_input}[expected_ahu_turn_ON_order]
#    #33.Write User event “Test 3: Manual overrides force MinOn violation”
#    apiresources.writeUserEventsEntryToNotificationEventLog  Test 3:Manual overrides force MinOn violation
#    #34.Override CAC_11 and CAC_10 OFF & SFC = NULL
#    apiresources.overrideNamedAHUsWithBOPValueOFF  ${test_input}[ahu_name_0]  ${test_input}[ahu_name_1]
#    common.waitForSeconds  60
#    #35.AHUs CAC_11 and CAC_10 should be OFF
#    apiresources.checkBOPValueOfNamedAHUsAreOFF  ${test_input}[ahu_name_0]  ${test_input}[ahu_name_1]
#    #36.Release overridden AHUs
#    apiresources.releaseOverrideOfNamedAHUs  ${test_input}[ahu_name_0]  ${test_input}[ahu_name_1]
#    #37.Wait 2 minute
#    common.waitForMinutes    3
#    #38.CAC_11 & CAC_10 should turn ON
#    apiresources.checkBOPValueOfNamedAHUsAreON  ${test_input}[ahu_name_0]  ${test_input}[ahu_name_1]
#    #39.Write User event “Test 4: Manual overrides OFF force other AHUs ON”
#    apiresources.writeUserEventsEntryToNotificationEventLog  Test 4:Manual OFF overrides can turn other AHUs ON
#    #40.Set Group property MinRequiredAhuOn = 2
#    apiresources.changeGroupPropertiesParameterValue    MinRequiredAhuOn  int  ${test_input}[min_required_ahu_on_2]
#    #41.Override AHUs CAC_12, CAC_13, CAC_14, CAC_15, CAC_16, & CAC_17 OFF
#    apiresources.overrideNamedAHUsWithBOPValueOFF  ${test_input}[ahu_name_2]  ${test_input}[ahu_name_3]  ${test_input}[ahu_name_4]  ${test_input}[ahu_name_5]  ${test_input}[ahu_name_6]  ${test_input}[ahu_name_7]
#    common.waitForSeconds  60
#    #42.The 6 AHUs should turn OFF
#    apiresources.checkBOPValueOfNamedAHUsAreOFF  ${test_input}[ahu_name_2]  ${test_input}[ahu_name_3]  ${test_input}[ahu_name_4]  ${test_input}[ahu_name_5]  ${test_input}[ahu_name_6]  ${test_input}[ahu_name_7]
#    #43.Release the overrides
#    apiresources.releaseOverrideOfNamedAHUs  ${test_input}[ahu_name_2]  ${test_input}[ahu_name_3]  ${test_input}[ahu_name_4]  ${test_input}[ahu_name_5]  ${test_input}[ahu_name_6]  ${test_input}[ahu_name_7]
#    #44.Wait 2 minute
#    common.waitForMinutes    2
#    #45.The 6 AHUs should stay OFF
#    apiresources.checkBOPValueOfNamedAHUsAreOFF  ${test_input}[ahu_name_2]  ${test_input}[ahu_name_3]  ${test_input}[ahu_name_4]  ${test_input}[ahu_name_5]  ${test_input}[ahu_name_6]  ${test_input}[ahu_name_7]
#    #46.Override CAC_10 & CAC_11 OFF
#    apiresources.overrideNamedAHUsWithBOPValueOFF  ${test_input}[ahu_name_0]  ${test_input}[ahu_name_1]
#    #47.Wait 60-90 seconds
#    common.waitForSeconds  90
#    #48.AHU CAC_14 should turn ON
#    apiresources.checkBOPValueOfNamedAHUsAreON  ${test_input}[ahu_name_4]
#    #49.Wait 60 seconds
#    common.waitForMinutes    1
#    #50.AHU CAC_13 should turn ON
#    apiresources.checkBOPValueOfNamedAHUsAreON  ${test_input}[ahu_name_3]
#    #51.Wait 120 seconds
#    common.waitForMinutes    2
#    #52.All other AHUs remain OFF
#    apiresources.checkBOPValueOfNamedAHUsAreOFF  ${test_input}[ahu_name_0]  ${test_input}[ahu_name_1]  ${test_input}[ahu_name_2]  ${test_input}[ahu_name_5]  ${test_input}[ahu_name_6]  ${test_input}[ahu_name_7]
#CleanUp
#    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Finished Test->MinOn test
#    #53.Reset group configs AllowNumExceedencesGuard=null, AllowNumExceedencesControl=null, GuardHotAbsTemp=90, AlmHotAbsTemp=90
#    uiresources.setListedGroupPropertiesToEmpty  AllowNumExceedencesGuard  AllowNumExceedencesControl  MinRequiredAhuOn
#    apiresources.changeGroupPropertiesParameterValue    GuardHotAbsTemp  float  ${test_input}[guard_hot_abs_temp_default]
#    apiresources.changeGroupPropertiesParameterValue    AlmHotAbsTemp  float  ${test_input}[alm_hot_abs_temp_default]
#    #54.Reset system config NumMinutesStartTimer=15
#    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  NumMinutesStartTimer  ${test_input}[config_num_minutes_start_timer_default]
#    #55.Stop all processes except vx_server and facs_launche
#    connection.establishConnectionAndStopAllProcessesExcept    vx_server    facs_launcher    facs_trend
#    #Release overrides
#    apiresources.releaseOverrideOfAllAHUs
#    [Teardown]   apiresources.setTestExitTemperatureToAllSensorPoints
#
#
