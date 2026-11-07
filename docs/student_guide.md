# Databricks Genie ハンズオン 手順書（学生用）

**所要時間：60分**　／　**テーマ：アンケートで答えたことと、ログに残った実際の行動は一致するか？**

**環境：各自の Databricks Free Edition**（データの準備から分析まで、すべて自分のワークスペースで行います）

---

## 事前準備（授業前に必ず）

当日は時間が限られているので、次の2つは授業の前に済ませておいてください。

1. **Databricks Free Edition のアカウントを作り、ログインできることを確認します。**
    - サインイン方法は「メール（ワンタイムコード）」「Google でサインイン」「Microsoft でサインイン」から選べます。
    - ログイン後、ワークスペースのトップ画面が開けば準備完了です。
2. **配布ファイルをダウンロードし、すぐに開ける場所に置いておきます。**

| ファイル | 使う場面 |
|---|---|
| `survey.csv` | Step1 でアップロード（事後アンケート） |
| `participants.csv` | Step1 でアップロード（参加者の属性） |
| `usage_logs.csv` | Step1 でアップロード（操作ログ） |
| `Genie設定メモ.pdf` | Step3 で Genie Code に添付するメモ |
| `Genie設定メモ.docx` | メモの編集用の元ファイル（任意） |

---

## 0. 背景設定（0–5分）

とある製造業の R&D 部門が、社内ナレッジ共有ツールに **AI 推薦機能** を試験導入しました。
社員200名が **AIあり群／AIなし群** に分かれて4週間ツールを使い、最後に事後アンケートに回答しています。

R&D 部門が知りたいこと：

- AI 推薦機能で満足度は上がったか？
- アンケートで「よく使った」と答えた人は、本当に使っていたのか？
- 自由記述がポジティブな人ほど、AI 推薦を活用していたか？

### 使うデータ

すべて自分のワークスペースの **`workspace.genie_handson`** スキーマに作ります。

| テーブル | 元ファイル | 行数 | 内容 |
|---|---|---|---|
| `survey` | `survey.csv` | 200 | 事後アンケート（5問＋自由記述） |
| `participants` | `participants.csv` | 200 | 参加者の属性と実験群 |
| `usage_logs` | `usage_logs.csv` | 10,000 | 4週間の操作ログ |

期間：2026-10-05〜2026-10-30 の平日（4週間）。結合キーはすべて `user_id` です。

### 各テーブルのカラム

**survey（survey.csv）**：Q1〜Q4 は5段階（1＝低い〜5＝高い）です。

| カラム | 内容 |
|---|---|
| `user_id` | 参加者ID |
| `q1_satisfaction` | Q1 満足度 |
| `q2_ease_of_use` | Q2 使いやすさ |
| `q3_usefulness` | Q3 業務に役立った |
| `q4_intention` | Q4 今後も使いたい |
| `q5_usage_frequency` | Q5 利用頻度の自己申告（1＝ほぼ使わない、2＝週1日、3＝週2〜3日、4＝週4日、5＝毎日） |
| `comment` | 自由記述 |

**participants（participants.csv）**

| カラム | 内容 |
|---|---|
| `user_id` | 参加者ID（U001〜U200） |
| `department` | 所属部署 |
| `age_group` | 年代（20代〜50代） |
| `ai_group` | 実験群（`AIあり` / `AIなし`） |

**usage_logs（usage_logs.csv）**

| カラム | 内容 |
|---|---|
| `log_id` | ログID |
| `user_id` | 参加者ID |
| `event_ts` | イベント発生日時（日本時間） |
| `event_type` | `login`＝ログイン、`search`＝検索、`ai_accept`＝AI推薦の文書を開いた（AIあり群のみ） |

---

## Step1. スキーマを作り、CSVを3つアップロードしてテーブルを作る（5–17分）

**ゴール：** `workspace.genie_handson` に `survey`・`participants`・`usage_logs` の3テーブルができている。

1. **スキーマを作ります。** 左のメニューから **SQLエディタ** を開き、SQLウェアハウス（Free Edition に1台ある Serverless のウェアハウス。名前は「Serverless Starter Warehouse」の想定）を選んで、次のSQLを実行してください。

    ```sql
    CREATE SCHEMA IF NOT EXISTS workspace.genie_handson;
    ```

    ※ カタログ `workspace` は Free Edition に最初からある想定です。名前が違う場合は当日の画面に合わせてください。

