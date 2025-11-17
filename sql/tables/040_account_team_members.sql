-- Table: public.account_team_members
-- Junction table for account team access

DROP TABLE IF EXISTS public.account_team_members CASCADE;

CREATE TABLE public.account_team_members
(
    account_team_member_id SERIAL PRIMARY KEY,
    account_team_member_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Associations
    account_uuid UUID NOT NULL,
    user_uuid UUID NOT NULL,
    team_uuid UUID,

    -- Role in Account Team
    team_role VARCHAR(100),
    access_level VARCHAR(50) DEFAULT 'read',

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
    CONSTRAINT fk_account_team_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_account_team_account FOREIGN KEY (account_uuid)
        REFERENCES public.accounts(account_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_account_team_user FOREIGN KEY (user_uuid)
        REFERENCES public.users(user_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_account_team_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT uk_account_team_account_user UNIQUE (account_uuid, user_uuid),
    CONSTRAINT chk_account_team_access CHECK (access_level IN ('read', 'write', 'admin'))
);

-- Indexes
CREATE INDEX idx_account_team_uuid ON public.account_team_members(account_team_member_uuid);
CREATE INDEX idx_account_team_account ON public.account_team_members(account_uuid);
CREATE INDEX idx_account_team_user ON public.account_team_members(user_uuid);
CREATE INDEX idx_account_team_team ON public.account_team_members(team_uuid);

-- Comments
COMMENT ON TABLE public.account_team_members IS 'Account team members with role-based access';
COMMENT ON COLUMN public.account_team_members.team_role IS 'Role in account team (Account Manager, Sales Rep, Support, etc.)';
COMMENT ON COLUMN public.account_team_members.access_level IS 'Access level: read, write, admin';
