*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library    OperatingSystem
Library    DateTime
Variables    ${EXECDIR}/Configurations/${environment}.py
Variables    ${EXECDIR}/Resources/ResourceVariables/globalVariables.py
Variables    ${EXECDIR}/JsonPath/basicHotAbsoluteGuardJsonpath.py
Variables    ${EXECDIR}/Inputs/expectedMutationJsonResponses.py
Resource    common.robot
Resource    connection.robot
Resource    ${EXECDIR}/Inputs/GraphQL/gqlMutation.robot


*** Variables ***
${base_url}    ${graphql_base_url}
${current_ahus_in_guard}    0
${counter}      0
${total_no_ahus}    0
${sensor_A_oid}    0
${sensor_B_oid}    0


*** Keywords ***
changeCxConfigsDashm_NumGuardUnits_NumMinutesGuardTimer_PercentDeadSensorThreshold_AndSystem_NumMinutesPast
    [Arguments]    ${num_guard_units_val}    ${num_minutes_guard_timer_val}    ${percent_dead_sensor_threshold_val}    ${num_minutes_past_val}
    changeCxConfigsTabModuleFieldValues    DASHM    NumGuardUnits    ${num_guard_units_val}
    changeCxConfigsTabModuleFieldValues    DASHM    NumMinutesGuardTimer    ${num_minutes_guard_timer_val}
    changeCxConfigsTabModuleFieldValues    DASHM    PercentDeadSensorThreshold    ${percent_dead_sensor_threshold_val}
    changeCxConfigsTabModuleFieldValues    SYSTEM   NumMinutesPast  ${num_minutes_past_val}

setPercentDeadSensorThresholdInDASHMConfig
    [Arguments]    ${percent_dead_sensor_threshold_val}
    changeCxConfigsTabModuleFieldValues    DASHM    PercentDeadSensorThreshold    ${percent_dead_sensor_threshold_val}

changeCxConfigsTabModuleFieldValues
    [Arguments]    ${module_name}    ${field_name}    ${value}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${graphql_mutation}=  gqlMutation.configWriteMutation    ${module_name}    ${field_name}    ${value}
    ${body}=          create dictionary    query= ${graphql_mutation}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings  ${result.json()}  ${configSetResponse}
    log to console    Config module :${module_name}->Field:${field_name}->Value:${value}-is updated

setRackPointSensorTemperature
    [Arguments]    ${oid}    ${temp}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${graphql_mutation}=  gqlMutation.pointWriteMutation    ${oid}    ${temp}
    ${body}=          create dictionary    query= ${graphql_mutation}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings  ${result.json()}  ${pointWriteResponse}
    log to console   Temperature ${temp} F set for ${oid}

setRackSensorPointsTemperature    #Contain both query and mutation
    [Arguments]    ${tempF}
    log to console    Fetch the number of rack sensors ----------------->
    ${json_dict}    queryToFetchJsonResponseContainingTheRackSensorsFromGroup
    ${total}=    fetchTheNumberOfItemsInDictionary    ${json_dict}    ${racks_in_group}
    log to console  No: of rack sensors is ${total}
    log to console    Setting temperature for all sensor points----------------->
    FOR    ${i}    IN RANGE    0    ${total}
        log to console    ${i} Rack Sensor
        ${rack_type1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].type
        ${rack_type2}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].type
        ${oid1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].oid
        ${oid2}     fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].oid
        run keyword if    '${rack_type1}'=='CBot'    setRackPointSensorTemperature    ${oid1}    ${tempF}
        run keyword if    '${rack_type2}'=='CTop'     setRackPointSensorTemperature    ${oid2}    ${tempF}
    END
    log to console    ******************************Temperature set for all rack sensors*********************************

queryToFetchJsonResponseContainingTheRackSensorsFromGroup
    ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${query_api_token}
    ${query}=    gqlMutation.getRackSensorPointsOfGroupQuery  ${group_name}
    ${body}=          create dictionary    query= ${query}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    ${json_dict}=   set variable    ${result.json()}
    return from keyword    ${json_dict}

