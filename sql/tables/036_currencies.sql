-- Table: public.currencies
-- Currency definitions with exchange rates

DROP TABLE IF EXISTS public.currencies CASCADE;

CREATE TABLE public.currencies
(
    currency_id SERIAL PRIMARY KEY,
    currency_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Currency Information
    currency_code VARCHAR(3) NOT NULL UNIQUE,
    currency_name VARCHAR(100) NOT NULL,
    currency_symbol VARCHAR(10),

    -- Format
    decimal_places INTEGER DEFAULT 2,
    decimal_separator VARCHAR(5) DEFAULT '.',
    thousands_separator VARCHAR(5) DEFAULT ',',
    symbol_position VARCHAR(10) DEFAULT 'before',

    -- Exchange Rate (relative to base currency)
    exchange_rate NUMERIC(15,6) DEFAULT 1.000000,
    is_base_currency BOOLEAN DEFAULT false,

    -- Status
    is_active BOOLEAN DEFAULT true,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID
);

-- Indexes
CREATE INDEX idx_currencies_uuid ON public.currencies(currency_uuid);
CREATE INDEX idx_currencies_code ON public.currencies(currency_code);
CREATE INDEX idx_currencies_active ON public.currencies(is_active);

-- Comments
COMMENT ON TABLE public.currencies IS 'Currency definitions with formatting and exchange rates';
COMMENT ON COLUMN public.currencies.exchange_rate IS 'Exchange rate relative to base currency';
COMMENT ON COLUMN public.currencies.is_base_currency IS 'Designates the base currency (usually one per system)';
