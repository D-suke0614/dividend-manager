# データベースER図

配当管理アプリケーションのデータベース構造を視覚化したER図です。

## Phase 1 完全版ER図

```mermaid
erDiagram
    %% ========================================
    %% ユーザー関連
    %% ========================================
    auth_users ||--o{ securities_accounts : "所有"
    auth_users ||--o| user_profiles : "設定"
    auth_users ||--o{ holdings : "保有"
    auth_users ||--o{ dividends : "配当受取"
    auth_users ||--o{ transactions : "売買履歴"

    %% ========================================
    %% 証券口座と銘柄の関係
    %% ========================================
    securities_accounts ||--o{ holdings : "口座内保有"
    securities_accounts ||--o{ transactions : "口座内取引"

    stocks ||--o{ holdings : "銘柄"
    stocks ||--o{ transactions : "取引銘柄"
    stocks ||--o{ stock_price_history : "価格履歴"

    %% ========================================
    %% 保有と配当の関係
    %% ========================================
    holdings ||--o{ dividends : "配当"

    %% ========================================
    %% テーブル定義
    %% ========================================

    auth_users {
        uuid id PK "ユーザーID"
        string email UK "メールアドレス"
        timestamp created_at "作成日時"
    }

    user_profiles {
        uuid id PK "プロファイルID"
        uuid user_id FK "ユーザーID"
        string default_currency "デフォルト通貨(JPY/USD)"
        integer decimal_places "小数点桁数(0-4)"
        string dividend_month_format "配当月表示形式"
        boolean auto_update_enabled "自動更新有効フラグ"
        time update_time "更新実行時刻"
        timestamp created_at "作成日時"
        timestamp updated_at "更新日時"
    }

    securities_accounts {
        uuid id PK "証券口座ID"
        uuid user_id FK "ユーザーID"
        text account_name "口座名(例:SBI証券)"
        text account_type "口座種別(特定/NISA等)"
        integer display_order "表示順"
        timestamp created_at "作成日時"
        timestamp updated_at "更新日時"
    }

    stocks {
        uuid id PK "銘柄ID"
        text symbol UK "ティッカーシンボル"
        text name "銘柄名"
        text market "市場(JP/US/ADR)"
        text currency "通貨(JPY/USD)"
        text sector "セクター"
        numeric current_price "現在株価"
        numeric dividend_yield "配当利回り"
        numeric latest_dividend_per_share "最新1株配当"
        date ex_dividend_date "権利落ち日"
        integer_array dividend_months "配当月"
        timestamp last_updated "最終更新日時"
        timestamp created_at "作成日時"
    }

    holdings {
        uuid id PK "保有ID"
        uuid user_id FK "ユーザーID"
        uuid account_id FK "証券口座ID"
        uuid stock_id FK "銘柄ID"
        integer shares "保有株数"
        numeric average_price "平均取得単価"
        numeric total_cost "取得価格合計"
        boolean is_active "アクティブフラグ"
        timestamp created_at "作成日時"
        timestamp updated_at "更新日時"
    }

    transactions {
        uuid id PK "取引ID"
        uuid user_id FK "ユーザーID"
        uuid account_id FK "証券口座ID"
        uuid stock_id FK "銘柄ID"
        text transaction_type "取引種別(BUY/SELL)"
        date transaction_date "取引日"
        integer shares "取引株数"
        numeric price_per_share "1株単価"
        numeric total_amount "取引総額"
        numeric fees "手数料"
        numeric exchange_rate "為替レート"
        text notes "備考"
        timestamp created_at "作成日時"
        timestamp updated_at "更新日時"
    }

    dividends {
        uuid id PK "配当ID"
        uuid user_id FK "ユーザーID"
        uuid holding_id FK "保有ID"
        date received_date "受取日"
        integer shares_at_payment "受取時株数"
        numeric dividend_per_share_before_tax "1株配当(税引前)"
        numeric amount_before_tax "配当額(税引前)"
        numeric amount_after_tax "配当額(税引後)"
        text tax_type "税区分"
        numeric foreign_tax "外国源泉税"
        numeric domestic_tax "国内税"
        numeric exchange_rate "為替レート"
        numeric amount_jpy "円換算額"
        text notes "備考"
        timestamp created_at "作成日時"
        timestamp updated_at "更新日時"
    }

    exchange_rates {
        uuid id PK "為替レートID"
        date date UK "日付"
        numeric usd_jpy "USD/JPY為替レート"
        timestamp created_at "作成日時"
    }

    stock_price_history {
        uuid id PK "株価履歴ID"
        uuid stock_id FK "銘柄ID"
        date date "日付"
        numeric close_price "終値"
        timestamp created_at "作成日時"
    }
```

