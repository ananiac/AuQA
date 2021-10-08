*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library    OperatingSystem
Library  pabot.PabotLib
Variables    ${EXECDIR}/Configurations/${environment}.py
Variables    ${EXECDIR}/Inputs/testInputs.robot
Library    ${EXECDIR}/ExternalKeywords/common.py
Library    DateTime

*** Variables ***
${type_of_file}  png
${flag}    0

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

setFlagValue
    [Arguments]    ${flag_value}
#    log to console    Setting flag value to ${flag_value}!!!
    ${newflag}=    evaluate   ${flag_value}*1
    set parallel value for key    ${flag}    ${newflag}

getFlagValue
    ${current_flag_value}=    get parallel value for key    ${flag}
#    log to console    Getting current flag value:${current_flag_value}
    return from keyword    ${current_flag_value}

takeScreenshot
    [Arguments]  ${filename}
    ${current_date_time}=  getCurrentDateTime
    set global variable  ${screenshot_directory_path}  ${EXECDIR}/Reports/Screenshots/${SUITE_NAME}
    set screenshot directory  ${screenshot_directory_path}
    capture page screenshot  ${filename} ${current_date_time}.${type_of_file}

getCurrentDateTime
  ${get_current_date_time}=  get current date  result_format=%Y%m%d %H%M%S
  [Return]     ${get_current_date_time}

moveReports
    ${foldername}=  	Get Current Date  result_format=%Y-%m-%d-%H-%M-%S
    ${foldernamestr}=  convert to string  ${foldername}
    log to console  folder ${foldernamestr} created under testReports
    copy directory  ${EXECDIR}/Reports   /home/fc/automation/testReports/${foldernamestr}/
    log to console  folder /home/fc/automation/testReports/${foldernamestr}/

clearReports
    remove directory  ${EXECDIR}/Reports/pabot_results  recursive
    remove directory  ${EXECDIR}/Reports/Screenshots  recursive
    remove files  ${EXECDIR}/Reports/*.html
    remove files  ${EXECDIR}/Reports/*.xml
    remove files  ${EXECDIR}/Reports/*.txt
