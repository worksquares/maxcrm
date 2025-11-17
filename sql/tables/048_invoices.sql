-- Table: public.invoices
-- Description: Customer invoices for billing and payment tracking
-- Part of Order-to-Cash process

CREATE TABLE public.invoices
(
    invoice_id SERIAL PRIMARY KEY,
    invoice_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Invoice identification
    invoice_number VARCHAR(50) UNIQUE NOT NULL,
    invoice_name VARCHAR(255),
    invoice_type VARCHAR(50) DEFAULT 'standard',

    -- Customer
    account_uuid UUID NOT NULL,
    contact_uuid UUID,
    billing_contact_uuid UUID,

    -- Source documents
    order_uuid UUID,
    quote_uuid UUID,
    deal_uuid UUID,

    -- Assignment
    owner_uuid UUID,
    team_uuid UUID,

    -- Pricing
    currency_code VARCHAR(10) DEFAULT 'USD',
    subtotal_amount NUMERIC(15,2) DEFAULT 0,
    discount_amount NUMERIC(15,2) DEFAULT 0,
    tax_amount NUMERIC(15,2) DEFAULT 0,
    shipping_amount NUMERIC(15,2) DEFAULT 0,
    total_amount NUMERIC(15,2) DEFAULT 0,
    amount_paid NUMERIC(15,2) DEFAULT 0,
    amount_due NUMERIC(15,2) DEFAULT 0,

    -- Addresses (extracted for queries)
    billing_country VARCHAR(100),
    billing_state VARCHAR(100),
    billing_city VARCHAR(100),

    -- Full billing address (for display)
    billing_address JSONB DEFAULT '{}'::jsonb,

    -- Dates
    invoice_date DATE NOT NULL,
    due_date DATE,
    service_start_date DATE,
    service_end_date DATE,
    paid_date DATE,

    -- Status
    status VARCHAR(50) DEFAULT 'draft',
    payment_status VARCHAR(50) DEFAULT 'unpaid',

    -- Payment terms
    payment_terms VARCHAR(100),
    payment_method VARCHAR(100),
    late_fee_percentage NUMERIC(5,2) DEFAULT 0,

    -- Banking details
    bank_account_info JSONB DEFAULT '{}'::jsonb,

    -- Notes
    customer_notes TEXT,
    internal_notes TEXT,
    terms_and_conditions TEXT,

    -- Recurring
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_pattern JSONB DEFAULT '{}'::jsonb,

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
    CONSTRAINT fk_invoices_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_invoices_account FOREIGN KEY (account_uuid)
        REFERENCES public.accounts(account_uuid) ON DELETE RESTRICT,
    CONSTRAINT fk_invoices_contact FOREIGN KEY (contact_uuid)
        REFERENCES public.contacts(contact_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_invoices_order FOREIGN KEY (order_uuid)
        REFERENCES public.orders(order_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_invoices_quote FOREIGN KEY (quote_uuid)
        REFERENCES public.quotes(quote_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_invoices_deal FOREIGN KEY (deal_uuid)
        REFERENCES public.deals(deal_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_invoices_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_invoices_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_invoices_type CHECK (invoice_type IN ('standard', 'credit_memo', 'debit_memo', 'proforma', 'recurring')),
    CONSTRAINT chk_invoices_status CHECK (status IN ('draft', 'sent', 'viewed', 'approved', 'cancelled', 'void')),
    CONSTRAINT chk_invoices_payment CHECK (payment_status IN ('unpaid', 'partial', 'paid', 'overdue', 'refunded', 'written_off'))
);

-- Indexes
CREATE INDEX idx_invoices_company ON public.invoices(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_invoices_account ON public.invoices(account_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_invoices_owner ON public.invoices(owner_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_invoices_number ON public.invoices(invoice_number) WHERE is_deleted = FALSE;
CREATE INDEX idx_invoices_status ON public.invoices(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_invoices_payment_status ON public.invoices(payment_status) WHERE is_deleted = FALSE;
CREATE INDEX idx_invoices_invoice_date ON public.invoices(invoice_date DESC);
CREATE INDEX idx_invoices_due_date ON public.invoices(due_date) WHERE is_deleted = FALSE;
CREATE INDEX idx_invoices_amount_due ON public.invoices(amount_due) WHERE is_deleted = FALSE AND amount_due > 0;

-- Comments
COMMENT ON TABLE public.invoices IS 'Customer invoices for billing and payment tracking';
COMMENT ON COLUMN public.invoices.invoice_number IS 'Auto-generated unique invoice number';
COMMENT ON COLUMN public.invoices.recurring_pattern IS 'JSON: {frequency: monthly|yearly, interval: 1, next_invoice_date: 2024-12-01}';
