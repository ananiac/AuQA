*** Settings ***
Documentation          This demonstrates executing a command on a remote machine
...                    and getting its output.
...
Library                SSHLibrary
Variables    ../Configurations/config.py


*** Variables ***
${host}               10.252.9.37
${username}            fc
${password}            Id3aV@tAcc3ss


*** Keywords ***
OpenConnectionAndLogIn
    open connection     ${host}
    login               ${username}        ${password}
CloseAllConnections
    execute command    exit
    log to console    *******************Processes started and now proceeding to next step********************
ExecuteProcessCommandWithoutTraceInHistory
    [Arguments]    ${process_name}
    execute command     export HISTIGNORE='*sudo -S*'
    execute command     echo "Id3aV@tAcc3ss" | sudo -S -k systemctl start ${process_name}
EstablishConnectionAndStartProcesses
    [Documentation]    Establish connection and start processes on the remote machine.
    ...                HISTIGNORE command is used to avoid saving the password in history
    OpenConnectionAndLogIn
    ExecuteProcessCommandWithoutTraceInHistory    vx_server
    ExecuteProcessCommandWithoutTraceInHistory    facs_trend
    ExecuteProcessCommandWithoutTraceInHistory    facs_launcher
    sleep    ${medium_speed}
    CloseAllConnections
    sleep    ${medium_speed}
    #wait until keyword succeeds    ${low_speed}
EstablishConnectionAndStartCoolingControlProcess
    [Documentation]    Establish connection and start processes on the remote machine.
    ...                HISTIGNORE command is used to avoid saving the password in history
    OpenConnectionAndLogIn
    ExecuteProcessCommandWithoutTraceInHistory    facs_dash
    sleep    ${medium_speed}
    CloseAllConnections
    sleep    ${medium_speed}

