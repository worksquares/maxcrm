-- Table: public.territories
-- Description: Sales territories for geographic and account-based segmentation
-- Supports hierarchical territory management

CREATE TABLE public.territories
(
    territory_id SERIAL PRIMARY KEY,
    territory_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Territory details
    territory_name VARCHAR(255) NOT NULL,
    territory_code VARCHAR(100),
    description TEXT,
    territory_type VARCHAR(50) DEFAULT 'geographic',

    -- Hierarchy
    parent_territory_uuid UUID,
    territory_level INTEGER DEFAULT 1,
    territory_path VARCHAR(1000),

    -- Manager
    territory_manager_uuid UUID,

    -- Geographic criteria (for geographic territories)
    countries TEXT[],
    states TEXT[],
    cities TEXT[],
    zip_codes TEXT[],

    -- Account criteria (for account-based territories)
    account_criteria JSONB DEFAULT '{}'::jsonb,
    industry_codes TEXT[],
    account_size_criteria VARCHAR(100),
    revenue_range_min NUMERIC(15,2),
    revenue_range_max NUMERIC(15,2),

    -- Quotas
    annual_quota NUMERIC(15,2),
    quarterly_quota NUMERIC(15,2),
    monthly_quota NUMERIC(15,2),
    quota_currency VARCHAR(10) DEFAULT 'USD',

    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    effective_from_date DATE,
    effective_to_date DATE,

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
    CONSTRAINT fk_territories_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_territories_parent FOREIGN KEY (parent_territory_uuid)
        REFERENCES public.territories(territory_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_territories_manager FOREIGN KEY (territory_manager_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_territories_type CHECK (territory_type IN ('geographic', 'account_based', 'industry', 'hybrid', 'named_accounts', 'other')),
    CONSTRAINT uq_territories_name UNIQUE (company_id, territory_name)
);

-- Indexes
CREATE INDEX idx_territories_company ON public.territories(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_territories_manager ON public.territories(territory_manager_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_territories_parent ON public.territories(parent_territory_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_territories_active ON public.territories(is_active) WHERE is_deleted = FALSE;
CREATE INDEX idx_territories_countries ON public.territories USING GIN (countries);
CREATE INDEX idx_territories_states ON public.territories USING GIN (states);

-- Comments
COMMENT ON TABLE public.territories IS 'Sales territories with geographic and account-based segmentation';
COMMENT ON COLUMN public.territories.account_criteria IS 'JSON: Complex account matching rules {employee_count_min: 100, annual_revenue_min: 1000000}';
COMMENT ON COLUMN public.territories.territory_path IS 'Full UUID path from root: /uuid1/uuid2/uuid3';
