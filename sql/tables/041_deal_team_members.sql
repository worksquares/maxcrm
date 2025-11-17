-- Table: public.deal_team_members
-- Junction table for deal team collaboration

DROP TABLE IF EXISTS public.deal_team_members CASCADE;

CREATE TABLE public.deal_team_members
(
    deal_team_member_id SERIAL PRIMARY KEY,
    deal_team_member_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Associations
    deal_uuid UUID NOT NULL,
    user_uuid UUID NOT NULL,
    team_uuid UUID,

    -- Role in Deal Team
    team_role VARCHAR(100),
    split_percentage NUMERIC(5,2),
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
    CONSTRAINT fk_deal_team_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_deal_team_deal FOREIGN KEY (deal_uuid)
        REFERENCES public.deals(deal_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_deal_team_user FOREIGN KEY (user_uuid)
        REFERENCES public.users(user_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_deal_team_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT uk_deal_team_deal_user UNIQUE (deal_uuid, user_uuid),
    CONSTRAINT chk_deal_team_access CHECK (access_level IN ('read', 'write', 'admin')),
    CONSTRAINT chk_deal_team_split CHECK (split_percentage >= 0 AND split_percentage <= 100)
);

-- Indexes
CREATE INDEX idx_deal_team_uuid ON public.deal_team_members(deal_team_member_uuid);
CREATE INDEX idx_deal_team_deal ON public.deal_team_members(deal_uuid);
CREATE INDEX idx_deal_team_user ON public.deal_team_members(user_uuid);
CREATE INDEX idx_deal_team_team ON public.deal_team_members(team_uuid);

-- Comments
COMMENT ON TABLE public.deal_team_members IS 'Deal team members with roles and revenue splits';
COMMENT ON COLUMN public.deal_team_members.team_role IS 'Role in deal team (Sales Rep, Sales Engineer, Partner, etc.)';
COMMENT ON COLUMN public.deal_team_members.split_percentage IS 'Revenue/commission split percentage for this team member';
COMMENT ON COLUMN public.deal_team_members.access_level IS 'Access level: read, write, admin';
