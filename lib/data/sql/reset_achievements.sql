-- ============================================
-- SCRIPT PARA LIMPAR E RECRIAR CONQUISTAS
-- Execute isso no Supabase SQL Editor
-- ============================================

-- 1. Remover todas as conquistas desbloqueadas pelos usuários
DELETE FROM user_achievements;

-- 2. Remover todas as definições de conquistas
DELETE FROM achievements;

-- 3. Reinserir conquistas (sem duplicatas)
INSERT INTO achievements (name, description, icon, xp_reward, category, requirement_type, requirement_value) VALUES
    -- Conquistas de Missões
    ('Primeiro Passo', 'Complete sua primeira missão', 'directions_walk', 50, 'general', 'missions_completed', 1),
    ('Dedicado', 'Complete 10 missões', 'star', 100, 'general', 'missions_completed', 10),
    ('Veterano', 'Complete 50 missões', 'military_tech', 250, 'general', 'missions_completed', 50),
    ('Mestre das Missões', 'Complete 100 missões', 'workspace_premium', 500, 'general', 'missions_completed', 100),
    
    -- Conquistas de XP
    ('Iniciante', 'Alcance 100 XP', 'emoji_events', 25, 'general', 'xp_earned', 100),
    ('Competidor', 'Alcance 500 XP', 'emoji_events', 50, 'general', 'xp_earned', 500),
    ('Expert', 'Alcance 1500 XP', 'emoji_events', 100, 'general', 'xp_earned', 1500),
    ('Mestre', 'Alcance 3000 XP', 'emoji_events', 200, 'general', 'xp_earned', 3000),
    ('Lendário', 'Alcance 5000 XP', 'diamond', 500, 'general', 'xp_earned', 5000),
    
    -- Conquistas de Streak
    ('Consistente', 'Mantenha um streak de 7 dias', 'local_fire_department', 75, 'streak', 'streak_days', 7),
    ('Imparável', 'Mantenha um streak de 30 dias', 'whatshot', 200, 'streak', 'streak_days', 30),
    ('Lenda', 'Mantenha um streak de 60 dias', 'whatshot', 400, 'streak', 'streak_days', 60),
    
    -- Conquistas de Economia
    ('Investidor', 'Atinja uma meta de economia', 'trending_up', 100, 'savings', 'goals_reached', 1),
    ('Poupador', 'Atinja 3 metas de economia', 'savings', 200, 'savings', 'goals_reached', 3);

-- 4. Verificar conquistas inseridas
SELECT id, name, category, xp_reward, requirement_type, requirement_value 
FROM achievements 
ORDER BY category, requirement_value;
