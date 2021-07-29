*** Settings ***
Variables    ${EXECDIR}/Inputs/basicHotAbsoluteGuardInputs.py
Resource    ${EXECDIR}/Resources/apiresources.robot

*** Variables ***


*** Keywords ***
setGrpPropMutation
    [Arguments]    ${allow_num_excd_ctrl}    ${allow_num_excd_guard}    ${alm_hot_abs_temp}    ${guard_hot_abs_temp}
    ${setGrpProp}=  set variable  mutation setGrpProp { propertyWrite(requests: [{oid: ${responseOid}, name: "AllowNumExceedencesGuard", int: ${allow_num_excd_guard}},{oid: ${responseOid}, name: "AllowNumExceedencesControl", int: ${allow_num_excd_ctrl}},{oid: ${responseOid}, name: "GuardHotAbsTemp", float: ${guard_hot_abs_temp}},{oid: ${responseOid}, name: "AlmHotAbsTemp", float: ${alm_hot_abs_temp}}]) { index reason }}
    set global variable  ${setGrpProp}

configWriteMutation
    [Arguments]    ${module_name}    ${field_name}    ${value}
    ${configWrite}=  set variable  mutation configWrite { configSet(requests: [{module: "${module_name}", name: "${field_name}", value: "${value}"}]) { index reason }}
    set global variable  ${configWrite}

pointWriteMutation
    [Arguments]    ${oid}    ${temp}
    ${pointWrite}=  set variable  mutation pointWrite { pointWrite(requests: [{oid: ${oid}, value: ${temp}}]) { index reason }}
    set global variable  ${pointWrite}

getAHUStatusInGroupQuery
    [Arguments]    ${group_name}
    ${getAHUStatusInGroup}=  set variable  query getAHUStatusInGroupGRP00 {site {groups : children(selector:{type: Group,name:"${group_name}"}) {oid type displayName ahus: children(selector:{type: AHU}) {oid type displayName name controls: search(selector: {target: CONTROL}, pruneDepth: false){oid type displayName name status:targetStatus(target: CONTROL) {origin}}}}}}
    set global variable  ${getAHUStatusInGroup}

getCtrlStateValueQuery
    [Arguments]    ${group_name}
    ${getCtrlStateValue}=  set variable  query getCtrlStateValue{site {groups: children(selector:{type: Group, name: "${group_name}"}) {children(selector:{type: GroupStatus, name: "Group Status"}){children(selector:{type: State, name: "CtrlState"}){name pointCurrent{value}}}}}}
    set global variable  ${getCtrlStateValue}

rackSensorPointsMutation
    [Arguments]    ${group_name}
    ${rackSensorPoints}=  set variable  query rackSensorPoints {site {groups: children(selector: {type: Group,name: "${group_name}"}) @skip(if:false) {oid name racks: children(selector:{type: Rack},){oid displayName points: children{oid name type pointCurrent{value}}}}}}
    set global variable  ${rackSensorPoints}

getOidQuery
    [Arguments]    ${group_name}
    ${groupNameOid}=  set variable  query getGroupOid{site{groups: children(selector: {type: Group,name: "${group_name}"}){oid}}}
    set global variable  ${groupNameOid}