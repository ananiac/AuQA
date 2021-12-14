*** Settings ***
Documentation          This resource file provides the keyword definition specific to Alram1-1 testsuite
#...                    Created on 8th Dec 2021
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library     String
Library    SeleniumLibrary
Library    ${EXECDIR}/ExternalKeywords/common.py
Variables    ${EXECDIR}/Configurations/${environment}.py
#Variables    ${EXECDIR}/PageObjects/siteEditorHomePage.py
Resource    ${EXECDIR}/Resources/apiresources.robot
#Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/common.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot


*** Keywords ***
ahuFailedToTurnOffAlarmTestPreconditionSetup
    [Documentation]    Stop all VEM processes and wait for 2 minutes
    ...                Also write test entry temperature for the parallel staleStatePrevention program
    log to console    !-----Reading the inputs from the excel and storing in dictionary------!
    testInputs.readingInputsFromExcel  alarmTest  A  B
    common.setFlagValue    ${test_entry_flag}         #to handle the parallel program stale state.
    log to console    !-----PreCondition for the Alarm-1 test is been executed------!
    connection.establishConnectionAndStopAllProcessesExcept
    common.waitForMinutes    2
    apiresources.writeTestEntryTemperatureToSensorsAfterVXServerStarted

setAllowNumExceedencesGuardCATGuardBandRangeOnPwrLvl
    ##config DASHM::AllowNumExceedencesGuard=1 and CATGuardBandRange=4 and for AHU NB-AHU-13 set the OnPwrLvl property to 0.5
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  AllowNumExceedencesGuard  ${test_input}[allow_num_exceedences_guard]
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  CATGuardBandRange  ${test_input}[cat_guard_band_range]
    ${ahuoid}=    apiresources.getOidOfComponentUsingComponentName   ${test_input}[ahu_change_onpwrlvl]
    log to console     ${ahuoid}
    apiresources.setComponentPropertyValue   ${ahuoid}     OnPwrLvl    float      ${test_input}[ahu_property_onpwrlvl]

noFailedToTurnOffAlarms
    ${noalarm}=     apiresources.queryToFetchJsonResponseAlarmMsgAHUFailToTurOff
#    log to console  from ahuresourcefile ${noalarm}
    should be equal as strings  ${noalarm}  None
    log to console  ================No Alarms are found===========================

#Delete if not requit=tred
#setConfigSFCMinAndSFCMaxValues
#    [arguments]    ${sfc_min_value}    ${sfc_max_value}
#    apiresources.changeCxConfigsTabModuleFieldValues  SYSTEM  SFCMin  ${sfc_min_value}
#    apiresources.changeCxConfigsTabModuleFieldValues  SYSTEM  SFCMax  ${sfc_max_value}
#
#    #Created by Greeshma on 3rd Nov 2021
#verifySupplyFanValueOfListedAHUsAreSFCMinValue
#    [Arguments]    @{ahu_list}
#    FOR  ${ahu_name}  IN  @{ahu_list}
#        apiresources.verifyValueOfSpecificControlofNamedAHU    ${ahu_name}   SFC    ${test_input}[SFCMinValue]
#    END