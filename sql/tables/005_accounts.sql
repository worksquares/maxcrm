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

    -- Classification
    account_type_uuid UUID,
    industry_uuid UUID,
    account_rating_uuid UUID,
    parent_account_uuid UUID,

    -- Contact Information
    website VARCHAR(255),
    email VARCHAR(255),
    phone VARCHAR(50),
    fax VARCHAR(50),

    -- Address
    billing_address JSONB DEFAULT '{}'::jsonb,
    shipping_address JSONB DEFAULT '{}'::jsonb,

    -- Business Details
    employee_count INTEGER,
    annual_revenue NUMERIC(15,2),
    tax_id VARCHAR(50),

    -- Ownership
    owner_uuid UUID,
    team_uuid UUID,

    -- Relationship Status
    status VARCHAR(50) DEFAULT 'active',
    lifecycle_stage VARCHAR(50),

    -- Social Media
    social_links JSONB DEFAULT '{}'::jsonb,

    -- Custom Fields
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

-- Comments
COMMENT ON TABLE public.accounts IS 'Customer accounts and organizations';
COMMENT ON COLUMN public.accounts.custom_fields IS 'Custom field values for dynamic fields';
COMMENT ON COLUMN public.accounts.billing_address IS 'JSON: {street, city, state, country, postal_code}';
COMMENT ON COLUMN public.accounts.social_links IS 'JSON: {linkedin, twitter, facebook, etc.}';
