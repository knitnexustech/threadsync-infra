-- Kramex Demo Data Seed Script
-- Run this in your Supabase SQL Editor to populate dummy credentials and demo data.

DO $$
DECLARE
    hq_id UUID;
    vendor_id UUID;
    admin_id UUID;
    junior_id UUID;
    vendor_admin_id UUID;
    manager_id UUID;
    po1_id UUID;
    po2_id UUID;
    ch1_id UUID;
    ch2_id UUID;
    ch3_id UUID;
BEGIN
    -- 1. Create Companies
    INSERT INTO companies (name, type) 
    VALUES ('Kramex Head Office', 'MANUFACTURER')
    RETURNING id INTO hq_id;

    INSERT INTO companies (name, type) 
    VALUES ('Elite Fabrics', 'VENDOR')
    RETURNING id INTO vendor_id;

    -- 2. Create Users (Dummy Credentials)
    -- Phone: 9876543210 | Passcode: 1234 (Demo Admin)
    INSERT INTO users (company_id, name, phone, passcode, role)
    VALUES (hq_id, 'Demo Admin', '9876543210', '1234', 'ADMIN')
    RETURNING id INTO admin_id;

    -- Phone: 9876543211 | Passcode: 5678 (Junior Merchandiser)
    INSERT INTO users (company_id, name, phone, passcode, role)
    VALUES (hq_id, 'Junior Merch', '9876543211', '5678', 'JUNIOR_MERCHANDISER')
    RETURNING id INTO junior_id;

    -- Phone: 8765432100 | Passcode: 2222 (Admin Vendor)
    INSERT INTO users (company_id, name, phone, passcode, role)
    VALUES (vendor_id, 'Expert Supplier', '8765432100', '2222', 'ADMIN')
    RETURNING id INTO vendor_admin_id;

    -- Phone: 7654321000 | Passcode: 3333 (Senior Manager)
    INSERT INTO users (company_id, name, phone, passcode, role)
    VALUES (hq_id, 'Senior Manager', '7654321000', '3333', 'SENIOR_MANAGER')
    RETURNING id INTO manager_id;

    -- 3. Create Demo Orders (Purchase Orders)
    INSERT INTO purchase_orders (manufacturer_id, order_number, style_number, status, created_by)
    VALUES (hq_id, 'ORD-2026-SPRING', 'Premium Cotton Tee', 'IN_PROGRESS', admin_id)
    RETURNING id INTO po1_id;

    INSERT INTO purchase_orders (manufacturer_id, order_number, style_number, status, created_by)
    VALUES (hq_id, 'ORD-2026-DENIM', 'Vintage Oversized Jacket', 'PENDING', manager_id)
    RETURNING id INTO po2_id;

    -- 4. Add PO Members
    INSERT INTO po_members (po_id, user_id) VALUES (po1_id, admin_id), (po1_id, junior_id), (po1_id, manager_id);
    INSERT INTO po_members (po_id, user_id) VALUES (po2_id, admin_id), (po2_id, manager_id);

    -- 5. Create Channels (Groups)
    INSERT INTO channels (po_id, vendor_id, name, type, status)
    VALUES (po1_id, vendor_id, 'Fabric Sourcing', 'KNITTING', 'ACTIVE')
    RETURNING id INTO ch1_id;

    INSERT INTO channels (po_id, vendor_id, name, type, status)
    VALUES (po1_id, vendor_id, 'Dyeing & Finishing', 'DYEING', 'PENDING')
    RETURNING id INTO ch2_id;

    INSERT INTO channels (po_id, vendor_id, name, type, status)
    VALUES (po2_id, vendor_id, 'Sample Stitching', 'STITCHING', 'PENDING')
    RETURNING id INTO ch3_id;

    -- 6. Add Channel Members
    INSERT INTO channel_members (channel_id, user_id, added_by) 
    VALUES 
        (ch1_id, admin_id, admin_id), 
        (ch1_id, vendor_admin_id, admin_id),
        (ch2_id, junior_id, admin_id),
        (ch2_id, vendor_admin_id, admin_id),
        (ch3_id, manager_id, admin_id),
        (ch3_id, vendor_admin_id, admin_id);

    -- 7. Add Demo Messages
    INSERT INTO messages (channel_id, user_id, content) VALUES
    (ch1_id, admin_id, 'Hello Expert Supplier, welcome to the Kramex team! Please check the specs for the Spring PO.'),
    (ch1_id, vendor_admin_id, 'Thanks! We have received the requirements. Will update the knitting schedule by EOD.'),
    (ch2_id, junior_id, 'Checking if the color lab dips are ready for review?'),
    (ch3_id, manager_id, 'We need the first prototype by next Monday for the Denim order.');

    -- 8. Add System Messages
    INSERT INTO messages (channel_id, content, is_system_update) VALUES
    (ch1_id, 'Admin updated status to ACTIVE', true),
    (ch2_id, 'Fabric Sourcing channel created', true);

END $$;
