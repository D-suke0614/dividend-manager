# ゼロからプロジェクトを構築する手順

このドキュメントでは、配当管理アプリを**完全にゼロから構築する手順**を説明します。

既存のリポジトリをクローンして開発を始める場合は、[DEVELOPMENT.md](./DEVELOPMENT.md) を参照してください。

---

## 📋 前提条件

- Node.js 20.x LTS
- pnpm 8.x以上
- Docker Desktop
- Supabaseアカウント（本番環境用）

---

## 🎯 構築手順

### Phase 1: Next.jsプロジェクトの初期化

#### 1-1. Next.jsプロジェクトを作成

```bash
# pnpmでNext.jsプロジェクトを作成
pnpm create next-app@latest dividend-manager

# プロンプトで以下を選択:
# ✔ Would you like to use TypeScript? › Yes
# ✔ Would you like to use ESLint? › Yes
# ✔ Would you like to use Tailwind CSS? › Yes
# ✔ Would you like to use `src/` directory? › No
# ✔ Would you like to use App Router? › Yes
# ✔ Would you like to customize the default import alias (@/*)? › Yes
# ✔ What import alias would you like configured? › @/*

cd dividend-manager
```

#### 1-2. 基本的な依存関係をインストール

```bash
# 日付処理
pnpm add date-fns

# フォーム管理
pnpm add react-hook-form @hookform/resolvers zod

# 状態管理
pnpm add zustand

# グラフライブラリ
pnpm add recharts

# アイコン
pnpm add lucide-react

# 開発依存関係
pnpm add -D @types/node typescript
```

---

### Phase 2: Tailwind CSS + shadcn/ui のセットアップ

#### 2-1. shadcn/ui の初期化

```bash
pnpm dlx shadcn-ui@latest init

# プロンプトで以下を選択:
# ✔ Would you like to use TypeScript? › yes
# ✔ Which style would you like to use? › Default
# ✔ Which color would you like to use as base color? › Slate
# ✔ Where is your global CSS file? › app/globals.css
# ✔ Would you like to use CSS variables for colors? › yes
# ✔ Where is your tailwind.config.js located? › tailwind.config.ts
# ✔ Configure the import alias for components: › @/components
# ✔ Configure the import alias for utils: › @/lib/utils
# ✔ Are you using React Server Components? › yes
```

#### 2-2. 必要なコンポーネントを追加

```bash
# よく使うコンポーネントを一括追加
pnpm dlx shadcn-ui@latest add button
pnpm dlx shadcn-ui@latest add card
pnpm dlx shadcn-ui@latest add table
pnpm dlx shadcn-ui@latest add form
pnpm dlx shadcn-ui@latest add input
pnpm dlx shadcn-ui@latest add select
pnpm dlx shadcn-ui@latest add dialog
pnpm dlx shadcn-ui@latest add dropdown-menu
pnpm dlx shadcn-ui@latest add calendar
pnpm dlx shadcn-ui@latest add popover
pnpm dlx shadcn-ui@latest add toast
pnpm dlx shadcn-ui@latest add tabs
pnpm dlx shadcn-ui@latest add separator
pnpm dlx shadcn-ui@latest add badge
pnpm dlx shadcn-ui@latest add alert
```

---

### Phase 3: Supabaseのセットアップ

#### 3-1. Supabase CLIをインストール

```bash
# macOS
brew install supabase/tap/supabase

# Windows (Scoop)
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase

# Linux
brew install supabase/tap/supabase
```

**確認:**
```bash
supabase --version
```

#### 3-2. Supabaseプロジェクトを初期化

```bash
# プロジェクトディレクトリで実行
supabase init

# 以下のファイル/ディレクトリが作成されます:
# supabase/
#   ├── config.toml
#   ├── seed.sql
#   └── migrations/
```

#### 3-3. Supabase依存関係をインストール

```bash
# Supabaseクライアント
pnpm add @supabase/supabase-js @supabase/ssr

# 型定義生成用
pnpm add -D supabase
```

#### 3-4. ローカルSupabaseを起動

