*** Settings ***
Documentation          This resource file provides the keyword definition specific to Basic Hot Absolute Guard test
#...                    Created by Greeshma on 18th August 2021
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Variables    ${EXECDIR}/Resources/ResourceVariables/globalVariables.py
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot


*** Keywords ***
basicHotAbsoluteGuardTestSetup
    [Documentation]    Make sure no VEMS processes are running except vx_server and facs_trends
    ...                Make sure the simulator is NOT running
    ...                Also write test entry temperature for the parallel staleStatePrevention program
    ...                24Sep21: readingInputsFromExcel included to read the input from excel
    log to console    !-----Reading the inputs from the excel and storing in dictionary------!
    testInputs.readingInputsFromExcel  guardTest  A  B
    log to console    !-----PreCondition for the Basic Hot Absolute Guard test is been executed------!
    connection.establishConnectionAndStopAllProcessesExcept    vx_server  facs_trend
    apiresources.writeTestEntryTemperatureToSensorsAfterVXServerStarted
    common.waitForMinutes    1

    #Moved from apiresource.robot by Greeshma on 31 August 2021
setGroupProperties_GuardHotAbsTemp_AlmHotAbsTemp_AllowNumExceedencesGuard_AllowNumExceedencesControl
    [Arguments]    ${allow_num_excd_ctrl}    ${allow_num_excd_guard}    ${alm_hot_abs_temp}    ${guard_hot_abs_temp}
    log to console    Set the Group properties values->Group>Properties->AllowNumExceedencesGuard = ${allow_num_excd_guard} AllowNumExceedencesControl = ${allow_num_excd_ctrl}
    log to console    AlmHotAbsTemp = ${alm_hot_abs_temp}(degree F) GuardHotAbsTemp = ${guard_hot_abs_temp} (degrees F)---------->
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${setGrpProp}=  gqlMutation.setGrpPropMutation  ${allow_num_excd_ctrl}  ${allow_num_excd_guard}  ${alm_hot_abs_temp}  ${guard_hot_abs_temp}
    ${body}=          create dictionary    query= ${setGrpProp}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings  ${result.json()}  ${propertyWriteResponse}