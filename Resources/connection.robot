*** Settings ***
Documentation          This demonstrates executing a command on a remote machine
...                    and getting its output.
...
Library                SSHLibrary
Variables    ../Configurations/config.py
Variables    ./Variables/globalVariables.py

*** Variables ***
${host}               10.252.9.37
${username}            fc
${password}            Id3aV@tAcc3ss


*** Keywords ***
openConnectionAndLogIn
    log to console    !--------Opening Connection----------!
    open connection     ${host}
    login               ${username}        ${password}
closeAllConnections
    execute command    exit
    log to console    *******************Processes started and now proceeding to next step********************
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
    sleep    ${medium_speed}
    CloseAllConnections
    sleep    ${medium_speed}
    #wait until keyword succeeds    ${low_speed}
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
    execute command     export HISTIGNORE='*sudo -S*'
    execute command     echo "Id3aV@tAcc3ss" | sudo -S -k systemctl stop ${process_name}
establishConnectionAndStopCoolingControlProcess
    [Documentation]    Establish connection and start processes on the remote machine.
    ...                HISTIGNORE command is used to avoid saving the password in history
    OpenConnectionAndLogIn
    ExecuteSTOPProcessCommandWithoutTraceInHistory    facs_dash
    sleep    ${high_speed}
    CloseAllConnections