```bash
# Docker Desktopが起動していることを確認
supabase start

# 初回は時間がかかります（イメージのダウンロード）
# 完了すると以下が表示されます:
# API URL: http://localhost:54321
# DB URL: postgresql://postgres:postgres@localhost:54322/postgres
# Studio URL: http://localhost:54323
# anon key: eyJhbGc...
# service_role key: eyJhbGc...
```

#### 3-5. 環境変数を設定

```bash
# .env.localファイルを作成
touch .env.local
```

**.env.local に以下を記載:**
```bash
# Supabase（ローカル開発用）
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=<anon keyをコピー>
SUPABASE_SERVICE_ROLE_KEY=<service_role keyをコピー>
```

**注意:** `supabase start` コマンドの出力から、anon keyとservice_role keyをコピーしてください。

#### 3-6. Supabaseクライアントを作成

**クライアントサイド用:**
```bash
mkdir -p lib/supabase
touch lib/supabase/client.ts
```

**lib/supabase/client.ts:**
```typescript
import { createBrowserClient } from '@supabase/ssr'

export const createClient = () =>
  createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
```

**サーバーサイド用:**
```bash
touch lib/supabase/server.ts
```

**lib/supabase/server.ts:**
```typescript
import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { cookies } from 'next/headers'

export const createClient = () => {
  const cookieStore = cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value
        },
        set(name: string, value: string, options: CookieOptions) {
          try {
            cookieStore.set({ name, value, ...options })
          } catch (error) {
            // Server Component内ではset/removeができない場合がある
          }
        },
        remove(name: string, options: CookieOptions) {
          try {
            cookieStore.set({ name, value: '', ...options })
          } catch (error) {
            // Server Component内ではset/removeができない場合がある
          }
        },
      },
    }
  )
}
```

---

### Phase 4: データベースのセットアップ

#### 4-1. マイグレーションファイルを作成

```bash
# 最初のマイグレーションファイルを作成
supabase migration new create_initial_tables
```

**supabase/migrations/[timestamp]_create_initial_tables.sql に以下を記載:**

```sql
-- 証券口座テーブル
CREATE TABLE securities_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  account_name TEXT NOT NULL,
  account_type TEXT NOT NULL CHECK (account_type IN ('特定口座', 'NISA', 'つみたてNISA')),
  display_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_securities_accounts_user_id ON securities_accounts(user_id);

-- 銘柄マスターテーブル
CREATE TABLE stocks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  symbol TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  market TEXT NOT NULL CHECK (market IN ('JP', 'US', 'ADR')),
  currency TEXT DEFAULT 'USD' CHECK (currency IN ('USD', 'JPY')),
  sector TEXT,
  current_price NUMERIC(12, 4),
  dividend_yield NUMERIC(6, 4),
  latest_dividend_per_share NUMERIC(10, 4),
  ex_dividend_date DATE,
  dividend_months INTEGER[],
  last_updated TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_stocks_symbol ON stocks(symbol);
CREATE INDEX idx_stocks_market ON stocks(market);

-- 保有銘柄テーブル
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

-- 配当履歴テーブル
CREATE TABLE dividends (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  holding_id UUID NOT NULL REFERENCES holdings(id) ON DELETE CASCADE,
  received_date DATE NOT NULL,
  shares_at_payment INTEGER NOT NULL CHECK (shares_at_payment > 0),
  dividend_per_share_before_tax NUMERIC(10, 4),
  amount_before_tax NUMERIC(15, 2),
  amount_after_tax NUMERIC(15, 2) NOT NULL CHECK (amount_after_tax > 0),
  tax_type TEXT NOT NULL CHECK (
    tax_type IN ('JP_STANDARD', 'JP_NISA', 'US_STANDARD', 'US_NISA', 'ADR_STANDARD')
  ),
  foreign_tax NUMERIC(15, 2) DEFAULT 0,
  domestic_tax NUMERIC(15, 2) DEFAULT 0,
  exchange_rate NUMERIC(10, 4),
  amount_jpy NUMERIC(15, 2),
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_dividends_user_id ON dividends(user_id);
CREATE INDEX idx_dividends_holding_id ON dividends(holding_id);
CREATE INDEX idx_dividends_received_date ON dividends(received_date);

-- 為替レートテーブル
CREATE TABLE exchange_rates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL UNIQUE,
  usd_jpy NUMERIC(10, 4) NOT NULL CHECK (usd_jpy > 0),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_exchange_rates_date ON exchange_rates(date DESC);

-- 株価履歴テーブル
CREATE TABLE stock_price_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  stock_id UUID NOT NULL REFERENCES stocks(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  close_price NUMERIC(12, 4) NOT NULL CHECK (close_price > 0),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(stock_id, date)
);

CREATE INDEX idx_stock_price_history_stock_date ON stock_price_history(stock_id, date DESC);

-- updated_at自動更新トリガー
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

#### 4-2. RLSポリシーを設定

```bash
# RLS用のマイグレーションファイルを作成
supabase migration new enable_rls
```

**supabase/migrations/[timestamp]_enable_rls.sql:**

```sql
-- securities_accounts のRLS
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

