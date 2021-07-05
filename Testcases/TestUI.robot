*** Settings ***
Library    SeleniumLibrary
Resource    ../Resources/resources.robot
Variables    ../PageObjects/loginPage.py
Variables    ../Configurations/config.py
Test Setup    startBrowserAndLoginToAIEngine
Test Teardown    close browser

*** Variables ***


*** Test Cases ***
AbsHotGuardSmokeTest
#Go to Equipement tab and check the current AHUs are in 'control' and not 'guard'
    openEquipmentTabToCheckTheCoolingUnitStatus

#Open Site editor which redirects to another url. Change the AbsHotGuard temperature to 3 degree
    openSiteEditorPage
    changeAbsoluteHotGuardTemperatureTo3Degree

#Go to System console to check the Equipment tab.Cooling units are expected to be in GUARD mode
    openSystemConsoleEquipmentTabToCheckGuardModeONForCoolingUnits

#Reset temperature back to 34 Degree under SiteEditor page
    gotoSiteEditorPage
    changeAbsoluteHotGuardTemperatureTo34Degree
TitleCheckTest
    verifyTitle
*** Keywords ***

