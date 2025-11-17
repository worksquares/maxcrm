-- Table: public.assets
-- Description: Installed products at customer sites for service tracking
-- Tracks warranty, maintenance, and service history

CREATE TABLE public.assets
(
    asset_id SERIAL PRIMARY KEY,
    asset_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Asset identification
    asset_number VARCHAR(50) UNIQUE NOT NULL,
    asset_name VARCHAR(255) NOT NULL,
    serial_number VARCHAR(255),
    asset_tag VARCHAR(100),

    -- Product
    product_uuid UUID NOT NULL,
    product_name VARCHAR(255),

    -- Customer
    account_uuid UUID NOT NULL,
    contact_uuid UUID,

    -- Location
    installation_location VARCHAR(255),
    site_address JSONB DEFAULT '{}'::jsonb,

    -- Assignment
    owner_uuid UUID,
    team_uuid UUID,

    -- Source
    order_uuid UUID,
    deal_uuid UUID,

    -- Dates
    purchase_date DATE,
    installation_date DATE,
    go_live_date DATE,
    retirement_date DATE,

    -- Warranty
    warranty_start_date DATE,
    warranty_end_date DATE,
    warranty_type VARCHAR(100),
    is_under_warranty BOOLEAN DEFAULT FALSE,

    -- Service contract
    service_contract_uuid UUID,

    -- Status
    status VARCHAR(50) DEFAULT 'active',
    usage_status VARCHAR(50),

    -- Pricing
    purchase_price NUMERIC(15,2),
    current_value NUMERIC(15,2),
    currency_code VARCHAR(10) DEFAULT 'USD',

    -- Technical details
    model_number VARCHAR(255),
    manufacturer VARCHAR(255),
    firmware_version VARCHAR(100),
    software_version VARCHAR(100),

    -- Parent/child hierarchy (for complex assets)
    parent_asset_uuid UUID,
    root_asset_uuid UUID,

    -- Service metrics
    total_cases_count INTEGER DEFAULT 0,
    open_cases_count INTEGER DEFAULT 0,
    last_service_date DATE,
    next_service_date DATE,

    -- Notes
    description TEXT,
    internal_notes TEXT,

    -- Flex columns for custom fields
    custom_text_1 VARCHAR(255),
    custom_text_2 VARCHAR(255),
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
    CONSTRAINT fk_assets_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_assets_product FOREIGN KEY (product_uuid)
        REFERENCES public.products(product_uuid) ON DELETE RESTRICT,
    CONSTRAINT fk_assets_account FOREIGN KEY (account_uuid)
        REFERENCES public.accounts(account_uuid) ON DELETE RESTRICT,
    CONSTRAINT fk_assets_contact FOREIGN KEY (contact_uuid)
        REFERENCES public.contacts(contact_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_assets_order FOREIGN KEY (order_uuid)
        REFERENCES public.orders(order_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_assets_deal FOREIGN KEY (deal_uuid)
        REFERENCES public.deals(deal_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_assets_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_assets_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_assets_parent FOREIGN KEY (parent_asset_uuid)
        REFERENCES public.assets(asset_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_assets_service_contract FOREIGN KEY (service_contract_uuid)
        REFERENCES public.service_contracts(service_contract_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_assets_status CHECK (status IN ('active', 'inactive', 'retired', 'in_repair', 'lost', 'sold', 'disposed')),
    CONSTRAINT chk_assets_usage CHECK (usage_status IN ('in_use', 'idle', 'under_maintenance', 'in_storage', 'other'))
);

-- Indexes
CREATE INDEX idx_assets_company ON public.assets(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_assets_account ON public.assets(account_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_assets_product ON public.assets(product_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_assets_number ON public.assets(asset_number) WHERE is_deleted = FALSE;
CREATE INDEX idx_assets_serial ON public.assets(serial_number) WHERE is_deleted = FALSE;
CREATE INDEX idx_assets_status ON public.assets(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_assets_warranty ON public.assets(is_under_warranty, warranty_end_date) WHERE is_deleted = FALSE;
CREATE INDEX idx_assets_parent ON public.assets(parent_asset_uuid) WHERE is_deleted = FALSE;

-- Comments
COMMENT ON TABLE public.assets IS 'Installed products at customer sites with warranty and service tracking';
COMMENT ON COLUMN public.assets.is_under_warranty IS 'Computed field: TRUE if current date is between warranty dates';
COMMENT ON COLUMN public.assets.root_asset_uuid IS 'Top-level parent asset in hierarchy (for reporting)';
