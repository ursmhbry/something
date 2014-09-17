require 'bundler/setup'
require 'curses'
require 'stringio'

Curses.init_screen

root = Curses::Window.new(0, 0, 0, 0)

output = root.subwin(Curses.lines - 2, 0, 0, 0)
input  = root.subwin(1, 0, Curses.lines - 1, 0)

output.scrollok true

input << '>> '
input.refresh

def context
  @binding ||= binding
end

while line = input.getstr
  output << ">> #{line}" << "\n"

  begin
    out, err = $stdout, $stderr
    io       = $stdout = $stderr = StringIO.new

    ret = context.eval(line)

    output << io.string
    output << '=> ' << ret.inspect << "\n"

    $stdout, $stderr = out, err
  rescue => e
    output << "#{e.class}: #{e.message}" << "\n"
  end

  output.refresh

  input.setpos 0, 3
  input.clrtoeol
  input.refresh
end

output.close
input.close
