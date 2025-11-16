-- Table: public.tags
-- Universal tags for all modules

DROP TABLE IF EXISTS public.tags CASCADE;

CREATE TABLE public.tags
(
    tag_id SERIAL PRIMARY KEY,
    tag_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Tag Information
    tag_name VARCHAR(100) NOT NULL,
    tag_color VARCHAR(20),

    -- Category
    tag_category VARCHAR(100),

    -- Usage Count
    usage_count INTEGER DEFAULT 0,

    -- Status
    is_active BOOLEAN DEFAULT true,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_tags_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT uk_tags_company_name UNIQUE (company_id, tag_name)
);

-- Indexes
CREATE INDEX idx_tags_uuid ON public.tags(tag_uuid);
CREATE INDEX idx_tags_company_id ON public.tags(company_id);
CREATE INDEX idx_tags_company_active ON public.tags(company_id, is_active);

-- Comments
COMMENT ON TABLE public.tags IS 'Universal tags for categorizing records';
