*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Resource    ${EXECDIR}/Resources/apiresources.robot
Variables    ${EXECDIR}/Resources/ResourceVariables/globalVariables.py
Variables    ${EXECDIR}/Inputs/basicHotAbsoluteGuardInputs.py

*** Variables ***


*** Test Cases ***
StaleStatePreventionForSensors
    apiresources.setRackSensorPointsTemperature    ${test_entry_sensor_temp}
    ${current_time}=    get current date    result_format=%H:%M:%S
    log to console    ${current_time}
    ${stop_time}=    add time to time    ${current_time}    ${duration_of_test}    timer  exclude_millis=yes
    log to console    ${stop_time}
    FOR    ${i}    IN RANGE    0    9999
        writeTemperatureToSensors
        ${time_left}=    timeRemainingToFinishTest    ${stop_time}
        #Checking for exit criteria
        IF    ${time_left} < 1
            ${t}    get current date    result_format=%H:%M:%S
            log to console    exit time ${t}
            exit for loop
        ELSE IF  '${current_temperature}'=='${test_exit_sensor_temp}'
            log to console    Stale state prevention program exit- Exit temperature ${test_exit_sensor_temp} detected
            exit for loop
        END
        #IF end - Checking for exit criteria
        common.waitForMinutes    1
    END


*** Keywords ***

writeTemperatureToSensors
    ${current_temperature}=    apiresources.getCurrentTemperatureOfSensorsAandB
    set test variable  ${current_temperature}
    IF    ${current_temperature}==${sensor_point_cooling_temp}
        apiresources.setRackSensorPointsTemperature    ${sensor_point_cooling_temp}
    ELSE IF    ${current_temperature}==${sensor_point_hot_temp}
        apiresources.setTwoSetOfSensorTemperatureForRack    ${sensor_point_hot_temp}    ${sensor_point_cooling_temp}
    ELSE
        log to console    Waiting for temperature changes   #Dependancy for exit criteria
    END

timeRemainingToFinishTest
    [Arguments]    ${stop_time}
    ${current_time}=    get current date    result_format=%H:%M:%S
    ${time_left_in_loop}    subtract time from time    ${stop_time}    ${current_time}    timer  exclude_millis=yes
    log to console    ${time_left_in_loop}
    ${time}    convert time    ${time_left_in_loop}
    ${time_int}    convert to integer    ${time}
    log to console    ${time_int}
    return from keyword    ${time_int}






