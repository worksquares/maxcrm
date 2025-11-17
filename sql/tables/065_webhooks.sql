-- Table: public.webhooks
-- Description: Webhook configurations for real-time event notifications
-- Enables integration with external systems

CREATE TABLE public.webhooks
(
    webhook_id SERIAL PRIMARY KEY,
    webhook_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Webhook details
    webhook_name VARCHAR(255) NOT NULL,
    description TEXT,

    -- Endpoint
    webhook_url VARCHAR(1000) NOT NULL,
    http_method VARCHAR(10) DEFAULT 'POST',

    -- Authentication
    auth_type VARCHAR(50) DEFAULT 'none',
    auth_token TEXT,
    auth_headers JSONB DEFAULT '{}'::jsonb,

    -- Event triggers
    trigger_module VARCHAR(100) NOT NULL,
    trigger_events TEXT[] DEFAULT ARRAY[]::TEXT[],

    -- Filters
    trigger_conditions JSONB DEFAULT '{}'::jsonb,

    -- Payload
    payload_template JSONB DEFAULT '{}'::jsonb,
    include_custom_fields BOOLEAN DEFAULT TRUE,

    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,

    -- Owner
    owner_uuid UUID,
    team_uuid UUID,

    -- Retry configuration
    max_retries INTEGER DEFAULT 3,
    retry_interval_seconds INTEGER DEFAULT 60,
    timeout_seconds INTEGER DEFAULT 30,

    -- Performance tracking
    total_calls_count INTEGER DEFAULT 0,
    successful_calls_count INTEGER DEFAULT 0,
    failed_calls_count INTEGER DEFAULT 0,
    last_triggered_at TIMESTAMPTZ,
    last_success_at TIMESTAMPTZ,
    last_failure_at TIMESTAMPTZ,
    last_error_message TEXT,

    -- Security
    secret_key VARCHAR(255),
    allowed_ip_addresses TEXT[],

    -- Custom fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Standard fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT fk_webhooks_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_webhooks_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_webhooks_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_webhooks_method CHECK (http_method IN ('POST', 'PUT', 'PATCH', 'GET')),
    CONSTRAINT chk_webhooks_auth_type CHECK (auth_type IN ('none', 'basic', 'bearer', 'api_key', 'oauth2', 'custom')),
    CONSTRAINT uq_webhooks_name UNIQUE (company_id, webhook_name)
);

-- Indexes
CREATE INDEX idx_webhooks_company ON public.webhooks(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_webhooks_active ON public.webhooks(is_active) WHERE is_deleted = FALSE;
CREATE INDEX idx_webhooks_module ON public.webhooks(trigger_module) WHERE is_deleted = FALSE;
CREATE INDEX idx_webhooks_events ON public.webhooks USING GIN (trigger_events);

-- Comments
COMMENT ON TABLE public.webhooks IS 'Webhook configurations for real-time event notifications to external systems';
COMMENT ON COLUMN public.webhooks.trigger_events IS 'Array: [create, update, delete, custom_event_name]';
COMMENT ON COLUMN public.webhooks.trigger_conditions IS 'JSON: Field conditions that must be met to trigger webhook';
COMMENT ON COLUMN public.webhooks.secret_key IS 'Used to sign webhook payloads for verification by receiver';
