*** Settings ***
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/apiresources.robot
Variables    ${EXECDIR}/Resources/ResourceVariables/globalVariables.py
Variables    ${EXECDIR}/Inputs/basicHotAbsoluteGuardInputs.py
Variables    ${EXECDIR}/Inputs/deadSensorGuardInputs.py

*** Variables ***
${dead_sensor_writing_cycle}    0


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
    ELSE IF    ${current_temperature}==${dead_sensor_test_temp}                   #Dead sensor guard test
        IF   ( ${dead_sensor_writing_cycle}==0 or ${dead_sensor_writing_cycle}==1)
            apiresources.setRackSensorPointsTemperature   ${dead_sensor_test_temp}
            ${dead_sensor_writing_cycle}=    incrementingByOne    ${dead_sensor_writing_cycle}
            set test variable    ${dead_sensor_writing_cycle}
            log to console     Writing Cycle ${dead_sensor_writing_cycle} finished
        ELSE
             log to console    Repeating write operation
             apiresources.setTemperatureForAllExceptDeadSensor    ${dead_sensor_test_temp}
             ${dead_sensor_writing_cycle}=    evaluate    ${dead_sensor_writing_cycle} + 1
             set test variable    ${dead_sensor_writing_cycle}
             log to console     Writing Cycle ${dead_sensor_writing_cycle} finished
        END
    ELSE IF  '${current_temperature}'=='${test_exit_sensor_temp}'                #Tear down
        ${current_time}  get current date
        log to console    Stale state prevention program exit- Exit temperature ${test_exit_sensor_temp} detected
        log to console   Stale state prevention program stopped at ${current_time}
        exit for loop
    ELSE                                                                #Setup where application is getting ready for test
        log to console    Waiting for temperature changes
    END





