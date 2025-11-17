-- Table: public.knowledge_articles
-- Description: Knowledge base articles for customer support and self-service
-- Supports versioning, categorization, and multi-language

CREATE TABLE public.knowledge_articles
(
    knowledge_article_id SERIAL PRIMARY KEY,
    knowledge_article_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Article details
    article_number VARCHAR(50) UNIQUE NOT NULL,
    title VARCHAR(500) NOT NULL,
    summary TEXT,
    body_html TEXT,
    body_plain TEXT,

    -- Categorization
    article_type VARCHAR(50) DEFAULT 'how_to',
    category VARCHAR(255),
    subcategory VARCHAR(255),
    tags TEXT[],

    -- Visibility
    visibility VARCHAR(50) DEFAULT 'internal',
    published_status VARCHAR(50) DEFAULT 'draft',

    -- Ownership
    author_uuid UUID,
    owner_uuid UUID,
    team_uuid UUID,

    -- Versioning
    version_number INTEGER DEFAULT 1,
    is_latest_version BOOLEAN DEFAULT TRUE,
    parent_article_uuid UUID,

    -- Language
    language_code VARCHAR(10) DEFAULT 'en',
    translated_from_uuid UUID,

    -- Publishing
    published_at TIMESTAMPTZ,
    published_by_uuid UUID,
    archived_at TIMESTAMPTZ,
    archived_by_uuid UUID,

    -- Dates
    review_date DATE,
    expiration_date DATE,

    -- Engagement metrics
    view_count INTEGER DEFAULT 0,
    helpful_count INTEGER DEFAULT 0,
    not_helpful_count INTEGER DEFAULT 0,
    rating_average NUMERIC(3,2),
    rating_count INTEGER DEFAULT 0,

    -- Attachments
    attachment_uuids UUID[] DEFAULT ARRAY[]::UUID[],

    -- Related articles
    related_article_uuids UUID[] DEFAULT ARRAY[]::UUID[],

    -- SEO
    meta_title VARCHAR(255),
    meta_description TEXT,
    url_slug VARCHAR(255),

    -- Custom fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Standard fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT fk_knowledge_articles_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_knowledge_articles_author FOREIGN KEY (author_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_knowledge_articles_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_knowledge_articles_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_knowledge_articles_published_by FOREIGN KEY (published_by_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_knowledge_articles_parent FOREIGN KEY (parent_article_uuid)
        REFERENCES public.knowledge_articles(knowledge_article_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_knowledge_articles_translated_from FOREIGN KEY (translated_from_uuid)
        REFERENCES public.knowledge_articles(knowledge_article_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_knowledge_articles_type CHECK (article_type IN ('how_to', 'troubleshooting', 'faq', 'reference', 'overview', 'policy', 'other')),
    CONSTRAINT chk_knowledge_articles_visibility CHECK (visibility IN ('internal', 'customer_portal', 'public', 'partner')),
    CONSTRAINT chk_knowledge_articles_status CHECK (published_status IN ('draft', 'in_review', 'approved', 'published', 'archived')),
    CONSTRAINT chk_knowledge_articles_rating CHECK (rating_average IS NULL OR (rating_average >= 0 AND rating_average <= 5))
);

-- Indexes
CREATE INDEX idx_knowledge_articles_company ON public.knowledge_articles(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_knowledge_articles_number ON public.knowledge_articles(article_number) WHERE is_deleted = FALSE;
CREATE INDEX idx_knowledge_articles_author ON public.knowledge_articles(author_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_knowledge_articles_status ON public.knowledge_articles(published_status) WHERE is_deleted = FALSE;
CREATE INDEX idx_knowledge_articles_visibility ON public.knowledge_articles(visibility) WHERE is_deleted = FALSE;
CREATE INDEX idx_knowledge_articles_category ON public.knowledge_articles(category) WHERE is_deleted = FALSE;
CREATE INDEX idx_knowledge_articles_language ON public.knowledge_articles(language_code) WHERE is_deleted = FALSE;
CREATE INDEX idx_knowledge_articles_latest ON public.knowledge_articles(is_latest_version) WHERE is_deleted = FALSE;
CREATE INDEX idx_knowledge_articles_tags ON public.knowledge_articles USING GIN (tags);
CREATE INDEX idx_knowledge_articles_slug ON public.knowledge_articles(url_slug) WHERE is_deleted = FALSE;

-- Full text search
CREATE INDEX idx_knowledge_articles_fts ON public.knowledge_articles USING GIN (to_tsvector('english', title || ' ' || COALESCE(body_plain, '')));

-- Comments
COMMENT ON TABLE public.knowledge_articles IS 'Knowledge base articles with versioning, categorization, and engagement tracking';
COMMENT ON COLUMN public.knowledge_articles.is_latest_version IS 'Whether this is the current published version';
COMMENT ON COLUMN public.knowledge_articles.parent_article_uuid IS 'Reference to previous version for version history';
