*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library    OperatingSystem
Library    DateTime
Variables    ${EXECDIR}/Configurations/${environment}.py
Variables    ${EXECDIR}/JsonPath/basicHotAbsoluteGuardJsonpath.py
Variables    ${EXECDIR}/Inputs/expectedMutationJsonResponses.py
Variables    ${EXECDIR}/Inputs/testInputs.robot
Resource    common.robot
Resource    connection.robot
Resource    ${EXECDIR}/Inputs/GraphQL/gqlMutation.robot
Resource    ${EXECDIR}/Inputs/GraphQL/gqlQueries.robot


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
    apiresources.writeUserEventsEntryToNotificationEventLog    AuQA test->${group_name}->Config->${module_name}->${field_name}=${value}-is updated.

setRackPointSensorTemperature
    [Arguments]    ${oid}    ${temp}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${graphql_mutation}=  gqlMutation.pointWriteMutation    ${oid}    ${temp}
    ${body}=          create dictionary    query= ${graphql_mutation}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings  ${result.json()}  ${pointWriteResponse}
    log to console   Temperature ${temp} F set for ${oid}

setTemperatureForAllRackSensorPoints    #Contain both query and mutation
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
    ${query}=    gqlQueries.getRackSensorPointsOfGroupQuery  ${group_name}
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
    ${query}=  gqlQueries.getAHUStatusInGroupQuery  ${group_name}
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
    ${query}=  gqlQueries.getOidQuery  ${group_name}
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
    apiresources.setTemperatureForAllRackSensorPoints  ${test_entry_sensor_temp}

writeTestEntryTemperatureToSensorsAfterVXServerStarted
    common.setFlagValue    ${test_entry_flag}
    ${current_status_of_vx_server}=  connection.establishConnectionAndCheckVX_ServerProcesseStatus
    log to console  Current status of vx server is ${current_status_of_vx_server}
    IF  '${current_status_of_vx_server}'=='process_up'
        apiresources.setTestEntryTemperatureToSensorPoints
    ELSE
        log to console  !!--------Need to start vx_server and write test_entry_sensor_temp---------------!!
        connection.establishConnectionAndStartRequiredProcesses    vx_server
        apiresources.setTestEntryTemperatureToSensorPoints

    END
    log to console  !!!--------------------Test Setup done------------------------------!!!

setTestExitTemperatureToAllSensorPoints
    common.setFlagValue    ${test_exit_flag}
    log to console  *************Test finished and writing test_exit_sensor_temp ${test_exit_sensor_temp}************
    apiresources.setTemperatureForAllRackSensorPoints  ${test_exit_sensor_temp}
    log to console  !!!--------------------Test Teardown done------------------------------!!!
    connection.killChromeAndChromedriverProcessesAfterTest

    #Created by Greeshma on 19 Aug 2021
queryToFetchJsonResponseForSpecificAlarmType
    [Arguments]    ${alarm_type}
    ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${query_api_token}
    ${query}=  gqlQueries.getAlarmStatusQuery    ${group_name}    ${alarm_type}
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

    #Created by Greeshma on 20 Aug 2021.Modified on 6th Sep 2021
checkingAlarmStatusForGroup
    [Arguments]    ${alarm_name}    ${exepected_alarm_status}
    log to console    !--------Checking for the ${alarm_name} Alarm status to be:${exepected_alarm_status}-------!
    ${json_response}=    apiresources.queryToFetchJsonResponseForSpecificAlarmType    ${alarm_name}
    IF  '${exepected_alarm_status}'=='ALARM_ON'
        ${no_of_alarms}    apiresources.fetchTheNumberOfItemsInDictionary   ${json_response}    $.data.alarms
        should be equal as integers  ${no_of_alarms}  1
        log to console    =================${alarm_name} Alarm raised=======================
    ELSE
        ${actual_value}    apiresources.fetchValueOfFieldFromJsonDictionary   ${json_response}  $.data
        should be equal as strings   ${actual_value}  None
        log to console    ===============${alarm_name} Alarm Cleared====================
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
    apiresources.setTemperatureForAllRackSensorPoints  ${temp}
    common.setFlagValue    ${current_temp_to_all_flag}

    #Created by Greeshma on 30 August 2021