setTemperatureForSensorsAandB
    [Arguments]    ${temp}
    ${json_dict}    queryToFetchJsonResponseContainingTheRackSensorsFromGroup
    #First two sensor points are picked as Sensor A and Sensor B if they are Rack Top or Rack Bottom
    ${total}=    fetchTheNumberOfItemsInDictionary    ${json_dict}    ${racks_in_group}
    log to console    Setting temperature for Sensor A and B----------------->
    FOR    ${i}    IN RANGE    0    ${total}
        log to console    ${i} Rack Sensor
        ${rack_type1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].type
        ${rack_type2}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].type
        ${oid1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].oid
        ${oid2}     fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].oid
        IF   '${rack_type1}'=='CBot'
            IF    '${rack_type2}'=='CTop'    #Excluding RHUM and ZNT
                 ${sensor_A_oid}=    set variable    ${oid1}
                 ${sensor_B_oid}=    set variable    ${oid2}
                 exit for loop
            END
        END
    END
    setRackPointSensorTemperature  ${sensor_A_oid}    ${temp}
    setRackPointSensorTemperature  ${sensor_B_oid}    ${temp}
    common.setFlagValue    ${two_sets_of_temp_flag}


getCurrentTemperatureOfSensorsAandB
    ${json_dict}    queryToFetchJsonResponseContainingTheRackSensorsFromGroup
    #First two sensor points are picked as Sensor A and Sensor B if they are Rack Top or Rack Bottom
    ${total}=    fetchTheNumberOfItemsInDictionary    ${json_dict}    ${racks_in_group}
    log to console    Getting temperature of Sensor A----------------->
    FOR    ${i}    IN RANGE    0    ${total}
        ${rack_type1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].type
        ${rack_type2}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].type
        ${oid1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].oid
        ${oid2}     fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].oid
        ${current_temp}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].pointCurrent.value
        IF   '${rack_type1}'=='CBot'
            IF    '${rack_type2}'=='CTop'    #Excluding RHUM and ZNT
                 ${sensor_A_oid}=    set variable    ${oid1}
                 ${sensor_B_oid}=    set variable    ${oid2}
                 exit for loop
            END
        END
    END
    log to console    Current temperature of Sensor A is:${current_temp}
    return from keyword    ${current_temp}

setTwoSetOfSensorTemperatureForRack
    [Arguments]    ${tempH}    ${tempC}
    ${json_dict}    queryToFetchJsonResponseContainingTheRackSensorsFromGroup
    #First two sensor points are picked as Sensor A and Sensor B if they are Rack Top or Rack Bottom
    ${total}=    fetchTheNumberOfItemsInDictionary    ${json_dict}    ${racks_in_group}
    log to console    Setting temperature for Sensor A and B----------------->
    FOR    ${i}    IN RANGE    0    ${total}
        log to console    ${i} Rack Sensor
        ${rack_type1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].type
        ${rack_type2}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].type
        ${oid1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].oid
        ${oid2}     fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].oid
        IF   '${rack_type1}'=='CBot'
            IF    '${rack_type2}'=='CTop'    #Excluding RHUM and ZNT
                 ${sensor_A_oid}=    set variable    ${oid1}
                 ${sensor_B_oid}=    set variable    ${oid2}
                 exit for loop
            END
        END
    END
    setRackPointSensorTemperature  ${sensor_A_oid}    ${tempH}
    setRackPointSensorTemperature  ${sensor_B_oid}    ${tempH}
    log to console    Setting temperature for other Sensors----------------->
    FOR    ${i}    IN RANGE    0    ${total}
        ${rack_type1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].type
        ${rack_type2}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].type
        ${oid1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].oid
        ${oid2}     fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].oid
        run keyword if
        ...    ('${rack_type1}'=='CBot' and '${oid1}'!='${sensor_A_oid}')   setRackPointSensorTemperature    ${oid1}    ${tempC}
        run keyword if
        ...   ('${rack_type2}'=='CTop' and '${oid2}'!='${sensor_B_oid}')   setRackPointSensorTemperature    ${oid2}    ${tempC}
    END

