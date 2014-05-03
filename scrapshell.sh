echo "Check if Hadoop Process is Running or Not !!"

ISHADOOPRUNNING=$(ps aux | grep hadoop | tr -s ' ' | cut -d " " -f 2)

if [[ -n $ISHADOOPRUNNING ]]; then
	#statements
	for line in $ISHADOOPRUNNING ; do 
	kill -9 $line
	done
fi