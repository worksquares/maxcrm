-- Table: public.price_book_entries
-- Product prices within price books

DROP TABLE IF EXISTS public.price_book_entries CASCADE;

CREATE TABLE public.price_book_entries
(
    price_book_entry_id SERIAL PRIMARY KEY,
    price_book_entry_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Associations
    price_book_uuid UUID NOT NULL,
    product_uuid UUID NOT NULL,

    -- Pricing
    unit_price NUMERIC(15,2) NOT NULL,
    list_price NUMERIC(15,2),
    discount_percentage NUMERIC(5,2) DEFAULT 0,

    -- Validity
    valid_from DATE,
    valid_to DATE,

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
    CONSTRAINT fk_price_entries_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_price_entries_price_book FOREIGN KEY (price_book_uuid)
        REFERENCES public.price_books(price_book_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_price_entries_product FOREIGN KEY (product_uuid)
        REFERENCES public.products(product_uuid) ON DELETE CASCADE,
    CONSTRAINT uk_price_entries_book_product UNIQUE (price_book_uuid, product_uuid)
);

-- Indexes
CREATE INDEX idx_price_entries_uuid ON public.price_book_entries(price_book_entry_uuid);
CREATE INDEX idx_price_entries_company_id ON public.price_book_entries(company_id);
CREATE INDEX idx_price_entries_price_book ON public.price_book_entries(price_book_uuid);
CREATE INDEX idx_price_entries_product ON public.price_book_entries(product_uuid);

-- Comments
COMMENT ON TABLE public.price_book_entries IS 'Product prices within specific price books';
