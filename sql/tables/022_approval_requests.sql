-- Table: public.approval_requests
-- Individual approval request instances

DROP TABLE IF EXISTS public.approval_requests CASCADE;

CREATE TABLE public.approval_requests
(
    approval_request_id SERIAL PRIMARY KEY,
    approval_request_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Process Association
    approval_process_uuid UUID NOT NULL,

    -- Record Information
    module_name VARCHAR(100) NOT NULL,
    record_uuid UUID NOT NULL,
    record_name VARCHAR(255),

    -- Request Details
    submitted_by UUID NOT NULL,
    submitted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    submission_comments TEXT,

    -- Current Status
    current_step INTEGER DEFAULT 1,
    overall_status VARCHAR(50) DEFAULT 'pending',

    -- Approval Chain
    approval_chain JSONB DEFAULT '[]'::jsonb,

    -- Timeline
    completed_at TIMESTAMP WITH TIME ZONE,
    duration_hours INTEGER,

    -- Context Data
    context_data JSONB DEFAULT '{}'::jsonb,

    -- Recall
    is_recalled BOOLEAN DEFAULT false,
    recalled_at TIMESTAMP WITH TIME ZONE,
    recalled_by UUID,
    recall_reason TEXT,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_approval_req_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_approval_req_process FOREIGN KEY (approval_process_uuid)
        REFERENCES public.approval_processes(approval_process_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_approval_req_submitted_by FOREIGN KEY (submitted_by)
        REFERENCES public.users(user_uuid) ON DELETE RESTRICT,
    CONSTRAINT chk_approval_req_status CHECK (overall_status IN ('pending', 'approved', 'rejected', 'recalled', 'cancelled'))
);

-- Indexes
CREATE INDEX idx_approval_req_uuid ON public.approval_requests(approval_request_uuid);
CREATE INDEX idx_approval_req_company_id ON public.approval_requests(company_id);
CREATE INDEX idx_approval_req_process ON public.approval_requests(approval_process_uuid);
CREATE INDEX idx_approval_req_record ON public.approval_requests(record_uuid);
CREATE INDEX idx_approval_req_submitted_by ON public.approval_requests(submitted_by);
CREATE INDEX idx_approval_req_status ON public.approval_requests(overall_status);
CREATE INDEX idx_approval_req_created ON public.approval_requests(created_at DESC);

-- Comments
COMMENT ON TABLE public.approval_requests IS 'Individual approval request instances';
COMMENT ON COLUMN public.approval_requests.approval_chain IS 'Complete approval chain with all steps and responses';
