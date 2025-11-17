-- Table: public.audit_logs
DROP TABLE IF EXISTS public.audit_logs CASCADE;
CREATE TABLE public.audit_logs (
    audit_log_id SERIAL PRIMARY KEY, audit_log_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    module_name VARCHAR(100) NOT NULL, record_uuid UUID NOT NULL, record_name VARCHAR(255),
    action_type VARCHAR(50) NOT NULL, action_description TEXT,
    old_values JSONB DEFAULT '{}'::jsonb, new_values JSONB DEFAULT '{}'::jsonb,
    changed_fields JSONB DEFAULT '[]'::jsonb, user_uuid UUID, user_name VARCHAR(255),
    ip_address VARCHAR(50), user_agent TEXT, context_data JSONB DEFAULT '{}'::jsonb,
    company_id INTEGER NOT NULL, created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT fk_audit_logs_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT chk_audit_action_type CHECK (action_type IN ('create', 'update', 'delete', 'view', 'export', 'import', 'share', 'unshare'))
);
CREATE INDEX idx_audit_logs_module ON public.audit_logs(module_name);
CREATE INDEX idx_audit_logs_record ON public.audit_logs(record_uuid);
CREATE INDEX idx_audit_logs_user ON public.audit_logs(user_uuid);
CREATE INDEX idx_audit_logs_created ON public.audit_logs(created_at DESC);