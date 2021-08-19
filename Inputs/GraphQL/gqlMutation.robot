*** Settings ***
Variables    ${EXECDIR}/Configurations/${environment}.py
Resource    ${EXECDIR}/Resources/apiresources.robot


*** Variables ***


*** Keywords ***
setGrpPropMutation
    [Arguments]    ${allow_num_excd_ctrl}    ${allow_num_excd_guard}    ${alm_hot_abs_temp}    ${guard_hot_abs_temp}
    queryToFetchGroupOid
#    log to console  ${group_oid}
#    ${setGrpProp}=  set variable  mutation setGrpProp { propertyWrite(requests: [{oid: 17, name: "AllowNumExceedencesGuard", int: ${allow_num_excd_guard}},{oid: 17, name: "AllowNumExceedencesControl", int: ${allow_num_excd_ctrl}},{oid: 17, name: "GuardHotAbsTemp", float: ${guard_hot_abs_temp}},{oid: 17, name: "AlmHotAbsTemp", float: ${alm_hot_abs_temp}}]) { index reason }}
    ${setGrpProp}=  set variable  mutation setGrpProp { propertyWrite(requests: [{oid: ${group_oid}, name: "AllowNumExceedencesGuard", int: ${allow_num_excd_guard}},{oid: ${group_oid}, name: "AllowNumExceedencesControl", int: ${allow_num_excd_ctrl}},{oid: ${group_oid}, name: "GuardHotAbsTemp", float: ${guard_hot_abs_temp}},{oid: ${group_oid}, name: "AlmHotAbsTemp", float: ${alm_hot_abs_temp}}]) { index reason }}
    set global variable  ${setGrpProp}

configWriteMutation
    [Arguments]    ${module_name}    ${field_name}    ${value}
    ${configWrite}=  set variable  mutation configWrite { configSet(requests: [{module: "${module_name}", name: "${field_name}", value: "${value}"}]) { index reason }}
    set global variable  ${configWrite}

pointWriteMutation
    [Arguments]    ${oid}    ${temp}
    ${pointWrite}=  set variable  mutation pointWrite { pointWrite(requests: [{oid: ${oid}, value: ${temp}}]) { index reason }}
    set global variable  ${pointWrite}

groupNameOidMutation
    [Arguments]    ${group_name}
    ${groupNameOid}=  set variable  query getGroupOid{site{groups: children(selector: {type: Group,name: "${group_name}"}){oid}}}
    set global variable  ${groupNameOid}

getAHUStatusInGroupQuery
    [Arguments]    ${group_name}
    ${getAHUStatusInGroup}=  set variable  query getAHUStatusInGroup {site {groups : children(selector:{type: Group,name:"${group_name}"}) {oid type displayName ahus: children(selector:{type: AHU}) {oid type displayName name controls: search(selector: {target: CONTROL}, pruneDepth: false){oid type displayName name status:targetStatus(target: CONTROL) {origin}}}}}}
    set global variable  ${getAHUStatusInGroup}

getCtrlStateValueQuery
    [Arguments]    ${group_name}
    ${getCtrlStateValue}=  set variable  query getCtrlStateValue{site {groups: children(selector:{type: Group, name: "${group_name}"}) {children(selector:{type: GroupStatus, name: "Group Status"}){children(selector:{type: State, name: "CtrlState"}){name pointCurrent{value}}}}}}
    set global variable  ${getCtrlStateValue}

rackSensorPointsMutation
    [Arguments]    ${group_name}
    ${rackSensorPoints}=  set variable  query rackSensorPoints {site {groups: children(selector: {type: Group,name: "${group_name}"}) @skip(if:false) {oid name racks: children(selector:{type: Rack},){oid displayName points: children{oid name type pointCurrent{value}}}}}}
    set global variable  ${rackSensorPoints}

getResponseOidQuery
    [Arguments]    ${oid}
    ${getResponseOid}=  set variable  query getAHUStatusInGroup {site {groups : children(selector:{type: Group,oid:${oid}}) {oid type displayName ahus: children(selector:{type: AHU}) {oid type displayName name controls: search(selector: {target: CONTROL}, pruneDepth: false){oid type displayName name status:targetStatus(target: CONTROL) {origin}}}}}}
    set global variable  ${getResponseOid}

getOidQuery
    [Arguments]    ${group_name}
    ${group_oid_query}=  set variable  query getGroupOid{site{groups: children(selector: {type: Group,name: "${group_name}"}){oid}}}
    set global variable  ${group_oid_query}

    #Created by Greeshma on 19 Aug 2021
setGroupPropertyFloat
    [Arguments]    ${property_name}    ${property_value}
    queryToFetchGroupOid
    ${setGroupPropertyFloatValueMutation}=    set variable    mutation setGrpProp { propertyWrite(requests: [{oid: ${group_oid}, name: "${property_name}", float : ${property_value}}]) { index reason }}
    set global variable  ${setGroupPropertyFloatValueMutation}

    #Created by Greeshma on 19 Aug 2021
setGroupPropertyInt
    [Arguments]    ${property_name}    ${property_value}
    queryToFetchGroupOid
    ${setGroupPropertyIntValueMutation}=    set variable    mutation setGrpProp { propertyWrite(requests: [{oid: ${group_oid}, name: "${property_name}", int : ${property_value}}]) { index reason }}
    set global variable  ${setGroupPropertyIntValueMutation}

    #Created by Greeshma on 19 Aug 2021
getAlarmStatusQuery
    [Arguments]   ${group_name}    ${alarm_name}
    ${getAlarmStatusOfGroupQuery}=  set variable  query alarmStatus{ alarms(selector:{subjectName: "${group_name}", type : ${alarm_name}}) { type severity status }}
    set global variable  ${getAlarmStatusOfGroupQuery}