# AI News Aggregator - Setup Guide

**Last Updated:** December 20, 2024  
**Status:** Database Setup Complete ✅ | Ready for Python Development

This document contains complete setup instructions for the AI News Aggregator project.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Cloud Database Setup](#cloud-database-setup)
3. [Local Environment Setup](#local-environment-setup)
4. [Database Schema Creation](#database-schema-creation)
5. [Verification](#verification)
6. [Next Steps](#next-steps)
7. [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, ensure you have:

- macOS (or Linux/Windows with adjustments)
- Git installed
- PostgreSQL client tools (`psql`)
- Internet connection
- GitHub account

---

## Cloud Database Setup

### Step 1: Create Supabase Account

1. Go to [supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign up with GitHub (recommended) or email
4. Verify your email if required

### Step 2: Create New Project

1. Click "New Project"
2. Fill in project details:
   - **Name:** `ai-news-aggregator`
   - **Database Password:** Create a strong password (save it securely!)
   - **Region:** Choose closest to you (e.g., Europe, US West)
   - **Plan:** Free
3. Click "Create new project"
4. Wait ~2 minutes for provisioning

### Step 3: Enable pgvector Extension

1. In Supabase dashboard, click **SQL Editor** (left sidebar)
2. Click **+ New query**
3. Paste this SQL:
   ```sql
   CREATE EXTENSION IF NOT EXISTS vector;
   ```
4. Click **Run** (or Cmd/Ctrl + Enter)
5. You should see: `Success. No rows returned`

### Step 4: Get Connection String

1. Click **Project Settings** (gear icon, bottom left)
2. Click **Database** in settings menu
3. Scroll to **Connection string** section
4. Click **URI** tab
5. **IMPORTANT:** Use the **Transaction pooler** method:
   - Click the **Method** dropdown
   - Select **Transaction pooler**
   - Copy the connection string shown
   - It should look like: `postgresql://postgres.[PROJECT_ID]:[YOUR-PASSWORD]@aws-region.pooler.supabase.com:6543/postgres`

**Note:** The pooler connection is more reliable than direct connection for new projects.

---

## Local Environment Setup

### Step 1: Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/rss-aggregator.git
cd rss-aggregator
```

### Step 2: Create .env File

```bash
# Copy the example file
cp .env.example .env

# Edit with your actual credentials
nano .env
```

Add your Supabase credentials:

```bash
# Supabase Database Connection (use Transaction pooler URL)
DATABASE_URL=postgresql://postgres.[PROJECT_ID]:[PASSWORD]@aws-region.pooler.supabase.com:6543/postgres

# Supabase Project Details
SUPABASE_URL=https://[PROJECT_ID].supabase.co
SUPABASE_PROJECT_ID=[PROJECT_ID]

# Ollama Configuration (to be installed later)
OLLAMA_BASE_URL=http://localhost:11434
EMBEDDING_MODEL=nomic-embed-text
LLM_MODEL=llama3.1

# App Settings
DEBUG=True
LOG_LEVEL=INFO
```

Save and exit (Ctrl + O, Enter, Ctrl + X in nano).

**IMPORTANT:** Never commit the `.env` file to Git. It's protected by `.gitignore`.

### Step 3: Verify .gitignore

Ensure `.gitignore` exists and contains:

```bash
cat .gitignore
```

Should include:
```
.env
.env.local
.env.production
*.env
__pycache__/
*.pyc
.venv/
venv/
```

If missing, create it:
```bash
cat > .gitignore << 'EOF'
.env
.env.local
.env.production
*.env

__pycache__/
*.pyc
.venv/
venv/
.DS_Store
*.db
*.sqlite3
node_modules/
.pytest_cache/
EOF
```

---

## Database Schema Creation

### Step 1: Verify schema.sql Exists

```bash
ls scripts/schema.sql
```

If missing, the file should be in your repository. Pull latest changes:
```bash
git pull origin main
```

### Step 2: Run the Schema

**From your project root directory:**

```bash
# Set your database password as environment variable (replace with your actual password)
export PGPASSWORD='your_database_password'

# Run the schema file
psql -h aws-region.pooler.supabase.com -p 6543 -U postgres.[PROJECT_ID] -d postgres -f scripts/schema.sql
```

**Or use this one-line command:**

```bash
PGPASSWORD='your_password' psql -h aws-region.pooler.supabase.com -p 6543 -U postgres.[PROJECT_ID] -d postgres -f scripts/schema.sql
```

### Step 3: Verify Output

You should see:
- `CREATE EXTENSION` (pgvector)
- `CREATE TABLE` (5 times: feeds, articles, summaries, tags, article_tags)
- `CREATE INDEX` (multiple times)
- `INSERT 0 16` (initial tags)
- `CREATE VIEW` (3 views)
- Success message at the end

---

## Verification

### Verify Database Tables

**Connect to your database:**

```bash
PGPASSWORD='your_password' psql -h aws-region.pooler.supabase.com -p 6543 -U postgres.[PROJECT_ID] -d postgres
```

**Once connected (you'll see `postgres=>` prompt), run:**

```sql
-- List all tables
\dt

-- You should see:
-- article_tags
-- articles
-- feeds
-- summaries
-- tags

-- View pre-populated tags
SELECT tag_name, tag_category FROM tags ORDER BY tag_category, tag_name;

-- Exit
\q
```

### Verify in Supabase Dashboard

1. Go to your Supabase project dashboard
2. Click **Table Editor** (left sidebar)
3. You should see all 5 tables listed
4. Click on **tags** table
5. You should see 16 pre-populated tags (ai-trends, ai-tools, etc.)

---

## Next Steps

Now that your database is set up, you can:

### 1. Set Up Python Project (Recommended Next)

```bash
# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Initialize Python project
uv init

# Add dependencies
uv add fastapi uvicorn sqlalchemy psycopg2-binary
uv add feedparser python-dotenv requests
uv add llama-index llama-index-embeddings-ollama
```

### 2. Install Ollama (For AI Features)

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull required models
ollama pull nomic-embed-text
ollama pull llama3.1
```

### 3. Create Your First RSS Feeds

Manually add feeds via Supabase dashboard or wait until Python app is built.

### 4. Build the Fetcher Agent

Create Python script to collect articles from RSS feeds.

---

## Troubleshooting

### Issue: "could not translate host name to address"

**Problem:** Direct connection hostname doesn't resolve.

**Solution:** Use Transaction pooler instead:
- In Supabase: Settings → Database → Connection String
- Method dropdown → Select "Transaction pooler"
- Use that connection string (port 6543)

### Issue: "invalid percent-encoded token"

**Problem:** Special characters in password need URL encoding.

**Solution:** Use `PGPASSWORD` environment variable instead:
```bash
PGPASSWORD='your_password' psql -h ... -U ... -d ...
```

### Issue: "relation already exists"

**Problem:** Tables already created from previous run.

**Solution:** This is fine - the schema uses `IF NOT EXISTS`. Your tables are already set up.

### Issue: Cannot connect to database

**Checklist:**
1. Is your Supabase project active? (Check dashboard)
2. Is your password correct?
3. Are you using the Transaction pooler connection string?
4. Is your project ID correct in the username? (should be `postgres.[PROJECT_ID]`)
5. Try pinging the pooler: `ping aws-region.pooler.supabase.com`

---

## Security Reminders

### ⚠️ Never Commit These:
- `.env` file (contains real passwords)
- Any files with API keys or secrets
- Database backups with real data

### ✅ Safe to Commit:
- `.gitignore`
- `.env.example` (template only)
- `scripts/schema.sql`
- All code files
- Documentation

### 🔒 Sharing with Collaborators:

When your friend sets up:
1. They clone the repo (gets code, NOT secrets)
2. You share database credentials privately (Signal, password manager)
3. They create their own `.env` file with your shared credentials
4. Both of you use the same Supabase database

---

## Database Schema Overview

Your database now contains:

### Tables:
1. **feeds** - RSS feed sources to monitor
2. **articles** - Individual articles collected from feeds
3. **summaries** - AI-generated article summaries (1:1 with articles)
4. **tags** - Reusable topic tags (ai-trends, ai-tools, etc.)
5. **article_tags** - Many-to-many relationship between articles and tags

### Views (Analytics):
1. **v_articles_full** - Complete article data with all metadata
2. **v_feed_stats** - Statistics and metrics per feed
3. **v_tag_popularity** - Tag usage and popularity metrics

### Initial Data:
- 16 pre-populated tags across 4 categories:
  - **Topics:** ai-trends, ai-tools, ai-use-cases, ai-governance, ai-agents, machine-learning, llm, computer-vision, robotics
  - **Industries:** healthcare, finance, education, technology
  - **Sentiment:** positive, neutral, negative

---

## Connection String Reference

### Transaction Pooler (Recommended):
```
postgresql://postgres.[PROJECT_ID]:[PASSWORD]@aws-[region].pooler.supabase.com:6543/postgres
```

### Direct Connection (May not work for new projects):
```
postgresql://postgres:[PASSWORD]@db.[PROJECT_ID].supabase.co:5432/postgres
```

**Always use Transaction pooler for reliability.**

---

## Resources

- **Supabase Dashboard:** https://app.supabase.com
- **Supabase Docs:** https://supabase.com/docs
- **pgvector Docs:** https://github.com/pgvector/pgvector
- **PostgreSQL Docs:** https://www.postgresql.org/docs/
- **LlamaIndex Docs:** https://docs.llamaindex.ai/

---

## Change Log

| Date | What Changed | Notes |
|------|-------------|-------|
| 2024-12-20 | Initial setup complete | Database, schema, documentation |
| 2024-12-20 | Schema created | 5 tables, 3 views, 16 initial tags |

---

## Document Status

- **Version:** 2.0
- **Completed:** Database infrastructure setup
- **Next:** Python project initialization
- **Ready for:** Collaboration and development

---

## Quick Reference Commands

```bash
# Connect to database
PGPASSWORD='password' psql -h aws-region.pooler.supabase.com -p 6543 -U postgres.[PROJECT_ID] -d postgres

# Run schema
PGPASSWORD='password' psql -h aws-region.pooler.supabase.com -p 6543 -U postgres.[PROJECT_ID] -d postgres -f scripts/schema.sql

# Check tables
psql> \dt

# View tags
psql> SELECT * FROM tags;

# Exit
psql> \q
```
