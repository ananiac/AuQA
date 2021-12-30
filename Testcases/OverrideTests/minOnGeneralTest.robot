*** Settings ***
Documentation          This testcase validates the AHU's going into BOP-ON and OFF with respect to MinRequiredAhuOn property
...                    of the group with bindings.The StaleStatePrevention is not required as simulator is ON and the Group has bindings.
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created by Greeshma on 9th Dec 2021
Library    Collections
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/common.robot
Resource    ${EXECDIR}/Resources/OverrideTestResources/minOnTestResources.robot


*** Test Cases ***
MinONGeneralTest
    #1. Use the General-test group with the modified AHU specifications given above
    #2. Stop all processes
    #3. Wait 2 minutes
    #The AHU properties->CoolSource,DesignCapacity and DesignCop of General Test group are checked
    [Setup]      minOnTestResources.minOnTestOnGeneralTestPrecondition
    #4. Start all processes
    connection.establishConnectionAndStartRequiredProcesses    vx_server  facs_trend  dcsim  facs_cleanup  vems-snmp  facs_cp  facs_dash  facs_sift  vems-plugin-smart-mesh-ip  facs_launcher  vx_report  vems-plugin-dust  vems-plugin-modbus  vems-plugin-bacnet
    #5. Wait 2 minutes
    common.waitForMinutes    2
    #6. Set group configs
    #AllowNumExceedencesGuard=9,
    apiresources.changeGroupPropertiesParameterValue    AllowNumExceedencesGuard  int  ${test_input}[config_allow_num_exceedences_guard]
    #GuardHotAbsTemp=null. …. ie disable guard
    #AlmHotAbsTemp=null
    minOnTestResources.setNullValueForGuardHotAbsTempAndAlmHotAbsTemp
    #AllowNumExceedencesControl=0
    apiresources.changeGroupPropertiesParameterValue    AllowNumExceedencesControl  int  ${test_input}[config_allow_num_exceedences_control]
    #AlgName=DASHM_MIX
    apiresources.changeGroupPropertiesParameterValue    AlgName  string  "${test_input}[grp_property_alg_name]"
    #7. Load default DASHM_MIX template under Site config
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    #8. Set system config NumMinutesStartTimer=1 so we don’t have to wait long for AHUs to turn ON
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  NumMinutesStartTimer  ${test_input}[config_num_minutes_start_timer]
    #9. Set system config MinRequiredAhuOn = 0 so all the AHUs can turn OFF as the initial conditions
    apiresources.changeGroupPropertiesParameterValue    MinRequiredAhuOn  int  ${test_input}[min_required_ahu_on_0]
    #Make sure no AHUs are in Guard or Overridden
    apiresources.releaseOverrideOfAllAHUsAndConfirmAHUsAreGuardCleared
    #10. Test 1 - Cold room AHUs remain OFF if MinOn=0
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Start Test->Minimum AHU On–Test-1->Cold room AHUs remain off if MinOn=0
    #11. Make the room “cold”
    #Make all High SetPoints = 120 F and all Low SetPoints = 110 F
    apiresources.setAllHighAndLowSetPointLimits    ${test_input}[high_set_point_limit]    ${test_input}[low_set_point_limit]
    #12. Wait 1 minute
    common.waitForMinutes    1
    #13. Override all AHUs off
    apiresources.overrideAllAHUsWithBOPValueOFF
    #14. Wait 2 minutes
    common.waitForMinutes    2
    #15. Release overrides
    apiresources.releaseOverrideOfAllAHUs
    #16. Wait 2 minutes
    common.waitForMinutes    2
    #We expect no AHUs to turn ON
    apiresources.checkBOPValueOfAllAHUsAreOFF
    #17. Test 2 - MinOn AHU turn-on order
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Test 2-MinOn AHU turn-on order
    #18. Set system config MinRequiredAhuOn = 9 … so all the AHUs should turn ON
    apiresources.changeGroupPropertiesParameterValue    MinRequiredAhuOn  int  ${test_input}[min_required_ahu_on_9]
    #19. Wait 12 minutes
    #All AHUs should turn ON at 1 minute intervals …. or maybe 90 seconds intervals
    #AHUs should turn on in the correct order - CAC_14, 13, 15, 17, 16, 12, 11, 10
    minOnTestResources.checkTheOrderOfAHUsTurningON  ${test_input}[expected_ahu_turn_ON_order]
    #20. Test 3 - Manual overrides force MinOn violation
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Test 3-Manual overrides force MinOn violation
    #21. Override CAC_10, CAC_11 OFF - they turn off
    apiresources.overrideNamedAHUsWithBOPValueOFF  ${test_input}[ahu_name_0]  ${test_input}[ahu_name_1]
    common.waitForSeconds  60
    apiresources.checkBOPValueOfNamedAHUsAreOFF  ${test_input}[ahu_name_0]  ${test_input}[ahu_name_1]
    #22. Release the overrides and wait 2 minutes
    apiresources.releaseOverrideOfNamedAHUs  ${test_input}[ahu_name_0]  ${test_input}[ahu_name_1]
    common.waitForMinutes    3
    #The AHUs should turn back ON
    apiresources.checkBOPValueOfNamedAHUsAreON  ${test_input}[ahu_name_0]  ${test_input}[ahu_name_1]
    #23. Test 4 - Manual OFF overrides can turn other AHUs ON
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Test 4-Manual overrides force MinOn violation
    #24. Set system config MinRequiredAhuOn = 2
    apiresources.changeGroupPropertiesParameterValue    MinRequiredAhuOn  int  ${test_input}[min_required_ahu_on_2]
    #25. Override all AHUs except CAC_10, CAC_11 OFF
    apiresources.overrideNamedAHUsWithBOPValueOFF  ${test_input}[ahu_name_2]  ${test_input}[ahu_name_3]  ${test_input}[ahu_name_4]  ${test_input}[ahu_name_5]  ${test_input}[ahu_name_6]  ${test_input}[ahu_name_7]
    #26. Wait 1 minute
    common.waitForMinutes    1
    #27. The 6 AHUs should turn OFF
    apiresources.checkBOPValueOfNamedAHUsAreOFF  ${test_input}[ahu_name_2]  ${test_input}[ahu_name_3]  ${test_input}[ahu_name_4]  ${test_input}[ahu_name_5]  ${test_input}[ahu_name_6]  ${test_input}[ahu_name_7]
    #28. Release the overrides
    apiresources.releaseOverrideOfNamedAHUs  ${test_input}[ahu_name_2]  ${test_input}[ahu_name_3]  ${test_input}[ahu_name_4]  ${test_input}[ahu_name_5]  ${test_input}[ahu_name_6]  ${test_input}[ahu_name_7]
    #29. Wait 2 minutes
    common.waitForMinutes    2
    #30. The AHUs should stay OFF
    apiresources.checkBOPValueOfNamedAHUsAreOFF  ${test_input}[ahu_name_2]  ${test_input}[ahu_name_3]  ${test_input}[ahu_name_4]  ${test_input}[ahu_name_5]  ${test_input}[ahu_name_6]  ${test_input}[ahu_name_7]
    #31. Override CAC_10, CAC_11 OFF and wait 3 minutes
    apiresources.overrideNamedAHUsWithBOPValueOFF  ${test_input}[ahu_name_0]  ${test_input}[ahu_name_1]
    common.waitForMinutes    3
    #Two other AHUs should turn ON
    apiresources.checkBOPValueOfNamedAHUsAreON  ${test_input}[ahu_name_4]  ${test_input}[ahu_name_3]
    #32. End Test
CleanUp
    [Teardown]  apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Finished Test->MinOn test
    #a..Reset group configs AllowNumExceedencesGuard = null, AllowNumExceedencesControl = null, GuardHotAbsTemp = 90, AlmHotAbsTemp = 90, MinRequiredAhuOn = null
    uiresources.setListedGroupPropertiesToEmpty  AllowNumExceedencesGuard  AllowNumExceedencesControl  MinRequiredAhuOn
    apiresources.changeGroupPropertiesParameterValue    GuardHotAbsTemp  float  ${test_input}[guard_hot_abs_temp_default]
    apiresources.changeGroupPropertiesParameterValue    AlmHotAbsTemp  float  ${test_input}[alm_hot_abs_temp_default]
    #33.Reset system config NumMinutesStartTimer=15
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  NumMinutesStartTimer  ${test_input}[config_num_minutes_start_timer_default]
    #34.Stop all processes except vx_server and facs_launcher
    connection.establishConnectionAndStopAllProcessesExcept    vx_server    facs_launcher    facs_trend
    #Release overrides
    apiresources.releaseOverrideOfAllAHUs

