/*  Financial Persona Analysis of Young Adults
    Target: Age 18-24
*/

-- Data Cleaning & Staging
-- Filter for Young Adults (18-24) and remove refused/invalid responses (-1, -2, -4)

CREATE TABLE stg_young_adults AS 
SELECT 
    PUF_ID,
    FWBscore, -- Financial Well-Being Score
    PPINCIMP AS income_level, -- Income brackets
    -- Identify investment ownership (PRODHAVE_6: Stocks, Bonds, Mutual Funds)
    CASE WHEN PRODHAVE_6 = 1 THEN 'Yes' ELSE 'No' END AS is_investor,
    -- Calculate average Self-Control score from 3 survey indicators
    (SELFCONTROL_1 + SELFCONTROL_2 + SELFCONTROL_3) / 3.0 AS avg_self_control,
    -- Calculate average Materialism score from 3 survey indicators
    (MATERIALISM_1 + MATERIALISM_2 + MATERIALISM_3) / 3.0 AS avg_materialism 
FROM nfwbs_puf_2016_data 
WHERE agecat = 1            -- Target: Young Adults cohort (Aged 18-24 in 2016)
  AND SELFCONTROL_1 > 0     -- Filter out invalid/refused self-control data
  AND MATERIALISM_1 > 0;    -- Filter out invalid/refused materialism data

-- Fact Table & Segmentation
-- Categorize individuals into 4 distinct personas based on behavioral traits

CREATE TABLE fct_financial_personas AS
SELECT 
    *,
    CASE 
        -- Persona 1: High self-control and low materialism
        WHEN avg_self_control >= 3.5 AND avg_materialism <= 2.5 
            THEN 'The Disciplined Saver'
        
        -- Persona 2: Active investor with decent self-control
        WHEN is_investor = 'Yes' AND avg_self_control >= 3.0 
            THEN 'The Strategic Investor'
        
        -- Persona 3: High materialism (focus on status and luxury)
        WHEN avg_materialism >= 3.5 
            THEN 'The Status Seeker'
        
        -- Persona 4: Remaining group with lower self-control/higher spending tendencies
        ELSE 'The Struggling Spender'
    END AS persona_segment
FROM stg_young_adults;

-- Analytical Queries for Portfolio Insights
-- Insight A: Average Financial Well-Being score per Persona Segment

SELECT 
    persona_segment,
    COUNT(*) AS total_respondents,
    ROUND(AVG(FWBscore), 2) AS avg_financial_wellbeing,
    ROUND(AVG(avg_self_control), 2) AS group_self_control_index
FROM fct_financial_personas
GROUP BY persona_segment
ORDER BY avg_financial_wellbeing DESC;

-- Insight B: Investment Adoption Rate among different segments

SELECT 
    persona_segment,
    ROUND((SUM(CASE WHEN is_investor = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS investment_adoption_rate
FROM fct_financial_personas
GROUP BY persona_segment;
