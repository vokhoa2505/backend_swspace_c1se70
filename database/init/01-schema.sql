-- PostgreSQL Database Schema for SWSpace
-- Converted from MySQL to PostgreSQL

-- Create database extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create ENUM types
CREATE TYPE booking_status_enum AS ENUM ('pending','awaiting_payment','paid','failed','canceled','refunded','checked_in','checked_out');
CREATE TYPE seat_status_enum AS ENUM ('available','occupied','reserved','disabled');
CREATE TYPE user_role_enum AS ENUM ('user','admin');
CREATE TYPE user_status_enum AS ENUM ('active','inactive');
CREATE TYPE payment_status_enum AS ENUM ('created','processing','success','failed','expired');
CREATE TYPE refund_status_enum AS ENUM ('requested','success','failed');
CREATE TYPE checkin_method_enum AS ENUM ('qr','face');
CREATE TYPE checkin_direction_enum AS ENUM ('in','out');
CREATE TYPE notification_channel_enum AS ENUM ('email','in_app');
CREATE TYPE notification_status_enum AS ENUM ('created','sent','delivered','read');
CREATE TYPE automation_trigger_enum AS ENUM ('rule','admin');
CREATE TYPE service_package_status_enum AS ENUM ('active','paused','inactive');

-- Table: time_units
CREATE TABLE time_units (
    id SMALLSERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    days_equivalent INTEGER NOT NULL
);

-- Table: service_categories  
CREATE TABLE service_categories (
    id SMALLSERIAL PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(60) NOT NULL
);

-- Table: services
CREATE TABLE services (
    id SMALLSERIAL PRIMARY KEY,
    category_id SMALLINT NOT NULL REFERENCES service_categories(id),
    code VARCHAR(40) NOT NULL UNIQUE,
    name VARCHAR(80) NOT NULL,
    description TEXT
);

-- Table: floors
CREATE TABLE floors (
    id SMALLSERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(80) NOT NULL
);

-- Table: zones
CREATE TABLE zones (
    id BIGSERIAL PRIMARY KEY,
    floor_id SMALLINT NOT NULL REFERENCES floors(id),
    service_id SMALLINT NOT NULL REFERENCES services(id),
    name VARCHAR(80) NOT NULL,
    capacity INTEGER NOT NULL,
    layout_image_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(floor_id, service_id, name)
);

-- Table: users
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password_hash TEXT NOT NULL,
    full_name VARCHAR(120),
    role user_role_enum NOT NULL,
    status user_status_enum NOT NULL DEFAULT 'active',
    avatar_url TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: service_packages
