require 'sinatra'

configure :development do
  ENV['DATABASE_URL'] = 'sqlite://db/dev.db'

  def reload!
    # Tux reloading tip: https://github.com/cldwalker/tux/issues/3
    exec $PROGRAM_NAME, *ARGV
  end
end
