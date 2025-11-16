-- Table: public.email_templates
-- Email templates for campaigns and communications

DROP TABLE IF EXISTS public.email_templates CASCADE;

CREATE TABLE public.email_templates
(
    email_template_id SERIAL PRIMARY KEY,
    email_template_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Template Information
    template_name VARCHAR(255) NOT NULL,
    template_code VARCHAR(50),
    description TEXT,

    -- Category
    category VARCHAR(100),
    template_type VARCHAR(50) DEFAULT 'email',

    -- Email Content
    subject VARCHAR(500) NOT NULL,
    body_html TEXT,
    body_text TEXT,

    -- Merge Fields
    available_merge_fields JSONB DEFAULT '[]'::jsonb,

    -- Module Association
    module_name VARCHAR(100),

    -- Template Configuration
    is_shared BOOLEAN DEFAULT false,
    is_default BOOLEAN DEFAULT false,

    -- Ownership
    owner_uuid UUID,

    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    tags JSONB DEFAULT '[]'::jsonb,

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
    CONSTRAINT fk_email_templates_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_email_templates_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT uk_email_templates_company_code UNIQUE (company_id, template_code)
);

-- Indexes
CREATE INDEX idx_email_templates_uuid ON public.email_templates(email_template_uuid);
CREATE INDEX idx_email_templates_company_id ON public.email_templates(company_id);
CREATE INDEX idx_email_templates_category ON public.email_templates(category);
CREATE INDEX idx_email_templates_module ON public.email_templates(module_name);
CREATE INDEX idx_email_templates_company_active ON public.email_templates(company_id, is_active);

-- Comments
COMMENT ON TABLE public.email_templates IS 'Email templates for campaigns and communications';
COMMENT ON COLUMN public.email_templates.available_merge_fields IS 'Available merge fields for this template';
