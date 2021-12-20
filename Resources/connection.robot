*** Settings ***
Documentation          This demonstrates executing a command on a remote machine
...                    and getting its output using ssh library.Also the commands on staging machine using process library
Library                SSHLibrary
Library                Process
Library                Collections
Library    CryptoLibrary  variable_decryption=True  key_path=${EXECDIR}/Inputs/keys
Variables    ${EXECDIR}/Configurations/${environment}.py
Resource    ${EXECDIR}/Inputs/testInputs.robot


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
    log to console    *******************Closed ssh connection********************

executeStartProcessCommand
    [Arguments]    ${process_name}
    execute command     echo "${password}" | sudo -S -k systemctl start ${process_name}
    log to console    =============Process:${process_name} Started================

executeStopProcessCommand
    [Arguments]    ${process_name}
    execute command     echo "${password}" | sudo -S -k systemctl stop ${process_name}
    log to console    ***********Process ${process_name} Stopped**********

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

    #Created by Greeshma on 14 Sep 2021
killChromeAndChromedriverProcessesAfterTest
    log to console  !!-----Killing all the Chrome instances in Staging machine------!!
    run process    echo    "${password}"  |    sudo    killall    chrome     shell=True
    log to console  !!-----Killing chromedriver process in Staging machine------!!
    run process    killall    chromedriver      shell=True


    #Created by Greeshma on 15 sep 2021
    #Argument of this keyword is the list of process that need to be started.
establishConnectionAndStartRequiredProcesses
    [Arguments]    @{process_list}
    ${length}    get length    ${process_list}
    IF    ${length}==0
        log to console    Process name not recieved
    ELSE
        ${num}    evaluate    1 * 1
        connection.openConnectionAndLogIn
        FOR    ${process}    IN    @{process_list}
            log to console    ${num}-Starting ${process}---->
            connection.executeStartProcessCommand    ${process}
            sleep    ${short_wait_time}
            ${num}    evaluate   ${num} + 1
        END
        connection.closeAllConnections
    END

    #Created by Greeshma on 15 sep 2021 .
    #Argument for this keyword should be the list of process which should not be stopped
establishConnectionAndStopAllProcessesExcept
    [Arguments]    @{exception_list}
    @{all_processes_list}    create list    vx_server  facs_trend  dcsim  facs_cleanup  vems-snmp  facs_cp  facs_cl  facs_dash  facs_sift  vems-plugin-smart-mesh-ip  facs_launcher  vx_report  vems-plugin-dust  vems-plugin-modbus  vems-plugin-bacnet
    connection.openConnectionAndLogIn
    ${num}    evaluate    1 * 1
    FOR    ${process}    IN    @{all_processes_list}
        ${count}=    count values in list    ${exception_list}    ${process}
        IF    ${count}==0
            log to console    ${num}-Stopping ${process}---->
            connection.executeStopProcessCommand    ${process}
            ${num}    evaluate    ${num} + 1
        ELSE
            log to console    ------------------------------------------------------------
            log to console   >>>>>>>>>>>>>>>>>>>>>>${process} not stopped<<<<<<<<<<<<<<<<<
        END
    END
    connection.closeAllConnections