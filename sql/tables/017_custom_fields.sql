-- Table: public.custom_fields
DROP TABLE IF EXISTS public.custom_fields CASCADE;

CREATE TABLE public.custom_fields
(
    custom_field_id SERIAL PRIMARY KEY,
    custom_field_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    field_name VARCHAR(100) NOT NULL,
    field_label VARCHAR(100) NOT NULL,
    field_api_name VARCHAR(100) NOT NULL,
    help_text TEXT,
    placeholder TEXT,
    module_name VARCHAR(100) NOT NULL,
    custom_module_uuid UUID,
    field_type VARCHAR(50) NOT NULL,
    data_type VARCHAR(50) NOT NULL,
    is_required BOOLEAN DEFAULT false,
    is_unique BOOLEAN DEFAULT false,
    is_searchable BOOLEAN DEFAULT true,
    is_filterable BOOLEAN DEFAULT true,
    is_sortable BOOLEAN DEFAULT true,
    is_visible_in_list BOOLEAN DEFAULT true,
    is_visible_in_detail BOOLEAN DEFAULT true,
    is_visible_in_create BOOLEAN DEFAULT true,
    is_visible_in_edit BOOLEAN DEFAULT true,
    validation_rules JSONB DEFAULT '{}'::jsonb,
    min_length INTEGER,
    max_length INTEGER,
    min_value NUMERIC(15,2),
    max_value NUMERIC(15,2),
    regex_pattern VARCHAR(255),
    field_options JSONB DEFAULT '[]'::jsonb,
    lookup_module VARCHAR(100),
    lookup_field VARCHAR(100),
    default_value TEXT,
    default_value_config JSONB DEFAULT '{}'::jsonb,
    is_calculated BOOLEAN DEFAULT false,
    formula TEXT,
    dependent_on_field UUID,
    dependency_config JSONB DEFAULT '{}'::jsonb,
    field_group VARCHAR(100),
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    is_system BOOLEAN DEFAULT false,
    company_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    CONSTRAINT fk_custom_fields_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_custom_fields_module FOREIGN KEY (custom_module_uuid) REFERENCES public.custom_modules(custom_module_uuid) ON DELETE CASCADE,
    CONSTRAINT uk_custom_fields_module_api_name UNIQUE (company_id, module_name, field_api_name),
    CONSTRAINT chk_custom_fields_type CHECK (field_type IN (
        'text', 'textarea', 'number', 'decimal', 'currency', 'percentage',
        'date', 'datetime', 'time', 'email', 'phone', 'url',
        'picklist', 'multi_select', 'checkbox', 'radio',
        'lookup', 'auto_number', 'formula', 'file', 'image',
        'rich_text', 'json', 'rating'
    )),
    CONSTRAINT chk_custom_fields_data_type CHECK (data_type IN (
        'string', 'integer', 'decimal', 'boolean', 'date', 'datetime',
        'text', 'json', 'uuid', 'array'
    ))
);

CREATE INDEX idx_custom_fields_uuid ON public.custom_fields(custom_field_uuid);
CREATE INDEX idx_custom_fields_company_id ON public.custom_fields(company_id);
CREATE INDEX idx_custom_fields_module ON public.custom_fields(module_name);
CREATE INDEX idx_custom_fields_custom_module ON public.custom_fields(custom_module_uuid);
CREATE INDEX idx_custom_fields_company_module ON public.custom_fields(company_id, module_name);
CREATE INDEX idx_custom_fields_company_active ON public.custom_fields(company_id, is_active);
CREATE INDEX idx_custom_fields_type ON public.custom_fields(field_type);

COMMENT ON COLUMN public.custom_fields.field_options IS 'Options for picklist/multi-select - JSONB: [{value, label, color, is_default}]';
COMMENT ON COLUMN public.custom_fields.validation_rules IS 'Validation configuration and error messages - JSONB';
