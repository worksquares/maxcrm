-- Table: public.email_templates
DROP TABLE IF EXISTS public.email_templates CASCADE;
CREATE TABLE public.email_templates (
    email_template_id SERIAL PRIMARY KEY, email_template_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    template_name VARCHAR(255) NOT NULL, template_code VARCHAR(50), description TEXT,
    category VARCHAR(100), template_type VARCHAR(50) DEFAULT 'email',
    subject VARCHAR(500) NOT NULL, body_html TEXT, body_text TEXT,
    available_merge_fields JSONB DEFAULT '[]'::jsonb, module_name VARCHAR(100),
    is_shared BOOLEAN DEFAULT false, is_default BOOLEAN DEFAULT false, owner_uuid UUID,
    metadata JSONB DEFAULT '{}'::jsonb, tags JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT true, company_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, updated_by UUID,
    CONSTRAINT fk_email_templates_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_email_templates_owner FOREIGN KEY (owner_uuid) REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT uk_email_templates_company_code UNIQUE (company_id, template_code)
);
CREATE INDEX idx_email_templates_uuid ON public.email_templates(email_template_uuid);
CREATE INDEX idx_email_templates_category ON public.email_templates(category);