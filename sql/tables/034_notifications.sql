-- Table: public.notifications
DROP TABLE IF EXISTS public.notifications CASCADE;
CREATE TABLE public.notifications (
    notification_id SERIAL PRIMARY KEY, notification_uuid UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    user_uuid UUID NOT NULL, notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL, message TEXT, action_url TEXT,
    related_to_module VARCHAR(100), related_to_uuid UUID, related_to_name VARCHAR(255),
    priority VARCHAR(50) DEFAULT 'normal', is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE, is_dismissed BOOLEAN DEFAULT false,
    dismissed_at TIMESTAMP WITH TIME ZONE, is_sent BOOLEAN DEFAULT false,
    sent_at TIMESTAMP WITH TIME ZONE, delivery_channels JSONB DEFAULT '[]'::jsonb,
    metadata JSONB DEFAULT '{}'::jsonb, company_id INTEGER NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), created_by UUID,
    CONSTRAINT fk_notifications_company FOREIGN KEY (company_id) REFERENCES public.companies(company_id) ON DELETE RESTRICT,
    CONSTRAINT fk_notifications_user FOREIGN KEY (user_uuid) REFERENCES public.users(user_uuid) ON DELETE CASCADE,
    CONSTRAINT chk_notifications_type CHECK (notification_type IN ('mention', 'assignment', 'approval', 'task_due', 'activity_reminder', 'deal_stage_change', 'workflow', 'system', 'chat', 'comment'))
);
CREATE INDEX idx_notifications_user ON public.notifications(user_uuid);
CREATE INDEX idx_notifications_user_unread ON public.notifications(user_uuid, is_read) WHERE is_read = false;