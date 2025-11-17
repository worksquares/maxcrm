-- Table: public.custom_records
DROP TABLE IF EXISTS public.custom_records CASCADE;

CREATE TABLE public.custom_records
(
    custom_record_id SERIAL PRIMARY KEY,
    custom_record_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    custom_module_uuid UUID NOT NULL,
    record_name VARCHAR(255) NOT NULL,
    record_number VARCHAR(50),
    field_data JSONB DEFAULT '{}'::jsonb,
    owner_uuid UUID,
    status VARCHAR(50) DEFAULT 'active',
    is_active BOOLEAN DEFAULT true,
    is_deleted BOOLEAN DEFAULT false,
    metadata JSONB DEFAULT '{}'::jsonb,
    tags JSONB DEFAULT '[]'::jsonb,
    company_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    CONSTRAINT fk_custom_records_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_custom_records_module FOREIGN KEY (custom_module_uuid) REFERENCES public.custom_modules(custom_module_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_custom_records_owner FOREIGN KEY (owner_uuid) REFERENCES public.users(user_uuid) ON DELETE SET NULL
);

CREATE INDEX idx_custom_records_uuid ON public.custom_records(custom_record_uuid);
CREATE INDEX idx_custom_records_company_id ON public.custom_records(company_id);
CREATE INDEX idx_custom_records_module ON public.custom_records(custom_module_uuid);
CREATE INDEX idx_custom_records_owner ON public.custom_records(owner_uuid);
CREATE INDEX idx_custom_records_company_module ON public.custom_records(company_id, custom_module_uuid);
CREATE INDEX idx_custom_records_company_active ON public.custom_records(company_id, is_active);
CREATE INDEX idx_custom_records_field_data ON public.custom_records USING gin(field_data);

COMMENT ON TABLE public.custom_records IS 'Dynamic records for custom modules with JSONB field storage';
COMMENT ON COLUMN public.custom_records.field_data IS 'All custom field values stored as JSON {field_api_name: value}';