waitForTwoMinutes
    log to console    Waiting for Two minutes
    #sleep    ${low_speed}
    sleep    2 minutes
    log to console    **************two minutes waiting done***************

waitForOneMinute
    common.waitForMinutes    1

fetchTheNumberOfItemsInDictionary
    [Arguments]    ${dictionary}    ${json_of_required_node}
    @{points}    get value from json    ${dictionary}    ${json_of_required_node}
    ${total_points_to_write}    get length   @{points}
    ${total}=    convert to integer    ${total_points_to_write}
    return from keyword    ${total}

fetchValueOfFieldFromJsonDictionary
    [Arguments]    ${json_dictionary}     ${json_path_of_required_field}
    ${field_value_list}    get value from json    ${json_dictionary}    ${json_path_of_required_field}
    ${field_value}    get from list    ${field_value_list}    0
    return from keyword    ${field_value}

checkForAllAHUsToBeGuardCleared
    log to console    <----Validating AHU Guard is cleared ----->
    ${json_dictionary}=     queryToFetchJsonResponseContaingTheCurrentAHUStatus
    ${total_no_ahus}=    fetchTheNumberOfItemsInDictionary    ${json_dictionary}    ${ahus_list_path}
    confirmStatusOfAHUsNotGuard     ${total_no_ahus}     ${json_dictionary}
    log to console    *************************************************************

queryToFetchJsonResponseContaingTheCurrentAHUStatus
    ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${query_api_token}
    ${query}=  gqlMutation.getAHUStatusInGroupQuery  ${group_name}
    ${body}=          create dictionary    query= ${query}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    ${json_dictionary}=     set variable    ${result.json()}
    return from keyword    ${json_dictionary}

fetchNumberOfAHUsWithGuardON
    [Arguments]    ${total}     ${json_dictionary}
    #log to console    !---Intial counter value is ${counter}---!
    FOR    ${ahu}   IN RANGE    0    ${total}
                log to console    !!---Checking ahu at position ${ahu}---!!s
                ${no_of_controls}=    fetchTheNumberOfItemsInDictionary    ${json_dictionary}    $.data.site.groups[0].ahus[${ahu}].controls
                log to console    !!!--No of Controls for ${ahu} is ${no_of_controls}---!!!
                FOR    ${controls}  IN RANGE  0   ${no_of_controls}
                    ${ahu_status_ctrl_value}     fetchValueOfFieldFromJsonDictionary    ${json_dictionary}    $.data.site.groups[0].ahus[${ahu}].controls[${controls}].status.origin
                    log to console    !V-------Status value for AHU:${ahu} control:${controls} is ${ahu_status_ctrl_value}-----!V
                    IF  "${ahu_status_ctrl_value}"=="GUARD"         #Do we need to check both to be in Guard?
                        ${counter}=    incrementingByOne    ${counter}
                        IF    ${no_of_controls} > 1
                                FOR    ${remaining_controls}  IN RANGE  1   ${no_of_controls}
                                    ${ahu_status_ctrl_value}     fetchValueOfFieldFromJsonDictionary    ${json_dictionary}    $.data.site.groups[0].ahus[${ahu}].controls[${remaining_controls}].status.origin
                                    log to console    !V-------Status value for AHU:${ahu} control:${remaining_controls} is ${ahu_status_ctrl_value}-----!V
                                    should be equal as strings    ${ahu_status_ctrl_value}    GUARD
                                END
                        END
                        exit for loop
                    END
                END
    END
    return from keyword    ${counter}


