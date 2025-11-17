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

    -- Associated Entities (UUIDs for efficient JOINs)
    account_uuid UUID,
    contact_uuid UUID,
    lead_uuid UUID,

    -- Deal Value (Frequently filtered - keep as columns)
    amount NUMERIC(15,2),
    currency_code VARCHAR(3) DEFAULT 'USD',
    expected_revenue NUMERIC(15,2),
    discount_amount NUMERIC(15,2) DEFAULT 0,
    tax_amount NUMERIC(15,2) DEFAULT 0,
    total_amount NUMERIC(15,2),

    -- Sales Process (Frequently filtered/joined)
    pipeline_uuid UUID,
    stage_uuid UUID,
    probability INTEGER DEFAULT 0,
    deal_type_uuid UUID,

    -- Timeline (Frequently filtered/sorted)
    close_date DATE,
    expected_close_date DATE,
    actual_close_date DATE,
    age_days INTEGER DEFAULT 0,

    -- Ownership (Frequently filtered)
    owner_uuid UUID,
    team_uuid UUID,

    -- Deal Source
    deal_source_uuid UUID,

    -- Outcome (Frequently filtered)
    is_won BOOLEAN DEFAULT false,
    is_lost BOOLEAN DEFAULT false,
    is_closed BOOLEAN DEFAULT false,
    lost_reason_uuid UUID,
    won_reason_uuid UUID,
    outcome_notes TEXT,

    -- Next Steps
    next_step TEXT,
    next_step_date DATE,

    -- Competition (Display only - JSONB fine)
    competitors JSONB DEFAULT '[]'::jsonb,

    -- Flex Columns for High-Query Custom Fields
    custom_text_1 VARCHAR(255),
    custom_text_2 VARCHAR(255),
    custom_text_3 VARCHAR(255),
    custom_number_1 NUMERIC(15,2),
    custom_number_2 NUMERIC(15,2),
    custom_date_1 DATE,
    custom_date_2 DATE,
    custom_boolean_1 BOOLEAN,
    custom_boolean_2 BOOLEAN,
    custom_lookup_1_uuid UUID,
    custom_lookup_2_uuid UUID,

    -- Custom Fields (JSONB for overflow)
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
    CONSTRAINT fk_deals_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_deals_account FOREIGN KEY (account_uuid)
        REFERENCES public.accounts(account_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_deals_contact FOREIGN KEY (contact_uuid)
        REFERENCES public.contacts(contact_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_deals_lead FOREIGN KEY (lead_uuid)
        REFERENCES public.leads(lead_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_deals_owner FOREIGN KEY (owner_uuid)
    CONSTRAINT fk_deals_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
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
CREATE INDEX idx_deals_expected_close_date ON public.deals(expected_close_date);
CREATE INDEX idx_deals_won ON public.deals(is_won);
CREATE INDEX idx_deals_lost ON public.deals(is_lost);
CREATE INDEX idx_deals_closed ON public.deals(is_closed);
CREATE INDEX idx_deals_amount ON public.deals(amount DESC NULLS LAST);
CREATE INDEX idx_deals_total_amount ON public.deals(total_amount DESC NULLS LAST);
CREATE INDEX idx_deals_pipeline_stage ON public.deals(pipeline_uuid, stage_uuid);
CREATE INDEX idx_deals_owner_active ON public.deals(owner_uuid, is_active) WHERE is_active = true;
CREATE INDEX idx_deals_custom_number_1 ON public.deals(custom_number_1) WHERE custom_number_1 IS NOT NULL;
CREATE INDEX idx_deals_custom_date_1 ON public.deals(custom_date_1) WHERE custom_date_1 IS NOT NULL;

-- Comments
COMMENT ON TABLE public.deals IS 'Sales opportunities and deals';
COMMENT ON COLUMN public.deals.custom_fields IS 'Overflow custom fields (JSONB)';
COMMENT ON COLUMN public.deals.amount IS 'Primary deal amount - frequently filtered';
COMMENT ON COLUMN public.deals.stage_uuid IS 'Current deal stage - frequently joined to pipeline_stages';
