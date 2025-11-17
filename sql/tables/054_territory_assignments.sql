-- Table: public.territory_assignments
-- Description: Junction table assigning users to territories with roles
-- Supports multiple users per territory and multiple territories per user

CREATE TABLE public.territory_assignments
(
    territory_assignment_id SERIAL PRIMARY KEY,
    territory_assignment_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Assignment
    territory_uuid UUID NOT NULL,
    user_uuid UUID NOT NULL,

    -- Role in territory
    territory_role VARCHAR(50) DEFAULT 'member',
    access_level VARCHAR(50) DEFAULT 'read_write',

    -- Dates
    effective_from_date DATE NOT NULL,
    effective_to_date DATE,

    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_primary BOOLEAN DEFAULT FALSE,

    -- Notes
    assignment_notes TEXT,

    -- Standard fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT fk_territory_assignments_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_territory_assignments_territory FOREIGN KEY (territory_uuid)
        REFERENCES public.territories(territory_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_territory_assignments_user FOREIGN KEY (user_uuid)
        REFERENCES public.users(user_uuid) ON DELETE CASCADE,
    CONSTRAINT chk_territory_assignments_role CHECK (territory_role IN ('manager', 'member', 'viewer', 'collaborator')),
    CONSTRAINT chk_territory_assignments_access CHECK (access_level IN ('read_only', 'read_write', 'full_access')),
    CONSTRAINT uq_territory_assignments UNIQUE (territory_uuid, user_uuid, effective_from_date)
);

-- Indexes
CREATE INDEX idx_territory_assignments_company ON public.territory_assignments(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_territory_assignments_territory ON public.territory_assignments(territory_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_territory_assignments_user ON public.territory_assignments(user_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_territory_assignments_active ON public.territory_assignments(is_active) WHERE is_deleted = FALSE;
CREATE INDEX idx_territory_assignments_dates ON public.territory_assignments(effective_from_date, effective_to_date) WHERE is_deleted = FALSE;

-- Comments
COMMENT ON TABLE public.territory_assignments IS 'User assignments to territories with roles and date ranges';
COMMENT ON COLUMN public.territory_assignments.is_primary IS 'Whether this is the user''s primary territory assignment';
