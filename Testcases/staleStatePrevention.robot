*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/apiresources.robot
Variables    ${EXECDIR}/Resources/ResourceVariables/globalVariables.py
Variables    ${EXECDIR}/Inputs/basicHotAbsoluteGuardInputs.py

*** Variables ***

*** Test Cases ***
StaleStatePreventionForSensors
    common.waitForMinutes  1
    ${current_time}=    get current date
    log to console    !----Stale prevention-Writing to Sensors started at -->${current_time} ----!
    FOR    ${i}    IN RANGE    0    9999
        writeTemperatureToSensors
        common.waitForMinutes    1
    END


*** Keywords ***
writeTemperatureToSensors
    ${current_temperature}=    apiresources.getCurrentTemperatureOfSensorsAandB
    IF    ${current_temperature}==${sensor_point_cooling_temp}                  #BasicHotAbsoluteGuardTest
        apiresources.setRackSensorPointsTemperature    ${sensor_point_cooling_temp}
    ELSE IF    ${current_temperature}==${sensor_point_hot_temp}                 #BasicHotAbsoluteGuardTest
        apiresources.setTwoSetOfSensorTemperatureForRack    ${sensor_point_hot_temp}    ${sensor_point_cooling_temp}
    ELSE IF  '${current_temperature}'=='${test_exit_sensor_temp}'                #Tear down
        ${current_time}  get current date
        log to console    Stale state prevention program exit- Exit temperature ${test_exit_sensor_temp} detected
        log to console   Stale state prevention program stopped at ${current_time}
        exit for loop
    ELSE                                                                #Setup where application is getting ready for test
        log to console    Waiting for temperature changes
    END





