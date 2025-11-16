-- Table: public.activities
-- Unified activity table (tasks, events, calls, emails)

DROP TABLE IF EXISTS public.activities CASCADE;

CREATE TABLE public.activities
(
    activity_id SERIAL PRIMARY KEY,
    activity_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Activity Information
    activity_type VARCHAR(50) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT,

    -- Related To (polymorphic)
    related_to_module VARCHAR(100),
    related_to_uuid UUID,
    related_to_name VARCHAR(255),

    -- Contact Association
    contact_uuid UUID,
    account_uuid UUID,

    -- Activity Details
    activity_date DATE,
    start_datetime TIMESTAMP WITH TIME ZONE,
    end_datetime TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER,

    -- Status & Priority
    status VARCHAR(50) DEFAULT 'not_started',
    priority VARCHAR(50) DEFAULT 'medium',

    -- Ownership
    owner_uuid UUID,
    assigned_to_uuid UUID,

    -- Task Specific
    due_date DATE,
    completion_percentage INTEGER DEFAULT 0,

    -- Event Specific
    location VARCHAR(255),
    is_all_day BOOLEAN DEFAULT false,
    attendees JSONB DEFAULT '[]'::jsonb,

    -- Call Specific
    call_type VARCHAR(50),
    call_outcome VARCHAR(50),
    call_duration_seconds INTEGER,

    -- Email Specific
    email_from VARCHAR(255),
    email_to JSONB DEFAULT '[]'::jsonb,
    email_cc JSONB DEFAULT '[]'::jsonb,
    email_bcc JSONB DEFAULT '[]'::jsonb,
    is_email_sent BOOLEAN DEFAULT false,
    sent_at TIMESTAMP WITH TIME ZONE,

    -- Reminders
    reminder_datetime TIMESTAMP WITH TIME ZONE,
    reminder_sent BOOLEAN DEFAULT false,

    -- Recurrence
    is_recurring BOOLEAN DEFAULT false,
    recurrence_config JSONB DEFAULT '{}'::jsonb,
    parent_activity_uuid UUID,

    -- Custom Fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    tags JSONB DEFAULT '[]'::jsonb,

    -- Status
    is_active BOOLEAN DEFAULT true,
    is_completed BOOLEAN DEFAULT false,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_activities_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_activities_contact FOREIGN KEY (contact_uuid)
        REFERENCES public.contacts(contact_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_activities_account FOREIGN KEY (account_uuid)
        REFERENCES public.accounts(account_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_activities_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_activities_assigned_to FOREIGN KEY (assigned_to_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_activities_type CHECK (activity_type IN ('task', 'event', 'call', 'email', 'meeting', 'note')),
    CONSTRAINT chk_activities_status CHECK (status IN ('not_started', 'in_progress', 'completed', 'waiting', 'deferred', 'cancelled')),
    CONSTRAINT chk_activities_priority CHECK (priority IN ('low', 'medium', 'high', 'urgent'))
);

-- Indexes
CREATE INDEX idx_activities_uuid ON public.activities(activity_uuid);
CREATE INDEX idx_activities_company_id ON public.activities(company_id);
CREATE INDEX idx_activities_type ON public.activities(activity_type);
CREATE INDEX idx_activities_related ON public.activities(related_to_module, related_to_uuid);
CREATE INDEX idx_activities_contact ON public.activities(contact_uuid);
CREATE INDEX idx_activities_account ON public.activities(account_uuid);
CREATE INDEX idx_activities_owner ON public.activities(owner_uuid);
CREATE INDEX idx_activities_assigned ON public.activities(assigned_to_uuid);
CREATE INDEX idx_activities_status ON public.activities(status);
CREATE INDEX idx_activities_due_date ON public.activities(due_date);
CREATE INDEX idx_activities_start ON public.activities(start_datetime);
CREATE INDEX idx_activities_company_active ON public.activities(company_id, is_active);

-- Comments
COMMENT ON TABLE public.activities IS 'Unified activity table for tasks, events, calls, and emails';
COMMENT ON COLUMN public.activities.related_to_module IS 'Module name (accounts, deals, leads, etc.)';
COMMENT ON COLUMN public.activities.related_to_uuid IS 'UUID of the related record';
COMMENT ON COLUMN public.activities.attendees IS 'Array of attendee objects for events/meetings';
