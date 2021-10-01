*** Settings ***
Variables    ${EXECDIR}/Configurations/${environment}.py
Resource    ${EXECDIR}/Resources/apiresources.robot


*** Variables ***


*** Keywords ***
# Query setGroupProperties_GuardHotAbsTemp_AlmHotAbsTemp_AllowNumExceedencesGuard_AllowNumExceedencesControl
setGrpPropMutation
    [Arguments]    ${allow_num_excd_ctrl}    ${allow_num_excd_guard}    ${alm_hot_abs_temp}    ${guard_hot_abs_temp}
    ${group_oid}=  apiresources.queryToFetchGroupOid
    ${mutation}=  set variable  mutation setGrpProp { propertyWrite(requests: [{oid: ${group_oid}, name: "AllowNumExceedencesGuard", int: ${allow_num_excd_guard}},{oid: ${group_oid}, name: "AllowNumExceedencesControl", int: ${allow_num_excd_ctrl}},{oid: ${group_oid}, name: "GuardHotAbsTemp", float: ${guard_hot_abs_temp}},{oid: ${group_oid}, name: "AlmHotAbsTemp", float: ${alm_hot_abs_temp}}]) { index reason }}
    return from keyword    ${mutation}

# Query queryToFetchJsonResponseContaingTheCurrentAHUStatus
getAHUStatusInGroupQuery
    [Arguments]    ${group_name}
    ${getAHUStatusInGroup}=  set variable  query getAHUStatusInGroup {site {groups : children(selector:{type: Group,name:"${group_name}"}) {oid type displayName ahus: children(selector:{type: AHU}) {oid type displayName name controls: search(selector: {target: CONTROL}, pruneDepth: false){oid type displayName name status:targetStatus(target: CONTROL) {origin}}}}}}
    return from keyword  ${getAHUStatusInGroup}

# Query queryToFetchControlStatusValueOfGroup
getCtrlStateValueQuery
    [Arguments]    ${group_name}
    ${getCtrlStateValue}=  set variable  query getCtrlStateValue{site {groups: children(selector:{type: Group, name: "${group_name}"}) {children(selector:{type: GroupStatus, name: "Group Status"}){children(selector:{type: State, name: "CtrlState"}){name pointCurrent{value}}}}}}
    return from keyword  ${getCtrlStateValue}

# Query queryToFetchJsonResponseContainingTheRackSensorsFromGroup
getRackSensorPointsOfGroupQuery
    [Arguments]    ${group_name}
    ${query}=  set variable  query rackSensorPoints {site {groups: children(selector: {type: Group,name: "${group_name}"}) @skip(if:false) {oid name racks: children(selector:{type: Rack},){oid displayName points: children{oid name type pointCurrent{value}}}}}}
    return from keyword    ${query}

# Query queryToFetchJsonResponseForSpecificAlarmType
# Created by Greeshma on 19 Aug 2021
getAlarmStatusQuery
    [Arguments]   ${group_name}    ${alarm_name}
    ${getAlarmStatusOfGroupQuery}=  set variable  query alarmStatus{ alarms(selector:{subjectName: "${group_name}", type : ${alarm_name}}) { type severity status }}
    return from keyword  ${getAlarmStatusOfGroupQuery}