-- stocks のRLS（全ユーザー共通）
ALTER TABLE stocks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view stocks"
  ON stocks FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Authenticated users can insert stocks"
  ON stocks FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- holdings のRLS
ALTER TABLE holdings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own holdings"
  ON holdings FOR ALL
  USING (auth.uid() = user_id);

-- dividends のRLS
ALTER TABLE dividends ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own dividends"
  ON dividends FOR ALL
  USING (auth.uid() = user_id);

-- exchange_rates のRLS（全ユーザー読み取り可）
ALTER TABLE exchange_rates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view exchange_rates"
  ON exchange_rates FOR SELECT
  TO authenticated
  USING (true);

-- stock_price_history のRLS（全ユーザー読み取り可）
ALTER TABLE stock_price_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view stock_price_history"
  ON stock_price_history FOR SELECT
  TO authenticated
  USING (true);
```

#### 4-3. マイグレーションを実行

```bash
# ローカルデータベースにマイグレーションを適用
supabase db reset
```

#### 4-4. TypeScript型定義を生成

```bash
# Supabaseの型定義を生成
supabase gen types typescript --local > types/database.ts
```

**package.jsonにスクリプトを追加:**
```json
{
  "scripts": {
    "supabase:start": "supabase start",
    "supabase:stop": "supabase stop",
    "supabase:reset": "supabase db reset",
    "supabase:migrate": "supabase migration up",
    "supabase:gen-types": "supabase gen types typescript --local > types/database.ts",
    "supabase:seed": "supabase db reset --seed-only"
  }
}
```

#### 4-5. シードデータを作成（オプション）

**supabase/seed.sql:**

```sql
-- テスト用銘柄データ
INSERT INTO stocks (symbol, name, market, currency, current_price, dividend_yield, latest_dividend_per_share, sector) VALUES
  ('AAPL', 'Apple Inc.', 'US', 'USD', 178.50, 0.0052, 0.93, 'Technology'),
  ('MSFT', 'Microsoft Corporation', 'US', 'USD', 420.55, 0.0078, 3.28, 'Technology'),
  ('JNJ', 'Johnson & Johnson', 'US', 'USD', 155.20, 0.0295, 4.58, 'Healthcare'),
  ('7203.T', 'トヨタ自動車', 'JP', 'JPY', 3200, 0.025, 80, 'Automotive'),
  ('9434.T', 'ソフトバンク', 'JP', 'JPY', 1850, 0.054, 100, 'Telecommunications');

-- テスト用為替レート
INSERT INTO exchange_rates (date, usd_jpy) VALUES
  (CURRENT_DATE, 140.50),
  (CURRENT_DATE - INTERVAL '1 day', 140.20),
  (CURRENT_DATE - INTERVAL '2 days', 139.80);
```

**シードデータを投入:**
```bash
pnpm supabase:seed
```

---

### Phase 5: tRPCのセットアップ

#### 5-1. tRPC依存関係をインストール

```bash
pnpm add @trpc/server @trpc/client @trpc/react-query @trpc/next @tanstack/react-query superjson
```

#### 5-2. tRPCサーバーを設定

**server/context.ts:**
```typescript
import { createClient } from '@/lib/supabase/server'

export const createContext = async () => {
  const supabase = createClient()

  const { data: { user } } = await supabase.auth.getUser()

  return {
    supabase,
    userId: user?.id,
  }
}

export type Context = Awaited<ReturnType<typeof createContext>>
```

**server/trpc.ts:**
```typescript
import { initTRPC, TRPCError } from '@trpc/server'
import superjson from 'superjson'
import { Context } from './context'

