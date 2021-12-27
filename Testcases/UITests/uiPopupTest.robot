*** Settings ***
Documentation          This testcase validates the popup messages of VX and CX
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/UIResources/uiPopupResources.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot


*** Test Cases ***
VXPopupMessagesVerification
    [Setup]    uiPopupResources.popupTestSetup
    uiPopupResources.suppressAlarmPopup
    uiPopupResources.suppressedAlarmsPopup
    uiPopupResources.setOverridesPopup
    uiPopupResources.clearOverridesPopup
    uiPopupResources.showTrendsPopup
    uiPopupResources.bypassPopup

CXPopupMessagesVerification
    uiPopupResources.verifySystemPropertySFCMinSetToBlank
    uiPopupResources.savePopup
    uiPopupResources.validationErrorForTurnOffLimit24Hr
    uiPopupResources.unsavedChanges