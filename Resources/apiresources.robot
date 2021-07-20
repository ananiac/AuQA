*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library    OperatingSystem
Library    DateTime
Variables    ${EXECDIR}/Configurations/config.py
Variables    ${EXECDIR}/Resources/ResourceVariables/globalVariables.py
Variables    ${EXECDIR}/JsonPath/basicHotAbsoluteGuardJsonpath.py
Resource    common.robot



*** Variables ***
${base_url}    ${graphql_base_url}
#${increment_counter}=       1
#${current_ahus_in_guard}=    0
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
    ${body}=          create dictionary    query= mutation configWrite { configSet(requests: [{module: "${module_name}", name: "${field_name}", value: "${value}"}]) { index reason }}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings    ${result.status_code}    200
    log to console    Config module :${module_name}->Field:${field_name}->Value:${value}-is updated

setGroupPropertiesGuardHotAbsTempAllowNumExceedencesGuardAndControl
    #log to console    Set the Group properties values->Grp GRP00->Properties->AllowNumExceedencesGuard = 10 AllowNumExceedencesControl = 10
    #log to console    AlmHotAbsTemp = 200(degree F) GuardHotAbsTemp = 90 (degrees F)---------->
    [Arguments]    ${allow_num_excd_ctrl}    ${allow_num_excd_guard}    ${alm_hot_abs_temp}    ${guard_hot_abs_temp}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${body}=          create dictionary    query= mutation setGrpProp { propertyWrite(requests: [{oid: 17, name: "AllowNumExceedencesGuard", int: ${allow_num_excd_guard}},{oid: 17, name: "AllowNumExceedencesControl", int: ${allow_num_excd_ctrl}},{oid: 17, name: "GuardHotAbsTemp", float: ${guard_hot_abs_temp}},{oid: 17, name: "AlmHotAbsTemp", float: ${alm_hot_abs_temp}}]) { index reason }}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings    ${result.status_code}     200
    #log to console    ${result.json()}
    #sleep    ${medium_speed}

checkGroupControlStatusValueNotInGuard
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${query_api_token}
    ${file}    get binary file    ${EXECDIR}/Inputs/GraphQL/getGroupControlStatusValue.gql
    ${body}=    create dictionary    query= ${file}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    #log to console    ${result.json()}
    @{ctrl_state_value}    get value from json    ${result.json()}    ${trends_groupStatus_controlStatus_value_path}
    ${value}    get from list    ${ctrl_state_value}    0
    log to console    *********Validating the Ctrl Status is not Guard(expect any other value than 2)******
    should not be equal as integers    ${value}    2    System should not be in guard(2)
    log to console    ---------Status value is ${value}-Not in Guard--Validated Successfully------------------------

checkGroupControlStausValueInGuard
    log to console    Checking Group Control Status for the value to be in guard.
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${query_api_token}
    ${file}    get binary file    ${EXECDIR}/Inputs/GraphQL/getGroupControlStatusValue.gql
    ${body}=          create dictionary    query= ${file}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    @{ctrl_state_value}    get value from json    ${result.json()}    ${trends_groupStatus_controlStatus_value_path}
    ${value}    get from list    ${ctrl_state_value}    0
    should be equal as integers    ${value}    2    System should be in guard(2)
    log to console    Validated and the Group is in Guard

setRackPointSensorTemperature
    [Arguments]    ${oid}    ${temp}
    ${headers}=       create dictionary    Content-Type=${content_type}    Vigilent-Api-Token=${write_api_token}
    ${body}=          create dictionary    query= mutation pointWrite { pointWrite(requests: [{oid: ${oid}, value: ${temp}}]) { index reason }}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings    ${result.status_code}    200
    log to console   Temperature ${temp} F set for ${oid}

