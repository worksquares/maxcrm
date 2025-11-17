-- Table: public.entitlements
-- Description: Service entitlements defining what support customers are entitled to
-- Links assets/products to service contracts with specific SLA rules

CREATE TABLE public.entitlements
(
    entitlement_id SERIAL PRIMARY KEY,
    entitlement_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Entitlement details
    entitlement_name VARCHAR(255) NOT NULL,
    entitlement_number VARCHAR(50) UNIQUE NOT NULL,

    -- Customer
    account_uuid UUID NOT NULL,

    -- Service contract
    service_contract_uuid UUID NOT NULL,

    -- Coverage
    asset_uuid UUID,
    product_uuid UUID,
    contact_uuid UUID,

    -- Assignment
    owner_uuid UUID,
    team_uuid UUID,

    -- Dates
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    -- Status
    status VARCHAR(50) DEFAULT 'active',

    -- Service levels
    service_level VARCHAR(100),
    case_priority VARCHAR(50),
    business_hours_uuid UUID,

    -- SLA
    response_time_hours NUMERIC(8,2),
    resolution_time_hours NUMERIC(8,2),

    -- Channels
    support_channels JSONB DEFAULT '[]'::jsonb,

    -- Limits
    max_cases INTEGER,
    cases_remaining INTEGER,

    -- Type
    entitlement_type VARCHAR(50) DEFAULT 'support',

    -- Notes
    description TEXT,

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
    CONSTRAINT fk_entitlements_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_entitlements_account FOREIGN KEY (account_uuid)
        REFERENCES public.accounts(account_uuid) ON DELETE RESTRICT,
    CONSTRAINT fk_entitlements_service_contract FOREIGN KEY (service_contract_uuid)
        REFERENCES public.service_contracts(service_contract_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_entitlements_asset FOREIGN KEY (asset_uuid)
        REFERENCES public.assets(asset_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_entitlements_product FOREIGN KEY (product_uuid)
        REFERENCES public.products(product_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_entitlements_contact FOREIGN KEY (contact_uuid)
        REFERENCES public.contacts(contact_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_entitlements_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_entitlements_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_entitlements_status CHECK (status IN ('active', 'expired', 'cancelled', 'suspended')),
    CONSTRAINT chk_entitlements_type CHECK (entitlement_type IN ('support', 'maintenance', 'warranty', 'extended_warranty', 'training', 'other')),
    CONSTRAINT chk_entitlements_dates CHECK (end_date >= start_date)
);

-- Indexes
CREATE INDEX idx_entitlements_company ON public.entitlements(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_entitlements_account ON public.entitlements(account_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_entitlements_service_contract ON public.entitlements(service_contract_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_entitlements_asset ON public.entitlements(asset_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_entitlements_status ON public.entitlements(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_entitlements_dates ON public.entitlements(start_date, end_date) WHERE is_deleted = FALSE;

-- Comments
COMMENT ON TABLE public.entitlements IS 'Service entitlements linking assets/products to service contracts with SLA rules';
COMMENT ON COLUMN public.entitlements.support_channels IS 'JSON array: [phone, email, chat, portal]';
COMMENT ON COLUMN public.entitlements.cases_remaining IS 'Calculated field: max_cases - cases_used from service_contract';
