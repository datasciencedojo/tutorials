# Scale R to Big Data Using Hadoop and Spark

Meetup Page: [http://www.meetup.com/data-science-dojo/events/231449206/](http://www.meetup.com/data-science-dojo/events/231449206/)

## Requirements
* Azure subscription or free trial account
	* [30 day free trial](https://azure.microsoft.com/en-us/pricing/free-trial/)
* [Github.com](https://github.com/) account (to recieve code)
* Text Editor, I'll be using [Sublime Text 3](https://www.sublimetext.com/3)
* [R Installed](https://cran.r-project.org/bin/windows/base/)
* [RStudio](https://www.rstudio.com/products/rstudio/download/)
* Windows Only: [Putty](https://the.earth.li/~sgtatham/putty/latest/x86/putty.exe)

## Cloning the Repo for Code & Materials
```
git clone https://www.github.com/datasciencedojo/meetup.git
```
Folder: scaling\_r\_to\_big\_data

## The data

Public dataset of air travel delays:
~1.2 gb
~12.5 million rows
44 columns
[https://packages.revolutionanalytics.com/datasets/AirOnTimeCSV2012/](https://packages.revolutionanalytics.com/datasets/AirOnTimeCSV2012/)

## Setting up an R Cluster

Source: [Microsoft](https://azure.microsoft.com/en-us/documentation/articles/hdinsight-hadoop-r-server-get-started/ )

1. Sign in to the [Azure portal](https://portal.azure.com).

2. Select __NEW__, __Data + Analytics__, and then __HDInsight__.

    ![Image of creating a new cluster](/scaling_r_to_big_data/media/newcluster.png)

3. Enter a name for the cluster in the __Cluster Name__ field. If you have multiple Azure subscriptions, use the __Subscription__ entry to select the one you want to use.

    ![Cluster name and subscription selections](/scaling_r_to_big_data/media/clustername.png)

4. Select __Select Cluster Type__. On the __Cluster Type__ blade, select the following options:

    * __Cluster Type__: R Server on Spark
    
    * __Cluster Tier__: Premium

    Leave the other options at the default values, then use the __Select__ button to save the cluster type.
    
    ![Cluster type blade screenshot](/scaling_r_to_big_data/media/clustertypeconfig.png)
    
    > [AZURE.NOTE] You can also add R Server to other HDInsight cluster types (such as Hadoop or HBase,) by selecting the cluster type, and then selecting __Premium__.

5. Select **Resource Group** to see a list of existing resource groups and then select the one to create the cluster in. Or, you can select **Create New** and then enter the name of the new resource group. A green check will appear to indicate that the new group name is available.

    > [AZURE.NOTE] This entry will default to one of your existing resource groups, if any are available.
    
    Use the __Select__ button to save the resource group.

6. Select **Credentials**, then enter a **Cluster Login Username** and **Cluster Login Password**.

    Enter an __SSH Username__ and select __Password__, then enter the __SSH Password__ to configure the SSH account. SSH is used to remotely connect to the cluster using a Secure Shell (SSH) client.
    
    Use the __Select__ button to save the credentials.
    
    ![Credentials blade](/scaling_r_to_big_data/media/clustercredentials.png)

7. Select **Data Source** to select a data source for the cluster. Either select an existing storage account by selecting __Select storage account__ and then selecting the account, or create a new account using the __New__ link in the __Select storage account__ section.

    If you select __New__, you must enter a name for the new storage account. A green check will appear if the name is accepted.

    The __Default Container__ will default to the name of the cluster. Leave this as the value.
    
    Select __Location__ to select the region to create the storage account in.
    
    > [AZURE.IMPORTANT] Selecting the location for the default data source will also set the location of the HDInsight cluster. The cluster and default data source must be located in the same region.

    Use the **Select** button to save the data source configuration.
    
    ![Data source blade](/scaling_r_to_big_data/media/datastore.png)

8. Select **Node Pricing Tiers** to display information about the nodes that will be created for this cluster. Unless you know that you'll need a larger cluster, leave the number of worker nodes at the default of `4`. The estimated cost of the cluster will be shown within the blade.

    ![Node pricing tiers blade](/scaling_r_to_big_data/media/pricingtier.png)

    Use the **Select** button to save the node pricing configuration.
    
9. On the **New HDInsight Cluster** blade, make sure that **Pin to Startboard** is selected, and then select **Create**. This will create the cluster and add a tile for it to the Startboard of your Azure Portal. The icon will indicate that the cluster is creating, and will change to display the HDInsight icon once creation has completed.

    | While creating | Creation complete |
    | ------------------ | --------------------- |
    | ![Creating indicator on startboard](/scaling_r_to_big_data/media/provisioning.png) | ![Created cluster tile](/scaling_r_to_big_data/media/provisioned.png) |

    > [AZURE.NOTE] It will take some time for the cluster to be created, usually around 15~40 minutes. Use the tile on the Startboard, or the **Notifications** entry on the left of the page to check on the creation process.

### SSH Into Edge Node
Please be aware that R Server is not installed on the head/master/name node, but on the edge node

1. Find the edge node SSH address by selecting your cluster then, __All Settings__, __Apps__, and __RServer__. Copy the SSH endpoint.

    ![Image of the SSH Endpoint for the edge node](/scaling_r_to_big_data/media/sshendpoint.png)

2. Connect to the edge node using an SSH client.
    You can ignore SSH keys for the purposes of this lab. In production it is highly recommended that you use SSH keys rather than username/password authentication.
    * [Windows: Putty](https://azure.microsoft.com/en-us/documentation/articles/hdinsight-hadoop-linux-use-ssh-unix/)
    * [Mac or Linux: ssh client in terminal](https://azure.microsoft.com/en-us/documentation/articles/hdinsight-hadoop-linux-use-ssh-windows/)

3. Enter your SSH username and password.

4. Type R within the console to begin. Capital R.
```
R
```

To exit the R Console:
```
quit()
```
### Installing R Studio Server into the Cluster

Source: [Microsoft](https://azure.microsoft.com/en-us/documentation/articles/hdinsight-hadoop-r-server-install-r-studio/)

2. Once you are connected, become a root user on the cluster. In the SSH session, use the following command.

        sudo su -

3. Download the custom script to install RStudio. Use the following command.

        wget http://mrsactionscripts.blob.core.windows.net/rstudio-server-community-v01/InstallRStudio.sh

4. Change the permissions on the custom script file and run the script. Use the following commands.

        chmod 755 InstallRStudio.sh
        ./InstallRStudio.sh

5. If you used an SSH password while creating an HDInsight cluster with R Server, you can skip this step and proceed to the next. If you used an SSH key instead to create the cluster, you must set a password for your SSH user. You will need this password when connecting to RStudio. Run the following commands. When prompted for **Current Kerberos password**, just press **ENTER**.

        passwd remoteuser
        Current Kerberos password:
        New password:
        Retype new password:
        Current Kerberos password:
        
    If your password is successfully set, you should see a message like this.

        passwd: password updated successfully


    Exit the SSH session.

6. Create an SSH tunnel to the cluster by mapping `localhost:8787` on the HDInsight cluster to the client machine. You must create an SSH tunnel before opening a new browser session.

    * On a Linux client or a Windows client (using [Cygwin](http://www.redhat.com/services/custom/cygwin/)), open a terminal session and use the following command.

            ssh -L localhost:8787:localhost:8787 USERNAME@r-server.CLUSTERNAME-ssh.azurehdinsight.net
            
        Replace **USERNAME** with an SSH user for your HDInsight cluster, and replace **CLUSTERNAME** with the name of your HDInsight cluster       

    * On a Windows client create an SSH tunnel PuTTY.

        1.  Open PuTTY, and enter your connection information. If you are not familiar with PuTTY, see [Use SSH with Linux-based Hadoop on HDInsight from Windows](hdinsight-hadoop-linux-use-ssh-windows.md) for information on how to use it with HDInsight.
        2.  In the **Category** section to the left of the dialog, expand **Connection**, expand **SSH**, and then select **Tunnels**.
        3.  Provide the following information on the **Options controlling SSH port forwarding** form:

            * **Source port** - The port on the client that you wish to forward. For example, **8787**.
            * **Destination** - The destination that must be mapped to the local client machine. For example, **localhost:8787**.

            ![Create an SSH tunnel](/scaling_r_to_big_data/media/createsshtunnel.png "Create an SSH tunnel")

        4. Click **Add** to add the settings, and then click **Open** to open an SSH connection.
        5. When prompted, log in to the server. This will establish an SSH session and enable the tunnel.

7. Open a web browser and enter the following URL based on the port you entered for the tunnel.

        http://localhost:8787/ 

8. You will be prompted to enter the SSH username and password to connect to the cluster. If you used an SSH key while creating the cluster, you must enter the password you created in step 5 above.

    ![Connect to R Studio](/scaling_r_to_big_data/media/connecttostudio.png "Create an SSH tunnel")

9. To test whether the RStudio installation was successful, you can run a test script that executes R based MapReduce and Spark jobs on the cluster. Go back to the SSH console and enter the following commands to download the test script to run in RStudio.

    * If you created a Hadoop cluster with R, use this command.
        
            wget http://mrsactionscripts.blob.core.windows.net/rstudio-server-community-v01/testhdi.r

    * If you created a Spark cluster with R, use this command.

            wget http://mrsactionscripts.blob.core.windows.net/rstudio-server-community-v01/testhdi_spark.r

10. In RStudio, you will see the test script you downloaded. Double click the file to open it, select the contents of the file, and then click **Run**. You should see the output in the **Console** pane.
 
    ![Test the installation](/scaling_r_to_big_data/media/test-r-script.png "Test the installation")


### Predictive Model
```
# Where are we? What is our directory?
rxHadoopListFiles("/")

# Set the HDFS (WASB) location of example data
bigDataDirRoot <- "/example/data"

# create a local folder for storaging data temporarily
source <- "/tmp/AirOnTimeCSV2012"
dir.create(source)

# Download data to the tmp folder, 12 parts
remoteDir <- "http://packages.revolutionanalytics.com/datasets/AirOnTimeCSV2012"
download.file(file.path(remoteDir, "airOT201201.csv"), file.path(source, "airOT201201.csv"))
download.file(file.path(remoteDir, "airOT201202.csv"), file.path(source, "airOT201202.csv"))
download.file(file.path(remoteDir, "airOT201203.csv"), file.path(source, "airOT201203.csv"))
download.file(file.path(remoteDir, "airOT201204.csv"), file.path(source, "airOT201204.csv"))
download.file(file.path(remoteDir, "airOT201205.csv"), file.path(source, "airOT201205.csv"))
download.file(file.path(remoteDir, "airOT201206.csv"), file.path(source, "airOT201206.csv"))
download.file(file.path(remoteDir, "airOT201207.csv"), file.path(source, "airOT201207.csv"))
download.file(file.path(remoteDir, "airOT201208.csv"), file.path(source, "airOT201208.csv"))
download.file(file.path(remoteDir, "airOT201209.csv"), file.path(source, "airOT201209.csv"))
download.file(file.path(remoteDir, "airOT201210.csv"), file.path(source, "airOT201210.csv"))
download.file(file.path(remoteDir, "airOT201211.csv"), file.path(source, "airOT201211.csv"))
download.file(file.path(remoteDir, "airOT201212.csv"), file.path(source, "airOT201212.csv"))

# Set directory in bigDataDirRoot to load the data into
inputDir <- file.path(bigDataDirRoot,"AirOnTimeCSV2012")

# Make the directory
rxHadoopMakeDir(inputDir)

# Copy the data from source to input
rxHadoopCopyFromLocal(source, bigDataDirRoot)

# Define the HDFS (WASB) file system
hdfsFS <- RxHdfsFileSystem()

# Create info list for the airline data
airlineColInfo <- list(
    DAY_OF_WEEK = list(type = "factor"),
    ORIGIN = list(type = "factor"),
    DEST = list(type = "factor"),
    DEP_TIME = list(type = "integer"),
    ARR_DEL15 = list(type = "logical"))

# get all the column names
varNames <- names(airlineColInfo)

# Define the text data source in hdfs
airOnTimeData <- RxTextData(inputDir, colInfo = airlineColInfo, varsToKeep = varNames, fileSystem = hdfsFS)

# formula to use
formula = "ARR_DEL15 ~ ORIGIN + DAY_OF_WEEK + DEP_TIME + DEST"

# Set a Spark compute context
myContext <- RxSpark()
rxSetComputeContext(myContext)   

# Run a logistic regression
system.time(
    myModel <- rxLogit(formula, data = airOnTimeData)
)
# Display a summary 
summary(myModel)

# Random forest
# Help: http://www.rdocumentation.org/packages/RevoScaleR/functions/rxDForest
system.time(
    myModel <- rxDForest(formula, data = airOnTimeData)
)
# Display a summary 
summary(myModel)

# Other Models: http://www.rdocumentation.org/packages/RevoScaleR

# Converts the distributed forest to a normal random forest
myModel.Forest <- as.randomForest(myModel)

# Saving your forest
save(myModel.Forest,file = "awesomeModel.RData")
```

Download the RDATA file. Load it to your local machine.
```
# install.packages(randomForest)
library(randomForest)
my.local.forest <- load("awesomeModel.RData")
```