confirmStatusOfAHUsNotGuard
   [Arguments]    ${total}     ${json_dictionary}
    FOR    ${ahu}   IN RANGE    0    ${total}
                log to console    !!---Checking ahu at position ${ahu}---!!s
                ${no_of_controls}=    fetchTheNumberOfItemsInDictionary    ${json_dictionary}    $.data.site.groups[0].ahus[${ahu}].controls
                log to console    !!!--No of Controls for ${ahu} is ${no_of_controls}---!!!
                ${ahu_status_ctrl_value}     fetchValueOfFieldFromJsonDictionary    ${json_dictionary}    $.data.site.groups[0].ahus[${ahu}].controls[0].status.origin
                log to console    !V-------Status value for AHU:${ahu} first Control is ${ahu_status_ctrl_value}-----!V
                should not be equal as strings    ${ahu_status_ctrl_value}    GUARD    AHUS are expected with GUARD Cleared
                IF    "${no_of_controls}"=="2"
                        ${ahu_status_ctrl_value}     fetchValueOfFieldFromJsonDictionary    ${json_dictionary}    $.data.site.groups[0].ahus[${ahu}].controls[1].status.origin
                        log to console    !V-------Status value for AHU:${ahu} second control is ${ahu_status_ctrl_value}-----!V
                        should not be equal as strings    ${ahu_status_ctrl_value}    GUARD    AHUS are expected with GUARD Cleared
                END
    END
    log to console    *********All AHUS are cleared of GUARD*****************

getOid
    [Arguments]    ${group_name}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${query}=  gqlMutation.getOidQuery  ${group_name}
    ${body}=  create dictionary  query= ${query}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    ${var_dict}=    evaluate     json.loads("""${result.content}""")    json
    ${group_oid_str}=    set variable    ${var_dict}[data][site][groups][0][oid]
    ${group_oid}=    convert to integer  ${group_oid_str}
    return from keyword  ${group_oid}

queryToFetchGroupOid
    ${group_oid}=  getOid  ${group_name}
    return from keyword  ${group_oid}

setTestEntryTemperatureToSensorPoints
    log to console  !!--------Test started and writing test_entry_sensor_temp ${test_entry_sensor_temp} ---------------!!
    setRackSensorPointsTemperature  ${test_entry_sensor_temp}


writeTestEntryTemperatureToSensorsAfterVXServerStarted
    common.setFlagValue    ${test_entry_flag}
    ${current_status_of_vx_server}=  connection.establishConnectionAndCheckVX_ServerProcesseStatus
    log to console  Current status of vx server is ${current_status_of_vx_server}
    IF  '${current_status_of_vx_server}'=='process_up'
        setTestEntryTemperatureToSensorPoints
    ELSE
        log to console  !!--------Need to start vx_server and write test_entry_sensor_temp---------------!!
        connection.startVXServerProcess
        setTestEntryTemperatureToSensorPoints

    END
    log to console  !!!--------------------Test Setup done------------------------------!!!

setTestExitTemperatureToFirstSensorPoint
    common.setFlagValue    ${test_exit_flag}
    log to console  *************Test finished and writing test_exit_sensor_temp ${test_exit_sensor_temp}************
    setRackSensorPointsTemperature  ${test_exit_sensor_temp}
    log to console  !!!--------------------Test Teardown done------------------------------!!!

    #Created by Greeshma on 19 Aug 2021 #remove this after making changes to test2 and test3
changeGroupPropertiesFloatParameterValue
    [Arguments]    ${property_name}  ${property_value}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${graphql_mutation}=  gqlMutation.setGroupPropertyFloat    ${property_name}  ${property_value}
    ${body}=          create dictionary    query= ${graphql_mutation}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings  ${result.json()}  ${propertyWriteResponse}
    log to console  !!------------------Group ->Propertie ${property_name} updated successfully with ${property_value}----------------!!

    #Created by Greeshma on 19 Aug 2021 #remove this after making changes to test2 and test3
changeGroupPropertiesIntParameterValue
    [Arguments]    ${property_name}  ${property_value}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${graphql_mutation}=  gqlMutation.setGroupPropertyInt    ${property_name}  ${property_value}
    ${body}=          create dictionary    query= ${graphql_mutation}
     #log to console    ${body}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    #log to console  ${result.json()}
    should be equal as strings  ${result.json()}  ${propertyWriteResponse}
    log to console  !!------------------Group ->Propertie ${property_name} updated successfully with ${property_value}----------------!!

    #Created by Greeshma on 19 Aug 2021
