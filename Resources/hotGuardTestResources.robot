*** Settings ***
Documentation          This resource file provides the keyword definition specific to Guard 3-Hot Guard testsuite
...                    Created by Greeshma on 20th August 2021
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
    [Documentation]    Make sure no VEMS processes are running except
    ...                vx_server, facs_launcher, facs_dash, facs_trends, and facs_sift (Application Metrics).
    ...                Only these processes should be enabled.
    ...                Make sure the simulator is NOT running
    ...                Also write test entry temperature for the parallel staleStatePrevention program
    log to console    !-----PreCondition for the Dead Sensor Guard test is been executed------!
    connection.establishConnectionAndStopAllVEMProcessesExceptVx_serverFacsLauncherFacsSiftFacsDashAndFacs_trends
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
    setGroupPropertiesForHotGuardToZero
    sleep  5 seconds
    uiresources.startBrowserAndLoginToAIEngine
    sleep  2 seconds
    selectAndClickGroupName
    clickAllPropertiesButton
    setGroupPropertyToEmpty  AllowNumExceedencesGuard
    setGroupPropertyToEmpty  GuardHotAbsTemp
    setGroupPropertyToEmpty  AlmHotAbsTemp
    reload page
    close browser

# Select and click Group Name and click on 'All Properties' button to display all properties
selectAndClickGroupName
    log to console  '${group_name}' group selected
    sleep  5 seconds
    # Group drop down list
    click element  ${group_dropdown_list}
    sleep  5 seconds

    # Select a Group from drop down list
    ${select_group}=  set variable  xpath=//li[contains(text(),'${group_name}')]

    click element  ${select_group}
    sleep  5 seconds
    # Click a Group Name
    ${select_and_click_group}=  set variable  xpath=//span[contains(.,'${group_name}')]
    click element  ${select_and_click_group}
    sleep  10 seconds

# Click 'All Properties' button to display all properties
clickAllPropertiesButton
    click element  ${all_properties_button}
    sleep    5 seconds

# Set Group Property to empty
setGroupPropertyToEmpty
    [Arguments]    ${property}
    ${group_property}=  set variable  //div[contains(text(),'${property}')]/following::td[1]
    sleep  2 seconds
    ${property_value}=  get text  ${group_property}
    log to console  ${property} property value is ${property_value}, set through api
    ${IsElementVisible}=  Run Keyword And Return Status    Element Should Be Visible   ${group_property}
    sleep  5 seconds
    IF  ${IsElementVisible}
        press keys  ${group_property}  CTRL+a+BACKSPACE+DELETE+ENTER
#        log to console  Set ${property} property to empty
        ${property_empty_value}=  get text  ${group_property}
        log to console  ${property} property value is ${property_empty_value}empty after setting to empty
        sleep  5 seconds
    ELSE
        log to console  ${property} property is not visible
    END

setGroupPropertiesForHotGuardToZero
    apiresources.changeGroupPropertiesIntValue    AllowNumExceedencesGuard    ${allow_num_exceedences_guard_value}
    apiresources.changeGroupPropertiesIntValue    GuardHotAbsTemp     ${guard_hot_abs_temp_value}
    apiresources.changeGroupPropertiesIntValue    AlmHotAbsTemp   ${alm_hot_abs_temp_value}

