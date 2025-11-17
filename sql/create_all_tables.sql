-- =====================================================
-- MAXCRM Database Creation Script
-- PostgreSQL Complete CRM Schema - ULTRA VERSION
-- =====================================================
--
-- ULTRATHINK ANALYSIS RESULT:
-- Based on comprehensive analysis of Salesforce, Zoho CRM, and HubSpot
--
-- IMPROVEMENTS OVER PREVIOUS VERSION:
-- ✓ Separated activity types (tasks, events, calls, emails)
-- ✓ Complete Order-to-Cash cycle (orders, invoices, payments)
-- ✓ Contracts and service management
-- ✓ Territory and forecast management
-- ✓ Knowledge base and solutions
-- ✓ Asset tracking
-- ✓ Competitive intelligence
-- ✓ Field-level audit trail
-- ✓ Webhook integrations
-- ✓ Saved filters/views
--
-- TABLE COUNT: 66 tables
-- Traditional Enterprise CRM: ~180 tables
-- MAXCRM: 66 tables (64% reduction)
--
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- SECTION 1: CORE TENANT & COMPANY (2 tables)
-- =====================================================

\echo 'Creating companies table...'
\i tables/001_companies.sql

\echo 'Creating common_master table (replaces ~38 lookup tables)...'
\i tables/002_common_master.sql

-- =====================================================
-- SECTION 2: USER MANAGEMENT (3 tables)
-- =====================================================

\echo 'Creating users table...'
\i tables/003_users.sql

\echo 'Creating roles table...'
\i tables/004_roles.sql

\echo 'Creating teams table...'
\i tables/035_teams.sql

-- =====================================================
-- SECTION 3: REFERENCE DATA (4 tables)
-- Standard global reference tables
-- =====================================================

\echo 'Creating currencies table...'
\i tables/036_currencies.sql

\echo 'Creating countries table...'
\i tables/037_countries.sql

\echo 'Creating states table...'
\i tables/038_states.sql

\echo 'Creating timezones table...'
\i tables/039_timezones.sql

-- =====================================================
-- SECTION 4: PRODUCT MANAGEMENT (2 tables)
-- =====================================================

\echo 'Creating product_categories table...'
\i tables/052_product_categories.sql

\echo 'Creating products table...'
\i tables/011_products.sql

-- =====================================================
-- SECTION 5: CRM CORE ENTITIES (3 tables)
-- With flex columns and extracted address fields
-- =====================================================

\echo 'Creating accounts table (with flex columns)...'
\i tables/005_accounts.sql

\echo 'Creating contacts table (with flex columns)...'
\i tables/006_contacts.sql

\echo 'Creating leads table (with flex columns)...'
\i tables/007_leads.sql

-- =====================================================
-- SECTION 6: TERRITORY MANAGEMENT (3 tables)
-- =====================================================

\echo 'Creating territories table...'
\i tables/053_territories.sql

\echo 'Creating territory_assignments table...'
\i tables/054_territory_assignments.sql

\echo 'Creating lead_sources table...'
\i tables/061_lead_sources.sql

-- =====================================================
-- SECTION 7: DEALS & PIPELINE (3 tables)
-- =====================================================

\echo 'Creating pipelines table...'
\i tables/009_pipelines.sql

\echo 'Creating pipeline_stages table...'
\i tables/010_pipeline_stages.sql

\echo 'Creating deals table (with flex columns)...'
\i tables/008_deals.sql

-- =====================================================
-- SECTION 8: TEAM ASSIGNMENTS (2 tables)
-- Junction tables for team-based access
-- =====================================================

\echo 'Creating account_team_members table...'
\i tables/040_account_team_members.sql

\echo 'Creating deal_team_members table...'
\i tables/041_deal_team_members.sql

-- =====================================================
-- SECTION 9: FORECASTING (1 table)
-- =====================================================

\echo 'Creating forecasts table...'
\i tables/055_forecasts.sql

-- =====================================================
-- SECTION 10: PRICING (2 tables)
-- =====================================================

\echo 'Creating price_books table...'
\i tables/012_price_books.sql

\echo 'Creating price_book_entries table...'
\i tables/013_price_book_entries.sql

-- =====================================================
-- SECTION 11: QUOTES (2 tables)
-- =====================================================

