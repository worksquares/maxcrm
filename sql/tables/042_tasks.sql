-- Table: public.tasks
-- Description: Task management with priorities, dependencies, and assignments
-- Replaces generic "activities" table for task-specific functionality

CREATE TABLE public.tasks
(
    task_id SERIAL PRIMARY KEY,
    task_uuid UUID UNIQUE NOT NULL DEFAULT gen_random_uuid(),
    company_id INTEGER NOT NULL,

    -- Task details
    subject VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(50) DEFAULT 'not_started',
    priority VARCHAR(50) DEFAULT 'medium',

    -- Assignment
    assigned_to_uuid UUID,
    team_uuid UUID,

    -- Related records (polymorphic)
    related_to_module VARCHAR(100),
    related_to_uuid UUID,

    -- Timing
    due_date DATE,
    due_time TIME,
    reminder_datetime TIMESTAMPTZ,

    -- Progress
    progress_percentage INTEGER DEFAULT 0,
    estimated_hours NUMERIC(8,2),
    actual_hours NUMERIC(8,2),

    -- Dependencies
    parent_task_uuid UUID,
    blocks_task_uuids UUID[] DEFAULT ARRAY[]::UUID[],

    -- Recurrence
    is_recurring BOOLEAN DEFAULT FALSE,
    recurrence_pattern JSONB DEFAULT '{}'::jsonb,

    -- Flex columns for custom fields
    custom_text_1 VARCHAR(255),
    custom_text_2 VARCHAR(255),
    custom_number_1 NUMERIC(15,2),
    custom_date_1 DATE,
    custom_lookup_1_uuid UUID,

    -- Additional custom fields
    custom_fields JSONB DEFAULT '{}'::jsonb,

    -- Standard fields
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by_uuid UUID,
    updated_by_uuid UUID,
    is_deleted BOOLEAN DEFAULT FALSE,
    deleted_at TIMESTAMPTZ,

    -- Constraints
    CONSTRAINT fk_tasks_company FOREIGN KEY (company_id)
        REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_tasks_assigned_to FOREIGN KEY (assigned_to_uuid)
        REFERENCES public.users(user_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_tasks_team FOREIGN KEY (team_uuid)
        REFERENCES public.teams(team_uuid) ON DELETE SET NULL,
    CONSTRAINT fk_tasks_parent FOREIGN KEY (parent_task_uuid)
        REFERENCES public.tasks(task_uuid) ON DELETE SET NULL,
    CONSTRAINT chk_tasks_status CHECK (status IN ('not_started', 'in_progress', 'waiting', 'completed', 'deferred', 'cancelled')),
    CONSTRAINT chk_tasks_priority CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    CONSTRAINT chk_tasks_progress CHECK (progress_percentage >= 0 AND progress_percentage <= 100)
);

-- Indexes
CREATE INDEX idx_tasks_company ON public.tasks(company_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_tasks_assigned_to ON public.tasks(assigned_to_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_tasks_team ON public.tasks(team_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_tasks_status ON public.tasks(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_tasks_priority ON public.tasks(priority) WHERE is_deleted = FALSE;
CREATE INDEX idx_tasks_due_date ON public.tasks(due_date) WHERE is_deleted = FALSE;
CREATE INDEX idx_tasks_related_to ON public.tasks(related_to_module, related_to_uuid) WHERE is_deleted = FALSE;
CREATE INDEX idx_tasks_created_at ON public.tasks(created_at DESC);

-- Comments
COMMENT ON TABLE public.tasks IS 'Task management with priorities, dependencies, and recurrence';
COMMENT ON COLUMN public.tasks.blocks_task_uuids IS 'Array of task UUIDs that are blocked by this task';
COMMENT ON COLUMN public.tasks.recurrence_pattern IS 'JSON: {frequency: daily|weekly|monthly, interval: 1, end_date: 2024-12-31}';
