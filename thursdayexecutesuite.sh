# test suite for execution scheduled on thursday using cronjob
# Can be executed manually from AuQA folder using - sh thursdayexecutesuite.sh

full_path=$(realpath $0)
dir_path=$(dirname $full_path)

#suite Execution using the python script
cd $dir_path
python3 execution.py thursdaysuite

#Uncomment the below for suite execution using below command. Note the command added here will only be executed
#tc_path=$dir_path/Testcases
#gt_path=$dir_path/Testcases/GuardTests
#rp_path=$dir_path/Reports
#se_path=$dir_path/ExternalKeywords
#if [ `ps -ef | grep pabot | wc -l` -lt 2 ];  then
#    echo "No automated tests are running so starting the test execution"
#    cd $dir_path
#    pabot --pabotlib -d Reports/cleanReports --output cleanReports.xml --variable environment:config118  $tc_path/cleanReports.robot
#    pabot --pabotlib --processes 2 --name "Guard1_General-test_$(date +%F_%H:%M:%S)" --reporttitle "BasicHotAbsoluteGuard" --outputdir Reports --output basichotGuard.xml --variable environment:config118  -v groupname:General-test -T $gt_path/basicHotAbsoluteGuardTest.robot $tc_path/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- BasicHotAbsoluteGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
#    pabot --pabotlib --processes 2 --name "Guard2_Imputes-test_$(date +%F_%H:%M:%S)" --reporttitle "DeadSensorGuard" --outputdir Reports --output deadSensorGuard.xml --variable environment:config118  -v groupname:Imputes-test -T $gt_path/deadSensorGuardTest.robot $tc_path/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- DeadSensorGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
#    pabot --pabotlib --processes 2 --name "Guard3_General-test_$(date +%F_%H:%M:%S)" --reporttitle "HotGuard" --outputdir Reports --output hotGuard.xml --variable environment:config118  -v groupname:General-test -T $gt_path/hotGuardTest.robot  $tc_path/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- HotGuard/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
#    pabot --pabotlib --processes 2 --name "Guard4_General-test_$(date +%F_%H:%M:%S)" --reporttitle "GuardOrderMIX" --outputdir Reports --output guardOrderMIX.xml --variable environment:config118  -v groupname:General-test -T $gt_path/guardOrderMIXTest.robot  $tc_path/staleStatePrevention.robot >> Reports/executionLog.txt 2>&1 || echo $(date +%F_%H:%M:%S)- GuardOrderMIX/staleStatePrevention  execution failed >> Reports/executionLog.txt 2>&1
#    rebot --removekeywords passed --name "GuardTest" --reporttitle "Test performed on environment 118" --outputdir Reports --output output.xml $rp_path/basichotGuard.xml $rp_path/deadSensorGuard.xml $rp_path/hotGuard.xml $rp_path/guardOrderMIX.xml 2>&1 | tee -a Reports/executionLog.txt
#    pabot --pabotlib -d Reports/cleanReports --output moveReports.xml --variable environment:config118 $tc_path/moveReports.robot
#    echo "sending the email"
#    python3 $se_path/sendemail.py thursdaydaysuite 2>&1 | tee -a Reports/executionLog.txt
#    echo "Automated test execution completed"
#  else
#    echo "Automated test are running so the test execution is aborted"
# fi
