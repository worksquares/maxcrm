-- Table: public.roles
-- User roles and permissions

DROP TABLE IF EXISTS public.roles CASCADE;

CREATE TABLE public.roles
(
    role_id SERIAL PRIMARY KEY,
    role_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Role Information
    role_name VARCHAR(100) NOT NULL,
    role_code VARCHAR(50),
    description TEXT,

    -- Permissions Configuration
    permissions JSONB DEFAULT '{}'::jsonb,
    module_access JSONB DEFAULT '{}'::jsonb,
    data_access_level VARCHAR(50) DEFAULT 'own',

    -- Hierarchy
    parent_role_uuid UUID,
    role_level INTEGER DEFAULT 0,

    -- Status
    is_active BOOLEAN DEFAULT true,
    is_system BOOLEAN DEFAULT false,

    -- Custom Fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_roles_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_roles_parent FOREIGN KEY (parent_role_uuid)
        REFERENCES public.roles(role_uuid) ON DELETE SET NULL,
    CONSTRAINT uk_roles_company_name UNIQUE (company_id, role_name),
    CONSTRAINT chk_roles_data_access CHECK (data_access_level IN ('own', 'team', 'department', 'all', 'custom'))
);

-- Indexes
CREATE INDEX idx_roles_uuid ON public.roles(role_uuid);
CREATE INDEX idx_roles_company_id ON public.roles(company_id);
CREATE INDEX idx_roles_company_active ON public.roles(company_id, is_active);
CREATE INDEX idx_roles_parent ON public.roles(parent_role_uuid) WHERE parent_role_uuid IS NOT NULL;

-- Comments
COMMENT ON TABLE public.roles IS 'User roles with permission configuration';
COMMENT ON COLUMN public.roles.permissions IS 'Permission matrix: {module: {create, read, update, delete, export}}';
COMMENT ON COLUMN public.roles.module_access IS 'Module-level access controls';
COMMENT ON COLUMN public.roles.data_access_level IS 'Data visibility scope for this role';