queryToFetchJsonResponseForSpecificAlarmType
    [Arguments]    ${alarm_type}
    ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${query_api_token}
    ${query}=  gqlMutation.getAlarmStatusQuery    ${group_name}    ${alarm_type}
    ${body}=          create dictionary    query= ${query}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    ${json_dictionary}=     set variable    ${result.json()}
    return from keyword    ${json_dictionary}

    #Created by Greeshma on 19 Aug 2021
setConfigAlarmGroupDeadSensorHysteresis
    [Arguments]    ${value}
    apiresources.changeCxConfigsTabModuleFieldValues  ALARM    GrpDeadSensorHysteresis    ${value}

    #Created by Greeshma on 19 Aug 2021
setConfigAlarmGroupDeadSensorThreshold
    [Arguments]    ${value}
    apiresources.changeCxConfigsTabModuleFieldValues  ALARM    GrpDeadSensorThreshold    ${value}

    #Created by Greeshma on 19 Aug 2021
setTemperatureForAllExceptDeadSensor    #Contain both query and mutation, 25% of the total rack should be made as stale
    [Arguments]    ${tempF}
    log to console    Fetch the number of rack sensors ----------------->
    ${json_dict}    queryToFetchJsonResponseContainingTheRackSensorsFromGroup
    ${total}=    fetchTheNumberOfItemsInDictionary    ${json_dict}    ${racks_in_group}
    log to console  No: of rack sensors is ${total}
    ${stale_sensor_count}=    evaluate    ${total} / 4       #25% of the total rack should be made as stale
    ${live_sensor_count}=    evaluate    ${total} - ${stale_sensor_count}
    ${count}=    convert to integer    ${live_sensor_count}
    log to console    Setting temperature for ${count} Racks except the last ${stale_sensor_count} rack/racks----------------->
    FOR    ${i}    IN RANGE    0    ${count}
        log to console    ${i} Rack Sensor
        ${rack_type1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].type
        ${rack_type2}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].type
        ${oid1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].oid
        ${oid2}     fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].oid
        run keyword if    '${rack_type1}'=='CBot'    setRackPointSensorTemperature    ${oid1}    ${tempF}
        run keyword if    '${rack_type2}'=='CTop'     setRackPointSensorTemperature    ${oid2}    ${tempF}
    END
    log to console    ******************************Temperature set for all, except ${stale_sensor_count} rack/racks*********************************

    #Copied from deadSensorGuardResources to apiresources on 20 Aug 2021 by Greeshma
    #Modified on 31 August 2021 by Greeshma to replace checkGroupControlStatusValueNotInGuard and checkGroupControlStausValueInGuard keywords
checkingGuardModeOfGroup
    [Arguments]    ${expected_guard_status}
    ${current_ctrl_status_value}=    queryToFetchControlStatusValueOfGroup
       log to console    *********Validating the Group Ctrl Status is ${expected_guard_status}***********
     IF    '${expected_guard_status}'=='GUARD_ON'    #Checking Group is in guard
        should be equal as integers    ${current_ctrl_status_value}    2    System should be in guard(2)
        log to console    =============Validated Successfully->Group is in Guard -${current_ctrl_status_value}==================
     ELSE                                            #Checking Group is in guard
        should not be equal as integers    ${current_ctrl_status_value}    2    System should not be in guard(2)
        log to console    ==============--Validated Successfully->Status value is ${current_ctrl_status_value}-Not in Guard===================
     END

    #remove below keyword after modifying test2 and test3
checkGroupControlStatusValueNotInGuard
    ${current_ctrl_status_value}=    queryToFetchControlStatusValueOfGroup
    log to console    *********Validating the Ctrl Status is not Guard(expect any other value than 2)******
    should not be equal as integers    ${current_ctrl_status_value}    2    System should not be in guard(2)
    log to console    ==============Status value is ${current_ctrl_status_value}-Not in Guard--Validated Successfully===================

    #remove below keyword after modifying test2 and test3
checkGroupControlStausValueInGuard
    ${current_ctrl_status_value}=    queryToFetchControlStatusValueOfGroup
    should be equal as integers    ${current_ctrl_status_value}    2    System should be in guard(2)
    log to console    =============Validated and the Group is in Guard -${current_ctrl_status_value}==================

    #Created by Greeshma on 20 Aug 2021
