-- =====================================================================
-- Step2：自由記述のポジティブ度を ai_decide で一括判定する
-- 実行環境：Free Edition の SQL ウェアハウス（Serverless Starter Warehouse）
-- =====================================================================

USE CATALOG workspace;
USE SCHEMA genie_handson;

-- (1) まず3件だけ試して、返ってくる形を見る
SELECT
  user_id,
  comment,
  ai_decide(
    comment,
    '{
      "positive": {
        "type": "noul",
        "instructions": "このコメントは、社内ナレッジ共有ツールに対して肯定的な評価をしている",
        "criteria": {
          "true": "満足、便利、役立った、今後も使いたい等の肯定的な評価",
          "false": "不満、使いにくい、役に立たない、使わなかった等の否定的な評価"
        }
      }
    }'
  ) AS decision
FROM survey
LIMIT 3;

-- (2) 全200件を判定し、positive_score（0〜1）を付けたテーブルとして保存する
--     判定は呼び出すたびに少し変わるため、毎回計算せずテーブルに保存して使う
CREATE OR REPLACE TABLE survey_enriched
COMMENT '事後アンケート＋自由記述のポジティブ度（ai_decide で判定）'
AS
WITH judged AS (
  SELECT
    *,
    ai_decide(
      comment,
      '{
        "positive": {
          "type": "noul",
          "instructions": "このコメントは、社内ナレッジ共有ツールに対して肯定的な評価をしている",
          "criteria": {
            "true": "満足、便利、役立った、今後も使いたい等の肯定的な評価",
            "false": "不満、使いにくい、役に立たない、使わなかった等の否定的な評価"
          }
        }
      }'
    ) AS decision
  FROM survey
)
SELECT
  * EXCEPT (decision),
  decision:response.answers.positive.probability::DOUBLE AS positive_score
FROM judged;

-- (3) 結果を確認する
SELECT
  ROUND(positive_score, 2) AS positive_score,
  comment
FROM survey_enriched
ORDER BY positive_score DESC;
