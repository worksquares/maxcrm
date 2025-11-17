-- Table: public.order_line_items
-- Description: Individual line items in orders with fulfillment tracking

CREATE TABLE public.order_line_items
(
    order_line_item_id SERIAL PRIMARY KEY,
    order_line_item_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Parent order
    order_uuid UUID NOT NULL,

    -- Product
    product_uuid UUID NOT NULL,
    product_code VARCHAR(100),
    product_name VARCHAR(255) NOT NULL,
    product_description TEXT,

    -- Pricing
    quantity NUMERIC(12,3) NOT NULL,
    unit_price NUMERIC(15,2) NOT NULL,
    discount_percent NUMERIC(5,2) DEFAULT 0,
    discount_amount NUMERIC(15,2) DEFAULT 0,
    tax_percent NUMERIC(5,2) DEFAULT 0,
    tax_amount NUMERIC(15,2) DEFAULT 0,
    line_total NUMERIC(15,2) NOT NULL,

    -- Source quote line
    quote_line_item_uuid UUID,

    -- Fulfillment
    fulfillment_status VARCHAR(50) DEFAULT 'pending',
    quantity_ordered NUMERIC(12,3),
    quantity_fulfilled NUMERIC(12,3) DEFAULT 0,
    quantity_shipped NUMERIC(12,3) DEFAULT 0,
    quantity_cancelled NUMERIC(12,3) DEFAULT 0,

    -- Inventory
    warehouse_location VARCHAR(255),
    bin_location VARCHAR(100),
    serial_numbers TEXT[],
    batch_numbers TEXT[],

    -- Dates
    expected_ship_date DATE,
    actual_ship_date DATE,

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
    CONSTRAINT fk_order_line_items_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_order_line_items_order FOREIGN KEY (order_uuid)
        REFERENCES public.orders(order_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_order_line_items_product FOREIGN KEY (product_uuid)
        REFERENCES public.products(product_uuid) ON DELETE RESTRICT,
    CONSTRAINT fk_order_line_items_quote_line FOREIGN KEY (quote_line_item_uuid)
        REFERENCES public.quote_line_items(quote_line_item_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_order_line_items_quantity CHECK (quantity > 0),
    CONSTRAINT chk_order_line_items_fulfillment CHECK (fulfillment_status IN ('pending', 'allocated', 'picked', 'packed', 'shipped', 'delivered', 'cancelled', 'returned'))
);

-- Indexes
CREATE INDEX idx_order_line_items_company ON public.order_line_items(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_order_line_items_order ON public.order_line_items(order_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_order_line_items_product ON public.order_line_items(product_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_order_line_items_fulfillment ON public.order_line_items(fulfillment_status) WHERE is_deleted = FALSE;

-- Comments
COMMENT ON TABLE public.order_line_items IS 'Order line items with fulfillment and inventory tracking';
COMMENT ON COLUMN public.order_line_items.serial_numbers IS 'Array of serial numbers for serialized items';
COMMENT ON COLUMN public.order_line_items.batch_numbers IS 'Array of batch/lot numbers for batch-tracked items';
