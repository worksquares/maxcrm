-- Table: public.orders
-- Description: Sales orders for fulfillment tracking (post-quote acceptance)
-- Part of Order-to-Cash process

CREATE TABLE public.orders
(
    order_id SERIAL PRIMARY KEY,
    order_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Order identification
    order_number VARCHAR(50) UNIQUE NOT NULL,
    order_name VARCHAR(255),
    order_type VARCHAR(50) DEFAULT 'standard',

    -- Customer
    account_uuid UUID NOT NULL,
    contact_uuid UUID,
    billing_contact_uuid UUID,

    -- Source
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

    -- Addresses (extracted for queries)
    billing_country VARCHAR(100),
    billing_state VARCHAR(100),
    billing_city VARCHAR(100),
    shipping_country VARCHAR(100),
    shipping_state VARCHAR(100),
    shipping_city VARCHAR(100),

    -- Full addresses (for display)
    billing_address JSONB DEFAULT '{}'::jsonb,
    shipping_address JSONB DEFAULT '{}'::jsonb,

    -- Dates
    order_date DATE NOT NULL,
    expected_ship_date DATE,
    actual_ship_date DATE,
    expected_delivery_date DATE,
    actual_delivery_date DATE,

    -- Status
    status VARCHAR(50) DEFAULT 'draft',
    fulfillment_status VARCHAR(50) DEFAULT 'pending',
    payment_status VARCHAR(50) DEFAULT 'pending',

    -- Shipping
    shipping_method VARCHAR(100),
    tracking_number VARCHAR(255),
    shipping_carrier VARCHAR(100),

    -- Terms
    payment_terms VARCHAR(100),
    delivery_terms VARCHAR(100),

    -- Notes
    customer_notes TEXT,
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
    CONSTRAINT fk_orders_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_orders_account FOREIGN KEY (account_uuid)
        REFERENCES public.accounts(account_uuid) ON DELETE RESTRICT,
    CONSTRAINT fk_orders_contact FOREIGN KEY (contact_uuid)
        REFERENCES public.contacts(contact_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_orders_quote FOREIGN KEY (quote_uuid)
        REFERENCES public.quotes(quote_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_orders_deal FOREIGN KEY (deal_uuid)
        REFERENCES public.deals(deal_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_orders_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_orders_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_orders_type CHECK (order_type IN ('standard', 'return', 'exchange', 'sample', 'trial')),
    CONSTRAINT chk_orders_status CHECK (status IN ('draft', 'submitted', 'approved', 'processing', 'completed', 'cancelled', 'on_hold')),
    CONSTRAINT chk_orders_fulfillment CHECK (fulfillment_status IN ('pending', 'partial', 'fulfilled', 'shipped', 'delivered', 'cancelled')),
    CONSTRAINT chk_orders_payment CHECK (payment_status IN ('pending', 'partial', 'paid', 'refunded', 'cancelled'))
);

-- Indexes
CREATE INDEX idx_orders_company ON public.orders(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_orders_account ON public.orders(account_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_orders_owner ON public.orders(owner_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_orders_number ON public.orders(order_number) WHERE is_deleted = FALSE;
CREATE INDEX idx_orders_status ON public.orders(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_orders_order_date ON public.orders(order_date DESC);
CREATE INDEX idx_orders_total_amount ON public.orders(total_amount) WHERE is_deleted = FALSE;
CREATE INDEX idx_orders_shipping_country ON public.orders(shipping_country) WHERE is_deleted = FALSE;

-- Comments
COMMENT ON TABLE public.orders IS 'Sales orders for fulfillment and shipment tracking';
COMMENT ON COLUMN public.orders.order_number IS 'Auto-generated unique order number';
COMMENT ON COLUMN public.orders.fulfillment_status IS 'Tracks item picking, packing, shipping status';
