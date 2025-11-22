# Information Product Canvas: AI News Aggregator

## Vision

> An AI-powered news aggregator that collects, deduplicates, and summarizes AI news from newsletters and tech sites — helping data and analytics professionals stay informed on what matters, understand trends over time, and confidently articulate what AI developments mean for their organizations.

---

## Personas

| Persona | Description | How they'll use it |
|---------|-------------|-------------------|
| Co-Primary | Me — Data strategist working with clients on data/analytics transformation | Browse dashboard, ask natural language questions, prepare for client conversations |
| Co-Primary | Daniel L — Staff Data Engineer, collaborator on this project | Same access to dashboard, co-building the tool |
| Future | Anyone interested in AI news | Subscribe to weekly email digest (read-only, curated) |

---

## Business Questions

*What questions will this product answer?*

1. What are the latest trends in AI and how are they impacting the world?
2. What new tools have been released for natural language querying and how can they make my life easier?
3. What is an AI agent and how can we use it?
4. What use cases is AI actually solving?
5. How are businesses onboarding AI and what efficiencies is it creating?
6. What are the security concerns and governance needs for AI?

---

## Actions / Outcomes

| Action I'll Take | Outcome / Benefit |
|------------------|-------------------|
| Spend 15 mins browsing dashboard instead of 2 hours reading newsletters | Save time while staying informed |
| Ask natural language questions before client meetings | Confidently explain AI trends with recent, concrete examples |
| Track topics over time | Spot emerging trends early, bring proactive insights to clients |
| Share weekly digest with colleagues/network | Build reputation as someone who curates valuable AI insights |

---

## Delivery Types

- [x] React web dashboard (primary - for me and Daniel)
- [x] Weekly email digest (future - for broader sharing)
- [ ] ~~Daily email digest~~
- [ ] ~~Mobile app~~
- [ ] ~~API for other tools~~
- [ ] ~~CLI / Terminal~~

---

## Data Sync

- [ ] Real-time (minutes)
- [ ] Hourly
- [x] Daily
- [ ] Weekly

Why? AI news doesn't move so fast that hourly matters. Daily collection keeps the database current without overcomplicating the system.

---

## Core Data Sources (MVP)

## RSS Feeds for AI News Aggregator (Final List)

| Source          | Type        | Topic         | RSS Feed URL                                           |
|-----------------|-------------|---------------|---------------------------------------------------------|
| Rundown AI      | Newsletter  | AI News       | https://rss.beehiiv.com/feeds/2R3C6Bt5wj.xml           |
| TLDR AI         | Newsletter  | AI Tech       | https://tldr.tech/api/rss/ai                           |
| Ars Technica AI | News Site   | AI / Machine Learning | https://arstechnica.com/ai/feed                 |
| TechCrunch      | News Site   | General Tech (AI posts included; no AI-only feed) | https://techcrunch.com/feed/ |


---

## Topic Tags (MVP)

Articles will be tagged with simple, database-friendly tags:

| Tag | Description |
|-----|-------------|
| ai-trends | Big picture shifts in AI, industry impact |
| ai-tools | New products, features, capabilities |
| ai-use-cases | Real examples of AI being used, business adoption |
| ai-governance | Risk, compliance, security, guardrails |
| ai-agents | Specifically about AI agents and agentic workflows |

---

## Feature Stories (MVP)

1. As a **data professional**, I want to **see deduplicated AI news summaries**, so that **I don't read the same story from 4 sources**
2. As a **data professional**, I want to **browse articles filtered by topic tag**, so that **I can focus on what's relevant (e.g., governance)**
3. As a **data professional**, I want to **ask natural language questions about recent news**, so that **I can quickly prep for client conversations**
4. As a **data professional**, I want to **see which topics are trending (rising/falling)**, so that **I can spot emerging themes early**
5. As a **data professional**, I want to **click through to original sources**, so that **I can dig deeper when needed**

---

## Will / Won't (Scope)

### Will Do (MVP)
- Collect articles from 4 sources (2 newsletters, 2 news sites)
- Deduplicate similar stories
- Generate AI summaries for each article/group
- Tag articles with fixed topic categories
- Store everything in a database with history
- React dashboard to browse and filter articles
- Natural language Q&A interface
- Show topic frequency over time (simple counts, not fancy charts)

### Won't Do (MVP)
- User accounts / login
- Let users add their own RSS feeds
- Real-time alerts or notifications
- Summarize full research papers
- Weekly email digest (move to v2)
- Mobile app
- Public signup

---

## Product Owner

Co-owners: Me and Daniel L

---

## T-Shirt Size Estimate

- [ ] S - Weekend project
- [ ] M - 2-4 weeks
- [ ] L - 1-2 months
- [x] XL - 3+ months

This is a learning project as much as a product. Pace will depend on available time.

---

## Open Questions / Concerns

1. **Scope risk** — Is React dashboard + email digest too much for MVP? 
   - *Resolution: Drop email digest from MVP. Focus on data pipeline + dashboard first.*

2. **AI summarization quality** — Will the summaries be good enough?
   - *Resolution: Start simple, iterate on prompts, improve over time.*

3. **Tagging approach** — How to tag and store things effectively?
   - *Resolution: Start with 5 fixed tags based on business questions. Keep it simple.*

4. **Skills gap** — Using tools and techniques I don't have experience with.
   - *Resolution: This is a learning project. Use the learning guide, collaborator, and Claude for support. Build incrementally.*

---

## Revised MVP Definition

**Phase 1: Data Pipeline (start here)**
- Set up database schema
- Build RSS collector for 4 sources
- Store articles with deduplication

**Phase 2: AI Processing**
- Add summarization agent
- Add tagging agent
- Store summaries and tags

**Phase 3: React Dashboard**
- Browse articles with filters
- Natural language Q&A
- Simple trend counts

**Phase 4 (Future): Email Digest**
- Weekly automated email
- Top stories + trends + one insight

---

*Last Updated: 2025-11-22*
