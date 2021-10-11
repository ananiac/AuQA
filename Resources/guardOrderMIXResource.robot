*** Settings ***
Documentation          This resource file provides the keyword definition specific to Dead Sensor Guard testsuite
#...                    Created by Greeshma on 28th July 2021
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library     String
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Library    SeleniumLibrary
Variables    ${EXECDIR}/Configurations/${environment}.py
Variables    ${EXECDIR}/PageObjects/siteEditorHomePage.py
Resource    common.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot
Library    ${EXECDIR}/ExternalKeywords/common.py

*** Variables ***
${index}    0
${exp_index}     0


*** Keywords ***
guardOrderMIXTestPreconditionSetup
    [Documentation]    Stop all VEM processes and wait for 2 minutes
    ...                Also write test entry temperature for the parallel staleStatePrevention program
    log to console    !-----Reading the inputs from the excel and storing in dictionary------!
    testInputs.readingInputsFromExcel  guardTest  J  K
    common.setFlagValue    ${test_entry_flag}         #to handle the parallel program stale state.
    log to console    !-----PreCondition for the Guard Order Mix test is been executed------!
    connection.establishConnectionAndStopAllProcessesExcept
    common.waitForMinutes    2
    apiresources.writeTestEntryTemperatureToSensorsAfterVXServerStarted

