-- Table: public.campaigns
-- Marketing campaigns

DROP TABLE IF EXISTS public.campaigns CASCADE;

CREATE TABLE public.campaigns
(
    campaign_id SERIAL PRIMARY KEY,
    campaign_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Campaign Information
    campaign_name VARCHAR(255) NOT NULL,
    campaign_code VARCHAR(50),
    description TEXT,

    -- Campaign Type & Status
    campaign_type_uuid UUID,
    status VARCHAR(50) DEFAULT 'planning',

    -- Timeline
    start_date DATE,
    end_date DATE,
    actual_start_date DATE,
    actual_end_date DATE,

    -- Budget & Costs
    budgeted_cost NUMERIC(15,2),
    actual_cost NUMERIC(15,2),
    expected_revenue NUMERIC(15,2),
    currency_code VARCHAR(3) DEFAULT 'USD',

    -- Targets
    expected_responses INTEGER,
    actual_responses INTEGER,
    num_sent INTEGER DEFAULT 0,

    -- Campaign Details
    campaign_source VARCHAR(100),
    parent_campaign_uuid UUID,

    -- Ownership
    owner_uuid UUID,

    -- Custom Fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

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
    CONSTRAINT fk_campaigns_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_campaigns_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_campaigns_parent FOREIGN KEY (parent_campaign_uuid)
        REFERENCES public.campaigns(campaign_uuid) ON DELETE SET NULL,
    CONSTRAINT uk_campaigns_company_code UNIQUE (company_id, campaign_code),
    CONSTRAINT chk_campaigns_status CHECK (status IN ('planning', 'active', 'inactive', 'completed', 'aborted'))
);

-- Indexes
CREATE INDEX idx_campaigns_uuid ON public.campaigns(campaign_uuid);
CREATE INDEX idx_campaigns_company_id ON public.campaigns(company_id);
CREATE INDEX idx_campaigns_owner ON public.campaigns(owner_uuid);
CREATE INDEX idx_campaigns_status ON public.campaigns(status);
CREATE INDEX idx_campaigns_company_active ON public.campaigns(company_id, is_active);
CREATE INDEX idx_campaigns_parent ON public.campaigns(parent_campaign_uuid) WHERE parent_campaign_uuid IS NOT NULL;

-- Comments
COMMENT ON TABLE public.campaigns IS 'Marketing campaigns';
COMMENT ON COLUMN public.campaigns.custom_fields IS 'Custom field values for dynamic fields';
