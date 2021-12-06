*** Settings ***
Documentation          This testcase validates the popup messages of VX
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/UIResources/uiPopupResources.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot


*** Test Cases ***
VXPopupMessagesVerification
    log to console  test1
#    [Setup]    uiPopupResources.popupTestSetup
#    uiPopupResources.suppressAlarmPopup