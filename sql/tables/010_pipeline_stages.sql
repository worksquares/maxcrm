-- Table: public.pipeline_stages
-- Stages within sales pipelines

DROP TABLE IF EXISTS public.pipeline_stages CASCADE;

CREATE TABLE public.pipeline_stages
(
    stage_id SERIAL PRIMARY KEY,
    stage_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Stage Information
    stage_name VARCHAR(100) NOT NULL,
    stage_code VARCHAR(50),
    description TEXT,

    -- Pipeline Association
    pipeline_uuid UUID NOT NULL,

    -- Stage Configuration
    probability INTEGER DEFAULT 0,
    is_closed_won BOOLEAN DEFAULT false,
    is_closed_lost BOOLEAN DEFAULT false,
    is_final BOOLEAN DEFAULT false,

    -- Stage Behavior (JSONB for config)
    required_fields JSONB DEFAULT '[]'::jsonb,
    automation_rules JSONB DEFAULT '{}'::jsonb,

    -- Sort Order
    sort_order INTEGER DEFAULT 0,

    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,

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
    CONSTRAINT fk_stages_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_stages_pipeline FOREIGN KEY (pipeline_uuid)
        REFERENCES public.pipelines(pipeline_uuid) ON DELETE CASCADE,
    CONSTRAINT uk_stages_pipeline_name UNIQUE (pipeline_uuid, stage_name),
    CONSTRAINT chk_stages_probability CHECK (probability >= 0 AND probability <= 100)
);

CREATE INDEX idx_stages_uuid ON public.pipeline_stages(stage_uuid);
CREATE INDEX idx_stages_company_id ON public.pipeline_stages(company_id);
CREATE INDEX idx_stages_pipeline ON public.pipeline_stages(pipeline_uuid);
CREATE INDEX idx_stages_pipeline_order ON public.pipeline_stages(pipeline_uuid, sort_order);

COMMENT ON TABLE public.pipeline_stages IS 'Stages within sales pipelines';
COMMENT ON COLUMN public.pipeline_stages.required_fields IS 'Fields required before moving to this stage - JSONB';
COMMENT ON COLUMN public.pipeline_stages.automation_rules IS 'Automation triggers for this stage - JSONB';
