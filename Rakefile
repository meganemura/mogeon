# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'

begin
  require 'bundler'
  Bundler.require
rescue LoadError
end

Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'mogeon'
  app.frameworks += ["SpriteKit"]
  app.files_dependencies 'app/unit/enemy.rb'  => 'app/unit/base.rb'
  app.files_dependencies 'app/unit/friend.rb' => 'app/unit/base.rb'
  app.files_dependencies 'app/unit/tile.rb'   => 'app/unit/base.rb'
end
