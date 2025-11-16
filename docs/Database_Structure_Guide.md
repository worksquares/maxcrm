# MAXCRM Database Structure Guide

## Overview

This document describes the complete PostgreSQL database structure for MAXCRM - a modern SaaS CRM system designed to be better than Zoho CRM but without unnecessary complexity.

## Key Features

### 1. Multi-Tenancy
- All tables include `company_id` for data isolation
- Each company can have custom configurations
- Row-level security ready

### 2. UUID Primary Keys
- Every table has both `{table}_id` (SERIAL) and `{table}_uuid` (UUID)
- UUIDs used for external references and APIs
- Integer IDs for internal operations and performance

### 3. Dynamic Forms & Fields
- Custom modules can be created without schema changes
- Custom fields stored in JSONB columns
- Field definitions stored in `custom_fields` table
- Record data stored in `custom_records` table with JSONB

### 4. Workflow Automation
- Trigger-based workflow engine
- Support for on_create, on_update, on_field_change, scheduled triggers
- Action configurations stored as JSON
- Complete execution history and logging

### 5. Multi-Level Approvals
- Configurable approval processes
- Sequential and parallel approvals
- Delegation and reassignment support
- Complete audit trail

### 6. Comprehensive Audit Trail
- All tables have created_at, updated_at, created_by, updated_by
- Separate audit_logs table for detailed change tracking
- Old and new values stored as JSON

---

## Database Structure

### Total Tables: 34

---

## 1. Core Tenant & Company (2 tables)

### companies
Master table for multi-tenant organizations
- Subscription and billing information
- Company settings and features (JSONB)
- Branding configuration
- Storage and user limits

### common_master
Universal lookup/master data table
- Replaces hundreds of lookup tables
- Hierarchical (parent_uuid for nested values)
- Type-based categorization
- Metadata stored as JSONB
- Examples: lead_source, industry, deal_stage, priority, etc.

**Common Types:**
- CRM: lead_source, lead_status, account_type, industry, deal_stage, priority
- Products: product_category, currency, tax_type, discount_type
- Support: case_type, case_priority, case_status
- Workflow: workflow_status, approval_status
- General: country, state, city, timezone, language

---

## 2. User Management (2 tables)

### users
User accounts and profiles
- Personal and professional information
- Manager hierarchy (manager_uuid)
- Role-based access control
- User preferences and settings (JSONB)
- Password and authentication management

### roles
Role definitions with permissions
- Permission matrix (JSONB)
- Module-level access controls
- Data access levels: own, team, department, all, custom
- Role hierarchy support

---

## 3. CRM Core Entities (3 tables)

### accounts
Customer/company accounts
- Business information and classification
- Billing and shipping addresses (JSONB)
- Parent-child account relationships
- Ownership and team assignment
- Custom fields support (JSONB)

### contacts
Individual contact persons
- Associated with accounts
- Reporting hierarchy (reports_to_uuid)
- Communication preferences
- Email opt-out and GDPR compliance
- Social media links (JSONB)

### leads
Potential customers before conversion
- Lead scoring and qualification
- Conversion tracking to account/contact/deal
- UTM parameters for source tracking (JSONB)
- Lead nurturing support

---

## 4. Deals & Pipeline (3 tables)

### deals
Sales opportunities
- Associated with accounts, contacts, and leads
- Financial details (amount, discount, tax)
- Win/loss tracking with reasons
- Competitor information (JSONB)
- Custom fields (JSONB)

### pipelines
Sales pipeline configurations
- Multiple pipelines support
- Pipeline-specific settings (JSONB)
- Default pipeline designation

### pipeline_stages
Stages within pipelines
- Stage probability and outcomes
- Required fields per stage (JSONB)
- Automation rules per stage (JSONB)
- Closed won/lost flags

---

## 5. Products & Pricing (3 tables)

