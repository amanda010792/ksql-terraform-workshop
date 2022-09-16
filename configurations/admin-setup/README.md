# Confluent Cloud ksqlDB Workshop - Admin Setup Instructions

## Pre-requisites 

###### Ensure proper access for users/admin
- The administrator setting up resources in Confluent Cloud for the ksqlDB workshop will require organization admin access to the Confluent Cloud Environment.     
- The users require a Confluent Cloud User Account linked to the email address provided in the registration form. No roles are required to be assigned for this user, as they will be assigned during the setup. However, please ensure that any registered users have a Confluent Cloud User Account before begining the setup of this workshop. 
- Before running this script, ensure that your Confluent contact has provided you with a csv file containing the list of registrants and their email addresses. 


###### Login to confluent cloud 
```
confluent login --save
```


###### Ensure Terraform 0.14+ is installed

Install Terraform version manager [tfutils/tfenv](https://github.com/tfutils/tfenv)

Alternatively, install the [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli?_ga=2.42178277.1311939475.1662583790-739072507.1660226902#install-terraform)

To ensure you're using the acceptable version of Terraform you may run the following command:
```
terraform version
```
Your output should resemble: 
```
Terraform v0.14.0 # any version >= v0.14.0 is OK
```
###### Create a Cloud API Key 

1. Open the Confluent Cloud Console
2. In the top right menu, select "Cloud API Keys"
3. Choose "Add Key" and select "Granular Access"
4. For Service Account, select "Create a New One" and name is <YOUR_NAME>-terraform-workshop-SA
5. Download your key
6. In the top right menu, select "Accounts & Access", select "Access" tab
7. Click on the organization and select "Add Role Assignment" 
8. Select the account you created (service account) and select "Organization Admin". Click Save


## Set Up Workshop Resources 
In the setup of the workshop you will be provisioning the following resources: 
- An environment per every 10 users registered
- A Kafka Cluster per environment 
- A ksqlDB cluster per user 
- Two topics 
- Two Datagen Source connectors to simulate mock data in the topics you created. 
- Necessary service accounts, API keys and ACLs. 

Run the script to set up resources (providing the path to the csv file provided by your Confluent Contact with registrations)
```
./setup.sh <path-to-csv>
```

