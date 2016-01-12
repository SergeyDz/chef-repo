require 'rubygems'
require 'bundler'
require 'rake'


def master?
  `git rev-parse --abbrev-ref HEAD`.strip == 'master'
end


def test_kitchen?
  File.exist? '.kitchen.yml'
end


def realm?
  `git ls-files` =~ /\bBerksfile\.lock\b/
end


def current_version
  File.read('VERSION').strip
end


def youre_behind?
  `git fetch >/dev/null 2>&1`
  behind = `git log ..origin/master --oneline`.split("\n").length > 0
  raise unless $?.exitstatus.zero?
  return behind
end


def youre_behind!
  if youre_behind?
    raise "ERROR: You're out of sync with the remote! Try 'git pull --rebase'"
  end
end


def bump component
  youre_behind!
  `tony bump #{component}`
  if realm?
    `berks`
    `git add Berksfile.lock`
  end
  version = current_version
  `git add VERSION`
  `git commit -m "Version bump to #{version}"`
  `git tag -a v#{version} -m v#{version}`
  raise 'Could not add tag' unless $?.exitstatus.zero?
  puts 'Version is now "%s"' % version
end


def bump_and_release component
  bump component
    youre_behind!
  `git push`
  raise 'Push failed' unless $?.exitstatus.zero?
  `git push --tag`
  raise 'Tag push failed' unless $?.exitstatus.zero?
end


raise 'ERROR: You should only run tasks on the "master" branch' unless master?


desc 'Perform syntax check and linting'
task :lint do
  system "knife cookbook test magic -o .."
  raise 'Failed "knife cookbook test"' unless $?.exitstatus.zero?
  system 'foodcritic .' # Merely a suggestion
end


if test_kitchen?
  desc 'Execute default Test Kitchen test suite'
  task test: :lint do
    system 'kitchen test'
  end
end


desc 'Print the current version'
task :version do
  puts current_version
end


namespace :release do
  desc 'Release new major version'
  task :major do
    bump_and_release :major
  end

  desc 'Release new minor version'
  task :minor do
    bump_and_release :minor
  end

  task :patch do
    bump_and_release :patch
  end
end

desc 'Release a new patch version'
task release: %w[ release:patch ]


if realm?
  desc 'Apply Berksfile lock to an environment'
  task :constrain, [ :env ] do |_, args|
    youre_behind!
    `git tag -a #{args[:env]} -m #{args[:env]} --force`
    `git push --tag --force`
  end
end
