-- ============================================
-- SCRIPT DE RESET COMPLETO DO SISTEMA DE RANKING
-- Execute isso no Supabase SQL Editor
-- Isso remove TODOS os dados existentes e recria do zero
-- ============================================

-- 1. Remover todas as missões existentes
DELETE FROM weekly_missions;

-- 2. Remover todo o histórico de conquistas dos usuários
DELETE FROM user_achievements;

-- 3. Remover histórico mensal
DELETE FROM monthly_history;

-- 4. Reset dos rankings dos usuários (mantém usuários mas zera XP)
UPDATE user_rankings SET
    total_xp = 0,
    monthly_xp = 0,
    current_streak = 0,
    longest_streak = 0,
    rank_position = 0,
    last_activity_date = NULL,
    updated_at = NOW();

-- 5. Verificar se as colunas estão corretas
ALTER TABLE weekly_missions 
    ALTER COLUMN week_start TYPE DATE USING week_start::DATE,
    ALTER COLUMN week_end TYPE DATE USING week_end::DATE;

-- ============================================
-- DADOS LIMPOS! 
-- Agora faça hot restart no Flutter para gerar novas missões
-- ============================================

-- OPCIONAL: Ver status atual
SELECT 'Missões removidas' as status, COUNT(*) as count FROM weekly_missions;
SELECT 'Conquistas de usuários removidas' as status, COUNT(*) as count FROM user_achievements;
SELECT 'Rankings resetados' as status, COUNT(*) as count FROM user_rankings WHERE total_xp = 0;
