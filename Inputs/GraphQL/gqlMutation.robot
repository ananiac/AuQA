*** Settings ***
Variables    ${EXECDIR}/Configurations/${environment}.py
Resource    ${EXECDIR}/Resources/apiresources.robot


*** Variables ***


*** Keywords ***
setGrpPropMutation
    [Arguments]    ${allow_num_excd_ctrl}    ${allow_num_excd_guard}    ${alm_hot_abs_temp}    ${guard_hot_abs_temp}
    ${group_oid}=  apiresources.queryToFetchGroupOid
    ${mutation}=  set variable  mutation setGrpProp { propertyWrite(requests: [{oid: ${group_oid}, name: "AllowNumExceedencesGuard", int: ${allow_num_excd_guard}},{oid: ${group_oid}, name: "AllowNumExceedencesControl", int: ${allow_num_excd_ctrl}},{oid: ${group_oid}, name: "GuardHotAbsTemp", float: ${guard_hot_abs_temp}},{oid: ${group_oid}, name: "AlmHotAbsTemp", float: ${alm_hot_abs_temp}}]) { index reason }}
    return from keyword    ${mutation}

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

getAHUStatusInGroupQuery
    [Arguments]    ${group_name}
    ${getAHUStatusInGroup}=  set variable  query getAHUStatusInGroup {site {groups : children(selector:{type: Group,name:"${group_name}"}) {oid type displayName ahus: children(selector:{type: AHU}) {oid type displayName name controls: search(selector: {target: CONTROL}, pruneDepth: false){oid type displayName name status:targetStatus(target: CONTROL) {origin}}}}}}
    return from keyword  ${getAHUStatusInGroup}

getCtrlStateValueQuery
    [Arguments]    ${group_name}
    ${getCtrlStateValue}=  set variable  query getCtrlStateValue{site {groups: children(selector:{type: Group, name: "${group_name}"}) {children(selector:{type: GroupStatus, name: "Group Status"}){children(selector:{type: State, name: "CtrlState"}){name pointCurrent{value}}}}}}
    return from keyword  ${getCtrlStateValue}

getRackSensorPointsOfGroupQuery
    [Arguments]    ${group_name}
    ${query}=  set variable  query rackSensorPoints {site {groups: children(selector: {type: Group,name: "${group_name}"}) @skip(if:false) {oid name racks: children(selector:{type: Rack},){oid displayName points: children{oid name type pointCurrent{value}}}}}}
    return from keyword    ${query}

getResponseOidQuery
    [Arguments]    ${oid}
    ${getResponseOid}=  set variable  query getAHUStatusInGroup {site {groups : children(selector:{type: Group,oid:${oid}}) {oid type displayName ahus: children(selector:{type: AHU}) {oid type displayName name controls: search(selector: {target: CONTROL}, pruneDepth: false){oid type displayName name status:targetStatus(target: CONTROL) {origin}}}}}}
    return from keyword  ${getResponseOid}

getOidQuery
    [Arguments]    ${group_name}
    ${group_oid_query}=  set variable  query getGroupOid{site{groups: children(selector: {type: Group,name: "${group_name}"}){oid}}}
    return from keyword  ${group_oid_query}

    #Created by Greeshma on 19 Aug 2021
getAlarmStatusQuery
    [Arguments]   ${group_name}    ${alarm_name}
    ${getAlarmStatusOfGroupQuery}=  set variable  query alarmStatus{ alarms(selector:{subjectName: "${group_name}", type : ${alarm_name}}) { type severity status }}
    return from keyword  ${getAlarmStatusOfGroupQuery}

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