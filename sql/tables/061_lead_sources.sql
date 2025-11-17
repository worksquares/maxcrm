-- Table: public.lead_sources
-- Description: Detailed lead source tracking for attribution and ROI analysis
-- Separate table from common_master for richer source data

CREATE TABLE public.lead_sources
(
    lead_source_id SERIAL PRIMARY KEY,
    lead_source_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Source details
    source_name VARCHAR(255) NOT NULL,
    source_code VARCHAR(100),
    source_type VARCHAR(50) DEFAULT 'other',

    -- Categorization
    category VARCHAR(100),
    subcategory VARCHAR(100),

    -- Campaign
    campaign_uuid UUID,

    -- Owner
    owner_uuid UUID,
    team_uuid UUID,

    -- Cost tracking
    cost_per_lead NUMERIC(15,2),
    monthly_budget NUMERIC(15,2),
    total_spent NUMERIC(15,2) DEFAULT 0,
    currency_code VARCHAR(10) DEFAULT 'USD',

    -- Performance metrics
    total_leads_count INTEGER DEFAULT 0,
    qualified_leads_count INTEGER DEFAULT 0,
    converted_leads_count INTEGER DEFAULT 0,
    conversion_rate NUMERIC(5,2) DEFAULT 0,

    -- Revenue attribution
    total_revenue NUMERIC(15,2) DEFAULT 0,
    won_deals_count INTEGER DEFAULT 0,

    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    start_date DATE,
    end_date DATE,

    -- UTM parameters (for web sources)
    utm_source VARCHAR(255),
    utm_medium VARCHAR(255),
    utm_campaign VARCHAR(255),
    utm_term VARCHAR(255),
    utm_content VARCHAR(255),

    -- Notes
    description TEXT,
    internal_notes TEXT,

    -- Custom fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Standard fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT fk_lead_sources_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_lead_sources_campaign FOREIGN KEY (campaign_uuid)
        REFERENCES public.campaigns(campaign_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_lead_sources_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_lead_sources_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_lead_sources_type CHECK (source_type IN ('web', 'email', 'social', 'paid_search', 'organic_search', 'referral', 'event', 'cold_call', 'partner', 'trade_show', 'content', 'advertisement', 'webinar', 'other')),
    CONSTRAINT uq_lead_sources_name UNIQUE (company_id, source_name)
);

-- Indexes
CREATE INDEX idx_lead_sources_company ON public.lead_sources(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_lead_sources_active ON public.lead_sources(is_active) WHERE is_deleted = FALSE;
CREATE INDEX idx_lead_sources_campaign ON public.lead_sources(campaign_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_lead_sources_type ON public.lead_sources(source_type) WHERE is_deleted = FALSE;
CREATE INDEX idx_lead_sources_utm_source ON public.lead_sources(utm_source) WHERE is_deleted = FALSE;

-- Comments
COMMENT ON TABLE public.lead_sources IS 'Lead source tracking with cost, performance, and revenue attribution';
COMMENT ON COLUMN public.lead_sources.conversion_rate IS 'Calculated: (converted_leads / total_leads) * 100';
COMMENT ON COLUMN public.lead_sources.cost_per_lead IS 'Average cost to acquire one lead from this source';
