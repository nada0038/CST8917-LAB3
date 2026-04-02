# ==============================================================================
# FleetBook - Lab 3 Azure Infrastructure Setup Automation
# Automatically creates the Resource Group, Service Bus Standard Namespace,
# Queues, Topics, and Filtered Subscriptions required for the lab.
#
# RUN: .\setup_infra.ps1
# ==============================================================================

# Login to Azure (uncomment if you are not already logged in)
# az login

$RESOURCE_GROUP = "rg-serverless-lab3"
$LOCATION = "canadacentral"
# Adding the user's id 'nada0038' + a random string as Azure requires global uniqueness
$SB_NAMESPACE = "nada0038-booking-sb-$(Get-Random -Maximum 9999)" 

Write-Host "Creating Resource Group: $RESOURCE_GROUP" -ForegroundColor Cyan
az group create --name $RESOURCE_GROUP --location $LOCATION --output none

Write-Host "Creating Service Bus Namespace: $SB_NAMESPACE (Standard Tier)" -ForegroundColor Cyan
az servicebus namespace create `
    --resource-group $RESOURCE_GROUP `
    --name $SB_NAMESPACE `
    --location $LOCATION `
    --sku Standard `
    --output none

Write-Host "Creating 'booking-queue' Queue" -ForegroundColor Cyan
az servicebus queue create `
    --resource-group $RESOURCE_GROUP `
    --namespace-name $SB_NAMESPACE `
    --name booking-queue `
    --output none

Write-Host "Creating 'booking-results' Topic" -ForegroundColor Cyan
az servicebus topic create `
    --resource-group $RESOURCE_GROUP `
    --namespace-name $SB_NAMESPACE `
    --name booking-results `
    --output none

# ==============================================================================
# SUB 1: Confirmed Bookings
# ==============================================================================
Write-Host "Creating 'confirmed-sub' Subscription and Rule" -ForegroundColor Cyan
az servicebus topic subscription create `
    --resource-group $RESOURCE_GROUP `
    --namespace-name $SB_NAMESPACE `
    --topic-name booking-results `
    --name confirmed-sub `
    --max-delivery-count 10 `
    --output none

az servicebus topic subscription rule create `
    --resource-group $RESOURCE_GROUP `
    --namespace-name $SB_NAMESPACE `
    --topic-name booking-results `
    --subscription-name confirmed-sub `
    --name ConfirmedFilter `
    --filter-sql-expression "sys.label='confirmed'" `
    --output none

Write-Host "WARNING: Sometimes Azure creates a default rule, attempting to delete it..."
az servicebus topic subscription rule delete `
    --resource-group $RESOURCE_GROUP `
    --namespace-name $SB_NAMESPACE `
    --topic-name booking-results `
    --subscription-name confirmed-sub `
    --name "`$Default" `
    --output none 2>$null

# ==============================================================================
# SUB 2: Rejected Bookings
# ==============================================================================
Write-Host "Creating 'rejected-sub' Subscription and Rule" -ForegroundColor Cyan
az servicebus topic subscription create `
    --resource-group $RESOURCE_GROUP `
    --namespace-name $SB_NAMESPACE `
    --topic-name booking-results `
    --name rejected-sub `
    --max-delivery-count 10 `
    --output none

az servicebus topic subscription rule create `
    --resource-group $RESOURCE_GROUP `
    --namespace-name $SB_NAMESPACE `
    --topic-name booking-results `
    --subscription-name rejected-sub `
    --name RejectedFilter `
    --filter-sql-expression "sys.label='rejected'" `
    --output none

az servicebus topic subscription rule delete `
    --resource-group $RESOURCE_GROUP `
    --namespace-name $SB_NAMESPACE `
    --topic-name booking-results `
    --subscription-name rejected-sub `
    --name "`$Default" `
    --output none 2>$null

# ==============================================================================
# SECRETS AND CONNECTIONS
# ==============================================================================
Write-Host "--------------------------------------------------------" -ForegroundColor Green
Write-Host "SETUP COMPLETE! Here are the secrets you need for the lab:" -ForegroundColor Green

$keys = az servicebus namespace authorization-rule keys list `
    --resource-group $RESOURCE_GROUP `
    --namespace-name $SB_NAMESPACE `
    --name RootManageSharedAccessKey | ConvertFrom-Json

Write-Host ""
Write-Host "Namespace Name: " -NoNewline; Write-Host $SB_NAMESPACE -ForegroundColor Yellow
Write-Host "Primary Key (For Web Client): " -NoNewline; Write-Host $keys.primaryKey -ForegroundColor Yellow
Write-Host "Primary Connection String (For Logic App Trigger): " -NoNewline; Write-Host $keys.primaryConnectionString -ForegroundColor Yellow
Write-Host "--------------------------------------------------------" -ForegroundColor Green
