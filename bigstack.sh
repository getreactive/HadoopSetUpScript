#!/bin/sh
# echo "Please enter sudo password:"
# stty -echo
# read password
# stty echo
# SUDOPASS=$password
#echo $SUDOPASS

echo "Check if Hadoop Process is Running or Not !!"

ISHADOOPRUNNING=$(ps aux | grep hadoop | tr -s ' ' | cut -d " " -f 2)

# Adding one extra process ant end need to delete it 2479 2572 2721 2883 2982 30016 ** here 3--16 should be remove

if [[ -n $ISHADOOPRUNNING ]]; then
	#statements
	for line in $ISHADOOPRUNNING ; do 
	kill -9 $line
	done
fi

echo "Installing openssh-server "
sudo apt-get install openssh-server
echo "Keygen for password less SSH "
ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
ssh-add
echo "Login to ssh "
ssh localhost 'sleep 5 &'

echo "SSH Checked"

echo "Creating temprory folder for installaton \n"
tempname="tempbiginstall"
username=$USER
foldername=$username$tempname
hadoopfolder=/usr/local/hadoop
echo $foldername
if [ -d ~/"$foldername" ]; then
  # Control will enter here if $DIRECTORY exists.
  echo $foldername
  sudo rm -r ~/$foldername
fi
if [ -d "$hadoopfolder" ]; then
  # Control will enter here if $DIRECTORY exists.
  sudo rm -r $hadoopfolder
fi
echo "Creating folder :- "
mkdir -p ~/$foldername
cd ~/$foldername
echo "Downloading Hadoop2.2.0 ..\n"
wget http://mirror.cc.columbia.edu/pub/software/apache/hadoop/common/stable/hadoop-2.2.0.tar.gz
tar -xvzf hadoop-2.2.0.tar.gz
mv hadoop-2.2.0 hadoop

if [ -d ~/hadoop/data/namenode ]; then
	sudo rm -r ~/hadoop/data/namenode
fi
if [ -d ~/hadoop/data/datanode ]; then
	sudo rm -r ~/hadoop/data/datanode
fi

mkdir -p ~/hadoop/data/namenode
mkdir -p ~/hadoop/data/datanode
coresite="hadoop/etc/hadoop/core-site.xml"
hdfssite="hadoop/etc/hadoop/hdfs-site.xml"
echo "Remaming mapred-site.xml.template to mapred-site.xml \n"
cp hadoop/etc/hadoop/mapred-site.xml.template hadoop/etc/hadoop/mapred-site.xml
mapredsite="hadoop/etc/hadoop/mapred-site.xml"
yarnsite="hadoop/etc/hadoop/yarn-site.xml"

echo "Editing hadoop-env.sh \n"

#For Java 7
sed -i 's/.*export JAVA_HOME=.*/export JAVA_HOME=\/usr\/lib\/jvm\/java-7-openjdk-amd64\//' hadoop/etc/hadoop/hadoop-env.sh
#For java 8
#s ed -i 's/.*export JAVA_HOME=.*/export JAVA_HOME=\/usr\/lib\/jvm\/java-8-oracle\//' hadoop/etc/hadoop/hadoop-env.sh
echo "Editing Core-site.xml \n"
sed -i 's/<configuration>/<configuration>\n\n \n<property>\n<name>fs.default.name<\/name>\n<value>hdfs:\/\/localhost:9000<\/value>\n<\/property> \n/g' $coresite
echo " Editing hdfs-site.xml \n"
sed -i 's/<configuration>/<configuration>\n\n<property> \n <name>dfs.replication<\/name> \n <value>1<\/value> \n <\/property> \n <property> \n <name>dfs.namenode.name.dir<\/name> \n <value>${user.home}\/hadoop\/data\/namenode<\/value> \n <\/property>\n<property><name>dfs.datanode.data.dir<\/name>\n<value>${user.home}\/hadoop\/data\/datanode<\/value>\n<\/property> \n/g' $hdfssite
echo " Editing yarn-site.xml \n"
sed -i 's/<configuration>/<configuration>\n\n<property> \n <name>yarn.nodemanager.aux-services<\/name> \n <value>mapreduce_shuffle<\/value> \n <\/property> \n <property> \n <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class<\/name> \n <value>org.apache.hadoop.mapred.ShuffleHandler<\/value>\n<\/property> \n\n/g' $yarnsite
echo " Editing mapred-site.xml \n"
sed -i 's/<configuration>/<configuration>\n\n<property> \n <name>mapreduce.framework.name<\/name> \n <value>yarn<\/value>\n<\/property>\n\n/g' $mapredsite

echo "Moving Hadoop folder to /usr/local/ Directory !!"
sudo mv hadoop /usr/local/

#cd /usr/local/hadoop

BASHRCLOC=~/.bashrc
BASH_BASHRCLOC=/etc/bash.bashrc

echo "Editing Environment Variable !! \n"

