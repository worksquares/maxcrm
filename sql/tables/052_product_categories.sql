-- Table: public.product_categories
-- Description: Hierarchical product categorization taxonomy
-- Supports unlimited levels of nesting for product organization

CREATE TABLE public.product_categories
(
    product_category_id SERIAL PRIMARY KEY,
    product_category_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Category details
    category_name VARCHAR(255) NOT NULL,
    category_code VARCHAR(100),
    description TEXT,

    -- Hierarchy
    parent_category_uuid UUID,
    category_level INTEGER DEFAULT 1,
    category_path VARCHAR(1000),
    full_path_names VARCHAR(1000),

    -- Display
    display_order INTEGER DEFAULT 0,
    icon_url VARCHAR(500),
    image_url VARCHAR(500),

    -- Status
    is_active BOOLEAN DEFAULT TRUE,

    -- SEO & metadata
    meta_title VARCHAR(255),
    meta_description TEXT,
    meta_keywords TEXT,

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
    CONSTRAINT fk_product_categories_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_product_categories_parent FOREIGN KEY (parent_category_uuid)
        REFERENCES public.product_categories(product_category_uuid) ON DELETE SET NULL,
    CONSTRAINT uq_product_categories_name UNIQUE (company_id, category_name, parent_category_uuid)
);

-- Indexes
CREATE INDEX idx_product_categories_company ON public.product_categories(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_product_categories_parent ON public.product_categories(parent_category_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_product_categories_active ON public.product_categories(is_active) WHERE is_deleted = FALSE;
CREATE INDEX idx_product_categories_path ON public.product_categories(category_path) WHERE is_deleted = FALSE;
CREATE INDEX idx_product_categories_level ON public.product_categories(category_level) WHERE is_deleted = FALSE;

-- Comments
COMMENT ON TABLE public.product_categories IS 'Hierarchical product categorization with unlimited nesting levels';
COMMENT ON COLUMN public.product_categories.category_path IS 'Full UUID path from root: /uuid1/uuid2/uuid3';
COMMENT ON COLUMN public.product_categories.full_path_names IS 'Human-readable path: Electronics > Computers > Laptops';
COMMENT ON COLUMN public.product_categories.category_level IS '1 = root, 2 = child of root, etc.';
