# 技術スタック

## 📦 コア技術

### Frontend Framework

**Next.js 15 (App Router)**

- React Server Components対応
- ファイルベースルーティング
- 画像最適化
- 将来的なiOSアプリ化（WebView）を視野

### Language

**TypeScript 5.x**

- 型安全性
- 開発体験の向上
- tRPCとの完全な統合

### UI Framework

**Tailwind CSS + shadcn/ui**

- ユーティリティファーストCSS
- 高度にカスタマイズ可能なコンポーネント
- アクセシビリティ対応（Radix UIベース）
- 開発速度の向上

**選定理由:**

- コンポーネントをプロジェクトにコピーする方式で完全にカスタマイズ可能
- テーブル、フォーム、ダイアログなど必要なコンポーネントが揃っている
- TypeScript完全対応
- ダークモード対応が容易

---

## 🔧 開発ツール

### API層

**tRPC 10.x**

- エンドツーエンドの型安全性
- React Queryベース（キャッシュ、再取得）
- Zodバリデーション統合

**使用例:**

```typescript
// サーバー側
export const dividendRouter = router({
  getAll: privateProcedure.query(async ({ ctx }) => {
    return await ctx.db.dividends.findMany();
  }),
});

// クライアント側（型が自動推論）
const { data } = trpc.dividend.getAll.useQuery();
```

### フォーム管理

**React Hook Form + Zod**

- 宣言的なバリデーション
- パフォーマンス最適化
- TypeScript型推論

**使用例:**

```typescript
const schema = z.object({
  amountAfterTax: z.number().positive(),
  receivedDate: z.date(),
});

const { register, handleSubmit } = useForm({
  resolver: zodResolver(schema),
});
```

### 状態管理

**Zustand**

- シンプルなAPI
- TypeScript完全対応
- 軽量（約1KB）

**使用ケース:**

- ユーザー設定（表示通貨、小数点桁数）
- グローバルな状態（為替レート、株価キャッシュ）

### 日付処理

**date-fns**

- Tree-shakable（必要な関数のみバンドル）
- イミュータブル
- TypeScript対応

### グラフ

**Recharts**

- React向け
- レスポンシブ
- カスタマイズ可能

**使用するグラフ:**

- 棒グラフ（年別配当）
- 折れ線グラフ（資産額推移）
- エリアグラフ（投資額推移）

---

## 💾 バックエンド

### Database & Auth

**Supabase**

- PostgreSQL（リレーショナルDB）
- 自動REST API生成
- Row Level Security（データ分離）
- 認証機能（メール、OAuth）
- TypeScript型定義自動生成

**無料枠:**

- データベース: 500MB
- 帯域幅: 5GB/月
- 認証ユーザー: 50,000人/月

**選定理由:**

- PostgreSQL（強力なRDB）
- 認証機能が標準装備
- Next.js App Routerと相性抜群
- 無料枠が十分（個人利用〜100人規模）

### External APIs

**yahoo-finance2**

- 株価データ取得
- 配当情報取得
- 無料、APIキー不要

**取得データ:**

- 現在株価
- 配当利回り
- 権利落ち日
- セクター情報
- 配当履歴

**ExchangeRate-API**

- USD/JPY為替レート
- 無料枠: 1,500リクエスト/月

---

## 🧪 テスト

### 単体テスト

**Jest + React Testing Library**

- コンポーネントテスト
- ロジックのテスト

### E2Eテスト

**Playwright**

- ブラウザ自動化
- クロスブラウザテスト
- スクリーンショット比較

### APIモック

**MSW (Mock Service Worker)**

- ネットワークレベルでモック
- 開発・テスト両用

---

## 🎨 コード品質

### Linter & Formatter

**ESLint**

- Next.js推奨設定
- TypeScript対応
- React Hooks ルール

**Prettier**

- コードフォーマット自動化
- チーム内の一貫性

### Git Hooks

**Husky + lint-staged**

- コミット前に自動チェック
- ESLint実行
- Prettier実行
- TypeScript型チェック

---

## 🚀 CI/CD

### GitHub Actions

**ワークフロー:**

1. Lint & Type Check
2. Unit Tests
3. E2E Tests
4. Build
5. Deploy (Vercelへ自動デプロイ)

**設定ファイル:**

```yaml
# .github/workflows/ci.yml
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: pnpm lint
      - run: pnpm tsc --noEmit
  test:
    runs-on: ubuntu-latest
    steps:
      - run: pnpm test
  e2e:
    runs-on: ubuntu-latest
    steps:
      - run: pnpm test:e2e
```

