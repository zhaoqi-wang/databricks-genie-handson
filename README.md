# Databricks Genie ハンズオン（60分）

**テーマ：アンケートで答えたことと、ログに残った実際の行動は一致するか？**

とある製造業の R&D 部門が、社内ナレッジ共有ツールに AI 推薦機能を試験導入しました。社員200名が AIあり群／AIなし群に分かれて4週間ツールを使い、最後に事後アンケートに回答しています。
このアンケートと操作ログを、各自の **Databricks Free Edition** 上で Genie を使って分析します。

> データはすべてハンズオン用に作った架空のデータです。

## 授業前にやっておくこと

1. [Databricks Free Edition](https://www.databricks.com/learn/free-edition) のアカウントを作り、ログインできることを確認する。
2. このリポジトリをダウンロードする（右上の **Code → Download ZIP**）。ZIP を展開して、すぐ開ける場所に置いておく。

## 手順書

- [docs/student_guide.md](docs/student_guide.md)（GitHub 上でそのまま読めます）
- `docs/student_guide.html`（ダウンロード後にブラウザで開くと印刷しやすい版）

実行するSQLはすべて手順書の中にあります。コードブロック右上のコピーボタンでコピーし、SQLエディタに貼り付けて実行してください。

## ファイル一覧

| ファイル | 使う場面 |
|---|---|
| `data/survey.csv` | Step1 でアップロード（事後アンケート、200行） |
| `data/participants.csv` | Step1 でアップロード（参加者の属性、200行） |
| `data/usage_logs.csv` | Step1 でアップロード（操作ログ、10,000行） |
| `memo/Genie設定メモ.pdf` | Step3 で Genie Code に添付するメモ |
| `memo/Genie設定メモ.docx` | 上記メモの編集用の元ファイル |
| `data/backup/survey_enriched_backup.csv` | 予備データ。**講師から指示があったときだけ使う**（`positive_score` は AI の判定ではない予備の値） |
