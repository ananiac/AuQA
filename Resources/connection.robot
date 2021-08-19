*** Settings ***
Documentation          This demonstrates executing a command on a remote machine
...                    and getting its output.
...
Library                SSHLibrary
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
    openConnectionAndLogIn
    log to console    !!------Connection opened and now starting the processes----!!
    executeProcessCommandWithoutTraceInHistory    vx_server
    executeProcessCommandWithoutTraceInHistory    facs_trend
    executeProcessCommandWithoutTraceInHistory    facs_launcher
    sleep    ${high_speed}
    closeAllConnections

establishConnectionAndStartProcessesVx_serverFacs_launcherFacs_siftFacs_dashAndFacs_trends
    [Documentation]    Establish connection and start processes on the remote machine.
    ...                HISTIGNORE command is used to avoid saving the password in history
    openConnectionAndLogIn
    log to console    !!------Connection opened and now starting the processes----!!
    executeProcessCommandWithoutTraceInHistory    vx_server
    log to console    ----****1.done***---------
    executeProcessCommandWithoutTraceInHistory    facs_launcher
    log to console    ---------****2.done****---------
    executeProcessCommandWithoutTraceInHistory    facs_sift
    log to console    ---------****3.done****---------
    executeProcessCommandWithoutTraceInHistory    facs_dash
    log to console    ---------****4.done****---------
    executeProcessCommandWithoutTraceInHistory    facs_trend
    log to console    ---------****5.done****---------
    sleep    ${high_speed}
    closeAllConnections

establishConnectionAndStartCoolingControlProcess
    [Documentation]    Establish connection and start processes on the remote machine.
    ...                HISTIGNORE command is used to avoid saving the password in history
    openConnectionAndLogIn
    executeProcessCommandWithoutTraceInHistory    facs_dash
    sleep    ${high_speed}
    closeAllConnections
    #sleep    ${medium_speed}

executeSTOPProcessCommandWithoutTraceInHistory
    [Arguments]    ${process_name}
    log to console    !!------Connection opened and now stopping the process ${process_name}----!!
    execute command     export HISTIGNORE='*sudo -S*'
    execute command     echo "${password}" | sudo -S -k systemctl stop ${process_name}
    log to console    ***********Process ${process_name} Stopped**********

establishConnectionAndStopCoolingControlProcess
    [Documentation]    Establish connection and start processes on the remote machine.
    ...                HISTIGNORE command is used to avoid saving the password in history
    openConnectionAndLogIn
    executeSTOPProcessCommandWithoutTraceInHistory    facs_dash
    sleep    ${high_speed}
    closeAllConnections

startVXServerProcess
    openConnectionAndLogIn
    executeProcessCommandWithoutTraceInHistory    vx_server
    closeAllConnections

establishConnectionAndStopAllVEMProcessesExceptVx_serverAndFacs_trends
    log to console    !--------------Stopping all 13 processes except vx_Server and facs_trends----------!
    openConnectionAndLogIn
    executeSTOPProcessCommandWithoutTraceInHistory    dcsim
    log to console    !!----1.Simulator Stopped----!!
    executeSTOPProcessCommandWithoutTraceInHistory    facs_cleanup
    log to console    !!----2.CleanUp Stopped----!!
    executeSTOPProcessCommandWithoutTraceInHistory    vems-snmp
    log to console    !!----3.SNMP Stopped----!!
    executeSTOPProcessCommandWithoutTraceInHistory    facs_cp
    log to console    !!----4.Calibration Stopped----!!
    executeSTOPProcessCommandWithoutTraceInHistory    facs_cl
    log to console    !!----5.Learning Stopped----!!
    executeSTOPProcessCommandWithoutTraceInHistory    facs_dash
    log to console    !!----6.Cooling Control Stopped----!!
    executeSTOPProcessCommandWithoutTraceInHistory    facs_sift
    log to console    !!----7.Application Metrics Stopped----!!
    executeSTOPProcessCommandWithoutTraceInHistory    vems-plugin-smart-mesh-ip
    log to console    !!----8.Plugin: SmartMesh IP Stopped----!!
    executeSTOPProcessCommandWithoutTraceInHistory    facs_launcher
    log to console    !!----9.Script Laucnher Stopped----!!
    executeSTOPProcessCommandWithoutTraceInHistory    vx_report
    log to console    !!----10.Reports Stopped----!!
    executeSTOPProcessCommandWithoutTraceInHistory    vems-plugin-dust
    log to console    !!----11.Plugin:DUST Stopped----!!
    executeSTOPProcessCommandWithoutTraceInHistory    vems-plugin-modbus
    log to console    !!----12.Plugin:Modbus/TCP Stopped----!!
    executeSTOPProcessCommandWithoutTraceInHistory    vems-plugin-bacnet
    log to console    !!----13.Plugin:BACnet Stopped----!!
    closeAllConnections

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
    openConnectionAndLogIn
    ${current_status}=  executeCommandToCheckProcessStatus  vx_server
    closeAllConnections
    return from keyword  ${current_status}

