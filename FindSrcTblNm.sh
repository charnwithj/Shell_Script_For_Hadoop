#!/bin/bash
#############################################################################################################
## Script Name: FindSrcTblNm.sh                                                                            ##
## Description: Use this script to find out what in the table name in each script in each area             ##
##                                                                                                         ##
## Parameter:  Mandatory arguments                                                                         ##
##               -e      Environment e.g. dldev or dlsit or dluat or dlprod                                ##
##               -a      Area name e.g. atm or esn                                                         ##
##             Optional arguments                                                                          ##
##               -c      Curated Script                                                                    ##
##               -l      List File of Curated Script                                                       ##
##                                                                                                         ##
## Output result: The result file will be exported into path work_directory/result                         ##
##                ex. /datagrid/dldev/raw/etl/common/bin/result/                                           ##
##                                                                                                         ##
## Usage Usage: FindSrcTblNm.sh -e Environment -a Area [-c Curate Script]                                  ##
##                                                                                                         ##
## Revision History: 2018-03-20 : Intial (Charnwith J.)                                                    ##
##                                                                                                         ##
#############################################################################################################

#############################################################################################################
##   Set Parameter                                                                                         ##
#############################################################################################################
##Initial Value
environment=""
area=""
curated_script=""
curate_table_name=""
work_directory=$(pwd)
result_path=$work_directory"/result"

##Get Parameter
if [ $# -le 3 ]; then
    echo "Usage: `basename ${0}` -e Environment -a Area [-c Curate Script]"
    echo "Mandatory arguments"
    echo "  -e      Environment e.g. dldev or dlsit or dluat or dlprod"
    echo "  -a      Area name e.g. atm or esn"
    echo "Optional arguments"
    echo "  -c      Curated Script"
	exit 1
elif [ $# -ge 4 ] && [ $# -le 8 ] ; then
    while getopts ":e:a:c:" opt; do
        case $opt in 
            "e") 
                    environment=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    echo "Environment: "$environment
                    ;;
            "a") 
                    area=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    echo "Area: "$area
                    ;;
            "c")    
                    curated_script=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    echo "Curated Script Name: "$curated_script
                    ;;
            "l")    
                    list_file_of_curated_script=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    echo "Curated Script Name: "$list_file_of_curated_script
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

##Make Result Directory
mkdir -p $result_path