---

## 🌐 デプロイ

### ホスティング

**Vercel**

- Next.js開発元が提供
- 自動デプロイ（GitHubプッシュ時）
- Edge Functions
- 画像最適化
- プレビューデプロイ

**無料枠（Hobby）:**

- 100GB帯域幅/月
- 6,000分ビルド時間/月
- ⚠️ 個人プロジェクト限定（商用はPro: $20/月）

**将来の選択肢:**

- Cloudflare Pages（完全無料で商用利用可）

---

## 🐳 開発環境

### Docker

**用途: Supabaseローカル開発のみ**

```bash
# Supabase CLI で自動的にDocker起動
supabase start
```

**起動されるサービス:**

- PostgreSQL (5432)
- Supabase Studio (54323)
- GoTrue (認証)
- PostgREST (API)

### Package Manager

**pnpm**

- ディスク容量節約
- 高速インストール
- モノレポ対応

---

## 📊 アーキテクチャ

```
┌─────────────┐
│   Browser   │
└──────┬──────┘
       │
       ↓ (HTTP/tRPC)
┌─────────────────────────────┐
│   Next.js 15 (App Router)   │
│  ┌─────────────────────┐    │
│  │  Server Components  │    │
│  │  (SSR/RSC)         │    │
│  └─────────────────────┘    │
│  ┌─────────────────────┐    │
│  │  Client Components  │    │
│  │  (React Hooks)     │    │
│  └─────────────────────┘    │
│  ┌─────────────────────┐    │
│  │  API Routes (tRPC)  │ ◄──── BFF層
│  └─────────────────────┘    │
└──────────┬──────────────────┘
           │
           ↓
    ┌──────────────┐
    │   Supabase   │
    │ (PostgreSQL) │
    └──────────────┘
           │
           ↓
    ┌──────────────┐
    │ yahoo-finance│
    │  (External)  │
    └──────────────┘
```

**FE → BFF → BE 構成:**

- **FE**: React Server/Client Components
- **BFF**: Next.js API Routes (tRPC)
- **BE**: Supabase + External APIs

---

## 🔐 セキュリティ

### 認証

**Supabase Auth**

- JWT（JSON Web Token）
- HTTPOnly Cookie
- リフレッシュトークン

### データ保護

**Row Level Security (RLS)**

```sql
-- ユーザーは自分のデータのみアクセス可能
CREATE POLICY "Users can only access own data"
  ON dividends FOR ALL
  USING (auth.uid() = user_id);
```

### 環境変数

```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...
SUPABASE_SERVICE_ROLE_KEY=eyJ... # サーバーサイドのみ
```

---

## 📈 パフォーマンス最適化

### Next.js最適化

- **React Server Components**: 初期ロードを高速化
- **Partial Prerendering**: 静的部分は事前生成
- **Image Optimization**: 自動WebP変換、遅延読み込み
- **Font Optimization**: Google Fonts最適化

### データベース最適化

- **インデックス**: よく検索するカラムに設定
- **ビュー**: 複雑なクエリを事前計算
- **キャッシュ**: React Queryでデータキャッシュ

### バンドルサイズ削減

- **Tree Shaking**: 未使用コードを削除
- **Code Splitting**: ルートごとに分割
- **Dynamic Import**: 必要なときだけロード

---

## 🔄 バージョン管理

### 依存関係の更新

```bash
# 依存関係の確認
pnpm outdated

# パッチバージョンのみ更新
pnpm update

# メジャーバージョン更新（慎重に）
pnpm update --latest
```

### Node.js バージョン

**推奨: Node.js 20 LTS**

`.nvmrc` ファイルで固定:

```
20
```

---

## 🎯 開発原則

1. **型安全性**: TypeScript + tRPC で完全な型安全性
2. **テスト駆動**: 重要なロジックは必ずテスト
3. **ドキュメント**: コードはドキュメント、複雑な部分にコメント
4. **パフォーマンス**: 不要な再レンダリングを避ける
5. **アクセシビリティ**: WCAG 2.1準拠

---

## 📚 学習リソース

### 公式ドキュメント

- [Next.js](https://nextjs.org/docs)
- [tRPC](https://trpc.io/docs)
- [Supabase](https://supabase.com/docs)
- [shadcn/ui](https://ui.shadcn.com/)
- [Tailwind CSS](https://tailwindcss.com/docs)

### チュートリアル

- [Next.js + Supabase Tutorial](https://supabase.com/docs/guides/getting-started/quickstarts/nextjs)
- [tRPC Quickstart](https://trpc.io/docs/quickstart)
