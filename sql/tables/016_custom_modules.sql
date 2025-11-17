-- Table: public.custom_modules
DROP TABLE IF EXISTS public.custom_modules CASCADE;

CREATE TABLE public.custom_modules
(
    custom_module_id SERIAL PRIMARY KEY,
    custom_module_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    module_name VARCHAR(100) NOT NULL,
    module_label VARCHAR(100) NOT NULL,
    module_label_plural VARCHAR(100),
    module_icon VARCHAR(50),
    description TEXT,
    api_name VARCHAR(100) NOT NULL,
    table_name VARCHAR(100),
    is_standard BOOLEAN DEFAULT false,
    supports_activities BOOLEAN DEFAULT true,
    supports_attachments BOOLEAN DEFAULT true,
    supports_notes BOOLEAN DEFAULT true,
    supports_tags BOOLEAN DEFAULT true,
    quick_create_enabled BOOLEAN DEFAULT true,
    record_image_field VARCHAR(100),
    record_name_field VARCHAR(100),
    permissions JSONB DEFAULT '{}'::jsonb,
    list_view_config JSONB DEFAULT '{}'::jsonb,
    detail_view_config JSONB DEFAULT '{}'::jsonb,
    create_view_config JSONB DEFAULT '{}'::jsonb,
    relationships JSONB DEFAULT '[]'::jsonb,
    settings JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT true,
    is_deleted BOOLEAN DEFAULT false,
    company_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    CONSTRAINT fk_custom_modules_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT uk_custom_modules_company_name UNIQUE (company_id, module_name),
    CONSTRAINT uk_custom_modules_company_api UNIQUE (company_id, api_name)
);

CREATE INDEX idx_custom_modules_uuid ON public.custom_modules(custom_module_uuid);
CREATE INDEX idx_custom_modules_company_id ON public.custom_modules(company_id);
CREATE INDEX idx_custom_modules_api_name ON public.custom_modules(api_name);
CREATE INDEX idx_custom_modules_company_active ON public.custom_modules(company_id, is_active);
