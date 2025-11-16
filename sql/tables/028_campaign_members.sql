-- Table: public.campaign_members
-- Members (leads/contacts) in campaigns

DROP TABLE IF EXISTS public.campaign_members CASCADE;

CREATE TABLE public.campaign_members
(
    campaign_member_id SERIAL PRIMARY KEY,
    campaign_member_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Campaign Association
    campaign_uuid UUID NOT NULL,

    -- Member (polymorphic: lead or contact)
    member_type VARCHAR(50) NOT NULL,
    member_uuid UUID NOT NULL,
    member_name VARCHAR(255),

    -- Member Status
    status VARCHAR(50) DEFAULT 'sent',
    responded BOOLEAN DEFAULT false,
    response_date TIMESTAMP WITH TIME ZONE,

    -- Engagement
    emails_opened INTEGER DEFAULT 0,
    emails_clicked INTEGER DEFAULT 0,
    links_clicked JSONB DEFAULT '[]'::jsonb,

    -- Conversion
    is_converted BOOLEAN DEFAULT false,
    converted_deal_uuid UUID,

    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_campaign_members_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_campaign_members_campaign FOREIGN KEY (campaign_uuid)
        REFERENCES public.campaigns(campaign_uuid) ON DELETE CASCADE,
    CONSTRAINT uk_campaign_members_unique UNIQUE (campaign_uuid, member_type, member_uuid),
    CONSTRAINT chk_campaign_member_type CHECK (member_type IN ('lead', 'contact')),
    CONSTRAINT chk_campaign_member_status CHECK (status IN ('sent', 'responded', 'bounced', 'unsubscribed', 'converted'))
);

-- Indexes
CREATE INDEX idx_campaign_members_uuid ON public.campaign_members(campaign_member_uuid);
CREATE INDEX idx_campaign_members_company_id ON public.campaign_members(company_id);
CREATE INDEX idx_campaign_members_campaign ON public.campaign_members(campaign_uuid);
CREATE INDEX idx_campaign_members_member ON public.campaign_members(member_type, member_uuid);
CREATE INDEX idx_campaign_members_status ON public.campaign_members(status);

-- Comments
COMMENT ON TABLE public.campaign_members IS 'Leads and contacts associated with campaigns';
