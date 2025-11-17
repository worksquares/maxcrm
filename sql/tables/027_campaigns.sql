-- Table: public.campaigns
DROP TABLE IF EXISTS public.campaigns CASCADE;
CREATE TABLE public.campaigns (
    campaign_id SERIAL PRIMARY KEY, campaign_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    campaign_name VARCHAR(255) NOT NULL, campaign_code VARCHAR(50), description TEXT,
    campaign_type_uuid UUID, status VARCHAR(50) DEFAULT 'planning',
    start_date DATE, end_date DATE, actual_start_date DATE, actual_end_date DATE,
    budgeted_cost NUMERIC(15,2), actual_cost NUMERIC(15,2), expected_revenue NUMERIC(15,2),
    currency_code VARCHAR(3) DEFAULT 'USD', expected_responses INTEGER, actual_responses INTEGER,
    num_sent INTEGER DEFAULT 0, campaign_source VARCHAR(100), parent_campaign_uuid UUID,
    owner_uuid UUID, custom_fields JSONB DEFAULT '{}'::jsonb, metadata JSONB DEFAULT '{}'::jsonb,
    tags JSONB DEFAULT '[]'::jsonb, is_active BOOLEAN DEFAULT true, company_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, updated_by UUID,
    CONSTRAINT fk_campaigns_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_campaigns_owner FOREIGN KEY (owner_uuid) REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT uk_campaigns_company_code UNIQUE (company_id, campaign_code)
);
CREATE INDEX idx_campaigns_uuid ON public.campaigns(campaign_uuid);
CREATE INDEX idx_campaigns_owner ON public.campaigns(owner_uuid);
CREATE INDEX idx_campaigns_status ON public.campaigns(status);