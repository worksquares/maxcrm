-- Table: public.events
-- Description: Calendar events with attendees, locations, and recurrence
-- Separate from tasks for meeting/event-specific functionality

CREATE TABLE public.events
(
    event_id SERIAL PRIMARY KEY,
    event_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Event details
    subject VARCHAR(255) NOT NULL,
    description TEXT,
    location VARCHAR(255),
    event_type VARCHAR(50) DEFAULT 'meeting',

    -- Timing
    start_datetime TIMESTAMPTZ NOT NULL,
    end_datetime TIMESTAMPTZ NOT NULL,
    all_day_event BOOLEAN DEFAULT FALSE,
    timezone VARCHAR(100),

    -- Organizer
    organizer_uuid UUID,
    team_uuid UUID,

    -- Related records (polymorphic)
    related_to_module VARCHAR(100),
    related_to_uuid UUID,

    -- Meeting details
    meeting_url VARCHAR(500),
    meeting_platform VARCHAR(50),
    meeting_id VARCHAR(255),
    meeting_password VARCHAR(100),

    -- Attendees (stored as JSONB array)
    attendees JSONB DEFAULT '[]'::jsonb,

    -- Recurrence
    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence_pattern JSONB DEFAULT '{}'::jsonb,
    recurrence_end_date DATE,

    -- Reminders
    reminder_minutes_before INTEGER DEFAULT 15,
    reminder_sent BOOLEAN DEFAULT FALSE,

    -- Status
    status VARCHAR(50) DEFAULT 'planned',
    show_as VARCHAR(50) DEFAULT 'busy',

    -- Flex columns for custom fields
    custom_text_1 VARCHAR(255),
    custom_number_1 NUMERIC(15,2),
    custom_date_1 DATE,
    custom_lookup_1_uuid UUID,

    -- Additional custom fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Standard fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT fk_events_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_events_organizer FOREIGN KEY (organizer_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_events_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_events_type CHECK (event_type IN ('meeting', 'call', 'demo', 'presentation', 'training', 'conference', 'webinar', 'other')),
    CONSTRAINT chk_events_status CHECK (status IN ('planned', 'confirmed', 'completed', 'cancelled', 'no_show')),
    CONSTRAINT chk_events_show_as CHECK (show_as IN ('free', 'busy', 'tentative', 'out_of_office')),
    CONSTRAINT chk_events_datetime CHECK (end_datetime > start_datetime)
);

-- Indexes
CREATE INDEX idx_events_company ON public.events(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_events_organizer ON public.events(organizer_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_events_start_datetime ON public.events(start_datetime) WHERE is_deleted = FALSE;
CREATE INDEX idx_events_end_datetime ON public.events(end_datetime) WHERE is_deleted = FALSE;
CREATE INDEX idx_events_status ON public.events(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_events_related_to ON public.events(related_to_module, related_to_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_events_attendees ON public.events USING GIN (attendees);

-- Comments
COMMENT ON TABLE public.events IS 'Calendar events with attendees, locations, and meeting details';
COMMENT ON COLUMN public.events.attendees IS 'JSON array: [{user_uuid: xxx, response: accepted|declined|tentative, is_required: true}]';
COMMENT ON COLUMN public.events.recurrence_pattern IS 'JSON: {frequency: daily|weekly|monthly, interval: 1, days_of_week: [1,3,5]}';
COMMENT ON COLUMN public.events.show_as IS 'Calendar availability status';
