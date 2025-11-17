-- Table: public.timezones
-- Standard timezone reference data

DROP TABLE IF EXISTS public.timezones CASCADE;

CREATE TABLE public.timezones
(
    timezone_id SERIAL PRIMARY KEY,
    timezone_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Timezone Information
    timezone_name VARCHAR(100) NOT NULL UNIQUE,
    timezone_abbr VARCHAR(10),
    timezone_offset VARCHAR(10) NOT NULL,

    -- UTC Offset (in minutes)
    utc_offset_minutes INTEGER NOT NULL,

    -- DST
    supports_dst BOOLEAN DEFAULT false,
    dst_offset_minutes INTEGER,

    -- Geographic
    country_code VARCHAR(2),
    region VARCHAR(100),

    -- Display
    display_name VARCHAR(255),

    -- Sort Order
    sort_order INTEGER DEFAULT 0,

    -- Status
    is_active BOOLEAN DEFAULT true,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT fk_timezones_country FOREIGN KEY (country_code)
        REFERENCES public.countries(country_code) ON DELETE SET NULL
);

-- Indexes
CREATE INDEX idx_timezones_uuid ON public.timezones(timezone_uuid);
CREATE INDEX idx_timezones_name ON public.timezones(timezone_name);
CREATE INDEX idx_timezones_country ON public.timezones(country_code);
CREATE INDEX idx_timezones_active ON public.timezones(is_active);

-- Comments
COMMENT ON TABLE public.timezones IS 'Standard timezone reference data (IANA timezone database)';
COMMENT ON COLUMN public.timezones.timezone_name IS 'IANA timezone name (e.g., America/New_York)';
COMMENT ON COLUMN public.timezones.utc_offset_minutes IS 'Offset from UTC in minutes';
