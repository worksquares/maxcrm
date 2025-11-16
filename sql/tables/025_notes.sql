-- Table: public.notes
-- Notes attached to records

DROP TABLE IF EXISTS public.notes CASCADE;

CREATE TABLE public.notes
(
    note_id SERIAL PRIMARY KEY,
    note_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- Note Information
    title VARCHAR(255),
    note_content TEXT NOT NULL,

    -- Related To (polymorphic)
    related_to_module VARCHAR(100) NOT NULL,
    related_to_uuid UUID NOT NULL,
    related_to_name VARCHAR(255),

    -- Note Type
    note_type VARCHAR(50) DEFAULT 'general',

    -- Privacy
    is_private BOOLEAN DEFAULT false,

    -- Ownership
    owner_uuid UUID,

    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    tags JSONB DEFAULT '[]'::jsonb,

    -- Status
    is_active BOOLEAN DEFAULT true,
    is_pinned BOOLEAN DEFAULT false,

    -- Multi-tenant
    company_id INTEGER NOT NULL,

    -- Audit Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,

    -- Constraints
    CONSTRAINT fk_notes_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_notes_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL
);

-- Indexes
CREATE INDEX idx_notes_uuid ON public.notes(note_uuid);
CREATE INDEX idx_notes_company_id ON public.notes(company_id);
CREATE INDEX idx_notes_related ON public.notes(related_to_module, related_to_uuid);
CREATE INDEX idx_notes_owner ON public.notes(owner_uuid);
CREATE INDEX idx_notes_company_active ON public.notes(company_id, is_active);
CREATE INDEX idx_notes_created ON public.notes(created_at DESC);

-- Comments
COMMENT ON TABLE public.notes IS 'Notes attached to any record';
COMMENT ON COLUMN public.notes.related_to_module IS 'Module name (accounts, deals, contacts, etc.)';
