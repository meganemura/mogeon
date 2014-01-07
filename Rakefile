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
  app.files_dependencies 'app/mogeon/unit/body.rb'   => 'app/mogeon/unit/base.rb'
  app.files_dependencies 'app/mogeon/unit/enemy.rb'  => 'app/mogeon/unit/base.rb'
  app.files_dependencies 'app/mogeon/unit/friend.rb' => 'app/mogeon/unit/base.rb'
  app.files_dependencies 'app/mogeon/unit/tile.rb'   => 'app/mogeon/unit/base.rb'
end
