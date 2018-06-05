#!/bin/bash
#############################################################################################################
## Script Name: MoveDataDeployment.sh                                                                      ##
## Description: Use this script to move data step as below:                                                ##
##              1. Move Target data to backup location                                                     ##
##              2. Move Source data to target location                                                     ##
##                                                                                                         ##
## Parameter:    -f      Full Path of Table List                                                           ##
##                                                                                                         ##
## Output result: Moving log file                                                                          ##
##                                                                                                         ##
## Usage Usage: ex. sh MoveDataDeployment.sh -f fileName.txt                                               ##
##                                                                                                         ##
## Revision History: 2018-06-05 : Initial (Charnwith J.)                                                   ##
##                                                                                                         ##
#############################################################################################################

#############################################################################################################
##   Set Parameter                                                                                         ##
#############################################################################################################
##Initial Value
fullpath_file=""

work_directory=$(pwd)
log_path=$work_directory"/log_moving/"

##Get Parameter
if [ $# -le 1 ]; then
    echo "Parameter:    -f      Full Path of Table List               "
    exit 1
elif [ $# -ge 2 ] && [ $# -le 2 ]; then
    while getopts ":f:" opt; do
        case $opt in 
            "f") 
                    fullpath_file=$(echo $OPTARG | tr '[:upper:]' '[:lower:]')
                    echo "INFO: Fullpath File: "$fullpath_file
                    ;;

            \?)
                    echo "ERROR: Invalid option: -$OPTARG"
                    exit 1
                    ;;
        esac
    done
fi


#############################################################################################################
##   Pre Processing                                                                                        ##
#############################################################################################################
#"hdfs://DEV-NNHA/discovery/migrate_stnd/curated/<<DB_NAME>>/<<TABLE_NAME>>"

##Make Log Directory
mkdir -p $log_path

##Initial Output Nam
log_name=$log_path"/moving_log_$(basename $fullpath_file| cut -d'.' -f1)_$(date '+%Y%m%d%H%M%S' ).log"

echo "=======================================================================================================================================" > $log_name
echo "Start Process $(date)" >> $log_name
echo "=======================================================================================================================================" >> $log_name

#############################################################################################################
##   Execute Process                                                                                       ##
#############################################################################################################


for filename in $(cat $fullpath_file | sed '1d'); do

   src_table=$( echo $filename | awk -F'|' '{print $1}')
   src_location=$( echo $filename | awk -F'|' '{print $2}')
   trgt_table=$( echo $filename | awk -F'|' '{print $3}')
   trgt_location=$( echo $filename | awk -F'|' '{print $4}')
   
   tbl_name_len=$(expr ${#trgt_location} - ${#trgt_table} - 2)
   bk_location=$( echo $trgt_location | cut -c1-$tbl_name_len )"_bk/"$(echo $trgt_table | awk -F'.' '{print $1}')"/"
 
   echo "Start backup existing data: Table $trgt_table To "$bk_location$(echo $trgt_table | awk -F'.' '{print $2}')"/ [ $(date) ]" 
   echo "Start backup existing data: Table $trgt_table To "$bk_location$(echo $trgt_table | awk -F'.' '{print $2}')"/ [ $(date) ]"  >> $log_name
   
   hdfs dfs -mkdir -p $bk_location &>> $log_name
   if [ "$?" -eq "0" ] ; then 
       echo "create backup location successfully"  >> $log_name
   else
       echo "create backup location failure"  >> $log_name
   fi 
   echo "===============================================================================" >> $log_name
   
   hdfs dfs -mv $trgt_location $bk_location &>> $log_name
   if [ "$?" -eq "0" ] ; then 
       echo "backup existing data successfully"  >> $log_name
   else
       echo "backup existing data failure"  >> $log_name
   fi 
   echo "===============================================================================" >> $log_name
   
   hdfs dfs -ls $bk_location$(echo $trgt_table | awk -F'.' '{print $2}')"/" &>> $log_name
   
   echo "=======================================================================================================================================" >> $log_name
   echo "Finish backup existing data: Table $trgt_table [ $(date) ]"
   echo "Finish backup existing data: Table $trgt_table [ $(date) ]" >> $log_name
   echo "=======================================================================================================================================" >> $log_name
   
done

for filename in $(cat $fullpath_file | sed '1d'); do

   src_table=$( echo $filename | awk -F'|' '{print $1}')
   src_location=$( echo $filename | awk -F'|' '{print $2}')
   trgt_table=$( echo $filename | awk -F'|' '{print $3}')
   trgt_location=$( echo $filename | awk -F'|' '{print $4}')
   
   src_table_name=$( echo $src_table | awk -F'.' '{print $2}')
   trgt_table_name=$( echo $trgt_table | awk -F'.' '{print $2}')
   
   trgt_path=$(echo $trgt_location | sed 's,'"$trgt_table_name/"',,g')
   
   echo "Start move existing data: Table $trgt_table from $src_table [ $(date) ]" 
   echo "Start move existing data: Table $trgt_table from $src_table [ $(date) ]"  >> $log_name
   
   hdfs dfs -mv $src_location $trgt_path &>> $log_name
   if [ "$?" -eq "0" ] ; then 
       echo "move existing data successfully"  >> $log_name
   else
       echo "move existing data failure"  >> $log_name
   fi 	
   echo "===============================================================================" >> $log_name
   
   echo "=== Check result ===" >> $log_name
   hdfs dfs -ls $trgt_location &>> $log_name
   echo ""
   hdfs dfs -ls $( echo $src_location | sed 's,'"$src_table_name/"',,g') &>> $log_name
   echo "===============================================================================" >> $log_name
   
   echo "=== MSCK REPAIR TABLE ===" >> $log_name
   hive -e "MSCK REPAIR TABLE $trgt_table;" &>> $log_name
   hive -e "MSCK REPAIR TABLE $src_table;" &>> $log_name
   echo "=======================================================================================================================================" >> $log_name
   echo "Finish backup existing data: Table $trgt_table [ $(date) ]"
   echo "Finish backup existing data: Table $trgt_table [ $(date) ]" >> $log_name
   echo "=======================================================================================================================================" >> $log_name
   
done


#############################################################################################################
##   Post Processing                                                                                       ##
#############################################################################################################

echo "Finish Process $(date)" >> $log_name
echo "=======================================================================================================================================" >> $log_name
