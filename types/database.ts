export type Json = string | number | boolean | null | { [key: string]: Json | undefined } | Json[];

export type Database = {
  graphql_public: {
    Tables: {
      [_ in never]: never;
    };
    Views: {
      [_ in never]: never;
    };
    Functions: {
      graphql: {
        Args: {
          extensions?: Json;
          operationName?: string;
          query?: string;
          variables?: Json;
        };
        Returns: Json;
      };
    };
    Enums: {
      [_ in never]: never;
    };
    CompositeTypes: {
      [_ in never]: never;
    };
  };
  public: {
    Tables: {
      _prisma_migrations: {
        Row: {
          applied_steps_count: number;
          checksum: string;
          finished_at: string | null;
          id: string;
          logs: string | null;
          migration_name: string;
          rolled_back_at: string | null;
          started_at: string;
        };
        Insert: {
          applied_steps_count?: number;
          checksum: string;
          finished_at?: string | null;
          id: string;
          logs?: string | null;
          migration_name: string;
          rolled_back_at?: string | null;
          started_at?: string;
        };
        Update: {
          applied_steps_count?: number;
          checksum?: string;
          finished_at?: string | null;
          id?: string;
          logs?: string | null;
          migration_name?: string;
          rolled_back_at?: string | null;
          started_at?: string;
        };
        Relationships: [];
      };
      dividends: {
        Row: {
          amountAfterTax: number;
          amountBeforeTax: number | null;
          amountJpy: number | null;
          createdAt: string;
          dividendPerShareBeforeTax: number | null;
          domesticTax: number;
          exchangeRate: number | null;
          foreignTax: number;
          holdingId: string;
          id: string;
          notes: string | null;
          receivedDate: string;
          sharesAtPayment: number;
          taxType: string;
          updatedAt: string;
          userId: string;
        };
        Insert: {
          amountAfterTax: number;
          amountBeforeTax?: number | null;
          amountJpy?: number | null;
          createdAt?: string;
          dividendPerShareBeforeTax?: number | null;
          domesticTax?: number;
          exchangeRate?: number | null;
          foreignTax?: number;
          holdingId: string;
          id?: string;
          notes?: string | null;
          receivedDate: string;
          sharesAtPayment: number;
          taxType: string;
          updatedAt: string;
          userId: string;
        };
        Update: {
          amountAfterTax?: number;
          amountBeforeTax?: number | null;
          amountJpy?: number | null;
          createdAt?: string;
          dividendPerShareBeforeTax?: number | null;
          domesticTax?: number;
          exchangeRate?: number | null;
          foreignTax?: number;
          holdingId?: string;
          id?: string;
          notes?: string | null;
          receivedDate?: string;
          sharesAtPayment?: number;
          taxType?: string;
          updatedAt?: string;
          userId?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'dividends_holdingId_fkey';
            columns: ['holdingId'];
            isOneToOne: false;
            referencedRelation: 'holdings';
            referencedColumns: ['id'];
          },
        ];
      };
      exchange_rates: {
        Row: {
          createdAt: string;
          date: string;
          id: string;
          usdJpy: number;
        };
        Insert: {
          createdAt?: string;
          date: string;
          id?: string;
          usdJpy: number;
        };
        Update: {
          createdAt?: string;
          date?: string;
          id?: string;
          usdJpy?: number;
        };
        Relationships: [];
      };
      holdings: {
        Row: {
          accountId: string;
          averagePrice: number;
          createdAt: string;
          id: string;
          isActive: boolean;
          shares: number;
          stockId: string;
          totalCost: number;
          updatedAt: string;
          userId: string;
        };
        Insert: {
          accountId: string;
          averagePrice: number;
          createdAt?: string;
          id?: string;
          isActive?: boolean;
          shares: number;
          stockId: string;
          totalCost: number;
          updatedAt: string;
          userId: string;
        };
        Update: {
          accountId?: string;
          averagePrice?: number;
          createdAt?: string;
          id?: string;
          isActive?: boolean;
          shares?: number;
          stockId?: string;
          totalCost?: number;
          updatedAt?: string;
          userId?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'holdings_accountId_fkey';
            columns: ['accountId'];
            isOneToOne: false;
            referencedRelation: 'securities_accounts';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'holdings_stockId_fkey';
            columns: ['stockId'];
            isOneToOne: false;
            referencedRelation: 'stocks';
            referencedColumns: ['id'];
          },
        ];
      };
      securities_accounts: {
        Row: {
          accountName: string;
          accountType: string;
          createdAt: string;
          displayOrder: number;
          id: string;
          updatedAt: string;
          userId: string;
        };
        Insert: {
          accountName: string;
          accountType: string;
          createdAt?: string;
          displayOrder?: number;
          id?: string;
          updatedAt: string;
          userId: string;
        };
        Update: {
          accountName?: string;
          accountType?: string;
          createdAt?: string;
          displayOrder?: number;
          id?: string;
          updatedAt?: string;
          userId?: string;
        };
        Relationships: [];
      };
      stock_price_history: {
        Row: {
          closePrice: number;
          createdAt: string;
          date: string;
          id: string;
          stockId: string;
        };
        Insert: {
          closePrice: number;
          createdAt?: string;
          date: string;
          id?: string;
          stockId: string;
        };
        Update: {
          closePrice?: number;
          createdAt?: string;
          date?: string;
          id?: string;
          stockId?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'stock_price_history_stockId_fkey';
            columns: ['stockId'];
            isOneToOne: false;
            referencedRelation: 'stocks';
            referencedColumns: ['id'];
          },
        ];
      };
      stocks: {
        Row: {
          createdAt: string;
          currency: string;
          currentPrice: number | null;
          dividendMonths: number[] | null;
          dividendYield: number | null;
          exDividendDate: string | null;
          id: string;
          lastUpdated: string | null;
          latestDividendPerShare: number | null;
          market: string;
          name: string;
          sector: string | null;
          symbol: string;
        };
        Insert: {
          createdAt?: string;
          currency?: string;
          currentPrice?: number | null;
          dividendMonths?: number[] | null;
          dividendYield?: number | null;
          exDividendDate?: string | null;
          id?: string;
          lastUpdated?: string | null;
          latestDividendPerShare?: number | null;
          market: string;
          name: string;
          sector?: string | null;
          symbol: string;
        };
        Update: {
          createdAt?: string;
          currency?: string;
          currentPrice?: number | null;
          dividendMonths?: number[] | null;
          dividendYield?: number | null;
          exDividendDate?: string | null;
          id?: string;
          lastUpdated?: string | null;
          latestDividendPerShare?: number | null;
          market?: string;
          name?: string;
          sector?: string | null;
          symbol?: string;
        };
        Relationships: [];
      };
      transactions: {
        Row: {
          accountId: string;
          createdAt: string;
          exchangeRate: number | null;
          fees: number;
          id: string;
          notes: string | null;
          pricePerShare: number;
          shares: number;
          stockId: string;
          totalAmount: number;
          transactionDate: string;
          transactionType: string;
          updatedAt: string;
          userId: string;
        };
        Insert: {
          accountId: string;
          createdAt?: string;
          exchangeRate?: number | null;
          fees?: number;
          id?: string;
          notes?: string | null;
          pricePerShare: number;
          shares: number;
          stockId: string;
          totalAmount: number;
          transactionDate: string;
          transactionType: string;
          updatedAt: string;
          userId: string;
        };
        Update: {
          accountId?: string;
          createdAt?: string;
          exchangeRate?: number | null;
          fees?: number;
          id?: string;
          notes?: string | null;
          pricePerShare?: number;
          shares?: number;
          stockId?: string;
          totalAmount?: number;
          transactionDate?: string;
          transactionType?: string;
          updatedAt?: string;
          userId?: string;
        };
        Relationships: [
          {
            foreignKeyName: 'transactions_accountId_fkey';
            columns: ['accountId'];
            isOneToOne: false;
            referencedRelation: 'securities_accounts';
            referencedColumns: ['id'];
          },
          {
            foreignKeyName: 'transactions_stockId_fkey';
            columns: ['stockId'];
            isOneToOne: false;
            referencedRelation: 'stocks';
            referencedColumns: ['id'];
          },
        ];
      };
      user_profiles: {
        Row: {
          autoUpdateEnabled: boolean;
          createdAt: string;
          decimalPlaces: number;
          defaultCurrency: string;
          dividendMonthFormat: string;
          id: string;
          updatedAt: string;
          updateTime: string;
          userId: string;
        };
        Insert: {
          autoUpdateEnabled?: boolean;
          createdAt?: string;
          decimalPlaces?: number;
          defaultCurrency?: string;
          dividendMonthFormat?: string;
          id?: string;
          updatedAt: string;
          updateTime?: string;
          userId: string;
        };
        Update: {
          autoUpdateEnabled?: boolean;
          createdAt?: string;
          decimalPlaces?: number;
          defaultCurrency?: string;
          dividendMonthFormat?: string;
          id?: string;
          updatedAt?: string;
          updateTime?: string;
          userId?: string;
        };
        Relationships: [];
      };
    };
    Views: {
      [_ in never]: never;
    };
    Functions: {
      [_ in never]: never;
    };
    Enums: {
      [_ in never]: never;
    };
    CompositeTypes: {
      [_ in never]: never;
    };
  };
};

