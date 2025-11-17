-- Table: public.contracts
-- Description: Business contracts with accounts including terms and renewal tracking

CREATE TABLE public.contracts
(
    contract_id SERIAL PRIMARY KEY,
    contract_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Contract identification
    contract_number VARCHAR(50) UNIQUE NOT NULL,
    contract_name VARCHAR(255) NOT NULL,
    contract_type VARCHAR(50) DEFAULT 'standard',

    -- Customer
    account_uuid UUID NOT NULL,
    contact_uuid UUID,
    billing_contact_uuid UUID,

    -- Source
    deal_uuid UUID,
    quote_uuid UUID,

    -- Assignment
    owner_uuid UUID,
    team_uuid UUID,

    -- Contract value
    currency_code VARCHAR(10) DEFAULT 'USD',
    contract_value NUMERIC(15,2),
    annual_value NUMERIC(15,2),
    monthly_value NUMERIC(15,2),

    -- Dates
    start_date DATE NOT NULL,
    end_date DATE,
    signed_date DATE,
    activated_date DATE,
    terminated_date DATE,

    -- Terms
    contract_term_months INTEGER,
    billing_frequency VARCHAR(50),
    payment_terms VARCHAR(100),
    notice_period_days INTEGER DEFAULT 30,

    -- Status
    status VARCHAR(50) DEFAULT 'draft',

    -- Renewal
    auto_renew BOOLEAN DEFAULT FALSE,
    renewal_term_months INTEGER,
    renewal_notice_days INTEGER DEFAULT 60,
    renewal_date DATE,

    -- Ownership transfer
    company_signed_by_uuid UUID,
    company_signed_date DATE,
    customer_signed_by VARCHAR(255),
    customer_signed_date DATE,

    -- Documents
    contract_document_url VARCHAR(500),
    attachment_uuids UUID[] DEFAULT ARRAY[]::UUID[],

    -- Terms & clauses
    special_terms TEXT,
    termination_clause TEXT,
    sla_terms JSONB DEFAULT '{}'::jsonb,

    -- Addresses (extracted for queries)
    billing_country VARCHAR(100),
    billing_state VARCHAR(100),
    billing_city VARCHAR(100),

    -- Full billing address (for display)
    billing_address JSONB DEFAULT '{}'::jsonb,

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
    CONSTRAINT fk_contracts_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_contracts_account FOREIGN KEY (account_uuid)
        REFERENCES public.accounts(account_uuid) ON DELETE RESTRICT,
    CONSTRAINT fk_contracts_contact FOREIGN KEY (contact_uuid)
        REFERENCES public.contacts(contact_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_contracts_deal FOREIGN KEY (deal_uuid)
        REFERENCES public.deals(deal_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_contracts_quote FOREIGN KEY (quote_uuid)
        REFERENCES public.quotes(quote_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_contracts_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_contracts_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_contracts_signed_by FOREIGN KEY (company_signed_by_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_contracts_type CHECK (contract_type IN ('standard', 'msa', 'nda', 'sow', 'subscription', 'service', 'license', 'other')),
    CONSTRAINT chk_contracts_status CHECK (status IN ('draft', 'pending_approval', 'approved', 'sent', 'in_review', 'signed', 'active', 'expired', 'terminated', 'cancelled')),
    CONSTRAINT chk_contracts_billing CHECK (billing_frequency IN ('one_time', 'monthly', 'quarterly', 'semi_annual', 'annual', 'custom')),
    CONSTRAINT chk_contracts_dates CHECK (end_date IS NULL OR end_date >= start_date)
);

-- Indexes
CREATE INDEX idx_contracts_company ON public.contracts(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_contracts_account ON public.contracts(account_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_contracts_owner ON public.contracts(owner_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_contracts_number ON public.contracts(contract_number) WHERE is_deleted = FALSE;
CREATE INDEX idx_contracts_status ON public.contracts(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_contracts_start_date ON public.contracts(start_date DESC);
CREATE INDEX idx_contracts_end_date ON public.contracts(end_date) WHERE is_deleted = FALSE;
CREATE INDEX idx_contracts_renewal_date ON public.contracts(renewal_date) WHERE is_deleted = FALSE AND auto_renew = TRUE;

-- Comments
COMMENT ON TABLE public.contracts IS 'Business contracts with renewal tracking and SLA terms';
COMMENT ON COLUMN public.contracts.contract_number IS 'Auto-generated unique contract number';
COMMENT ON COLUMN public.contracts.sla_terms IS 'JSON: Service level agreement terms and metrics';