if [ -e $BASHRCLOC ]; then

	echo "Removing Variables"

	sed '/JAVA_HOME/d' $BASHRCLOC
	sed '/HADOOP_HOME/d' $BASHRCLOC
	sed '/HADOOP_INSTALL/d' $BASHRCLOC
	sed '/HADOOP_PREFIX/d' $BASHRCLOC
	sed '/HADOOP_COMMON_LIB_NATIVE_DIR/d' $BASHRCLOC
	sed '/HADOOP_OPTS/d' $BASHRCLOC
	sed '/HADOOP_MAPRED_HOME/d' $BASHRCLOC
	sed '/HADOOP_COMMON_HOME/d' $BASHRCLOC
	sed '/HADOOP_HDFS_HOME/d' $BASHRCLOC
	sed '/YARN_HOME/d' $BASHRCLOC

	echo " Editing file"
	echo "export JAVA_HOME=`dirname $(readlink /etc/alternatives/java)`" | sed -r 's/(.*)\/jre.*/\1/' | sudo tee -a ~/.bashrc
	echo "export HADOOP_HOME=/usr/local/hadoop" | sudo tee -a ~/.bashrc
	echo "export HADOOP_INSTALL=/usr/local/hadoop" | sudo tee -a ~/.bashrc
	echo "export HADOOP_PREFIX=/usr/local/hadoop" | sudo tee -a ~/.bashrc
	#echo "export HADOOP_COMMON_LIB_NATIVE_DIR=/usr/local/hadoop/lib" | sudo tee -a ~/.bashrc
	#echo "export HADOOP_OPTS="/usr/local/hadoop -Djava.library.path=/usr/local/hadoop/lib"" | sudo tee -a ~/.bashrc
	echo "export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native" | sudo tee -a ~/.bashrc
	echo "export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"" | sudo tee -a ~/.bashrc
	echo "export HADOOP_MAPRED_HOME=/usr/local/hadoop" | sudo tee -a ~/.bashrc
	echo "export HADOOP_COMMON_HOME=/usr/local/hadoop" | sudo tee -a  ~/.bashrc
	echo "export HADOOP_HDFS_HOME=/usr/local/hadoop" | sudo tee -a ~/.bashrc
	echo "export YARN_HOME=/usr/local/hadoop" | sudo tee -a ~/.bashrc
	echo "export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin" | sudo tee -a ~/.bashrc
	
fi
if [ -e /etc/bash.bashrc ]; then
	
	sed '/JAVA_HOME/d' /etc/bash.bashrc
	sed '/HADOOP_HOME/d' /etc/bash.bashrc
	sed '/HADOOP_INSTALL/d' /etc/bash.bashrc
	sed '/HADOOP_PREFIX/d' /etc/bash.bashrc
	sed '/HADOOP_COMMON_LIB_NATIVE_DIR/d' /etc/bash.bashrc
	sed '/HADOOP_OPTS/d' /etc/bash.bashrc
	sed '/HADOOP_MAPRED_HOME/d' /etc/bash.bashrc
	sed '/HADOOP_COMMON_HOME/d' /etc/bash.bashrc
	sed '/HADOOP_HDFS_HOME/d' /etc/bash.bashrc
	sed '/YARN_HOME/d' /etc/bash.bashrc
	
	echo " Editing file"
	echo "export JAVA_HOME=`dirname $(readlink /etc/alternatives/java)`" | sed -r 's/(.*)\/jre.*/\1/' | sudo tee -a /etc/bash.bashrc
	echo "export HADOOP_HOME=/usr/local/hadoop" | sudo tee -a /etc/bash.bashrc
	echo "export HADOOP_INSTALL=/usr/local/hadoop" | sudo tee -a /etc/bash.bashrc
	echo "export HADOOP_PREFIX=/usr/local/hadoop" | sudo tee -a /etc/bash.bashrc
	echo "export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native" | sudo tee -a /etc/bash.bashrc
	echo "export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib"" | sudo tee -a /etc/bash.bashrc
	#echo "export HADOOP_OPTS="/usr/local/hadoop -Djava.library.path=/usr/local/hadoop/lib"" | sudo tee -a /etc/bash.bashrc
	echo "export HADOOP_MAPRED_HOME=/usr/local/hadoop" | sudo tee -a /etc/bash.bashrc
	echo "export HADOOP_COMMON_HOME=/usr/local/hadoop" | sudo tee -a  /etc/bash.bashrc
	echo "export HADOOP_HDFS_HOME=/usr/local/hadoop" | sudo tee -a /etc/bash.bashrc
	echo "export YARN_HOME=/usr/local/hadoop" | sudo tee -a /etc/bash.bashrc
	echo "export PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin" | sudo tee -a /etc/bash.bashrc

	#source /etc/bash.bashrc
fi


sudo exec ~/.bashrc

hadoop version
hdfs namenode -format
start-dfs.sh
start-yarn.sh
jps