type DatabaseWithoutInternals = Omit<Database, '__InternalSupabase'>;

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, 'public'>];

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema['Tables'] & DefaultSchema['Views'])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Views'])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Views'])[TableName] extends {
      Row: infer R;
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema['Tables'] & DefaultSchema['Views'])
    ? (DefaultSchema['Tables'] & DefaultSchema['Views'])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R;
      }
      ? R
      : never
    : never;

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema['Tables']
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables']
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'][TableName] extends {
      Insert: infer I;
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema['Tables']
    ? DefaultSchema['Tables'][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I;
      }
      ? I
      : never
    : never;

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema['Tables']
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables']
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions['schema']]['Tables'][TableName] extends {
      Update: infer U;
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema['Tables']
    ? DefaultSchema['Tables'][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U;
      }
      ? U
      : never
    : never;

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema['Enums']
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions['schema']]['Enums']
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions['schema']]['Enums'][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema['Enums']
    ? DefaultSchema['Enums'][DefaultSchemaEnumNameOrOptions]
    : never;

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema['CompositeTypes']
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals;
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions['schema']]['CompositeTypes']
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals;
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions['schema']]['CompositeTypes'][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema['CompositeTypes']
    ? DefaultSchema['CompositeTypes'][PublicCompositeTypeNameOrOptions]
    : never;

export const Constants = {
  graphql_public: {
    Enums: {},
  },
  public: {
    Enums: {},
  },
} as const;
