-- Table: public.leads
-- Sales leads before conversion

DROP TABLE IF EXISTS public.leads CASCADE;

CREATE TABLE public.leads
(
    lead_id SERIAL PRIMARY KEY,
    lead_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Personal Information
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(255) NOT NULL,
    salutation VARCHAR(20),

    -- Company Information
    company_name VARCHAR(255),
    title VARCHAR(100),
    industry_uuid UUID,
    employee_count INTEGER,
    annual_revenue NUMERIC(15,2),

    -- Contact Information
    email VARCHAR(255),
    phone VARCHAR(50),
    mobile VARCHAR(50),
    website VARCHAR(255),

    -- Address - Extract frequently queried fields
    country VARCHAR(100),
    state VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    address_line1 VARCHAR(255),
    address_line2 VARCHAR(255),
    address_full JSONB DEFAULT '{}'::jsonb,

    -- Lead Classification (UUID references for efficient JOINs)
    lead_source_uuid UUID,
    lead_status_uuid UUID,
    lead_rating_uuid UUID,
    lead_score INTEGER DEFAULT 0,

    -- Ownership
    owner_uuid UUID,
    team_uuid UUID,

    -- Conversion Status
    is_converted BOOLEAN DEFAULT false,
    converted_at TIMESTAMP WITH TIME ZONE,
    converted_account_uuid UUID,
    converted_contact_uuid UUID,
    converted_deal_uuid UUID,

    -- Lead Qualification (Frequently filtered)
    budget NUMERIC(15,2),
    timeline VARCHAR(100),
    pain_points TEXT,
    qualification_notes TEXT,
    is_qualified BOOLEAN DEFAULT false,

    -- Communication Preferences
    email_opt_out BOOLEAN DEFAULT false,
    sms_opt_out BOOLEAN DEFAULT false,
    do_not_call BOOLEAN DEFAULT false,

    -- Flex Columns for High-Query Custom Fields
    custom_text_1 VARCHAR(255),
    custom_text_2 VARCHAR(255),
    custom_text_3 VARCHAR(255),
    custom_number_1 NUMERIC(15,2),
    custom_number_2 NUMERIC(15,2),
    custom_date_1 DATE,
    custom_date_2 DATE,
    custom_boolean_1 BOOLEAN,
    custom_boolean_2 BOOLEAN,
    custom_lookup_1_uuid UUID,
    custom_lookup_2_uuid UUID,

    -- Custom Fields (JSONB for overflow)
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    tags JSONB DEFAULT '[]'::jsonb,
    utm_params JSONB DEFAULT '{}'::jsonb,

    -- Status
    is_active BOOLEAN DEFAULT true,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_leads_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_leads_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_leads_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_leads_converted_account FOREIGN KEY (converted_account_uuid)
        REFERENCES public.accounts(account_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_leads_converted_contact FOREIGN KEY (converted_contact_uuid)
        REFERENCES public.contacts(contact_uuid) ON DELETE SET NULL
);

-- Indexes
CREATE INDEX idx_leads_uuid ON public.leads(lead_uuid);
CREATE INDEX idx_leads_company_id ON public.leads(company_id);
CREATE INDEX idx_leads_name ON public.leads(full_name);
CREATE INDEX idx_leads_email ON public.leads(email);
CREATE INDEX idx_leads_owner ON public.leads(owner_uuid);
CREATE INDEX idx_leads_company_active ON public.leads(company_id, is_active);
CREATE INDEX idx_leads_status ON public.leads(lead_status_uuid);
CREATE INDEX idx_leads_source ON public.leads(lead_source_uuid);
CREATE INDEX idx_leads_converted ON public.leads(is_converted);
CREATE INDEX idx_leads_score ON public.leads(lead_score DESC);
CREATE INDEX idx_leads_country ON public.leads(country);
CREATE INDEX idx_leads_state ON public.leads(state);
CREATE INDEX idx_leads_annual_revenue ON public.leads(annual_revenue) WHERE annual_revenue IS NOT NULL;
CREATE INDEX idx_leads_budget ON public.leads(budget) WHERE budget IS NOT NULL;
CREATE INDEX idx_leads_custom_number_1 ON public.leads(custom_number_1) WHERE custom_number_1 IS NOT NULL;
CREATE INDEX idx_leads_custom_date_1 ON public.leads(custom_date_1) WHERE custom_date_1 IS NOT NULL;

-- Comments
COMMENT ON TABLE public.leads IS 'Sales leads before conversion to accounts/contacts/deals';
COMMENT ON COLUMN public.leads.lead_score IS 'Calculated lead score based on engagement and fit';
COMMENT ON COLUMN public.leads.utm_params IS 'UTM tracking parameters - JSONB: {source, medium, campaign, term, content}';
COMMENT ON COLUMN public.leads.custom_fields IS 'Overflow custom fields (JSONB)';
