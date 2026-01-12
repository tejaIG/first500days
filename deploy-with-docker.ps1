# Azure Container Registry Deployment Script
# Run this AFTER installing and starting Docker Desktop

Write-Host "Starting deployment to Azure..." -ForegroundColor Green

# Navigate to project directory
Set-Location "C:\Users\tejat\First500days - assignment\my-rag-agent"

# Step 1: Login to ACR (get token without Docker)
Write-Host "`n[1/4] Logging into Azure Container Registry..." -ForegroundColor Cyan
$token = az acr login --name acrragagent21078 --expose-token --output tsv --query accessToken

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to get ACR token" -ForegroundColor Red
    exit 1
}

# Login to Docker using the token
Write-Host "Authenticating Docker with ACR..." -ForegroundColor Cyan
echo $token | docker login acrragagent21078.azurecr.io --username 00000000-0000-0000-0000-000000000000 --password-stdin

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to login to Docker" -ForegroundColor Red
    exit 1
}

# Step 2: Build the Docker image
Write-Host "`n[2/4] Building Docker image..." -ForegroundColor Cyan
docker build -t acrragagent21078.azurecr.io/rag-api:latest ./apps/api

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to build Docker image" -ForegroundColor Red
    exit 1
}

# Step 3: Push the image to ACR
Write-Host "`n[3/4] Pushing image to Azure Container Registry..." -ForegroundColor Cyan
docker push acrragagent21078.azurecr.io/rag-api:latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to push Docker image" -ForegroundColor Red
    exit 1
}

# Step 4: Restart the App Service
Write-Host "`n[4/4] Restarting App Service..." -ForegroundColor Cyan
az webapp restart --name app-rag-agent-16515 --resource-group rg-rag-agent-prod

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to restart App Service" -ForegroundColor Red
    exit 1
}

Write-Host "`n✅ Deployment completed successfully!" -ForegroundColor Green
Write-Host "Your API should now be available at: https://app-rag-agent-16515.azurewebsites.net" -ForegroundColor Yellow
Write-Host "`nDon't forget to add GEMINI_API_KEY in Azure Portal:" -ForegroundColor Yellow
Write-Host "1. Go to: https://portal.azure.com" -ForegroundColor White
Write-Host "2. Navigate to your App Service (app-rag-agent-16515)" -ForegroundColor White
Write-Host "3. Go to Configuration > Application settings" -ForegroundColor White
Write-Host "4. Add GEMINI_API_KEY with your API key value" -ForegroundColor White
