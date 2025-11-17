-- Table: public.calls
-- Description: Call logs with duration, outcome, and recording tracking
-- Separate from activities for call-specific metrics and analytics

CREATE TABLE public.calls
(
    call_id SERIAL PRIMARY KEY,
    call_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Call details
    subject VARCHAR(255) NOT NULL,
    description TEXT,
    call_type VARCHAR(50) DEFAULT 'outbound',
    call_purpose VARCHAR(100),

    -- Participants
    caller_uuid UUID,
    assigned_to_uuid UUID,
    team_uuid UUID,

    -- Contact information
    phone_number VARCHAR(50),

    -- Related records (polymorphic)
    related_to_module VARCHAR(100),
    related_to_uuid UUID,

    -- Timing
    scheduled_start_datetime TIMESTAMPTZ,
    actual_start_datetime TIMESTAMPTZ,
    actual_end_datetime TIMESTAMPTZ,
    duration_seconds INTEGER,

    -- Call outcome
    status VARCHAR(50) DEFAULT 'scheduled',
    call_outcome VARCHAR(100),
    disposition VARCHAR(100),

    -- Recording & transcription
    recording_url VARCHAR(500),
    recording_duration_seconds INTEGER,
    transcription TEXT,
    sentiment_score NUMERIC(3,2),

    -- Follow-up
    requires_follow_up BOOLEAN DEFAULT FALSE,
    follow_up_date DATE,
    follow_up_notes TEXT,

    -- Metrics
    talk_time_seconds INTEGER,
    hold_time_seconds INTEGER,
    quality_score INTEGER,

    -- Flex columns for custom fields
    custom_text_1 VARCHAR(255),
    custom_text_2 VARCHAR(255),
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
    CONSTRAINT fk_calls_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_calls_caller FOREIGN KEY (caller_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_calls_assigned_to FOREIGN KEY (assigned_to_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_calls_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_calls_type CHECK (call_type IN ('inbound', 'outbound', 'missed', 'voicemail')),
    CONSTRAINT chk_calls_status CHECK (status IN ('scheduled', 'in_progress', 'completed', 'cancelled', 'no_answer', 'busy')),
    CONSTRAINT chk_calls_sentiment CHECK (sentiment_score IS NULL OR (sentiment_score >= -1 AND sentiment_score <= 1)),
    CONSTRAINT chk_calls_quality CHECK (quality_score IS NULL OR (quality_score >= 0 AND quality_score <= 100))
);

-- Indexes
CREATE INDEX idx_calls_company ON public.calls(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_calls_assigned_to ON public.calls(assigned_to_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_calls_status ON public.calls(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_calls_outcome ON public.calls(call_outcome) WHERE is_deleted = FALSE;
CREATE INDEX idx_calls_start_datetime ON public.calls(actual_start_datetime) WHERE is_deleted = FALSE;
CREATE INDEX idx_calls_related_to ON public.calls(related_to_module, related_to_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_calls_phone_number ON public.calls(phone_number) WHERE is_deleted = FALSE;

-- Comments
COMMENT ON TABLE public.calls IS 'Call logs with duration, outcome, recording, and sentiment analysis';
COMMENT ON COLUMN public.calls.sentiment_score IS 'Sentiment analysis score from -1 (negative) to 1 (positive)';
COMMENT ON COLUMN public.calls.quality_score IS 'Call quality rating from 0-100';
COMMENT ON COLUMN public.calls.disposition IS 'Call disposition codes like connected, left_voicemail, wrong_number, etc.';
