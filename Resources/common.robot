*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library    OperatingSystem
Variables    ${EXECDIR}/Configurations/${environment}.py
Library    ${EXECDIR}/ExternalKeywords/common.py


*** Variables ***


*** Keywords ***
checkResponseStatusCode
        [Arguments]    ${statusCode}
        ${status_code}=     convert to string   ${statusCode} #status code extraction from response
        should be equal as strings   ${status_code}      200

incrementingByOne
    [Arguments]     ${before_val}
    ${value}    incrementByOne    ${before_val}
    return from keyword    ${value}

waitForMinutes
    [Arguments]    ${minutes}
    log to console    !------------Waiting for ${minutes} minutes------------!
    sleep    ${minutes} minutes
    log to console    !!---------Waiting - Done--------------------!!

waitForSeconds
    [Arguments]    ${seconds}
    log to console    !------------Waiting for ${seconds} seconds------------!
    sleep    ${seconds} seconds
    log to console    !!---------Waiting - Done--------------------!!
