*** Settings ***
Documentation    Move the files in the Reports directory to /automation/testReports/<date-time folder>
Resource    ${EXECDIR}/Resources/common.robot


*** Test Cases ***
MoveReportsToExternalFolder
    common.moveReports

