-- =====================================================
-- MAXCRM Database Creation Script
-- PostgreSQL Complete CRM Schema - IMPROVED VERSION
-- =====================================================
--
-- This script creates all tables for the MAXCRM system
-- Execute tables in order to maintain foreign key dependencies
--
-- IMPROVEMENTS IN THIS VERSION:
-- ✓ Flex columns for high-query custom fields
-- ✓ Extract commonly queried address fields as columns
-- ✓ Keep JSONB for display-only/rare-query data
-- ✓ Better performance for common WHERE/JOIN queries
-- ✓ Still uses common_master for lookups (UUID references)
-- ✓ All tables have _id and _uuid columns
--
-- TABLE REDUCTION: ~73 tables eliminated (68% reduction)
-- Traditional CRM: ~108 tables
-- MAXCRM: 35 tables (34 + common_master replaces ~45 lookup tables)
--
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- SECTION 1: CORE TENANT & COMPANY (2 tables)
-- =====================================================

\echo 'Creating companies table...'
\i tables/001_companies.sql

\echo 'Creating common_master table (replaces ~45 lookup tables)...'
\i tables/002_common_master.sql

-- =====================================================
-- SECTION 2: USER MANAGEMENT (2 tables)
-- =====================================================

\echo 'Creating users table...'
\i tables/003_users.sql

\echo 'Creating roles table...'
\i tables/004_roles.sql

-- =====================================================
-- SECTION 3: CRM CORE ENTITIES (3 tables)
-- With flex columns and extracted address fields
-- =====================================================

\echo 'Creating accounts table (with flex columns)...'
\i tables/005_accounts.sql

\echo 'Creating contacts table (with flex columns)...'
\i tables/006_contacts.sql

\echo 'Creating leads table (with flex columns)...'
\i tables/007_leads.sql

-- =====================================================
-- SECTION 4: DEALS & PIPELINE (3 tables)
-- =====================================================

\echo 'Creating deals table (with flex columns)...'
\i tables/008_deals.sql

\echo 'Creating pipelines table...'
\i tables/009_pipelines.sql

\echo 'Creating pipeline_stages table...'
\i tables/010_pipeline_stages.sql

-- =====================================================
-- SECTION 5: PRODUCTS & PRICING (3 tables)
-- =====================================================

\echo 'Creating products table...'
\i tables/011_products.sql

\echo 'Creating price_books table...'
\i tables/012_price_books.sql

\echo 'Creating price_book_entries table...'
\i tables/013_price_book_entries.sql

-- =====================================================
-- SECTION 6: QUOTES (2 tables)
-- =====================================================

\echo 'Creating quotes table...'
\i tables/014_quotes.sql

\echo 'Creating quote_line_items table...'
\i tables/015_quote_line_items.sql

-- =====================================================
-- SECTION 7: DYNAMIC FORMS & FIELDS (3 tables)
-- Custom modules with JSONB storage
-- =====================================================

\echo 'Creating custom_modules table...'
\i tables/016_custom_modules.sql

\echo 'Creating custom_fields table...'
\i tables/017_custom_fields.sql

\echo 'Creating custom_records table (JSONB field storage)...'
\i tables/018_custom_records.sql

-- =====================================================
-- SECTION 8: WORKFLOW ENGINE (2 tables)
-- =====================================================

\echo 'Creating workflows table...'
\i tables/019_workflows.sql

\echo 'Creating workflow_executions table...'
\i tables/020_workflow_executions.sql

-- =====================================================
-- SECTION 9: APPROVAL SYSTEM (3 tables)
-- =====================================================

\echo 'Creating approval_processes table...'
\i tables/021_approval_processes.sql

\echo 'Creating approval_requests table...'
\i tables/022_approval_requests.sql

\echo 'Creating approval_steps table...'
\i tables/023_approval_steps.sql

-- =====================================================
-- SECTION 10: ACTIVITIES & COMMUNICATIONS (3 tables)
-- =====================================================

\echo 'Creating activities table (unified)...'
\i tables/024_activities.sql

\echo 'Creating notes table...'
\i tables/025_notes.sql

\echo 'Creating attachments table...'
\i tables/026_attachments.sql

-- =====================================================
-- SECTION 11: MARKETING (3 tables)
-- =====================================================

\echo 'Creating campaigns table...'
\i tables/027_campaigns.sql

\echo 'Creating campaign_members table...'
\i tables/028_campaign_members.sql

\echo 'Creating email_templates table...'
\i tables/029_email_templates.sql

-- =====================================================
-- SECTION 12: CUSTOMER SUPPORT (1 table)
-- =====================================================

\echo 'Creating cases table...'
\i tables/030_cases.sql

-- =====================================================
-- SECTION 13: SUPPORTING TABLES (4 tables)
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
\echo 'IMPROVEMENTS:'
\echo '  ✓ Flex columns for frequently queried custom fields'
\echo '  ✓ Extracted address fields (country, state, city)'
\echo '  ✓ common_master UUIDs used in JOINs (indexed)'
\echo '  ✓ JSONB for display-only/config data'
\echo '  ✓ Better query performance'
\echo ''
\echo 'KEY FEATURES:'
\echo '  ✓ Multi-tenant architecture'
\echo '  ✓ All tables have _id and _uuid'
\echo '  ✓ Dynamic forms via custom_modules'
\echo '  ✓ Workflow automation engine'
\echo '  ✓ Multi-level approval system'
\echo '  ✓ Comprehensive indexing'
\echo '  ✓ Full audit trail'
\echo ''
\echo 'EFFICIENCY:'
\echo '  ✓ ~73 tables eliminated (68% reduction)'
\echo '  ✓ Traditional CRM: ~108 tables'
\echo '  ✓ MAXCRM: 35 tables'
\echo ''
\echo 'FLEX COLUMNS (on core entities):'
\echo '  • custom_text_1, custom_text_2, custom_text_3'
\echo '  • custom_number_1, custom_number_2'
\echo '  • custom_date_1, custom_date_2'
\echo '  • custom_boolean_1, custom_boolean_2'
\echo '  • custom_lookup_1_uuid, custom_lookup_2_uuid'
\echo ''
\echo 'Next Steps:'
\echo '  1. Populate common_master with lookup values'
\echo '  2. Configure workflows and approvals'
\echo '  3. Create custom modules as needed'
\echo '  4. Map important custom fields to flex columns'
\echo ''
\echo '====================================================='
