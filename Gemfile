source "https://rubygems.org"

# Deliberately minimal: Jekyll + the three plugins that produce SEO meta, RSS
# and a sitemap. No theme gem, no pagination plugin (Jekyll 4 paginates
# natively), no include-cache (that only existed for Minimal Mistakes).
gem "jekyll", "~> 4.4"

group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.18"
  gem "jekyll-seo-tag", "~> 2.9"
  gem "jekyll-sitemap", "~> 1.4"
end

gem "rake", "~> 13.0" # rake serve / build / check / new / highlight
gem "webrick", "~> 1.9" # Jekyll's dev server on Ruby 3.x