setRackSensorPointsTemperature    #Contain both query and mutation
    [Arguments]    ${tempF}
    log to console    Fetch the number of rack sensors ----------------->
    ${json_dict}    queryToFetchJsonResponseContainingTheRackSensorsFromGroup
    ${total}=    fetchTheNumberOfItemsInDictionary    ${json_dict}    ${racks_in_group}
    log to console    Setting temperature for all sensor points----------------->
    FOR    ${i}    IN RANGE    0    ${total}
        log to console    ${i} Rack Sensor
        ${rack_type1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].name
        ${rack_type2}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].name
        ${oid1}    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[0].oid
        ${oid2}     fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].racks[${i}].points[1].oid
        run keyword if    '${rack_type1}'!='Humidity Monitor'    setRackPointSensorTemperature    ${oid1}    ${tempF}
        run keyword if    '${rack_type2}'!='Internal Thermistor'     setRackPointSensorTemperature    ${oid2}    ${tempF}
    END
    log to console    ******************************Temperature set for all rack sensors*********************************

queryToFetchJsonResponseContainingTheRackSensorsFromGroup
    ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${query_api_token}
    ${file}    get binary file    ${EXECDIR}/Inputs/GraphQL/getRackPoints.gql
    ${body}=          create dictionary    query= ${file}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings    ${result.status_code}     200
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
    #${time_at_sensor_is_100F}    get current date
    #log to console    ${time_at_sensor_is_100F}

getCurrentTemperatureOfSensorsAandB
    ${json_dict}    queryToFetchJsonResponseContainingTheRackSensorsFromGroup
    #First two sensor points are picked as Sensor A and Sensor B if they are Rack Top or Rack Bottom
    ${total}=    fetchTheNumberOfItemsInDictionary    ${json_dict}    ${racks_in_group}
    log to console    Getting temperature of Sensor A----------------->
    FOR    ${i}    IN RANGE    0    ${total}
        #log to console    ${i} Rack Sensor
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
    #log to console    ---find number of Items in Dictionary for JSonpath ${json_of_required_node}----
    @{points}    get value from json    ${dictionary}    ${json_of_required_node}
    ${total_points_to_write}    get length   @{points}
    ${total}=    convert to integer    ${total_points_to_write}
    #log to console      ${total}
    return from keyword    ${total}

fetchValueOfFieldFromJsonDictionary
    [Arguments]    ${json_dictionary}     ${json_path_of_required_field}
    ${field_value_list}    get value from json    ${json_dictionary}    ${json_path_of_required_field}
    ${field_value}    get from list    ${field_value_list}    0
    return from keyword    ${field_value}

checkForAHUToBeInGuardAtRegularIntervalUntilFourAHUsReached
    [Arguments]    ${num_guard_units_val}    ${num_minutes_guard_timer_val}
    log to console    <----Validation on the AHUs going on guard at regular interval----->
    FOR    ${reps}  IN RANGE    1    5
        log to console    XX----------Entering--${reps}-Cycle of Checking AHUs in Guard----------------XX
        ${json_dictionary}=     queryToFetchJsonResponseContaingTheCurrentAHUStatus
        IF    "${reps}"=="1"
            ${total_no_ahus}=    fetchTheNumberOfItemsInDictionary    ${json_dictionary}    ${ahus_list_path}
            log to console    !---Total Number of Ahus is ${total_no_ahus}------!
            ${ahus_to_be_on}=    evaluate    ${num_guard_units_val} * 4
            log to console    !!----We need to wait until ${ahus_to_be_on} AHUs are in Guard-----!!
        END
        ${expected_ahus_in_guard}=    evaluate    ${num_guard_units_val} * ${reps}
        log to console    LL------We Expect ${expected_ahus_in_guard} to be in guard now---LL
        IF    ${total_no_ahus} >= ${expected_ahus_in_guard}
            ${current_ahus_in_guard}=    fetchNumberOfAHUsWithGuardON    ${total_no_ahus}    ${json_dictionary}
            log to console    !!-----Currently ${current_ahus_in_guard} ahus in Guard----!!
            should be equal as integers    ${current_ahus_in_guard}    ${expected_ahus_in_guard}
            exit for loop if    ${current_ahus_in_guard}==${ahus_to_be_on}
            waitForMinutes    ${num_minutes_guard_timer_val}
        ELSE
            log to console    Sufficient AHUs are not present to cool the system
            should be true    ${total_no_ahus} >= ${expected_ahus_in_guard}     #need to check failure scenario
        END
    END
    #run keyword if    ${total_no_ahus}>=
    log to console    *************************************************************

