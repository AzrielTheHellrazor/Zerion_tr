#!/bin/zsh

# Son commit mesajını al
last_commit=$(git log -1 --pretty=%B 2>/dev/null)

# Eğer son commit "commit-X" formatındaysa, numarayı çıkar
if [[ $last_commit =~ ^commit-([0-9]+)$ ]]; then
    # Son numarayı al ve 1 artır
    last_number=${match[1]}
    new_number=$((last_number + 1))
else
    # Eğer format uymazsa veya commit yoksa, 1'den başla
    new_number=1
fi

# Yeni commit mesajı
commit_message="commit-$new_number"

echo "📦 Değişiklikler ekleniyor..."
git add .

echo "💾 Commit atılıyor: $commit_message"
git commit -m "$commit_message"

echo "🚀 GitHub'a push ediliyor..."
git push

echo "✅ Tamamlandı! Commit mesajı: $commit_message"


