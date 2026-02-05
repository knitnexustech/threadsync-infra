
-- Phase 1: Structural Efficiency Migration
-- Implementation for ThreadSync Performance Roadmap

-- 1. Create Channel Summaries View (Phase 1 Step B)
-- This view pre-calculates the last message and PO details for the Sidebar
CREATE OR REPLACE VIEW channel_summaries AS
SELECT 
    c.id as channel_id,
    c.name as channel_name,
    c.type as channel_type,
    c.status as channel_status,
    c.completion_percentage,
    c.po_id,
    po.order_number as po_order_number,
    po.style_number as po_style_number,
    (
        SELECT m.content 
        FROM messages m 
        WHERE m.channel_id = c.id 
        ORDER BY m.created_at DESC 
        LIMIT 1
    ) as last_message,
    (
        SELECT m.created_at 
        FROM messages m 
        WHERE m.channel_id = c.id 
        ORDER BY m.created_at DESC 
        LIMIT 1
    ) as last_message_at
FROM channels c
JOIN purchase_orders po ON c.po_id = po.id;

-- 2. Additional Performance Indexes (Phase 1 Step C)
-- Most indexes were already present, but these specifically help with sorted results and complex filters

-- Faster message retrieval by channel and time
CREATE INDEX IF NOT EXISTS idx_messages_channel_created_at 
ON messages(channel_id, created_at DESC);

-- Faster unread counts by indexing last_read_at
CREATE INDEX IF NOT EXISTS idx_channel_members_last_read 
ON channel_members(user_id, last_read_at);

-- Performance for PO lookups by manufacturer
CREATE INDEX IF NOT EXISTS idx_po_manufacturer_created 
ON purchase_orders(manufacturer_id, created_at DESC);

-- Optimize searching for vendors/suppliers
CREATE INDEX IF NOT EXISTS idx_companies_type_name 
ON companies(type, name);
