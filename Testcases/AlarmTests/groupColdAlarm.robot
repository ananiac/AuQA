*** Settings ***
Documentation          This testcase validates Alarm-08 GroupCold Alarm.
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created on 27th Dec 2021 by Greeshma
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/AlarmTestsResources/alarmResources.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot
Resource    ${EXECDIR}/Resources/common.robot


*** Test Cases ***