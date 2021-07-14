*** Settings ***
Library    RequestsLibrary
Library    JsonLibrary
Resource    ../Resources/apiresources.robot
Variables    ../Inputs/basicHotAbsoluteGuardInputs.py

*** Variables ***


*** Test Cases ***
StaleStatePreventionProgram
    apiresources.setRackSensorPointsTemperature    ${sensor_point_cooling_temp}
