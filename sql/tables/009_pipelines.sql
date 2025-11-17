-- Table: public.pipelines
-- Sales pipelines configuration

DROP TABLE IF EXISTS public.pipelines CASCADE;

CREATE TABLE public.pipelines
(
    pipeline_id SERIAL PRIMARY KEY,
    pipeline_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Pipeline Information
    pipeline_name VARCHAR(100) NOT NULL,
    pipeline_code VARCHAR(50),
    description TEXT,

    -- Configuration
    is_default BOOLEAN DEFAULT false,
    pipeline_type VARCHAR(50) DEFAULT 'sales',

    -- Settings (JSONB for config data)
    settings JSONB DEFAULT '{}'::jsonb,

    -- Sort Order
    sort_order INTEGER DEFAULT 0,

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
    CONSTRAINT fk_pipelines_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT uk_pipelines_company_name UNIQUE (company_id, pipeline_name),
    CONSTRAINT chk_pipelines_type CHECK (pipeline_type IN ('sales', 'service', 'custom'))
);

CREATE INDEX idx_pipelines_uuid ON public.pipelines(pipeline_uuid);
CREATE INDEX idx_pipelines_company_id ON public.pipelines(company_id);
CREATE INDEX idx_pipelines_company_active ON public.pipelines(company_id, is_active);

COMMENT ON TABLE public.pipelines IS 'Sales pipeline configurations';
COMMENT ON COLUMN public.pipelines.settings IS 'Pipeline settings (automation rules, notifications, etc.) - JSONB';