2. 左上の **「新規」→「データを追加またはアップロード」→「テーブルを作成または変更」** を開きます。
    ※ メニューの名前は当日の画面に合わせてください。
3. `survey.csv` をドラッグ＆ドロップし、アップロード先とテーブル名を指定します。
    - カタログ：`workspace`
    - スキーマ：`genie_handson`
    - テーブル名：`survey`
4. プレビュー画面で次を確認してから、**「テーブルを作成」** を押します。
    - 1行目が列名として読み込まれていること
    - `q1_satisfaction`〜`q5_usage_frequency` が数値型になっていること
5. 同じ手順で、残りの2つもアップロードします。
    - `participants.csv` → テーブル名 `participants`
    - `usage_logs.csv` → テーブル名 `usage_logs`（プレビューで `event_ts` が timestamp 型になっていることを確認）
6. **件数を確認します。** 次のSQLをSQLエディタにコピーして実行し、`survey` 200行／`participants` 200行／`usage_logs` 10,000行になっているか確かめます。

    ```sql
    SELECT 'survey' AS table_name, COUNT(*) AS n FROM workspace.genie_handson.survey
    UNION ALL SELECT 'participants', COUNT(*) FROM workspace.genie_handson.participants
    UNION ALL SELECT 'usage_logs',   COUNT(*) FROM workspace.genie_handson.usage_logs;
    ```

7. **型を確認します。** 次のSQLを実行し、`event_ts` の型が `timestamp` になっているか見ます。

    ```sql
    DESCRIBE workspace.genie_handson.usage_logs;
    ```

    `event_ts` が `string` になっていた場合だけ、次のSQLを実行して `timestamp` に直してください。

    ```sql
    CREATE OR REPLACE TABLE workspace.genie_handson.usage_logs AS
    SELECT log_id, user_id, CAST(event_ts AS TIMESTAMP) AS event_ts, event_type
    FROM workspace.genie_handson.usage_logs;
    ```

---

## Step2. AI Functions（ai_analyze_sentiment）で自由記述の感情を判定する（17–25分）

**ゴール：** 自由記述ごとに感情のラベル（`sentiment`）を付けた `survey_enriched` テーブルができている。

`ai_analyze_sentiment` は、文章を読んで次の4つのどれかを返す AI Functions です。

| ラベル | 意味 |
|---|---|
| `positive` | 肯定的 |
| `negative` | 否定的 |
| `neutral` | どちらでもない |
| `mixed` | 肯定と否定が混ざっている |

> **注意**
>
> - 感情を判定できなかったコメントは `NULL` になります。
> - 動かない場合は自分で直そうとせず、講師の指示を待ってください。

次の3つのSQLを、上から順に1つずつSQLエディタにコピーして実行します。

1. **まず3件だけ試します。** 返ってくる `sentiment` 列の中身を確認してください。

    ```sql
    SELECT
      user_id,
      comment,
      ai_analyze_sentiment(comment) AS sentiment
    FROM workspace.genie_handson.survey
    LIMIT 3;
    ```

2. **全200件を判定して保存します。** 判定結果を `sentiment` 列として、`survey_enriched` テーブルに保存します。

    ```sql
    CREATE OR REPLACE TABLE workspace.genie_handson.survey_enriched
    COMMENT '事後アンケート＋自由記述の感情ラベル（ai_analyze_sentiment で判定）'
    AS
    SELECT
      *,
      ai_analyze_sentiment(comment) AS sentiment
    FROM workspace.genie_handson.survey;
    ```

3. **結果を確認します。** ラベルごとの件数を数え、いくつかのコメントを読んで、判定が自分の感覚と合っているかを見てください。

    ```sql
    SELECT sentiment, COUNT(*) AS n
    FROM workspace.genie_handson.survey_enriched
    GROUP BY sentiment
    ORDER BY n DESC;
    ```

    ```sql
    SELECT sentiment, comment
    FROM workspace.genie_handson.survey_enriched
    ORDER BY sentiment
    LIMIT 20;
    ```

> **ポイント：** AI の判定は、実行するたびに結果が変わることがあります。
> そのため、判定結果はテーブルに保存しておき、分析ではその値を使います。
> また、`mixed` と `neutral` の境目のように、人が読んでも迷うコメントは AI の判定も揺れやすくなります。

---

## Step3. Genie Code と会話して Genie Agent を作る（25–37分）

**ゴール：** 3つのテーブルと分析用の定義を設定した Genie Agent（旧 Genie スペース）ができている。

