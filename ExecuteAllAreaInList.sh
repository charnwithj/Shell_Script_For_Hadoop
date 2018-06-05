#!/bin/bash
#############################################################################################################
## Script Name: ExecuteAllAreaInList.sh                                                                    ##
## Description: Use this script to get all column name and data type in each table                         ##
##                                                                                                         ##
## Parameter:  Mandatory arguments                                                                         ##
##               -e      Environment e.g. dldev or dlsit or dluat or dlprod                                ##
##               -l      List of Area (Keep in Filename)                                                   ##
##               -d      Running Date                                                                      ##
##             Optional arguments                                                                          ##
##               -o      Oozie job id (OOZIE_JOB_ID)                                                       ##
##               -r      Rerun failed job option (OPT2)  ('Y','N')                                         ##
##               -b      Dependency bypass option (OPT3) ('Y','N')                                         ##
##               -m      Mode (RANGE, RANGE_LITERAL)                                                       ##
##                                                                                                         ##
## Output result: The job's execute status will be inseted into audit_log table.                           ##
##                                                                                                         ##
## Usage Usage:                                                                                            ##
##                                                                                                         ##
## Revision History: 2018-03-26 : Intial (Charnwith J.)                                                    ##
##                                                                                                         ##
#############################################################################################################

#############################################################################################################
##   Set Parameter                                                                                         ##
#############################################################################################################
##Initial Value
environment=""
list_of_area_file=""
business_date=""
oozie_job_id=""
rerun_failed_job_flag=""
bypass_flag=""
mode=""

work_directory=$(pwd)


##Get Parameter
if [ $# -le 5 ]; then
    echo "Parameter:  Mandatory arguments                                         "     
    echo "              -e      Environment e.g. dldev or dlsit or dluat or dlprod"     
    echo "              -l      List of Area (Keep in Filename)                   "     
    echo "              -d      Running Date                                      "     
    echo "            Optional arguments                                          "     
    echo "              -o      Oozie job id (OOZIE_JOB_ID)                       "     
    echo "              -r      Rerun failed job option (OPT2)  ('Y','N')         "     
    echo "              -b      Dependency bypass option (OPT3) ('Y','N')         "     
    echo "              -m      Mode (RANGE, RANGE_LITERAL)                       "     
	exit 1
elif [ $# -ge 6 ] && [ $# -le 14 ] ; then
    while getopts ":e:l:d:o:r:b:m:" opt; do
        case $opt in 
            "e") 
                    environment=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    echo "Environment: "$environment
                    ;;
            "l") 
                    list_of_area_file=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    echo "List of Area Name in File: "$list_of_area_file
                    ;;
            "d")    
                    business_date=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    ;;
            "o") 
                    oozie_job_id=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    echo "Oozie Job ID: "$oozie_job_id
                    ;;
            "r") 
                    rerun_failed_job_flag=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    echo "Rerun Flag: "$rerun_failed_job_flag
                    ;;
            "b")    
                    bypass_flag=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    echo "Bypass Flag: "$bypass_flag
                    ;;
            "m")    
                    mode=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    echo "Mode: "$mode
                    ;;
            \?)
                        echo "Invalid option: -$OPTARG"
                        exit 1
                        ;;
        esac
    done
fi


##Verify Parameter
if [[ $environment != "dldev" && $environment != "dlsit" && $environment != "dluat" && $environment != "dlprod" ]]; then
    echo "Error!! This environment '"$environment"' doesn't exist.."
	echo "Hint: his environment should be dldev, dlsit, dluat or dlprod"
    exit 1
fi

if [[ $(echo -n $business_date | wc -m) -eq 10 && $business_date == $(echo ${business_date:0:4}"-"${business_date:5:2}"-"${business_date:8:2}) ]]; then
    business_date=$business_date
	echo "Business Date: "$business_date
elif [[ $(echo -n $business_date | wc -m) -eq 8 ]]; then
    business_date=$(echo  ${business_date:0:4}"-"${business_date:4:2}"-"${business_date:6:2})
	echo "Business Date: "$business_date
else
    echo "Error!! This business date ("$business_date") is invalid format"
    echo "Hint: Business Date should be 'YYYY-MM-DD' or 'YYYYMMDD'"
	exit 1
fi


#Set MySQL config
. /datagrid/$environment/raw/etl/common/config/environment.config $environment > /dev/null


##############################################################################################################
##   Executer Process                                                                                       ##
##############################################################################################################
for area_name in $(cat $list_of_area_file); do
    echo "Start Execute Area: "$area_name >> 
    echo $area_name
	echo "Finished Execute Area: "$area_name
done

