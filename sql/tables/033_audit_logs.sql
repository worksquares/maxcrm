-- Table: public.audit_logs
-- Comprehensive audit trail for all changes

DROP TABLE IF EXISTS public.audit_logs CASCADE;

CREATE TABLE public.audit_logs
(
    audit_log_id SERIAL PRIMARY KEY,
    audit_log_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Record Information
    module_name VARCHAR(100) NOT NULL,
    record_uuid UUID NOT NULL,
    record_name VARCHAR(255),

    -- Action Details
    action_type VARCHAR(50) NOT NULL,
    action_description TEXT,

    -- Changes
    old_values JSONB DEFAULT '{}'::jsonb,
    new_values JSONB DEFAULT '{}'::jsonb,
    changed_fields JSONB DEFAULT '[]'::jsonb,

    -- User & Session
    user_uuid UUID,
    user_name VARCHAR(255),
    ip_address VARCHAR(50),
    user_agent TEXT,

    -- Context
    context_data JSONB DEFAULT '{}'::jsonb,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Timestamp
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT fk_audit_logs_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_audit_logs_user FOREIGN KEY (user_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_audit_action_type CHECK (action_type IN ('create', 'update', 'delete', 'view', 'export', 'import', 'share', 'unshare'))
);

-- Indexes
CREATE INDEX idx_audit_logs_uuid ON public.audit_logs(audit_log_uuid);
CREATE INDEX idx_audit_logs_company_id ON public.audit_logs(company_id);
CREATE INDEX idx_audit_logs_module ON public.audit_logs(module_name);
CREATE INDEX idx_audit_logs_record ON public.audit_logs(record_uuid);
CREATE INDEX idx_audit_logs_user ON public.audit_logs(user_uuid);
CREATE INDEX idx_audit_logs_action ON public.audit_logs(action_type);
CREATE INDEX idx_audit_logs_created ON public.audit_logs(created_at DESC);
CREATE INDEX idx_audit_logs_company_module ON public.audit_logs(company_id, module_name);

-- Comments
COMMENT ON TABLE public.audit_logs IS 'Comprehensive audit trail for all record changes';
COMMENT ON COLUMN public.audit_logs.changed_fields IS 'Array of field names that were changed';
