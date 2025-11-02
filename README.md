# Dividend Manager

配当金管理アプリケーション

## 技術スタック

- **Framework**: Next.js 15 (App Router)
- **Language**: TypeScript
- **Database**: PostgreSQL
- **ORM**: Prisma
- **Styling**: Tailwind CSS 4
- **Package Manager**: pnpm

## 前提条件

- Node.js 20.18.1
- pnpm 9.12.0
- Docker（Supabaseローカル環境用）
- Supabase CLI

## セットアップ

### 1. 依存関係のインストール

```bash
pnpm install
```

### 2. 環境変数の設定

`.env`ファイルを作成し、以下の環境変数を設定してください：

```
DATABASE_URL="接続プーリング用のURL"
DIRECT_URL="マイグレーション用の直接接続URL"
```

### 3. Supabaseローカル環境の起動

```bash
supabase start
```

起動後、以下のサービスが利用可能になります：

- **Studio**: http://127.0.0.1:54323（データベース管理UI）
- **API**: http://127.0.0.1:54321
- **Database**: postgresql://postgres:postgres@127.0.0.1:54322/postgres

### 4. データベースのマイグレーション

```bash
pnpm prisma migrate dev
```

### 5. 開発サーバーの起動

```bash
pnpm dev
```

http://localhost:3000 でアプリケーションが起動します。

## 利用可能なコマンド

### 開発

```bash
pnpm dev              # 開発サーバーを起動
pnpm type-check       # 型チェックを実行
pnpm lint             # ESLintでコードをチェック
pnpm lint:fix         # ESLintで自動修正
pnpm format           # Prettierでコードをフォーマット
pnpm format:check     # Prettierのフォーマットチェック
```

### ビルド

```bash
pnpm run build:ci       # CI環境・Vercel用（マイグレーションなし）
pnpm run build:migrate  # マイグレーション込みビルド（本番デプロイ時）
pnpm start              # 本番サーバーを起動
```

### データベース

```bash
pnpm prisma migrate dev --name 変更内容  # マイグレーション作成・適用
pnpm prisma generate                     # Prisma Clientを生成
pnpm prisma studio                       # Prisma Studioを起動
```

### Supabase

```bash
supabase start           # ローカルSupabase環境を起動
supabase stop            # ローカルSupabase環境を停止
supabase status          # サービス状態を確認
supabase db reset        # データベースをリセット（seedファイルも実行）
supabase db push         # スキーマ変更をプッシュ
supabase migration new   # 新しいマイグレーションファイルを作成
```

## Database Migration

### スキーマ変更時の手順

1. **開発環境**: スキーマ変更後、マイグレーションを作成・適用

- 新しいマイグレーションファイルが`prisma/migrations/`に生成
- ローカルDBに変更が適用

```bash
pnpm prisma migrate dev --name 変更内容
```

2. **本番環境**: 未適用のマイグレーションを実行

- 未適用のマイグレーションファイルが順次適用

```bash
pnpm run build:migrate
```

### 注意事項

- `build:migrate`は既存のマイグレーションを実行するだけで、スキーマ変更は行わない
- 既存のテーブルやデータは保持され、マイグレーションファイルに記述された変更のみが適用される
- DBを完全に作り直す場合は、手動でDB削除後に`prisma migrate deploy`を実行

## CI/CD

### GitHub Actions

PRの作成・更新時に以下のチェックが自動実行されます:

- コードフォーマットチェック (Prettier)
- Lint (ESLint)
- 型チェック (TypeScript)
- ビルドチェック

ワークフロー: `.github/workflows/ci-checks.yml`

### Vercel デプロイ設定

**Build Command**: `pnpm run build:ci`

マイグレーションはビルド時には実行されません。本番環境へのマイグレーション適用は別途手動で行ってください。

## 開発ワークフロー

1. 新しいブランチを作成
2. 機能開発・修正を実施
3. コミット前に自動でlint・formatが実行される (Husky + lint-staged)
4. PRを作成すると自動でCIチェックが実行される
5. レビュー後、mainブランチにマージ
