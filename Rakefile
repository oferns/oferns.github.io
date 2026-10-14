# Site tasks — run `rake -T` to list them.
require "date"

desc "Serve locally with live reload at http://localhost:4000"
task :serve do
  sh "bundle exec jekyll serve --livereload"
end

desc "Build the site to _site (same command CI runs)"
task :build do
  sh "bundle exec jekyll build"
end

desc "Build, then run the CI smoke assertions"
task check: :build do
  sh "bash scripts/check.sh _site"
end

desc "Scaffold a post: rake new TITLE='My post' [TAGS=a,b] [CATEGORY=math]"
task :new do
  title = ENV["TITLE"] or abort %(usage: rake new TITLE="My post" [TAGS=a,b] [CATEGORY=math])
  args = [title]
  args << (ENV["TAGS"] || "")
  args << (ENV["CATEGORY"] || "") if ENV["CATEGORY"]
  sh "bash", "scripts/new-post.sh", *args
end

desc "Bump every dependency within the Gemfile constraints (then run rake check)"
task :update do
  sh "bundle update"
end
