*** Settings ***
Documentation          This test the minon test on group with bindings such as 'General-test' group
#...                   This follows the manual test steps with simulator control.No stale state program is required.
#...                    Created by Greeshma on 29th Oct 2021
Library    RequestsLibrary
Library    JSONLibrary
Library    Collections
Library     String
Library    SeleniumLibrary
Library    ${EXECDIR}/ExternalKeywords/common.py
Variables    ${EXECDIR}/Configurations/${environment}.py
Variables    ${EXECDIR}/PageObjects/siteEditorHomePage.py
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/common.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot


*** Keywords ***
    #Created by Greeshma on 29th Nov 2021
minOnTestOnNoBindingsPrecondition
    [Documentation]    Stop all VEM processes and wait for 2 minutes
    ...                Also write test entry temperature for the parallel staleStatePrevention program
    log to console    !-----Reading the inputs from the excel and storing in dictionary------!
    testInputs.readingInputsFromExcel  overrideTest  D  E
    common.setFlagValue    ${test_entry_flag}         #to handle the parallel program stale state.
    log to console    !-----PreCondition for the MinOn test-No Bindings is been executed------!
    connection.establishConnectionAndStopAllProcessesExcept
    common.waitForMinutes    2
    apiresources.writeTestEntryTemperatureToSensorsAfterVXServerStarted

    #Created by Greeshma on 8th Dec 2021
minOnTestOnGeneralTestPrecondition
    [Documentation]    Stop all VEM processes and wait for 2 minutes
    log to console    !-----Reading the inputs from the excel and storing in dictionary------!
    testInputs.readingInputsFromExcel  overrideTest  G  H
    log to console    !-----PreCondition for the MinOn-General test is been executed------!
    checkAHUPropertiesPrecondition  ${test_input}
    connection.establishConnectionAndStopAllProcessesExcept
    common.waitForMinutes    2

    #Created by Greeshma on 26th Nov 2021
checkTheOrderOfAHUsTurningON
    [Arguments]    ${expected_ahu_turn_ON_order}
    ${index}  evaluate  0 + 0
    @{expected_order_ahus_into_ON}=    split string    ${expected_ahu_turn_ON_order}  ,
    @{actual_order_ahus_into_ON}=  getActualOrderListOfAllAHUsTurningONAtRegularInterval
    log to console    Expected Order->${expected_order_ahus_into_ON}
    log to console    Actual Order->${actual_order_ahus_into_ON}
    log to console    !>>>>>>>>>>>>>>>>>>>Entering Order Validation-MinON test<<<<<<<<<<<<<<<<<<<<<<<<<<<!
    FOR    ${ahu}    IN    @{actual_order_ahus_into_ON}
        log to console    >>>>>>>>>>>>>>>>>Validation of AHU:${ahu}-----------------------!!
        should be equal as strings    ${expected_order_ahus_into_ON}[${index}]    ${ahu}    Validation of order of AHUs that turns ON
        log to console    !!!=====Validation Passed for ${index} AHU to be ON: ${ahu}=======!!!
        ${index}    evaluate    ${index} + 1
    END
    log to console    ------------------------------------All AHUs are ON in expected order--------------------------------

    #Created by Greeshma on 26th Nov 2021
setNullValueForGuardHotAbsTempAndAlmHotAbsTemp
    apiresources.changeGroupPropertiesParameterValue    GuardHotAbsTemp  float  90
    apiresources.changeGroupPropertiesParameterValue    AlmHotAbsTemp  float  90
    common.waitForSeconds    10
    uiresources.setListedGroupPropertiesToEmpty    GuardHotAbsTemp  AlmHotAbsTemp

    #Created by Greeshma on 26th Nov 2021
getActualOrderListOfAllAHUsTurningONAtRegularInterval
    @{actual_order_of_ahu_turns_ON}  create list
    @{group_ahu_name_list}=    apiresources.getAHUNamesListOfGroup
    waitForSeconds    50
    &{json_dict}=  apiresources.queryToFetchJsonResponseContaingTheCurrentAHUStatus
    FOR    ${reps}  IN RANGE    1    9999
        log to console    XX----------Entering--${reps}-Cycle of Checking AHU ON----------------XX
        FOR  ${ahu_name}  IN  @{group_ahu_name_list}
            log to console  !-------------${ahu_name}----------------!
            ${field_value}=    getValueFieldOfSpecificControlInOverriddenAHUUsingJsonPath    $.data.site.groups[0].ahus[?(@.name=="${ahu_name}")].controls[?(@.type=="BOP")].point.value
            log to console  AHU->${ahu_name}->BOP value is->${field_value}
            IF  '${field_value}'=='1'
                append to list    ${actual_order_of_ahu_turns_ON}    ${ahu_name}
                log to console    !============->${ahu_name}->Added to actual order list-===========!
                remove values from list  ${group_ahu_name_list}  ${ahu_name}
            END
        END
        ${ahus_pending_to_be_on}  get length  ${group_ahu_name_list}
        IF  ${ahus_pending_to_be_on}==0
            exit for loop
        END
        common.waitForMinutes  1
    END
     return from keyword    ${actual_order_of_ahu_turns_ON}

    #Created by Greeshma on 8th Dec 2021
checkAHUPropertiesPrecondition
    [Arguments]  ${test_input}
    @{group_ahu_name_list}=    apiresources.getAHUNamesListOfGroup
    ${json_dict}=  fetchJsonRespContainingAHUPropertiesOfSpecificGroup
    FOR  ${ahu}  IN  @{group_ahu_name_list}
        ${ahu_cool_source}=    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].ahus[?(@.name=='${ahu}')].CoolSource
        ${ahu_design_capacity}=    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].ahus[?(@.name=='${ahu}')].DesignCapacity
        ${ahu_design_cop}=    fetchValueOfFieldFromJsonDictionary    ${json_dict}    $.data.site.groups[0].ahus[?(@.name=='${ahu}')].DesignCop
        ${ahu_design_cop}=  evaluate  "%.2f" % ${ahu_design_cop}
        log to console  Actual properties of ${ahu} are->CoolSource=${ahu_cool_source},DesignCapacity=${ahu_design_capacity},DesignCop=${ahu_design_cop}
        @{expected_ahu_prop}  split string  ${test_input}[${ahu}]  ,
        log to console  Expected properties of ${ahu} are->CoolSource=${expected_ahu_prop}[0],DesignCapacity=${expected_ahu_prop}[1],DesignCop=${expected_ahu_prop}[2]
        should be equal as strings    ${ahu_cool_source}    ${expected_ahu_prop}[0]  Validation for ${ahu}->CoolSource
        should be equal as strings    ${ahu_design_capacity}    ${expected_ahu_prop}[1]  Validation for ${ahu}->DesignCapacity
        should be equal as strings    ${ahu_design_cop}    ${expected_ahu_prop}[2]  Validation for ${ahu}->DesignCop
    END
    log to console  =========================Validation of AHU properties-value required for minon test passed====================