stopUpdatingTemperatureToLastRack
    [Arguments]    ${temp}
    common.setFlagValue    ${exclude_dead_rack_flag}
    apiresources.setTemperatureForAllExceptDeadSensor    ${temp}

    #Created by Greeshma on 31 August 2021
queryToFetchControlStatusValueOfGroup
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${query_api_token}
    ${query}=  gqlQueries.getCtrlStateValueQuery  ${group_name}
    ${body}=          create dictionary    query= ${query}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    @{ctrl_state_value}    get value from json    ${result.json()}    ${trends_groupStatus_controlStatus_value_path}
    ${value}    get from list    ${ctrl_state_value}    0
    return from keyword    ${value}

    #Created by Greeshma and moved to apiresources on 7th Sep 2021
setGroupPropertyFloatValue
    [Arguments]    ${property_name}    ${property_value}
    apiresources.changeGroupPropertiesParameterValue    ${property_name}  float  ${property_value}

    #Created by Greeshma on 13 Sep 2021
writeUserEventsEntryToNotificationEventLog
    [Arguments]    ${message}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${mutation}=    gqlMutation.testEventLogMutation    ${message}
    ${body}=          create dictionary    query= ${mutation}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings  ${result.json()}  ${testEventLogResponse}
    log to console    !---------------VX-->Notification tab->Event-->updated--> ${message}--!

getAHUCount
    ${json_dict}=  apiresources.queryToFetchJsonResponseContaingTheCurrentAHUStatus
    ${total_no_ahus}=    fetchTheNumberOfItemsInDictionary    ${json_dict}    ${ahus_list_path}
    return from keyword    ${total_no_ahus}

    #Mutation for setting BOP value as 'ON' for a AHU
settingBOPValueOfAHU
    [Arguments]    ${ahu_bop_oid}
    ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${write_api_token}
    ${graphql_mutation}=  gqlMutation.setBOPMutation  ${ahu_bop_oid}
    ${body}=          create dictionary    query= ${graphql_mutation}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings  ${result.json()}  ${setSetPointLimitsResponse}
    log to console   !!===========BOP ON->done===========!!

    #Mutation for setting SFC value as 'ON' for an AHU
settingSFCValueOfAHU
    [Arguments]    ${ahu_sfc_oid}  ${oid_sfc_value}
    ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${write_api_token}
    ${graphql_mutation}=  gqlMutation.setSFCMutation  ${ahu_sfc_oid}  ${oid_sfc_value}
    ${body}=          create dictionary    query= ${graphql_mutation}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings  ${result.json()}  ${setSetPointLimitsResponse}
    log to console   !!=======SFC value:${oid_sfc_value} is set=========!!

    #Created by Greeshma on 30 Sep 2021.Set the AHUs into override as per the sfc values provided in the Test input.
overrideAllAHUsWithSFCValuesAsPerList
    [Arguments]    ${test_input}
    &{json_dict}=  apiresources.queryToFetchJsonResponseContaingTheCurrentAHUStatus
    @{group_ahu_name_list}=    apiresources.getAHUNamesListOfGroup
    FOR    ${ahu}    IN    @{group_ahu_name_list}
        ${ahu_bop_oid}=    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].ahus[?(@.name=="${ahu}")].controls[?(@.type=="BOP")].oid
        ${ahu_sfc_oid}=    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].ahus[?(@.name=="${ahu}")].controls[?(@.type=="SFC")].oid
        log to console    !---Overriding AHU:${ahu}->ahu_bop_oid ${ahu_bop_oid}->ahu_sfc_oid ${ahu_sfc_oid}-----!
        settingBOPValueOfAHU    ${ahu_bop_oid}
        settingSFCValueOfAHU    ${ahu_sfc_oid}    ${test_input}[${ahu}]
    END
    log to console    !!*****************==============All AHUs in the list are overridden==================****************!!

    #Created by Greeshma on 27 Sep 2021.
