# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure


<img src="images/Microsoft_Azure-Logo.wine.png" width="220" >      <img src="images/Terraform-logo.png" width="220" >    <img src="images/packer_empty.png" width="220" >


### Introduction
This project is developed to deploy a customizable, scalable web server in Azure using Terraform and Packer templates.

### Getting Started
Before you start using the project code:
* Make sure you have a git account.
* Clone the project to your local git repository. 
* Open the project files in your local Integrated development environment(IDE).

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) on the Microsoft website. 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) on your laptop or work station.
3. Install [Packer](https://www.packer.io/downloads) on your laptop or work station.
4. Install [Terraform](https://www.terraform.io/downloads.html) on your laptop or work station.
5. Install an Integrated development environment(IDE) to use for code manipulation. If you already have one installed, you don't need to 
   install any new IDE. 

### Instructions
cmd = command

**How to customize the vars.tf**

The vars.tf contains variables for terraform including  prefix, location, password, username, num_vms and num_managed_disks. You can customize each variable. 

**NOTE:** 

* For each of these variables, they can either have integer or string default values, in case you want to specify a default value, within the code definition of each variable, add a default value:  

For string defaults values ------------------> "default" = "name_here"

For integer defaults values -----------------> "default" = 2

In case you do not specify a default value within the vars.tf for each variable, you will be be prompted to do that when running terraform plan or apply. 


**prefix:** This is the prefix name that will be added to azure resource names specified in the main.tf file. To make sure the prefix is added to  the name of a resource in the main.tf file during creation, add the prefix variable to the name parameter of the resource, for example: 
name  = "${var.variable_name}-network"    ---------->   name   = "${var.prefix}-network"


**location**: This is the region in which you want your azure resources to be created. 

**password**: This is the azure resource password. Here you just need to specify your password on the default parameter. 

**username**: This is the azure resource username. Here you just need to specidy your username on the default parameter. 

**num_vms** : This is the variable that provides the number of Vitual machines to created by terraform. You can change the default value to meet your requirements by following the steps above for variables with int defaults.

**num_managed_disks**: This is the variable that provides the number of managed disks to be created by terraform. You can change the default value to meet your requirements by following the steps above for variables with int defaults.


You can specify default values for each variable or leave it empty to only do that when running the cmd line. 

  Within this  file for the password and username, you can sepcify the default username , also specify the password or  azure secrets if you have.


**Instructions to run packer and Terraform templates**

1. On cmd line run : **az login**

   This will help you to connect to your azure account and portal. 

2. Go the Azure portal and on the resource search bar look for resource groups.

3. Once you are in resource  group landing page , click on Create, to make a new reource group. Keep the name of this resource group as it will be used in the steps below.

4. On the cmd  line run: **packer build server.json**

   **NOTE:** 
   * server.json is the name of the json file containing all the commands to create the packer image.

   * In some instances you might get an error of packer not being able to get the subscription id of your azure subscription under which you want to deploy the image. To make sure this step works, you will have to hard code the subscription id in the cmd line when running packer build. 

   * Go to the azure portal and search for the subscription under which your image will be deployed. copy the subscription_id and  run the following command on your work station comman line: 

    **packer build  -var "subscription_id=subscription_id_from_azure portal" server.json**

   * subscription_id_from_azure portal is the subscription id obtained from the azure subscription on the portal. 

   * This command will help to create the packer image. 

5. OPTIONAL: Once the image  creation step is complete, to check the list of image(s), run the cmd: **az image list**

6. To deploy the azure resources using terraform, on cmd line run: **terraform plan -out solution.plan** 

  This command will store  all metadata for resources to be created in the solution.plan file. 

7. Then on cmd line run: **terraform apply solution.plan**

  * You will be prompted to specify the number of managed disks, the number of virtual machines, and the prefix to use for all resources during creation.

  * In case you get an error about an already existing resource group , prompting you to import it locally. Run command below in cmd line:

  **terraform import azurerm_resource_group.resource_group_name_tf /subscriptions/subscription_id/resourceGroups/resource_group_name_portal**
  
  **resource_group_name_tf**---> name of the resource group in the terraform main.tf file.

  **subscription_id**----------> subscription id from azure portal.

  **resource_group_name**------> azure resource group already existing in azure portal.


### Output

Upon running the  commands above, you will see a message on cmd line from terraform  indicating: 

**Apply complete! Resources No added, changed and destroyed**

