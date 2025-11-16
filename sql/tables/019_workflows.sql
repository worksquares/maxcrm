-- Table: public.workflows
-- Workflow automation definitions

DROP TABLE IF EXISTS public.workflows CASCADE;

CREATE TABLE public.workflows
(
    workflow_id SERIAL PRIMARY KEY,
    workflow_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Workflow Information
    workflow_name VARCHAR(100) NOT NULL,
    workflow_code VARCHAR(50),
    description TEXT,

    -- Module Association
    module_name VARCHAR(100) NOT NULL,

    -- Trigger Configuration
    trigger_type VARCHAR(50) NOT NULL,
    trigger_conditions JSONB DEFAULT '{}'::jsonb,

    -- Execution Configuration
    execution_order INTEGER DEFAULT 0,
    execution_criteria JSONB DEFAULT '{}'::jsonb,

    -- Actions
    actions JSONB DEFAULT '[]'::jsonb,

    -- Schedule (for scheduled workflows)
    schedule_config JSONB DEFAULT '{}'::jsonb,
    last_run_at TIMESTAMP WITH TIME ZONE,
    next_run_at TIMESTAMP WITH TIME ZONE,

    -- Status
    is_active BOOLEAN DEFAULT true,
    is_system BOOLEAN DEFAULT false,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_workflows_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT uk_workflows_company_name UNIQUE (company_id, workflow_name),
    CONSTRAINT chk_workflows_trigger CHECK (trigger_type IN (
        'on_create', 'on_update', 'on_delete', 'on_field_change',
        'scheduled', 'manual', 'on_approval', 'on_stage_change'
    ))
);

-- Indexes
CREATE INDEX idx_workflows_uuid ON public.workflows(workflow_uuid);
CREATE INDEX idx_workflows_company_id ON public.workflows(company_id);
CREATE INDEX idx_workflows_module ON public.workflows(module_name);
CREATE INDEX idx_workflows_company_module ON public.workflows(company_id, module_name);
CREATE INDEX idx_workflows_company_active ON public.workflows(company_id, is_active);
CREATE INDEX idx_workflows_trigger ON public.workflows(trigger_type);

-- Comments
COMMENT ON TABLE public.workflows IS 'Workflow automation rule definitions';
COMMENT ON COLUMN public.workflows.trigger_conditions IS 'Conditions that must be met to trigger workflow: {field_conditions, criteria_logic}';
COMMENT ON COLUMN public.workflows.actions IS 'Array of actions to execute: [{type, config, order}]';
COMMENT ON COLUMN public.workflows.schedule_config IS 'Schedule configuration for scheduled workflows';
