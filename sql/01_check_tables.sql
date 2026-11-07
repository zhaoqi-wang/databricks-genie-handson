-- =====================================================================
-- Step1：アップロードした3つのテーブルを確認する
-- 実行環境：Free Edition の SQL ウェアハウス（Serverless Starter Warehouse）
-- =====================================================================

USE CATALOG workspace;
USE SCHEMA genie_handson;

-- 件数（survey 200 / participants 200 / usage_logs 10000 になること）
SELECT 'survey' AS table_name, COUNT(*) AS n FROM survey
UNION ALL SELECT 'participants', COUNT(*) FROM participants
UNION ALL SELECT 'usage_logs',   COUNT(*) FROM usage_logs;

-- 型の確認：q1〜q5 が数値、event_ts が timestamp になっていること
DESCRIBE survey;
DESCRIBE usage_logs;

-- event_ts が文字列で読み込まれていた場合だけ、次を実行して timestamp に直す
-- CREATE OR REPLACE TABLE usage_logs AS
-- SELECT log_id, user_id, CAST(event_ts AS TIMESTAMP) AS event_ts, event_type
-- FROM usage_logs;
