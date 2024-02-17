SELECT
  category,
  COUNT(1) article_count
FROM {{ source('bbc_news', 'fulltext') }}
GROUP BY category
