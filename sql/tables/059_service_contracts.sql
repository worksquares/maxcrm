-- Table: public.service_contracts
-- Description: Service and support contracts with entitlements
-- Defines support levels and SLAs for customers

CREATE TABLE public.service_contracts
(
    service_contract_id SERIAL PRIMARY KEY,
    service_contract_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Contract identification
    contract_number VARCHAR(50) UNIQUE NOT NULL,
    contract_name VARCHAR(255) NOT NULL,
    contract_type VARCHAR(50) DEFAULT 'support',

    -- Customer
    account_uuid UUID NOT NULL,
    contact_uuid UUID,

    -- Source contract
    parent_contract_uuid UUID,

    -- Assignment
    owner_uuid UUID,
    team_uuid UUID,

    -- Dates
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    signed_date DATE,
    renewal_date DATE,

    -- Status
    status VARCHAR(50) DEFAULT 'draft',
    auto_renew BOOLEAN DEFAULT FALSE,

    -- Pricing
    contract_value NUMERIC(15,2),
    annual_value NUMERIC(15,2),
    billing_frequency VARCHAR(50),
    currency_code VARCHAR(10) DEFAULT 'USD',

    -- Coverage
    coverage_hours VARCHAR(100),
    response_time_hours NUMERIC(8,2),
    resolution_time_hours NUMERIC(8,2),

    -- Service levels
    service_level VARCHAR(100),
    sla_terms JSONB DEFAULT '{}'::jsonb,

    -- Entitlements
    max_cases_per_year INTEGER,
    max_support_hours_per_year NUMERIC(10,2),
    included_services JSONB DEFAULT '[]'::jsonb,

    -- Usage tracking
    cases_used INTEGER DEFAULT 0,
    support_hours_used NUMERIC(10,2) DEFAULT 0,

    -- Covered products/assets
    covered_product_uuids UUID[] DEFAULT ARRAY[]::UUID[],
    covered_asset_uuids UUID[] DEFAULT ARRAY[]::UUID[],

    -- Terms
    terms_and_conditions TEXT,
    renewal_terms TEXT,

    -- Notes
    description TEXT,
    internal_notes TEXT,

    -- Flex columns for custom fields
    custom_text_1 VARCHAR(255),
    custom_number_1 NUMERIC(15,2),
    custom_date_1 DATE,
    custom_lookup_1_uuid UUID,

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
    CONSTRAINT fk_service_contracts_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_service_contracts_account FOREIGN KEY (account_uuid)
        REFERENCES public.accounts(account_uuid) ON DELETE RESTRICT,
    CONSTRAINT fk_service_contracts_contact FOREIGN KEY (contact_uuid)
        REFERENCES public.contacts(contact_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_service_contracts_parent FOREIGN KEY (parent_contract_uuid)
        REFERENCES public.contracts(contract_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_service_contracts_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_service_contracts_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_service_contracts_type CHECK (contract_type IN ('support', 'maintenance', 'warranty_extension', 'managed_services', 'consulting', 'other')),
    CONSTRAINT chk_service_contracts_status CHECK (status IN ('draft', 'pending_approval', 'active', 'expired', 'cancelled', 'suspended')),
    CONSTRAINT chk_service_contracts_billing CHECK (billing_frequency IN ('one_time', 'monthly', 'quarterly', 'semi_annual', 'annual')),
    CONSTRAINT chk_service_contracts_dates CHECK (end_date >= start_date)
);

-- Indexes
CREATE INDEX idx_service_contracts_company ON public.service_contracts(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_service_contracts_account ON public.service_contracts(account_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_service_contracts_number ON public.service_contracts(contract_number) WHERE is_deleted = FALSE;
CREATE INDEX idx_service_contracts_status ON public.service_contracts(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_service_contracts_dates ON public.service_contracts(start_date, end_date) WHERE is_deleted = FALSE;
CREATE INDEX idx_service_contracts_renewal ON public.service_contracts(renewal_date) WHERE is_deleted = FALSE AND auto_renew = TRUE;

-- Comments
COMMENT ON TABLE public.service_contracts IS 'Service and support contracts with SLA terms and entitlements';
COMMENT ON COLUMN public.service_contracts.sla_terms IS 'JSON: SLA definitions {p1_response_hours: 1, p2_response_hours: 4, p3_response_hours: 24}';
COMMENT ON COLUMN public.service_contracts.included_services IS 'JSON array: List of included services and support types';
