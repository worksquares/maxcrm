-- Table: public.field_history
-- Description: Field-level audit trail for tracking changes to specific fields
-- More granular than audit_logs which tracks full record changes

CREATE TABLE public.field_history
(
    field_history_id SERIAL PRIMARY KEY,
    field_history_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Record identification
    module_name VARCHAR(100) NOT NULL,
    record_uuid UUID NOT NULL,
    record_id INTEGER,

    -- Field change
    field_name VARCHAR(100) NOT NULL,
    field_label VARCHAR(255),

    -- Values
    old_value TEXT,
    new_value TEXT,
    old_value_display TEXT,
    new_value_display TEXT,

    -- Data type info
    field_data_type VARCHAR(50),

    -- Change tracking
    change_type VARCHAR(50) DEFAULT 'update',
    changed_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    changed_by_uuid UUID,

    -- Context
    changed_via VARCHAR(50),
    ip_address INET,
    user_agent TEXT,

    -- Standard fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    -- Constraints
    CONSTRAINT fk_field_history_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_field_history_changed_by FOREIGN KEY (changed_by_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_field_history_change_type CHECK (change_type IN ('create', 'update', 'delete')),
    CONSTRAINT chk_field_history_changed_via CHECK (changed_via IN ('web', 'mobile', 'api', 'import', 'workflow', 'integration', 'system'))
);

-- Indexes
CREATE INDEX idx_field_history_company ON public.field_history(company_id);
CREATE INDEX idx_field_history_record ON public.field_history(module_name, record_uuid);
CREATE INDEX idx_field_history_field ON public.field_history(field_name);
CREATE INDEX idx_field_history_changed_at ON public.field_history(changed_at DESC);
CREATE INDEX idx_field_history_changed_by ON public.field_history(changed_by_uuid);

-- Partitioning comment
COMMENT ON TABLE public.field_history IS 'Field-level audit trail - consider partitioning by changed_at for large datasets';
COMMENT ON COLUMN public.field_history.old_value_display IS 'Human-readable old value (e.g., user name instead of UUID)';
COMMENT ON COLUMN public.field_history.new_value_display IS 'Human-readable new value (e.g., user name instead of UUID)';