##############################################################################################################
##   Executer Process                                                                                       ##
##############################################################################################################
if [[ ($curated_script == "" || $curated_script == "-skip") && ($list_file_of_curated_script == "" || $list_file_of_curated_script == "-skip") ]]; then
##List all curated script name
    for file_name in $(ls -l /datagrid/"$environment"/curated/etl/"$area"/transform/*.hql | awk -F" " '{print $NF}' | uniq); do
        curated_script=$file_name
		curated_script_name=$(echo $file_name | awk -F "/" '{print $NF}')
        curate_table_name=$(echo $curated_script_name | sed -e 's/cur_//g' | sed -e 's/.hql//g' | tr '[:upper:]' '[:lower:]' )
        for table_name_tmp_1 in $(cat $file_name  | sed -s 's/${hiveconf:dl_data_dt}/9999-12-31/g' | grep "hiveconf" | grep -i "from " | awk -F"$" '{print "$"$2}'| awk -F" " '{print $1}'|sed -e 's/${hiveconf:environment}/'$environment'/g'| sed -e 's/${hiveconf:curateddb}/'$environment'_curated_'$area'_db/g' | tr '[:upper:]' '[:lower:]'| uniq ); do
            echo $curated_script_name"|"$environment"_curated_"$area"_db|"$curate_table_name"|"$(echo $table_name_tmp_1|sed -e 's/\./\|/g'|tr -d '\015' ) >> $result_path"/"tmp_result.txt
		done
        for table_name_tmp_1 in $(cat $file_name  | sed -s 's/${hiveconf:dl_data_dt}/9999-12-31/g' | grep "hiveconf" | grep -i "join " | awk -F"$" '{print "$"$2}'| awk -F" " '{print $1}'|sed -e 's/${hiveconf:environment}/'$environment'/g'| sed -e 's/${hiveconf:curateddb}/'$environment'_curated_'$area'_db/g' | tr '[:upper:]' '[:lower:]'| uniq ); do
            echo $curated_script_name"|"$environment"_curated_"$area"_db|"$curate_table_name"|"$(echo $table_name_tmp_1|sed -e 's/\./\|/g'|tr -d '\015' ) >> $result_path"/"tmp_result.txt
        done
        for table_name_tmp_1 in $(cat $file_name  | sed -s 's/${hiveconf:dl_data_dt}/9999-12-31/g' | grep "hiveconf" | grep -i "join " | grep -i ","| awk -F"$" '{print "$"$2}'| awk -F" " '{print $1}'|sed -e 's/${hiveconf:environment}/'$environment'/g'| sed -e 's/${hiveconf:curateddb}/'$environment'_curated_'$area'_db/g' | tr '[:upper:]' '[:lower:]'| uniq ); do
            echo $curated_script_name"|"$environment"_curated_"$area"_db|"$curate_table_name"|"$(echo $table_name_tmp_1|sed -e 's/\./\|/g'|tr -d '\015' ) >> $result_path"/"tmp_result.txt
        done
        for table_name_tmp_1 in $(cat $file_name  | sed -s 's/${hiveconf:dl_data_dt}/9999-12-31/g' | grep "hiveconf" | grep -i "join " | grep -i ","| awk -F"$" '{print "$"$2}'| awk -F" " '{print $1}'|sed -e 's/${hiveconf:environment}/'$environment'/g'| sed -e 's/${hiveconf:curateddb}/'$environment'_curated_'$area'_db/g' | tr '[:upper:]' '[:lower:]'| uniq ); do
            echo $curated_script_name"|"$environment"_curated_"$area"_db|"$curate_table_name"|"$(echo $table_name_tmp_1|sed -e 's/\./\|/g'|tr -d '\015' ) >> $result_path"/"tmp_result.txt
        done
    done
	echo "curated_script_name|curated_schema_name|curated_table_name|schema_name|table_name" > $result_path"/"$environment"_curated_"$area"_db_"result.txt
    sort $result_path"/"tmp_result.txt | uniq  >> $result_path"/"$environment"_curated_"$area"_db_"result.txt
    rm $result_path"/"tmp_result.txt
	echo "Result completed : "$result_path"/"$environment"_curated_"$area"_db_"result.txt
elif [[ ($curated_script != "" && $curated_script != "-skip") && ($list_file_of_curated_script == "" || $list_file_of_curated_script == "-skip") ]]; then
##List curated script name as expect
	file_name="/datagrid/"$environment"/curated/etl/"$area"/transform/"$curated_script
	echo "Curated File Name"$file_name
	curated_script_name=$(echo $curated_script | awk -F "/" '{print $NF}')
    curate_table_name=$(echo $curated_script_name | sed -e 's/cur_//g' | sed -e 's/.hql//g' | tr '[:upper:]' '[:lower:]' )
    for table_name_tmp_1 in $(grep "hiveconf" $file_name | grep -i "from " | awk -F"$" '{print "$"$2}'| awk -F" " '{print $1}'|sed -e 's/${hiveconf:environment}/'$environment'/g'| sed -e 's/${hiveconf:curateddb}/'$environment'_curated_'$area'_db/g' | tr '[:upper:]' '[:lower:]'| uniq ); do
        echo $curated_script_name"|"$environment"_curated_"$area"_db|"$curate_table_name"|"$(echo $table_name_tmp_1|sed -e 's/\./\|/g'|tr -d '\015' ) >> $result_path"/"tmp_result.txt
		done
    for table_name_tmp_1 in $(grep "hiveconf" $file_name | grep -i "join " | awk -F"$" '{print "$"$2}'| awk -F" " '{print $1}'|sed -e 's/${hiveconf:environment}/'$environment'/g'| sed -e 's/${hiveconf:curateddb}/'$environment'_curated_'$area'_db/g' | tr '[:upper:]' '[:lower:]'| uniq ); do
        echo $curated_script_name"|"$environment"_curated_"$area"_db|"$curate_table_name"|"$(echo $table_name_tmp_1|sed -e 's/\./\|/g'|tr -d '\015' ) >> $result_path"/"tmp_result.txt
    done
    for table_name_tmp_1 in $(grep "hiveconf" $file_name | grep -i "join " | grep -i ","| awk -F"$" '{print "$"$2}'| awk -F" " '{print $1}'|sed -e 's/${hiveconf:environment}/'$environment'/g'| sed -e 's/${hiveconf:curateddb}/'$environment'_curated_'$area'_db/g' | tr '[:upper:]' '[:lower:]'| uniq ); do
        echo $curated_script_name"|"$environment"_curated_"$area"_db|"$curate_table_name"|"$(echo $table_name_tmp_1|sed -e 's/\./\|/g'|tr -d '\015' ) >> $result_path"/"tmp_result.txt
    done
    for table_name_tmp_1 in $(grep "hiveconf" $file_name | grep -i "join " | grep -i ","| awk -F"$" '{print "$"$2}'| awk -F" " '{print $1}'|sed -e 's/${hiveconf:environment}/'$environment'/g'| sed -e 's/${hiveconf:curateddb}/'$environment'_curated_'$area'_db/g' | tr '[:upper:]' '[:lower:]'| uniq ); do
        echo $curated_script_name"|"$environment"_curated_"$area"_db|"$curate_table_name"|"$(echo $table_name_tmp_1|sed -e 's/\./\|/g'|tr -d '\015' ) >> $result_path"/"tmp_result.txt
    done
	echo "curated_script_name|curated_schema_name|curated_table_name|schema_name|table_name" > $result_path"/"$environment"_curated_"$area"_db."$curate_table_name"_"result.txt
	sort $result_path"/"tmp_result.txt | uniq >> $result_path"/"$environment"_curated_"$area"_db."$curate_table_name"_"result.txt
    rm $result_path"/"tmp_result.txt
	echo "Result completed : "$result_path"/"$environment"_curated_"$area"_db."$curate_table_name"_"result.txt
elif [[ ($curated_script == "" && $curated_script == "-skip") && ($list_file_of_curated_script != "" && $list_file_of_curated_script != "-skip") ]]; then
    for file_name in $(cat $list_file_of_curated_script  | uniq ); do
        curated_script=$file_name
		curated_script_name=$(echo $file_name | awk -F "/" '{print $NF}')
        curate_table_name=$(echo $curated_script_name | sed -e 's/cur_//g' | sed -e 's/.hql//g' | tr '[:upper:]' '[:lower:]' )
        for table_name_tmp_1 in $(cat $file_name  | sed -s 's/${hiveconf:dl_data_dt}/9999-12-31/g' | grep "hiveconf" | grep -i "from " | awk -F"$" '{print "$"$2}'| awk -F" " '{print $1}'|sed -e 's/${hiveconf:environment}/'$environment'/g'| sed -e 's/${hiveconf:curateddb}/'$environment'_curated_'$area'_db/g' | tr '[:upper:]' '[:lower:]'| uniq ); do
            echo $curated_script_name"|"$environment"_curated_"$area"_db|"$curate_table_name"|"$(echo $table_name_tmp_1|sed -e 's/\./\|/g'|tr -d '\015' ) >> $result_path"/"tmp_result.txt
		done
        for table_name_tmp_1 in $(cat $file_name  | sed -s 's/${hiveconf:dl_data_dt}/9999-12-31/g' | grep "hiveconf" | grep -i "join " | awk -F"$" '{print "$"$2}'| awk -F" " '{print $1}'|sed -e 's/${hiveconf:environment}/'$environment'/g'| sed -e 's/${hiveconf:curateddb}/'$environment'_curated_'$area'_db/g' | tr '[:upper:]' '[:lower:]'| uniq ); do
            echo $curated_script_name"|"$environment"_curated_"$area"_db|"$curate_table_name"|"$(echo $table_name_tmp_1|sed -e 's/\./\|/g'|tr -d '\015' ) >> $result_path"/"tmp_result.txt
        done
        for table_name_tmp_1 in $(cat $file_name  | sed -s 's/${hiveconf:dl_data_dt}/9999-12-31/g' | grep "hiveconf" | grep -i "join " | grep -i ","| awk -F"$" '{print "$"$2}'| awk -F" " '{print $1}'|sed -e 's/${hiveconf:environment}/'$environment'/g'| sed -e 's/${hiveconf:curateddb}/'$environment'_curated_'$area'_db/g' | tr '[:upper:]' '[:lower:]'| uniq ); do
            echo $curated_script_name"|"$environment"_curated_"$area"_db|"$curate_table_name"|"$(echo $table_name_tmp_1|sed -e 's/\./\|/g'|tr -d '\015' ) >> $result_path"/"tmp_result.txt
        done
        for table_name_tmp_1 in $(cat $file_name  | sed -s 's/${hiveconf:dl_data_dt}/9999-12-31/g' | grep "hiveconf" | grep -i "join " | grep -i ","| awk -F"$" '{print "$"$2}'| awk -F" " '{print $1}'|sed -e 's/${hiveconf:environment}/'$environment'/g'| sed -e 's/${hiveconf:curateddb}/'$environment'_curated_'$area'_db/g' | tr '[:upper:]' '[:lower:]'| uniq ); do
            echo $curated_script_name"|"$environment"_curated_"$area"_db|"$curate_table_name"|"$(echo $table_name_tmp_1|sed -e 's/\./\|/g'|tr -d '\015' ) >> $result_path"/"tmp_result.txt
        done
    done
	echo "curated_script_name|curated_schema_name|curated_table_name|schema_name|table_name" > $result_path"/"$environment"_curated_"$area"_db_"result.txt
    sort $result_path"/"tmp_result.txt | uniq  >> $result_path"/"$environment"_curated_"$area"_db_"result.txt
    rm $result_path"/"tmp_result.txt
	echo "Result completed : "$result_path"/"$environment"_curated_"$area"_db_"result.txt
fi