\echo 'Creating quotes table...'
\i tables/014_quotes.sql

\echo 'Creating quote_line_items table...'
\i tables/015_quote_line_items.sql

-- =====================================================
-- SECTION 12: ORDERS (2 tables)
-- =====================================================

\echo 'Creating orders table...'
\i tables/046_orders.sql

\echo 'Creating order_line_items table...'
\i tables/047_order_line_items.sql

-- =====================================================
-- SECTION 13: INVOICES & PAYMENTS (3 tables)
-- =====================================================

\echo 'Creating invoices table...'
\i tables/048_invoices.sql

\echo 'Creating invoice_line_items table...'
\i tables/049_invoice_line_items.sql

\echo 'Creating payments table...'
\i tables/050_payments.sql

-- =====================================================
-- SECTION 14: CONTRACTS (1 table)
-- =====================================================

\echo 'Creating contracts table...'
\i tables/051_contracts.sql

-- =====================================================
-- SECTION 15: SERVICE MANAGEMENT (4 tables)
-- =====================================================

\echo 'Creating service_contracts table...'
\i tables/059_service_contracts.sql

\echo 'Creating entitlements table...'
\i tables/060_entitlements.sql

\echo 'Creating assets table...'
\i tables/058_assets.sql

\echo 'Creating solutions table...'
\i tables/057_solutions.sql

-- =====================================================
-- SECTION 16: COMPETITIVE INTELLIGENCE (2 tables)
-- =====================================================

\echo 'Creating competitors table...'
\i tables/062_competitors.sql

\echo 'Creating deal_competitors table...'
\i tables/063_deal_competitors.sql

-- =====================================================
-- SECTION 17: ACTIVITIES - SEPARATED BY TYPE (4 tables)
-- Replacing generic activities table with specific types
-- =====================================================

\echo 'Creating tasks table...'
\i tables/042_tasks.sql

\echo 'Creating events table...'
\i tables/043_events.sql

\echo 'Creating calls table...'
\i tables/044_calls.sql

\echo 'Creating emails table...'
\i tables/045_emails.sql

-- =====================================================
-- SECTION 18: ACTIVITIES - LEGACY (3 tables)
-- Keeping original unified activities table for backward compatibility
-- =====================================================

\echo 'Creating activities table (legacy unified)...'
\i tables/024_activities.sql

\echo 'Creating notes table...'
\i tables/025_notes.sql

\echo 'Creating attachments table...'
\i tables/026_attachments.sql

-- =====================================================
-- SECTION 19: KNOWLEDGE BASE (1 table)
-- =====================================================

\echo 'Creating knowledge_articles table...'
\i tables/056_knowledge_articles.sql

-- =====================================================
-- SECTION 20: DYNAMIC FORMS & FIELDS (3 tables)
-- =====================================================

\echo 'Creating custom_modules table...'
\i tables/016_custom_modules.sql

\echo 'Creating custom_fields table...'
\i tables/017_custom_fields.sql

\echo 'Creating custom_records table (JSONB field storage)...'
\i tables/018_custom_records.sql

-- =====================================================
-- SECTION 21: WORKFLOW ENGINE (2 tables)
-- =====================================================

\echo 'Creating workflows table...'
\i tables/019_workflows.sql

\echo 'Creating workflow_executions table...'
\i tables/020_workflow_executions.sql

-- =====================================================
-- SECTION 22: APPROVAL SYSTEM (3 tables)
-- =====================================================

\echo 'Creating approval_processes table...'
\i tables/021_approval_processes.sql

\echo 'Creating approval_requests table...'
\i tables/022_approval_requests.sql

\echo 'Creating approval_steps table...'
\i tables/023_approval_steps.sql

-- =====================================================
-- SECTION 23: MARKETING (3 tables)
-- =====================================================

\echo 'Creating campaigns table...'
\i tables/027_campaigns.sql

\echo 'Creating campaign_members table...'
\i tables/028_campaign_members.sql

\echo 'Creating email_templates table...'
\i tables/029_email_templates.sql

-- =====================================================
-- SECTION 24: CUSTOMER SUPPORT (1 table)
-- =====================================================

\echo 'Creating cases table...'
\i tables/030_cases.sql

