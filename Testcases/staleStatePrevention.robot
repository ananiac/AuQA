*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Resource    ../Resources/apiresources.robot
#Variables    ../Resources/ResourceVariables/globalVariables.py
Variables    ../Inputs/basicHotAbsoluteGuardInputs.py

*** Variables ***


*** Test Cases ***
StaleStatePreventionForTemperatureSensors
    #apiresources.setRackSensorPointsTemperature    ${sensor_point_cooling_temp}
    #log    Intial flag value is ${flag}
    apiresources.waitForTwoMinutes
    apiresources.setRackSensorPointsTemperature    ${sensor_point_cooling_temp}
    apiresources.waitForTwoMinutes
    FOR    ${i}    IN RANGE    0    7
        #apiresources.setRackSensorPointsTemperature    ${sensor_point_cooling_temp}
        apiresources.setTwoSetOfSensorTemperatureForRack    ${sensor_point_hot_temp}    ${sensor_point_cooling_temp}
        apiresources.waitForOneMinute
    END
improvedStatleStateprevention
    ${current_temperature}=    apiresources.getCurrentTemperatureOfSensorsAandB
    IF    ${current_temperature}==${sensor_point_cooling_temp}
        apiresources.setRackSensorPointsTemperature    ${sensor_point_cooling_temp}
    ELSE IF    ${current_temperature}==${sensor_point_hot_temp}
        apiresources.setTwoSetOfSensorTemperatureForRack    ${sensor_point_hot_temp}    ${sensor_point_cooling_temp}