### products
Product catalog
- Product categorization
- Pricing and inventory tracking
- Product specifications (JSONB)
- Custom fields (JSONB)
- Support for: standard, service, subscription, bundle

### price_books
Price books for market segments
- Multi-currency support
- Validity periods
- Default price book

### price_book_entries
Product prices within price books
- Unit prices and discounts
- Validity date ranges
- One product per price book

---

## 6. Quotes (2 tables)

### quotes
Sales quotes and proposals
- Associated with deals/accounts/contacts
- Financial calculations (subtotal, tax, discount, total)
- Billing and shipping addresses (JSONB)
- Status tracking: draft, sent, viewed, accepted, rejected, expired
- Custom fields (JSONB)

### quote_line_items
Line items within quotes
- Product references
- Quantity and pricing
- Line-level discounts
- Tax calculations

---

## 7. Dynamic Forms & Fields (3 tables)

### custom_modules
Custom module/entity definitions
- Module configuration and settings
- UI layout configurations (JSONB)
- Relationship definitions (JSONB)
- API naming and table mapping

### custom_fields
Dynamic field definitions
- Field types: text, number, date, picklist, lookup, formula, etc.
- Validation rules (JSONB)
- Field options for picklists (JSONB)
- Visibility and editability controls
- Field dependencies (JSONB)

### custom_records
Records for custom modules
- All field data stored as JSONB
- Ownership and status tracking
- Full audit trail
- Tag support (JSONB)

---

## 8. Workflow Engine (2 tables)

### workflows
Workflow automation definitions
- Trigger types: on_create, on_update, on_delete, on_field_change, scheduled, manual
- Trigger conditions (JSONB)
- Actions to execute (JSONB array)
- Schedule configuration for scheduled workflows

**Action Types:**
- Field updates
- Email notifications
- Task creation
- Webhooks
- Custom functions

### workflow_executions
Workflow execution history
- Execution status and duration
- Input/output data (JSONB)
- Actions executed with results
- Error handling and retry tracking

---

## 9. Approval System (3 tables)

### approval_processes
Multi-step approval process definitions
- Entry criteria for triggering (JSONB)
- Approval steps configuration (JSONB array)
- Final approval/rejection actions
- Recall and comment settings

### approval_requests
Individual approval instances
- Current step tracking
- Overall status
- Complete approval chain (JSONB)
- Recall functionality

### approval_steps
Individual step responses
- Approver assignment
- Response tracking (approved/rejected)
- Delegation support
- Comments and reasons

---

## 10. Activities & Communications (3 tables)

### activities
Unified activity table
- Types: task, event, call, email, meeting, note
- Related to any module (polymorphic)
- Contact and account associations
- Recurrence support (JSONB)
- Event attendees (JSONB)
- Email details (to, cc, bcc as JSONB)
- Custom fields (JSONB)

### notes
Notes attached to any record
- Polymorphic associations
- Privacy controls
- Pinning support
- Tag support

### attachments
File attachments for any record
- Multi-storage support (local, S3, Azure, GCS)
- Version control
- Image metadata
- Access control and expiry
- Tag support

---

## 11. Marketing (3 tables)

### campaigns
Marketing campaigns
- Budget and cost tracking
- Expected vs actual metrics
- Campaign hierarchy (parent campaigns)
- ROI tracking

### campaign_members
Leads/contacts in campaigns
- Polymorphic member support
- Status and engagement tracking
- Email opens and clicks
- Conversion tracking

### email_templates
Reusable email templates
- HTML and plain text versions
- Merge fields support (JSONB)
- Module-specific templates
- Categorization

---

## 12. Customer Support (1 table)

### cases
Customer support cases
- Multi-channel origin tracking
- SLA tracking and violations
- Assignment and escalation
- Resolution tracking
- Response and resolution time metrics

---

## 13. Supporting Tables (4 tables)

### tags
Universal tagging system
- Color coding
- Category support
- Usage tracking

### record_tags
Junction table for tags
- Polymorphic record associations
- Quick tag filtering

