-- Table: public.price_books
DROP TABLE IF EXISTS public.price_books CASCADE;

CREATE TABLE public.price_books
(
    price_book_id SERIAL PRIMARY KEY,
    price_book_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    price_book_name VARCHAR(100) NOT NULL,
    price_book_code VARCHAR(50),
    description TEXT,
    is_default BOOLEAN DEFAULT false,
    currency_code VARCHAR(3) DEFAULT 'USD',
    valid_from DATE,
    valid_to DATE,
    is_active BOOLEAN DEFAULT true,
    company_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    CONSTRAINT fk_price_books_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT uk_price_books_company_name UNIQUE (company_id, price_book_name)
);

CREATE INDEX idx_price_books_uuid ON public.price_books(price_book_uuid);
CREATE INDEX idx_price_books_company_id ON public.price_books(company_id);
CREATE INDEX idx_price_books_company_active ON public.price_books(company_id, is_active);
