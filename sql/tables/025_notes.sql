-- Table: public.notes
DROP TABLE IF EXISTS public.notes CASCADE;
CREATE TABLE public.notes (
    note_id SERIAL PRIMARY KEY, note_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    title VARCHAR(255), note_content TEXT NOT NULL, related_to_module VARCHAR(100) NOT NULL,
    related_to_uuid UUID NOT NULL, related_to_name VARCHAR(255), note_type VARCHAR(50) DEFAULT 'general',
    is_private BOOLEAN DEFAULT false, owner_uuid UUID, metadata JSONB DEFAULT '{}'::jsonb,
    tags JSONB DEFAULT '[]'::jsonb, is_active BOOLEAN DEFAULT true, is_pinned BOOLEAN DEFAULT false,
    company_id INTEGER NOT NULL, created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), created_by UUID, updated_by UUID,
    CONSTRAINT fk_notes_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_notes_owner FOREIGN KEY (owner_uuid) REFERENCES public.users(user_uuid) ON DELETE SET NULL
);
CREATE INDEX idx_notes_uuid ON public.notes(note_uuid);
CREATE INDEX idx_notes_related ON public.notes(related_to_module, related_to_uuid);