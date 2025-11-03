# データベース設計

## 🗄️ 概要

**DBMS**: PostgreSQL 15（Supabase提供）

**設計方針:**

- 正規化（第3正規形）
- Row Level Security（RLS）による多テナント対応
- UUIDによる主キー
- タイムスタンプ自動管理

---

## 📊 ER図

```
┌─────────────┐
│    users    │
│  (Supabase  │
│    Auth)    │
└──────┬──────┘
       │
       ├─────────────────────┐
       │                     │
       ↓                     ↓
┌──────────────┐      ┌─────────────┐
│  securities  │      │   stocks    │
│  _accounts   │      │             │
└──────┬───────┘      └──────┬──────┘
       │                     │
       │                     │
       └──────┬──────────────┘
              ↓
       ┌──────────────┐
       │   holdings   │
       └──────┬───────┘
              │
              ↓
       ┌──────────────┐
       │  dividends   │
       └──────────────┘

┌──────────────────┐
│ exchange_rates   │
│ (為替レート)      │
└──────────────────┘

┌──────────────────┐
│stock_price_      │
│history           │
│(株価履歴)        │
└──────────────────┘
```

---

## 📋 テーブル定義

### 1. users

**説明**: ユーザー情報（Supabase Authが管理）

Supabase Authが自動管理するため、独自テーブルは不要。
`auth.users` テーブルを参照。

---

### 2. securities_accounts

**説明**: 証券口座情報

```sql
CREATE TABLE securities_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  account_name TEXT NOT NULL,
  account_type TEXT NOT NULL CHECK (account_type IN ('特定口座', 'NISA', 'つみたてNISA', '新NISA')),
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_securities_accounts_user_id ON securities_accounts(user_id);
```

**カラム説明:**

- `id`: 主キー
- `user_id`: ユーザーID（外部キー）
- `account_name`: 口座名（例: "SBI証券"）
- `account_type`: 口座種別
- `display_order`: 表示順
- `created_at`: 作成日時
- `updated_at`: 更新日時

---

### 3. stocks

**説明**: 銘柄マスター（株式・ETF・REIT）

```sql
CREATE TABLE stocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  symbol TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  market TEXT NOT NULL CHECK (market IN ('JP', 'US', 'ADR')),
  currency TEXT DEFAULT 'USD' CHECK (currency IN ('USD', 'JPY')),
  sector TEXT,

  -- yahoo-finance2から取得
  current_price NUMERIC(12, 4),
  dividend_yield NUMERIC(6, 4),
  latest_dividend_per_share NUMERIC(10, 4),
  ex_dividend_date DATE,
  dividend_months INTEGER[], -- 配当月の配列（例: {2,5,8,11}）

  last_updated TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_stocks_symbol ON stocks(symbol);
CREATE INDEX idx_stocks_market ON stocks(market);
```

**カラム説明:**

- `symbol`: ティッカーシンボル（例: "AAPL", "7203.T"）
- `market`: 市場区分（JP/US/ADR）
- `currency`: 通貨
- `dividend_months`: 配当支払月（推測値）

---

### 4. holdings

**説明**: 保有銘柄（証券口座×銘柄）

```sql
CREATE TABLE holdings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  account_id UUID NOT NULL REFERENCES securities_accounts(id) ON DELETE CASCADE,
  stock_id UUID NOT NULL REFERENCES stocks(id) ON DELETE CASCADE,

  shares INTEGER NOT NULL CHECK (shares > 0),
  average_price NUMERIC(12, 4) NOT NULL CHECK (average_price > 0),
  total_cost NUMERIC(15, 2) NOT NULL CHECK (total_cost > 0),

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(account_id, stock_id)
);

CREATE INDEX idx_holdings_user_id ON holdings(user_id);
CREATE INDEX idx_holdings_account_id ON holdings(account_id);
CREATE INDEX idx_holdings_stock_id ON holdings(stock_id);
```

**カラム説明:**

- `shares`: 保有株数
- `average_price`: 平均取得単価
- `total_cost`: 取得価格合計（= shares × average_price）

**制約:**

- 同じ口座で同じ銘柄は1レコードのみ（UNIQUE制約）

---

### 5. dividends

**説明**: 配当履歴

