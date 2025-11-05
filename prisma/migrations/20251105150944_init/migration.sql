/*
  Warnings:

  - You are about to drop the `Post` table. If the table is not empty, all the data it contains will be lost.
  - You are about to drop the `User` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "public"."Post" DROP CONSTRAINT "Post_authorId_fkey";

-- DropTable
DROP TABLE "public"."Post";

-- DropTable
DROP TABLE "public"."User";

-- CreateTable
CREATE TABLE "securities_accounts" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "userId" UUID NOT NULL,
    "accountName" TEXT NOT NULL,
    "accountType" TEXT NOT NULL,
    "displayOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "securities_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stocks" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "symbol" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "market" TEXT NOT NULL,
    "currency" TEXT NOT NULL DEFAULT 'USD',
    "sector" TEXT,
    "currentPrice" DECIMAL(12,4),
    "dividendYield" DECIMAL(6,4),
    "latestDividendPerShare" DECIMAL(10,4),
    "exDividendDate" DATE,
    "dividendMonths" INTEGER[],
    "lastUpdated" TIMESTAMPTZ,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stocks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "holdings" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "userId" UUID NOT NULL,
    "accountId" UUID NOT NULL,
    "stockId" UUID NOT NULL,
    "shares" INTEGER NOT NULL,
    "averagePrice" DECIMAL(12,4) NOT NULL,
    "totalCost" DECIMAL(15,2) NOT NULL,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "holdings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "dividends" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "userId" UUID NOT NULL,
    "holdingId" UUID NOT NULL,
    "receivedDate" DATE NOT NULL,
    "sharesAtPayment" INTEGER NOT NULL,
    "dividendPerShareBeforeTax" DECIMAL(10,4),
    "amountBeforeTax" DECIMAL(15,2),
    "amountAfterTax" DECIMAL(15,2) NOT NULL,
    "taxType" TEXT NOT NULL,
    "foreignTax" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "domesticTax" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "exchangeRate" DECIMAL(10,4),
    "amountJpy" DECIMAL(15,2),
    "notes" TEXT,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "dividends_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "transactions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "userId" UUID NOT NULL,
    "accountId" UUID NOT NULL,
    "stockId" UUID NOT NULL,
    "transactionType" TEXT NOT NULL,
    "transactionDate" DATE NOT NULL,
    "shares" INTEGER NOT NULL,
    "pricePerShare" DECIMAL(12,4) NOT NULL,
    "totalAmount" DECIMAL(15,2) NOT NULL,
    "fees" DECIMAL(15,2) NOT NULL DEFAULT 0,
    "exchangeRate" DECIMAL(10,4),
    "notes" TEXT,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "transactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_profiles" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "userId" UUID NOT NULL,
    "defaultCurrency" TEXT NOT NULL DEFAULT 'JPY',
    "decimalPlaces" INTEGER NOT NULL DEFAULT 2,
    "dividendMonthFormat" TEXT NOT NULL DEFAULT 'number',
    "autoUpdateEnabled" BOOLEAN NOT NULL DEFAULT true,
    "updateTime" TIME NOT NULL DEFAULT '09:00:00'::time,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "user_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "exchange_rates" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "date" DATE NOT NULL,
    "usdJpy" DECIMAL(10,4) NOT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "exchange_rates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "stock_price_history" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "stockId" UUID NOT NULL,
    "date" DATE NOT NULL,
    "closePrice" DECIMAL(12,4) NOT NULL,
    "createdAt" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "stock_price_history_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "securities_accounts_userId_idx" ON "securities_accounts"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "stocks_symbol_key" ON "stocks"("symbol");

-- CreateIndex
CREATE INDEX "stocks_symbol_idx" ON "stocks"("symbol");

-- CreateIndex
CREATE INDEX "stocks_market_idx" ON "stocks"("market");

-- CreateIndex
CREATE INDEX "holdings_userId_idx" ON "holdings"("userId");

-- CreateIndex
CREATE INDEX "holdings_accountId_idx" ON "holdings"("accountId");

-- CreateIndex
CREATE INDEX "holdings_stockId_idx" ON "holdings"("stockId");

-- CreateIndex
CREATE INDEX "holdings_userId_isActive_idx" ON "holdings"("userId", "isActive");

-- CreateIndex
CREATE UNIQUE INDEX "holdings_accountId_stockId_key" ON "holdings"("accountId", "stockId");

-- CreateIndex
CREATE INDEX "dividends_userId_idx" ON "dividends"("userId");

-- CreateIndex
CREATE INDEX "dividends_holdingId_idx" ON "dividends"("holdingId");

-- CreateIndex
CREATE INDEX "dividends_receivedDate_idx" ON "dividends"("receivedDate");

-- CreateIndex
CREATE INDEX "transactions_userId_idx" ON "transactions"("userId");

-- CreateIndex
CREATE INDEX "transactions_accountId_idx" ON "transactions"("accountId");

-- CreateIndex
CREATE INDEX "transactions_stockId_idx" ON "transactions"("stockId");

-- CreateIndex
CREATE INDEX "transactions_transactionDate_idx" ON "transactions"("transactionDate" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "user_profiles_userId_key" ON "user_profiles"("userId");

-- CreateIndex
CREATE INDEX "user_profiles_userId_idx" ON "user_profiles"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "exchange_rates_date_key" ON "exchange_rates"("date");

-- CreateIndex
CREATE INDEX "exchange_rates_date_idx" ON "exchange_rates"("date" DESC);

-- CreateIndex
CREATE INDEX "stock_price_history_stockId_date_idx" ON "stock_price_history"("stockId", "date" DESC);

-- CreateIndex
CREATE UNIQUE INDEX "stock_price_history_stockId_date_key" ON "stock_price_history"("stockId", "date");

-- AddForeignKey
ALTER TABLE "holdings" ADD CONSTRAINT "holdings_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "securities_accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "holdings" ADD CONSTRAINT "holdings_stockId_fkey" FOREIGN KEY ("stockId") REFERENCES "stocks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "dividends" ADD CONSTRAINT "dividends_holdingId_fkey" FOREIGN KEY ("holdingId") REFERENCES "holdings"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_accountId_fkey" FOREIGN KEY ("accountId") REFERENCES "securities_accounts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "transactions" ADD CONSTRAINT "transactions_stockId_fkey" FOREIGN KEY ("stockId") REFERENCES "stocks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "stock_price_history" ADD CONSTRAINT "stock_price_history_stockId_fkey" FOREIGN KEY ("stockId") REFERENCES "stocks"("id") ON DELETE CASCADE ON UPDATE CASCADE;
