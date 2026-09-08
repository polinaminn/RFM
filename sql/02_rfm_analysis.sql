-- Итоговая RFM-сегментация клиентов
-- Пороговые значения взяты из файла analysis/rfm_thresholds.xlsx
WITH client_metrics AS (
    SELECT
        card,
        COUNT(*) AS frequency,
        SUM(summ_with_disc) AS monetary,
        MAX(datetime::date) AS last_purchase_date
    FROM bonuscheques
    WHERE card NOT LIKE '%-%'
    [[AND {{datetime}}]]
    GROUP BY card
),
analysis_date AS (
    SELECT
        MAX(datetime::date) AS analysis_date
    FROM bonuscheques
    WHERE card NOT LIKE '%-%'
    [[AND {{datetime}}]]
),
client_rfm AS (
    SELECT
        c.card,
        c.frequency,
        c.monetary,
        c.last_purchase_date,
        a.analysis_date,
        a.analysis_date - c.last_purchase_date AS recency
    FROM client_metrics c
    CROSS JOIN analysis_date a
),
rfm_scored AS (
    SELECT
        c.*,
        CASE
            WHEN c.recency < 14 THEN 1
            WHEN c.recency < 61 THEN 2
            ELSE 3
        END AS r_score,
        CASE
            WHEN c.frequency >= 5 THEN 1
            WHEN c.frequency >= 3 THEN 2
            ELSE 3
        END AS f_score,
        CASE
            WHEN c.monetary > 2200 THEN 1
            WHEN c.monetary > 900 THEN 2
            ELSE 3
        END AS m_score
    FROM client_rfm c
)
SELECT
    card,
    frequency,
    monetary,
    last_purchase_date,
    analysis_date,
    recency,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_segment
FROM rfm_scored;
