-- Table: public.approval_processes
-- Approval process definitions

DROP TABLE IF EXISTS public.approval_processes CASCADE;

CREATE TABLE public.approval_processes
(
    approval_process_id SERIAL PRIMARY KEY,
    approval_process_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Process Information
    process_name VARCHAR(100) NOT NULL,
    process_code VARCHAR(50),
    description TEXT,

    -- Module Association
    module_name VARCHAR(100) NOT NULL,

    -- Entry Criteria
    entry_criteria JSONB DEFAULT '{}'::jsonb,

    -- Approval Steps Configuration
    approval_steps JSONB DEFAULT '[]'::jsonb,

    -- Settings
    allow_recall BOOLEAN DEFAULT true,
    require_comments BOOLEAN DEFAULT false,
    send_notifications BOOLEAN DEFAULT true,

    -- Rejection Behavior
    rejection_behavior VARCHAR(50) DEFAULT 'final_rejection',
    final_approval_actions JSONB DEFAULT '[]'::jsonb,
    final_rejection_actions JSONB DEFAULT '[]'::jsonb,

    -- Sort Order
    execution_order INTEGER DEFAULT 0,

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
    CONSTRAINT fk_approval_process_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT uk_approval_process_company_name UNIQUE (company_id, process_name),
    CONSTRAINT chk_approval_rejection CHECK (rejection_behavior IN ('final_rejection', 'previous_approver', 'submitter'))
);

-- Indexes
CREATE INDEX idx_approval_process_uuid ON public.approval_processes(approval_process_uuid);
CREATE INDEX idx_approval_process_company_id ON public.approval_processes(company_id);
CREATE INDEX idx_approval_process_module ON public.approval_processes(module_name);
CREATE INDEX idx_approval_process_company_active ON public.approval_processes(company_id, is_active);

-- Comments
COMMENT ON TABLE public.approval_processes IS 'Multi-step approval process definitions';
COMMENT ON COLUMN public.approval_processes.entry_criteria IS 'Conditions for record to enter approval process';
COMMENT ON COLUMN public.approval_processes.approval_steps IS 'Ordered array of approval steps with approvers and conditions';
