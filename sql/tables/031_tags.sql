-- Table: public.tags
DROP TABLE IF EXISTS public.tags CASCADE;
CREATE TABLE public.tags (
    tag_id SERIAL PRIMARY KEY, tag_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    tag_name VARCHAR(100) NOT NULL, tag_color VARCHAR(20), tag_category VARCHAR(100),
    usage_count INTEGER DEFAULT 0, is_active BOOLEAN DEFAULT true, company_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, updated_by UUID,
    CONSTRAINT fk_tags_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT uk_tags_company_name UNIQUE (company_id, tag_name)
);
CREATE INDEX idx_tags_uuid ON public.tags(tag_uuid);