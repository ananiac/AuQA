*** Settings ***
Documentation          This testcase validates the AHUS go into guard in the correct order on a DASHAM_MIX site
...                     Environment: ${host_ip}
...                     Group Name: ${group_name}
#...                    Created by Greeshma on 24th Sep 2021
Resource    ../Resources/apiresources.robot
Resource    ../Resources/uiresources.robot
Resource    ../Resources/connection.robot
Resource    ../Resources/common.robot
Resource    ${EXECDIR}/Resources/GuardTestResources/guardOrderMIXResource.robot
Resource    ../Inputs/testInputs.robot

*** Test Cases ***
Override_1
    common.setFlagValue    1    #to manage staleState
#    #2.Stop ALL processes including the API Server (vx_server) and Script Launcher
    connection.establishConnectionAndStopAllProcessesExcept
#    #3.Wait 2 minutes
    common.waitForMinutes    2
#    #5.Start the API Server (vx_server) and Script Launcher processes
    connection.establishConnectionAndStartRequiredProcesses    vx_server  facs_launcher
#    #6.Load the DASHAM_MIX template template in the CX configs (with overwrite) … or DASHAM_RSP_RESET template if using RSP-test group
    uiresources.resetSystemPropertiesUsingLoadTemplateOptionWithOverwrite
#    #7.Start all Plugins (Bacnet, Dust, Smartmesh)
#    #8.Start all other processes except Calibration (facs_cp), Learning (facs_cl), and Simulation (dcsim)
    connection.establishConnectionAndStartRequiredProcesses    vems-plugin-smart-mesh-ip  vems-plugin-dust  vems-plugin-modbus  vems-plugin-bacnet    facs_dash    facs_sift    facs_trend  facs_cleanup  vems-snmp
#    #9.Set the group property GuardHotAbsTemp=9
    guardOrderMIXResource.setGroupPropertyGuardHotAbsTemp    99
    #10.Set AHU Properties FanCtrlMin = 50% and FanCtrlMax = 100%
    setFanCtrlMinMaxValueOfAllAHUs     50    100
#    #12.Set config DASHM::NumGuardUnits=1, NumMinutesGuardTimer=1, and SYSTEM::NumMinutesPast=20
    guardOrderMIXResource.setconfigNumGuardUnitsNumMinutesGuardTimerAndNumMinutesPast    1    1  20
#    #13.Set all Setpoint to  80.6/64.4
    apiresources.setAllHighAndLowSetPointLimits    80.6    64.4
#    #14.set all rack temperature sensor points every minute at say 66 F
    apiresources.setCoolingTemperatureForAllSensorPoints    66
#    #15.Set all RAT sensors to 68.0
#    #16.Set all DAT sensors to 53.0
#    #17.Set all RAT/DAT sensor points every minute to 68.0/53.0
     setDefaultTempForAllRATandDATSensorPoints   68  53
    #18.Go to CX > Tools > Configs
    #19.Set Configs > System::SFCMin = 72% and SFCMax = 88%
    apiresources.changeCxConfigsTabModuleFieldValues  SYSTEM  SFCMin  72
    apiresources.changeCxConfigsTabModuleFieldValues  SYSTEM  SFCMax  88
    #20.Wait 3 minutes
    common.waitForMinutes    3
    #21.Make sure no AHUs are in Guard or Overridden
    apiresources.releaseOverrideOfAllAHUsAndConfirmAHUsAreGuardCleared
    #22.Go to VX > Equipment tab
    #23.Override AHU CAC_10 ON and 77%

    #18.Override AHU CAC_10 ON and 77%
    #19.Verify On/Off Override = ON
    #20.Verify On/Off Origin = MANUAL

    #21.Verify Supply Fan Override = 77.0% for AHU CAC_10

    #22.Verify Supply Fan Origin = MANUAL

    #23.Wait 4 minutes

    #24.Verify Supply Fan Value = 77.0% for AHU CAC_10

    #25.Verify On/Off Value = ON






