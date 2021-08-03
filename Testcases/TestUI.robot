*** Settings ***
Library    SeleniumLibrary
Resource    ${EXECDIR}/Resources/resources.robot
Variables    ${EXECDIR}/PageObjects/loginPage.py
Variables    ${EXECDIR}/Configurations/${environment}.py

Test Setup    startBrowserAndLoginToAIEngine
Test Teardown    close browser

*** Variables ***

# Added this for test
#added step2

*** Test Cases ***
#AbsHotGuardSmokeTest
##Go to Equipement tab and check the current AHUs are in 'control' and not 'guard'
#    openEquipmentTabToCheckTheCoolingUnitStatus
#
##Open Site editor which redirects to another url. Change the AbsHotGuard temperature to 3 degree
#    openSiteEditorPage
#    changeAbsoluteHotGuardTemperatureTo3Degree
#
##Go to System console to check the Equipment tab.Cooling units are expected to be in GUARD mode
#    openSystemConsoleEquipmentTabToCheckGuardModeONForCoolingUnits
#
##Reset temperature back to 34 Degree under SiteEditor page
#    gotoSiteEditorPage
#    changeAbsoluteHotGuardTemperatureTo34Degree
#TitleCheckTest
#    verifyTitle

# 2 Aug 2021 - Step 2 - Testcase 2 - SetProperties
# Git Branch - AUQA-14_Step2_Testcase2_SetProperties
SetProperties
    startBrowserAndLoginToAIEngine
    gotoSiteEditorPage
    selectGroupAndSetProperties

*** Keywords ***

