-- Table: public.approval_steps
DROP TABLE IF EXISTS public.approval_steps CASCADE;
CREATE TABLE public.approval_steps (
    approval_step_id SERIAL PRIMARY KEY, approval_step_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    approval_request_uuid UUID NOT NULL, step_number INTEGER NOT NULL, step_name VARCHAR(100),
    approver_uuid UUID NOT NULL, assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status VARCHAR(50) DEFAULT 'pending', responded_at TIMESTAMP WITH TIME ZONE, comments TEXT,
    is_delegated BOOLEAN DEFAULT false, delegated_to_uuid UUID,
    delegated_at TIMESTAMP WITH TIME ZONE, delegation_reason TEXT,
    is_reassigned BOOLEAN DEFAULT false, reassigned_from_uuid UUID, metadata JSONB DEFAULT '{}'::jsonb,
    company_id INTEGER NOT NULL, created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), created_by UUID, updated_by UUID,
    CONSTRAINT fk_approval_step_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_approval_step_request FOREIGN KEY (approval_request_uuid) REFERENCES public.approval_requests(approval_request_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_approval_step_approver FOREIGN KEY (approver_uuid) REFERENCES public.users(user_uuid) ON DELETE RESTRICT,
    CONSTRAINT chk_approval_step_status CHECK (status IN ('pending', 'approved', 'rejected', 'delegated', 'skipped'))
);
CREATE INDEX idx_approval_step_uuid ON public.approval_steps(approval_step_uuid);
CREATE INDEX idx_approval_step_request ON public.approval_steps(approval_request_uuid);
CREATE INDEX idx_approval_step_approver ON public.approval_steps(approver_uuid);
CREATE INDEX idx_approval_step_status ON public.approval_steps(status);