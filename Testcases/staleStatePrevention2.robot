*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/common.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot


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
    ${flg}=    common.getFlagValue
    IF  '${flg}'!='${test_entry_flag}'
        ${current_temperature}=    apiresources.getCurrentTemperatureOfFirstSensorPointSpecified    CTop,CBot
    END
    IF  '${flg}'=='${test_entry_flag}'     #Setup where application is getting ready for test
        log to console    Test started.Waiting for temperature changes
    ELSE IF    '${flg}'=='${current_temp_to_all_flag}'      #Writing current temperature to all sensor points
        log to console    Inside Flag Block 2
        apiresources.setTemperatureForAllRackSensorPoints    ${current_temperature}
        writingCycleCalculation
    ELSE IF    '${flg}'=='${two_sets_of_temp_flag}'                 #Writing two sets of temperature.First two sensor points with current temperature and remaining with cooling temperature
        log to console    Inside Flag Block 3
        apiresources.setTwoSetOfSensorTemperatureForRack    ${current_temperature}    ${sensor_point_cool_temp}
        writingCycleCalculation
    ELSE IF    '${flg}'=='${exclude_dead_rack_flag}'        #Writing to all sensor points except the last rack sensors
        log to console    Inside Flag Block 4
        apiresources.setTemperatureForAllExceptDeadSensor    ${current_temperature}
        writingCycleCalculation
    ELSE IF    '${flg}'=='${current_temp_to_racks_RAT_DAT}'        #Writing temperature to all 4 types of sensor points->Ctop and CBot[racks],RAT and DAT
        log to console    Inside Flag Block 5
        ${DAT_current_temp}=    apiresources.getCurrentTemperatureOfFirstSensorPointSpecified    DAT
        ${RAT_current_temp}=    apiresources.getCurrentTemperatureOfFirstSensorPointSpecified    RAT
        apiresources.setTemperatureForAllRackSensorPoints    ${current_temperature}
        apiresources.setTemperatureForAllRATAndDATSensorPoints    ${RAT_current_temp}    ${DAT_current_temp}
        writingCycleCalculation
    ELSE IF    '${flg}'=='${current_value_to_racks_RAT_DAT_PWR}'        #Writing temperature to all 5 types of sensor points->Ctop and CBot[racks],RAT,DAT and PWRs
        log to console    Inside Flag Block 6
        ${DAT_current_temp}=    apiresources.getCurrentTemperatureOfFirstSensorPointSpecified    DAT
        ${RAT_current_temp}=    apiresources.getCurrentTemperatureOfFirstSensorPointSpecified    RAT
        ${PWR_current_value}=    apiresources.getCurrentTemperatureOfFirstSensorPointSpecified    PWR
        apiresources.setTemperatureForAllRackSensorPoints    ${current_temperature}
        apiresources.setTemperatureForAllRATAndDATSensorPoints    ${RAT_current_temp}    ${DAT_current_temp}
        apiresources.setPowerValuesForAllPowerMonitorPoints  ${PWR_current_value}
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


