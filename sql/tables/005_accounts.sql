-- Table: public.accounts
-- Customer/Company accounts

DROP TABLE IF EXISTS public.accounts CASCADE;

CREATE TABLE public.accounts
(
    account_id SERIAL PRIMARY KEY,
    account_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Account Information
    account_name VARCHAR(255) NOT NULL,
    account_number VARCHAR(50),
    legal_name VARCHAR(255),

    -- Classification (UUID references to common_master - good for JOINs)
    account_type_uuid UUID,
    industry_uuid UUID,
    account_rating_uuid UUID,
    parent_account_uuid UUID,

    -- Contact Information
    website VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    fax VARCHAR(50),

    -- Billing Address - Extract frequently queried fields
    billing_country VARCHAR(100),
    billing_state VARCHAR(100),
    billing_city VARCHAR(100),
    billing_postal_code VARCHAR(20),
    billing_address_line1 VARCHAR(255),
    billing_address_line2 VARCHAR(255),
    billing_address_full JSONB DEFAULT '{}'::jsonb,

    -- Shipping Address - Extract frequently queried fields
    shipping_country VARCHAR(100),
    shipping_state VARCHAR(100),
    shipping_city VARCHAR(100),
    shipping_postal_code VARCHAR(20),
    shipping_address_line1 VARCHAR(255),
    shipping_address_line2 VARCHAR(255),
    shipping_address_full JSONB DEFAULT '{}'::jsonb,

    -- Business Details (Frequently filtered - keep as columns)
    employee_count INTEGER,
    annual_revenue NUMERIC(15,2),
    tax_id VARCHAR(50),

    -- Ownership
    owner_uuid UUID,
    team_uuid UUID,

    -- Relationship Status
    status VARCHAR(50) DEFAULT 'active',
    lifecycle_stage VARCHAR(50),

    -- Social Media (Display only - JSONB is fine)
    social_links JSONB DEFAULT '{}'::jsonb,

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

    -- Custom Fields (JSONB for overflow and rare-query fields)
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    tags JSONB DEFAULT '[]'::jsonb,

    -- Status
    is_active BOOLEAN DEFAULT true,
    is_customer BOOLEAN DEFAULT false,
    is_vendor BOOLEAN DEFAULT false,
    is_partner BOOLEAN DEFAULT false,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_accounts_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_accounts_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_accounts_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_accounts_parent FOREIGN KEY (parent_account_uuid)
        REFERENCES public.accounts(account_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_accounts_status CHECK (status IN ('active', 'inactive', 'prospect', 'customer', 'partner', 'vendor'))
);

-- Indexes
CREATE INDEX idx_accounts_uuid ON public.accounts(account_uuid);
CREATE INDEX idx_accounts_company_id ON public.accounts(company_id);
CREATE INDEX idx_accounts_name ON public.accounts(account_name);
CREATE INDEX idx_accounts_owner ON public.accounts(owner_uuid);
CREATE INDEX idx_accounts_company_active ON public.accounts(company_id, is_active);
CREATE INDEX idx_accounts_parent ON public.accounts(parent_account_uuid) WHERE parent_account_uuid IS NOT NULL;
CREATE INDEX idx_accounts_status ON public.accounts(status);
CREATE INDEX idx_accounts_type ON public.accounts(account_type_uuid);
CREATE INDEX idx_accounts_industry ON public.accounts(industry_uuid);

-- Geographic indexes for frequently queried address fields
CREATE INDEX idx_accounts_billing_country ON public.accounts(billing_country);
CREATE INDEX idx_accounts_billing_state ON public.accounts(billing_state);
CREATE INDEX idx_accounts_shipping_country ON public.accounts(shipping_country);

-- Indexes on frequently filtered business fields
CREATE INDEX idx_accounts_annual_revenue ON public.accounts(annual_revenue) WHERE annual_revenue IS NOT NULL;
CREATE INDEX idx_accounts_employee_count ON public.accounts(employee_count) WHERE employee_count IS NOT NULL;

-- Indexes on flex columns for custom field queries
CREATE INDEX idx_accounts_custom_number_1 ON public.accounts(custom_number_1) WHERE custom_number_1 IS NOT NULL;
CREATE INDEX idx_accounts_custom_number_2 ON public.accounts(custom_number_2) WHERE custom_number_2 IS NOT NULL;
CREATE INDEX idx_accounts_custom_date_1 ON public.accounts(custom_date_1) WHERE custom_date_1 IS NOT NULL;
CREATE INDEX idx_accounts_custom_lookup_1 ON public.accounts(custom_lookup_1_uuid) WHERE custom_lookup_1_uuid IS NOT NULL;

-- Comments
COMMENT ON TABLE public.accounts IS 'Customer accounts and organizations';
COMMENT ON COLUMN public.accounts.custom_fields IS 'Overflow custom fields (JSONB) for fields not mapped to flex columns';
COMMENT ON COLUMN public.accounts.custom_text_1 IS 'Flex column for frequently queried custom text field';
COMMENT ON COLUMN public.accounts.custom_number_1 IS 'Flex column for frequently queried custom number field';
COMMENT ON COLUMN public.accounts.billing_address_full IS 'Complete billing address JSON for display: {street, city, state, country, postal_code, landmark}';
COMMENT ON COLUMN public.accounts.social_links IS 'Social media links - JSONB: {linkedin, twitter, facebook, etc.}';