### audit_logs
Comprehensive audit trail
- All record changes tracked
- Old vs new values (JSONB)
- IP and user agent tracking
- Export and view tracking

### notifications
User notifications
- Multiple notification types
- Priority levels
- Read/dismissed status
- Multi-channel delivery (JSONB)
- Related record associations

---

## Common Patterns

### 1. Polymorphic Relationships
Many tables support polymorphic associations using:
- `related_to_module` (VARCHAR) - module name
- `related_to_uuid` (UUID) - record UUID
- `related_to_name` (VARCHAR) - cached display name

**Used in:**
- activities
- notes
- attachments
- notifications
- audit_logs
- record_tags

### 2. JSONB Usage

#### Custom Fields
```json
{
  "field_api_name_1": "value1",
  "field_api_name_2": "value2",
  "custom_dropdown": "option_a"
}
```

#### Settings/Configuration
```json
{
  "timezone": "America/New_York",
  "currency": "USD",
  "date_format": "MM/DD/YYYY",
  "features": ["workflows", "approvals", "custom_modules"]
}
```

#### Workflow Actions
```json
[
  {
    "order": 1,
    "type": "field_update",
    "config": {
      "field": "status",
      "value": "approved"
    }
  },
  {
    "order": 2,
    "type": "email",
    "config": {
      "template_uuid": "...",
      "recipients": ["owner", "creator"]
    }
  }
]
```

#### Approval Steps
```json
[
  {
    "step": 1,
    "name": "Manager Approval",
    "approvers_type": "role",
    "approvers": ["manager_role_uuid"],
    "approval_type": "any_one"
  },
  {
    "step": 2,
    "name": "Director Approval",
    "approvers_type": "user",
    "approvers": ["user_uuid_1", "user_uuid_2"],
    "approval_type": "all"
  }
]
```

### 3. Standard Columns

Every table includes:
- `{table}_id` - SERIAL PRIMARY KEY
- `{table}_uuid` - UUID UNIQUE (for external references)
- `company_id` - Multi-tenant isolation
- `is_active` - Soft delete support
- `created_at` - Creation timestamp
- `updated_at` - Last update timestamp
- `created_by` - User UUID who created
- `updated_by` - User UUID who last updated

### 4. Indexing Strategy

All tables include indexes for:
- UUID columns
- company_id
- company_id + is_active
- Foreign keys
- Commonly queried fields
- GIN indexes for JSONB columns (where needed)

---

## Comparison with Zoho CRM

### Better Than Zoho:
1. **True Multi-Tenancy** - Built-in from ground up
2. **Better Workflow Engine** - More flexible with JSON configuration
3. **Unified Activity Model** - Single table vs multiple tables
4. **Better Custom Fields** - JSONB storage is more flexible
5. **Proper Approval System** - Multi-level with delegation
6. **Better Audit Trail** - Comprehensive change tracking
7. **Polymorphic Relationships** - Attachments/notes work on any record

### Simpler Than Zoho:
1. **No Module Explosion** - Dynamic modules instead of 50+ tables
2. **Unified Master Data** - common_master instead of 100+ lookup tables
3. **Cleaner Schema** - 34 tables vs 200+ in Zoho
4. **No Redundancy** - Single source of truth

### Similar to Zoho:
1. **Core Entities** - Accounts, Contacts, Leads, Deals
2. **Sales Pipeline** - Customizable stages
3. **Products & Quotes** - Full product catalog
4. **Campaigns** - Marketing automation basics
5. **Cases** - Customer support

---

## Usage Examples

### Creating a Custom Module

