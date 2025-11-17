-- Table: public.cases
DROP TABLE IF EXISTS public.cases CASCADE;
CREATE TABLE public.cases (
    case_id SERIAL PRIMARY KEY, case_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    case_number VARCHAR(50), subject VARCHAR(255) NOT NULL, description TEXT,
    account_uuid UUID, contact_uuid UUID, case_type_uuid UUID,
    case_priority_uuid UUID, case_status_uuid UUID, case_origin_uuid UUID,
    owner_uuid UUID, assigned_to_uuid UUID, team_uuid UUID,
    opened_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), first_response_at TIMESTAMP WITH TIME ZONE,
    resolved_at TIMESTAMP WITH TIME ZONE, closed_at TIMESTAMP WITH TIME ZONE,
    sla_due_date TIMESTAMP WITH TIME ZONE, is_sla_violated BOOLEAN DEFAULT false,
    response_time_minutes INTEGER, resolution_time_minutes INTEGER,
    resolution TEXT, resolution_type VARCHAR(50), is_escalated BOOLEAN DEFAULT false,
    escalated_at TIMESTAMP WITH TIME ZONE, escalated_to_uuid UUID,
    custom_fields JSONB DEFAULT '{}'::jsonb, metadata JSONB DEFAULT '{}'::jsonb,
    tags JSONB DEFAULT '[]'::jsonb, is_active BOOLEAN DEFAULT true, is_closed BOOLEAN DEFAULT false,
    company_id INTEGER NOT NULL, created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), created_by UUID, updated_by UUID,
    CONSTRAINT fk_cases_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_cases_account FOREIGN KEY (account_uuid) REFERENCES public.accounts(account_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_cases_contact FOREIGN KEY (contact_uuid) REFERENCES public.contacts(contact_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_cases_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT uk_cases_company_number UNIQUE (company_id, case_number)
);
CREATE INDEX idx_cases_uuid ON public.cases(case_uuid);
CREATE INDEX idx_cases_account ON public.cases(account_uuid);
CREATE INDEX idx_cases_status ON public.cases(case_status_uuid);