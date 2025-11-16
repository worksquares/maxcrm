-- Table: public.contacts
-- Individual contact persons

DROP TABLE IF EXISTS public.contacts CASCADE;

CREATE TABLE public.contacts
(
    contact_id SERIAL PRIMARY KEY,
    contact_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Personal Information
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(255) NOT NULL,
    salutation VARCHAR(20),
    suffix VARCHAR(20),

    -- Professional Information
    title VARCHAR(100),
    department VARCHAR(100),
    account_uuid UUID,
    contact_role_uuid UUID,
    reports_to_uuid UUID,

    -- Contact Information
    email VARCHAR(255),
    secondary_email VARCHAR(255),
    phone VARCHAR(50),
    mobile VARCHAR(50),
    fax VARCHAR(50),

    -- Address
    mailing_address JSONB DEFAULT '{}'::jsonb,

    -- Social & Web
    linkedin_url VARCHAR(255),
    twitter_handle VARCHAR(100),
    social_links JSONB DEFAULT '{}'::jsonb,

    -- Personal Details
    birthdate DATE,
    gender VARCHAR(20),

    -- Ownership & Assignment
    owner_uuid UUID,
    team_uuid UUID,

    -- Status & Classification
    status VARCHAR(50) DEFAULT 'active',
    lifecycle_stage VARCHAR(50),
    lead_score INTEGER DEFAULT 0,

    -- Communication Preferences
    email_opt_out BOOLEAN DEFAULT false,
    sms_opt_out BOOLEAN DEFAULT false,
    do_not_call BOOLEAN DEFAULT false,
    preferred_contact_method VARCHAR(50),

    -- Custom Fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    tags JSONB DEFAULT '[]'::jsonb,

    -- Status
    is_active BOOLEAN DEFAULT true,
    is_primary BOOLEAN DEFAULT false,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_contacts_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_contacts_account FOREIGN KEY (account_uuid)
        REFERENCES public.accounts(account_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_contacts_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_contacts_reports_to FOREIGN KEY (reports_to_uuid)
        REFERENCES public.contacts(contact_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_contacts_status CHECK (status IN ('active', 'inactive', 'prospect', 'customer', 'unqualified'))
);

-- Indexes
CREATE INDEX idx_contacts_uuid ON public.contacts(contact_uuid);
CREATE INDEX idx_contacts_company_id ON public.contacts(company_id);
CREATE INDEX idx_contacts_name ON public.contacts(full_name);
CREATE INDEX idx_contacts_email ON public.contacts(email);
CREATE INDEX idx_contacts_account ON public.contacts(account_uuid);
CREATE INDEX idx_contacts_owner ON public.contacts(owner_uuid);
CREATE INDEX idx_contacts_company_active ON public.contacts(company_id, is_active);
CREATE INDEX idx_contacts_status ON public.contacts(status);

-- Comments
COMMENT ON TABLE public.contacts IS 'Individual contact persons associated with accounts';
COMMENT ON COLUMN public.contacts.custom_fields IS 'Custom field values for dynamic fields';
COMMENT ON COLUMN public.contacts.mailing_address IS 'JSON: {street, city, state, country, postal_code}';
