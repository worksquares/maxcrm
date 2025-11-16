# MAXCRM Database Tables Summary

## Quick Reference: All 34 Tables

### Core Tenant & Company (2)
| Table | Purpose | Key Features |
|-------|---------|--------------|
| **companies** | Multi-tenant organizations | Subscription, billing, settings (JSONB), feature flags |
| **common_master** | Universal lookup/master data | Type-based categorization, hierarchical, metadata (JSONB) |

### User Management (2)
| Table | Purpose | Key Features |
|-------|---------|--------------|
| **users** | User accounts and profiles | Manager hierarchy, roles, preferences (JSONB) |
| **roles** | Role definitions | Permissions matrix (JSONB), data access levels |

### CRM Core Entities (3)
| Table | Purpose | Key Features |
|-------|---------|--------------|
| **accounts** | Customer/company accounts | Hierarchical, addresses (JSONB), custom fields |
| **contacts** | Individual persons | Associated with accounts, reporting structure |
| **leads** | Potential customers | Lead scoring, conversion tracking, UTM params |

### Deals & Pipeline (3)
| Table | Purpose | Key Features |
|-------|---------|--------------|
| **deals** | Sales opportunities | Financial tracking, win/loss, competitors (JSONB) |
| **pipelines** | Sales pipeline configs | Multiple pipelines, settings (JSONB) |
| **pipeline_stages** | Stages within pipelines | Probability, required fields, automation rules |

### Products & Pricing (3)
| Table | Purpose | Key Features |
|-------|---------|--------------|
| **products** | Product catalog | Categories, specifications (JSONB), inventory |
| **price_books** | Price book definitions | Multi-currency, validity periods |
| **price_book_entries** | Prices within price books | Product-specific pricing, discounts |

### Quotes (2)
| Table | Purpose | Key Features |
|-------|---------|--------------|
| **quotes** | Sales quotes/proposals | Financial calculations, addresses (JSONB), status tracking |
| **quote_line_items** | Line items in quotes | Product references, pricing, discounts |

### Dynamic Forms & Fields (3)
| Table | Purpose | Key Features |
|-------|---------|--------------|
| **custom_modules** | Custom entity definitions | UI configs (JSONB), relationships (JSONB) |
| **custom_fields** | Dynamic field definitions | Validation (JSONB), options (JSONB), dependencies |
| **custom_records** | Records for custom modules | All data in JSONB, polymorphic |

### Workflow Engine (2)
| Table | Purpose | Key Features |
|-------|---------|--------------|
| **workflows** | Automation definitions | Triggers, conditions (JSONB), actions (JSONB) |
| **workflow_executions** | Execution history | Status, duration, input/output, errors |

### Approval System (3)
| Table | Purpose | Key Features |
|-------|---------|--------------|
| **approval_processes** | Process definitions | Entry criteria, steps (JSONB), actions |
| **approval_requests** | Approval instances | Status tracking, approval chain (JSONB) |
| **approval_steps** | Individual step responses | Delegation, reassignment, comments |

### Activities & Communications (3)
| Table | Purpose | Key Features |
|-------|---------|--------------|
| **activities** | Unified tasks/events/calls/emails | Polymorphic, recurrence, attendees (JSONB) |
| **notes** | Notes on any record | Polymorphic, privacy controls, pinning |
| **attachments** | File attachments | Multi-storage, versioning, polymorphic |

### Marketing (3)
| Table | Purpose | Key Features |
|-------|---------|--------------|
| **campaigns** | Marketing campaigns | Budget tracking, ROI, hierarchy |
| **campaign_members** | Leads/contacts in campaigns | Engagement tracking, conversion |
| **email_templates** | Reusable email templates | Merge fields (JSONB), HTML/text versions |

### Customer Support (1)
| Table | Purpose | Key Features |
|-------|---------|--------------|
| **cases** | Support tickets | SLA tracking, escalation, resolution metrics |

### Supporting Tables (4)
| Table | Purpose | Key Features |
|-------|---------|--------------|
| **tags** | Universal tags | Color coding, categories, usage tracking |
| **record_tags** | Tag-record junction | Polymorphic associations |
| **audit_logs** | Change tracking | Old/new values (JSONB), IP tracking |
| **notifications** | User notifications | Multi-channel, priority levels, read status |

