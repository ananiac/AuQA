import subprocess
from subprocess import call
import os
from ExternalKeywords import readExcel
import datetime
# import time
from pathlib import Path

#Gets the current date and time
date_format = datetime.datetime.now().strftime("%F_%X")

# path variables
dir_path=os.getcwd()
tc_path=dir_path+'\Testcases'
gt_path=dir_path+'\Testcases\GuardTests'
rp_path=dir_path+'\Reports'
se_path=dir_path+'\ExternalKeywords'

# Reading the excel as dictionary and fetching the rows and column header
command_input={}
command_input= readExcel.read_command_inputs_from_excel('execution')
header= readExcel.get_header('execution')
dic_row =len(command_input)

#Formalating te commands from excel inputs
command_for_execution =[]
for i in range(dic_row):
    execution_command =""
    for h in header:
        if (command_input[i][h] != None) and  h !="testcase":
            if(h == "command"):
                execution_command = execution_command + command_input[i][h]
            elif(h == "name" ):
                execution_command = execution_command + " --name"+" '"+command_input[i][h]+"_"+date_format+"' "
            elif(h == "reporttitle"):
                execution_command = execution_command + " --reporttitle" + ' "' +command_input[i][h]+ '" '
            elif (h == "output dir"):
                execution_command = execution_command + " --outputdir " + command_input[i][h]
            elif (h == "output"):
                if (command_input[i]['testcase'] =="combinereport") and (".xml/" in command_input[i][h]):
                    output_xml = (command_input[i][h]).split("/")
                    # print(output_xml)
                    xml_to_combine =""
                    for xml in output_xml:
                        xml_to_combine = xml_to_combine+" "+rp_path+"\\"+xml
                    # print("value of final xml"+ xml_to_combine)
                    execution_command = execution_command + " --output output.xml "+xml_to_combine
                else:
                    execution_command = execution_command + " --output " + command_input[i][h]
            elif (h == "environment"):
                execution_command = execution_command + " --variable " +"environment:"+ command_input[i][h]
            elif (h == "groupname"):
                execution_command = execution_command + " -v " + "groupname:" + command_input[i][h]
            elif (h == "testname"):
                if ".robot/" in command_input[i][h]:
                    test_name=(command_input[i][h]).split("/",1)
                if(command_input[i]['testcase'] !="cleanReports" and command_input[i]['testcase'] !="moveReports" ):
                    if("Guard" in command_input[i]['testcase']):
                        execution_command = execution_command + " -T " + gt_path+"\\"+test_name[0]+" "+tc_path+"\\"+ test_name[1]
                else:
                    execution_command = execution_command + " "+tc_path+"\\"+command_input[i][h]
    command_for_execution.append(execution_command)
# print(command_for_execution)
"""
#Executing the command and redirecting the output to executionLog.txt
for i in range(dic_row-2):
    print("executing the command: "+command_for_execution[i])
    try:
        output_report = subprocess.getstatusoutput(command_for_execution[i])
    except Exception:
        print("Error in testcase execution")
    with open("Reports/executionLog.txt", "a") as logfile:
        for line in output_report[1]:
            fileout = logfile.write(line)

#rebot command has to be separated from the loop of test execution else creates issue while combining the xml
#Executing the rebot to combine the output xml  and move the reports folder to testReports
for x in range(dic_row-2, dic_row):
    print("executing the command: " + command_for_execution[x])
    try:
        output_report = subprocess.getstatusoutput(command_for_execution[x])
    except Exception:
        print("Error in command execution")
    with open("Reports/executionLog.txt", "a") as logfile:
        for line in output_report[1]:
            fileout = logfile.write(line)
"""
#Execute send email
file_name=se_path+"\\sendemail.py"
print(file_name)
call(["python3", file_name,"thursdaydaysuite"])

# ==========================To be deleted

# call(command_for_execution[1])
# import sys
# from robot import run_cli, rebot_cli

#Executing the rebot to combine the output xml  and move the folder
# print(dic_row-2)
# output_report = subprocess.getstatusoutput(command_for_execution[dic_row-2])
# with open("Reports/executionLog.txt", "a") as logfile:
#     for line in output_report[1]:
#         fileout = logfile.write(line)
#
# print(dic_row-1)
# output_report = subprocess.getstatusoutput(command_for_execution[dic_row-1])
# with open("Reports/executionLog.txt", "a") as logfile:
#     for line in output_report[1]:
#         fileout = logfile.write(line)

# clean_report_op = subprocess.getstatusoutput('pabot --pabotlib -d Reports/cleanReports --output cleanReports.xml --variable environment:config37  Testcases/cleanReports.robot')
# print(clean_report_op)

# common = ['--log', 'none', '--report', 'none'] + sys.argv[1:] + ['login']
# run_cli(['--name', 'Firefox', '--variable', 'BROWSER:Firefox', '--output', 'out/fx.xml'] + common, exit=False)
# run_cli(['--name', 'IE', '--variable', 'BROWSER:IE', '--output', 'out/ie.xml'] + common, exit=False)
# rebot_cli(['--name', 'Login', '--outputdir', 'out', 'out/fx.xml', 'out/ie.xml'])
# does not work""
# run_cli(['-d' ' Reports/cleanReports' ' --output' ' cleanReports.xml'] + [' Testcases/cleanReports.robot'])

# from subprocess import call
# works:
# call('pabot --pabotlib -d Reports/cleanReports --output cleanReports.xml --variable environment:config37  Testcases/cleanReports.robot')

# command_for_execution =""
# for h in header:
#     print(h)
#     print(command_input[0][h])
#     if (command_input[0][h] != None) and  h !='testcase':
#         command_for_execution=command_for_execution+str((command_input[0][h]))
# print(command_for_execution)
# Executing the commands
# call(command_for_execution)

#Formalating te commands from excel inputs
# command_for_execution =[]
# for i in range(dic_row):
#     print(i)
#     execution_command =""
#     for h in header:
#          # print(h)
#         # print(command_input[i][h])
#         if (command_input[i][h] != None) and  h !='testcase':
#             execution_command=execution_command+str((command_input[i][h]))
#         # if (command_input[i][h] != name):
#         #     execution_command= execution_command+"--name"
#     # print(execution_command)
#     command_for_execution.append(execution_command)
# print(command_for_execution[0])