-- Расчёт клиентских метрик для последующего RFM-анализа
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
)
SELECT
    c.card,
    c.frequency,
    c.monetary,
    c.last_purchase_date,
    a.analysis_date,
    a.analysis_date - c.last_purchase_date AS recency
FROM client_metrics c
CROSS JOIN analysis_date a;
