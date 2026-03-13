-- Enhanced client fields: family, lifestyle, personality, ideal partner, assets/residence

-- Family
ALTER TABLE clients ADD COLUMN IF NOT EXISTS marital_history TEXT;        -- first_marriage|remarriage|divorced
ALTER TABLE clients ADD COLUMN IF NOT EXISTS has_children BOOLEAN DEFAULT false;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS children_count INT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS family_detail TEXT;          -- "1남2녀 중 장남"
ALTER TABLE clients ADD COLUMN IF NOT EXISTS parents_status TEXT;         -- both_alive|father_only|mother_only|deceased

-- Lifestyle
ALTER TABLE clients ADD COLUMN IF NOT EXISTS drinking TEXT;              -- none|social|regular
ALTER TABLE clients ADD COLUMN IF NOT EXISTS smoking TEXT;               -- none|sometimes|regular
ALTER TABLE clients ADD COLUMN IF NOT EXISTS health_notes TEXT;

-- Personality
ALTER TABLE clients ADD COLUMN IF NOT EXISTS personality_type TEXT;      -- MBTI etc
ALTER TABLE clients ADD COLUMN IF NOT EXISTS personality_traits TEXT[];

-- Ideal partner preferences
ALTER TABLE clients ADD COLUMN IF NOT EXISTS ideal_min_age INT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS ideal_max_age INT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS ideal_min_height INT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS ideal_max_height INT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS ideal_education_level TEXT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS ideal_income_range TEXT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS ideal_religion TEXT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS ideal_notes TEXT;

-- Assets / Residence
ALTER TABLE clients ADD COLUMN IF NOT EXISTS asset_range TEXT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS residence_area TEXT;
ALTER TABLE clients ADD COLUMN IF NOT EXISTS residence_type TEXT;        -- own|rent_deposit|rent_monthly|with_parents
