#!/bin/bash
#############################################################################################################
## Script Name: GetAllPartitionName.sh                                                                     ##
## Description: Use this script to get all Partition column name and data type in each table               ##
##                                                                                                         ##
## Parameter:  Mandatory arguments                                                                         ##
##               -e      Environment e.g. dldev or dlsit or dluat or dlprod                                ##
##             Optional arguments                                                                          ##
##               -l      Level of Database e.g. raw, persist or curated                                    ##
##               -d      Database Name                                                                     ##
##               -t      Table Name                                                                        ##
##                                                                                                         ##
## Output result: The result file will be exported into path work_directory/result                         ##
##                ex. /datagrid/dldev/raw/etl/common/bin/result/                                           ##
##                                                                                                         ##
## Usage Usage: sh GetAllPartitionName.sh -e dluat -d dluat_curated_crcard_db                              ##
##                                                                                                         ##
## Revision History: 2018-04-23 : Intial (Charnwith J.)                                                    ##
##                                                                                                         ##
#############################################################################################################

#############################################################################################################
##   Set Parameter                                                                                         ##
#############################################################################################################
##Initial Value
environment=""
level_of_db=""
database_name=""
table_name=""

work_directory=$(pwd)
result_path=$work_directory"/result"

##Get Parameter
if [ $# -le 1 ]; then
    echo "Usage: `basename ${0}` -e Environment -a Area [-c Curate Script]"
	echo "Mandatory arguments                                         "
	echo "  -e      Environment e.g. dldev or dlsit or dluat or dlprod"
	echo "Optional arguments                                          "
	echo "  -l      Level of Database e.g. raw, persist or curated    "
	echo "  -d      Database Name                                     "
	echo "  -t      Table Name                                        "
	exit 1
elif [ $# -ge 2 ] && [ $# -le 8 ] ; then
    while getopts ":e:l:d:t:" opt; do
        case $opt in 
            "e") 
                    environment=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    echo "Environment: "$environment
                    ;;
            "l") 
                    level_of_db=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    echo "Database Level: "$level_of_db
                    ;;
            "d")    
                    database_name=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    echo "Database Name: "$database_name
                    ;;
            "t")    
                    table_name=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    echo "Table Name: "$table_name
                    ;;
            \?)
                        echo "Invalid option: -$OPTARG"
                        exit 1
                        ;;
        esac
    done
fi

if [[ $environment != "dldev" && $environment != "dlsit" && $environment != "dluat" && $environment != "dlprod" ]]; then
    echo "Error!! This environment '"$environment"' doesn't exist.."
	echo "Hint: his environment should be dldev, dlsit, dluat or dlprod"
    exit 1
fi

if [[ $level_of_db != "raw" && $level_of_db != "persist" && $level_of_db != "curated" && $level_of_db != "" ]]; then
    echo "Error!! This Database Level '"$level_of_db"' doesn't exist.."
	echo "Hint: Database Level should be raw, persist or curated"
    exit 1
fi

##Make Result Directory
mkdir -p $result_path


##############################################################################################################
##   Executer Process                                                                                       ##
##############################################################################################################
echo "" > $result_path"/"partition_table_list_tmp.txt
echo "" > $result_path"/"partition_database_list_tmp.txt
echo "" > $result_path"/"partition_column_list_tmp.txt
echo "" > $result_path"/"partition_column_value_tmp.txt
echo "" > $result_path"/"partition_column_final.txt

cd $result_path
if [[ ($database_name == "" || $database_name == "-skip")  && ($table_name == "" || $table_name == "-skip") && ($level_of_db == "" || $level_of_db == "-skip") ]] ; then
    hive -e "show databases" > partition_database_list_tmp.txt
	grep ^$environment partition_database_list_tmp.txt | grep "_db"$ > partition_database_list.txt
    rm partition_database_list_tmp.txt
elif [[ ($level_of_db != "" || $level_of_db != "-skip") && ($database_name == "" || $database_name == "-skip") && ($table_name == "" || $table_name == "-skip") ]] ; then 
    hive -e "show databases" > partition_database_list_tmp.txt
	grep ^$environment partition_database_list_tmp.txt | grep "_db"$ | grep $level_of_db > partition_database_list.txt
    rm partition_database_list_tmp.txt
elif [[ ($database_name != "" || $database_name != "-skip") && ($table_name == "" || $table_name == "-skip") ]] ; then
    hive -e "show databases" > partition_database_list_tmp.txt
	grep ^$environment partition_database_list_tmp.txt | grep "_db"$ | grep $database_name > partition_database_list.txt
    rm partition_database_list_tmp.txt
fi


echo "schema_name|table_name|partition_column_name|partition_value" > $result_path"/"partition_column_final.txt
if [[ ($table_name == "" || $table_name == "-skip")  ]] ; then
    for database_name in $(cat $result_path"/"partition_database_list.txt); do
    	    hive -e "show tables in "$database_name > $database_name"_"partition_table_list_tmp.txt
    	    grep -v "\." $database_name"_"partition_table_list_tmp.txt | grep -v ":"  > $database_name"_"partition_table_list.txt
            rm $database_name"_"partition_table_list_tmp.txt
    	
    	    for table_name in $(grep -v "^WARN:" $result_path"/"$database_name"_"partition_table_list.txt); do
    	        hive --database $database_name -S -e "SHOW TABLE EXTENDED LIKE "$table_name | grep "partitionColumns:struct partition_columns" | sed 's/partitionColumns:struct partition_columns { //g' | sed -s 's/}//g' | sed -s 's/, /\//g' | sed -s 's/ /./g' > partition_column_list_tmp.txt
				hive --database $database_name -S -e "SHOW partitions "$table_name  > partition_column_value_tmp.txt
				for column_name in $(grep -v "^WARN:" $result_path"/"partition_column_list_tmp.txt); do
    			    for column_value in $(grep -v "^WARN:" $result_path"/"partition_column_value_tmp.txt); do
				        echo $database_name"|"$table_name"|"$column_name"|"$column_value>>  partition_column_final.txt
                    done
 			    done
    			rm partition_column_list_tmp.txt
    		done
    		rm $database_name"_"partition_table_list.txt
    done
elif [[  ($database_name != "" || $database_name != "-skip") && ($table_name != "" || $table_name != "-skip")  ]] ; then
        hive --database $database_name -S -e "SHOW TABLE EXTENDED LIKE "$table_name | grep "partitionColumns:struct partition_columns" | sed 's/partitionColumns:struct partition_columns { //g' | sed -s 's/}//g' | sed -s 's/, /\//g' | sed -s 's/ /./g' > partition_column_list_tmp.txt
    	hive --database $database_name -S -e "SHOW partitions "$table_name  > partition_column_value_tmp.txt
		for column_name in $(grep -v "^WARN:" $result_path"/"partition_column_list_tmp.txt); do
    		for column_value in $(grep -v "^WARN:" $result_path"/"partition_column_value_tmp.txt); do
				echo $database_name"|"$table_name"|"$column_name"|"$column_value>>  partition_column_final.txt
            done
 		done
    	rm partition_column_list_tmp.txt
fi

rm partition_table_list_tmp.txt
rm partition_database_list_tmp.txt
rm partition_column_value_tmp.txt