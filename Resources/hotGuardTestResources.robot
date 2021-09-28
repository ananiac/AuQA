*** Settings ***
Documentation          This resource file provides the keyword definition specific to Guard 3-Hot Guard testsuite
#...                    Created by Greeshma on 20th August 2021
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Variables    ${EXECDIR}/Resources/ResourceVariables/globalVariables.py
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    common.robot
Library    SeleniumLibrary
Variables    ${EXECDIR}/Configurations/${environment}.py
Variables    ${EXECDIR}/PageObjects/siteEditorHomePage.py
Resource    ${EXECDIR}/Inputs/testInputs.robot

*** Keywords ***
hotGuardTestPreconditionSetup
    [Documentation]    Make sure no VEMS processes are running except vx_server, facs_launcher, facs_trends.
    ...                Also write test entry temperature for the parallel staleStatePrevention program
    log to console    !-----Reading the inputs from the excel and storing in dictionary------!
    testInputs.readingInputsFromExcel  0  G  H
    log to console    !-----PreCondition for the Dead Sensor Guard test is been executed------!
    connection.establishConnectionAndStopAllProcessesExcept    vx_server    facs_launcher    facs_trend
    apiresources.writeTestEntryTemperatureToSensorsAfterVXServerStarted

setConfigAllowNumExceedencesGuardAndCATGuardBAndRange
    [Arguments]    ${config_allow_num_exceedences_guard_value}    ${config_CAT_guard_band_range_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM    AllowNumExceedencesGuard    ${config_allow_num_exceedences_guard_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM    CATGuardBandRange    ${config_CAT_guard_band_range_value}

setConfigGuardHysteresisBandAndCATGuardBandRange
    [Arguments]    ${config_guard_hysteresis_band_value}    ${config_CAT_guard_band_range_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM    GuardHysteresisBand    ${config_guard_hysteresis_band_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM    CATGuardBandRange    ${config_CAT_guard_band_range_value}

setconfigNumGuardUnitsNumMinutesGuardTimerAndGuardHysteresisBand
    [Arguments]    ${config_num_guard_units_value}    ${config_num_minutes_guard_timer_value}    ${config_guard_hysteresis_band_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM    NumGuardUnits    ${config_num_guard_units_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM    NumMinutesGuardTimer    ${config_num_minutes_guard_timer_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM    GuardHysteresisBand    ${config_guard_hysteresis_band_value}

checkGuardAndGroupHotAlarmForTemperatureChangeOnFirstRack
    [Arguments]    ${temp}    ${expected_guard_status_value}    ${expected_alarm_status_value}
    apiresources.setTemperatureForSensorsAandB    ${temp}    #write
    common.waitForMinutes    1
    apiresources.checkingGuardModeOfGroup    ${expected_guard_status_value}                         #query
    apiresources.checkingAlarmStatusForGroup    GroupHot    ${expected_alarm_status_value}                  #query

checkGuardAndGroupHotAlarmForConfigAllowNumExceedencesGuardValueChange
    [Arguments]    ${allow_num_exceedences_guard_value}    ${expected_guard_status_value}    ${expected_alarm_status_value}

    apiresources.setConfigAllowNumExceedencesGuard    ${allow_num_exceedences_guard_value}    #write
    common.waitForMinutes    1
    apiresources.checkingGuardModeOfGroup    ${expected_guard_status_value}                         #query
    apiresources.checkingAlarmStatusForGroup    GroupHot    ${expected_alarm_status_value}                  #query

checkGuardAndGroupHotAlarmForGroupAllowNumExceedencesGuardValueChange
    [Arguments]    ${allow_num_exceedences_guard_value}    ${expected_guard_status_value}    ${expected_alarm_status_value}
    apiresources.setAllowNumExceedencesGuardOfGroupProperties    ${allow_num_exceedences_guard_value}    #write
    common.waitForMinutes    1
    apiresources.checkingGuardModeOfGroup    ${expected_guard_status_value}                         #query
    apiresources.checkingAlarmStatusForGroup    GroupHot    ${expected_alarm_status_value}                  #query

setHotGuardGroupPropertiesToEmpty
    setGroupPropertiesForHotGuardToSomeValue
    sleep  ${load_time}
    uiresources.startBrowserAndLoginToAIEngine
    sleep  ${load_time}
    uiresources.selectAndClickGroupName
    uiresources.clickAllPropertiesButton
    uiresources.setGroupPropertyToEmpty  AllowNumExceedencesGuard
    uiresources.setGroupPropertyToEmpty  GuardHotAbsTemp
    uiresources.setGroupPropertyToEmpty  AlmHotAbsTemp
#    reload page
    close browser

setGroupPropertiesForHotGuardToSomeValue
    apiresources.changeGroupPropertiesParameterValue    AllowNumExceedencesGuard  int  ${test_input}[allow_num_exceedences_guard_cleanup_value]
    apiresources.changeGroupPropertiesParameterValue    GuardHotAbsTemp  float  ${test_input}[guard_hot_abs_temp_cleanup_value]
    apiresources.changeGroupPropertiesParameterValue    AlmHotAbsTemp  float  ${test_input}[alm_hot_abs_temp_cleanup_value]

#releaseAllAHUOverrides
#    log to console  Release all AHUs Overrides
##    checkAHUOverrideMode
##    apiresources.checkForAHUInOverrideMode
#    apiresources.releaseAllAHUBOPOverrides
#    apiresources.releaseAllAHUSFCOverrides

#Check AHU Override mode in Group
checkAHUOverrideMode
    ${var_dict}=  apiresources.queryToFetchJsonResponseContaingTheCurrentAHUStatus
    #log to console  ${var_dict}
    @{ahu_names_list}=  create list
    @{ahu_bop_oid_list}=  create list
    @{ahu_sfc_oid_list}=  create list
    FOR  ${i}  IN RANGE  0  8
        ${ahu_name}=    set variable    ${var_dict}[data][site][groups][0][ahus][${i}][name]
        ${ahu_bop_oid}=    set variable    ${var_dict}[data][site][groups][0][ahus][${i}][controls][0][oid]
        ${ahu_sfc_oid}=    set variable    ${var_dict}[data][site][groups][0][ahus][${i}][controls][1][oid]
        log to console    ahu_name ${ahu_name}
        log to console    ahu_bop_oid ${ahu_bop_oid}
        log to console    ahu_bop_oid ${ahu_sfc_oid}
        Append To List    ${ahu_names_list}    ${var_dict}[data][site][groups][0][ahus][${i}][name]
        Append To List    ${ahu_bop_oid_list}    ${var_dict}[data][site][groups][0][ahus][${i}][controls][0][oid]
        Append To List    ${ahu_sfc_oid_list}    ${var_dict}[data][site][groups][0][ahus][${i}][controls][1][oid]
#        settingBOPValueOfAHU    ${ahu_bop_oid}
#        run keyword if    '${ahu_name}'=='CAC_1${i}'    settingSFCValueOfAHU    ${ahu_sfc_oid}  ${guardOrderMIXInputs}[ahu_cac_1${i}_value]
    END
    log to console  AHU names in a Group ${ahu_names_list} BOP list ${ahu_bop_oid_list} SFC list ${ahu_sfc_oid_list}

#releaseAllAHUBOPOverrides
#    log to console  Release all AHUs with respect to BOP Overrides
#    ${var_dict}=  apiresources.queryToFetchJsonResponseContaingTheCurrentAHUStatus
#    #log to console  ${var_dict}
#    ${total_ahus}=  apiresources.getAHUCountAQUA42
#    FOR    ${i}    IN RANGE    0    ${total_ahus}
#        ${clear_bop_oid}=    set variable    ${var_dict}[data][site][groups][0][ahus][${i}][controls][0][oid]
#        log to console  AHUs BOP Oid ${clear_bop_oid}
#        ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${write_api_token}
#        ${graphql_mutation}=  gqlMutation.clearBOPMutation  ${clear_bop_oid}
#        #log to console  ${graphql_mutation}
#        ${body}=          create dictionary    query= ${graphql_mutation}
#        #log to console  Body ${body}
#        create session    AIEngine    ${base_url}     disable_warnings=1
#        ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
#        &{var_dict1}=    evaluate     json.loads("""${result.content}""")    json
#        log to console   ${var_dict1}
#    END

#releaseAllAHUSFCOverrides
#    log to console  Release all AHUs with respect to SFC Overrides
#    ${var_dict}=  apiresources.queryToFetchJsonResponseContaingTheCurrentAHUStatus
#    #log to console  ${var_dict}
#    ${total_ahus}=  apiresources.getAHUCountAQUA42
#    FOR    ${i}    IN RANGE    0    ${total_ahus}
#        ${clear_sfc_oid}=    set variable    ${var_dict}[data][site][groups][0][ahus][${i}][controls][1][oid]
#        log to console  AHUs SFC Oid ${clear_sfc_oid}
#        ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${write_api_token}
#        ${graphql_mutation}=  gqlMutation.clearSFCMutation  ${clear_sfc_oid}
#        #log to console  ${graphql_mutation}
#        ${body}=          create dictionary    query= ${graphql_mutation}
#        #log to console  Body ${body}
#        create session    AIEngine    ${base_url}     disable_warnings=1
#        ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
#        &{var_dict1}=    evaluate     json.loads("""${result.content}""")    json
#        log to console   ${var_dict1}
#    END
