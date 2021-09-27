*** Settings ***
Library    Collections
Library    SeleniumLibrary
Library    ${EXECDIR}/ExternalKeywords/readExcel.py


*** Variables ***
&{guard_switch}  guard_on=GUARD_ON    guard_off=GUARD_OFF


*** Keywords ***
readingInputsFromExcel
    [Documentation]    sheet_index starts with 0
    ...                key_column should be column of key like A
    ...                value_column should be column of value like B
    [Arguments]    ${sheet_index}    ${key_column}    ${value_column}
    &{excel_inputs}  read_inputs_from_excel  ${sheet_index}    ${key_column}    ${value_column}
    log to console  ${excel_inputs}
    &{test_input}  set variable    ${excel_inputs}
    Set Global Variable   ${test_input}