-- Table: public.solutions
-- Description: Reusable case solutions library for common issues
-- Helps support agents resolve cases faster

CREATE TABLE public.solutions
(
    solution_id SERIAL PRIMARY KEY,
    solution_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Solution details
    solution_number VARCHAR(50) UNIQUE NOT NULL,
    solution_title VARCHAR(500) NOT NULL,
    problem_description TEXT,
    solution_description TEXT NOT NULL,

    -- Categorization
    category VARCHAR(255),
    subcategory VARCHAR(255),
    tags TEXT[],

    -- Visibility
    visibility VARCHAR(50) DEFAULT 'internal',
    published_status VARCHAR(50) DEFAULT 'draft',

    -- Ownership
    owner_uuid UUID,
    team_uuid UUID,

    -- Publishing
    published_at TIMESTAMPTZ,
    published_by_uuid UUID,

    -- Related knowledge articles
    knowledge_article_uuids UUID[] DEFAULT ARRAY[]::UUID[],

    -- Usage tracking
    times_used_count INTEGER DEFAULT 0,
    helpful_count INTEGER DEFAULT 0,
    not_helpful_count INTEGER DEFAULT 0,
    rating_average NUMERIC(3,2),
    rating_count INTEGER DEFAULT 0,

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
    CONSTRAINT fk_solutions_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_solutions_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_solutions_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_solutions_published_by FOREIGN KEY (published_by_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_solutions_visibility CHECK (visibility IN ('internal', 'customer_portal', 'public')),
    CONSTRAINT chk_solutions_status CHECK (published_status IN ('draft', 'in_review', 'published', 'archived')),
    CONSTRAINT chk_solutions_rating CHECK (rating_average IS NULL OR (rating_average >= 0 AND rating_average <= 5))
);

-- Indexes
CREATE INDEX idx_solutions_company ON public.solutions(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_solutions_number ON public.solutions(solution_number) WHERE is_deleted = FALSE;
CREATE INDEX idx_solutions_owner ON public.solutions(owner_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_solutions_status ON public.solutions(published_status) WHERE is_deleted = FALSE;
CREATE INDEX idx_solutions_category ON public.solutions(category) WHERE is_deleted = FALSE;
CREATE INDEX idx_solutions_tags ON public.solutions USING GIN (tags);

-- Full text search
CREATE INDEX idx_solutions_fts ON public.solutions USING GIN (to_tsvector('english', solution_title || ' ' || COALESCE(problem_description, '') || ' ' || solution_description));

-- Comments
COMMENT ON TABLE public.solutions IS 'Reusable case solutions library with usage tracking';
COMMENT ON COLUMN public.solutions.times_used_count IS 'Number of times this solution was linked to cases';
