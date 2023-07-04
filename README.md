# AppGateway-HubAndSpoke


## Application Gateway

1. Path-based: We have 2 web apps serving to applications. We need our Application Gateway to forward the request to these Web Apps based on the requested path, /web /result 
2. Backend_address_pools local variable: We need to specify multiple backend pools in this resource. For that purpose, we need to reference to the App1 and App2 modules at the same time. We can't do this in the variables file. We are using a **for loop** to generate the local variable to use as the variable to pass to the module.
3. Dynamic resources: Even though we didn't need multiple probes or backend settings in this project, we design our module flexible enough to accomodate such multiple resources.

## Application Insights

To enable the Aplication Insights to our Applications, we have to add **Connection String** to their code.
```
from applicationinsights.flask.ext import AppInsights
import os
appinsights = AppInsights(app)
```

## App Service

1. Pull Image Over Vnet: Our Web Apps need to connect to ACR to pull the images but they do it through their Public IP by defaults. Our ACR is closed to the Public Access. Hence our Web Apps need to connect to the ACR through their Private IPs. This is achieved by setting **Pull Image Over Vnet = TRUE**. Normally, this is done at **Deployment Center Settings** but Terraform does not have an argument reference for this.A work around is defining a Web App configuration variable as **Pull Image Over Vnet = TRUE**.
2. application_insights_enabled variable:  Application Insights is enabled for a Web App by defining environment variables for **APPINSIGHTS_INSTRUMENTATIONKEY** and **APPLICATIONINSIGHTS_CONNECTION_STRING**. This variable uses a turnary operator to either fill in these values or leave them blank.  
3. Key Vault secret: We need to give the password to the Web Apps to access to our database. Our password is stored as a Secret in an existing Key Vault. We need to define an environment variable as 
```
"MYSQL_PASSWORD" = "@Microsoft.KeyVault(SecretUri=${module.key_vault_secrets["${each.value.mysql_password_secret}"].id})"
```

## Azure Container Registry 

We are disabling public access to the Acr by setting **network_rule_bypass_option = "None"**.

## Azure Firewall

We don't want to associate a public IP to our Firewall. This requires enabling **Forced Tunneling**. A subnet named **AzureFirewallManagementSubnet** is created and associated with a public IP when it is enabled. 

## Key Vault Access Policy 

We need to give Key Vault access to the Service Principal which is used by Terraform and the Web Apps to retrieve the MySQL password. Since the Object ID is too different for these objects we are calling the module twice for these object IDs.

## Azure MySQL Flexible Server

1. Since Flexible version of MySQL server does not have a Private Endpoint feature, we need to use Subnet Delegation for it.
2. We disable SSL authentication by setting **require_secure_transport_value = "OFF"**.
