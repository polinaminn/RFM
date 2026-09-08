-- Агрегация результатов ABC-анализа
WITH client_revenue AS (
    SELECT
        card,
        SUM(summ_with_disc) AS revenue
    FROM bonuscheques
    WHERE card NOT LIKE '%-%'
    [[AND {{datetime}}]]
    GROUP BY card
),
baza AS (
    SELECT
        card,
        revenue,
        CASE
            WHEN SUM(revenue) OVER (ORDER BY revenue DESC)
                 / SUM(revenue) OVER () <= 0.80 THEN 'A'
            WHEN SUM(revenue) OVER (ORDER BY revenue DESC)
                 / SUM(revenue) OVER () <= 0.95 THEN 'B'
            ELSE 'C'
        END AS revenue_abc
    FROM client_revenue
)
SELECT
    revenue_abc,
    COUNT(*) AS clients,
    SUM(revenue) AS revenue,
    ROUND(
        SUM(revenue) * 100
        / SUM(SUM(revenue)) OVER (),
        0
    ) AS per
FROM baza
GROUP BY revenue_abc
ORDER BY revenue DESC;
