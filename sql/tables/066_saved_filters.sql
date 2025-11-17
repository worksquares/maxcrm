-- Table: public.saved_filters
-- Description: User-saved filters and list views for quick access
-- Saves custom filter criteria, column selections, and sort orders

CREATE TABLE public.saved_filters
(
    saved_filter_id SERIAL PRIMARY KEY,
    saved_filter_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Filter details
    filter_name VARCHAR(255) NOT NULL,
    description TEXT,

    -- Module/table this filter applies to
    module_name VARCHAR(100) NOT NULL,

    -- Filter criteria
    filter_conditions JSONB DEFAULT '{}'::jsonb NOT NULL,

    -- Display configuration
    selected_columns TEXT[],
    column_order JSONB DEFAULT '[]'::jsonb,
    sort_by VARCHAR(100),
    sort_direction VARCHAR(10) DEFAULT 'ASC',

    -- Pagination
    default_page_size INTEGER DEFAULT 25,

    -- Visibility
    visibility VARCHAR(50) DEFAULT 'private',
    is_default BOOLEAN DEFAULT FALSE,

    -- Owner
    owner_uuid UUID NOT NULL,
    team_uuid UUID,

    -- Sharing
    shared_with_user_uuids UUID[] DEFAULT ARRAY[]::UUID[],
    shared_with_team_uuids UUID[] DEFAULT ARRAY[]::UUID[],
    shared_with_role_uuids UUID[] DEFAULT ARRAY[]::UUID[],

    -- Usage tracking
    usage_count INTEGER DEFAULT 0,
    last_used_at TIMESTAMPTZ,

    -- Pin/favorite
    is_pinned BOOLEAN DEFAULT FALSE,

    -- Custom fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Standard fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT fk_saved_filters_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_saved_filters_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE CASCADE,
    CONSTRAINT fk_saved_filters_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_saved_filters_visibility CHECK (visibility IN ('private', 'team', 'public', 'shared')),
    CONSTRAINT chk_saved_filters_sort_direction CHECK (sort_direction IN ('ASC', 'DESC'))
);

-- Indexes
CREATE INDEX idx_saved_filters_company ON public.saved_filters(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_saved_filters_owner ON public.saved_filters(owner_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_saved_filters_module ON public.saved_filters(module_name) WHERE is_deleted = FALSE;
CREATE INDEX idx_saved_filters_visibility ON public.saved_filters(visibility) WHERE is_deleted = FALSE;
CREATE INDEX idx_saved_filters_default ON public.saved_filters(is_default) WHERE is_deleted = FALSE;
CREATE INDEX idx_saved_filters_shared_users ON public.saved_filters USING GIN (shared_with_user_uuids);
CREATE INDEX idx_saved_filters_shared_teams ON public.saved_filters USING GIN (shared_with_team_uuids);

-- Comments
COMMENT ON TABLE public.saved_filters IS 'User-saved filters and list views with criteria, columns, and sharing';
COMMENT ON COLUMN public.saved_filters.filter_conditions IS 'JSON: Complex filter rules {field: amount, operator: gt, value: 10000, logic: AND}';
COMMENT ON COLUMN public.saved_filters.column_order IS 'JSON array: Ordered list of columns with widths [{field: name, width: 200}]';
COMMENT ON COLUMN public.saved_filters.is_default IS 'Whether this is the default view for the module for this user';
