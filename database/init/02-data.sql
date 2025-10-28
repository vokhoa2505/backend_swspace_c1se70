-- Insert sample data for SWSpace PostgreSQL database

-- Insert time_units
INSERT INTO time_units (code, days_equivalent) VALUES
('hour', 0),
('day', 1),
('week', 7),
('month', 30);

-- Insert service_categories
INSERT INTO service_categories (code, name) VALUES
('freelance', 'Freelance'),
('team', 'Team');

-- Insert services
INSERT INTO services (category_id, code, name, description) VALUES
(1, 'hot_desk', 'Hot Desk', NULL),
(1, 'fixed_desk', 'Fixed Desk', NULL),
(2, 'private_office', 'Private Office', NULL),
(2, 'meeting_room', 'Meeting Room', NULL),
(2, 'networking', 'Networking Space', NULL);

-- Insert floors
INSERT INTO floors (code, name) VALUES
('F1', 'Floor 1 – Main Workspace'),
('F2', 'Floor 2 – Meeting & Private Office'),
('F3', 'Floor 3 – Networking & Workshop');

-- Insert zones
INSERT INTO zones (floor_id, service_id, name, capacity, layout_image_url) VALUES
(1, 2, 'FD-Strip A', 30, '/img/floor1.png'),
(1, 1, 'HD-Main', 40, '/img/floor1.png'),
(2, 4, 'MR-Zone', 4, '/img/floor2.png'),
(2, 3, 'PO-Zone', 10, '/img/floor2.png'),
(3, 5, 'NW-Hall', 80, '/img/floor3.png');

-- Insert users
INSERT INTO users (email, phone, password_hash, full_name, role, status) VALUES
('admin@swspace.vn', '0900000000', '$2y$10$hashdemo', 'Admin', 'admin', 'active'),
('user@swspace.vn', '0900000001', '$2y$10$hashdemo', 'Demo User', 'user', 'active');

-- Insert service_packages
INSERT INTO service_packages (service_id, name, description, price, unit_id, access_days, features, thumbnail_url, badge, status) VALUES
(1, 'Day Pass', 'Access 1 day', 170000, 2, 1, '["Flexible seating", "High-speed WiFi"]', '/img/hotday.jpg', NULL, 'active'),
(2, '1 Week Access', 'Access 7 days', 700000, 3, 7, '["Fixed seat", "Locker"]', '/img/fixedweek.jpg', NULL, 'active'),
(1, '1 Month Access', 'Access 31 days', 2500000, 4, 30, '["24/7 access", "Discount meeting rooms"]', '/img/hotmonth.jpg', 'Best value', 'active'),
(1, '3 Months Access (90d)', 'Access 90 days', 7000000, 4, 30, '["Priority support"]', '/img/hotquarter.jpg', 'Save more', 'active'),
(4, 'Meeting Room Hour', 'Pay per hour', 300000, 1, 0, '["Projector", "Tea/Coffee"]', '/img/mrhour.jpg', NULL, 'active');

-- Insert seats for Fixed Desk zone (FD-Strip A)
INSERT INTO seats (zone_id, seat_code) VALUES
(1, 'FD-T1'), (1, 'FD-T2'), (1, 'FD-T3'), (1, 'FD-T4'), (1, 'FD-T5'),
(1, 'FD-T6'), (1, 'FD-T7'), (1, 'FD-T8'), (1, 'FD-T9'), (1, 'FD-T10'),
(1, 'FD-T11'), (1, 'FD-T12'), (1, 'FD-T13'), (1, 'FD-T14'), (1, 'FD-T15'),
(1, 'FD-T16'), (1, 'FD-T17'), (1, 'FD-T18'), (1, 'FD-L1'), (1, 'FD-L2'),
(1, 'FD-L3'), (1, 'FD-L4'), (1, 'FD-L5'), (1, 'FD-L6');

-- Insert seats for Hot Desk zone (HD-Main)
INSERT INTO seats (zone_id, seat_code) VALUES
(2, 'HD-1'), (2, 'HD-2'), (2, 'HD-3'), (2, 'HD-4'), (2, 'HD-5'),
(2, 'HD-6'), (2, 'HD-7'), (2, 'HD-8'), (2, 'HD-9'), (2, 'HD-10'),
(2, 'HD-11'), (2, 'HD-12'), (2, 'HD-13'), (2, 'HD-14'), (2, 'HD-15'),
(2, 'HD-16'), (2, 'HD-17'), (2, 'HD-18'), (2, 'HD-19'), (2, 'HD-20');

-- Insert seats for Networking Space (NW-Hall)
INSERT INTO seats (zone_id, seat_code) VALUES
(5, 'NW-1'), (5, 'NW-2'), (5, 'NW-3'), (5, 'NW-4'), (5, 'NW-5'),
(5, 'NW-6'), (5, 'NW-7'), (5, 'NW-8'), (5, 'NW-9'), (5, 'NW-10'),
(5, 'NW-11'), (5, 'NW-12'), (5, 'NW-13'), (5, 'NW-14'), (5, 'NW-15'),
(5, 'NW-16'), (5, 'NW-17'), (5, 'NW-18'), (5, 'NW-19'), (5, 'NW-20'),
(5, 'NW-21'), (5, 'NW-22'), (5, 'NW-23'), (5, 'NW-24');

-- Insert rooms
INSERT INTO rooms (zone_id, room_code, capacity) VALUES
(3, 'MR-201', 12),
(3, 'MR-202', 16),
(4, 'PO-203', 4);

-- Insert payment_methods
INSERT INTO payment_methods (code, name) VALUES
('momo', 'MoMo Pay'),
('zalopay', 'ZaloPay'),
('atm_qr', 'ATM/Napas QR');

-- Insert cancellation_policies
INSERT INTO cancellation_policies (name, full_refund_before_hours) VALUES
('default_24h', 24);

-- Insert service_floor_rules
INSERT INTO service_floor_rules (service_id, floor_id) VALUES
(2, 1), -- Fixed Desk on Floor 1
(1, 1), -- Hot Desk on Floor 1
(4, 2), -- Meeting Room on Floor 2
(3, 2), -- Private Office on Floor 2
(5, 3); -- Networking Space on Floor 3