setHighAndLowSetPointValues
    [Arguments]    ${ctop_oid}    ${high_value}    ${low_value}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${mutation}=    gqlMutation.setSetPointLimits    ${ctop_oid}  ${high_value}  ${low_value}
    ${body}=          create dictionary    query= ${mutation}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings  ${result.json()}  ${setSetPointLimitsResponse}
    log to console   Limits set for Setpoint on ctop ${ctop_oid} -> high_limit: ${high_value} and low_limit:${low_value}

    #Created by Greeshma on 20 Aug 2021
setAllHighAndLowSetPointLimits
    [Arguments]    ${high_limit}    ${low_limit}
    log to console    Fetch the number of rack sensors ----------------->
    ${json_dict}    queryToFetchJsonResponseContainingTheRackSensorsFromGroup
    ${total}=    fetchTheNumberOfItemsInDictionary    ${json_dict}    ${racks_in_group}
    log to console    Setting SetPoint High and Low Limits for all ${total} Racks----------------->
    FOR    ${i}    IN RANGE    0    ${total}
        ${rack_type2}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].type
        ${oid2}     fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].oid
        ${rack_name}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].displayName
        run keyword if    '${rack_type2}'=='CTop'     setHighAndLowSetPointValues    ${oid2}    ${high_limit}    ${low_limit}
        log to console    ===========-----Done for ${rack_name}---===============
    END
    log to console    ******************************SetPoint Limits are set for all Racks *********************************

    #Created by Greeshma on 20 Aug 2021
checkStatusOfAlarmIsRaised
    [Arguments]    ${alarm_name}
    log to console    !--------Checking for the ${alarm_name} Alarm to be Raised-------!
    ${json_response}=    apiresources.queryToFetchJsonResponseForSpecificAlarmType    ${alarm_name}
    ${no_of_alarms}    apiresources.fetchTheNumberOfItemsInDictionary   ${json_response}    $.data.alarms
    log to console    Total no: of ${alarm_name} is ${no_of_alarms}
    should be equal as integers  ${no_of_alarms}  1
    log to console    =================${alarm_name} Alarm raised=======================

    #Created by Greeshma on 20 Aug 2021
checkStatusOfAlarmIsCleared
    [Arguments]    ${alarm_name}
    log to console    !--------Checking for the ${alarm_name} Alarm to be Cleared-------!
    ${json_response}=    apiresources.queryToFetchJsonResponseForSpecificAlarmType    ${alarm_name}
    ${actual_value}    apiresources.fetchValueOfFieldFromJsonDictionary   ${json_response}  $.data
    should be equal as strings   ${actual_value}  None
    log to console    ===============${alarm_name} Alarm Cleared====================

    #Created by Greeshma on 20 Aug 2021
checkingAlarmStatusForGroup
    [Arguments]    ${alarm_name}    ${exepected_alarm_status}
    IF  '${exepected_alarm_status}'=='ALARM_ON'
        apiresources.checkStatusOfAlarmIsRaised    ${alarm_name}
    ELSE
        apiresources.checkStatusOfAlarmIsCleared    ${alarm_name}
    END

    #Created by Greeshma on 23 Aug 2021
checkForAHUToBeInGuardAtRegularIntervalUntilExpectedNoOfAHUsIntoGuard
    [Arguments]    ${ahus_to_be_on}   ${num_guard_units_val}    ${num_minutes_guard_timer_val}
    log to console    <----Validation on the->${num_guard_units_val} AHUs going into guard at every->${num_minutes_guard_timer_val}minutes----->
    FOR    ${reps}  IN RANGE    1    5
        log to console    XX----------Entering--${reps}-Cycle of Checking AHUs in Guard----------------XX
        ${json_dictionary}=     queryToFetchJsonResponseContaingTheCurrentAHUStatus
        IF    "${reps}"=="1"
            ${total_no_ahus}=    fetchTheNumberOfItemsInDictionary    ${json_dictionary}    ${ahus_list_path}
            log to console    !---Total Number of Ahus is ${total_no_ahus}------!
