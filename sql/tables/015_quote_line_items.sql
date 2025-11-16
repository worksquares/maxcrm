-- Table: public.quote_line_items
-- Line items within quotes

DROP TABLE IF EXISTS public.quote_line_items CASCADE;

CREATE TABLE public.quote_line_items
(
    quote_line_item_id SERIAL PRIMARY KEY,
    quote_line_item_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Associations
    quote_uuid UUID NOT NULL,
    product_uuid UUID,

    -- Item Details
    item_name VARCHAR(255) NOT NULL,
    description TEXT,

    -- Quantity & Pricing
    quantity NUMERIC(15,3) DEFAULT 1,
    unit_price NUMERIC(15,2) NOT NULL,
    list_price NUMERIC(15,2),

    -- Discounts
    discount_amount NUMERIC(15,2) DEFAULT 0,
    discount_percentage NUMERIC(5,2) DEFAULT 0,

    -- Calculated Amounts
    line_total NUMERIC(15,2) NOT NULL,
    tax_amount NUMERIC(15,2) DEFAULT 0,

    -- Tax
    is_taxable BOOLEAN DEFAULT true,
    tax_rate NUMERIC(5,2),

    -- Sort Order
    line_number INTEGER DEFAULT 0,
    sort_order INTEGER DEFAULT 0,

    -- Custom Fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,

    -- Status
    is_active BOOLEAN DEFAULT true,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_quote_items_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_quote_items_quote FOREIGN KEY (quote_uuid)
        REFERENCES public.quotes(quote_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_quote_items_product FOREIGN KEY (product_uuid)
        REFERENCES public.products(product_uuid) ON DELETE SET NULL
);

-- Indexes
CREATE INDEX idx_quote_items_uuid ON public.quote_line_items(quote_line_item_uuid);
CREATE INDEX idx_quote_items_company_id ON public.quote_line_items(company_id);
CREATE INDEX idx_quote_items_quote ON public.quote_line_items(quote_uuid);
CREATE INDEX idx_quote_items_product ON public.quote_line_items(product_uuid);
CREATE INDEX idx_quote_items_quote_order ON public.quote_line_items(quote_uuid, sort_order);

-- Comments
COMMENT ON TABLE public.quote_line_items IS 'Line items within sales quotes';
