## Objectives

In this lab, you learn how to do the following:
- Deploy an Enterprise Manager Marketplace Image.
- Install Agents.
- View monitoring details and set alerts.

## Requirements

To complete this lab, you will have needed to do the following:
- Installed Enterprise Manager Marketplace Image on a Private IP:
    - Followed Steps in the Networking Lab (EXACS-Networking.md) to setting up an app subnet in your ExaCS compartment
- Created a preexisting EM with Fast Connect to connect to OCI infrastructure


## Challenge
Follow these general steps:
Deploy Enterprise Manager Marketplace Image:
1. Setting Up Policies/Pre-reqs
2. Provision Marketplace Image
3. Logging into the Image
Install Agents:
4. Set up credentials in Enterprise Manager
5. Add host target manually
6. Add Non-Host targets using a guided process
View monitoring details/ set alerts:
7. View monitoring details/set alerts
8. Creating Groups
9. Viewing Monitoring Details

## Step-by-Step Instructions


### Part 1: Setting Up Policies/Pre-reqs

- Reference the [documentation](https://blogs.oracle.com/oem/oracle-enterprise-manager-is-now-available-on-oracle-cloud-marketplace) here to help set up your EM Markeplace Image.

- Keep in mind that the following steps must be executed by an OCI ADMIN, and that it is assumed you already have an Exa compartment setup.

- Navigate to the Exa compartment and copy the compartment OCID.

![](./images/dbsec/lab6EM/NavigatetoCompartment.png " ")
![](./images/dbsec/lab6EM/CopyCompartmentOCID.png " ")

- From the navigation menu, under 'Identity', click **Dynamic Groups**

![](./images/dbsec/lab6EM/NavigateOCIDDynamic.png " ")

- Click **Create Dynamic Group**

-  Name your dynamic group **OEM_GROUP**, give it a description, and optionally give it a tag.

![](./images/dbsec/lab6EM/CreateOCIDDynamicGroup.png " ")

-----

- In the **Matching Rules** section, type the following for 'Rule 1':
``` 
<copy>ALL {instance.compartment.id = '<compartment ocid>'}</copy>
```
- Click **Create Dynamic Group**

- Now, from the navigation menu, under 'Identity' click on **Policies**

![](./images/dbsec/lab6EM/NavigateOCIPolicies.png " ")

- Under 'List Scope', select the 'root' compartment.

![](./images/dbsec/lab6EM/ChangetorootCompartment.png " ")

- Click **Create Policy**

- Name your policy **OEM_Policy** and provide an optional description.

- Under 'Policy Statements', provide the following:

```
<copy>Allow dynamic-group OEM_Group to manage instancefamily in tenancy</copy>
```

```
<copy>Allow dynamic-group OEM_Group to manage volumefamily in tenancy</copy>
```
![](./images/dbsec/lab6EM/SetOCIPolicy.png " ")

- Click **Create Policy**

- Lastly, you need to ensure that these ports are open in your app subnet in your EXACS VPN (see the ExaCS Networking Lab for reference)

| Destination Port Range |  Protocol Type | Service |
|------------------------|----------------|---------|
|22    |  TCP | SSH
|7803 | TCP |   Console
|4903 | TCP |   Agent Upload
|7301 | TCP |   JVMD
|9851 | TCP |   BIP



### Part 2: Provision Marketplace Image

- From the navigation menu, under 'Solutions and Platform' click on **Marketplace**

![](./images/dbsec/lab6EM/NavigateMarketplace.png " ")

- Search for 'Oracle Enterprise Manager 13.3' and click on it.

![](./images/dbsec/lab6EM/FindEMinMarketplace.png " ")

- Review the 'Oracle Enterprise Manager Overview' and click on **Launch Instance**

![](./images/dbsec/lab6EM/ReviewandLaunch.png " ")

- Select the 'Package Version', select the 'Compartment', Accept the Terms of Use, and click **Launch Instance**

![](/images/dbsec/SpecifyCompartment.png " ")

- Create an Instance Name, select your desired OCI Availability Domain, and select the desired shape for the VM. You can choose any shape that is available.

![](./images/dbsec/lab6EM/NameInstanceSelectAD.png " ")

![](./images/dbsec/lab6EM/SelectComputeShape.png " ")

- Add the SSH Public Key that will be used to access the instance as well as the Virtual Cloud Network and Subnet created in the prerequisites, and then click **Create**

![](./images/dbsec/lab6EM/EnterSSHkey.png " ")

- Now you can go get some coffee while the Image is installed in your OCI compartment. The installation should take approximately 30 minutes.


### Part 3: Logging into the Image

- Once your VM instance is running, click on the instance and copy the Public IP Address.  SSH into the VM instance with the ssh key
```
<copy>ssh –i &lt;private_ssh_key&gt; opc@&ltpublic IP Address&gt</copy>
```
![](./images/dbsec/lab6EM/CopyVMIP.png " ")

- Check the status of your newly-installed EM:  In the command line console, change your user to ‘oracle’ user by executing below in the command and then Check the OMS status using the EMCLI.

```
<copy>sudo su – oracle</copy>
```

```
<copy>/u01/app/em13c/middleware/bin/emctl status oms</copy>
```
- Sample status:
![](./images/dbsec/lab6EM/CheckStatus.png " ")
- Change the default passwords. The password for the EM user sysman, EM Agent, Registration Password, Fusion Middleware user weblogic and Node Manager can be accessed in the below file (access as root user)

```
<copy>cat /root/.oem/.sysman.pwd</copy>
```

```
<copy>/u01/app/em13c/middleware/bin/emctl config oms -change_repos_pwd</copy>
```
- Log into your new EM Console

``` 
<copy>https://<private ip address>:7803/em</copy>
``` 

- If you need help trouble shooting before going to Part 4, the installation log is located at:
```
<copy>cat /var/log/emcg_setup.log</copy>
```
You should refer to this [doc](https://blogs.oracle.com/oem/enterprise-manager-on-oci-installation-phase-2-installing-the-em-app-into-your-oci-compartment) for more help.

### Part 4: Set up credentials in Enterprise Manager
- Log in to your Enterprise Manager from a bastion host GUI via a browser
``` 
<copy>https://<private ip address>:7803/em</copy>
``` 

- Username should be sysman / welcome16

- Go to **Setup**, and from there, go to **Security**, and then click on **Named Credentials**

![](./images/dbsec/lab6EM/SelectNamedCredentials.png " ")

- Click **Create**
![](./images/dbsec/lab6EM/PressCreateCredentials.png " ")

- Fill in the required fields (write **Credential Name** as 'ExaCS1'), Select **SSH Credentials** under **Credential Type**. Select **Global** as the **Scope**.
- Upload SSH Private Key. UserName should be opc

![](./images/dbsec/lab6EM/CreateCredential.png " ")


### Part 5: Add host target manually

- Select **Add Target manually**. Click on **Setup**, then select **Add Target**, and then **Add Targets Manually**

![](./images/dbsec/lab6EM/SelectAddTargets.png " ")

- Select **Install Agent on Host**

- Click **Add**

- If you have added the ExaCS node IP addresses to your host file, enter the Full Qualified Domain Name you have entered there, otherwise enter the IP address

- For the Platform, select **Linux x86-64**

- Add as many nodes as are on the ExaCS (Quarter Rack=2, Half=4, etc....)

![](./images/dbsec/lab6EM/EnterHostName.png " ")

- Click **Next**, then select your 'Named Credential' and specify an install directory that the user in your named credentials file has access to.

![](./images/dbsec/lab6EM/InstallationDetails.png " ")

- Click **Next**, and after reviewing, click **Deploy Agent**

- If you run into deployment issues, make sure port 3872 is open on DB port, and edit hosts file on both target and EM host to include each other with a full qualified unique name. 



### Part 6: Add Non-Host Targets using a guided process

- Click on **Setup**, then **Add Target**, and then **Configure Auto Discovery**

![](./images/dbsec/lab6EM/SelectConfigureAutoDisc.png " ")

- Select **Targets on Hosts**

![](./images/dbsec/lab6EM/SetupDiscovery.png " ")

- Select your hosts, one at a time

- Select **Discover Now**

- Select your next host and repeat the process until all nodes have been discovered

- Now navigate to 'Auto Discovery Results'

![](./images/dbsec/lab6EM/NavigateAutoDiscRes.png " ")

- You now need to find the 'Cluster' Target and promote it. 

![](./images/dbsec/lab6EM/SelectClusterTarget.png " ")

- No Cluster database target can be added/promoted/discovered until the 'Cluster' target has been added or discovered. Promote it with its default inputs.

- After promoting the 'Cluster' Target, promote the 'Cluster Database' target by finding one and clicking **Promote**. Promoting the Cluster DB should also promote its DB instances.

![](./images/dbsec/lab6EM/FindClusterDB.png " ")

- You will need to enter Monitoring User Credentials (like dbnsmp) for this cluster. You can also enter the SYSDBA Password.

![](./images/dbsec/lab6EM/PromoteClusterDatabase.png " ")

- If you have selected multiple databases and you want to set the same monitoring properties for all of them, select **Specify Common Monitoring Credentials**. Enter the monitoring credentials, monitoring password, and role. Click **Apply**.
- Click **Next**, review the page, and then click **Save**
.
![](./images/dbsec/lab6EM/PromoteClusterReview.png " ")

- For additional documentation click [here](https://docs.oracle.com/cd/E63000_01/EMADM/discovery_db.htm#EMADM13664)

- Repeat this process for all Cluster Databases. Promote any additional targets you want to monitor.

- You can review by going to the 'Configure Auto Discovery' to see what has been promoted.

- If there are errors, you need to make changes to your credentials or Installation Details Page.


### Part 7: View monitoring details/set alerts

- To View an Enterprise Summary of all targets, go to 'Enterprise' and click on **Summary**

![](./images/dbsec/lab6EM/NavigateEnterpriseSummary.png " ")

- In 'Enterprise Summary' you can view the status of all the targets, with the availability to sort by different types.

![](./images/dbsec/lab6EM/EnterpriseSummary.png " ")


### Part 8: Creating Groups
- To create a group, navigate to 'Targets', and click on **Groups**. We will create a dynamic group that includes everything on our Exadata Cloud Service hosts.

![](./images/dbsec/lab6EM/NavigateGroups.png " ")

- Once there, click **Create** and then **Dynamic Group**

![](./images/dbsec/lab6EM/CreateGroupButton.png " ")

- Give it a name (for example ExaCS)

- Click **Define Membership Criteria**

![](./images/dbsec/lab6EM/CreateDynamic.png " ")

- Press the search bar next to 'On Host'

![](./images/dbsec/lab6EM/DefineMemberCriteria.png " ")

- Move over all nodes(hosts) from the ExaCS and press **Select**

![](./images/dbsec/lab6EM/AddHosts.png " ")

- Then press **OK** and **OK** again to create 'Group'.


### Part 9: Viewing Monitoring Details
- To navigate to 'Targets', press the **Targets** dropdown, then select **All Targets**

![](./images/dbsec/lab6EM/NavigateTargets.png " ")

- In 'Search Target Name', add a target you want to see the metrics for, for example a db name

![](./images/dbsec/lab6EM/SearchTarget.png " ")

- Select **Cluster Database**

- This will take you to main target page for the database. To see all metrics, select **Cluster Database**, and then **Monitoring**, and choose **All Metrics**

![](./images/dbsec/lab6EM/NavigateAllMetrics.png " ")

- Here you can search and explore different metrics on the cluster level.

![](./images/dbsec/lab6EM/SearchMetrics.png " ")

- To view metrics, navigate to 'Members', and select **Dashboard**

![](./images/dbsec/lab6EM/NavigateMemDash.png " ")

- Here you can select a database instance and repeat the process to see metrics for an instance.

![](./images/dbsec/lab6EM/SeeMembers.png " ")
