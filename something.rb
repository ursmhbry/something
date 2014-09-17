require 'bundler/setup'
require 'curses'
require 'stringio'

Curses.init_screen
Curses.start_color

Curses.init_pair Curses::COLOR_BLUE,  Curses::COLOR_BLUE,  Curses::COLOR_BLACK
Curses.init_pair Curses::COLOR_GREEN, Curses::COLOR_GREEN, Curses::COLOR_BLACK
Curses.init_pair Curses::COLOR_RED,   Curses::COLOR_RED,   Curses::COLOR_BLACK

root = Curses::Window.new(0, 0, 0, 0)

output = root.subwin(Curses.lines - 2, 0, 0, 0)
input  = root.subwin(1, 0, Curses.lines - 1, 0)

output.scrollok true

input.attron Curses.color_pair(Curses::COLOR_BLUE) | Curses::A_BOLD do
  input << '>> '
end

input.refresh

def context
  @binding ||= binding
end

while line = input.getstr
  output.attron Curses.color_pair(Curses::COLOR_BLUE) | Curses::A_BOLD do
    output << ">> "
  end

  output << line << "\n"

  begin
    out, err = $stdout, $stderr
    fakeio = $stdout = $stderr = StringIO.new

    ret = context.eval(line)

    output << fakeio.string

    output.attron Curses.color_pair(Curses::COLOR_GREEN) | Curses::A_BOLD do
      output << '=> '
    end

    output << ret.inspect << "\n"

    $stdout, $stderr = out, err
  rescue => e
    output.attron Curses.color_pair(Curses::COLOR_RED) | Curses::A_NORMAL do
      output << "#{e.class}: #{e.message}" << "\n"
    end
  end

  output.refresh

  input.setpos 0, 3
  input.clrtoeol
  input.refresh
end

output.close
input.close