---

## Standard Columns (All Tables)

Every table includes:
- `{table}_id` - SERIAL PRIMARY KEY
- `{table}_uuid` - UUID UNIQUE
- `company_id` - Multi-tenant isolation
- `is_active` - Soft delete flag
- `created_at` - Creation timestamp
- `updated_at` - Last update timestamp
- `created_by` - Creator UUID
- `updated_by` - Last updater UUID

---

## JSONB Columns by Table

### Configuration & Settings
- **companies**: settings, features, branding
- **users**: preferences, notification_settings, permissions
- **roles**: permissions, module_access
- **pipelines**: settings
- **pipeline_stages**: required_fields, automation_rules

### Address & Contact Info
- **companies**: address
- **accounts**: billing_address, shipping_address, social_links
- **contacts**: mailing_address, social_links
- **leads**: address, utm_params
- **quotes**: billing_address, shipping_address

### Custom & Dynamic Data
- **All core entities**: custom_fields
- **custom_modules**: relationships, settings, list_view_config, detail_view_config
- **custom_fields**: validation_rules, field_options, dependency_config, default_value_config
- **custom_records**: field_data (all custom field values)

### Workflow & Automation
- **workflows**: trigger_conditions, execution_criteria, actions, schedule_config
- **workflow_executions**: input_data, output_data, context_data, actions_executed, error_details
- **approval_processes**: entry_criteria, approval_steps, final_approval_actions, final_rejection_actions
- **approval_requests**: approval_chain, context_data

### Activities & Communications
- **activities**: attendees, email_to, email_cc, email_bcc, recurrence_config
- **attachments**: metadata
- **email_templates**: available_merge_fields
- **campaign_members**: links_clicked
- **notifications**: delivery_channels

### Arrays & Lists
- **All entities**: tags (JSONB array)
- **deals**: competitors
- **products**: tags
- **workflows**: actions (array)
- **custom_fields**: field_options (array)

### Audit & Tracking
- **audit_logs**: old_values, new_values, changed_fields, context_data

---

## Foreign Key Relationships

### Primary Hierarchies

```
companies
  ├── users
  ├── roles
  ├── accounts
  │   ├── contacts
  │   ├── deals
  │   └── cases
  ├── leads → converts to → accounts/contacts/deals
  ├── products
  ├── pipelines
  │   └── pipeline_stages
  ├── custom_modules
  │   ├── custom_fields
  │   └── custom_records
  ├── workflows
  │   └── workflow_executions
  └── approval_processes
      └── approval_requests
          └── approval_steps
```

### Polymorphic Relationships

Tables that can relate to ANY entity:
- activities (related_to_module, related_to_uuid)
- notes (related_to_module, related_to_uuid)
- attachments (related_to_module, related_to_uuid)
- notifications (related_to_module, related_to_uuid)
- audit_logs (module_name, record_uuid)
- record_tags (module_name, record_uuid)

---

## Common Master Types

Used in `common_master.type`:

### CRM Types
- lead_source, lead_status, account_type, industry, account_rating
- contact_role, deal_stage, deal_type, lost_reason, win_reason
- priority, task_status, task_type, event_type, call_outcome

### Product Types
- product_category, product_family, price_book, currency
- tax_type, discount_type, uom

### Support Types
- case_type, case_priority, case_status, case_origin
- ticket_category, sla_type

### Workflow Types
- workflow_status, approval_status, workflow_action_type

### General Types
- country, state, city, timezone, language
- file_category, note_type, tag_category

---

## Indexes Summary

### Every table has indexes on:
1. UUID column (unique index)
2. company_id
3. company_id + is_active
4. created_at (for most tables)

### Additional indexes on:
- Foreign keys
- Status fields
- Owner/assigned_to fields
- Email addresses (users, contacts, leads)
- Name fields (accounts, contacts, products)
- Date fields (due_date, close_date, start_date)
- Polymorphic fields (module_name, record_uuid)

### GIN indexes:
- JSONB columns where querying is needed
- custom_records.field_data
- (Add as needed based on query patterns)

---

## Database Statistics

