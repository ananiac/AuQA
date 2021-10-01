*** Settings ***
Variables    ${EXECDIR}/Configurations/${environment}.py
Resource    ${EXECDIR}/Resources/apiresources.robot


*** Variables ***


*** Keywords ***
#setGrpPropMutation
#    [Arguments]    ${allow_num_excd_ctrl}    ${allow_num_excd_guard}    ${alm_hot_abs_temp}    ${guard_hot_abs_temp}
#    ${group_oid}=  apiresources.queryToFetchGroupOid
#    ${mutation}=  set variable  mutation setGrpProp { propertyWrite(requests: [{oid: ${group_oid}, name: "AllowNumExceedencesGuard", int: ${allow_num_excd_guard}},{oid: ${group_oid}, name: "AllowNumExceedencesControl", int: ${allow_num_excd_ctrl}},{oid: ${group_oid}, name: "GuardHotAbsTemp", float: ${guard_hot_abs_temp}},{oid: ${group_oid}, name: "AlmHotAbsTemp", float: ${alm_hot_abs_temp}}]) { index reason }}
#    return from keyword    ${mutation}

configWriteMutation
    [Arguments]    ${module_name}    ${field_name}    ${value}
    ${configWrite}=  set variable  mutation configWrite { configSet(requests: [{module: "${module_name}", name: "${field_name}", value: "${value}"}]) { index reason }}
    return from keyword  ${configWrite}

pointWriteMutation
    [Arguments]    ${oid}    ${temp}
    ${pointWrite}=  set variable  mutation pointWrite { pointWrite(requests: [{oid: ${oid}, value: ${temp}}]) { index reason }}
    return from keyword  ${pointWrite}

groupNameOidMutation
    [Arguments]    ${group_name}
    ${groupNameOid}=  set variable  query getGroupOid{site{groups: children(selector: {type: Group,name: "${group_name}"}){oid}}}
    return from keyword  ${groupNameOid}

#getAHUStatusInGroupQuery
#    [Arguments]    ${group_name}
#    ${getAHUStatusInGroup}=  set variable  query getAHUStatusInGroup {site {groups : children(selector:{type: Group,name:"${group_name}"}) {oid type displayName ahus: children(selector:{type: AHU}) {oid type displayName name controls: search(selector: {target: CONTROL}, pruneDepth: false){oid type displayName name status:targetStatus(target: CONTROL) {origin}}}}}}
#    return from keyword  ${getAHUStatusInGroup}

#getCtrlStateValueQuery
#    [Arguments]    ${group_name}
#    ${getCtrlStateValue}=  set variable  query getCtrlStateValue{site {groups: children(selector:{type: Group, name: "${group_name}"}) {children(selector:{type: GroupStatus, name: "Group Status"}){children(selector:{type: State, name: "CtrlState"}){name pointCurrent{value}}}}}}
#    return from keyword  ${getCtrlStateValue}

#getRackSensorPointsOfGroupQuery
#    [Arguments]    ${group_name}
#    ${query}=  set variable  query rackSensorPoints {site {groups: children(selector: {type: Group,name: "${group_name}"}) @skip(if:false) {oid name racks: children(selector:{type: Rack},){oid displayName points: children{oid name type pointCurrent{value}}}}}}
#    return from keyword    ${query}

getResponseOidQuery
    [Arguments]    ${oid}
    ${getResponseOid}=  set variable  query getAHUStatusInGroup {site {groups : children(selector:{type: Group,oid:${oid}}) {oid type displayName ahus: children(selector:{type: AHU}) {oid type displayName name controls: search(selector: {target: CONTROL}, pruneDepth: false){oid type displayName name status:targetStatus(target: CONTROL) {origin}}}}}}
    return from keyword  ${getResponseOid}

getOidQuery
    [Arguments]    ${group_name}
    ${group_oid_query}=  set variable  query getGroupOid{site{groups: children(selector: {type: Group,name: "${group_name}"}){oid}}}
    return from keyword  ${group_oid_query}

#    #Created by Greeshma on 19 Aug 2021
#getAlarmStatusQuery
#    [Arguments]   ${group_name}    ${alarm_name}
#    ${getAlarmStatusOfGroupQuery}=  set variable  query alarmStatus{ alarms(selector:{subjectName: "${group_name}", type : ${alarm_name}}) { type severity status }}
#    return from keyword  ${getAlarmStatusOfGroupQuery}

    #Created by Greeshma on 20 Aug 2021
setSetPointLimits
    [Arguments]    ${ctop_oid}    ${high_limit}    ${low_limit}
    ${mutation}=    set variable    mutation targetSetPoints { targetSet(requests: [{oid: ${ctop_oid}, value: ${high_limit}, target: LIMIT_HIGH, origin: "MANUAL"},{oid: ${ctop_oid}, value: ${low_limit}, target: LIMIT_LOW, origin: "MANUAL"}]) { index reason }}
    return from keyword    ${mutation}

setGroupPropertymutation
    [Arguments]    ${property_name}    ${property_type}    ${property_value}
    ${group_oid}=  apiresources.queryToFetchGroupOid
    ${mutation}=    set variable    mutation setGrpProp { propertyWrite(requests: [{oid: ${group_oid}, name: "${property_name}", ${property_type} : ${property_value}}]) { index reason }}
    return from keyword    ${mutation}

    #Created by Greeshma on 13 Sep 2021
testEventLogMutation
    [Arguments]    ${message}
    ${mutation}=    set variable    mutation TestEventLog { eventLog(requests: [{source: "Ideavat AuQA", message: "${message}"}]) { index reason }}
    return from keyword    ${mutation}

    #Created by Abhijit
setSFCMutation
    [Arguments]  ${oid_sfc}  ${oid_sfc_value}
    ${mutationSFC}=    set variable    mutation targetSetSFC {targetSet(requests: [{oid: ${oidSFC}, value: ${oid_sfc_value}, unit: percent100, target: CONTROL, origin: "MANUAL", priority: 70}]) { index reason }}
    return from keyword    ${mutationSFC}

    #Created by Abhijit
setBOPMutation
    [Arguments]  ${oid_bop}
    ${mutationBOP}=    set variable    mutation targetSetBOP {targetSet(requests: [{oid: ${oidBOP}, value: 1, target: CONTROL, origin: "MANUAL", priority: 70}]) { index reason }}
    return from keyword    ${mutationBOP}

    #Created by Greeshma on 27 Sep 2021
releaseOverrideOfAllAHUsMutation
    [Arguments]    @{ahu_ctrl_oid_list}
    ${all_target_set}=    set variable
     FOR  ${oid}  IN  @{ahu_ctrl_oid_list}
        ${target_string}    set variable  {oid: ${oid}, target: CONTROL, origin: "MANUAL"}
        IF    '${all_target_set}'!=''
        ${all_target_set}=    catenate  ${all_target_set}  ,    ${target_string}
        ELSE
        ${all_target_set}=    set variable   ${target_string}
        END
    END
    ${mutation}=    set variable  mutation targetClearOverride {targetClear(requests: [${all_target_set}]) {index reason}}
    return from keyword    ${mutation}

