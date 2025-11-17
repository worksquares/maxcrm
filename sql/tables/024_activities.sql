-- Table: public.activities
DROP TABLE IF EXISTS public.activities CASCADE;
CREATE TABLE public.activities (
    activity_id SERIAL PRIMARY KEY, activity_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    activity_type VARCHAR(50) NOT NULL, subject VARCHAR(255) NOT NULL, description TEXT,
    related_to_module VARCHAR(100), related_to_uuid UUID, related_to_name VARCHAR(255),
    contact_uuid UUID, account_uuid UUID, activity_date DATE,
    start_datetime TIMESTAMP WITH TIME ZONE, end_datetime TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER, status VARCHAR(50) DEFAULT 'not_started', priority VARCHAR(50) DEFAULT 'medium',
    owner_uuid UUID, assigned_to_uuid UUID, due_date DATE, completion_percentage INTEGER DEFAULT 0,
    location VARCHAR(255), is_all_day BOOLEAN DEFAULT false, attendees JSONB DEFAULT '[]'::jsonb,
    call_type VARCHAR(50), call_outcome VARCHAR(50), call_duration_seconds INTEGER,
    email_from VARCHAR(255), email_to JSONB DEFAULT '[]'::jsonb,
    email_cc JSONB DEFAULT '[]'::jsonb, email_bcc JSONB DEFAULT '[]'::jsonb,
    is_email_sent BOOLEAN DEFAULT false, sent_at TIMESTAMP WITH TIME ZONE,
    reminder_datetime TIMESTAMP WITH TIME ZONE, reminder_sent BOOLEAN DEFAULT false,
    is_recurring BOOLEAN DEFAULT false, recurrence_config JSONB DEFAULT '{}'::jsonb,
    parent_activity_uuid UUID, custom_fields JSONB DEFAULT '{}'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb, tags JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT true, is_completed BOOLEAN DEFAULT false, company_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, updated_by UUID,
    CONSTRAINT fk_activities_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_activities_contact FOREIGN KEY (contact_uuid) REFERENCES public.contacts(contact_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_activities_account FOREIGN KEY (account_uuid) REFERENCES public.accounts(account_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_activities_owner FOREIGN KEY (owner_uuid) REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_activities_type CHECK (activity_type IN ('task', 'event', 'call', 'email', 'meeting', 'note')),
    CONSTRAINT chk_activities_status CHECK (status IN ('not_started', 'in_progress', 'completed', 'waiting', 'deferred', 'cancelled'))
);
CREATE INDEX idx_activities_uuid ON public.activities(activity_uuid);
CREATE INDEX idx_activities_type ON public.activities(activity_type);
CREATE INDEX idx_activities_related ON public.activities(related_to_module, related_to_uuid);
CREATE INDEX idx_activities_owner ON public.activities(owner_uuid);
CREATE INDEX idx_activities_due_date ON public.activities(due_date);