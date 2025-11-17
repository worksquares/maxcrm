-- Table: public.emails
-- Description: Email messages with threading, tracking, and engagement metrics
-- Separate from email_templates for actual sent/received emails

CREATE TABLE public.emails
(
    email_id SERIAL PRIMARY KEY,
    email_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Email details
    subject VARCHAR(500) NOT NULL,
    body_html TEXT,
    body_plain TEXT,
    email_type VARCHAR(50) DEFAULT 'outbound',

    -- Sender/Recipient
    from_address VARCHAR(255) NOT NULL,
    to_addresses TEXT[],
    cc_addresses TEXT[],
    bcc_addresses TEXT[],

    -- Assignment
    owner_uuid UUID,
    team_uuid UUID,

    -- Related records (polymorphic)
    related_to_module VARCHAR(100),
    related_to_uuid UUID,

    -- Threading
    thread_id VARCHAR(255),
    in_reply_to_email_uuid UUID,
    message_id VARCHAR(255),

    -- Template
    email_template_uuid UUID,

    -- Timing
    scheduled_send_datetime TIMESTAMPTZ,
    sent_datetime TIMESTAMPTZ,
    delivered_datetime TIMESTAMPTZ,

    -- Status & tracking
    status VARCHAR(50) DEFAULT 'draft',
    is_tracked BOOLEAN DEFAULT TRUE,
    is_bulk_email BOOLEAN DEFAULT FALSE,

    -- Engagement metrics
    opened_count INTEGER DEFAULT 0,
    first_opened_at TIMESTAMPTZ,
    last_opened_at TIMESTAMPTZ,
    clicked_count INTEGER DEFAULT 0,
    first_clicked_at TIMESTAMPTZ,
    last_clicked_at TIMESTAMPTZ,
    replied BOOLEAN DEFAULT FALSE,
    replied_at TIMESTAMPTZ,
    bounced BOOLEAN DEFAULT FALSE,
    bounce_reason VARCHAR(255),

    -- Attachments
    has_attachments BOOLEAN DEFAULT FALSE,
    attachment_count INTEGER DEFAULT 0,
    attachment_uuids UUID[] DEFAULT ARRAY[]::UUID[],

    -- Campaign
    campaign_uuid UUID,

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
    CONSTRAINT fk_emails_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_emails_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_emails_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_emails_template FOREIGN KEY (email_template_uuid)
        REFERENCES public.email_templates(email_template_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_emails_campaign FOREIGN KEY (campaign_uuid)
        REFERENCES public.campaigns(campaign_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_emails_reply_to FOREIGN KEY (in_reply_to_email_uuid)
        REFERENCES public.emails(email_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_emails_type CHECK (email_type IN ('inbound', 'outbound', 'forwarded', 'auto_reply')),
    CONSTRAINT chk_emails_status CHECK (status IN ('draft', 'scheduled', 'sending', 'sent', 'delivered', 'bounced', 'failed'))
);

-- Indexes
CREATE INDEX idx_emails_company ON public.emails(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_emails_owner ON public.emails(owner_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_emails_status ON public.emails(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_emails_sent_datetime ON public.emails(sent_datetime DESC) WHERE is_deleted = FALSE;
CREATE INDEX idx_emails_related_to ON public.emails(related_to_module, related_to_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_emails_thread_id ON public.emails(thread_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_emails_from_address ON public.emails(from_address) WHERE is_deleted = FALSE;
CREATE INDEX idx_emails_campaign ON public.emails(campaign_uuid) WHERE is_deleted = FALSE;

-- Comments
COMMENT ON TABLE public.emails IS 'Email messages with threading, tracking, and engagement metrics';
COMMENT ON COLUMN public.emails.opened_count IS 'Number of times email was opened (may count multiple opens by same recipient)';
COMMENT ON COLUMN public.emails.clicked_count IS 'Number of times links in email were clicked';
COMMENT ON COLUMN public.emails.attachment_uuids IS 'Array of attachment UUIDs from attachments table';
