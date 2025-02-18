namespace :users do
  desc "既存のユーザーに新しいプロフィールフィールドのデフォルト値を設定する"
  task migrate_profiles: :environment do
    puts "既存ユーザーのプロフィール情報を更新中..."
    
    User.where(username: nil).find_each do |user|
      # ランダムなユーザー名を生成（既存のものと重複しないようにする）
      base_username = "user_#{SecureRandom.hex(4)}"
      username = base_username
      counter = 1
      
      # ユーザー名が重複する場合は、末尾に数字を追加して重複を避ける
      while User.exists?(username: username)
        username = "#{base_username}_#{counter}"
        counter += 1
      end
      
      user.update_columns(
        username: username,
        icon: "/default_icon.png",
        profile: "よろしくお願いします。"
      )
      puts "ユーザー(#{user.email})を更新: username=#{username}"
    end
    
    puts "更新完了！"
  end
end