```sql
-- 1. Create the module
INSERT INTO custom_modules (module_name, module_label, api_name, company_id)
VALUES ('Projects', 'Project', 'projects', 1);

-- 2. Add custom fields
INSERT INTO custom_fields (
  field_name, field_label, field_api_name,
  module_name, field_type, data_type,
  company_id
)
VALUES
  ('Project Name', 'Project Name', 'project_name', 'Projects', 'text', 'string', 1),
  ('Start Date', 'Start Date', 'start_date', 'Projects', 'date', 'date', 1),
  ('Budget', 'Budget', 'budget', 'Projects', 'currency', 'decimal', 1),
  ('Status', 'Status', 'status', 'Projects', 'picklist', 'string', 1);

-- 3. Create records
INSERT INTO custom_records (
  custom_module_uuid, record_name, field_data, company_id
)
VALUES (
  'module-uuid-here',
  'Website Redesign',
  '{
    "project_name": "Website Redesign",
    "start_date": "2025-01-01",
    "budget": 50000.00,
    "status": "in_progress"
  }'::jsonb,
  1
);
```

### Creating a Workflow

```sql
INSERT INTO workflows (
  workflow_name, module_name, trigger_type,
  trigger_conditions, actions, company_id
)
VALUES (
  'Auto-assign High Priority Leads',
  'leads',
  'on_create',
  '{
    "criteria": {
      "priority": "high",
      "lead_source": "website"
    }
  }'::jsonb,
  '[
    {
      "type": "field_update",
      "config": {"field": "owner_uuid", "value": "sales_manager_uuid"}
    },
    {
      "type": "email",
      "config": {"template": "new_high_priority_lead"}
    }
  ]'::jsonb,
  1
);
```

### Creating an Approval Process

```sql
INSERT INTO approval_processes (
  process_name, module_name, entry_criteria,
  approval_steps, company_id
)
VALUES (
  'Deal Approval > $10K',
  'deals',
  '{"amount": {"operator": ">", "value": 10000}}'::jsonb,
  '[
    {
      "step": 1,
      "name": "Sales Manager",
      "approvers_type": "role",
      "approvers": ["sales_manager_role_uuid"]
    },
    {
      "step": 2,
      "name": "VP Sales",
      "approvers_type": "user",
      "approvers": ["vp_sales_user_uuid"]
    }
  ]'::jsonb,
  1
);
```

---

## Installation

### 1. Create Database
```bash
createdb maxcrm
```

### 2. Run Schema
```bash
cd sql
psql -d maxcrm -f create_all_tables.sql
```

### 3. Verify
```sql
SELECT COUNT(*) FROM information_schema.tables
WHERE table_schema = 'public';
-- Should return 34
```

---

## Best Practices

### 1. Always Use UUIDs for External References
- APIs should use UUIDs, not integer IDs
- Foreign keys between companies should use UUIDs
- Share UUIDs with third-party integrations

### 2. Leverage JSONB for Flexibility
- Use custom_fields for user-defined data
- Store configuration as JSON
- Use JSONB operators for querying

### 3. Multi-Tenancy
- Always filter by company_id
- Use Row Level Security (RLS) in production
- Never expose data across companies

### 4. Audit Everything
- Use triggers to populate audit_logs
- Track field-level changes
- Store old and new values

### 5. Workflow Best Practices
- Keep workflows simple and focused
- Test trigger conditions thoroughly
- Monitor workflow_executions for errors
- Use retry logic for external calls

---

## Next Steps

1. **Set Up Common Master Data**
   - Populate lead sources, statuses, industries
   - Configure pipeline stages
   - Set up priority levels

2. **Create Default Workflows**
   - Lead assignment rules
   - Deal stage automation
   - Email notifications

3. **Configure Approval Processes**
   - Deal approvals by amount
   - Quote approvals
   - Discount approvals

4. **Build Custom Modules**
   - Create modules specific to your business
   - Define custom fields
   - Set up relationships

5. **Implement Business Logic**
   - Create stored procedures for complex operations
   - Set up triggers for automatic calculations
   - Build views for reporting

---

## Support

For questions or issues:
- Review table comments in SQL files
- Check JSONB column documentation
- Refer to PostgreSQL JSONB documentation
