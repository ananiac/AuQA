*** Settings ***
Variables    ${EXECDIR}/Configurations/${environment}.py
Resource    ${EXECDIR}/Resources/apiresources.robot


*** Variables ***


*** Keywords ***
configWriteMutation
    [Arguments]    ${module_name}    ${field_name}    ${value}
    ${configWrite}=  set variable  mutation configWrite { configSet(requests: [{module: "${module_name}", name: "${field_name}", value: "${value}"}]) { index reason }}
    return from keyword  ${configWrite}

pointWriteMutation
    [Arguments]    ${oid}    ${temp}
    ${pointWrite}=  set variable  mutation pointWrite { pointWrite(requests: [{oid: ${oid}, value: ${temp}}]) { index reason }}
    return from keyword  ${pointWrite}

getOidQuery
    [Arguments]    ${group_name}
    ${group_oid_query}=  set variable  query getGroupOid{site{groups: children(selector: {type: Group,name: "${group_name}"}){oid}}}
    return from keyword  ${group_oid_query}

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