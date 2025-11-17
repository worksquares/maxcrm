-- Table: public.competitors
-- Description: Competitor profiles for competitive intelligence
-- Track competitor products, strengths, weaknesses

CREATE TABLE public.competitors
(
    competitor_id SERIAL PRIMARY KEY,
    competitor_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Competitor details
    competitor_name VARCHAR(255) NOT NULL,
    legal_name VARCHAR(255),
    website VARCHAR(500),

    -- Industry
    industry VARCHAR(255),
    sub_industry VARCHAR(255),

    -- Size
    company_size VARCHAR(50),
    employee_count_range VARCHAR(50),
    annual_revenue_range VARCHAR(50),

    -- Headquarters
    headquarters_country VARCHAR(100),
    headquarters_state VARCHAR(100),
    headquarters_city VARCHAR(100),
    headquarters_address JSONB DEFAULT '{}'::jsonb,

    -- Contact
    main_phone VARCHAR(50),
    support_phone VARCHAR(50),
    sales_phone VARCHAR(50),

    -- Social media
    linkedin_url VARCHAR(500),
    twitter_url VARCHAR(500),
    facebook_url VARCHAR(500),

    -- Ownership
    owner_uuid UUID,
    team_uuid UUID,

    -- Competitive analysis
    strengths TEXT[],
    weaknesses TEXT[],
    key_products TEXT[],
    pricing_model VARCHAR(100),
    target_market TEXT,

    -- SWOT Analysis
    swot_strengths TEXT,
    swot_weaknesses TEXT,
    swot_opportunities TEXT,
    swot_threats TEXT,

    -- Win/Loss tracking
    total_deals_count INTEGER DEFAULT 0,
    deals_won_count INTEGER DEFAULT 0,
    deals_lost_count INTEGER DEFAULT 0,
    win_rate NUMERIC(5,2) DEFAULT 0,

    -- Status
    threat_level VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,

    -- Notes
    description TEXT,
    internal_notes TEXT,

    -- Flex columns for custom fields
    custom_text_1 VARCHAR(255),
    custom_number_1 NUMERIC(15,2),
    custom_date_1 DATE,

    -- Additional custom fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Standard fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT fk_competitors_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_competitors_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_competitors_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_competitors_size CHECK (company_size IN ('startup', 'small', 'medium', 'large', 'enterprise')),
    CONSTRAINT chk_competitors_threat CHECK (threat_level IN ('low', 'medium', 'high', 'critical')),
    CONSTRAINT uq_competitors_name UNIQUE (company_id, competitor_name)
);

-- Indexes
CREATE INDEX idx_competitors_company ON public.competitors(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_competitors_active ON public.competitors(is_active) WHERE is_deleted = FALSE;
CREATE INDEX idx_competitors_threat ON public.competitors(threat_level) WHERE is_deleted = FALSE;
CREATE INDEX idx_competitors_industry ON public.competitors(industry) WHERE is_deleted = FALSE;

-- Comments
COMMENT ON TABLE public.competitors IS 'Competitor profiles with SWOT analysis and win/loss tracking';
COMMENT ON COLUMN public.competitors.win_rate IS 'Calculated: (deals_won / total_deals) * 100';
COMMENT ON COLUMN public.competitors.threat_level IS 'Competitive threat level assessment';
