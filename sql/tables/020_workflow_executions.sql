-- Table: public.workflow_executions
DROP TABLE IF EXISTS public.workflow_executions CASCADE;
CREATE TABLE public.workflow_executions (
    workflow_execution_id SERIAL PRIMARY KEY, workflow_execution_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    workflow_uuid UUID NOT NULL, module_name VARCHAR(100) NOT NULL, record_uuid UUID NOT NULL,
    triggered_by VARCHAR(50) NOT NULL, trigger_event VARCHAR(50), status VARCHAR(50) DEFAULT 'pending',
    started_at TIMESTAMP WITH TIME ZONE, completed_at TIMESTAMP WITH TIME ZONE, duration_ms INTEGER,
    input_data JSONB DEFAULT '{}'::jsonb, output_data JSONB DEFAULT '{}'::jsonb,
    context_data JSONB DEFAULT '{}'::jsonb, actions_executed JSONB DEFAULT '[]'::jsonb,
    error_message TEXT, error_details JSONB DEFAULT '{}'::jsonb, retry_count INTEGER DEFAULT 0,
    company_id INTEGER NOT NULL, created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), created_by UUID, updated_by UUID,
    CONSTRAINT fk_workflow_exec_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_workflow_exec_workflow FOREIGN KEY (workflow_uuid) REFERENCES public.workflows(workflow_uuid) ON DELETE CASCADE,
    CONSTRAINT chk_workflow_exec_status CHECK (status IN ('pending', 'running', 'completed', 'failed', 'skipped'))
);
CREATE INDEX idx_workflow_exec_uuid ON public.workflow_executions(workflow_execution_uuid);
CREATE INDEX idx_workflow_exec_workflow ON public.workflow_executions(workflow_uuid);
CREATE INDEX idx_workflow_exec_record ON public.workflow_executions(record_uuid);
CREATE INDEX idx_workflow_exec_status ON public.workflow_executions(status);