-- Table: public.record_tags
DROP TABLE IF EXISTS public.record_tags CASCADE;
CREATE TABLE public.record_tags (
    record_tag_id SERIAL PRIMARY KEY, record_tag_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    tag_uuid UUID NOT NULL, module_name VARCHAR(100) NOT NULL, record_uuid UUID NOT NULL,
    company_id INTEGER NOT NULL, created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), created_by UUID,
    CONSTRAINT fk_record_tags_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_record_tags_tag FOREIGN KEY (tag_uuid) REFERENCES public.tags(tag_uuid) ON DELETE CASCADE,
    CONSTRAINT uk_record_tags_unique UNIQUE (tag_uuid, module_name, record_uuid)
);
CREATE INDEX idx_record_tags_tag ON public.record_tags(tag_uuid);
CREATE INDEX idx_record_tags_record ON public.record_tags(module_name, record_uuid);