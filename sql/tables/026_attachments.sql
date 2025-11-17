-- Table: public.attachments
DROP TABLE IF EXISTS public.attachments CASCADE;
CREATE TABLE public.attachments (
    attachment_id SERIAL PRIMARY KEY, attachment_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    file_name VARCHAR(255) NOT NULL, file_type VARCHAR(100), file_size_bytes BIGINT, mime_type VARCHAR(100),
    file_path TEXT NOT NULL, storage_provider VARCHAR(50) DEFAULT 'local', external_id VARCHAR(255),
    related_to_module VARCHAR(100) NOT NULL, related_to_uuid UUID NOT NULL,
    related_to_name VARCHAR(255), file_category VARCHAR(50), description TEXT,
    image_width INTEGER, image_height INTEGER, thumbnail_path TEXT,
    version INTEGER DEFAULT 1, parent_attachment_uuid UUID,
    is_public BOOLEAN DEFAULT false, access_url TEXT,
    access_expires_at TIMESTAMP WITH TIME ZONE, owner_uuid UUID,
    metadata JSONB DEFAULT '{}'::jsonb, tags JSONB DEFAULT '[]'::jsonb,
    is_active BOOLEAN DEFAULT true, company_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID, updated_by UUID,
    CONSTRAINT fk_attachments_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_attachments_owner FOREIGN KEY (owner_uuid) REFERENCES public.users(user_uuid) ON DELETE SET NULL
);
CREATE INDEX idx_attachments_uuid ON public.attachments(attachment_uuid);
CREATE INDEX idx_attachments_related ON public.attachments(related_to_module, related_to_uuid);