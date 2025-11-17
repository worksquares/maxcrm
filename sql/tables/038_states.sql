-- Table: public.states
-- States/provinces/regions within countries

DROP TABLE IF EXISTS public.states CASCADE;

CREATE TABLE public.states
(
    state_id SERIAL PRIMARY KEY,
    state_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- State Information
    state_code VARCHAR(10) NOT NULL,
    state_name VARCHAR(100) NOT NULL,
    state_name_local VARCHAR(100),

    -- Country Association
    country_code VARCHAR(2) NOT NULL,

    -- Type (state, province, region, etc.)
    division_type VARCHAR(50) DEFAULT 'state',

    -- Sort Order
    sort_order INTEGER DEFAULT 0,

    -- Status
    is_active BOOLEAN DEFAULT true,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT fk_states_country FOREIGN KEY (country_code)
        REFERENCES public.countries(country_code) ON DELETE CASCADE,
    CONSTRAINT uk_states_country_code UNIQUE (country_code, state_code)
);

-- Indexes
CREATE INDEX idx_states_uuid ON public.states(state_uuid);
CREATE INDEX idx_states_country ON public.states(country_code);
CREATE INDEX idx_states_name ON public.states(state_name);
CREATE INDEX idx_states_active ON public.states(is_active);

-- Comments
COMMENT ON TABLE public.states IS 'States, provinces, and administrative divisions within countries';
COMMENT ON COLUMN public.states.division_type IS 'Type: state, province, region, prefecture, etc.';
