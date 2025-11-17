-- Table: public.common_master
-- Universal lookup/master data table

DROP TABLE IF EXISTS public.common_master CASCADE;

CREATE TABLE public.common_master
(
    common_master_id SERIAL PRIMARY KEY,
    common_master_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Classification
    type VARCHAR(50) NOT NULL,
    code VARCHAR(50),
    name VARCHAR(255) NOT NULL,
    description TEXT,

    -- Hierarchy
    parent_uuid UUID,
    sort_order INTEGER DEFAULT 0,

    -- Additional Data
    metadata JSONB DEFAULT '{}'::jsonb,

    -- Status
    is_active BOOLEAN DEFAULT true,
    is_system BOOLEAN DEFAULT false,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_common_master_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_common_master_parent FOREIGN KEY (parent_uuid)
        REFERENCES public.common_master(common_master_uuid) ON DELETE SET NULL,
    CONSTRAINT uk_common_master_company_type_code UNIQUE (company_id, type, code),
    CONSTRAINT uk_common_master_company_type_name UNIQUE (company_id, type, name),
    CONSTRAINT chk_common_master_type CHECK (type IN (
        -- CRM Types
        'lead_source', 'lead_status', 'account_type', 'industry', 'account_rating',
        'contact_role', 'deal_stage', 'deal_type', 'lost_reason', 'win_reason',
        'priority', 'task_status', 'task_type', 'event_type', 'call_outcome',
        'email_template_category', 'campaign_type', 'campaign_status',
        -- Product Types
        'product_category', 'product_family', 'price_book', 'currency',
        'tax_type', 'discount_type', 'uom',
        -- Support Types
        'case_type', 'case_priority', 'case_status', 'case_origin',
        'ticket_category', 'sla_type',
        -- Workflow Types
        'workflow_status', 'approval_status', 'workflow_action_type',
        -- General Types
        'country', 'state', 'city', 'timezone', 'language',
        'file_category', 'note_type', 'tag_category'
    ))
);

-- Indexes
CREATE INDEX idx_common_master_uuid ON public.common_master(common_master_uuid);
CREATE INDEX idx_common_master_company_id ON public.common_master(company_id);
CREATE INDEX idx_common_master_type ON public.common_master(type);
CREATE INDEX idx_common_master_company_type ON public.common_master(company_id, type);
CREATE INDEX idx_common_master_company_type_active ON public.common_master(company_id, type, is_active) WHERE is_active = true;
CREATE INDEX idx_common_master_code ON public.common_master(code);
CREATE INDEX idx_common_master_parent ON public.common_master(parent_uuid) WHERE parent_uuid IS NOT NULL;
CREATE INDEX idx_common_master_active ON public.common_master(is_active);
CREATE INDEX idx_common_master_name ON public.common_master(name);

-- Comments
COMMENT ON TABLE public.common_master IS 'Universal master data table for lookups and picklists - replaces ~45 lookup tables';
COMMENT ON COLUMN public.common_master.type IS 'Category of master data (lead_source, industry, etc.) - indexed for fast lookups';
COMMENT ON COLUMN public.common_master.metadata IS 'Additional attributes like color, icon, default_value, etc. - JSONB';
COMMENT ON COLUMN public.common_master.is_system IS 'System-defined values that cannot be deleted';
