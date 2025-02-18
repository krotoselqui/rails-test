# 本番環境への移行手順

## 1. データベースマイグレーション

まず、新しいカラムを追加するマイグレーションを実行します：

```bash
RAILS_ENV=production bin/rails db:migrate
```

## 2. 既存ユーザーデータの移行

次に、既存ユーザーのプロフィールデータを設定するRakeタスクを実行します：

```bash
RAILS_ENV=production bin/rails users:migrate_profiles
```

## 注意事項

- **バックアップ**: 作業前に必ずデータベースのバックアップを取得してください
```bash
# MySQLの場合
mysqldump -u [ユーザー名] -p [データベース名] > backup_$(date +%Y%m%d).sql
```

- **実行時間**: ユーザー数によっては時間がかかる可能性があります
- **ロールバック手順**: 問題が発生した場合は以下のコマンドでロールバックできます
```bash
RAILS_ENV=production bin/rails db:rollback
```

## 動作確認項目

1. 既存ユーザーのログイン確認
2. プロフィール情報の表示確認
3. プロフィール編集機能の動作確認
4. 新規ユーザー登録の動作確認

## トラブルシューティング

### ユーザー名の重複が発生した場合
Rakeタスク `users:migrate_profiles` は自動的に重複を回避しますが、
問題が発生した場合は以下のSQLで重複をチェックできます：

```sql
SELECT username, COUNT(*) as count 
FROM users 
GROUP BY username 
HAVING count > 1;
```

### プロフィール画像が表示されない場合
1. デフォルトアイコンのパス `/default_icon.png` が正しく設定されているか確認
2. アセットのプリコンパイルを実行
```bash
RAILS_ENV=production bin/rails assets:precompile