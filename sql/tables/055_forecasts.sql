-- Table: public.forecasts
-- Description: Sales forecasts with quotas and actual performance tracking
-- Supports hierarchical rollup forecasting

CREATE TABLE public.forecasts
(
    forecast_id SERIAL PRIMARY KEY,
    forecast_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Forecast period
    forecast_name VARCHAR(255) NOT NULL,
    forecast_period VARCHAR(50) NOT NULL,
    period_year INTEGER NOT NULL,
    period_quarter INTEGER,
    period_month INTEGER,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,

    -- Owner
    user_uuid UUID NOT NULL,
    team_uuid UUID,
    territory_uuid UUID,

    -- Forecast categories
    pipeline_amount NUMERIC(15,2) DEFAULT 0,
    best_case_amount NUMERIC(15,2) DEFAULT 0,
    commit_amount NUMERIC(15,2) DEFAULT 0,
    closed_amount NUMERIC(15,2) DEFAULT 0,

    -- Quota
    quota_amount NUMERIC(15,2) DEFAULT 0,
    currency_code VARCHAR(10) DEFAULT 'USD',

    -- Attainment
    attainment_percentage NUMERIC(5,2) DEFAULT 0,

    -- Status
    status VARCHAR(50) DEFAULT 'draft',
    submitted_at TIMESTAMPTZ,
    approved_at TIMESTAMPTZ,
    approved_by_uuid UUID,

    -- Rollup (for managers)
    is_rollup BOOLEAN DEFAULT FALSE,
    parent_forecast_uuid UUID,
    team_pipeline_amount NUMERIC(15,2) DEFAULT 0,
    team_commit_amount NUMERIC(15,2) DEFAULT 0,
    team_closed_amount NUMERIC(15,2) DEFAULT 0,

    -- Notes
    forecast_notes TEXT,
    manager_notes TEXT,

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
    CONSTRAINT fk_forecasts_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_forecasts_user FOREIGN KEY (user_uuid)
        REFERENCES public.users(user_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_forecasts_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_forecasts_territory FOREIGN KEY (territory_uuid)
        REFERENCES public.territories(territory_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_forecasts_approved_by FOREIGN KEY (approved_by_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_forecasts_parent FOREIGN KEY (parent_forecast_uuid)
        REFERENCES public.forecasts(forecast_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_forecasts_period CHECK (forecast_period IN ('monthly', 'quarterly', 'annual', 'custom')),
    CONSTRAINT chk_forecasts_status CHECK (status IN ('draft', 'submitted', 'approved', 'rejected', 'closed')),
    CONSTRAINT chk_forecasts_quarter CHECK (period_quarter IS NULL OR (period_quarter >= 1 AND period_quarter <= 4)),
    CONSTRAINT chk_forecasts_month CHECK (period_month IS NULL OR (period_month >= 1 AND period_month <= 12)),
    CONSTRAINT chk_forecasts_dates CHECK (end_date >= start_date),
    CONSTRAINT uq_forecasts_period UNIQUE (company_id, user_uuid, forecast_period, period_year, period_quarter, period_month)
);

-- Indexes
CREATE INDEX idx_forecasts_company ON public.forecasts(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_forecasts_user ON public.forecasts(user_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_forecasts_team ON public.forecasts(team_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_forecasts_territory ON public.forecasts(territory_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_forecasts_period ON public.forecasts(period_year, period_quarter, period_month) WHERE is_deleted = FALSE;
CREATE INDEX idx_forecasts_status ON public.forecasts(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_forecasts_dates ON public.forecasts(start_date, end_date) WHERE is_deleted = FALSE;

-- Comments
COMMENT ON TABLE public.forecasts IS 'Sales forecasts with quota tracking and hierarchical rollup';
COMMENT ON COLUMN public.forecasts.commit_amount IS 'Amount the sales rep commits to closing this period';
COMMENT ON COLUMN public.forecasts.best_case_amount IS 'Best case scenario if all deals close';
COMMENT ON COLUMN public.forecasts.is_rollup IS 'Whether this forecast aggregates team forecasts';
