-- Table: public.payments
-- Description: Payment transactions against invoices
-- Tracks all customer payments and refunds

CREATE TABLE public.payments
(
    payment_id SERIAL PRIMARY KEY,
    payment_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Payment identification
    payment_number VARCHAR(50) UNIQUE NOT NULL,
    payment_type VARCHAR(50) DEFAULT 'payment',

    -- Customer
    account_uuid UUID NOT NULL,
    contact_uuid UUID,

    -- Invoice
    invoice_uuid UUID,

    -- Assignment
    owner_uuid UUID,
    team_uuid UUID,

    -- Payment details
    currency_code VARCHAR(10) DEFAULT 'USD',
    payment_amount NUMERIC(15,2) NOT NULL,
    applied_amount NUMERIC(15,2) DEFAULT 0,
    unapplied_amount NUMERIC(15,2) DEFAULT 0,

    -- Dates
    payment_date DATE NOT NULL,
    cleared_date DATE,
    deposit_date DATE,

    -- Payment method
    payment_method VARCHAR(100),
    payment_mode VARCHAR(50),

    -- Payment instrument details
    check_number VARCHAR(100),
    transaction_id VARCHAR(255),
    authorization_code VARCHAR(100),

    -- Card details (last 4 digits only for security)
    card_last_four VARCHAR(4),
    card_type VARCHAR(50),

    -- Bank details
    bank_account_info JSONB DEFAULT '{}'::jsonb,

    -- Status
    status VARCHAR(50) DEFAULT 'pending',
    reconciliation_status VARCHAR(50) DEFAULT 'unreconciled',

    -- Gateway integration
    gateway_name VARCHAR(100),
    gateway_transaction_id VARCHAR(255),
    gateway_response JSONB DEFAULT '{}'::jsonb,

    -- Fees
    processing_fee_amount NUMERIC(15,2) DEFAULT 0,
    late_fee_amount NUMERIC(15,2) DEFAULT 0,

    -- References
    reference_number VARCHAR(255),
    external_reference VARCHAR(255),

    -- Notes
    payment_notes TEXT,
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
    CONSTRAINT fk_payments_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_payments_account FOREIGN KEY (account_uuid)
        REFERENCES public.accounts(account_uuid) ON DELETE RESTRICT,
    CONSTRAINT fk_payments_contact FOREIGN KEY (contact_uuid)
        REFERENCES public.contacts(contact_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_payments_invoice FOREIGN KEY (invoice_uuid)
        REFERENCES public.invoices(invoice_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_payments_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_payments_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_payments_type CHECK (payment_type IN ('payment', 'refund', 'credit', 'advance', 'deposit')),
    CONSTRAINT chk_payments_method CHECK (payment_method IN ('cash', 'check', 'credit_card', 'debit_card', 'bank_transfer', 'wire_transfer', 'ach', 'paypal', 'stripe', 'other')),
    CONSTRAINT chk_payments_status CHECK (status IN ('pending', 'processing', 'cleared', 'failed', 'cancelled', 'refunded')),
    CONSTRAINT chk_payments_reconciliation CHECK (reconciliation_status IN ('unreconciled', 'reconciled', 'disputed')),
    CONSTRAINT chk_payments_amount CHECK (payment_amount > 0)
);

-- Indexes
CREATE INDEX idx_payments_company ON public.payments(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_payments_account ON public.payments(account_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_payments_invoice ON public.payments(invoice_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_payments_number ON public.payments(payment_number) WHERE is_deleted = FALSE;
CREATE INDEX idx_payments_status ON public.payments(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_payments_payment_date ON public.payments(payment_date DESC);
CREATE INDEX idx_payments_reconciliation ON public.payments(reconciliation_status) WHERE is_deleted = FALSE;
CREATE INDEX idx_payments_transaction_id ON public.payments(transaction_id) WHERE is_deleted = FALSE;

-- Comments
COMMENT ON TABLE public.payments IS 'Payment transactions against invoices with gateway integration';
COMMENT ON COLUMN public.payments.unapplied_amount IS 'Amount not yet applied to specific invoices (overpayments)';
COMMENT ON COLUMN public.payments.gateway_response IS 'Full JSON response from payment gateway';
COMMENT ON COLUMN public.payments.bank_account_info IS 'Sanitized bank account info (no full account numbers)';
