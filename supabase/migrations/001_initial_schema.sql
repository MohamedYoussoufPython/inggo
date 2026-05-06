-- ============================================
-- INGGO VTC - Database Schema
-- Djibouti Moto-Taxi
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- PROFILES (extends auth.users)
-- ============================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone TEXT UNIQUE NOT NULL,
    email TEXT,
    role TEXT NOT NULL DEFAULT 'client' CHECK (role IN ('client', 'driver', 'admin')),
    avatar_url TEXT,
    language TEXT NOT NULL DEFAULT 'fr' CHECK (language IN ('fr', 'en')),
    is_online BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================
-- DRIVERS
-- ============================================
CREATE TABLE drivers (
    id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    vehicle_type TEXT NOT NULL DEFAULT 'moto',
    plate_number TEXT NOT NULL,
    vehicle_color TEXT,
    is_verified BOOLEAN NOT NULL DEFAULT false,
    is_online BOOLEAN NOT NULL DEFAULT false,
    total_rides INTEGER NOT NULL DEFAULT 0,
    total_earnings NUMERIC NOT NULL DEFAULT 0,
    rating NUMERIC NOT NULL DEFAULT 5.0,
    id_card_url TEXT,
    license_url TEXT,
    vehicle_photo_url TEXT,
    current_lat DOUBLE PRECISION,
    current_lng DOUBLE PRECISION,
    last_location_update TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================
-- RIDES
-- ============================================
CREATE TABLE rides (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    client_id UUID NOT NULL REFERENCES profiles(id),
    driver_id UUID REFERENCES profiles(id),
    pickup_address TEXT NOT NULL,
    pickup_lat DOUBLE PRECISION NOT NULL,
    pickup_lng DOUBLE PRECISION NOT NULL,
    dropoff_address TEXT NOT NULL,
    dropoff_lat DOUBLE PRECISION NOT NULL,
    dropoff_lng DOUBLE PRECISION NOT NULL,
    price NUMERIC NOT NULL DEFAULT 250,
    commission NUMERIC NOT NULL DEFAULT 125,
    tip_amount NUMERIC NOT NULL DEFAULT 0,
    payment_method TEXT NOT NULL DEFAULT 'cash',
    payment_status TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'failed')),
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'searching', 'accepted', 'in_progress', 'completed', 'cancelled')),
    cancel_reason TEXT,
    rating NUMERIC CHECK (rating >= 1 AND rating <= 5),
    review TEXT,
    distance NUMERIC,
    estimated_duration INTEGER,
    actual_duration INTEGER,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    accepted_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ
);

-- ============================================
-- FAVORITES
-- ============================================
CREATE TABLE favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    label TEXT NOT NULL,
    address TEXT NOT NULL,
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================
-- NOTIFICATIONS
-- ============================================
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    type TEXT NOT NULL,
    data JSONB,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================
-- LANDMARKS (Djibouti points of interest)
-- ============================================
CREATE TABLE landmarks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name_fr TEXT NOT NULL,
    name_en TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'autre' CHECK (category IN ('quartier', 'marche', 'mosquee', 'hopital', 'gare', 'ecole', 'hotel', 'restaurant', 'banque', 'autre')),
    lat DOUBLE PRECISION NOT NULL,
    lng DOUBLE PRECISION NOT NULL,
    is_popular BOOLEAN NOT NULL DEFAULT false
);

-- ============================================
-- INDEXES
-- ============================================
CREATE INDEX idx_profiles_role ON profiles(role);
CREATE INDEX idx_profiles_phone ON profiles(phone);
CREATE INDEX idx_drivers_is_online ON drivers(is_online);
CREATE INDEX idx_drivers_is_verified ON drivers(is_verified);
CREATE INDEX idx_rides_client_id ON rides(client_id);
CREATE INDEX idx_rides_driver_id ON rides(driver_id);
CREATE INDEX idx_rides_status ON rides(status);
CREATE INDEX idx_rides_created_at ON rides(created_at DESC);
CREATE INDEX idx_favorites_user_id ON favorites(user_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_landmarks_category ON landmarks(category);
CREATE INDEX idx_landmarks_is_popular ON landmarks(is_popular);

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE drivers ENABLE ROW LEVEL SECURITY;
ALTER TABLE rides ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE landmarks ENABLE ROW LEVEL SECURITY;

-- Profiles: users can read own, admins can read all
CREATE POLICY "Users can read own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Admins can read all profiles" ON profiles FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
);

-- Drivers: anyone can read online/verified, own driver can update
CREATE POLICY "Anyone can read verified drivers" ON drivers FOR SELECT USING (is_verified = true OR id = auth.uid());
CREATE POLICY "Driver can update own record" ON drivers FOR UPDATE USING (id = auth.uid());
CREATE POLICY "Driver can insert own record" ON drivers FOR INSERT WITH CHECK (id = auth.uid());

-- Rides: participants can read, client creates, driver can see searching & accept
CREATE POLICY "Users can read own rides" ON rides FOR SELECT USING (
    client_id = auth.uid() 
    OR driver_id = auth.uid() 
    OR (status = 'searching' AND EXISTS (
        SELECT 1 FROM drivers WHERE id = auth.uid() AND is_verified = true AND is_online = true
    ))
);
CREATE POLICY "Client can create ride" ON rides FOR INSERT WITH CHECK (client_id = auth.uid());
CREATE POLICY "Driver or client can update ride" ON rides FOR UPDATE USING (
    client_id = auth.uid() 
    OR driver_id = auth.uid() 
    OR (status = 'searching' AND EXISTS (
        SELECT 1 FROM drivers WHERE id = auth.uid() AND is_verified = true AND is_online = true
    ))
);

