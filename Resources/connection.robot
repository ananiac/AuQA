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
    log to console    *******************Processes(start or stop or status check) completed and Closed ssh connection********************

executeProcessCommandWithoutTraceInHistory
    [Arguments]    ${process_name}
    execute command     export HISTIGNORE='*sudo -S*'
    execute command     echo "Id3aV@tAcc3ss" | sudo -S -k systemctl start ${process_name}

establishConnectionAndStartProcesses
    [Documentation]    Establish connection and start processes on the remote machine.
    ...                HISTIGNORE command is used to avoid saving the password in history
    OpenConnectionAndLogIn
    log to console    !!------Connection opened and now starting the processes----!!
    ExecuteProcessCommandWithoutTraceInHistory    vx_server
    ExecuteProcessCommandWithoutTraceInHistory    facs_trend
    ExecuteProcessCommandWithoutTraceInHistory    facs_launcher
    sleep    ${high_speed}
    CloseAllConnections

establishConnectionAndStartCoolingControlProcess
    [Documentation]    Establish connection and start processes on the remote machine.
    ...                HISTIGNORE command is used to avoid saving the password in history
    OpenConnectionAndLogIn
    ExecuteProcessCommandWithoutTraceInHistory    facs_dash
    sleep    ${high_speed}
    CloseAllConnections
    #sleep    ${medium_speed}

executeSTOPProcessCommandWithoutTraceInHistory
    [Arguments]    ${process_name}
    log to console    !!------Connection opened and now stopping the-${process_name} process----!!
    execute command     export HISTIGNORE='*sudo -S*'
    execute command     echo "Id3aV@tAcc3ss" | sudo -S -k systemctl stop ${process_name}

executeCommandToCheckProcessStatus
    [Arguments]  ${process_name}
    log to console  !!-----Checking the status of process ${process_name} now------!!
    ${pid}=  execute command  pidof ${process_name}
    log to console  PID of process-${process_name} is -${pid}
    IF  '${pid}'!=''
        ${ps_output}=  execute command  ps ${pid}
        #log to console  Process Status for ${process_name} is ${ps_output}  #additional chk for Ssl required?
        return from keyword  vx_server_up
    ELSE
        return from keyword  vx_server_down
    END

establishConnectionAndStopCoolingControlProcess
    [Documentation]    Establish connection and start processes on the remote machine.
    ...                HISTIGNORE command is used to avoid saving the password in history
    OpenConnectionAndLogIn
    ExecuteSTOPProcessCommandWithoutTraceInHistory    facs_dash
    sleep    ${high_speed}
    CloseAllConnections


establishConnectionAndCheckVX_ServerProcesseStatus
    OpenConnectionAndLogIn
    ${current_status}=  executeCommandToCheckProcessStatus  vx_server
    CloseAllConnections
    return from keyword  ${current_status}

startVXServerForTestEntry
    OpenConnectionAndLogIn
    ExecuteProcessCommandWithoutTraceInHistory    vx_server
    CloseAllConnections



