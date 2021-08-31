*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ../Resources/apiresources.robot
Resource    ../Resources/common.robot
Variables    ${EXECDIR}/Resources/ResourceVariables/globalVariables.py


*** Variables ***
${writing_cycle}    0


*** Test Cases ***
StaleStatePreventionForSensors
    waitForOneMinuteAndPrintCurrentTimeToConsole
    FOR    ${i}    IN RANGE    0    9999
        writeTemperatureToSensors
        common.waitForMinutes    1
    END


*** Keywords ***
    #Created by Greeshma on 30 August 2021
writeTemperatureToSensors
    ${current_temperature}=    apiresources.getCurrentTemperatureOfSensorsAandB
    ${flg}=    common.getFlagValue
    IF  '${flg}'=='${test_entry_flag}'     #Setup where application is getting ready for test
        log to console    Test started.Waiting for temperature changes
    ELSE IF    '${flg}'=='${current_temp_to_all_flag}'      #Writing current temperature to all sensor points
        log to console    Inside Flag Block 2
        apiresources.setRackSensorPointsTemperature    ${current_temperature}
        writingCycleCalculation
    ELSE IF    '${flg}'=='${two_sets_of_temp_flag}'                 #Writing two sets of temperature.First two sensor points with current temperature and remaining with cooling temperature
        log to console    Inside Flag Block 3
        apiresources.setTwoSetOfSensorTemperatureForRack    ${current_temperature}    ${sensor_point_cool_temp}
        writingCycleCalculation
    ELSE IF    '${flg}'=='${exclude_dead_rack_flag}'        #Writing to all sensor points except the last rack sensors
        log to console    Inside Flag Block 4
        apiresources.setTemperatureForAllExceptDeadSensor    ${current_temperature}
        writingCycleCalculation
    ELSE IF  '${flg}'=='${test_exit_flag}'      #Tear down
        ${current_time}  get current date
        log to console    Stale state prevention program exit- Exit temperature ${test_exit_sensor_temp} detected
        log to console   Stale state prevention program stopped at ${current_time}
        exit for loop
    ELSE
        log to console    Flag value not in list.Please check the code.
    END

writingCycleCalculation
    ${writing_cycle}=    incrementingByOne    ${writing_cycle}
    set test variable    ${writing_cycle}
    log to console     ========Writing Cycle ${writing_cycle} finished=========

waitForOneMinuteAndPrintCurrentTimeToConsole
    common.waitForMinutes  1
    ${current_time}=    get current date
    log to console    !----Stale prevention program-Time==========>${current_time}============!


