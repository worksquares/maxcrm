-- Table: public.invoice_line_items
-- Description: Individual line items in invoices

CREATE TABLE public.invoice_line_items
(
    invoice_line_item_id SERIAL PRIMARY KEY,
    invoice_line_item_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Parent invoice
    invoice_uuid UUID NOT NULL,

    -- Product/Service
    product_uuid UUID,
    product_code VARCHAR(100),
    item_name VARCHAR(255) NOT NULL,
    item_description TEXT,
    item_type VARCHAR(50) DEFAULT 'product',

    -- Pricing
    quantity NUMERIC(12,3) NOT NULL DEFAULT 1,
    unit_price NUMERIC(15,2) NOT NULL,
    discount_percent NUMERIC(5,2) DEFAULT 0,
    discount_amount NUMERIC(15,2) DEFAULT 0,
    tax_percent NUMERIC(5,2) DEFAULT 0,
    tax_amount NUMERIC(15,2) DEFAULT 0,
    line_total NUMERIC(15,2) NOT NULL,

    -- Source documents
    order_line_item_uuid UUID,
    quote_line_item_uuid UUID,

    -- Service period (for recurring/subscription items)
    service_start_date DATE,
    service_end_date DATE,

    -- Line number for ordering
    line_number INTEGER NOT NULL,

    -- Notes
    line_notes TEXT,

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
    CONSTRAINT fk_invoice_line_items_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_invoice_line_items_invoice FOREIGN KEY (invoice_uuid)
        REFERENCES public.invoices(invoice_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_invoice_line_items_product FOREIGN KEY (product_uuid)
        REFERENCES public.products(product_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_invoice_line_items_order_line FOREIGN KEY (order_line_item_uuid)
        REFERENCES public.order_line_items(order_line_item_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_invoice_line_items_quote_line FOREIGN KEY (quote_line_item_uuid)
        REFERENCES public.quote_line_items(quote_line_item_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_invoice_line_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_invoice_line_items_type CHECK (item_type IN ('product', 'service', 'shipping', 'discount', 'other'))
);

-- Indexes
CREATE INDEX idx_invoice_line_items_company ON public.invoice_line_items(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_invoice_line_items_invoice ON public.invoice_line_items(invoice_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_invoice_line_items_product ON public.invoice_line_items(product_uuid) WHERE is_deleted = FALSE;

-- Comments
COMMENT ON TABLE public.invoice_line_items IS 'Individual line items in invoices with pricing and tax details';
COMMENT ON COLUMN public.invoice_line_items.item_type IS 'Type of line item: product, service, shipping, discount, other';
