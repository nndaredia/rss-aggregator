# AI News Aggregator

This project is a simple tool that collects AI news from trusted sources, removes duplicates, generates short summaries, and lets us explore everything in one place. The goal is to stay informed on meaningful AI developments without spending hours reading newsletters and articles.

---

## What This Project Does

The AI News Aggregator will:

- collect articles from multiple AI and tech news sources  
- remove repeated stories  
- write short, clear summaries  
- tag articles using a small set of topics  
- track what topics are increasing or decreasing over time  
- provide a dashboard for quick browsing  
- support natural language questions like “What happened in AI this week?”

This helps us stay current, understand trends, and prepare for conversations with clients and colleagues quickly.

---

## Who This Is For

- **Data and analytics professionals** who need fast, reliable AI updates  
- **Engineers and collaborators** working on or reviewing the tool  
- **Future readers** who may want a simple weekly digest

---

## Key Questions We Want This to Answer

- What happened in AI recently that actually matters?  
- What new tools, products, or agents were released?  
- What use cases are emerging across industries?  
- How are organisations adopting AI?  
- What governance, security, or compliance topics are coming up?  
- Which themes are becoming more common over time?

---

## MVP: What We Are Building First

### ✔ Daily Data Pipeline  
- Collect stories from 4 main sources  
- Deduplicate overlapping stories  
- Store everything in a structured way  

### ✔ AI Processing  
- Generate summaries for each article  
- Tag each article with one of 5 simple topic labels  

### ✔ Dashboard  
- Browse articles by date, tag, or source  
- Ask natural language questions about recent topics  
- View simple trend counts over time  

### ❌ Not in Scope (For Now)  
- User accounts or login  
- Letting users add custom RSS feeds  
- Real-time alerts  
- Mobile app  
- Public signup  
- Weekly digest (planned for after MVP)

---

## Data Sources (MVP)

- Rundown AI  
- TLDR Newsletter  
- TechCrunch  
- Ars Technica  

---

## Topic Tags (MVP)

- **ai-trends** — high-level direction of AI  
- **ai-tools** — new tools, features, or products  
- **ai-use-cases** — real-world usage examples  
- **ai-governance** — risk, compliance, or security topics  
- **ai-agents** — agent workflows and automation  

---

## Roadmap

### Phase 1 — Data Pipeline  
- Build collectors  
- Deduplicate articles  
- Store everything in a database  

### Phase 2 — AI Summaries + Tags  
- Summarise articles  
- Apply topic tags  
- Store the outputs  

### Phase 3 — Dashboard  
- Browse and filter articles  
- Q&A interface  
- Topic counts over time  

### Phase 4 — Weekly Email (Future)  
- Automated weekly digest  
- Top stories and trends  

---

## Project Documents

All planning documents can be found in:

`/documents/news_agg_product_canvas.md`

---

## Current Status

Project setup is complete and planning is documented.  
Next step: build the data ingestion pipeline.
