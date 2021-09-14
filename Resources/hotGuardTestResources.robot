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
Variables    ${EXECDIR}/Inputs/hotGuardTestInputs.py

*** Keywords ***
hotGuardTestPreconditionSetup
    [Documentation]    Stop all VEMS processes except vx_server and facs_trends
    ...                Also write test entry temperature for the parallel staleStatePrevention program
    log to console    !-----PreCondition for the Dead Sensor Guard test is been executed------!
    connection.establishConnectionAndStopAllVEMProcessesExceptVx_serverAndFacs_trends
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
    apiresources.changeGroupPropertiesParameterValue    AllowNumExceedencesGuard  int  ${allow_num_exceedences_guard_cleanup_value}
    apiresources.changeGroupPropertiesParameterValue    GuardHotAbsTemp  float  ${guard_hot_abs_temp_cleanup_value}
    apiresources.changeGroupPropertiesParameterValue    AlmHotAbsTemp  float  ${alm_hot_abs_temp_cleanup_value}