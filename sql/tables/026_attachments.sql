-- Table: public.attachments
-- Files attached to records

DROP TABLE IF EXISTS public.attachments CASCADE;

CREATE TABLE public.attachments
(
    attachment_id SERIAL PRIMARY KEY,
    attachment_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,

    -- File Information
    file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(100),
    file_size_bytes BIGINT,
    mime_type VARCHAR(100),

    -- Storage
    file_path TEXT NOT NULL,
    storage_provider VARCHAR(50) DEFAULT 'local',
    external_id VARCHAR(255),

    -- Related To (polymorphic)
    related_to_module VARCHAR(100) NOT NULL,
    related_to_uuid UUID NOT NULL,
    related_to_name VARCHAR(255),

    -- File Details
    file_category VARCHAR(50),
    description TEXT,

    -- Image Specific
    image_width INTEGER,
    image_height INTEGER,
    thumbnail_path TEXT,

    -- Version Control
    version INTEGER DEFAULT 1,
    parent_attachment_uuid UUID,

    -- Access Control
    is_public BOOLEAN DEFAULT false,
    access_url TEXT,
    access_expires_at TIMESTAMP WITH TIME ZONE,

    -- Ownership
    owner_uuid UUID,

    -- Metadata
    metadata JSONB DEFAULT '{}'::jsonb,
    tags JSONB DEFAULT '[]'::jsonb,

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
    CONSTRAINT fk_attachments_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_attachments_owner FOREIGN KEY (owner_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_attachments_parent FOREIGN KEY (parent_attachment_uuid)
        REFERENCES public.attachments(attachment_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_attachments_storage CHECK (storage_provider IN ('local', 's3', 'azure', 'gcs', 'cloudinary'))
);

-- Indexes
CREATE INDEX idx_attachments_uuid ON public.attachments(attachment_uuid);
CREATE INDEX idx_attachments_company_id ON public.attachments(company_id);
CREATE INDEX idx_attachments_related ON public.attachments(related_to_module, related_to_uuid);
CREATE INDEX idx_attachments_owner ON public.attachments(owner_uuid);
CREATE INDEX idx_attachments_company_active ON public.attachments(company_id, is_active);
CREATE INDEX idx_attachments_created ON public.attachments(created_at DESC);

-- Comments
COMMENT ON TABLE public.attachments IS 'File attachments for any record';
COMMENT ON COLUMN public.attachments.related_to_module IS 'Module name (accounts, deals, contacts, etc.)';
COMMENT ON COLUMN public.attachments.file_path IS 'Relative or absolute path to file';
