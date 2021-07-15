*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library    OperatingSystem
Library    DateTime
Variables    ../Configurations/config.py
Variables    ../ExternalKeywords/common.py


*** Variables ***
# screenshot file exetention
${type_of_file}  png


*** Keywords ***
# Used to name the folder with date and time
getDateTime
    ${date1}=  get current date  result_format=%Y-%m-%d %H-%M-%S
    [Return]  ${date1}

# Take screenshot function which creates Reports/Screenshot folder and add screenshots
takeScreenshot
    [Arguments]  ${filename}
    ${date}=  getDateTime
    set global variable  ${path}  Reports/Screenshots/${date}
    set screenshot directory  ${path}
    wait until page contains  Element
    capture page screenshot  ${filename}.${type_of_file}
    log to console  ${\n}Screenshots

checkResponseStatusCode
    [Arguments]  ${statusCode}
    ${status_code}= convert to string   ${statusCode}   #status code extraction from response
    should be equal as strings  ${status_code}  200

incrementingByOne
    [Arguments]  ${before_val}
    ${value}  incrementByOne  ${before_val}
    return from keyword  ${value}

waitForMinutes
    [Arguments]  ${minutes}
    log to console  !------------Waiting for ${minutes} minutes------------!
    sleep  ${minutes}  minutes
    log to console  !!---------Waiting - Done--------------------!!
