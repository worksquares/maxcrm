-- Table: public.deals
-- Sales opportunities/deals

DROP TABLE IF EXISTS public.deals CASCADE;

CREATE TABLE public.deals
(
    deal_id SERIAL PRIMARY KEY,
    deal_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Deal Information
    deal_name VARCHAR(255) NOT NULL,
    deal_number VARCHAR(50),
    description TEXT,

    -- Associated Entities
    account_uuid UUID,
    contact_uuid UUID,
    lead_uuid UUID,

    -- Deal Value
    amount NUMERIC(15,2),
    currency_code VARCHAR(3) DEFAULT 'USD',
    expected_revenue NUMERIC(15,2),
    discount_amount NUMERIC(15,2) DEFAULT 0,
    tax_amount NUMERIC(15,2) DEFAULT 0,
    total_amount NUMERIC(15,2),

    -- Sales Process
    pipeline_uuid UUID,
    stage_uuid UUID,
    probability INTEGER DEFAULT 0,
    deal_type_uuid UUID,

    -- Timeline
    close_date DATE,
    expected_close_date DATE,
    actual_close_date DATE,
    age_days INTEGER DEFAULT 0,

    -- Ownership
    owner_uuid UUID,
    team_uuid UUID,

    -- Competition & Classification
    competitors JSONB DEFAULT '[]'::jsonb,
    deal_source_uuid UUID,

    -- Outcome
    is_won BOOLEAN DEFAULT false,
    is_lost BOOLEAN DEFAULT false,
    lost_reason_uuid UUID,
    won_reason_uuid UUID,
    outcome_notes TEXT,

    -- Next Steps
    next_step TEXT,
    next_step_date DATE,

    -- Custom Fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    tags JSONB DEFAULT '[]'::jsonb,

    -- Status
    is_active BOOLEAN DEFAULT true,
    is_closed BOOLEAN DEFAULT false,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_deals_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_deals_account FOREIGN KEY (account_uuid)
        REFERENCES public.accounts(account_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_deals_contact FOREIGN KEY (contact_uuid)
        REFERENCES public.contacts(contact_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_deals_lead FOREIGN KEY (lead_uuid)
        REFERENCES public.leads(lead_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_deals_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_deals_probability CHECK (probability >= 0 AND probability <= 100)
);

-- Indexes
CREATE INDEX idx_deals_uuid ON public.deals(deal_uuid);
CREATE INDEX idx_deals_company_id ON public.deals(company_id);
CREATE INDEX idx_deals_name ON public.deals(deal_name);
CREATE INDEX idx_deals_account ON public.deals(account_uuid);
CREATE INDEX idx_deals_owner ON public.deals(owner_uuid);
CREATE INDEX idx_deals_company_active ON public.deals(company_id, is_active);
CREATE INDEX idx_deals_stage ON public.deals(stage_uuid);
CREATE INDEX idx_deals_pipeline ON public.deals(pipeline_uuid);
CREATE INDEX idx_deals_close_date ON public.deals(close_date);
CREATE INDEX idx_deals_won ON public.deals(is_won);
CREATE INDEX idx_deals_lost ON public.deals(is_lost);
CREATE INDEX idx_deals_amount ON public.deals(amount DESC);

-- Comments
COMMENT ON TABLE public.deals IS 'Sales opportunities and deals';
COMMENT ON COLUMN public.deals.custom_fields IS 'Custom field values for dynamic fields';
COMMENT ON COLUMN public.deals.age_days IS 'Days since deal was created';
COMMENT ON COLUMN public.deals.competitors IS 'Array of competitor information';
