# Secrets required for CI/CD

## Azure Deployment
- `AZURE_CREDENTIALS`: Azure service principal credentials (JSON format)
  ```json
  {
    "clientId": "<client-id>",
    "clientSecret": "<client-secret>",
    "subscriptionId": "bd8a9395-fe3b-4c17-b9db-502055277e3f",
    "tenantId": "<tenant-id>"
  }
  ```

## Application Secrets
- `GEMINI_API_KEY`: Your Google Gemini API key
- `AZURE_SEARCH_ENDPOINT`: https://search-rag-agent-13674.search.windows.net
- `AZURE_SEARCH_KEY`: Your Azure Search admin key

## How to Add Secrets
1. Go to: https://github.com/tejaIG/first500days/settings/secrets/actions
2. Click "New repository secret"
3. Add each secret with the name and value listed above

## Azure Service Principal Creation
Run this command to create the Azure credentials:
```bash
az ad sp create-for-rbac \
  --name "github-actions-rag-agent" \
  --role contributor \
  --scopes /subscriptions/bd8a9395-fe3b-4c17-b9db-502055277e3f/resourceGroups/rg-rag-agent-prod \
  --sdk-auth
```

Copy the entire JSON output and save it as the `AZURE_CREDENTIALS` secret.
