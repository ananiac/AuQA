*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library    OperatingSystem
Variables    ../Configurations/config.py

*** Variables ***


*** Keywords ***
checkResponseStatusCode
        [Arguments]    ${statusCode}
        ${status_code}=     convert to string   ${statusCode} #status code extraction from response
        should be equal as strings   ${status_code}      200