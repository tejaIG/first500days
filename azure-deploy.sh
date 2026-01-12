#!/bin/bash

# ==============================================================================
# Azure AI RAG Agent Deployment Script (Direct Zip Deploy - No Docker)
# 
# This script deploys:
# 1. Resource Group
# 2. Azure AI Search (Free Tier)
# 3. Azure App Service (Native Python Environment)
# ==============================================================================

# 1. Checks and Variables
if ! command -v az &> /dev/null;
then
    echo "Azure CLI could not be found. Please install it first."
    exit 1
fi

echo "Please ensure you are logged in via 'az login'."

# Configuration Variables
RESOURCE_GROUP="rg-rag-agent-prod"
LOCATION="eastus2"
APP_SERVICE_PLAN="asp-rag-agent"
# We must use the EXISTING app name to update it, or delete it and create new.
# Since we are switching from Container to Code, it's safer to delete and recreate the app
# to avoid config conflicts, but let's try updating first.
APP_SERVICE_NAME="app-rag-agent-16515" 

echo "Starting Deployment..."
echo "Resource Group: $RESOURCE_GROUP"
echo "Location: $LOCATION"

# 2. Create/Update Resource Group
echo "Creating/Updating Resource Group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# 3. Azure AI Search
EXISTING_SEARCH=$(az search service list --resource-group $RESOURCE_GROUP --query "[0].name" --output tsv)

if [ -z "$EXISTING_SEARCH" ]; then
    SEARCH_SERVICE_NAME="search-rag-agent-${RANDOM}"
    echo "Creating Azure AI Search Service ($SEARCH_SERVICE_NAME)..."
    az search service create \
        --name $SEARCH_SERVICE_NAME \
        --resource-group $RESOURCE_GROUP \
        --sku free \
        --partition-count 1 \
        --replica-count 1
else
    SEARCH_SERVICE_NAME=$EXISTING_SEARCH
    echo "Using existing Azure AI Search Service: $SEARCH_SERVICE_NAME"
fi

# 4. Create App Service Plan
echo "Creating/Updating App Service Plan (Linux B1)..."
az appservice plan create \
    --name $APP_SERVICE_PLAN \
    --resource-group $RESOURCE_GROUP \
    --sku B1 \
    --is-linux

# 5. Create/Update Web App (PYTHON NATIVE)
echo "Configuring Web App for Python 3.11..."

# Check if app exists
APP_EXISTS=$(az webapp list --resource-group $RESOURCE_GROUP --query "[?name=='$APP_SERVICE_NAME'] | length(@)" --output tsv)

if [ "$APP_EXISTS" == "1" ]; then
    # Update existing app config to Python
    az webapp config set \
        --resource-group $RESOURCE_GROUP \
        --name $APP_SERVICE_NAME \
        --linux-fx-version "PYTHON|3.11"
else
    # Create new app with Python runtime
    az webapp create \
        --resource-group $RESOURCE_GROUP \
        --plan $APP_SERVICE_PLAN \
        --name $APP_SERVICE_NAME \
        --runtime "PYTHON|3.11"
fi

# 6. Prepare and Upload Code
echo "Preparing Deployment Package..."
# We need to zip the contents of apps/api
# Navigate to apps/api, zip all files, move zip to temp
current_dir=$(pwd)
cd apps/api
# Create zip file (excluding __pycache__ and venv)
if command -v zip &> /dev/null;
then
    zip -r ../../api_deploy.zip . -x "*__pycache__*" "*venv*"
else
    # Fallback for Windows environments without 'zip' command (using PowerShell)
    powershell.exe -nologo -noprofile -command "Compress-Archive -Path * -DestinationPath ..\..\api_deploy.zip -Force"
fi
cd "$current_dir"

echo "Deploying Code to Azure..."
az webapp deployment source config-zip \
    --resource-group $RESOURCE_GROUP \
    --name $APP_SERVICE_NAME \
    --src api_deploy.zip

# 7. Configure Startup Command & Settings
echo "Retrieving Secrets..."
SEARCH_KEY=$(az search admin-key show --service-name $SEARCH_SERVICE_NAME --resource-group $RESOURCE_GROUP --query primaryKey --output tsv)
SEARCH_ENDPOINT="https://$SEARCH_SERVICE_NAME.search.windows.net"

echo "Configuring App Settings..."
az webapp config appsettings set \
    --resource-group $RESOURCE_GROUP \
    --name $APP_SERVICE_NAME \
    --settings \
        AZURE_SEARCH_ENDPOINT="$SEARCH_ENDPOINT" \
        AZURE_SEARCH_KEY="$SEARCH_KEY" \
        AZURE_SEARCH_INDEX_NAME="rag-index" \
        GEMINI_API_KEY="PLACEHOLDER_UPDATE_ME" \
        SCM_DO_BUILD_DURING_DEPLOYMENT="true" \
        POST_BUILD_COMMAND="pip install -r requirements.txt" \
        WEBSITES_PORT="8000"

# Set Startup Command explicitly
echo "Setting Startup Command..."
az webapp config set \
    --resource-group $RESOURCE_GROUP \
    --name $APP_SERVICE_NAME \
    --startup-file "uvicorn main:app --host 0.0.0.0 --port 8000"

echo "Cleaning up..."
rm api_deploy.zip

echo "=============================================================================="
echo "Deployment Complete!"
echo "API URL: https://$APP_SERVICE_NAME.azurewebsites.net"
echo "IMPORTANT: Go to Azure Portal -> App Service -> Settings -> Environment Variables and update 'GEMINI_API_KEY'."
echo "=============================================================================="