1. 配布した **`Genie設定メモ.pdf`** を開き、何が書いてあるかざっと確認します。
2. 画面右上の **Genie Code** アイコンを押してチャットを開きます。
3. プロンプト欄の **「＋」** を押すか、ドラッグ＆ドロップで `Genie設定メモ.pdf` を添付します。
4. 次のように依頼します。

    ```text
    添付のメモに従って Genie agent を作成してください。
    テーブルは workspace.genie_handson.survey_enriched、
    workspace.genie_handson.participants、workspace.genie_handson.usage_logs です。
    ```

5. Genie Code がテーブル・説明文・質問例の案を出してきます。内容を確認し、問題がなければ作成を承認します。
6. 作成された Genie Agent を開き、**Instructions** に次の定義が入っているか確認します。入っていなければ、Genie Code に追加を依頼するか、自分で書き足してください。

| 用語 | 定義 |
|---|---|
| 感情ラベル | `sentiment`（`positive`／`negative`／`neutral`／`mixed`） |
| ポジティブ率 | `sentiment = 'positive'` の人の割合（`sentiment` が `NULL` の人は分母から除く） |
| 利用日数 | `login` があった日の数 |
| アクティブユーザ | 4週間の利用日数が12日以上（週平均3日以上）の人 |
| 満足度 | `q1_satisfaction` の平均 |

> **注意：** 添付ファイルはそのチャットの中だけで有効です。新しいチャットで作り直すときは、もう一度添付してください。

---

## Step4. Genie に質問して分析する（37–50分）

**ゴール：** アンケートとログを組み合わせて、「答えたこと」と「実際の行動」のズレを見つける。

Genie には、同僚に話しかけるような普段の言葉で質問して大丈夫です。下の質問を上から順に、そのままコピーして聞いてみましょう。

**回答が出たら、回答に付いている SQL（コード）の表示を開いて、Genie がどうやって計算したのかを必ず見てください。**

| # | Genie にこう聞いてみよう | ポイント |
|---|---|---|
| ① | AIありのグループとAIなしのグループで、満足度ってどれくらい違う？ | まずは肩慣らし |
| ② | アンケートで「毎日使った」って答えた人、本当に毎日使ってた？実際は週1日以下しか使ってなかった人って何人いる？ | **ここが今日のメイン。** アンケートとログのズレが見える |
| ③ | コメントがポジティブだった人の割合って、AIありとAIなしでどれくらい違う？ | Step2 の AI 判定を使う |

**最後に、ざっくりした質問をしてみましょう。**

④ はわざとあいまいにした質問です。何を調べるかは Genie におまかせします。

```text
このデータから分かることを、AI推薦機能の試験導入レポートとして詳しくまとめてください。
R&D部門の部長が「全社に展開するかどうか」を判断するための資料にしたいです。
根拠になる数字と、気をつけるべき点も入れてください。
```

レポートが出てきたら、次の3つを見てみましょう。

- ①〜③で自分が確かめた数字と、レポートの数字は合っている？
- 自分では聞かなかった観点（ログイン日数、AIのおすすめを開いた回数、部署や年代など）が入っている？
- 「AI推薦のおかげで満足度が上がった」のように、データだけでは言い切れないことを言い切っていない？

**早く終わった人は：**

- レポートを読んで気になったところを、「これってどういうこと？」「部署ごとだとどう？」と続けて聞いてみる
- 自分で気になったことを聞いてみる（例：「満足って答えてるのに、あんまり使ってない人ってどんな人？」）
- ④ の頼み方を変えて（「3行で」「表にして」「反対意見も入れて」など）、レポートがどう変わるか比べる

---

## まとめ（50–60分）

1. **Genie が書いた SQL は必ず確認しましょう。** 自然言語の質問は解釈の幅があります。「週あたり」「毎日」をどう計算したか、結合の仕方は正しいかを自分の目で確かめてください。
2. **記述統計は Genie で、検定はノートブックで確定しましょう。** 平均・分布・群間の差を探るのは Genie が得意です。t検定や効果量などの推論統計は、ノートブック（Python）で検算してから結論にしてください。
3. **自分の研究に応用できます。** 「アンケート（自己申告）＋ログ（実際の行動）」の組み合わせは、ユーザ実験・教育・HCI・組織研究などで広く使えます。Free Edition は授業後もそのまま使えるので、続きを試してみてください。
4. **実データを持ち込む前に確認しましょう。** 自分の研究データを使う場合は、倫理審査で認められた範囲か、個人情報が含まれていないか、事前に確認してください。
