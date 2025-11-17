-- Table: public.users
-- User accounts table

DROP TABLE IF EXISTS public.users CASCADE;

CREATE TABLE public.users
(
    user_id SERIAL PRIMARY KEY,
    user_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Basic Information
    email VARCHAR(255) NOT NULL,
    username VARCHAR(100),
    password_hash VARCHAR(255),

    -- Personal Information
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    full_name VARCHAR(255),
    phone VARCHAR(50),
    mobile VARCHAR(50),

    -- Profile
    title VARCHAR(100),
    department VARCHAR(100),
    employee_id VARCHAR(50),
    profile_picture_url TEXT,
    bio TEXT,

    -- Manager Hierarchy
    manager_uuid UUID,

    -- Role & Permissions
    role_uuid UUID,

    -- Settings (JSONB for display/rare queries)
    preferences JSONB DEFAULT '{}'::jsonb,
    notification_settings JSONB DEFAULT '{}'::jsonb,
    permissions JSONB DEFAULT '{}'::jsonb,

    -- Status
    status VARCHAR(50) DEFAULT 'active',
    is_active BOOLEAN DEFAULT true,
    is_verified BOOLEAN DEFAULT false,
    is_locked BOOLEAN DEFAULT false,

    -- Authentication
    last_login_at TIMESTAMP WITH TIME ZONE,
    password_changed_at TIMESTAMP WITH TIME ZONE,
    failed_login_attempts INTEGER DEFAULT 0,

    -- Custom Fields (JSONB for overflow)
    custom_fields JSONB DEFAULT '{}'::jsonb,

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
    CONSTRAINT fk_users_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_users_manager FOREIGN KEY (manager_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT uk_users_company_email UNIQUE (company_id, email),
    CONSTRAINT chk_users_status CHECK (status IN ('active', 'inactive', 'suspended', 'pending'))
);

-- Indexes
CREATE INDEX idx_users_uuid ON public.users(user_uuid);
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_company_id ON public.users(company_id);
CREATE INDEX idx_users_company_active ON public.users(company_id, is_active);
CREATE INDEX idx_users_manager ON public.users(manager_uuid) WHERE manager_uuid IS NOT NULL;
CREATE INDEX idx_users_role ON public.users(role_uuid);
CREATE INDEX idx_users_status ON public.users(status);

-- Comments
COMMENT ON TABLE public.users IS 'User accounts and profiles';
COMMENT ON COLUMN public.users.preferences IS 'User preferences (theme, language, timezone, etc.) - JSONB';
COMMENT ON COLUMN public.users.permissions IS 'User-specific permission overrides - JSONB';