---

## 簡易版ER図（リレーションシップ重視）

```mermaid
graph TB
    subgraph "ユーザー管理"
        Users[auth.users<br/>認証ユーザー]
        Profiles[user_profiles<br/>ユーザー設定]
    end

    subgraph "口座・銘柄管理"
        Accounts[securities_accounts<br/>証券口座]
        Stocks[stocks<br/>銘柄マスター]
    end

    subgraph "取引・保有管理"
        Transactions[transactions<br/>売買履歴]
        Holdings[holdings<br/>保有銘柄]
    end

    subgraph "配当管理"
        Dividends[dividends<br/>配当履歴]
    end

    subgraph "マスターデータ"
        ExchangeRates[exchange_rates<br/>為替レート]
        PriceHistory[stock_price_history<br/>株価履歴]
    end

    Users -->|1:1| Profiles
    Users -->|1:N| Accounts
    Users -->|1:N| Holdings
    Users -->|1:N| Transactions
    Users -->|1:N| Dividends

    Accounts -->|1:N| Holdings
    Accounts -->|1:N| Transactions

    Stocks -->|1:N| Holdings
    Stocks -->|1:N| Transactions
    Stocks -->|1:N| PriceHistory

    Holdings -->|1:N| Dividends

    style Users fill:#e1f5ff
    style Profiles fill:#e1f5ff
    style Accounts fill:#fff4e1
    style Stocks fill:#fff4e1
    style Transactions fill:#e8f5e9
    style Holdings fill:#e8f5e9
    style Dividends fill:#f3e5f5
    style ExchangeRates fill:#fce4ec
    style PriceHistory fill:#fce4ec
```

---

## テーブルカテゴリ別の説明

### 🔐 認証・ユーザー管理

| テーブル      | 目的         | 備考                       |
| ------------- | ------------ | -------------------------- |
| auth.users    | Supabase認証 | Supabase Authが管理        |
| user_profiles | ユーザー設定 | 表示設定、自動更新設定など |

### 💼 証券口座・銘柄マスター

| テーブル            | 目的         | 備考              |
| ------------------- | ------------ | ----------------- |
| securities_accounts | 証券口座管理 | SBI、楽天証券など |
| stocks              | 銘柄マスター | 全ユーザー共通    |

### 📊 取引・保有データ

| テーブル     | 目的     | 備考                   |
| ------------ | -------- | ---------------------- |
| transactions | 売買履歴 | 平均取得単価計算の基盤 |
| holdings     | 保有銘柄 | 現在の保有状況         |
| dividends    | 配当履歴 | 受取配当の記録         |

### 🌐 マスターデータ

| テーブル            | 目的       | 備考                 |
| ------------------- | ---------- | -------------------- |
| exchange_rates      | 為替レート | 1日1回更新           |
| stock_price_history | 株価履歴   | 四半期別資産額計算用 |

---

## 主要なリレーションシップ

### 1. ユーザー → 証券口座 → 保有銘柄

```
auth.users (1) ---> (N) securities_accounts (1) ---> (N) holdings
```

- 1ユーザーは複数の証券口座を持つ
- 1証券口座は複数の保有銘柄を持つ

### 2. 保有銘柄 → 配当履歴

```
holdings (1) ---> (N) dividends
```

- 1つの保有銘柄は複数の配当履歴を持つ

### 3. 銘柄マスター → 保有銘柄

```
stocks (1) ---> (N) holdings
```

- 1つの銘柄は複数のユーザーに保有される（全ユーザー共通）

### 4. 証券口座 → 売買履歴

```
securities_accounts (1) ---> (N) transactions
stocks (1) ---> (N) transactions
```

- 売買履歴は口座と銘柄の両方に紐づく

---

## データフロー

```mermaid
sequenceDiagram
    participant User as ユーザー
    participant Profile as user_profiles
    participant Account as securities_accounts
    participant Stock as stocks
    participant Trans as transactions
    participant Hold as holdings
    participant Div as dividends

    User->>Profile: 1. ユーザー登録時に設定作成
    User->>Account: 2. 証券口座を登録
    User->>Stock: 3. 銘柄を検索（共通マスター）
    User->>Trans: 4. 購入取引を記録
    Trans->>Hold: 5. 保有銘柄を更新（平均取得単価計算）
    User->>Div: 6. 配当を受取り記録
    Div->>Hold: 7. 保有銘柄に紐づけ
```