-- =====================================================
-- SECTION 25: SUPPORTING TABLES (4 tables)
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
-- SECTION 26: SYSTEM & INTEGRATION (3 tables)
-- =====================================================

\echo 'Creating field_history table...'
\i tables/064_field_history.sql

\echo 'Creating webhooks table...'
\i tables/065_webhooks.sql

\echo 'Creating saved_filters table...'
\i tables/066_saved_filters.sql

-- =====================================================
-- COMPLETION
-- =====================================================

\echo ''
\echo '====================================================='
\echo 'MAXCRM Database Schema Created Successfully!'
\echo '====================================================='
\echo ''
\echo 'Tables Created: 66'
\echo ''
\echo 'TABLE BREAKDOWN:'
\echo '  • Core & Company: 2'
\echo '  • User Management: 3 (users, roles, teams)'
\echo '  • Reference Data: 4 (currencies, countries, states, timezones)'
\echo '  • Product Management: 2 (categories, products)'
\echo '  • CRM Entities: 3 (accounts, contacts, leads)'
\echo '  • Territory Management: 3 (territories, assignments, lead sources)'
\echo '  • Deals & Pipeline: 3'
\echo '  • Team Assignments: 2'
\echo '  • Forecasting: 1'
\echo '  • Pricing: 2 (price books, entries)'
\echo '  • Quotes: 2'
\echo '  • Orders: 2 (Order-to-Cash cycle)'
\echo '  • Invoices & Payments: 3'
\echo '  • Contracts: 1'
\echo '  • Service Management: 4 (contracts, entitlements, assets, solutions)'
\echo '  • Competitive Intelligence: 2'
\echo '  • Activities (Separated): 4 (tasks, events, calls, emails)'
\echo '  • Activities (Legacy): 3 (activities, notes, attachments)'
\echo '  • Knowledge Base: 1'
\echo '  • Dynamic Forms: 3'
\echo '  • Workflows: 2'
\echo '  • Approvals: 3'
\echo '  • Marketing: 3'
\echo '  • Support: 1'
\echo '  • Supporting: 4'
\echo '  • System & Integration: 3 (field_history, webhooks, saved_filters)'
\echo ''
\echo 'KEY FEATURES:'
\echo '  ✓ Separate activity types (not generic activities table)'
\echo '  ✓ Complete Order-to-Cash: Orders → Invoices → Payments'
\echo '  ✓ Territory & Forecast management'
\echo '  ✓ Service management: Contracts, Entitlements, Assets'
\echo '  ✓ Knowledge base with version control'
\echo '  ✓ Competitive intelligence tracking'
\echo '  ✓ Field-level history (separate from audit_logs)'
\echo '  ✓ Webhook integrations'
\echo '  ✓ User-saved filters and views'
\echo '  ✓ Flex columns for high-query custom fields'
\echo '  ✓ Extracted address fields (country, state, city)'
\echo '  ✓ JSONB for display-only/config data'
\echo ''
\echo 'COMPARISON:'
\echo '  Traditional Enterprise CRM: ~180 tables'
\echo '  Salesforce Standard Objects: ~150 objects'
\echo '  Zoho CRM Modules: ~50+ modules'
\echo '  MAXCRM: 66 tables (64% reduction)'
\echo ''
\echo 'COMPETITIVE ADVANTAGES vs Zoho/Salesforce:'
\echo '  ✓ Simpler schema but comprehensive functionality'
\echo '  ✓ Better performance (indexed extracted columns)'
\echo '  ✓ Flexible (JSONB + flex columns)'
\echo '  ✓ All activity types properly separated'
\echo '  ✓ Complete financial tracking (Orders/Invoices/Payments)'
\echo '  ✓ Built-in territory and forecast management'
\echo '  ✓ Service asset tracking out-of-box'
\echo ''
\echo 'Next Steps:'
\echo '  1. Populate reference data (currencies, countries, states, timezones)'
\echo '  2. Populate common_master with lookup values'
\echo '  3. Create product categories and products'
\echo '  4. Configure territories and assign users'
\echo '  5. Configure workflows and approvals'
\echo '  6. Set up webhooks for integrations'
\echo '  7. Create knowledge base articles'
\echo '  8. Configure saved filters for users'
\echo ''
\echo '====================================================='
