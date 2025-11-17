-- Table: public.campaign_members
DROP TABLE IF EXISTS public.campaign_members CASCADE;
CREATE TABLE public.campaign_members (
    campaign_member_id SERIAL PRIMARY KEY, campaign_member_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    campaign_uuid UUID NOT NULL, member_type VARCHAR(50) NOT NULL, member_uuid UUID NOT NULL,
    member_name VARCHAR(255), status VARCHAR(50) DEFAULT 'sent', responded BOOLEAN DEFAULT false,
    response_date TIMESTAMP WITH TIME ZONE, emails_opened INTEGER DEFAULT 0, emails_clicked INTEGER DEFAULT 0,
    links_clicked JSONB DEFAULT '[]'::jsonb, is_converted BOOLEAN DEFAULT false,
    converted_deal_uuid UUID, metadata JSONB DEFAULT '{}'::jsonb, company_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, updated_by UUID,
    CONSTRAINT fk_campaign_members_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_campaign_members_campaign FOREIGN KEY (campaign_uuid) REFERENCES public.campaigns(campaign_uuid) ON DELETE CASCADE,
    CONSTRAINT uk_campaign_members_unique UNIQUE (campaign_uuid, member_type, member_uuid),
    CONSTRAINT chk_campaign_member_type CHECK (member_type IN ('lead', 'contact'))
);
CREATE INDEX idx_campaign_members_uuid ON public.campaign_members(campaign_member_uuid);
CREATE INDEX idx_campaign_members_campaign ON public.campaign_members(campaign_uuid);