queryToFetchJsonResponseContainingTheCoolEffortEstimateOfAHUs
    ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${query_api_token}
    ${query}=    gqlQueries.getCoolEstimateEffortsQuery  ${group_name}
    ${body}=          create dictionary    query= ${query}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    ${json_dict}=   set variable    ${result.json()}
    return from keyword    ${json_dict}

    #Created by Greeshma on 28 Sep 2021.This keyword returns a dictionary conatining (K=V) ahu_name=cool_effor_estimate_value
getCoolEffortEstimateValuesOfAllAHUs
    ${json_dict}=    queryToFetchJsonResponseContainingTheCoolEffortEstimateOfAHUs
    &{actual_ahu_cool_effort_value_dict}=    create dictionary
    ${ahu_count}    fetchTheNumberOfItemsInDictionary    ${json_dict}    ${ahus_list_path}
    FOR    ${i}    IN RANGE   0    ${ahu_count}
        ${ahu_name}=    fetchValueOfFieldFromJsonDictionary    ${json_dict}  $.data.site.groups[0].ahus[${i}].name
        ${cool_effort_value}=  fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].ahus[${i}].CoolEffort[0].point.value
        set to dictionary  ${actual_ahu_cool_effort_value_dict}    ${ahu_name}    ${cool_effort_value}
    END
    return from keyword    ${actual_ahu_cool_effort_value_dict}

    #Created by Greeshma on 30 Sep 2021.Input is the excel sheet data in dictionary format.
    #Validation of CooleEffortEstimate is done using this keyword
confirmTheCoolEffortEstimateValueIsAsPerSFCValuesSet
   [Arguments]    ${test_input}
   &{actual_ahu_cool_effort_value_dict}=    getCoolEffortEstimateValuesOfAllAHUs
      FOR    ${key}    IN    @{actual_ahu_cool_effort_value_dict.keys()}
        ${expected_cool_effort_value}=    set variable  ${test_input}[${key}]
        ${actual_cool_effort_value}=    set variable    ${actual_ahu_cool_effort_value_dict}[${key}]
        should be equal as strings    ${expected_cool_effort_value}    ${actual_cool_effort_value}    Cool Effort value validation
        log to console    !!-----------Validation passed for AHU:${key}-->Cool Effort value ${actual_ahu_cool_effort_value_dict}[${key}]-------------!!
      END

    #Created by Greeshma on 27 Sep 2021.
getSpecificControlOidListOfAllAHUs
    [Arguments]    ${ctrl_name}
    &{json_dict}=  apiresources.queryToFetchJsonResponseContaingTheCurrentAHUStatus
    ${ahu_count}    fetchTheNumberOfItemsInDictionary    ${json_dict}    ${ahus_list_path}
    @{ctrl_oid_list}    create list
    FOR    ${i}    IN RANGE    0    ${ahu_count}
        ${ahu_ctrl_oid}=    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].ahus[${i}].controls[?(@.type=="${ctrl_name}")].oid
        append to list    ${ctrl_oid_list}    ${ahu_ctrl_oid}
    END
    return from keyword    @{ctrl_oid_list}

    #Created by Greeshma on 27 Sep 2021.
getBOPOidListOfAllAHUs
    @{bop_oid_list}    getSpecificControlOidListOfAllAHUs    BOP
    return from keyword    @{bop_oid_list}

    #Created by Greeshma on 27 Sep 2021.
getSFCOidListOfAllAHUs
    @{sfc_oid_list}    getSpecificControlOidListOfAllAHUs    SFC
    return from keyword    @{sfc_oid_list}

    #Created by Greeshma on 27 Sep 2021.
