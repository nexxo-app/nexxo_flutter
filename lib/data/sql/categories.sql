-- Create categories table
CREATE TABLE IF NOT EXISTS categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  type text NOT NULL CHECK (type IN ('income', 'expense')),
  icon text NOT NULL,
  color text NOT NULL, -- Hex string e.g., '0xFF4CAF50'
  budget_limit_percent double precision, -- Nullable, percentage of total income
  is_default boolean DEFAULT true,
  user_id uuid REFERENCES auth.users(id) -- Null for system defaults
);

-- RLS Policies
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Categories are viewable by everyone" ON categories
  FOR SELECT USING (true); -- Or limit to user_id IS NULL OR user_id = auth.uid()

CREATE POLICY "Users can create their own categories" ON categories
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own categories" ON categories
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own categories" ON categories
  FOR DELETE USING (auth.uid() = user_id);

-- Seed Data (System Defaults)
INSERT INTO categories (name, type, icon, color, budget_limit_percent, is_default) VALUES
  -- Income
  ('Salário', 'income', 'attach_money_rounded', '0xFF4CAF50', NULL, true),
  ('Freelance', 'income', 'work_rounded', '0xFF2196F3', NULL, true),
  ('Investimentos', 'income', 'trending_up_rounded', '0xFF009688', NULL, true),
  ('Presente', 'income', 'card_giftcard_rounded', '0xFFFFC107', NULL, true),
  ('Outros (R)', 'income', 'account_balance_wallet_rounded', '0xFF9E9E9E', NULL, true),
  ('Bônus', 'income', 'star_rounded', '0xFFFFC107', NULL, true),
  ('Reembolso', 'income', 'replay_rounded', '0xFF4CAF50', NULL, true),

  -- Expense
  ('Alimentação', 'expense', 'restaurant_rounded', '0xFFFF5722', 15.0, true),
  ('Mercado', 'expense', 'shopping_cart_rounded', '0xFFFF9800', 15.0, true),
  ('Transporte', 'expense', 'directions_car_rounded', '0xFF2196F3', 10.0, true),
  ('Moradia', 'expense', 'home_rounded', '0xFF673AB7', 30.0, true),
  ('Lazer', 'expense', 'sports_esports_rounded', '0xFFE91E63', 10.0, true),
  ('Saúde', 'expense', 'local_hospital_rounded', '0xFFF44336', 5.0, true),
  ('Educação', 'expense', 'school_rounded', '0xFF00BCD4', 5.0, true),
  ('Compras', 'expense', 'shopping_bag_rounded', '0xFF9C27B0', 5.0, true),
  ('Contas', 'expense', 'receipt_long_rounded', '0xFF607D8B', 10.0, true),
  ('Viagem', 'expense', 'flight_rounded', '0xFFE91E63', 10.0, true),
  ('Pets', 'expense', 'pets_rounded', '0xFF795548', 5.0, true),
  ('Assinaturas', 'expense', 'subscriptions_rounded', '0xFF607D8B', 5.0, true),
  ('Eletrônicos', 'expense', 'devices_rounded', '0xFF3F51B5', 5.0, true),
  ('Cuidados Pessoais', 'expense', 'spa_rounded', '0xFFE91E63', 5.0, true),
  ('Outros (D)', 'expense', 'category_rounded', '0xFF9E9E9E', 5.0, true)
ON CONFLICT (name) DO NOTHING;
