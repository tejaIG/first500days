# RAG Agent Monorepo

Enterprise-grade AI Agent application with Next.js frontend and FastAPI backend, deployed on Azure.

## 🚀 Quick Start

### Prerequisites
- Node.js 20+
- Python 3.11+
- Azure CLI
- Google Gemini API Key

### Local Development

```bash
# Install dependencies
npm run install-all

# Start dev servers (Frontend + Backend)
npm run dev
```

- Frontend: http://localhost:3000
- Backend: http://localhost:8000

### Environment Setup

**Backend** (`apps/api/.env`):
```env
GEMINI_API_KEY=your_key_here
AZURE_SEARCH_ENDPOINT=https://search-rag-agent-13674.search.windows.net
AZURE_SEARCH_KEY=your_key_here
AZURE_SEARCH_INDEX_NAME=rag-index
```

**Frontend** (`apps/web/.env.local`):
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

## 📦 Project Structure

```
my-rag-agent/
├── apps/
│   ├── api/          # FastAPI backend with Gemini integration
│   └── web/          # Next.js 14 frontend (App Router)
├── packages/
│   └── ui/           # Shared UI components
└── .github/
    └── workflows/    # CI/CD pipelines
```

## 🛠 Tech Stack

- **Frontend**: Next.js 14, TypeScript, Tailwind CSS, Framer Motion
- **Backend**: Python 3.11, FastAPI, Google Gemini 1.5 Flash
- **Vector DB**: Azure AI Search (Free Tier)
- **Deployment**: Azure App Service
- **CI/CD**: GitHub Actions

## 🚢 Deployment

### Automatic (via GitHub Actions)
Push to `main` branch triggers automatic deployment to Azure.

### Manual
```bash
# Deploy backend
bash azure-deploy.sh

# Deploy frontend (configure Vercel or Azure Static Web Apps)
cd apps/web && npm run build
```

## 🔧 Available Scripts

- `npm run dev` - Start development servers
- `npm run build` - Build all packages
- `npm run lint` - Lint code
- `npm run format` - Format code with Prettier

## 📚 Features

- ✅ **RAG Pipeline**: Upload PDFs and query with AI-powered search
- ✅ **Hybrid Search**: Text + Vector search in Azure AI Search
- ✅ **Tool Calling**: Gemini automatically retrieves context
- ✅ **Neo-Noir UI**: Dark, cyberpunk-themed interface
- ✅ **Production Ready**: Deployed on Azure with CI/CD

## 🔐 Security

- Secrets managed via GitHub Secrets
- Environment variables for sensitive data
- No hardcoded API keys

## 📊 Monitoring

- Azure Application Insights (configured)
- Health check endpoint: `/health`
- Logs: `az webapp log tail --name app-rag-agent-16515 --resource-group rg-rag-agent-prod`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

MIT License - see LICENSE file for details

## 🙋‍♂️ Support

- **Issues**: https://github.com/tejaIG/first500days/issues
- **Discussions**: https://github.com/tejaIG/first500days/discussions

---

Built with ❤️ using Azure AI + Google Gemini
