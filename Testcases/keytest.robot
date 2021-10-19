*** Settings ***
Documentation          This testcase validates the AHUS go into guard in the correct order on a DASHAM_MIX site
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created by Greeshma on 24th Sep 2021
Resource    ../Resources/apiresources.robot
Resource    ../Resources/uiresources.robot
Resource    ../Resources/connection.robot
Resource    ../Resources/common.robot
Resource    ../Resources/guardOrderMIXResource.robot
Resource    ../Inputs/testInputs.robot

*** Test Cases ***
KeywordCheck
#    apiresources.setFanCtrlMaxAndMinValuesOfNamedAHU    CAC_10    96    40
#    apiresources.checkSupplyFanValueOfAllAHUs    88
#    apiresources.checkSupplyFanValueOfSingleAHUUsingName    CAC_13    96
#    apiresources.checkSupplyFanValueOfSingleAHUUsingName    CAC_10    96
#    apiresources.checkSupplyFanValueOfSingleAHUUsingName    CAC_12    97
    common.setFlagValue    1    #to manage staleState
    #2.Stop ALL processes including the API Server (vx_server) and Script Launcher
    connection.establishConnectionAndStopAllProcessesExcept
    #3.Wait 2 minutes
    common.waitForMinutes    2
    #5.Start the API Server (vx_server) and Script Launcher processes
    connection.establishConnectionAndStartRequiredProcesses    vx_server  facs_launcher
    #6.Load the DASHAM_MIX template template in the CX configs (with overwrite) … or DASHAM_RSP_RESET template if using RSP-test group
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
    #8.Start all Plugins (Bacnet, Dust, Smartmesh)
    #9.Start all other processes except Calibration (facs_cp), Learning (facs_cl), and Simulation (dcsim)
    connection.establishConnectionAndStartRequiredProcesses    facs_trend  facs_cleanup  vems-snmp  vems-plugin-smart-mesh-ip  vems-plugin-dust  vems-plugin-modbus  vems-plugin-bacnet
    #10.Set the group property GuardHotAbsTemp=9
    guardOrderMIXResource.setGroupPropertyGuardHotAbsTemp    99
    #12.Set config DASHM::NumGuardUnits=1, NumMinutesGuardTimer=1, and SYSTEM::NumMinutesPast=20
    guardOrderMIXResource.setconfigNumGuardUnitsNumMinutesGuardTimerAndNumMinutesPast    1    1  20
    #13.Set all Setpoint to  80.6/64.4
    apiresources.setAllHighAndLowSetPointLimits    80.6    64.4
    #14.set all rack temperature sensor points every minute at say 66 F
    apiresources.setCoolingTemperatureForAllSensorPoints    66
    #16.Set Configs > System::SFCMin = 72% and SFCMax = 88%
    apiresources.changeCxConfigsTabModuleFieldValues  SYSTEM  SFCMin  72
    apiresources.changeCxConfigsTabModuleFieldValues  SYSTEM  SFCMax  88
    #17.Start facs_dash (Cooling Control) and facs_sift (Application Metrics)
    connection.establishConnectionAndStartRequiredProcesses    facs_dash    facs_sift
    #18.Wait 3 minutes
    common.waitForMinutes    3
    #Verify Supply Fan Value = 72.0% for all AHUs
    apiresources.checkSupplyFanValueOfAllAHUs    72
#    apiresources.checkSupplyFanValueOfAllAHUs    88     #Just to make sure that the value remains as 88 . expected is 72
#    common.waitForMinutes    3
    apiresources.checkSupplyFanValueOfAllAHUs    72




