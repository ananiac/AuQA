*** Settings ***
Library    Collections
Library    SeleniumLibrary
Library    ${EXECDIR}/ExternalKeywords/readExcel.py


*** Variables ***
&{guard_switch}  guard_on=GUARD_ON    guard_off=GUARD_OFF
#All the global variables are stored here
#Wait time based on the system response
${long_wait_time}   60 seconds
${medium_wait_time}    30 seconds
${short_wait_time}    5 seconds
${load_time}    10 seconds
${test_entry_sensor_temp}    61.11
${test_exit_sensor_temp}    66.72
${sensor_point_cool_temp}    65
${flag}    0
#Flag for test_exit
${test_exit_flag}    0
#Flag for test_entry
${test_entry_flag}    1
#Flag to write current temperature of first rack sensor point, to all sensor points
${current_temp_to_all_flag}    2
#Flag to write hot temp to first two sensor points and cooling temp to remaining sensor points
${two_sets_of_temp_flag}    3
#Flag to write temp to all sensor points except the last two sensor points
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