# VAULT Rails MVP

README仕様に沿った、吸えログとは無関係の新規Rails MVPです。

## 実装済み

- bcrypt / `has_secure_password` によるログイン
- Organization / User / Company / Contact / BusinessCard / ContactNote
- role: `service_admin`, `org_admin`, `member`
- Organizationごとのデータ分離
- ホーム画面で登録済みの名刺を検索 / スクロール閲覧
- 上部ナビから登録画面へ移動
- 会社の一覧 / 登録 / 編集 / 詳細 / 非表示 / 復元
- 担当者の登録 / 編集 / 詳細 / 非表示 / 復元
- Active Storageによる名刺画像アップロード
- 名刺写真からの人・会社・名刺情報の自動登録
- 共有メモ / 個人メモ
- `archived_at` による非表示と復元
- 同一Organization内の重複候補警告
- 人・会社・名刺情報のシンプル検索

## 起動

```bash
bundle install
bin/rails db:setup
bin/rails server
```

スマホのデモ機から同一Wi-Fiでアクセスする場合:

```bash
bin/rails server -b 0.0.0.0 -p 3010
```

MacのIPアドレスを確認して、スマホから `http://<MacのIP>:3010` を開きます。Cloudflare Tunnelを使う場合の一時URLもdevelopment環境で許可しています。

## 権限確認

```bash
bin/rails test
```

主な確認対象:

- `service_admin` は全Organizationを閲覧できます
- `org_admin` と `member` は自Organizationに限定されます
- `member` は自分が登録した会社・担当者・名刺のみ編集できます
- `member` は非表示データを表示に戻せません
- 停止したユーザーの登録済みデータはOrganizationの資産として残ります

## 権限設計

- `service_admin`: 全Organizationを管理できます。Organization作成・停止・削除扱い、org_admin作成、全ユーザー閲覧、全データ閲覧、非表示データ復元、システム/OCR/課金管理土台を操作できます。
- `org_admin`: 自Organization内だけ管理できます。全名刺閲覧・編集、非表示一覧閲覧・表示戻し、member作成・編集・停止・復元ができます。
- `member`: 自Organization内の名刺閲覧・検索、共有メモ追加、個人メモ追加、自分が登録した会社・担当者・名刺の編集ができます。

物理削除は実装していません。停止・削除扱い・非表示は `archived_at` を使い、後から表示に戻せます。

## デモログイン

- Organization管理者: `admin@example.com` / `password`
- メンバー: `member@example.com` / `password`
- サービス管理者: `service@example.com` / `password`

通常ユーザーは所属Organizationのデータだけを閲覧・編集できます。`service_admin` は全Organizationを閲覧できます。

## 名刺写真から登録

ログイン後、上部ナビの「登録」から画像をアップロードします。

macOS Vision OCRが使える環境では画像から文字を読み取り、会社・担当者・名刺画像を一括登録します。この環境のようにSwift/SDKの組み合わせでOCRが動かない場合は、同じ画面の「読み取りテキスト」にOCR結果を貼り付けると、同じ解析ロジックで登録できます。

Google Cloud Vision APIを使う場合は、以下の環境変数を設定します。

```bash
BUSINESS_CARD_OCR_PROVIDER=google_cloud_vision
GOOGLE_CLOUD_VISION_API_KEY=your-api-key
```

または、`service_admin` でログインして `/system_settings` からOCR providerを `Google Cloud Vision` にし、APIキーを保存します。Google Cloud Vision APIは公式RESTの `images:annotate` に `DOCUMENT_TEXT_DETECTION` を投げる構成です。