const t = initTRPC.context<Context>().create({
  transformer: superjson,
})

export const router = t.router
export const publicProcedure = t.procedure

// 認証が必要なプロシージャ
export const privateProcedure = t.procedure.use(async ({ ctx, next }) => {
  if (!ctx.userId) {
    throw new TRPCError({ code: 'UNAUTHORIZED' })
  }
  return next({
    ctx: {
      ...ctx,
      userId: ctx.userId,
    },
  })
})
```

**server/routers/index.ts:**
```typescript
import { router } from '../trpc'
import { dividendRouter } from './dividend'
import { stockRouter } from './stock'
import { accountRouter } from './account'

export const appRouter = router({
  dividend: dividendRouter,
  stock: stockRouter,
  account: accountRouter,
})

export type AppRouter = typeof appRouter
```

**server/routers/dividend.ts（例）:**
```typescript
import { z } from 'zod'
import { router, privateProcedure } from '../trpc'

export const dividendRouter = router({
  getAll: privateProcedure.query(async ({ ctx }) => {
    const { data, error } = await ctx.supabase
      .from('dividends')
      .select('*, holding:holdings(*, stock:stocks(*))')
      .eq('user_id', ctx.userId)
      .order('received_date', { ascending: false })

    if (error) throw error
    return data
  }),

  create: privateProcedure
    .input(
      z.object({
        holdingId: z.string().uuid(),
        receivedDate: z.date(),
        amountAfterTax: z.number().positive(),
        taxType: z.enum(['JP_STANDARD', 'JP_NISA', 'US_STANDARD', 'US_NISA', 'ADR_STANDARD']),
      })
    )
    .mutation(async ({ ctx, input }) => {
      const { data, error } = await ctx.supabase
        .from('dividends')
        .insert({
          user_id: ctx.userId,
          holding_id: input.holdingId,
          received_date: input.receivedDate.toISOString().split('T')[0],
          amount_after_tax: input.amountAfterTax,
          tax_type: input.taxType,
          shares_at_payment: 100, // 実際の値は別途取得
        })
        .select()
        .single()

      if (error) throw error
      return data
    }),
})
```

#### 5-3. tRPCクライアントを設定

**lib/trpc/client.ts:**
```typescript
import { createTRPCReact } from '@trpc/react-query'
import type { AppRouter } from '@/server/routers'

export const trpc = createTRPCReact<AppRouter>()
```

**lib/trpc/server.ts:**
```typescript
import { httpBatchLink } from '@trpc/client'
import { createTRPCProxyClient } from '@trpc/client'
import type { AppRouter } from '@/server/routers'
import superjson from 'superjson'

export const serverTrpc = createTRPCProxyClient<AppRouter>({
  transformer: superjson,
  links: [
    httpBatchLink({
      url: `${process.env.NEXT_PUBLIC_APP_URL}/api/trpc`,
    }),
  ],
})
```

**app/api/trpc/[trpc]/route.ts:**
```typescript
import { fetchRequestHandler } from '@trpc/server/adapters/fetch'
import { appRouter } from '@/server/routers'
import { createContext } from '@/server/context'

const handler = (req: Request) =>
  fetchRequestHandler({
    endpoint: '/api/trpc',
    req,
    router: appRouter,
    createContext,
  })

export { handler as GET, handler as POST }
```

#### 5-4. tRPC Providerを設定

**app/providers.tsx:**
```typescript
'use client'

import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { httpBatchLink } from '@trpc/client'
import { useState } from 'react'
import { trpc } from '@/lib/trpc/client'
import superjson from 'superjson'

export function Providers({ children }: { children: React.ReactNode }) {
  const [queryClient] = useState(() => new QueryClient())
  const [trpcClient] = useState(() =>
    trpc.createClient({
      transformer: superjson,
      links: [
        httpBatchLink({
          url: '/api/trpc',
        }),
      ],
    })
  )

  return (
    <trpc.Provider client={trpcClient} queryClient={queryClient}>
      <QueryClientProvider client={queryClient}>
        {children}
      </QueryClientProvider>
    </trpc.Provider>
  )
}
```

**app/layout.tsx に追加:**
```typescript
import { Providers } from './providers'

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="ja">
      <body>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
