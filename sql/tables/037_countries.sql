-- Table: public.countries
-- Standard country reference data

DROP TABLE IF EXISTS public.countries CASCADE;

CREATE TABLE public.countries
(
    country_id SERIAL PRIMARY KEY,
    country_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Country Information
    country_code VARCHAR(2) NOT NULL UNIQUE,
    country_code_3 VARCHAR(3) UNIQUE,
    country_name VARCHAR(100) NOT NULL,
    country_name_official VARCHAR(255),

    -- ISO Codes
    iso_numeric VARCHAR(3),

    -- Phone
    phone_code VARCHAR(10),

    -- Geographic
    continent VARCHAR(50),
    region VARCHAR(100),
    subregion VARCHAR(100),

    -- Currency
    default_currency_code VARCHAR(3),

    -- Additional Data
    capital VARCHAR(100),
    languages JSONB DEFAULT '[]'::jsonb,
    timezones JSONB DEFAULT '[]'::jsonb,

    -- Sort Order
    sort_order INTEGER DEFAULT 0,

    -- Status
    is_active BOOLEAN DEFAULT true,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_countries_uuid ON public.countries(country_uuid);
CREATE INDEX idx_countries_code ON public.countries(country_code);
CREATE INDEX idx_countries_name ON public.countries(country_name);
CREATE INDEX idx_countries_active ON public.countries(is_active);

-- Comments
COMMENT ON TABLE public.countries IS 'Standard country reference data (ISO 3166)';
COMMENT ON COLUMN public.countries.country_code IS 'ISO 3166-1 alpha-2 code';
COMMENT ON COLUMN public.countries.country_code_3 IS 'ISO 3166-1 alpha-3 code';
