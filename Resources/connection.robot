*** Settings ***
Documentation          This demonstrates executing a command on a remote machine
...                    and getting its output.
...
Library                SSHLibrary
Library                Process
Library                OperatingSystem
Variables    ${EXECDIR}/Configurations/${environment}.py
Variables    ${EXECDIR}/Resources/ResourceVariables/globalVariables.py


*** Variables ***
${host}               ${host_ip}
${username}            ${ssh_username}
${password}            ${ssh_password}


*** Keywords ***
openConnectionAndLogIn
    log to console    !--------Opening SSH Connection----------!
    open connection     ${host}
    login               ${username}        ${password}

closeAllConnections
    execute command    exit
    log to console    *******************Processes(start or stop) completed and Closed ssh connection********************

executeProcessCommandWithoutTraceInHistory
    [Arguments]    ${process_name}
    execute command     export HISTIGNORE='*sudo -S*'
    execute command     echo "${password}" | sudo -S -k systemctl start ${process_name}
    log to console    =============Process:${process_name} Started================

establishConnectionAndStartProcessesVx_serverFacs_trendAndFacs_launcher
    [Documentation]    Establish connection and start processes on the remote machine.
    ...                HISTIGNORE command is used to avoid saving the password in history
    connection.openConnectionAndLogIn
    log to console    !!------Connection opened and now starting the processes----!!
    connection.executeProcessCommandWithoutTraceInHistory    vx_server
    connection.executeProcessCommandWithoutTraceInHistory    facs_trend
    connection.executeProcessCommandWithoutTraceInHistory    facs_launcher
    sleep    ${short_wait_time}
    connection.closeAllConnections

establishConnectionAndStartProcessesVx_serverFacs_launcherFacs_siftFacs_dashAndFacs_trends
    [Documentation]    Establish connection and start processes on the remote machine.
    ...                HISTIGNORE command is used to avoid saving the password in history
    connection.openConnectionAndLogIn
    log to console    !!------Connection opened and now starting the processes----!!
    connection.executeProcessCommandWithoutTraceInHistory    vx_server
    log to console    ----****1.done***---------
    connection.executeProcessCommandWithoutTraceInHistory    facs_launcher
    log to console    ---------****2.done****---------
    connection.executeProcessCommandWithoutTraceInHistory    facs_sift
    log to console    ---------****3.done****---------
    connection.executeProcessCommandWithoutTraceInHistory    facs_dash
    log to console    ---------****4.done****---------
    connection.executeProcessCommandWithoutTraceInHistory    facs_trend
    log to console    ---------****5.done****---------
    sleep    ${short_wait_time}
    connection.closeAllConnections

establishConnectionAndStartCoolingControlProcess
    [Documentation]    Establish connection and start processes on the remote machine.
    ...                HISTIGNORE command is used to avoid saving the password in history
    connection.openConnectionAndLogIn
    connection.executeProcessCommandWithoutTraceInHistory    facs_dash
    sleep    ${short_wait_time}
    connection.closeAllConnections
    #sleep    ${medium_wait_time}

executeSTOPProcessCommandWithoutTraceInHistory
    [Arguments]    ${process_name}
    log to console    !!------Connection opened and now stopping the process ${process_name}----!!
    execute command     export HISTIGNORE='*sudo -S*'
    execute command     echo "${password}" | sudo -S -k systemctl stop ${process_name}
    log to console    ***********Process ${process_name} Stopped**********

establishConnectionAndStopCoolingControlProcess
    [Documentation]    Establish connection and start processes on the remote machine.
    ...                HISTIGNORE command is used to avoid saving the password in history
    connection.openConnectionAndLogIn
    connection.executeSTOPProcessCommandWithoutTraceInHistory    facs_dash
    sleep    ${short_wait_time}
    connection.closeAllConnections

startVXServerProcess
    connection.openConnectionAndLogIn
    connection.executeProcessCommandWithoutTraceInHistory    vx_server
    connection.closeAllConnections

establishConnectionAndStopAllVEMProcessesExceptVx_serverAndFacs_trends
    log to console    !--------------Stopping all 13 processes except vx_Server and facs_trends----------!
    connection.openConnectionAndLogIn
    connection.executeSTOPProcessCommandWithoutTraceInHistory    dcsim
    log to console    !!----1.Simulator Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    facs_cleanup
    log to console    !!----2.CleanUp Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    vems-snmp
    log to console    !!----3.SNMP Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    facs_cp
    log to console    !!----4.Calibration Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    facs_cl
    log to console    !!----5.Learning Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    facs_dash
    log to console    !!----6.Cooling Control Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    facs_sift
    log to console    !!----7.Application Metrics Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    vems-plugin-smart-mesh-ip
    log to console    !!----8.Plugin: SmartMesh IP Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    facs_launcher
    log to console    !!----9.Script Laucnher Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    vx_report
    log to console    !!----10.Reports Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    vems-plugin-dust
    log to console    !!----11.Plugin:DUST Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    vems-plugin-modbus
    log to console    !!----12.Plugin:Modbus/TCP Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    vems-plugin-bacnet
    log to console    !!----13.Plugin:BACnet Stopped----!!
    connection.closeAllConnections

executeCommandToCheckProcessStatus
    [Arguments]  ${process_name}
    log to console  !!-----Checking the status of process ${process_name} now------!!
    ${pid}=  execute command  pidof ${process_name}
    log to console  PID of process-${process_name} is -${pid}
    IF  '${pid}'!=''
        ${ps_output}=  execute command  ps ${pid}
        #log to console  Process Status for ${process_name} is ${ps_output}  #additional chk for Ssl required?
        return from keyword  process_up
    ELSE
        return from keyword  process_down
    END

establishConnectionAndCheckVX_ServerProcesseStatus
    connection.openConnectionAndLogIn
    ${current_status}=  executeCommandToCheckProcessStatus  vx_server
    connection.closeAllConnections
    return from keyword  ${current_status}

    #Created by Greeshma on 20 Aug 2021
establishConnectionAndStopAllVEMProcessesExceptVx_serverFacsLauncherFacsSiftFacsDashAndFacs_trends
    log to console    !----------Stopping all processes except vx_server, facs_launcher, facs_dash, facs_trends, and facs_sift----------!
    connection.openConnectionAndLogIn
    connection.executeSTOPProcessCommandWithoutTraceInHistory    dcsim
    log to console    !!----1.Simulator Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    facs_cleanup
    log to console    !!----2.CleanUp Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    vems-snmp
    log to console    !!----3.SNMP Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    facs_cp
    log to console    !!----4.Calibration Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    facs_cl
    log to console    !!----5.Learning Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    vems-plugin-smart-mesh-ip
    log to console    !!----6.Plugin: SmartMesh IP Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    vx_report
    log to console    !!----7.Reports Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    vems-plugin-dust
    log to console    !!----8.Plugin:DUST Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    vems-plugin-modbus
    log to console    !!----9.Plugin:Modbus/TCP Stopped----!!
    connection.executeSTOPProcessCommandWithoutTraceInHistory    vems-plugin-bacnet
    log to console    !!----10.Plugin:BACnet Stopped----!!
    connection.closeAllConnections

killChromeAndChromedriverProcessesAfterTest
    log to console  !!-----Killing all the Chrome instances in Staging machine------!!
    run process    echo    "${password}"  |    sudo    killall    chrome     shell=True
    log to console  !!-----Killing chromedriver process in Staging machine------!!
    run process    echo    "${password}"  |    sudo    killall    chromedriver     shell=True

