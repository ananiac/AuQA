from subprocess import call
import os
from ExternalKeywords import readExcel
import datetime
from pathlib import Path

date = datetime.datetime.now()
date_format = date.strftime("%F_%X")
print(date_format)

# path variables
dir_path=os.getcwd()
# print(dir_path)
tc_path=dir_path+'\Testcases'
# print(tc_path)
gt_path=dir_path+'\Testcases\GuardTests'
# print(gt_path)
rp_path=dir_path+'\Reports'
# print(rp_path)
se_path=dir_path+'\ExternalKeywords'
# print(se_path)

command_input={}
command_input= readExcel.read_command_inputs_from_excel('execution')
# print(command_input)
# command_for_execution_test = command_input[0]['command']+command_input[0]['output dir']+command_input[0]['output']+\
#                         command_input[0]['environment']+command_input[0]['test']
# print (command_for_execution_test)

header= readExcel.get_header('execution')
# print(header)

dic_col = len(command_input[0])
# print(dic_col)

dic_row =len(command_input)
# print(dic_row)

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
                execution_command = execution_command + " --reporttitle" + " '" +command_input[i][h]+ "' "
            elif (h == "output dir"):
                execution_command = execution_command + " --outputdir " + command_input[i][h]
            elif (h == "output"):
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
            # elif (h == "log"):
            #     execution_command = execution_command +" >> "+ rp_path+"\\"+command_input[i][h]
    command_for_execution.append(execution_command)
print(command_for_execution[1])

# call(command_for_execution[1])
clean_report_op = subprocess.getstatusoutput(command_for_execution[1])
print(clean_report_op)






# ==========================To be deleted
# import sys
# from robot import run_cli, rebot_cli


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