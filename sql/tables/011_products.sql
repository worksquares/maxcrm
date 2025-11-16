-- Table: public.products
-- Product catalog

DROP TABLE IF EXISTS public.products CASCADE;

CREATE TABLE public.products
(
    product_id SERIAL PRIMARY KEY,
    product_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Product Information
    product_name VARCHAR(255) NOT NULL,
    product_code VARCHAR(100),
    sku VARCHAR(100),
    description TEXT,

    -- Classification
    product_category_uuid UUID,
    product_family_uuid UUID,

    -- Product Type
    product_type VARCHAR(50) DEFAULT 'standard',

    -- Pricing
    list_price NUMERIC(15,2),
    cost_price NUMERIC(15,2),
    currency_code VARCHAR(3) DEFAULT 'USD',

    -- Units
    unit_of_measure VARCHAR(50),

    -- Inventory
    is_tracked BOOLEAN DEFAULT false,
    quantity_available INTEGER DEFAULT 0,
    reorder_level INTEGER,

    -- Tax
    is_taxable BOOLEAN DEFAULT true,
    tax_rate NUMERIC(5,2),

    -- Lifecycle
    is_active BOOLEAN DEFAULT true,
    is_available_for_sale BOOLEAN DEFAULT true,

    -- Specifications
    specifications JSONB DEFAULT '{}'::jsonb,

    -- Custom Fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    tags JSONB DEFAULT '[]'::jsonb,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_products_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT uk_products_company_code UNIQUE (company_id, product_code),
    CONSTRAINT chk_products_type CHECK (product_type IN ('standard', 'service', 'subscription', 'bundle'))
);

-- Indexes
CREATE INDEX idx_products_uuid ON public.products(product_uuid);
CREATE INDEX idx_products_company_id ON public.products(company_id);
CREATE INDEX idx_products_name ON public.products(product_name);
CREATE INDEX idx_products_code ON public.products(product_code);
CREATE INDEX idx_products_sku ON public.products(sku);
CREATE INDEX idx_products_company_active ON public.products(company_id, is_active);
CREATE INDEX idx_products_category ON public.products(product_category_uuid);

-- Comments
COMMENT ON TABLE public.products IS 'Product catalog';
COMMENT ON COLUMN public.products.specifications IS 'Product technical specifications and features';
COMMENT ON COLUMN public.products.custom_fields IS 'Custom field values for dynamic fields';
