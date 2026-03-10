(The project was renamed from IOTG(insights-on-the-go) to Elastiviz)
# Elastiviz - From Question to Chart in a Single Quote

**Elastiviz** is an AI-powered, mobile-first observability platform designed to bridge the gap between complex infrastructure data and human intent. Instead of building static dashboards or writing complex query strings, Elastiviz allows you to ask questions in plain English and see the answers rendered instantly as interactive, real-time visualizations.

## 🚀 The Core Proposition

*   **Natural Language to Visuals:** Translate intent—like *"Show me pods consuming CPU for last 2 days"*—directly into optimized ES|QL queries and rich charts.
*   **Mobile-First Observability:** Built for the modern engineer on the move. Troubleshoot and monitor your K8s environment from your phone, not just your desk.
*   **Intelligent Reasoning:** Powered by a Elastic agent builder and custom MCP (Model Context Protocol) engine that manages multi-step investigative reasoning and automatic schema discovery.
*   **Premium UX:** Flutter interface designed for high-impact visual clarity and smooth interaction.

## 🏗️ Architecture

<img width="1140" height="1206" alt="elastiviz_arch" src="https://github.com/user-attachments/assets/31efec61-babd-4a5f-b72e-0c82ca30c9d1" />

(Note:-
1. Elastiviz uses custom MCP endpoints which use ESQL api to execute queries because observability project dosen't support creating agents using agent builder
2. Current implementation works only for kubernetes data that comes to  elastic's observability endpoint, but with some enhancements it can be generalized to work with any data, following similar architecture.)  

## 🛠️ Tech Stack

- **Frontend:** Flutter (Mobile & Web)
- **Backend:** Serverpod (Dart), PostgreSQL, Redis
- **Data Store:** Elastic Serverless Observability Project(Kubernetes Integration)

## 🚦 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-started/sdk)
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Serverpod CLI](https://docs.serverpod.dev/getting-started/install-cli)

### 1. Installation & Dependency Setup

Run `pub get` in all modules to fetch dependencies:

```bash
# Get dependencies for the client
cd iotg_client
dart pub get

# Get dependencies for the server
cd ../iotg_server
dart pub get

# Get dependencies for the flutter app
cd ../iotg_flutter
flutter pub get
```

### 2. Configuration & Security

To run the project, you need to configure your Elastic URLs and API keys in the server's `passwords.yaml`. **Never commit this file.**

1.  Navigate to `iotg_server/config/`.
2.  Open (or create) `passwords.yaml`.
3.  Add the following configuration:

```yaml
# iotg_server/config/passwords.yaml
development:
  # --- Elastiviz Observability Configuration (Hackathon Instance) ---
  observabilityUrl: 'https://elastiviz-de9b85.es.us-central1.gcp.elastic.cloud'
  observabilityApiKey: 'your_observability_api_key'
  kibanaUrl: 'https://elastiviz-agent-b7cadb.kb.us-central1.gcp.elastic.cloud'
  kibanaApiKey: 'your_kibana_api_key'
  agentId: 'elastiviz-agent'
```
The urls and agentId used above are of my actual project, please use them for hackathon
### 3. Agent Configuration

See [`agent_setup.md`](agent_setup.md) for the exact System Prompt and Tool Webhooks you need to configure in the Kibana Agent Builder UI. Once created, paste the generated Agent ID into your `passwords.yaml` as shown above.

### 4. Database Migrations

### 5. Start Backend & Run

Navigate to the server directory and start the services:

```bash
cd iotg_server
docker compose up --build --detach
dart run bin/main.dart --apply-migrations
```

Then, run the mobile app:

```bash
cd ../iotg_flutter
flutter run
```

---
*Built with ❤️ for the Modern SRE.*
