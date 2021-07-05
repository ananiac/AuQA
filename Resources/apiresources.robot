*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library    OperatingSystem
Variables    ../Configurations/config.py
Variables    ../JsonPath/basicHotAbsoluteGuard.py
Resource    common.robot



*** Variables ***
${base_url}    https://10.252.9.37/api


*** Keywords ***
changeNumGuardUnitsAndNumMinutesGuardTimer
    log to console    Set Guard Units and Guard timer under CX->Tools->Config->DASHM-------->
    [Arguments]    ${units}    ${timer}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${body}=          create dictionary    query= mutation configWrite { configSet(requests: [{module: "DASHM", name: "NumGuardUnits", value: "${units}"},{module: "DASHM",name:"NumMinutesGuardTimer",value:"${timer}"}]) { index reason }}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    log to console    ${result.json()}
setGuardHotAbsTemp
    [Arguments]    ${temp}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${body}=          create dictionary    query= mutation setGrpProp { propertyWrite(requests: [{oid: 17, name: "GuardHotAbsTemp", float: ${temp}}]) { index reason }}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    log to console    ${result.json()}
setGroupPropertiesGuardHotAbsTempAllowNumExceedencesGuardAndControl
    log to console    Set the Group properties values->Grp GRP00->Properties->AllowNumExceedencesGuard = 10 AllowNumExceedencesControl = 10
    log to console    AlmHotAbsTemp = 200(degree F) GuardHotAbsTemp = 90 (degrees F)---------->
    [Arguments]    ${allow_num_excd_ctrl}    ${allow_num_excd_guard}    ${alm_hot_abs_temp}    ${guard_hot_abs_temp}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${body}=          create dictionary    query= mutation setGrpProp { propertyWrite(requests: [{oid: 17, name: "AllowNumExceedencesGuard", int: ${allow_num_excd_guard}},{oid: 17, name: "AllowNumExceedencesControl", int: ${allow_num_excd_ctrl}},{oid: 17, name: "GuardHotAbsTemp", float: ${guard_hot_abs_temp}},{oid: 17, name: "AlmHotAbsTemp", float: ${alm_hot_abs_temp}}]) { index reason }}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    log to console    ${result.json()}
    sleep    ${medium_speed}

setRackPointTemp
    [Arguments]    ${temp}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${mutation}     get binary file    ./Inputs/setRackPointTemperature.gql
    ${body}=          create dictionary    query= ${mutation}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    log to console    ${result.json()}
setAllRackPointSensorTempCool
    [Arguments]    ${temp}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${body}=          create dictionary    query= mutation pointWrite { pointWrite(requests: [{oid: 26279, value: ${temp}}]) { index reason }}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    log to console    ${result.json()}
checkGroupControlStatusValueNotInGuard
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${query_api_token}
    ${file}    get binary file    ./Inputs/getGroupControlStatusValue.gql
    ${body}=          create dictionary    graphQuery= ${file}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    log to console    ${result.json()}
    @{ctrl_state_value}    get value from json    ${result.json()}    ${trends_groupStatus_controlStatus_value}
    ${value}    get from list    ${ctrl_state_value}    0
    log to console    *********Validating the Ctrl Status is not in Guard(expect any other value than 2)******
    should not be equal as integers    ${value}    2    System should not be in guard(2)
checkGroupControlStausValueInGuard
    log to console    Checking Group Control Status for the value to be in guard.
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${query_api_token}
    ${file}    get binary file    ./Inputs/getGroupControlStatusValue.gql
    ${body}=          create dictionary    graphQuery= ${file}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    log to console    ${result.json()}
    @{ctrl_state_value}    get value from json    ${result.json()}    ${trends_groupStatus_controlStatus_value}
    ${value}    get from list    ${ctrl_state_value}    0
    should be equal as integers    ${value}    2    System should be in guard(2)
checkAHUToBeInGuard
    log to console    Validate the number of AHUs in guard----------------->
    ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${query_api_token}
    ${file}    get binary file    ./Inputs/getGroupAHUControlsStatus.gql
    ${body}=          create dictionary    query= ${file}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    log to console    ${result.json()}
    log to console    ***************************************************************
    @{ahu_status_value}    get value from json    ${result.json()}    ${ahu_control_targetStatus_value}
    FOR    ${v}    IN    @{ahu_status_value}
        log to console    ${v}
        should be equal as strings    ${v}    GUARD
        END

setRackPointSensorTempCool
    [Arguments]    ${oid}    ${temp}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${body}=          create dictionary    query= mutation pointWrite { pointWrite(requests: [{oid: ${oid}, value: ${temp}}]) { index reason }}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    log to console    ${result.json()}
setRackPointsTemperature    #Contain both query and mutation
    [Arguments]    ${tempF}
    log to console    Fetch the number of rack sensor points ----------------->
    ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${query_api_token}
    ${file}    get binary file    ./Inputs/getRackPoints.gql
    ${body}=          create dictionary    query= ${file}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    #checkResponseStatusCode    ${result.status_code}
    ${json_dict}=   set variable    ${result.json()}
    ${total}=    FetchTheNumberOfItemsInDictionary    ${json_dict}    ${racks_in_group}
    log to console    Setting temperature for all sensor points----------------->
    FOR    ${i}    IN RANGE    0    ${total}
        log to console    ${i} Sensor Point
        ${rack_type1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].name
        ${rack_type2}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].name
        ${oid1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].oid
        ${oid2}     fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].oid
        run keyword if    '${rack_type1}'!='Humidity Monitor'    setRackPointSensorTempCool    ${oid1}    ${tempF}
        run keyword if    '${rack_type2}'!='Internal Thermistor'     setRackPointSensorTempCool    ${oid2}    ${tempF}
        END
    log to console    ******************************Temperature set for all rack sensors*********************************

waitForTwoMinutes
    sleep    ${low_speed}
    log to console    **************waiting for two minutes***************
    sleep    ${low_speed}
fetchTheNumberOfItemsInDictionary
    [Arguments]    ${dictionary}    ${json_of_required_node}
    log to console    find number of Points*************
    @{points}    get value from json    ${dictionary}    ${json_of_required_node}
    ${total_points_to_write}    get length   @{points}
    ${total}=    convert to integer    ${total_points_to_write}
    log to console      ${total}
    return from keyword    ${total}
fetchValueOfFieldFromJsonDictionary
        [Arguments]    ${json_dictionary}     ${json_path_of_required_field}
        ${field_value_list}    get value from json    ${json_dictionary}    ${json_path_of_required_field}
        ${field_value}    get from list    ${field_value_list}    0
        return from keyword    ${field_value}