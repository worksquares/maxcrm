-- Table: public.workflows
DROP TABLE IF EXISTS public.workflows CASCADE;
CREATE TABLE public.workflows (
    workflow_id SERIAL PRIMARY KEY, workflow_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    workflow_name VARCHAR(100) NOT NULL, workflow_code VARCHAR(50), description TEXT,
    module_name VARCHAR(100) NOT NULL, trigger_type VARCHAR(50) NOT NULL,
    trigger_conditions JSONB DEFAULT '{}'::jsonb, execution_order INTEGER DEFAULT 0,
    execution_criteria JSONB DEFAULT '{}'::jsonb, actions JSONB DEFAULT '[]'::jsonb,
    schedule_config JSONB DEFAULT '{}'::jsonb, last_run_at TIMESTAMP WITH TIME ZONE,
    next_run_at TIMESTAMP WITH TIME ZONE, is_active BOOLEAN DEFAULT true, is_system BOOLEAN DEFAULT false,
    company_id INTEGER NOT NULL, created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), created_by UUID, updated_by UUID,
    CONSTRAINT fk_workflows_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT uk_workflows_company_name UNIQUE (company_id, workflow_name),
    CONSTRAINT chk_workflows_trigger CHECK (trigger_type IN ('on_create', 'on_update', 'on_delete', 'on_field_change', 'scheduled', 'manual', 'on_approval', 'on_stage_change'))
);
CREATE INDEX idx_workflows_uuid ON public.workflows(workflow_uuid);
CREATE INDEX idx_workflows_company_id ON public.workflows(company_id);
CREATE INDEX idx_workflows_module ON public.workflows(module_name);
CREATE INDEX idx_workflows_company_active ON public.workflows(company_id, is_active);
COMMENT ON TABLE public.workflows IS 'Workflow automation rule definitions';
COMMENT ON COLUMN public.workflows.actions IS 'Array of actions to execute - JSONB';