-- Favorites: users can CRUD own
CREATE POLICY "Users can read own favorites" ON favorites FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can insert own favorites" ON favorites FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can delete own favorites" ON favorites FOR DELETE USING (user_id = auth.uid());

-- Notifications: users can read own, users can insert, users can update own
CREATE POLICY "Users can read own notifications" ON notifications FOR SELECT USING (user_id = auth.uid());
CREATE POLICY "Users can insert own notifications" ON notifications FOR INSERT WITH CHECK (user_id = auth.uid());
CREATE POLICY "Users can update own notifications" ON notifications FOR UPDATE USING (user_id = auth.uid());

-- Landmarks: anyone can read
CREATE POLICY "Anyone can read landmarks" ON landmarks FOR SELECT USING (true);

-- ============================================
-- TRIGGERS
-- ============================================

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-update driver stats after ride completion
CREATE OR REPLACE FUNCTION update_driver_stats()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'completed' AND (OLD.status IS NULL OR OLD.status != 'completed') THEN
        UPDATE drivers
        SET total_rides = total_rides + 1,
            total_earnings = total_earnings + NEW.commission
        WHERE id = NEW.driver_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER rides_driver_stats
    AFTER UPDATE ON rides
    FOR EACH ROW EXECUTE FUNCTION update_driver_stats();

-- ============================================
-- SEED DATA: Djibouti Landmarks
-- ============================================
INSERT INTO landmarks (name_fr, name_en, category, lat, lng, is_popular) VALUES
-- Quartiers
('Quartier 1', 'District 1', 'quartier', 11.5880, 43.1456, true),
('Quartier 2', 'District 2', 'quartier', 11.5850, 43.1480, true),
('Quartier 3', 'District 3', 'quartier', 11.5910, 43.1420, true),
('Quartier 4', 'District 4', 'quartier', 11.5820, 43.1510, true),
('Quartier 5', 'District 5', 'quartier', 11.5790, 43.1390, true),
('Quartier 6', 'District 6', 'quartier', 11.5940, 43.1550, true),
('Arhiba', 'Arhiba', 'quartier', 11.5700, 43.1350, true),
('Balbala', 'Balbala', 'quartier', 11.5600, 43.1250, true),
('Djibouti Ville', 'Djibouti City', 'quartier', 11.5880, 43.1456, true),
('Heron', 'Heron', 'quartier', 11.5950, 43.1500, false),

-- Marchés
('Marché Central', 'Central Market', 'marche', 11.5875, 43.1460, true),
('Marché de Balbala', 'Balbala Market', 'marche', 11.5610, 43.1260, true),
('Marché aux poissons', 'Fish Market', 'marche', 11.5900, 43.1520, true),

-- Mosquées
('Grande Mosquée Hamoudi', 'Hamoudi Grand Mosque', 'mosquee', 11.5885, 43.1445, true),
('Mosquée Saoudi', 'Saudi Mosque', 'mosquee', 11.5860, 43.1470, false),

-- Hôpitaux
('Hôpital Peltier', 'Peltier Hospital', 'hopital', 11.5865, 43.1430, true),
('Hôpital General', 'General Hospital', 'hopital', 11.5650, 43.1300, true),
('Centre Hospitalier Bel Air', 'Bel Air Hospital', 'hopital', 11.5920, 43.1490, false),

-- Gares
('Gare de Djibouti', 'Djibouti Train Station', 'gare', 11.5925, 43.1480, true),
('Port de Djibouti', 'Port of Djibouti', 'gare', 11.5950, 43.1530, true),

-- Écoles
('Lycée de Djibouti', 'Djibouti High School', 'ecole', 11.5855, 43.1410, false),
('Université de Djibouti', 'University of Djibouti', 'ecole', 11.5750, 43.1350, true),

-- Hôtels
('Hôtel Kempinski', 'Kempinski Hotel', 'hotel', 11.5930, 43.1510, true),
('Hôtel Djibouti Palace', 'Djibouti Palace Hotel', 'hotel', 11.5880, 43.1560, true),
('Hôtel Acacias', 'Acacias Hotel', 'hotel', 11.5870, 43.1450, false),

-- Restaurants
('Restaurant l'Atelier', 'L''Atelier Restaurant', 'restaurant', 11.5882, 43.1455, false),
('Café de la Gare', 'Café de la Gare', 'restaurant', 11.5920, 43.1485, false),

-- Banques
('Banque Centrale', 'Central Bank', 'banque', 11.5878, 43.1452, false),
('BCIMR', 'BCIMR Bank', 'banque', 11.5860, 43.1440, false),

-- Ambassades / Autres
('Ambassade de France', 'French Embassy', 'autre', 11.5888, 43.1440, false),
('Aéroport de Djibouti', 'Djibouti Airport', 'autre', 11.5470, 43.1590, true),
('Camp Lemonnier', 'Camp Lemonnier', 'autre', 11.5400, 43.1650, false);

-- ============================================
-- REALTIME — Enable for rides table
-- ============================================
-- Required for the Realtime Supabase subscription that notifies
-- drivers of new rides and clients of ride status changes.
ALTER PUBLICATION supabase_realtime ADD TABLE rides;
ALTER PUBLICATION supabase_realtime ADD TABLE notifications;
