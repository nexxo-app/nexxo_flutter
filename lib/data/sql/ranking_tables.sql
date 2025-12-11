-- Ranking System Tables for Nexxo Flutter
-- Run these in Supabase SQL Editor

-- User Rankings Table
CREATE TABLE IF NOT EXISTS user_rankings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL UNIQUE,
    total_xp INTEGER DEFAULT 0 NOT NULL,
    monthly_xp INTEGER DEFAULT 0 NOT NULL,
    current_streak INTEGER DEFAULT 0 NOT NULL,
    longest_streak INTEGER DEFAULT 0 NOT NULL,
    last_activity_date DATE,
    rank_position INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Weekly Missions Table
CREATE TABLE IF NOT EXISTS weekly_missions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    mission_type TEXT NOT NULL,
    target_value DECIMAL(12,2) DEFAULT 1.0 NOT NULL,
    current_value DECIMAL(12,2) DEFAULT 0.0 NOT NULL,
    xp_reward INTEGER NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    week_start DATE NOT NULL,
    week_end DATE NOT NULL,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Achievements Definition Table
CREATE TABLE IF NOT EXISTS achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon TEXT DEFAULT 'emoji_events',
    xp_reward INTEGER DEFAULT 50,
    category TEXT DEFAULT 'general', -- 'streak', 'savings', 'spending', 'general'
    requirement_type TEXT NOT NULL, -- 'streak_days', 'missions_completed', 'xp_earned', etc.
    requirement_value INTEGER NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User Achievements (unlocked achievements)
CREATE TABLE IF NOT EXISTS user_achievements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    achievement_id UUID REFERENCES achievements(id) ON DELETE CASCADE NOT NULL,
    unlocked_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- Monthly History (for progression tracking)
CREATE TABLE IF NOT EXISTS monthly_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    month INTEGER NOT NULL,
    year INTEGER NOT NULL,
    start_xp INTEGER DEFAULT 0,
    end_xp INTEGER DEFAULT 0,
    total_xp INTEGER DEFAULT 0,
    missions_completed INTEGER DEFAULT 0,
    missions_total INTEGER DEFAULT 0,
    rank_change INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, month, year)
);

-- Enable RLS
ALTER TABLE user_rankings ENABLE ROW LEVEL SECURITY;
ALTER TABLE weekly_missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE monthly_history ENABLE ROW LEVEL SECURITY;

-- RLS Policies for user_rankings
CREATE POLICY "Users can view all rankings" ON user_rankings
    FOR SELECT USING (true);

CREATE POLICY "Users can update own ranking" ON user_rankings
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own ranking" ON user_rankings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- RLS Policies for weekly_missions
CREATE POLICY "Users can view own missions" ON weekly_missions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own missions" ON weekly_missions
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own missions" ON weekly_missions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- RLS Policies for user_achievements
CREATE POLICY "Users can view own achievements" ON user_achievements
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own achievements" ON user_achievements
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- RLS Policies for monthly_history
CREATE POLICY "Users can view own history" ON monthly_history
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own history" ON monthly_history
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Achievements table is public readable
CREATE POLICY "Anyone can view achievements" ON achievements
    FOR SELECT USING (true);

-- Insert default achievements
INSERT INTO achievements (name, description, icon, xp_reward, category, requirement_type, requirement_value) VALUES
    ('Primeiro Passo', 'Complete sua primeira missão', 'directions_walk', 50, 'general', 'missions_completed', 1),
    ('Dedicado', 'Complete 10 missões', 'star', 100, 'general', 'missions_completed', 10),
    ('Veterano', 'Complete 50 missões', 'military_tech', 250, 'general', 'missions_completed', 50),
    ('Iniciante', 'Alcance 100 XP', 'emoji_events', 25, 'general', 'xp_earned', 100),
    ('Competidor', 'Alcance 500 XP', 'emoji_events', 50, 'general', 'xp_earned', 500),
    ('Expert', 'Alcance 1500 XP', 'emoji_events', 100, 'general', 'xp_earned', 1500),
    ('Mestre', 'Alcance 3000 XP', 'emoji_events', 200, 'general', 'xp_earned', 3000),
    ('Lendário', 'Alcance 5000 XP', 'emoji_events', 500, 'general', 'xp_earned', 5000),
    ('Consistente', 'Mantenha um streak de 7 dias', 'local_fire_department', 75, 'streak', 'streak_days', 7),
    ('Imparável', 'Mantenha um streak de 30 dias', 'whatshot', 200, 'streak', 'streak_days', 30),
    ('Economizador', 'Reduza gastos por 4 semanas seguidas', 'savings', 150, 'savings', 'savings_weeks', 4),
    ('Investidor', 'Atinja uma meta de economia', 'trending_up', 100, 'savings', 'goals_reached', 1),
    ('Semana Perfeita', 'Complete todas as missões em uma semana', 'workspace_premium', 150, 'general', 'perfect_weeks', 1),
    ('Mês Perfeito', 'Complete todas as missões em um mês', 'diamond', 500, 'general', 'perfect_months', 1)
ON CONFLICT DO NOTHING;

-- Function to calculate rank positions
CREATE OR REPLACE FUNCTION update_rank_positions()
RETURNS void AS $$
BEGIN
    UPDATE user_rankings
    SET rank_position = ranked.position
    FROM (
        SELECT id, ROW_NUMBER() OVER (ORDER BY total_xp DESC) as position
        FROM user_rankings
    ) AS ranked
    WHERE user_rankings.id = ranked.id;
END;
$$ LANGUAGE plpgsql;

-- Function to get leaderboard
CREATE OR REPLACE FUNCTION get_leaderboard(league_min_xp INTEGER, league_max_xp INTEGER, limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
    user_id UUID,
    user_name TEXT,
    avatar_url TEXT,
    total_xp INTEGER,
    rank_position INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ur.user_id,
        COALESCE(p.full_name, 'Usuário') as user_name,
        p.avatar_url,
        ur.total_xp,
        ROW_NUMBER() OVER (ORDER BY ur.total_xp DESC)::INTEGER as rank_position
    FROM user_rankings ur
    LEFT JOIN profiles p ON p.id = ur.user_id
    WHERE ur.total_xp >= league_min_xp AND ur.total_xp <= league_max_xp
    ORDER BY ur.total_xp DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_rankings_total_xp ON user_rankings(total_xp DESC);
CREATE INDEX IF NOT EXISTS idx_user_rankings_user_id ON user_rankings(user_id);
CREATE INDEX IF NOT EXISTS idx_weekly_missions_user_week ON weekly_missions(user_id, week_start);
CREATE INDEX IF NOT EXISTS idx_monthly_history_user ON monthly_history(user_id, year, month);