checkForAllAHUsToBeGuardCleared
    log to console    <----Validating AHU Guard is cleared ----->
    ${json_dictionary}=     queryToFetchJsonResponseContaingTheCurrentAHUStatus
    ${total_no_ahus}=    fetchTheNumberOfItemsInDictionary    ${json_dictionary}    ${ahus_list_path}
    confirmStatusOfAHUsNotGuard     ${total_no_ahus}     ${json_dictionary}
    log to console    *************************************************************

queryToFetchJsonResponseContaingTheCurrentAHUStatus
    ${headers}=       create dictionary    Content-Type=${content_type}   Vigilent-Api-Token=${query_api_token}
    ${file}    get binary file    ${EXECDIR}/Inputs/GraphQL/getGroupAHUControlsStatus.gql
    ${body}=          create dictionary    query= ${file}
    create session    AIEngine    ${base_url}     disable_warnings=1
    ${result}=  post on session    AIEngine  /public/graphql  headers=${headers}    json=${body}
    should be equal as strings    ${result.status_code}   200
    ${json_dictionary}=     set variable    ${result.json()}
    return from keyword    ${json_dictionary}

fetchNumberOfAHUsWithGuardON
    [Arguments]    ${total}     ${json_dictionary}
    log to console    !---Intial counter value is ${counter}---!
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

confirmStatusOfAHUs
    [Arguments]    ${total}     ${json_dictionary}    ${expected_status}
    log to console    !---Intial counter value is ${counter}---!
    FOR    ${ahu}   IN RANGE    0    ${total}
                log to console    !!---Checking ahu at position ${ahu}---!!s
                ${no_of_controls}=    fetchTheNumberOfItemsInDictionary    ${json_dictionary}    $.data.site.groups[0].ahus[${ahu}].controls
                log to console    !!!--No of Controls for ${ahu} is ${no_of_controls}---!!!
                ${ahu_status_ctrl_value}     fetchValueOfFieldFromJsonDictionary    ${json_dictionary}    $.data.site.groups[0].ahus[${ahu}].controls[0].status.origin
                log to console    !V-------Status value for AHU:${ahu} first Control is ${ahu_status_ctrl_value}-----!V
                should be equal as strings    ${ahu_status_ctrl_value}    ${expected_status}    AHUS are expected with Status ${expected_status}
                IF    "${no_of_controls}"=="2"
                        ${ahu_status_ctrl_value}     fetchValueOfFieldFromJsonDictionary    ${json_dictionary}    $.data.site.groups[0].ahus[${ahu}].controls[1].status.origin
                        log to console    !V-------Status value for AHU:${ahu} second control is ${ahu_status_ctrl_value}-----!V
                        should be equal as strings    ${ahu_status_ctrl_value}    ${expected_status}    AHUS are expected with Status ${expected_status}
                END
    END

confirmStatusOfAHUsNotGuard
   [Arguments]    ${total}     ${json_dictionary}
    FOR    ${ahu}   IN RANGE    0    ${total}
                log to console    !!---Checking ahu at position ${ahu}---!!s
                ${no_of_controls}=    fetchTheNumberOfItemsInDictionary    ${json_dictionary}    $.data.site.groups[0].ahus[${ahu}].controls
                log to console    !!!--No of Controls for ${ahu} is ${no_of_controls}---!!!
                ${ahu_status_ctrl_value}     fetchValueOfFieldFromJsonDictionary    ${json_dictionary}    $.data.site.groups[0].ahus[${ahu}].controls[0].status.origin
                log to console    !V-------Status value for AHU:${ahu} first Control is ${ahu_status_ctrl_value}-----!V
                should not be equal as strings    ${ahu_status_ctrl_value}    "GUARD"    AHUS are expected with GUARD Cleared
                IF    "${no_of_controls}"=="2"
                        ${ahu_status_ctrl_value}     fetchValueOfFieldFromJsonDictionary    ${json_dictionary}    $.data.site.groups[0].ahus[${ahu}].controls[1].status.origin
                        log to console    !V-------Status value for AHU:${ahu} second control is ${ahu_status_ctrl_value}-----!V
                        should not be equal as strings    ${ahu_status_ctrl_value}    "GUARD"    AHUS are expected with GUARD Cleared
                END
    END
    log to console    *********All AHUS are cleared of GUARD*****************


