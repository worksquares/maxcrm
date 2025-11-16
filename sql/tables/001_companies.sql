-- Table: public.companies
-- Multi-tenant company/organization table

DROP TABLE IF EXISTS public.companies CASCADE;

CREATE TABLE public.companies
(
    company_id SERIAL PRIMARY KEY,
    company_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Company Information
    company_name VARCHAR(255) NOT NULL,
    company_code VARCHAR(50) UNIQUE,
    legal_name VARCHAR(255),
    tax_id VARCHAR(50),

    -- Contact Information
    email VARCHAR(255),
    phone VARCHAR(50),
    website VARCHAR(255),

    -- Address
    address JSONB DEFAULT '{}'::jsonb,

    -- Subscription & Billing
    subscription_plan VARCHAR(50) DEFAULT 'free',
    subscription_status VARCHAR(50) DEFAULT 'active',
    subscription_start_date TIMESTAMP WITH TIME ZONE,
    subscription_end_date TIMESTAMP WITH TIME ZONE,
    max_users INTEGER DEFAULT 5,
    max_storage_gb INTEGER DEFAULT 10,

    -- Settings & Configuration
    settings JSONB DEFAULT '{}'::jsonb,
    features JSONB DEFAULT '{}'::jsonb,
    branding JSONB DEFAULT '{}'::jsonb,

    -- Custom Fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,

    -- Status
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    CONSTRAINT chk_subscription_status CHECK (subscription_status IN ('active', 'suspended', 'cancelled', 'trial', 'expired'))
);

-- Indexes
CREATE INDEX idx_companies_uuid ON public.companies(company_uuid);
CREATE INDEX idx_companies_code ON public.companies(company_code);
CREATE INDEX idx_companies_active ON public.companies(is_active);
CREATE INDEX idx_companies_subscription ON public.companies(subscription_status);

-- Comments
COMMENT ON TABLE public.companies IS 'Multi-tenant company/organization master table';
COMMENT ON COLUMN public.companies.settings IS 'Company-wide settings (timezone, currency, date format, etc.)';
COMMENT ON COLUMN public.companies.features IS 'Enabled features for this company';
COMMENT ON COLUMN public.companies.custom_fields IS 'Custom fields defined for company profile';