setconfigNumGuardUnitsNumMinutesGuardTimerAndNumMinutesPast
    [Arguments]    ${config_num_guard_units_value}    ${config_num_minutes_guard_timer_value}    ${config_system_num_minutes_past_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  NumGuardUnits  ${config_num_guard_units_value}
    apiresources.changeCxConfigsTabModuleFieldValues  DASHM  NumMinutesGuardTimer  ${config_num_minutes_guard_timer_value}
    apiresources.changeCxConfigsTabModuleFieldValues  SYSTEM  NumMinutesPast  ${config_system_num_minutes_past_value}

setGroupPropertyGuardHotAbsTemp
    [Arguments]    ${guard_hot_abs_temp_value}
    apiresources.changeGroupPropertiesParameterValue    GuardHotAbsTemp  int  ${guard_hot_abs_temp_value}

setGuardOrderMixPropertiesToEmpty
    setGroupPropertiesForGuardOrderMixToSomeValue
    sleep  ${load_time}
    uiresources.startBrowserAndLoginToAIEngine
    sleep  ${load_time}
    uiresources.selectAndClickGroupName
    uiresources.clickAllPropertiesButton
    uiresources.setGroupPropertyToEmpty  AllowNumExceedencesGuard
    uiresources.setGroupPropertyToEmpty  GuardHotAbsTemp
    uiresources.setGroupPropertyToEmpty  AllowNumExceedencesControl
    close browser

setGroupPropertiesForGuardOrderMixToSomeValue
    apiresources.changeGroupPropertiesParameterValue    AllowNumExceedencesGuard  int  ${test_input}[allow_num_exceedences_guard_cleanup_value]
    apiresources.changeGroupPropertiesParameterValue    GuardHotAbsTemp  float  ${test_input}[guard_hot_abs_temp_cleanup_value]
    apiresources.changeGroupPropertiesParameterValue    AllowNumExceedencesControl  int  ${test_input}[allow_num_exceedences_control_cleanup_value]

    #Created by Greeshma on 30 Sep 2021.This keyword takes the test_input from Excel and validates the AHU order w.r.t the SFC values
confirmTheOrderOfAHUsGoingIntoGuardIsIncrementalCoolEffortEstimateExceptFirstAHU
    [Arguments]    ${test_input}
    @{actual_order_ahus_into_guard}=    getActualOrderListOfAHUsGoingIntoGuard    ${test_input}[config_num_guard_units_value]    ${test_input}[config_num_minutes_guard_timer_value]
    @{expected_order_ahus_into_guard}=  getExpectedListOfAHUsGoingIntoGuard  ${test_input}
    log to console    Expected Order->${expected_order_ahus_into_guard}
    log to console    Actual Order->${actual_order_ahus_into_guard}
    @{first_ahus_predicted_into_guard}=    split string    ${test_input}[first_ahus_predicted_into_guard]    ,
    log to console    First AHUs Predicted are->${first_ahus_predicted_into_guard}
    log to console    !>>>>>>>>>>>>>>>>>>>Entering Order Validation-Guard order MIX<<<<<<<<<<<<<<<<<<<<<<<<<<<!
    FOR    ${ahu}    IN    @{actual_order_ahus_into_guard}
        IF    ${index}==0
            log to console    !!------------------Validating First AHU:${ahu}-----------------------!!
            ${count}=    count values in list    ${first_ahus_predicted_into_guard}    ${ahu}
            should be true    ${count} > 0    Validation of First AHU going into Guard. If this fails,remaining AHUs order will not be validated.
            remove values from list    ${expected_order_ahus_into_guard}    ${ahu}
            log to console    !!!=====Validation Passed for ${index} AHU into Guard: ${ahu}=======!!!
        ELSE
            log to console    >>>>>>>>>>>>>>>>>Validation of AHU:${ahu}-----------------------!!
            should be equal as strings    ${expected_order_ahus_into_guard}[${exp_index}]    ${ahu}    Validation of order of AHUs into Guard
            ${exp_index}    evaluate    ${exp_index} + 1
            log to console    !!!=====Validation Passed for ${index} AHU into Guard: ${ahu}=======!!!
        END
        ${index}    evaluate    ${index} + 1
        log to console    ----------
    END

    #Created by Greeshma on 28 Sep 2021.This will return a list of ahus went into guard in the actual order untill All AHUs are in guard.
getActualOrderListOfAHUsGoingIntoGuard
    [Arguments]    ${config_num_guard_units_value}    ${config_num_minutes_guard_timer_value}
    @{actual_order_of_ahu_into_guard}    create list
    ${total_no_of_ahus}=    apiresources.getAHUCount
    waitForSeconds    35
     FOR    ${reps}  IN RANGE    1    9999
        log to console    XX----------Entering--${reps}-Cycle of Checking AHUs in Guard----------------XX
        ${json_dict}=    apiresources.queryToFetchJsonResponseContaingTheCurrentAHUStatus
        @{currently_guard_ON_ahu_list}=    apiresources.fetchAHUNameListOfAHUsWithGuardON  ${total_no_of_ahus}    ${json_dict}
        ${expected_no_ahus_in_guard_currently}=    evaluate    ${config_num_guard_units_value} * ${reps}
        ${actual_no_ahus_in_guard_currently}=    get length    ${currently_guard_ON_ahu_list}
        should be equal as integers    ${expected_no_ahus_in_guard_currently}    ${actual_no_ahus_in_guard_currently}    Validation of number of AHUs into guard for current cycle
            FOR  ${ahu}  IN  @{currently_guard_ON_ahu_list}
                ${count}  count values in list    ${actual_order_of_ahu_into_guard}    ${ahu}
                IF    '${count}'=='0'
                    append to list    ${actual_order_of_ahu_into_guard}    ${ahu}
                END
            END
        IF    '${actual_no_ahus_in_guard_currently}'=='${total_no_of_ahus}'
            log to console    !!!===================All AHUs are in GUARD NOW========================!!!
            exit for loop
        END
        waitForMinutes    ${config_num_minutes_guard_timer_value}
     END
     return from keyword    ${actual_order_of_ahu_into_guard}

    #Created by Greeshma on 30 Sep 2021.This keyword creates the expected list of AHUs going into Guard from the Dictionary.
    #Duplicates of sfc_values are not allowed in test_input excel
getExpectedListOfAHUsGoingIntoGuard
    [Arguments]    ${test_input}
    @{ahus_expected_order_list}    create list
    &{ahu_sfc_input_dict}    create dictionary
    ${ahus_in_group}=    apiresources.getAHUNamesListOfGroup
    FOR    ${ahu}    IN    @{ahus_in_group}
        ${sfc_value}=    set variable    ${test_input}[${ahu}]
        set to dictionary    ${ahu_sfc_input_dict}    ${ahu}    ${sfc_value}
    END
    @{ahus_expected_order_list}    get_keys_list_after_sorting_dict_by_value    ${ahu_sfc_input_dict}
    return from keyword    ${ahus_expected_order_list}
