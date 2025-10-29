配当管理アプリ
複数証券口座の配当金を一元管理し、投資回収率を可視化するWebアプリケーション

🎯 プロジェクト概要
配当金投資家向けの管理ツール。日本株・米国株・ADR銘柄の配当を記録し、投資回収率や予想配当を可視化します。

主な機能
ポートフォリオ管理: 複数証券口座の保有銘柄を一元管理
配当金記録: 税引前後の配当を記録し、自動で税金計算
投資分析: 投資回収率、累積配当額、評価損益を可視化
配当予測: 月別・年別の予想配当を自動計算
グラフ表示: 年別配当推移、四半期別資産額推移
為替対応: 外国株の配当を円換算して管理
🚀 技術スタック
Frontend: Next.js 15 (App Router), React 19, TypeScript
UI: Tailwind CSS, shadcn/ui
Backend: tRPC (型安全なAPI)
Database: Supabase (PostgreSQL)
Auth: Supabase Auth
Deployment: Vercel
Data Source: yahoo-finance2 (株価・配当データ)
詳細は TECH_STACK.md を参照してください。

📋 ドキュメント
技術スタック - 使用技術の詳細と選定理由
要件定義書 - 機能仕様と画面設計
データベース設計 - テーブル設計とER図
開発ガイド - 環境構築と開発フロー
📦 前提条件
開発を始める前に、以下のツールをインストールしてください。

必須ツール

1. Node.js 20.x LTS
   macOS (Homebrew):

bash
brew install node@20
Windows (nvm-windows):

bash

# nvm-windowsをインストール: https://github.com/coreybutler/nvm-windows/releases

nvm install 20
nvm use 20
Linux (nvm):

bash

# nvmをインストール

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Node.js 20をインストール

nvm install 20
nvm use 20
確認:

bash
node --version # v20.x.x が表示されればOK 2. pnpm
インストール:

bash
npm install -g pnpm
確認:

bash
pnpm --version # 8.x.x 以上が表示されればOK 3. Git
macOS:

bash
brew install git
Windows: Git for Windows からインストーラーをダウンロード

Linux:

bash
sudo apt-get install git # Ubuntu/Debian
sudo yum install git # CentOS/RHEL
確認:

bash
git --version 4. Docker Desktop
Supabaseローカル開発に必要です。

インストール:

Docker Desktop for Mac
Docker Desktop for Windows
Docker for Linux
確認:

bash
docker --version
docker-compose --version
推奨ツール
Visual Studio Code
インストール: https://code.visualstudio.com/

推奨拡張機能:

ESLint
Prettier
Tailwind CSS IntelliSense
Prisma
🔧 セットアップ

1. リポジトリをクローン
   bash
   git clone https://github.com/your-username/dividend-manager.git
   cd dividend-manager
2. 依存関係をインストール
   bash
   pnpm install
3. 環境変数を設定
   bash

# .env.exampleをコピー

cp .env.example .env.local
.env.local を編集:

bash

# Supabase（ローカル開発用）

NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc... # ローカル開発用の固定キー
SUPABASE_SERVICE_ROLE_KEY=eyJhbGc... # ローカル開発用の固定キー

# ExchangeRate API（本番環境のみ必要）

EXCHANGE_RATE_API_KEY=your-api-key-here
注意: ローカル開発時のSupabaseキーは、pnpm supabase:start 実行後に表示されます。

4. Supabaseローカル環境を起動
   bash

# Docker Desktopが起動していることを確認

# Supabaseをローカルで起動

pnpm supabase:start
初回は時間がかかります（Dockerイメージのダウンロード）。
完了すると以下のサービスが起動します:

PostgreSQL: http://localhost:54322
Supabase Studio: http://localhost:54323
API: http://localhost:54321 5. データベースのマイグレーション
bash

# マイグレーション実行

pnpm supabase:migrate

# シードデータ投入（オプション）

pnpm supabase:seed 6. 開発サーバーを起動
bash
pnpm dev
ブラウザで確認:

http://localhost:3000 7. 動作確認
ブラウザで http://localhost:3000 にアクセス
ユーザー登録ページが表示されればOK
テストユーザーを作成してログイン
詳細なセットアップ手順は DEVELOPMENT.md を参照してください。

📊 プロジェクト構造
dividend-manager/
├── app/ # Next.js App Router
│ ├── (auth)/ # 認証関連ページ
│ ├── (dashboard)/ # メインアプリ
│ └── api/ # API Routes
├── components/ # Reactコンポーネント
│ ├── ui/ # shadcn/uiコンポーネント
│ └── features/ # 機能別コンポーネント
├── lib/ # ユーティリティ
│ ├── supabase/ # Supabaseクライアント
│ ├── trpc/ # tRPC設定
│ └── utils/ # ヘルパー関数
├── server/ # tRPCサーバー
│ └── routers/ # APIルーター
├── types/ # TypeScript型定義
├── docs/ # ドキュメント
├── e2e/ # E2Eテスト
└── supabase/ # Supabaseマイグレーション
🎨 画面構成
ダッシュボード: ポートフォリオサマリー、銘柄一覧、グラフ
銘柄詳細: 保有状況、配当履歴、配当入力フォーム
予想配当: 月別・年別の配当予測、為替シミュレーション
証券口座管理: 口座の追加・編集・削除
設定: 表示設定、データ管理
🧪 テスト
bash

# 単体テスト

pnpm test

# E2Eテスト

pnpm test:e2e

# カバレッジ

pnpm test:coverage
🚢 デプロイ
bash

# Vercelにデプロイ

vercel

# 本番環境

vercel --prod
詳細は DEVELOPMENT.md を参照してください。

🆘 トラブルシューティング
よくある問題
Docker関連のエラー
bash

# Docker Desktopが起動していることを確認

open -a Docker # macOS

# Docker動作確認

docker ps
ポートが使用中
bash

# 別のポートで起動

PORT=3001 pnpm dev
依存関係のエラー
bash

# クリーンインストール

rm -rf node_modules pnpm-lock.yaml
pnpm install
その他の問題は DEVELOPMENT.md のトラブルシューティングセクションを参照してください。

📝 ライセンス
MIT License

👤 作成者
[Your Name]

🤝 コントリビューション
現在は個人プロジェクトのため、コントリビューションは受け付けていません。

📮 お問い合わせ
Issue または email@example.com までご連絡ください。
