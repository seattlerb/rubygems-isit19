require 'rubygems/command_manager'

Gem::CommandManager.instance.register_command :isit19

Gem.pre_install do |i| # installer
  require 'isit19'

  spec = i.spec
  name = "#{spec.name} #{spec.version}"

  isit19 = IsIt19.new i.spec

  i.say

  if isit19.one_nine? then
    i.say "#{name} is #{isit19.percent} verified 1.9"
  else
    comment = isit19.maybe_one_nine?

    if comment then
      working = comment['version']
      i.say "#{name} might work, #{isit19.percent working} say #{working} works on 1.9"
    else
      i.say "Nobody has verified #{name} works with 1.9"
    end
  end

  i.say "Update #{isit19.url} with your experiences!"
  i.say
end