releaseOverrideOfAllAHUs
    @{bop_oid_list}=    getBOPOidListOfAllAHUs
    @{sfc_oid_list}=     getSFCOidListOfAllAHUs
    @{all_ctrl_oid_list}=    combine lists  ${bop_oid_list}    ${sfc_oid_list}
    ${mutation}=    gqlMutation.releaseOverrideOfAllAHUsMutation  @{all_ctrl_oid_list}
    ${body}=          create dictionary    query= ${mutation}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings  ${result.json()}  ${clearOverRideOfAllAHUsResponse}
    log to console   !!=======*********Override released for All AHUs*******=========!!

    #Created by Greeshma on 28 Sep 2021
fetchAHUNameListOfAHUsWithGuardON
    [Arguments]    ${total}     ${json_dictionary}
    @{guard_ON_AHU_List}    create list
    FOR    ${ahu}   IN RANGE    0    ${total}
                log to console    !!---Checking ahu at position ${ahu}---!!s
                ${ahu_name}=    fetchValueOfFieldFromJsonDictionary    ${json_dictionary}   $.data.site.groups[0].ahus[${ahu}].name
                ${no_of_controls}=    fetchTheNumberOfItemsInDictionary    ${json_dictionary}    $.data.site.groups[0].ahus[${ahu}].controls
                log to console    !!!--No of Controls for ${ahu_name} is ${no_of_controls}---!!!
                FOR    ${controls}  IN RANGE  0   ${no_of_controls}
                    ${ahu_status_ctrl_value}     fetchValueOfFieldFromJsonDictionary    ${json_dictionary}    $.data.site.groups[0].ahus[${ahu}].controls[${controls}].status.origin
                    log to console    !V-------Status value for AHU:${ahu_name} control:${controls} is ${ahu_status_ctrl_value}-----!V
                    IF  "${ahu_status_ctrl_value}"=="GUARD"         #Do we need to check both to be in Guard?
                        IF    ${no_of_controls} > 1
                                FOR    ${remaining_controls}  IN RANGE  1   ${no_of_controls}
                                    ${ahu_status_ctrl_value}     fetchValueOfFieldFromJsonDictionary    ${json_dictionary}    $.data.site.groups[0].ahus[${ahu}].controls[${remaining_controls}].status.origin
                                    log to console    !V-------Status value for AHU:${ahu_name} control:${remaining_controls} is ${ahu_status_ctrl_value}-----!V
                                    should be equal as strings    ${ahu_status_ctrl_value}    GUARD
                                    append to list    ${guard_ON_AHU_List}    ${ahu_name}
                                END
                        ELSE
                                append to list    ${guard_ON_AHU_List}    ${ahu_name}
                        END
                        exit for loop
                    END
                END
    END
    return from keyword    ${guard_ON_AHU_List}

    #Created by Greeshma on 28 Sep 2021. Release override for all AHUs and confirm the Guard is cleared for all.
releaseOverrideOfAllAHUsAndConfirmAHUsAreGuardCleared
    IF    '${group_name}'!='RSP-test'
        apiresources.releaseOverrideOfAllAHUs
    END
    apiresources.checkForAllAHUsToBeGuardCleared

    #Created by Greeshma on 30 September 2021.This keyword returns list of ahu_names belongs to current control group.
getAHUNamesListOfGroup
    &{json_dict}=  apiresources.queryToFetchJsonResponseContaingTheCurrentAHUStatus
    ${ahu_count}    fetchTheNumberOfItemsInDictionary    ${json_dict}    ${ahus_list_path}
    @{ahu_names_list}=    create list
    FOR    ${i}    IN RANGE   0    ${ahu_count}
        ${ahu_name}=    fetchValueOfFieldFromJsonDictionary    ${json_dict}  $.data.site.groups[0].ahus[${i}].name
        append to list    ${ahu_names_list}    ${ahu_name}
    END
    return from keyword    ${ahu_names_list}