#            ${ahus_to_be_on}=    evaluate    4 * 1
            log to console    !!----We need to wait until ${ahus_to_be_on} AHUs are in Guard-----!!
        END
        ${expected_ahus_in_guard}=    evaluate    ${num_guard_units_val} * ${reps}
        log to console    LL------We Expect ${expected_ahus_in_guard} to be in guard now---LL
        IF    ${total_no_ahus} >= ${expected_ahus_in_guard}
            ${current_ahus_in_guard}=    fetchNumberOfAHUsWithGuardON    ${total_no_ahus}    ${json_dictionary}
            log to console    !!-----===============Currently ${current_ahus_in_guard} ahus in Guard============----!!
            should be equal as integers    ${current_ahus_in_guard}    ${expected_ahus_in_guard}
            log to console    *******Validation passed for the expected AHU count into Guard for the current cycle********
            exit for loop if    ${current_ahus_in_guard}==${ahus_to_be_on}
            waitForMinutes    ${num_minutes_guard_timer_val}
        ELSE
            log to console    Sufficient AHUs are not present to cool the system
            should be true    ${total_no_ahus} >= ${expected_ahus_in_guard}     #need to check failure scenario
        END
    END
    log to console    *********============================================*******

    #Created by Greeshma on 23 Aug 2021
setConfigAllowNumExceedencesGuard
    [Arguments]    ${value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM    AllowNumExceedencesGuard    ${value}

    #Created by Greeshma on 23 Aug 2021
setConfigNumGuardUnits
    [Arguments]    ${value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM    NumGuardUnits    ${value}

    #Created by Greeshma on 23 Aug 2021
setConfigNumMinutesGuardTimer
    [Arguments]    ${value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM    NumMinutesGuardTimer    ${value}

    #Created by Greeshma on 23 Aug 2021
setAllowNumExceedencesGuardOfGroupProperties
    [Arguments]    ${property_value}
    apiresources.changeGroupPropertiesParameterValue    AllowNumExceedencesGuard  int   ${property_value}

    #Created by Greeshma on 23 Aug 2021
changeGroupPropertiesParameterValue
    [Arguments]    ${property_name}  ${property_type}  ${property_value}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${mutation}=    gqlMutation.setGroupPropertymutation    ${property_name}    ${property_type}    ${property_value}
    ${body}=          create dictionary    query= ${mutation}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings  ${result.json()}  ${propertyWriteResponse}
    log to console  !!------------------Group ->Propertie ${property_name} updated successfully with ${property_value}----------------!!

    #Created by Greeshma on 30 August 2021
setCoolingTemperatureForAllSensorPoints
    [Arguments]    ${temp}
    apiresources.setRackSensorPointsTemperature  ${temp}
    common.setFlagValue    ${current_temp_to_all_flag}


    #Created by Greeshma on 30 August 2021
stopUpdatingTemperatureToLastRack
    [Arguments]    ${temp}
    common.setFlagValue    ${exclude_dead_rack_flag}
    apiresources.setTemperatureForAllExceptDeadSensor    ${temp}

    #Created by Greeshma on 31 August 2021
queryToFetchControlStatusValueOfGroup
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${query_api_token}
    ${query}=  gqlMutation.getCtrlStateValueQuery  ${group_name}
    ${body}=          create dictionary    query= ${query}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    @{ctrl_state_value}    get value from json    ${result.json()}    ${trends_groupStatus_controlStatus_value_path}
    ${value}    get from list    ${ctrl_state_value}    0
    return from keyword    ${value}

    #Created by Abhijit on 26 Aug 2021
changeGroupPropertiesIntValue
    [Arguments]    ${property_name}  ${property_value}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${mutation}=    gqlMutation.setGroupPropertyInt    ${property_name}  ${property_value}
    ${body}=          create dictionary    query= ${mutation}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings  ${result.json()}  ${propertyWriteResponse}
    log to console  !!------------------Group ->Propertie ${property_name} updated successfully with ${property_value}----------------!!
