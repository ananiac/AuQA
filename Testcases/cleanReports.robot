*** Settings ***
Documentation    Deletes last run files and folder in the report directory except updating cleanReport folder
Resource    ${EXECDIR}/Resources/common.robot


*** Test Cases ***
CleanReportsFolder
    common.clearReports