---

## インデックス戦略

### 複合インデックス

```sql
-- よく使われる検索パターンに対応
CREATE INDEX idx_holdings_active ON holdings(user_id, is_active);
CREATE INDEX idx_transactions_date ON transactions(transaction_date DESC);
CREATE INDEX idx_dividends_received_date ON dividends(received_date DESC);
```

### 外部キーインデックス

```sql
-- JOIN性能の向上
CREATE INDEX idx_holdings_user_id ON holdings(user_id);
CREATE INDEX idx_holdings_account_id ON holdings(account_id);
CREATE INDEX idx_holdings_stock_id ON holdings(stock_id);
CREATE INDEX idx_transactions_user_id ON transactions(user_id);
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_dividends_holding_id ON dividends(holding_id);
```

---

## RLS（Row Level Security）適用状況

| テーブル            | RLSポリシー         | 説明                           |
| ------------------- | ------------------- | ------------------------------ |
| user_profiles       | ✅ ユーザー自身のみ | 自分の設定のみアクセス可       |
| securities_accounts | ✅ ユーザー自身のみ | 自分の口座のみアクセス可       |
| holdings            | ✅ ユーザー自身のみ | 自分の保有銘柄のみアクセス可   |
| transactions        | ✅ ユーザー自身のみ | 自分の取引履歴のみアクセス可   |
| dividends           | ✅ ユーザー自身のみ | 自分の配当履歴のみアクセス可   |
| stocks              | ✅ 認証ユーザー全員 | 全ユーザー共通（読み取りのみ） |
| exchange_rates      | ✅ 認証ユーザー全員 | 全ユーザー共通（読み取りのみ） |
| stock_price_history | ✅ 認証ユーザー全員 | 全ユーザー共通（読み取りのみ） |

---

## 制約（Constraints）

### UNIQUE制約

```sql
-- 重複防止
holdings: UNIQUE(account_id, stock_id)  -- 同一口座で同一銘柄は1レコードのみ
exchange_rates: UNIQUE(date)            -- 1日1レートのみ
stock_price_history: UNIQUE(stock_id, date)  -- 1銘柄1日1価格のみ
```

### CHECK制約

```sql
-- データ整合性
holdings: CHECK (shares > 0)
holdings: CHECK (average_price > 0)
dividends: CHECK (amount_after_tax > 0)
transactions: CHECK (shares > 0)
transactions: CHECK (price_per_share > 0)
```

### 外部キー制約

```sql
-- 参照整合性（ON DELETE CASCADE）
holdings.user_id → auth.users(id)
holdings.account_id → securities_accounts(id)
holdings.stock_id → stocks(id)
dividends.holding_id → holdings(id)
transactions.account_id → securities_accounts(id)
```

---

## トリガー

### updated_at自動更新

以下のテーブルで`updated_at`カラムが自動更新されます：

- ✅ securities_accounts
- ✅ holdings
- ✅ dividends
- ✅ user_profiles
- ✅ transactions

```sql
CREATE TRIGGER update_{table_name}_updated_at
  BEFORE UPDATE ON {table_name}
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

## Phase 2以降の拡張予定

将来追加を検討しているテーブル：

```mermaid
graph LR
    subgraph "Phase 2-3で追加検討"
        BatchLogs[batch_execution_logs<br/>バッチ実行ログ]
        Forecasts[dividend_forecasts<br/>配当予測]
        Watchlist[watchlist<br/>ウォッチリスト]
    end

    subgraph "Phase 4以降"
        Notifications[notification_settings<br/>通知設定]
        AuditLogs[audit_logs<br/>監査ログ]
        Snapshots[portfolio_snapshots<br/>スナップショット]
    end

    style BatchLogs fill:#fff9c4
    style Forecasts fill:#fff9c4
    style Watchlist fill:#fff9c4
    style Notifications fill:#f0f0f0
    style AuditLogs fill:#f0f0f0
    style Snapshots fill:#f0f0f0
```

---

## 参考資料

- [database.md](../initial-docs/database.md) - 詳細なテーブル定義
- [setup_scratch.md](../initial-docs/setup_scratch.md) - セットアップ手順
- [Supabase RLS ドキュメント](https://supabase.com/docs/guides/auth/row-level-security)
- [Mermaid ER図 構文](https://mermaid.js.org/syntax/entityRelationshipDiagram.html)
