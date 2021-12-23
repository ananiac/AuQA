*** Settings ***
Variables    ${EXECDIR}/Configurations/${environment}.py
Resource    ${EXECDIR}/Resources/apiresources.robot


*** Variables ***


*** Keywords ***
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
    #Created by Greeshma on 19 Aug 2021
    #Updated on 22Dec to add message in the query.
    #component_name can be group name or the ahu name
getAlarmStatusQuery
    [Arguments]   ${component_name}    ${alarm_name}
    ${getAlarmStatusOfGroupQuery}=  set variable  query alarmStatus{ alarms(selector:{subjectName: "${component_name}", type : ${alarm_name}}) { type severity status message }}
    return from keyword  ${getAlarmStatusOfGroupQuery}

# Query queryToFetchJsonResponseContainingTheCoolEffortEstimateOfAHUs
    #Created by Abhijit
getCoolEstimateEffortsQuery
    [Arguments]     ${group_name}
    ${coolEstimateEffortsQuery}=  set variable  query getCoolEstimateEffortOfAHUS {site {groups:children(selector:{type:Group,name:"${group_name}"}) {oid type displayName ahus:children(selector:{type:AHU}) {name CoolEffort:children(selector:{type:CoolEffort}){name point:pointCurrent(unit:percent100){value}}}}}}
    return from keyword    ${coolEstimateEffortsQuery}

getOidQuery
    [Arguments]    ${group_name}
    ${group_oid_query}=  set variable  query getGroupOid{site{groups: children(selector: {type: Group,name: "${group_name}"}){oid}}}
    return from keyword  ${group_oid_query}

    #Created by Greeshma on 13 Oct 2021.This query is to retrieve details-name,oid,type of any component(rack,ahu)of the control group
getComponentDetailsUsingName
    [Arguments]    ${group_name}    ${component_name}
    ${query}=  set variable  query getComponentDetailsUsingName{site{group:children(selector:{type:Group,name:"${group_name}"}){ oid name component:children(selector:{name:"${component_name}"}){ oid name type }}}}
    return from keyword  ${query}

    #Created by Greeshma on 25 Oct 2021. This query returns the details of override such as value,origin,status and also the current value of each control getracksensorpointsofgroupquery
getOverrideDetailsOfAHUsInGroup
    [Arguments]    ${group_name}
    ${query}=    set variable    query overrideGet {site {groups: children(selector: {type: Group,name:"${group_name}"}) {oid name ahus: children(selector: {type: AHU}) {oid name controls: search(selector: {target: CONTROL}) {oid type name point:pointCurrent(unit:percent100){ value } targetStatus(target: CONTROL,unit:percent100) {requests {status origin priority value unit}}}}}}}
    return from keyword  ${query}

    #Created by Greeshma on 28 Oct 2021
getSpecificSensorPointsOfGroupQuery
    [Arguments]    ${group_name}    ${type}
    ${query}=  set variable  query getSpecificSensorPointDetails{site {name groups: children(selector: {type: Group,name:"${group_name}"}) { name sensors: search(selector: {types: [${type}]}, maxResults: 9999) { name type oid pathName(details: true) pointCurrent(units:[degF,kWe]) { unit value tstamp }}}}}
    return from keyword    ${query}

    #Created by Greeshma on 08 Dec 2021
getAHUsPropertiesOfSpecificGroup
    [Arguments]    ${group_name}
    ${query}=  set variable  query getGroupsAHUProperties{site{groups: children(selector: {type: Group, name: "General-test"}){name ahus:children(selector: {type: AHU}){ name CoolSource: propString(name: "CoolSource") DesignCapacity: propFloat(name: "DesignCapacity") DesignCop: propFloat(name: "DesignCop")}}}}
    return from keyword    ${query}

#========Queries related to Alarm testcases
getAHUsInMismatchState
    ${query}=   set variable   query AHUMismatchInGroup {site{groups: children(selector: {type: Group, name: "${group_name}"}){nameahus:children(selector: {type: AHU}){name pointCurrent: children(selector: {name: "SyncFaultStatus"}){type name pathName SyncFaultStatus:pointCurrent{value}}}}}}
    return from keyword    ${query}

getAHUStateofAhuInGroup
    [Arguments]    ${group_oid}
    ${query}=   set variable   query getAHUStateofAhuInGroup { site { groups: children(selector: {type: Group, oid: ${group_oid}}) { ahus: children(selector: {type: AHU}) { AHUState: prop(name: "AhuState") { name string }}}}}
    return from keyword    ${query}