CREATE TABLE service_packages (
    id BIGSERIAL PRIMARY KEY,
    service_id SMALLINT NOT NULL REFERENCES services(id),
    name VARCHAR(120) NOT NULL,
    description TEXT,
    price DECIMAL(14,0) NOT NULL,
    unit_id SMALLINT NOT NULL REFERENCES time_units(id),
    access_days INTEGER,
    features JSONB,
    thumbnail_url TEXT,
    badge VARCHAR(40),
    max_capacity INTEGER,
    status service_package_status_enum NOT NULL DEFAULT 'active',
    created_by BIGINT REFERENCES users(id),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: seats
CREATE TABLE seats (
    id BIGSERIAL PRIMARY KEY,
    zone_id BIGINT NOT NULL REFERENCES zones(id),
    seat_code VARCHAR(20) NOT NULL,
    status seat_status_enum NOT NULL DEFAULT 'available',
    pos_x DECIMAL(5,2),
    pos_y DECIMAL(5,2),
    UNIQUE(zone_id, seat_code)
);

-- Table: rooms
CREATE TABLE rooms (
    id BIGSERIAL PRIMARY KEY,
    zone_id BIGINT NOT NULL REFERENCES zones(id),
    room_code VARCHAR(20) NOT NULL,
    capacity INTEGER NOT NULL,
    status seat_status_enum NOT NULL DEFAULT 'available',
    pos_x DECIMAL(5,2),
    pos_y DECIMAL(5,2),
    UNIQUE(zone_id, room_code)
);

-- Table: bookings
CREATE TABLE bookings (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    category_id SMALLINT NOT NULL REFERENCES service_categories(id),
    service_id SMALLINT NOT NULL REFERENCES services(id),
    package_id BIGINT REFERENCES service_packages(id),
    zone_id BIGINT REFERENCES zones(id),
    seat_id BIGINT REFERENCES seats(id),
    room_id BIGINT REFERENCES rooms(id),
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    price_total DECIMAL(14,0) NOT NULL,
    status booking_status_enum NOT NULL DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_seat_or_room CHECK (
        (seat_id IS NOT NULL AND room_id IS NULL) OR 
        (seat_id IS NULL AND room_id IS NOT NULL) OR 
        (seat_id IS NULL AND room_id IS NULL)
    )
);

-- Table: payment_methods
CREATE TABLE payment_methods (
    id SMALLSERIAL PRIMARY KEY,
    code VARCHAR(30) NOT NULL UNIQUE,
    name VARCHAR(60) NOT NULL
);

-- Table: payments
CREATE TABLE payments (
    id BIGSERIAL PRIMARY KEY,
    booking_id BIGINT NOT NULL REFERENCES bookings(id),
    method_id SMALLINT NOT NULL REFERENCES payment_methods(id),
    amount DECIMAL(14,0) NOT NULL,
    currency CHAR(3) NOT NULL DEFAULT 'VND',
    provider_txn_id VARCHAR(100),
    status payment_status_enum NOT NULL DEFAULT 'created',
    qr_url TEXT,
    qr_payload TEXT,
    provider_meta JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(booking_id, method_id)
);

-- Table: refunds
CREATE TABLE refunds (
    id BIGSERIAL PRIMARY KEY,
    payment_id BIGINT NOT NULL REFERENCES payments(id),
    amount DECIMAL(14,0) NOT NULL,
    reason TEXT,
    status refund_status_enum NOT NULL,
    provider_refund_id VARCHAR(100),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Table: cancellation_policies
CREATE TABLE cancellation_policies (
    id SMALLSERIAL PRIMARY KEY,
    name VARCHAR(60) NOT NULL DEFAULT 'default_24h',
    full_refund_before_hours INTEGER NOT NULL DEFAULT 24
);

-- Table: service_floor_rules
CREATE TABLE service_floor_rules (
    id SMALLSERIAL PRIMARY KEY,
    service_id SMALLINT NOT NULL REFERENCES services(id),
    floor_id SMALLINT NOT NULL REFERENCES floors(id),
    UNIQUE(service_id, floor_id)
);

-- Table: cameras
CREATE TABLE cameras (
    id VARCHAR(50) PRIMARY KEY,
    floor_id SMALLINT REFERENCES floors(id),
    zone_id BIGINT REFERENCES zones(id),
    name VARCHAR(80)
);

-- Table: checkins
CREATE TABLE checkins (
    id BIGSERIAL PRIMARY KEY,
    booking_id BIGINT REFERENCES bookings(id),
    user_id BIGINT NOT NULL REFERENCES users(id),
    method checkin_method_enum NOT NULL,
    direction checkin_direction_enum NOT NULL,
    detected_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    camera_id VARCHAR(50),
    extra JSONB
);

-- Table: notifications
CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT REFERENCES users(id),
    booking_id BIGINT REFERENCES bookings(id),
    type VARCHAR(40) NOT NULL,
    title VARCHAR(140),
    content TEXT NOT NULL,
    channel notification_channel_enum NOT NULL,
    status notification_status_enum NOT NULL DEFAULT 'created',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP
);

-- Table: occupancy_events
CREATE TABLE occupancy_events (
    id BIGSERIAL PRIMARY KEY,
    camera_id VARCHAR(50),
    floor_id SMALLINT,
    zone_id BIGINT,
    people_count INTEGER NOT NULL,
    detected_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    model_version VARCHAR(40),
    extra JSONB
);

-- Table: automation_actions
CREATE TABLE automation_actions (
    id BIGSERIAL PRIMARY KEY,
    floor_id SMALLINT,
    zone_id BIGINT,
    action VARCHAR(40) NOT NULL,
    reason TEXT,
    triggered_by automation_trigger_enum NOT NULL,
    executed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    extra JSONB
);

-- Table: auth_sessions
CREATE TABLE auth_sessions (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    refresh_token_hash TEXT NOT NULL,
    user_agent TEXT,
    ip VARCHAR(64),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NOT NULL
);

-- Create function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_service_packages_updated_at BEFORE UPDATE ON service_packages
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookings_updated_at BEFORE UPDATE ON bookings
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at BEFORE UPDATE ON payments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create indexes for better performance
CREATE INDEX idx_bookings_user_id ON bookings(user_id);
CREATE INDEX idx_bookings_status ON bookings(status);
CREATE INDEX idx_bookings_start_time ON bookings(start_time);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_seats_zone_id ON seats(zone_id);
CREATE INDEX idx_rooms_zone_id ON rooms(zone_id);
CREATE INDEX idx_zones_floor_id ON zones(floor_id);
CREATE INDEX idx_zones_service_id ON zones(service_id);

-- Views for analytics
CREATE VIEW v_admin_kpis AS
SELECT 
    (SELECT COUNT(*) FROM users WHERE role = 'user') AS total_users,
    (SELECT COUNT(*) FROM service_packages WHERE status = 'active') AS active_packages,
    (SELECT COUNT(*) FROM bookings WHERE status IN ('paid','checked_in','checked_out')) AS total_bookings,
    (SELECT COALESCE(SUM(amount), 0) FROM payments WHERE status = 'success') AS revenue_total;

CREATE VIEW v_revenue_daily AS
SELECT 
    DATE(updated_at) AS day,
    SUM(CASE WHEN status = 'success' THEN amount ELSE 0 END) AS revenue
FROM payments
GROUP BY DATE(updated_at);

CREATE VIEW v_utilization_daily AS
SELECT 
    DATE(start_time) AS day,
    service_id,
    SUM(CASE WHEN status IN ('paid','checked_in','checked_out') THEN 1 ELSE 0 END) AS bookings_count
FROM bookings
GROUP BY DATE(start_time), service_id;