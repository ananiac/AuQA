*** Settings ***
Documentation          This testcase validates the AHUS go into guard in the correct order on a DASHAM_MIX site
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created by Greeshma on 24th Sep 2021
Resource    ${EXECDIR}/Resources/apiresources.robot
Resource    ${EXECDIR}/Resources/uiresources.robot
Resource    ${EXECDIR}/Resources/connection.robot
Resource    ${EXECDIR}/Resources/guardOrderMIXResource.robot
Resource    ${EXECDIR}/Inputs/testInputs.robot

*** Test Cases ***
KeywordCheck
#    apiresources.setFanCtrlMaxAndMinValuesOfNamedAHU    CAC_10    96    40
#    apiresources.checkSupplyFanValueOfAllAHUs    88
#    apiresources.checkSupplyFanValueOfSingleAHUUsingName    CAC_13    96
#    apiresources.checkSupplyFanValueOfSingleAHUUsingName    CAC_10    96
#    apiresources.checkSupplyFanValueOfSingleAHUUsingName    CAC_12    97



