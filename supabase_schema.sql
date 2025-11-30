-- Supabase Database Schema untuk JagaKost
-- Jalankan script ini di Supabase SQL Editor

-- 1. Tabel Rooms (Kamar Kost)
CREATE TABLE rooms (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    room_number VARCHAR(20) NOT NULL UNIQUE,
    type VARCHAR(20) NOT NULL CHECK (type IN ('single', 'double', 'shared')),
    price DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'occupied', 'maintenance')),
    description TEXT,
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Tabel Tenants (Penyewa)
CREATE TABLE tenants (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(100),
    ktp_number VARCHAR(20),
    room_id UUID REFERENCES rooms(id) ON DELETE SET NULL,
    check_in_date DATE NOT NULL,
    check_out_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    photo_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Tabel Payments (Pembayaran)
CREATE TABLE payments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    amount DECIMAL(10, 2) NOT NULL,
    due_date DATE NOT NULL,
    paid_date TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'overdue')),
    proof_image_url TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 4. Tabel Complaints (Keluhan)
CREATE TABLE complaints (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL CHECK (category IN ('maintenance', 'cleanliness', 'facility', 'other')),
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'in_progress', 'resolved')),
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes untuk performa query
CREATE INDEX idx_tenants_room_id ON tenants(room_id);
CREATE INDEX idx_tenants_status ON tenants(status);
CREATE INDEX idx_payments_tenant_id ON payments(tenant_id);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_due_date ON payments(due_date);
CREATE INDEX idx_complaints_tenant_id ON complaints(tenant_id);
CREATE INDEX idx_complaints_status ON complaints(status);

-- Trigger untuk auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_rooms_updated_at
    BEFORE UPDATE ON rooms
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tenants_updated_at
    BEFORE UPDATE ON tenants
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_payments_updated_at
    BEFORE UPDATE ON payments
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_complaints_updated_at
    BEFORE UPDATE ON complaints
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function untuk auto-update status pembayaran overdue
CREATE OR REPLACE FUNCTION update_payment_status_overdue()
RETURNS void AS $$
BEGIN
    UPDATE payments
    SET status = 'overdue'
    WHERE status = 'pending'
    AND due_date < CURRENT_DATE;
END;
$$ LANGUAGE plpgsql;

-- Function untuk auto-update status kamar saat penyewa check-out
CREATE OR REPLACE FUNCTION update_room_status_on_checkout()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'inactive' AND OLD.status = 'active' THEN
        UPDATE rooms
        SET status = 'available'
        WHERE id = NEW.room_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_room_on_checkout
    AFTER UPDATE ON tenants
    FOR EACH ROW
    WHEN (NEW.status = 'inactive')
    EXECUTE FUNCTION update_room_status_on_checkout();

-- Row Level Security (RLS) - PENTING untuk keamanan
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE complaints ENABLE ROW LEVEL SECURITY;

-- Policy: Authenticated users can read all data
CREATE POLICY "Enable read access for authenticated users" ON rooms
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Enable read access for authenticated users" ON tenants
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Enable read access for authenticated users" ON payments
    FOR SELECT TO authenticated USING (true);

CREATE POLICY "Enable read access for authenticated users" ON complaints
    FOR SELECT TO authenticated USING (true);

-- Policy: Authenticated users can insert/update/delete
CREATE POLICY "Enable all access for authenticated users" ON rooms
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Enable all access for authenticated users" ON tenants
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Enable all access for authenticated users" ON payments
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

CREATE POLICY "Enable all access for authenticated users" ON complaints
    FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- Sample Data untuk Testing
INSERT INTO rooms (room_number, type, price, status, description) VALUES
    ('101', 'single', 1500000, 'available', 'Kamar single dengan AC, kamar mandi dalam'),
    ('102', 'single', 1500000, 'occupied', 'Kamar single dengan AC, kamar mandi dalam'),
    ('103', 'double', 2000000, 'available', 'Kamar double dengan 2 kasur single'),
    ('201', 'single', 1400000, 'maintenance', 'Kamar single, sedang perbaikan AC'),
    ('202', 'shared', 2500000, 'available', 'Kamar shared untuk 3 orang');