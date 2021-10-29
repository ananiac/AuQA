*** Settings ***
Documentation          This resource file provides the keyword definition specific to Override-1 testsuite
#...                    Created by Greeshma on 29th Oct 2021
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library     String
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Library    SeleniumLibrary
Variables    ${EXECDIR}/Configurations/${environment}.py
Variables    ${EXECDIR}/PageObjects/siteEditorHomePage.py
Resource    ${EXECDIR}/Resources/common.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot
Library    ${EXECDIR}/ExternalKeywords/common.py


*** Keywords ***
override1TestPreconditionSetup
    [Documentation]    Stop all VEM processes and wait for 2 minutes
    ...                Also write test entry temperature for the parallel staleStatePrevention program
    log to console    !-----Reading the inputs from the excel and storing in dictionary------!
    testInputs.readingInputsFromExcel  overrideTest  A  B
    common.setFlagValue    ${test_entry_flag}         #to handle the parallel program stale state.
    log to console    !-----PreCondition for the Override-1 test is been executed------!
    connection.establishConnectionAndStopAllProcessesExcept
    common.waitForMinutes    2
    apiresources.writeTestEntryTemperatureToSensorsAfterVXServerStarted

setConfigSFCMinAndSFCMaxValues
    [arguments]    ${sfc_min_value}    ${sfc_max_value}
    apiresources.changeCxConfigsTabModuleFieldValues  SYSTEM  SFCMin  ${sfc_min_value}
    apiresources.changeCxConfigsTabModuleFieldValues  SYSTEM  SFCMax  ${sfc_max_value}