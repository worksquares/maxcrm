-- =====================================================
-- MAXCRM Database Creation Script
-- PostgreSQL Complete CRM Schema
-- =====================================================
--
-- This script creates all tables for the MAXCRM system
-- Execute tables in order to maintain foreign key dependencies
--
-- Features:
-- - Multi-tenant architecture
-- - Dynamic forms and fields (JSONB)
-- - Workflow automation engine
-- - Multi-level approval system
-- - All tables have _id and _uuid columns
-- - Extensive use of JSONB for flexibility
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- SECTION 1: CORE TENANT & COMPANY
-- =====================================================

\echo 'Creating companies table...'
\i tables/001_companies.sql

\echo 'Creating common_master table...'
\i tables/002_common_master.sql

-- =====================================================
-- SECTION 2: USER MANAGEMENT
-- =====================================================

\echo 'Creating users table...'
\i tables/003_users.sql

\echo 'Creating roles table...'
\i tables/004_roles.sql

-- =====================================================
-- SECTION 3: CRM CORE ENTITIES
-- =====================================================

\echo 'Creating accounts table...'
\i tables/005_accounts.sql

\echo 'Creating contacts table...'
\i tables/006_contacts.sql

\echo 'Creating leads table...'
\i tables/007_leads.sql

-- =====================================================
-- SECTION 4: DEALS & PIPELINE
-- =====================================================

\echo 'Creating deals table...'
\i tables/008_deals.sql

\echo 'Creating pipelines table...'
\i tables/009_pipelines.sql

\echo 'Creating pipeline_stages table...'
\i tables/010_pipeline_stages.sql

-- =====================================================
-- SECTION 5: PRODUCTS & PRICING
-- =====================================================

\echo 'Creating products table...'
\i tables/011_products.sql

\echo 'Creating price_books table...'
\i tables/012_price_books.sql

\echo 'Creating price_book_entries table...'
\i tables/013_price_book_entries.sql

-- =====================================================
-- SECTION 6: QUOTES
-- =====================================================

\echo 'Creating quotes table...'
\i tables/014_quotes.sql

\echo 'Creating quote_line_items table...'
\i tables/015_quote_line_items.sql

-- =====================================================
-- SECTION 7: DYNAMIC FORMS & FIELDS
-- =====================================================

\echo 'Creating custom_modules table...'
\i tables/016_custom_modules.sql

\echo 'Creating custom_fields table...'
\i tables/017_custom_fields.sql

\echo 'Creating custom_records table...'
\i tables/018_custom_records.sql

-- =====================================================
-- SECTION 8: WORKFLOW ENGINE
-- =====================================================

\echo 'Creating workflows table...'
\i tables/019_workflows.sql

\echo 'Creating workflow_executions table...'
\i tables/020_workflow_executions.sql

-- =====================================================
-- SECTION 9: APPROVAL SYSTEM
-- =====================================================

\echo 'Creating approval_processes table...'
\i tables/021_approval_processes.sql

\echo 'Creating approval_requests table...'
\i tables/022_approval_requests.sql

\echo 'Creating approval_steps table...'
\i tables/023_approval_steps.sql

-- =====================================================
-- SECTION 10: ACTIVITIES & COMMUNICATIONS
-- =====================================================

\echo 'Creating activities table...'
\i tables/024_activities.sql

\echo 'Creating notes table...'
\i tables/025_notes.sql

\echo 'Creating attachments table...'
\i tables/026_attachments.sql

-- =====================================================
-- SECTION 11: MARKETING
-- =====================================================

\echo 'Creating campaigns table...'
\i tables/027_campaigns.sql

\echo 'Creating campaign_members table...'
\i tables/028_campaign_members.sql

\echo 'Creating email_templates table...'
\i tables/029_email_templates.sql

-- =====================================================
-- SECTION 12: CUSTOMER SUPPORT
-- =====================================================

\echo 'Creating cases table...'
\i tables/030_cases.sql

-- =====================================================
-- SECTION 13: SUPPORTING TABLES
-- =====================================================

\echo 'Creating tags table...'
\i tables/031_tags.sql

\echo 'Creating record_tags table...'
\i tables/032_record_tags.sql

\echo 'Creating audit_logs table...'
\i tables/033_audit_logs.sql

\echo 'Creating notifications table...'
\i tables/034_notifications.sql

-- =====================================================
-- COMPLETION
-- =====================================================

\echo ''
\echo '====================================================='
\echo 'MAXCRM Database Schema Created Successfully!'
\echo '====================================================='
\echo ''
\echo 'Tables Created: 34'
\echo ''
\echo 'Core Features:'
\echo '  ✓ Multi-tenant architecture'
\echo '  ✓ Dynamic forms and fields (JSONB)'
\echo '  ✓ Workflow automation engine'
\echo '  ✓ Multi-level approval system'
\echo '  ✓ All tables have _id and _uuid'
\echo '  ✓ Comprehensive indexing'
\echo '  ✓ Audit logging'
\echo ''
\echo 'Next Steps:'
\echo '  1. Review table structures'
\echo '  2. Set up initial data (common_master types)'
\echo '  3. Configure workflows and approvals'
\echo '  4. Create custom modules and fields as needed'
\echo ''
\echo '====================================================='
