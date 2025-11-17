-- Table: public.teams
-- Teams for organization and access control

DROP TABLE IF EXISTS public.teams CASCADE;

CREATE TABLE public.teams
(
    team_id SERIAL PRIMARY KEY,
    team_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Team Information
    team_name VARCHAR(100) NOT NULL,
    team_code VARCHAR(50),
    description TEXT,

    -- Hierarchy
    parent_team_uuid UUID,
    team_level INTEGER DEFAULT 0,

    -- Team Lead
    team_lead_uuid UUID,

    -- Settings
    settings JSONB DEFAULT '{}'::jsonb,

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
    CONSTRAINT fk_teams_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_teams_parent FOREIGN KEY (parent_team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_teams_lead FOREIGN KEY (team_lead_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT uk_teams_company_name UNIQUE (company_id, team_name)
);

-- Indexes
CREATE INDEX idx_teams_uuid ON public.teams(team_uuid);
CREATE INDEX idx_teams_company_id ON public.teams(company_id);
CREATE INDEX idx_teams_company_active ON public.teams(company_id, is_active);
CREATE INDEX idx_teams_parent ON public.teams(parent_team_uuid) WHERE parent_team_uuid IS NOT NULL;
CREATE INDEX idx_teams_lead ON public.teams(team_lead_uuid);

-- Comments
COMMENT ON TABLE public.teams IS 'Teams for organization structure and access control';
COMMENT ON COLUMN public.teams.parent_team_uuid IS 'Parent team for hierarchical team structure';
COMMENT ON COLUMN public.teams.team_lead_uuid IS 'User who leads this team';
