*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Resource    ../Resources/apiresources.robot
#Variables    ../Resources/ResourceVariables/globalVariables.py
Variables    ../Inputs/basicHotAbsoluteGuardInputs.py

*** Variables ***


*** Test Cases ***
#StaleStatePreventionForTemperatureSensors
    #apiresources.setRackSensorPointsTemperature    ${sensor_point_cooling_temp}
    #log    Intial flag value is ${flag}
#    apiresources.waitForTwoMinutes
#    apiresources.setRackSensorPointsTemperature    ${sensor_point_cooling_temp}
#    apiresources.waitForTwoMinutes
#    FOR    ${i}    IN RANGE    0    7
#        #apiresources.setRackSensorPointsTemperature    ${sensor_point_cooling_temp}
#        apiresources.setTwoSetOfSensorTemperatureForRack    ${sensor_point_hot_temp}    ${sensor_point_cooling_temp}
#        apiresources.waitForOneMinute
#    END

StaleStatePreventionForSensors
    ${current_time}=    get current date    result_format=%H:%M:%S
    log to console    ${current_time}
    ${stop_time}=    add time to time    ${current_time}    ${duration_of_test}    timer  exclude_millis=yes
    log to console    ${stop_time}
    FOR    ${i}    IN RANGE    0    9999
        writeTemperatureToSensors
        common.waitForMinutes    1
        ${time_left}=    timeRemainingToFinishTest    ${stop_time}
        IF    ${time_left} < 1
            ${t}    get current date    result_format=%H:%M:%S
            log to console    exit time ${t}
            exit for loop
        END
    END


*** Keywords ***

writeTemperatureToSensors
    ${current_temperature}=    apiresources.getCurrentTemperatureOfSensorsAandB
    IF    ${current_temperature}==${sensor_point_cooling_temp}
        apiresources.setRackSensorPointsTemperature    ${sensor_point_cooling_temp}
    ELSE IF    ${current_temperature}==${sensor_point_hot_temp}
        apiresources.setTwoSetOfSensorTemperatureForRack    ${sensor_point_hot_temp}    ${sensor_point_cooling_temp}
    ELSE
        log to console    Waiting for temperature changes
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






