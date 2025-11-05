-- 開発用シードデータ
-- 実行: pnpm supabase:seed

-- ============================================
-- 0. Supabase Auth テストユーザー
-- ============================================
-- テストユーザー情報:
--   Email: test@example.com
--   Password: password123
--   User ID: 00000000-0000-0000-0000-000000000001

-- auth.usersテーブルにテストユーザーを作成
INSERT INTO auth.users (
  id,
  instance_id,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  raw_app_meta_data,
  raw_user_meta_data,
  aud,
  role
)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000000',
  'test@example.com',
  -- password123 をbcryptでハッシュ化したもの
  '$2a$10$5S8a6rlFfKn/9E.L0yQZFOpF.gTqRJP5Z5LFnN8WnP5uZjTHqFkMG',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  '{"provider":"email","providers":["email"]}',
  '{"name":"Test User"}',
  'authenticated',
  'authenticated'
)
ON CONFLICT (id) DO NOTHING;

-- auth.identitiesテーブルにも対応するレコードを作成
INSERT INTO auth.identities (
  id,
  user_id,
  identity_data,
  provider,
  last_sign_in_at,
  created_at,
  updated_at
)
VALUES (
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001',
  jsonb_build_object(
    'sub', '00000000-0000-0000-0000-000000000001',
    'email', 'test@example.com'
  ),
  'email',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 1. ユーザープロフィール
-- ============================================
-- 上記のSupabase Authユーザーと紐付けたプロフィール
INSERT INTO user_profiles (id, "userId", "defaultCurrency", "decimalPlaces", "dividendMonthFormat", "autoUpdateEnabled", "updateTime", "createdAt", "updatedAt")
VALUES
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', 'JPY', 2, 'number', true, '09:00:00'::time, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT ("userId") DO NOTHING;

-- ============================================
-- 2. 証券口座
-- ============================================
INSERT INTO securities_accounts (id, "userId", "accountName", "accountType", "displayOrder", "createdAt", "updatedAt")
VALUES
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'SBI証券 特定口座', '特定口座', 1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '楽天証券 新NISA', '新NISA', 2, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 3. 株式銘柄
-- ============================================

-- 日本株
INSERT INTO stocks (id, symbol, name, market, currency, sector, "currentPrice", "dividendYield", "latestDividendPerShare", "exDividendDate", "dividendMonths", "lastUpdated", "createdAt")
VALUES
  ('20000000-0000-0000-0000-000000000001', '9433.T', 'KDDI', 'JP', 'JPY', '通信', 4250.0000, 3.5300, 150.0000, '2025-03-31', ARRAY[3, 9], CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('20000000-0000-0000-0000-000000000002', '2914.T', '日本たばこ産業', 'JP', 'JPY', '食品', 4100.0000, 5.8500, 240.0000, '2024-12-31', ARRAY[6, 12], CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (symbol) DO NOTHING;

-- 米国株
INSERT INTO stocks (id, symbol, name, market, currency, sector, "currentPrice", "dividendYield", "latestDividendPerShare", "exDividendDate", "dividendMonths", "lastUpdated", "createdAt")
VALUES
  ('20000000-0000-0000-0000-000000000003', 'AAPL', 'Apple Inc.', 'US', 'USD', 'Technology', 178.7200, 0.5200, 0.2400, '2025-02-10', ARRAY[2, 5, 8, 11], CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('20000000-0000-0000-0000-000000000004', 'MSFT', 'Microsoft Corporation', 'US', 'USD', 'Technology', 425.6700, 0.7500, 0.8300, '2025-02-20', ARRAY[2, 5, 8, 11], CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
  ('20000000-0000-0000-0000-000000000005', 'KO', 'The Coca-Cola Company', 'US', 'USD', 'Consumer Staples', 62.1800, 3.0900, 0.4850, '2024-12-15', ARRAY[3, 6, 9, 12], CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (symbol) DO NOTHING;

-- ADR
INSERT INTO stocks (id, symbol, name, market, currency, sector, "currentPrice", "dividendYield", "latestDividendPerShare", "exDividendDate", "dividendMonths", "lastUpdated", "createdAt")
VALUES
  ('20000000-0000-0000-0000-000000000006', 'NVO', 'Novo Nordisk A/S', 'ADR', 'USD', 'Healthcare', 98.4500, 1.4500, 0.7150, '2025-03-21', ARRAY[3, 8], CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (symbol) DO NOTHING;

-- ============================================
-- 4. 為替レート（過去5ヶ月分）
-- ============================================
INSERT INTO exchange_rates (id, date, "usdJpy", "createdAt")
VALUES
  (gen_random_uuid(), '2024-11-01', 149.3500, CURRENT_TIMESTAMP),
  (gen_random_uuid(), '2024-12-01', 150.1200, CURRENT_TIMESTAMP),
  (gen_random_uuid(), '2025-01-01', 148.8700, CURRENT_TIMESTAMP),
  (gen_random_uuid(), '2025-02-01', 149.5600, CURRENT_TIMESTAMP),
  (gen_random_uuid(), '2025-03-01', 150.2300, CURRENT_TIMESTAMP)
ON CONFLICT (date) DO NOTHING;

-- ============================================
-- 5. 取引履歴
-- ============================================
INSERT INTO transactions (id, "userId", "accountId", "stockId", "transactionType", "transactionDate", shares, "pricePerShare", "totalAmount", fees, "exchangeRate", notes, "createdAt", "updatedAt")
VALUES
  -- KDDI購入
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 'BUY', '2024-10-15', 100, 4150.0000, 415000.00, 500.00, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  -- JT購入
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 'BUY', '2024-11-01', 200, 3950.0000, 790000.00, 800.00, NULL, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  -- Apple購入
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000003', 'BUY', '2024-09-20', 50, 176.5000, 8825.00, 0.00, 148.2500, 'NISA口座のため手数料無料', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  -- Microsoft購入
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000004', 'BUY', '2024-10-05', 30, 415.3000, 12459.00, 0.00, 149.1200, 'NISA口座のため手数料無料', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  -- Coca-Cola購入
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 'BUY', '2024-08-15', 100, 61.2000, 6120.00, 20.00, 147.3500, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  -- Novo Nordisk購入
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 'BUY', '2024-09-10', 50, 95.8000, 4790.00, 18.00, 148.6700, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ============================================
-- 6. 保有株式
-- ============================================
INSERT INTO holdings (id, "userId", "accountId", "stockId", shares, "averagePrice", "totalCost", "isActive", "createdAt", "updatedAt")
VALUES
  -- KDDI保有
  ('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000001', 100, 4155.0000, 415500.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  -- JT保有
  ('30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000002', 200, 3954.0000, 790800.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  -- Apple保有
  ('30000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000003', 50, 176.5000, 8825.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  -- Microsoft保有
  ('30000000-0000-0000-0000-000000000004', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000002', '20000000-0000-0000-0000-000000000004', 30, 415.3000, 12459.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  -- Coca-Cola保有
  ('30000000-0000-0000-0000-000000000005', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000005', 100, 61.4000, 6140.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  -- Novo Nordisk保有
  ('30000000-0000-0000-0000-000000000006', '00000000-0000-0000-0000-000000000001', '10000000-0000-0000-0000-000000000001', '20000000-0000-0000-0000-000000000006', 50, 96.1600, 4808.00, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT ("accountId", "stockId") DO NOTHING;

-- ============================================
-- 7. 配当金履歴
-- ============================================
INSERT INTO dividends (id, "userId", "holdingId", "receivedDate", "sharesAtPayment", "dividendPerShareBeforeTax", "amountBeforeTax", "amountAfterTax", "taxType", "foreignTax", "domesticTax", "exchangeRate", "amountJpy", notes, "createdAt", "updatedAt")
VALUES
  -- KDDI配当（日本株・特定口座）
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000001', '2024-12-10', 100, 75.0000, 7500.00, 6115.00, 'JP_STANDARD', 0.00, 1385.00, NULL, 6115.00, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  -- JT配当（日本株・特定口座）
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000002', '2025-01-15', 200, 120.0000, 24000.00, 19560.00, 'JP_STANDARD', 0.00, 4440.00, NULL, 19560.00, NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  -- Apple配当（米国株・NISA）
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000003', '2024-11-15', 50, 0.2400, 12.00, 10.80, 'US_NISA', 1.20, 0.00, 149.8200, 1618.10, '米国での10%源泉徴収のみ', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  -- Microsoft配当（米国株・NISA）
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000004', '2024-11-20', 30, 0.8300, 24.90, 22.41, 'US_NISA', 2.49, 0.00, 150.1200, 3364.20, '米国での10%源泉徴収のみ', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  -- Coca-Cola配当（米国株・特定口座）
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000005', '2025-01-02', 100, 0.4850, 48.50, 37.13, 'US_STANDARD', 4.85, 6.52, 148.8700, 5527.60, '米国10% + 日本20.315%の二重課税', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),

  -- Novo Nordisk配当（ADR・特定口座）
  (gen_random_uuid(), '00000000-0000-0000-0000-000000000001', '30000000-0000-0000-0000-000000000006', '2024-12-20', 50, 0.7150, 35.75, 27.36, 'ADR_STANDARD', 5.36, 3.03, 150.2300, 4110.30, 'ADRは外国税+米国税+日本税', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ============================================
-- 8. 株価履歴（サンプル：各銘柄の過去30日分）
-- ============================================

-- KDDI株価履歴
INSERT INTO stock_price_history (id, "stockId", date, "closePrice", "createdAt")
SELECT
  gen_random_uuid(),
  '20000000-0000-0000-0000-000000000001',
  CURRENT_DATE - (i || ' days')::interval,
  4250.0000 + (random() - 0.5) * 100,
  CURRENT_TIMESTAMP
FROM generate_series(0, 30) AS i
ON CONFLICT ("stockId", date) DO NOTHING;

-- JT株価履歴
INSERT INTO stock_price_history (id, "stockId", date, "closePrice", "createdAt")
SELECT
  gen_random_uuid(),
  '20000000-0000-0000-0000-000000000002',
  CURRENT_DATE - (i || ' days')::interval,
  4100.0000 + (random() - 0.5) * 160,
  CURRENT_TIMESTAMP
FROM generate_series(0, 30) AS i
ON CONFLICT ("stockId", date) DO NOTHING;

-- Apple株価履歴
INSERT INTO stock_price_history (id, "stockId", date, "closePrice", "createdAt")
SELECT
  gen_random_uuid(),
  '20000000-0000-0000-0000-000000000003',
  CURRENT_DATE - (i || ' days')::interval,
  178.7200 + (random() - 0.5) * 10,
  CURRENT_TIMESTAMP
FROM generate_series(0, 30) AS i
ON CONFLICT ("stockId", date) DO NOTHING;

-- Microsoft株価履歴
INSERT INTO stock_price_history (id, "stockId", date, "closePrice", "createdAt")
SELECT
  gen_random_uuid(),
  '20000000-0000-0000-0000-000000000004',
  CURRENT_DATE - (i || ' days')::interval,
  425.6700 + (random() - 0.5) * 20,
  CURRENT_TIMESTAMP
FROM generate_series(0, 30) AS i
ON CONFLICT ("stockId", date) DO NOTHING;

-- Coca-Cola株価履歴
INSERT INTO stock_price_history (id, "stockId", date, "closePrice", "createdAt")
SELECT
  gen_random_uuid(),
  '20000000-0000-0000-0000-000000000005',
  CURRENT_DATE - (i || ' days')::interval,
  62.1800 + (random() - 0.5) * 4,
  CURRENT_TIMESTAMP
FROM generate_series(0, 30) AS i
ON CONFLICT ("stockId", date) DO NOTHING;

-- Novo Nordisk株価履歴
INSERT INTO stock_price_history (id, "stockId", date, "closePrice", "createdAt")
SELECT
  gen_random_uuid(),
  '20000000-0000-0000-0000-000000000006',
  CURRENT_DATE - (i || ' days')::interval,
  98.4500 + (random() - 0.5) * 6,
  CURRENT_TIMESTAMP
FROM generate_series(0, 30) AS i
ON CONFLICT ("stockId", date) DO NOTHING;

-- ============================================
-- シードデータの投入完了
-- ============================================
-- 以下のデータが投入されました：
-- - 1 Supabase Authユーザー（test@example.com / password123）
-- - 1 ユーザープロフィール
-- - 2 証券口座
-- - 6 株式銘柄（日本株2、米国株3、ADR1）
-- - 6 保有株式
-- - 6 取引履歴
-- - 6 配当金履歴
-- - 5 為替レート
-- - 186 株価履歴レコード（31日 × 6銘柄）
