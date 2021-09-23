*** Settings ***
Documentation          This resource file provides the keyword definition specific to
...                    Guard 4 - Guard order MIX testsuite

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
#Variables    ${EXECDIR}/Inputs/hotGuardTestInputs.py
Variables    ${EXECDIR}/Inputs/guardOrderMIXInputs.py

*** Keywords ***
guardOrderMIXTestPreconditionSetup
    [Documentation]    No VEMS processes are running except
    ...                API Server[vx_server], Script Launcher[facs_launcher], Trend[facs_trend], Cooling Control[facs_dash] and Application Metrics[facs_sift]
    ...                Simulator process is NOT running
    ...                Also write test entry temperature for the parallel staleStatePrevention program
    log to console    !-----PreCondition for the Guard order MIX test is been executed------!
    connection.establishConnectionAndStopAllProcessesExcept    vx_server    facs_launcher    facs_trend
    connection.establishConnectionAndStartRequiredProcesses    vx_server  facs_launcher  facs_trend

#    apiresources.writeTestEntryTemperatureToSensorsAfterVXServerStarted

setConfigAllowNumExceedencesGuardAndCATGuardBAndRange
    [Arguments]    ${config_allow_num_exceedences_guard_value}    ${config_CAT_guard_band_range_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM    AllowNumExceedencesGuard    ${config_allow_num_exceedences_guard_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM    CATGuardBandRange    ${config_CAT_guard_band_range_value}

setConfigGuardHysteresisBandAndCATGuardBandRange
    [Arguments]    ${config_guard_hysteresis_band_value}    ${config_CAT_guard_band_range_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM    GuardHysteresisBand    ${config_guard_hysteresis_band_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM    CATGuardBandRange    ${config_CAT_guard_band_range_value}

setconfigNumGuardUnitsNumMinutesGuardTimerAndNumMinutesPast
    [Arguments]    ${config_num_guard_units_value}    ${config_num_minutes_guard_timer_value}    ${config_system_num_minutes_past_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  NumGuardUnits  ${config_num_guard_units_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  NumMinutesGuardTimer  ${config_num_minutes_guard_timer_value}
    apiresources.changeCxConfigsTabModuleFieldValues  SYSTEM  NumMinutesPast  ${config_system_num_minutes_past_value}

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

setGuardOrderMIXGroupPropertiesToEmpty
    setGroupPropertiesForGuardOrderMIXToZero
    sleep  ${load_time}
    uiresources.startBrowserAndLoginToAIEngine
    sleep  ${load_time}
    uiresources.selectAndClickGroupName
    uiresources.clickAllPropertiesButton
    uiresources.setGroupPropertyToEmpty  AllowNumExceedencesGuard
    uiresources.setGroupPropertyToEmpty  GuardHotAbsTemp
    close browser

setGroupPropertiesForGuardOrderMIXToZero
    apiresources.changeGroupPropertiesParameterValue    AllowNumExceedencesGuard  int  ${allow_num_exceedences_guard_cleanup_value}
    apiresources.changeGroupPropertiesParameterValue    GuardHotAbsTemp  float  ${guard_hot_abs_temp_cleanup_value}

setGroupPropertyAllowNumExceedencesControl
    [Arguments]    ${allow_num_exceedences_control_value}
    apiresources.changeGroupPropertiesParameterValue    AllowNumExceedencesControl  int  ${allow_num_exceedences_control_value}
    common.waitForMinutes   1
#    apiresources.checkingGuardModeOfGroup    ${expected_guard_status_value}                         #query
#    apiresources.checkingAlarmStatusForGroup  GroupDeadSensor  ${expected_alarm_status_value}                  #query

overrideAHUsGuard4
    ${var_dict}=  queryToFetchJsonResponseContaingTheCurrentAHUStatus
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
        setBOPValueGuard4    ${ahu_bop_oid}
        #settingSFC  ${ahu_name}  ${ahu_sfc_oid}
        run keyword if    '${ahu_name}'=='CAC_1${i}'    setSFCValueGuard4    ${ahu_sfc_oid}  ${guardOrderMIXInputs}[ahu_cac_1${i}_value]
    END
    log to console  AHU names in a Group ${ahu_names_list} BOP list ${ahu_bop_oid_list} SFC list ${ahu_sfc_oid_list}

settingSFC
    [Arguments]    ${ahu_name}  ${ahu_sfc_oid}
    log to console    ${ahu_name}  ${ahu_sfc_oid}
    run keyword if    '${ahu_name}'=='CAC_10'    setSFCValueGuard4    ${ahu_sfc_oid}  ${guardOrderMIXInputs}[ahu_cac_10_value]
    log to console  ${ahu_sfc_oid}  ${guardOrderMIXInputs}[ahu_cac_10_value]
#    FOR    ${i}    IN RANGE    0    8       #${total_no_ahus}
#    run keyword if    '${ahu_name}'=='CAC_1${i}'    setSFCValueGuard4    ${ahu_sfc_oid}  ${guardOrderMIXInputs}[ahu_cac_1${i}_value]
#    log to console  ${ahu_sfc_oid}  ${guardOrderMIXInputs}[ahu_cac_1${i}_value]
#    END

setBOPValueGuard4
    [Arguments]    ${ahu_bop_oid}
    ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${write_api_token}
    ${graphql_mutation}=  gqlMutation.setBOPMutation  ${ahu_bop_oid}    #${oid_sfc_value}
    log to console  ${graphql_mutation}
    ${body}=          create dictionary    query= ${graphql_mutation}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    log to console  ${result}
    log to console   Set ON for AHU's BOP ${ahu_bop_oid}

setSFCValueGuard4
    [Arguments]    ${ahu_sfc_oid}  ${oid_sfc_value}
    ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${write_api_token}
    ${graphql_mutation}=  gqlMutation.setSFCMutation  ${ahu_sfc_oid}  ${oid_sfc_value}
    log to console  ${graphql_mutation}
    ${body}=          create dictionary    query= ${graphql_mutation}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    log to console  ${result}
    log to console   Set SFC value for AHU

coolEffortEstimates
    ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${write_api_token}
    ${graphql_mutation}=  gqlMutation.getCoolEstimateEffortsQuery  ${group_name}
    ${body}=          create dictionary    query= ${graphql_mutation}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    &{var_dict}=    evaluate     json.loads("""${result.content}""")    json
    log to console   ${var_dict}
    @{cool_effort_estimate_ahus_list}=  create list
    @{cool_effort_estimate_value_list}=  create list
    FOR    ${i}    IN RANGE    0    8   #${total_no_ahus}
        ${cool_effort_estimate_ahu}=    set variable    ${var_dict}[data][site][groups][0][ahus][${i}][name]
        ${cool_effort_estimate_value}=    set variable    ${var_dict}[data][site][groups][0][ahus][${i}][CoolEffortEstimate][0][pointCurrent][value]
        log to console    cool_effort_estimate_ahu ${cool_effort_estimate_ahu}
        log to console    CoolEffortEstimate value ${cool_effort_estimate_value}
        Append To List    ${cool_effort_estimate_ahus_list}    ${var_dict}[data][site][groups][0][ahus][${i}][name]
        Append To List    ${cool_effort_estimate_value_list}    ${var_dict}[data][site][groups][0][ahus][${i}][CoolEffortEstimate][0][pointCurrent][value]
    END
    log to console  cool_effort_estimate_ahus_list ${cool_effort_estimate_ahus_list}
    log to console  cool_effort_estimate_value_list ${cool_effort_estimate_value_list}

setGuardHotAbsTempProperty
    [Arguments]    ${guard_hot_abs_temp_property_value}
    apiresources.changeGroupPropertiesParameterValue    GuardHotAbsTemp  int  ${guard_hot_abs_temp_property_value}
    common.waitForMinutes   1

releaseAllAHUOverrides
    releaseAllAHUBOPOverrides
    releaseAllAHUSFCOverrides

releaseAllAHUBOPOverrides
    ${var_dict}=  fetchAHUsBOPOidsAndSFCOidsInDictionaryGuard4
    ${total_ahus}=  getAHUCount
    FOR    ${i}    IN RANGE    0    ${total_ahus}
        ${clear_bop_oid}=    set variable    ${var_dict}[data][site][groups][0][ahus][${i}][oid]
        log to console  ${clear_bop_oid}
        ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${write_api_token}
        ${graphql_mutation}=  gqlMutation.clearBOPMutation  601
         log to console  Mutation ${graphql_mutation}
        ${body}=          create dictionary    query= ${graphql_mutation}
        log to console  Body ${body}
        create session    AIEngine    ${base_url}     disable_warnings=1
        ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
        &{var_dict1}=    evaluate     json.loads("""${result.content}""")    json
        log to console   ${var_dict1}
    END

releaseAllAHUSFCOverrides
    ${var_dict}=  fetchAHUsBOPOidsAndSFCOidsInDictionaryGuard4
    ${total_ahus}=  getAHUCount
    FOR    ${i}    IN RANGE    0    ${total_ahus}
        ${clear_bop_oid}=    set variable    ${var_dict}[data][site][groups][0][ahus][${i}][oid]
        log to console  ${clear_bop_oid}
        ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${write_api_token}
        ${graphql_mutation}=  gqlMutation.clearSFCMutation  601
         log to console  Mutation ${graphql_mutation}
        ${body}=          create dictionary    query= ${graphql_mutation}
        log to console  Body ${body}
        create session    AIEngine    ${base_url}     disable_warnings=1
        ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
        &{var_dict1}=    evaluate     json.loads("""${result.content}""")    json
        log to console   ${var_dict1}
    END

fetchAHUsBOPOidsAndSFCOidsInDictionaryGuard4
    ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${query_api_token}
    ${query}=  gqlMutation.getAHUStatusInGroupQuery  ${group_name}
    ${body}=          create dictionary    query= ${query}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    &{var_dict}=    evaluate     json.loads("""${result.content}""")    json
    return from keyword    ${var_dict}

getAHUCount
    ${var_dict}=  fetchAHUsBOPOidsAndSFCOidsInDictionaryGuard4
    ${total_no_ahus}=    fetchTheNumberOfItemsInDictionary    ${var_dict}    ${ahus_list_path}
    return from keyword    ${total_no_ahus}


