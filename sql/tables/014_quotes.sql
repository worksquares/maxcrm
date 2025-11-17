-- Table: public.quotes
DROP TABLE IF EXISTS public.quotes CASCADE;

CREATE TABLE public.quotes
(
    quote_id SERIAL PRIMARY KEY,
    quote_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    quote_name VARCHAR(255) NOT NULL,
    quote_number VARCHAR(50),
    subject VARCHAR(255),
    description TEXT,
    deal_uuid UUID,
    account_uuid UUID,
    contact_uuid UUID,
    subtotal NUMERIC(15,2) DEFAULT 0,
    discount_amount NUMERIC(15,2) DEFAULT 0,
    discount_percentage NUMERIC(5,2) DEFAULT 0,
    tax_amount NUMERIC(15,2) DEFAULT 0,
    shipping_amount NUMERIC(15,2) DEFAULT 0,
    adjustment_amount NUMERIC(15,2) DEFAULT 0,
    total_amount NUMERIC(15,2) NOT NULL,
    currency_code VARCHAR(3) DEFAULT 'USD',
    status VARCHAR(50) DEFAULT 'draft',
    valid_until DATE,
    quote_date DATE,
    accepted_date DATE,
    billing_address_full JSONB DEFAULT '{}'::jsonb,
    shipping_address_full JSONB DEFAULT '{}'::jsonb,
    payment_terms TEXT,
    terms_and_conditions TEXT,
    owner_uuid UUID,
    template_uuid UUID,
    custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT true,
    is_synced_to_deal BOOLEAN DEFAULT false,
    company_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    CONSTRAINT fk_quotes_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_quotes_deal FOREIGN KEY (deal_uuid) REFERENCES public.deals(deal_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_quotes_account FOREIGN KEY (account_uuid) REFERENCES public.accounts(account_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_quotes_contact FOREIGN KEY (contact_uuid) REFERENCES public.contacts(contact_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_quotes_owner FOREIGN KEY (owner_uuid) REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT uk_quotes_company_number UNIQUE (company_id, quote_number),
    CONSTRAINT chk_quotes_status CHECK (status IN ('draft', 'sent', 'viewed', 'accepted', 'rejected', 'expired'))
);

CREATE INDEX idx_quotes_uuid ON public.quotes(quote_uuid);
CREATE INDEX idx_quotes_company_id ON public.quotes(company_id);
CREATE INDEX idx_quotes_number ON public.quotes(quote_number);
CREATE INDEX idx_quotes_deal ON public.quotes(deal_uuid);
CREATE INDEX idx_quotes_account ON public.quotes(account_uuid);
CREATE INDEX idx_quotes_owner ON public.quotes(owner_uuid);
CREATE INDEX idx_quotes_status ON public.quotes(status);
CREATE INDEX idx_quotes_company_active ON public.quotes(company_id, is_active);
