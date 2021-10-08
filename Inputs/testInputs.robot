*** Settings ***
Library    Collections
Library    SeleniumLibrary
Library    ${EXECDIR}/ExternalKeywords/readExcel.py


*** Variables ***
&{guard_switch}  guard_on=GUARD_ON    guard_off=GUARD_OFF
#All the global variables is stored here
#Regulate speed based on system response time delay
${long_wait_time}   60 seconds
${medium_wait_time}    30 seconds
${short_wait_time}    5 seconds
#time to overcome Clickable exception
${load_time}    10 seconds
${test_entry_sensor_temp}    61.11
${test_exit_sensor_temp}    66.72
${sensor_point_cool_temp}    65
${flag}    0
${test_exit_flag}    0
${test_entry_flag}    1
${current_temp_to_all_flag}    2
${two_sets_of_temp_flag}    3
${exclude_dead_rack_flag}    4


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