- **Total Tables**: 34
- **Tables with JSONB**: 28 (82%)
- **Tables with UUIDs**: 34 (100%)
- **Polymorphic Tables**: 6
- **Junction Tables**: 3 (record_tags, campaign_members, price_book_entries)
- **Audit Tables**: 2 (audit_logs, workflow_executions)

---

## Query Examples

### Find all records tagged with "important"
```sql
SELECT rt.module_name, rt.record_uuid, t.tag_name
FROM record_tags rt
JOIN tags t ON t.tag_uuid = rt.tag_uuid
WHERE t.tag_name = 'important' AND rt.company_id = 1;
```

### Get all activities for a deal
```sql
SELECT * FROM activities
WHERE related_to_module = 'deals'
  AND related_to_uuid = 'deal-uuid-here'
  AND company_id = 1
ORDER BY created_at DESC;
```

### Find high-value deals in final stage
```sql
SELECT d.*, ps.stage_name
FROM deals d
JOIN pipeline_stages ps ON ps.stage_uuid = d.stage_uuid
WHERE d.amount > 50000
  AND ps.is_final = true
  AND d.company_id = 1;
```

### Query custom module records
```sql
SELECT
  record_name,
  field_data->>'project_name' as project_name,
  field_data->>'budget' as budget,
  field_data->>'status' as status
FROM custom_records
WHERE custom_module_uuid = 'projects-module-uuid'
  AND company_id = 1;
```

### Get pending approvals for a user
```sql
SELECT ar.*, aps.step_number, aps.step_name
FROM approval_requests ar
JOIN approval_steps aps ON aps.approval_request_uuid = ar.approval_request_uuid
WHERE aps.approver_uuid = 'user-uuid-here'
  AND aps.status = 'pending'
  AND ar.company_id = 1;
```

---

## Maintenance Queries

### Find unused tags
```sql
SELECT * FROM tags
WHERE usage_count = 0
  AND created_at < NOW() - INTERVAL '30 days'
  AND company_id = 1;
```

### Archive old audit logs
```sql
DELETE FROM audit_logs
WHERE created_at < NOW() - INTERVAL '1 year'
  AND company_id = 1;
```

### Check workflow failures
```sql
SELECT w.workflow_name, COUNT(*) as failure_count
FROM workflow_executions we
JOIN workflows w ON w.workflow_uuid = we.workflow_uuid
WHERE we.status = 'failed'
  AND we.created_at > NOW() - INTERVAL '7 days'
  AND we.company_id = 1
GROUP BY w.workflow_name
ORDER BY failure_count DESC;
```

---

## Performance Tips

1. **Use indexes wisely** - Already comprehensive indexes in place
2. **Partition large tables** - Consider partitioning audit_logs by date
3. **Archive old data** - Move old audit_logs, workflow_executions to archive tables
4. **Monitor JSONB queries** - Add GIN indexes where needed
5. **Use materialized views** - For complex reporting queries
6. **Regular VACUUM** - Keep tables optimized
7. **Connection pooling** - Use pgBouncer or similar

---

## Backup Strategy

### Daily backups:
- Full database backup
- Separate backup of audit_logs (can be large)

### Point-in-time recovery:
- Enable WAL archiving
- 30-day retention

### Critical tables (backup more frequently):
- companies
- users
- deals
- quotes
- approval_requests

---

## Migration Path from Other CRMs

### From Zoho CRM:
1. Export modules → Map to accounts/contacts/leads/deals
2. Custom modules → Use custom_modules + custom_fields
3. Layouts → Store in custom_modules.detail_view_config
4. Workflows → Convert to workflows table
5. Approvals → Map to approval_processes

### From Salesforce:
1. Standard objects → Direct mapping
2. Custom objects → Use custom_modules
3. Custom fields → Use custom_fields
4. Process Builder → Convert to workflows
5. Approval processes → Map to approval_processes

### From HubSpot:
1. Contacts/Companies → accounts/contacts
2. Deals → deals
3. Tickets → cases
4. Custom properties → custom_fields
5. Workflows → workflows

---

## License

This database schema is part of MAXCRM and follows the project license.

---

## Version

Schema Version: 1.0.0
Last Updated: 2025-11-16
PostgreSQL Version: 12+
