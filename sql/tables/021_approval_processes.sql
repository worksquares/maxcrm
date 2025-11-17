-- Table: public.approval_processes
DROP TABLE IF EXISTS public.approval_processes CASCADE;
CREATE TABLE public.approval_processes (
    approval_process_id SERIAL PRIMARY KEY, approval_process_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    process_name VARCHAR(100) NOT NULL, process_code VARCHAR(50), description TEXT,
    module_name VARCHAR(100) NOT NULL, entry_criteria JSONB DEFAULT '{}'::jsonb,
    approval_steps JSONB DEFAULT '[]'::jsonb, allow_recall BOOLEAN DEFAULT true,
    require_comments BOOLEAN DEFAULT false, send_notifications BOOLEAN DEFAULT true,
    rejection_behavior VARCHAR(50) DEFAULT 'final_rejection',
    final_approval_actions JSONB DEFAULT '[]'::jsonb, final_rejection_actions JSONB DEFAULT '[]'::jsonb,
    execution_order INTEGER DEFAULT 0, is_active BOOLEAN DEFAULT true, is_system BOOLEAN DEFAULT false,
    company_id INTEGER NOT NULL, created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), created_by UUID, updated_by UUID,
    CONSTRAINT fk_approval_process_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT uk_approval_process_company_name UNIQUE (company_id, process_name)
);
CREATE INDEX idx_approval_process_uuid ON public.approval_processes(approval_process_uuid);
CREATE INDEX idx_approval_process_company_id ON public.approval_processes(company_id);
COMMENT ON COLUMN public.approval_processes.approval_steps IS 'Ordered array of approval steps - JSONB';