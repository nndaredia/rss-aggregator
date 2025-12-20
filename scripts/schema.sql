-- ============================================
-- RSS Feed Aggregator Database Schema
-- ============================================
-- Created: December 20, 2024
-- Database: PostgreSQL 15+ with pgvector extension
-- Purpose: Store and analyze RSS feed articles with AI-powered summarization and semantic search
--
-- Tables:
--   1. feeds - RSS feed sources
--   2. articles - Individual articles from feeds
--   3. summaries - AI-generated article summaries
--   4. tags - Topic tags for categorization
--   5. article_tags - Many-to-many relationship between articles and tags
--
-- Features:
--   - Vector embeddings for semantic search (pgvector)
--   - Time-series analysis support
--   - AI processing tracking
--   - Comprehensive indexing for performance

-- ============================================
-- EXTENSIONS
-- ============================================

-- Enable pgvector extension for vector embeddings
CREATE EXTENSION IF NOT EXISTS vector;

-- ============================================
-- TABLE: feeds
-- Purpose: Store RSS feed sources to monitor
-- ============================================

CREATE TABLE IF NOT EXISTS feeds (
    id SERIAL PRIMARY KEY,
    feed_url TEXT NOT NULL UNIQUE,
    feed_name TEXT NOT NULL,
    feed_category TEXT,
    fetch_frequency INTEGER DEFAULT 3600,  -- Seconds between fetches (default: 1 hour)
    last_fetched TIMESTAMP,
    last_error TEXT,
    error_count INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    modified_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for feeds table
CREATE INDEX IF NOT EXISTS idx_feeds_active ON feeds(is_active);
CREATE INDEX IF NOT EXISTS idx_feeds_last_fetched ON feeds(last_fetched);
CREATE INDEX IF NOT EXISTS idx_feeds_category ON feeds(feed_category);

-- Comments for documentation
COMMENT ON TABLE feeds IS 'RSS feed sources to monitor and collect articles from';
COMMENT ON COLUMN feeds.feed_url IS 'Unique RSS/Atom feed URL';
COMMENT ON COLUMN feeds.fetch_frequency IS 'How often to fetch this feed (in seconds)';
COMMENT ON COLUMN feeds.error_count IS 'Sequential error count - feed marked inactive after threshold';
COMMENT ON COLUMN feeds.is_active IS 'Whether to actively fetch this feed';

-- ============================================
-- TABLE: articles
-- Purpose: Store individual articles from RSS feeds
-- ============================================

CREATE TABLE IF NOT EXISTS articles (
    id SERIAL PRIMARY KEY,
    feed_id INTEGER NOT NULL REFERENCES feeds(id) ON DELETE CASCADE,
    guid TEXT UNIQUE NOT NULL,  -- RSS GUID for deduplication
    title TEXT NOT NULL,
    url TEXT NOT NULL,
    content TEXT,
    content_hash TEXT,  -- For detecting content changes
    published_date TIMESTAMP,
    fetched_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    author TEXT,
    processing_status VARCHAR(20) DEFAULT 'pending' 
        CHECK (processing_status IN ('pending', 'processing', 'completed', 'failed')),
    processing_attempts INTEGER DEFAULT 0
);

-- Indexes for articles table
CREATE INDEX IF NOT EXISTS idx_articles_feed ON articles(feed_id);
CREATE INDEX IF NOT EXISTS idx_articles_published ON articles(published_date DESC);
CREATE INDEX IF NOT EXISTS idx_articles_status ON articles(processing_status);
CREATE INDEX IF NOT EXISTS idx_articles_guid ON articles(guid);
CREATE INDEX IF NOT EXISTS idx_articles_fetched ON articles(fetched_date DESC);

-- Comments
COMMENT ON TABLE articles IS 'Individual articles collected from RSS feeds';
COMMENT ON COLUMN articles.guid IS 'Unique RSS identifier (GUID) for deduplication';
COMMENT ON COLUMN articles.content_hash IS 'Hash of content for detecting updates to existing articles';
COMMENT ON COLUMN articles.processing_status IS 'Status of AI processing: pending, processing, completed, or failed';

-- ============================================
-- TABLE: summaries
-- Purpose: Store AI-generated summaries of articles
-- ============================================

CREATE TABLE IF NOT EXISTS summaries (
    id SERIAL PRIMARY KEY,
    article_id INTEGER NOT NULL UNIQUE REFERENCES articles(id) ON DELETE CASCADE,
    summary_text TEXT NOT NULL,
    summary_type VARCHAR(20) DEFAULT 'brief'
        CHECK (summary_type IN ('brief', 'detailed', 'bullet')),
    word_count INTEGER,
    model_version TEXT NOT NULL,  -- e.g., 'llama3.1', 'claude-sonnet-4'
    processing_time_ms INTEGER,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for summaries table
CREATE INDEX IF NOT EXISTS idx_summaries_article ON summaries(article_id);
CREATE INDEX IF NOT EXISTS idx_summaries_model ON summaries(model_version);

-- Comments
COMMENT ON TABLE summaries IS 'AI-generated summaries of articles (1:1 relationship)';
COMMENT ON COLUMN summaries.summary_type IS 'Type of summary: brief (2-3 sentences), detailed (1-2 paragraphs), or bullet points';
COMMENT ON COLUMN summaries.model_version IS 'LLM model used to generate the summary';
COMMENT ON COLUMN summaries.processing_time_ms IS 'Time taken to generate summary in milliseconds';

-- ============================================
-- TABLE: tags
-- Purpose: Store topic tags for categorization
-- ============================================

CREATE TABLE IF NOT EXISTS tags (
    id SERIAL PRIMARY KEY,
    tag_name TEXT UNIQUE NOT NULL,
    tag_category VARCHAR(50) NOT NULL
        CHECK (tag_category IN ('topic', 'entity', 'sentiment', 'industry')),
    tag_description TEXT,
    parent_tag_id INTEGER REFERENCES tags(id) ON DELETE SET NULL,  -- For hierarchical tags
    usage_count INTEGER DEFAULT 0,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for tags table
CREATE INDEX IF NOT EXISTS idx_tags_category ON tags(tag_category);
CREATE INDEX IF NOT EXISTS idx_tags_name ON tags(tag_name);
CREATE INDEX IF NOT EXISTS idx_tags_usage ON tags(usage_count DESC);

-- Comments
COMMENT ON TABLE tags IS 'Reusable tags for categorizing articles';
COMMENT ON COLUMN tags.tag_category IS 'Category: topic (AI, tech), entity (companies, people), sentiment, or industry';
COMMENT ON COLUMN tags.parent_tag_id IS 'Optional parent tag for hierarchical organization';
COMMENT ON COLUMN tags.usage_count IS 'Number of articles tagged with this tag (for analytics)';

-- ============================================
-- TABLE: article_tags
-- Purpose: Many-to-many relationship between articles and tags
-- ============================================

CREATE TABLE IF NOT EXISTS article_tags (
    article_id INTEGER NOT NULL REFERENCES articles(id) ON DELETE CASCADE,
    tag_id INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    confidence_score FLOAT DEFAULT 1.0
        CHECK (confidence_score >= 0 AND confidence_score <= 1),
    source VARCHAR(20) DEFAULT 'auto'
        CHECK (source IN ('auto', 'manual', 'hybrid')),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (article_id, tag_id)
);

-- Indexes for article_tags table
CREATE INDEX IF NOT EXISTS idx_article_tags_article ON article_tags(article_id);
CREATE INDEX IF NOT EXISTS idx_article_tags_tag ON article_tags(tag_id);
CREATE INDEX IF NOT EXISTS idx_article_tags_confidence ON article_tags(confidence_score DESC);

-- Comments
COMMENT ON TABLE article_tags IS 'Many-to-many relationship between articles and tags';
COMMENT ON COLUMN article_tags.confidence_score IS 'AI confidence in tag assignment (0.0 to 1.0)';
COMMENT ON COLUMN article_tags.source IS 'How tag was assigned: auto (AI), manual (user), or hybrid';

-- ============================================
-- FUNCTION: Update tag usage count
-- Purpose: Automatically update tag usage_count when articles are tagged
-- ============================================

CREATE OR REPLACE FUNCTION update_tag_usage_count()
RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        UPDATE tags SET usage_count = usage_count + 1 WHERE id = NEW.tag_id;
        RETURN NEW;
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE tags SET usage_count = usage_count - 1 WHERE id = OLD.tag_id;
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update tag usage count
DROP TRIGGER IF EXISTS trigger_update_tag_usage ON article_tags;
CREATE TRIGGER trigger_update_tag_usage
    AFTER INSERT OR DELETE ON article_tags
    FOR EACH ROW
    EXECUTE FUNCTION update_tag_usage_count();

-- ============================================
-- FUNCTION: Update modified_date on feeds
-- Purpose: Automatically update modified_date when feed is updated
-- ============================================

CREATE OR REPLACE FUNCTION update_modified_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.modified_date = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update modified_date
DROP TRIGGER IF EXISTS trigger_update_feed_modified ON feeds;
CREATE TRIGGER trigger_update_feed_modified
    BEFORE UPDATE ON feeds
    FOR EACH ROW
    EXECUTE FUNCTION update_modified_date();

-- ============================================
-- INITIAL DATA: Sample tags
-- Purpose: Pre-populate common AI/tech tags
-- ============================================

INSERT INTO tags (tag_name, tag_category, tag_description) VALUES
    -- Topic tags
    ('ai-trends', 'topic', 'High-level direction and trends in AI'),
    ('ai-tools', 'topic', 'New AI tools, features, and products'),
    ('ai-use-cases', 'topic', 'Real-world AI usage examples and applications'),
    ('ai-governance', 'topic', 'AI risk, compliance, security, and regulation'),
    ('ai-agents', 'topic', 'AI agent workflows and automation'),
    ('machine-learning', 'topic', 'Machine learning algorithms and techniques'),
    ('llm', 'topic', 'Large language models and NLP'),
    ('computer-vision', 'topic', 'Image and video AI'),
    ('robotics', 'topic', 'AI in robotics and automation'),
    
    -- Industry tags
    ('healthcare', 'industry', 'AI in healthcare and medicine'),
    ('finance', 'industry', 'AI in financial services'),
    ('education', 'industry', 'AI in education and learning'),
    ('technology', 'industry', 'Technology sector general'),
    
    -- Sentiment tags
    ('positive', 'sentiment', 'Positive developments or sentiment'),
    ('neutral', 'sentiment', 'Neutral or factual reporting'),
    ('negative', 'sentiment', 'Concerns, risks, or negative developments')
ON CONFLICT (tag_name) DO NOTHING;

-- ============================================
-- VIEWS: Useful analytics views
-- ============================================

-- View: Articles with all metadata
CREATE OR REPLACE VIEW v_articles_full AS
SELECT 
    a.id,
    a.guid,
    a.title,
    a.url,
    a.content,
    a.author,
    a.published_date,
    a.fetched_date,
    a.processing_status,
    f.feed_name,
    f.feed_category,
    s.summary_text,
    s.summary_type,
    s.model_version as summary_model,
    COUNT(DISTINCT at.tag_id) as tag_count
FROM articles a
JOIN feeds f ON a.feed_id = f.id
LEFT JOIN summaries s ON a.id = s.article_id
LEFT JOIN article_tags at ON a.id = at.article_id
GROUP BY a.id, f.id, s.id;

COMMENT ON VIEW v_articles_full IS 'Complete article view with feed, summary, and tag count';

-- View: Feed statistics
CREATE OR REPLACE VIEW v_feed_stats AS
SELECT 
    f.id,
    f.feed_name,
    f.feed_category,
    f.is_active,
    f.last_fetched,
    f.error_count,
    COUNT(a.id) as total_articles,
    COUNT(CASE WHEN a.processing_status = 'completed' THEN 1 END) as processed_articles,
    COUNT(CASE WHEN a.processing_status = 'pending' THEN 1 END) as pending_articles,
    MAX(a.published_date) as latest_article_date
FROM feeds f
LEFT JOIN articles a ON f.id = a.feed_id
GROUP BY f.id;

COMMENT ON VIEW v_feed_stats IS 'Statistics and metrics for each feed';

-- View: Tag popularity
CREATE OR REPLACE VIEW v_tag_popularity AS
SELECT 
    t.id,
    t.tag_name,
    t.tag_category,
    t.usage_count,
    COUNT(DISTINCT at.article_id) as article_count,
    AVG(at.confidence_score) as avg_confidence
FROM tags t
LEFT JOIN article_tags at ON t.id = at.tag_id
GROUP BY t.id
ORDER BY t.usage_count DESC;

COMMENT ON VIEW v_tag_popularity IS 'Tag usage statistics and popularity metrics';

-- ============================================
-- COMPLETION MESSAGE
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '========================================';
    RAISE NOTICE 'RSS Aggregator Schema Created Successfully!';
    RAISE NOTICE '========================================';
    RAISE NOTICE 'Tables created:';
    RAISE NOTICE '  - feeds (RSS sources)';
    RAISE NOTICE '  - articles (collected content)';
    RAISE NOTICE '  - summaries (AI-generated summaries)';
    RAISE NOTICE '  - tags (categorization tags)';
    RAISE NOTICE '  - article_tags (article-tag relationships)';
    RAISE NOTICE '';
    RAISE NOTICE 'Views created:';
    RAISE NOTICE '  - v_articles_full (complete article view)';
    RAISE NOTICE '  - v_feed_stats (feed statistics)';
    RAISE NOTICE '  - v_tag_popularity (tag usage metrics)';
    RAISE NOTICE '';
    RAISE NOTICE 'Initial tags populated: 16 tags';
    RAISE NOTICE '';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '  1. Add RSS feeds to the feeds table';
    RAISE NOTICE '  2. Run the fetcher agent to collect articles';
    RAISE NOTICE '  3. Process articles with summarizer and tagger agents';
    RAISE NOTICE '========================================';
END $$;
