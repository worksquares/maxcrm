-- MAXCRM Database Seed Data
-- Sample data for development and testing

-- Insert sample users
-- Note: Password is 'password123' hashed with bcrypt (rounds=10)
INSERT INTO users (id, email, password_hash, first_name, last_name, role) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'admin@maxcrm.example.com', '$2b$10$rQ3qYz0Z1lqYZ3ZqYz0Z1.qYz0Z1lqYz0Z1lqYz0Z1lqYz0Z1lqYz', 'Admin', 'User', 'admin'),
  ('550e8400-e29b-41d4-a716-446655440002', 'manager@maxcrm.example.com', '$2b$10$rQ3qYz0Z1lqYZ3ZqYz0Z1.qYz0Z1lqYz0Z1lqYz0Z1lqYz0Z1lqYz', 'Sales', 'Manager', 'manager'),
  ('550e8400-e29b-41d4-a716-446655440003', 'sales@maxcrm.example.com', '$2b$10$rQ3qYz0Z1lqYZ3ZqYz0Z1.qYz0Z1lqYz0Z1lqYz0Z1lqYz0Z1lqYz', 'John', 'Sales', 'sales_rep');

-- Insert sample companies
INSERT INTO companies (id, name, website, industry, size) VALUES
  ('650e8400-e29b-41d4-a716-446655440001', 'Acme Corporation', 'https://acme.example.com', 'Technology', '51-200'),
  ('650e8400-e29b-41d4-a716-446655440002', 'Global Industries', 'https://global.example.com', 'Manufacturing', '201+'),
  ('650e8400-e29b-41d4-a716-446655440003', 'Tech Innovators Inc', 'https://techinnovators.example.com', 'Software', '11-50'),
  ('650e8400-e29b-41d4-a716-446655440004', 'Green Energy Solutions', 'https://greenenergy.example.com', 'Energy', '51-200'),
  ('650e8400-e29b-41d4-a716-446655440005', 'FinTech Dynamics', 'https://fintech.example.com', 'Financial Services', '11-50');

-- Insert sample contacts
INSERT INTO contacts (id, first_name, last_name, email, phone, company_id) VALUES
  ('750e8400-e29b-41d4-a716-446655440001', 'John', 'Doe', 'john.doe@acme.example.com', '+1-555-0101', '650e8400-e29b-41d4-a716-446655440001'),
  ('750e8400-e29b-41d4-a716-446655440002', 'Jane', 'Smith', 'jane.smith@global.example.com', '+1-555-0102', '650e8400-e29b-41d4-a716-446655440002'),
  ('750e8400-e29b-41d4-a716-446655440003', 'Bob', 'Johnson', 'bob.johnson@techinnovators.example.com', '+1-555-0103', '650e8400-e29b-41d4-a716-446655440003'),
  ('750e8400-e29b-41d4-a716-446655440004', 'Alice', 'Williams', 'alice.williams@acme.example.com', '+1-555-0104', '650e8400-e29b-41d4-a716-446655440001'),
  ('750e8400-e29b-41d4-a716-446655440005', 'Charlie', 'Brown', 'charlie.brown@greenenergy.example.com', '+1-555-0105', '650e8400-e29b-41d4-a716-446655440004'),
  ('750e8400-e29b-41d4-a716-446655440006', 'Diana', 'Garcia', 'diana.garcia@fintech.example.com', '+1-555-0106', '650e8400-e29b-41d4-a716-446655440005'),
  ('750e8400-e29b-41d4-a716-446655440007', 'Edward', 'Martinez', 'edward.martinez@global.example.com', '+1-555-0107', '650e8400-e29b-41d4-a716-446655440002'),
  ('750e8400-e29b-41d4-a716-446655440008', 'Fiona', 'Davis', 'fiona.davis@techinnovators.example.com', '+1-555-0108', '650e8400-e29b-41d4-a716-446655440003');

-- Insert sample deals
INSERT INTO deals (id, title, value, stage, contact_id, company_id, expected_close_date) VALUES
  ('850e8400-e29b-41d4-a716-446655440001', 'Enterprise Software License', 50000.00, 'proposal', '750e8400-e29b-41d4-a716-446655440001', '650e8400-e29b-41d4-a716-446655440001', CURRENT_TIMESTAMP + INTERVAL '30 days'),
  ('850e8400-e29b-41d4-a716-446655440002', 'Consulting Services', 25000.00, 'negotiation', '750e8400-e29b-41d4-a716-446655440002', '650e8400-e29b-41d4-a716-446655440002', CURRENT_TIMESTAMP + INTERVAL '15 days'),
  ('850e8400-e29b-41d4-a716-446655440003', 'Cloud Infrastructure Setup', 75000.00, 'qualified', '750e8400-e29b-41d4-a716-446655440003', '650e8400-e29b-41d4-a716-446655440003', CURRENT_TIMESTAMP + INTERVAL '45 days'),
  ('850e8400-e29b-41d4-a716-446655440004', 'Annual Support Contract', 12000.00, 'closed_won', '750e8400-e29b-41d4-a716-446655440004', '650e8400-e29b-41d4-a716-446655440001', CURRENT_TIMESTAMP - INTERVAL '5 days'),
  ('850e8400-e29b-41d4-a716-446655440005', 'Custom Development Project', 100000.00, 'proposal', '750e8400-e29b-41d4-a716-446655440005', '650e8400-e29b-41d4-a716-446655440004', CURRENT_TIMESTAMP + INTERVAL '60 days'),
  ('850e8400-e29b-41d4-a716-446655440006', 'Security Audit', 15000.00, 'lead', '750e8400-e29b-41d4-a716-446655440006', '650e8400-e29b-41d4-a716-446655440005', CURRENT_TIMESTAMP + INTERVAL '90 days'),
  ('850e8400-e29b-41d4-a716-446655440007', 'Training Program', 8000.00, 'negotiation', '750e8400-e29b-41d4-a716-446655440007', '650e8400-e29b-41d4-a716-446655440002', CURRENT_TIMESTAMP + INTERVAL '20 days'),
  ('850e8400-e29b-41d4-a716-446655440008', 'Mobile App Development', 45000.00, 'qualified', '750e8400-e29b-41d4-a716-446655440008', '650e8400-e29b-41d4-a716-446655440003', CURRENT_TIMESTAMP + INTERVAL '50 days');
