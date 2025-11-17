-- Table: public.deal_competitors
-- Description: Junction table tracking competitors on specific deals
-- Enables competitive win/loss analysis

CREATE TABLE public.deal_competitors
(
    deal_competitor_id SERIAL PRIMARY KEY,
    deal_competitor_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Links
    deal_uuid UUID NOT NULL,
    competitor_uuid UUID NOT NULL,

    -- Competitive position
    competitive_position VARCHAR(50),

    -- Strengths vs competitor
    our_strengths_vs_competitor TEXT,
    competitor_strengths TEXT,

    -- Pricing comparison
    our_quoted_amount NUMERIC(15,2),
    competitor_quoted_amount NUMERIC(15,2),
    price_difference_percent NUMERIC(5,2),

    -- Battle cards / tactics
    recommended_tactics TEXT,
    objection_handling TEXT,

    -- Outcome
    outcome VARCHAR(50),
    outcome_notes TEXT,
    won_lost_date DATE,

    -- Primary competitor flag
    is_primary_competitor BOOLEAN DEFAULT FALSE,

    -- Notes
    internal_notes TEXT,

    -- Standard fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT fk_deal_competitors_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_deal_competitors_deal FOREIGN KEY (deal_uuid)
        REFERENCES public.deals(deal_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_deal_competitors_competitor FOREIGN KEY (competitor_uuid)
        REFERENCES public.competitors(competitor_uuid) ON DELETE CASCADE,
    CONSTRAINT chk_deal_competitors_position CHECK (competitive_position IN ('ahead', 'even', 'behind', 'unknown')),
    CONSTRAINT chk_deal_competitors_outcome CHECK (outcome IN ('won', 'lost', 'no_decision', 'ongoing', 'withdrawn')),
    CONSTRAINT uq_deal_competitors UNIQUE (deal_uuid, competitor_uuid)
);

-- Indexes
CREATE INDEX idx_deal_competitors_company ON public.deal_competitors(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_deal_competitors_deal ON public.deal_competitors(deal_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_deal_competitors_competitor ON public.deal_competitors(competitor_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_deal_competitors_outcome ON public.deal_competitors(outcome) WHERE is_deleted = FALSE;
CREATE INDEX idx_deal_competitors_primary ON public.deal_competitors(is_primary_competitor) WHERE is_deleted = FALSE;

-- Comments
COMMENT ON TABLE public.deal_competitors IS 'Competitors on specific deals for win/loss analysis';
COMMENT ON COLUMN public.deal_competitors.is_primary_competitor IS 'The main competitor we are competing against on this deal';
COMMENT ON COLUMN public.deal_competitors.price_difference_percent IS 'Calculated: ((our_amount - competitor_amount) / competitor_amount) * 100';
