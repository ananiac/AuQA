*** Settings ***
Documentation          This resource file provides the keyword definition specific to Basic Hot Absolute Guard test
...                    Created by Greeshma on 18th August 2021
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Variables    ${EXECDIR}/Resources/ResourceVariables/globalVariables.py
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot


*** Keywords ***
basicHotAbsoluteGuardTestSetup
    [Documentation]    Make sure no VEMS processes are running except vx_server and facs_trends
    ...                Make sure the simulator is NOT running
    ...                Also write test entry temperature for the parallel staleStatePrevention program
    log to console    !-----PreCondition for the Basic Hot Absolute Guard test is been executed------!
    connection.establishConnectionAndStopAllVEMProcessesExceptVx_serverAndFacs_trends
    apiresources.writeTestEntryTemperatureToSensorsAfterVXServerStarted