```

---

### Phase 6: 外部APIのセットアップ

#### 6-1. yahoo-finance2をインストール

```bash
pnpm add yahoo-finance2
```

#### 6-2. ユーティリティ関数を作成

**lib/yahoo-finance.ts:**
```typescript
import yahooFinance from 'yahoo-finance2'

export async function getStockQuote(symbol: string) {
  try {
    const quote = await yahooFinance.quote(symbol)
    return {
      currentPrice: quote.regularMarketPrice,
      dividendYield: quote.dividendYield,
      dividendRate: quote.dividendRate,
      exDividendDate: quote.exDividendDate,
    }
  } catch (error) {
    console.error('Failed to fetch stock quote:', error)
    return null
  }
}

export async function getDividendHistory(symbol: string) {
  try {
    const result = await yahooFinance.historical(symbol, {
      period1: new Date(Date.now() - 365 * 24 * 60 * 60 * 1000), // 1年前
      events: 'dividends',
    })
    return result
  } catch (error) {
    console.error('Failed to fetch dividend history:', error)
    return []
  }
}
```

#### 6-3. ExchangeRate APIのセットアップ

```bash
# .env.localに追加
echo "EXCHANGE_RATE_API_KEY=your-api-key-here" >> .env.local
```

**lib/exchange-rate.ts:**
```typescript
export async function getExchangeRate(date?: Date): Promise<number> {
  try {
    const apiKey = process.env.EXCHANGE_RATE_API_KEY
    const response = await fetch(
      `https://v6.exchangerate-api.com/v6/${apiKey}/latest/USD`
    )
    const data = await response.json()
    return data.conversion_rates.JPY
  } catch (error) {
    console.error('Failed to fetch exchange rate:', error)
    return 140 // フォールバック値
  }
}
```

---

### Phase 7: 認証ページの作成

#### 7-1. ログインページ

**app/(auth)/login/page.tsx:**
```typescript
'use client'

import { useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { useRouter } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const router = useRouter()
  const supabase = createClient()

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault()
    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    if (!error) {
      router.push('/dashboard')
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center">
      <form onSubmit={handleLogin} className="w-full max-w-md space-y-4">
        <h1 className="text-2xl font-bold">ログイン</h1>
        <Input
          type="email"
          placeholder="メールアドレス"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />
        <Input
          type="password"
          placeholder="パスワード"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
        <Button type="submit" className="w-full">
          ログイン
        </Button>
      </form>
    </div>
  )
}
```

---

### Phase 8: package.jsonスクリプトの設定

**package.json:**
```json
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "next lint",
    "lint:fix": "next lint --fix",
    "format": "prettier --write .",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "test:e2e": "playwright test",
    "test:e2e:ui": "playwright test --ui",
    "supabase:start": "supabase start",
    "supabase:stop": "supabase stop",
    "supabase:reset": "supabase db reset",
    "supabase:migrate": "supabase migration up",
    "supabase:gen-types": "supabase gen types typescript --local > types/database.ts",
    "supabase:seed": "supabase db reset --seed-only"
  }
}
```

---

### Phase 9: 動作確認

#### 9-1. 開発サーバーを起動

```bash
# Supabaseを起動
pnpm supabase:start

# 開発サーバーを起動
pnpm dev
```

#### 9-2. ブラウザで確認

```
http://localhost:3000
```

#### 9-3. テストユーザーを作成

1. Supabase Studioにアクセス: http://localhost:54323
2. Authenticationタブ → Users → Add user
3. メールアドレスとパスワードを設定
4. ログインページでログイン

---

## 📝 まとめ

これで以下が完了しました：

✅ Next.js + TypeScriptプロジェクト
✅ Tailwind CSS + shadcn/ui
✅ Supabase（Auth + Database）
✅ データベーステーブル + RLS
✅ tRPC（型安全なAPI）
✅ yahoo-finance2（株価データ）
✅ ExchangeRate API（為替レート）
✅ 認証ページ

次のステップは、各機能（ダッシュボード、銘柄管理、配当入力など）の実装です。

[DEVELOPMENT.md](./DEVELOPMENT.md) を参照して、開発を進めてください。
