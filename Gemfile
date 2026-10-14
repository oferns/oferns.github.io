source "https://rubygems.org"

# Jekyll + theme. Exact versions live in Gemfile.lock (committed); Dependabot
# opens PRs against it. CI and production both use this Gemfile — there is no
# "GitHub Pages provides its own gems" path any more.
gem "jekyll", "~> 4.4"
gem "minimal-mistakes-jekyll", "~> 4.28"

# Plugins. The `:jekyll_plugins` group is auto-required by Jekyll; they are also
# listed explicitly under `plugins:` in _config.yml.
group :jekyll_plugins do
  gem "jekyll-feed", "~> 0.18"
  gem "jekyll-include-cache", "~> 0.3" # MM's layouts use {% include_cached %}
  gem "jekyll-paginate", "~> 1.1"
  gem "jekyll-seo-tag", "~> 2.9"
  gem "jekyll-sitemap", "~> 1.4"
end

gem "rake", "~> 13.0" # rake serve / build / check / new
gem "webrick", "~> 1.9" # Jekyll's dev server on Ruby 3.x