```sql
CREATE TABLE dividends (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  holding_id UUID NOT NULL REFERENCES holdings(id) ON DELETE CASCADE,

  received_date DATE NOT NULL,
  shares_at_payment INTEGER NOT NULL CHECK (shares_at_payment > 0),

  dividend_per_share_before_tax NUMERIC(10, 4),
  amount_before_tax NUMERIC(15, 2),
  amount_after_tax NUMERIC(15, 2) NOT NULL CHECK (amount_after_tax > 0),

  -- 税金情報
  tax_type TEXT NOT NULL CHECK (
    tax_type IN ('JP_STANDARD', 'JP_NISA', 'US_STANDARD', 'US_NISA', 'ADR_STANDARD')
  ),
  foreign_tax NUMERIC(15, 2) DEFAULT 0,
  domestic_tax NUMERIC(15, 2) DEFAULT 0,

  -- 為替（外国株の場合）
  exchange_rate NUMERIC(10, 4),
  amount_jpy NUMERIC(15, 2),

  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_dividends_user_id ON dividends(user_id);
CREATE INDEX idx_dividends_holding_id ON dividends(holding_id);
CREATE INDEX idx_dividends_received_date ON dividends(received_date);
```

**カラム説明:**

- `holding_id`: どの口座のどの銘柄か
- `shares_at_payment`: 配当受取時の株数
- `tax_type`: 税区分
- `exchange_rate`: 受取時の為替レート
- `amount_jpy`: 円換算額

---

### 6. exchange_rates

**説明**: 為替レート履歴

```sql
CREATE TABLE exchange_rates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL UNIQUE,
  usd_jpy NUMERIC(10, 4) NOT NULL CHECK (usd_jpy > 0),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_exchange_rates_date ON exchange_rates(date DESC);
```

**カラム説明:**

- `date`: 日付
- `usd_jpy`: USD/JPY為替レート

**更新頻度**: 1日1回（バッチ処理）

---

### 7. stock_price_history

**説明**: 株価履歴（四半期別資産額計算用）

```sql
CREATE TABLE stock_price_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stock_id UUID NOT NULL REFERENCES stocks(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  close_price NUMERIC(12, 4) NOT NULL CHECK (close_price > 0),
  created_at TIMESTAMPTZ DEFAULT NOW(),

  UNIQUE(stock_id, date)
);

CREATE INDEX idx_stock_price_history_stock_date ON stock_price_history(stock_id, date DESC);
```

**カラム説明:**

- `close_price`: 終値

**更新頻度**: 1日1回（バッチ処理）

---

## 🔒 Row Level Security (RLS)

### 基本方針

**ユーザーは自分のデータのみアクセス可能**

### 1. securities_accounts

```sql
ALTER TABLE securities_accounts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own accounts"
  ON securities_accounts FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own accounts"
  ON securities_accounts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own accounts"
  ON securities_accounts FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own accounts"
  ON securities_accounts FOR DELETE
  USING (auth.uid() = user_id);
```

### 2. stocks（全ユーザー共通）

```sql
ALTER TABLE stocks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view stocks"
  ON stocks FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert stocks"
  ON stocks FOR INSERT
  TO authenticated
  WITH CHECK (true);
```

### 3. holdings

```sql
ALTER TABLE holdings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own holdings"
  ON holdings FOR ALL
  USING (auth.uid() = user_id);
```

### 4. dividends

```sql
ALTER TABLE dividends ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own dividends"
  ON dividends FOR ALL
  USING (auth.uid() = user_id);
```

### 5. exchange_rates, stock_price_history（全ユーザー読み取り可）

```sql
ALTER TABLE exchange_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_price_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view exchange_rates"
  ON exchange_rates FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Anyone can view stock_price_history"
  ON stock_price_history FOR SELECT
  TO authenticated
  USING (true);
```

---

## 📊 ビュー（集計用）

### 1. stock_totals（銘柄別合計保有情報）

```sql
CREATE VIEW stock_totals AS
SELECT
  h.stock_id,
  h.user_id,
  s.symbol,
  s.name,
  s.market,
  SUM(h.shares) as total_shares,
  SUM(h.total_cost) as total_cost,
  SUM(h.total_cost) / SUM(h.shares) as average_price
FROM holdings h
JOIN stocks s ON h.stock_id = s.id
GROUP BY h.stock_id, h.user_id, s.symbol, s.name, s.market;
```

### 2. dividend_totals（銘柄別累積配当）

```sql
CREATE VIEW dividend_totals AS
SELECT
  h.stock_id,
  h.user_id,
  SUM(d.amount_after_tax) as cumulative_dividend_after_tax,
  SUM(d.amount_before_tax) as cumulative_dividend_before_tax,
  COUNT(*) as dividend_count
FROM dividends d
JOIN holdings h ON d.holding_id = h.id
GROUP BY h.stock_id, h.user_id;
```

### 3. portfolio_summary（ポートフォリオサマリー）

```sql
CREATE VIEW portfolio_summary AS
SELECT
  st.user_id,
  SUM(st.total_shares * s.current_price *
    CASE WHEN s.currency = 'USD'
    THEN (SELECT usd_jpy FROM exchange_rates ORDER BY date DESC LIMIT 1)
    ELSE 1 END
  ) as total_market_value,
  SUM(st.total_cost) as total_investment,
  COALESCE(SUM(dt.cumulative_dividend_after_tax), 0) as total_dividends
FROM stock_totals st
JOIN stocks s ON st.stock_id = s.id
LEFT JOIN dividend_totals dt ON st.stock_id = dt.stock_id AND st.user_id = dt.user_id
GROUP BY st.user_id;
```

