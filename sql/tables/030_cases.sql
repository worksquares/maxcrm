-- Table: public.cases
-- Customer support cases/tickets

DROP TABLE IF EXISTS public.cases CASCADE;

CREATE TABLE public.cases
(
    case_id SERIAL PRIMARY KEY,
    case_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Case Information
    case_number VARCHAR(50),
    subject VARCHAR(255) NOT NULL,
    description TEXT,

    -- Associations
    account_uuid UUID,
    contact_uuid UUID,

    -- Case Classification
    case_type_uuid UUID,
    case_priority_uuid UUID,
    case_status_uuid UUID,
    case_origin_uuid UUID,

    -- Assignment
    owner_uuid UUID,
    assigned_to_uuid UUID,
    team_uuid UUID,

    -- Timeline
    opened_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    first_response_at TIMESTAMP WITH TIME ZONE,
    resolved_at TIMESTAMP WITH TIME ZONE,
    closed_at TIMESTAMP WITH TIME ZONE,

    -- SLA Tracking
    sla_due_date TIMESTAMP WITH TIME ZONE,
    is_sla_violated BOOLEAN DEFAULT false,
    response_time_minutes INTEGER,
    resolution_time_minutes INTEGER,

    -- Resolution
    resolution TEXT,
    resolution_type VARCHAR(50),

    -- Escalation
    is_escalated BOOLEAN DEFAULT false,
    escalated_at TIMESTAMP WITH TIME ZONE,
    escalated_to_uuid UUID,

    -- Custom Fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    tags JSONB DEFAULT '[]'::jsonb,

    -- Status
    is_active BOOLEAN DEFAULT true,
    is_closed BOOLEAN DEFAULT false,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_cases_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_cases_account FOREIGN KEY (account_uuid)
        REFERENCES public.accounts(account_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_cases_contact FOREIGN KEY (contact_uuid)
        REFERENCES public.contacts(contact_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_cases_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_cases_assigned_to FOREIGN KEY (assigned_to_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT uk_cases_company_number UNIQUE (company_id, case_number)
);

-- Indexes
CREATE INDEX idx_cases_uuid ON public.cases(case_uuid);
CREATE INDEX idx_cases_company_id ON public.cases(company_id);
CREATE INDEX idx_cases_number ON public.cases(case_number);
CREATE INDEX idx_cases_account ON public.cases(account_uuid);
CREATE INDEX idx_cases_contact ON public.cases(contact_uuid);
CREATE INDEX idx_cases_owner ON public.cases(owner_uuid);
CREATE INDEX idx_cases_assigned ON public.cases(assigned_to_uuid);
CREATE INDEX idx_cases_status ON public.cases(case_status_uuid);
CREATE INDEX idx_cases_priority ON public.cases(case_priority_uuid);
CREATE INDEX idx_cases_company_active ON public.cases(company_id, is_active);
CREATE INDEX idx_cases_sla ON public.cases(sla_due_date) WHERE is_closed = false;

-- Comments
COMMENT ON TABLE public.cases IS 'Customer support cases and tickets';
COMMENT ON COLUMN public.cases.custom_fields IS 'Custom field values for dynamic fields';