---

## 🔄 トリガー

### 1. updated_at自動更新

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_securities_accounts_updated_at
  BEFORE UPDATE ON securities_accounts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_holdings_updated_at
  BEFORE UPDATE ON holdings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_dividends_updated_at
  BEFORE UPDATE ON dividends
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

## 📈 インデックス戦略

### よく検索されるカラム

**holdings:**

- `user_id` + `stock_id`（銘柄別集計）
- `account_id`（口座別表示）

**dividends:**

- `user_id` + `received_date`（年別集計）
- `holding_id`（銘柄別配当履歴）

**stocks:**

- `symbol`（銘柄検索）
- `market`（市場フィルター）

---

## 🔄 マイグレーション管理

### Supabase CLIを使用

```bash
# 新しいマイグレーション作成
supabase migration new create_tables

# マイグレーション実行
supabase migration up

# ロールバック
supabase migration down
```

### マイグレーションファイル例

```sql
-- supabase/migrations/20250115000001_create_tables.sql

-- 証券口座テーブル
CREATE TABLE securities_accounts (...);

-- 銘柄マスターテーブル
CREATE TABLE stocks (...);

-- その他のテーブル...
```

---

## 💾 データ容量見積もり

### 1ユーザーあたりのデータサイズ

```
stocks:           1,000銘柄 × 1KB  = 1MB（全ユーザー共通）
holdings:         20銘柄 × 1KB     = 20KB
dividends:        200件 × 500B     = 100KB
exchange_rates:   365日 × 100B     = 36KB（全ユーザー共通）
stock_price_history: 100銘柄 × 365日 × 100B = 3.6MB（全ユーザー共通）

1ユーザー合計: 約120KB
```

### Supabase無料枠（500MB）での想定

```
約4,000ユーザーまで対応可能
（実際は共通データがあるためもっと多い）
```

---

## 🔧 バックアップ戦略

### Supabase自動バックアップ

**無料プラン:**

- 7日間のPoint-in-Time Recovery

**有料プラン（Pro: $25/月）:**

- 30日間のPoint-in-Time Recovery
- 手動バックアップ

### エクスポート機能

**CSV/JSONエクスポート:**

- ユーザーごとにデータをエクスポート
- 定期的なローカルバックアップ推奨

---

## 📊 パフォーマンス最適化

### N+1問題の回避

**悪い例:**

```typescript
// 銘柄ごとにクエリ（N+1問題）
for (const holding of holdings) {
  const stock = await supabase.from('stocks').select('*').eq('id', holding.stock_id);
}
```

**良い例:**

```typescript
// JOINで一度に取得
const { data } = await supabase.from('holdings').select('*, stock:stocks(*)').eq('user_id', userId);
```

### ページング

```typescript
// 大量データはページング
const { data } = await supabase
  .from('dividends')
  .select('*')
  .order('received_date', { ascending: false })
  .range(0, 49); // 最初の50件
```

---

## 🧪 テストデータ

### シードデータ作成

```sql
-- supabase/seed.sql

-- テストユーザー（Supabase Authで作成）
-- テスト用証券口座
INSERT INTO securities_accounts (user_id, account_name, account_type) VALUES
  ('user-uuid', 'SBI証券', '特定口座'),
  ('user-uuid', '楽天証券', 'NISA');

-- テスト用銘柄
INSERT INTO stocks (symbol, name, market, currency, current_price, dividend_yield) VALUES
  ('AAPL', 'Apple Inc.', 'US', 'USD', 178.50, 0.0052),
  ('7203.T', 'トヨタ自動車', 'JP', 'JPY', 3200, 0.025);

-- テスト用保有銘柄
INSERT INTO holdings (user_id, account_id, stock_id, shares, average_price, total_cost) VALUES
  ('user-uuid', 'account-1-uuid', 'stock-1-uuid', 100, 150.00, 2100000);

-- テスト用配当
INSERT INTO dividends (user_id, holding_id, received_date, shares_at_payment, amount_after_tax, tax_type) VALUES
  ('user-uuid', 'holding-1-uuid', '2025-01-15', 100, 2512, 'US_STANDARD');
```

---

## 📝 まとめ

- **正規化**: 第3正規形で冗長性を排除
- **RLS**: ユーザーごとのデータ分離
- **インデックス**: よく検索するカラムに設定
- **ビュー**: 複雑な集計を簡素化
- **トリガー**: updated_atの自動更新

このデータベース設計により、安全で効率的なデータ管理が可能になります。
