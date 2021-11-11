# Inspired by  https://github.com/adamperrry/ruby-mastermind/blob/master/colors.rb to get colorize working on replit.

# monkey patch String class to colorize text
class String
  def white
    "\e[0;37;49m#{self}\e[0m"
  end

  def black
    "\e[0;30;49m#{self}\e[0m"
  end

  def red
    "\e[91m#{self}\e[0m"
  end

  def light_red
    "\e[0;91;49m#{self}\e[0m"
  end

  def colorize(hash)
    case hash[:background]
    when :red
      new_self = "\e[41m#{self}\e[0m" 
    when :light_red
      new_self = "\e[101m#{self}\e[0m"
    else
      new_self = self
    end

    new_self
  end

  def green
    "\e[92m#{self}\e[0m"
  end

  def light_green
    "\e[0;92;49m#{self}\e[0m"
  end

  def yellow
    "\e[93m#{self}\e[0m"
  end

  def light_yellow
    "\e[0;93;49m#{self}\e[0m"
  end

  def blue
    "\e[0;34;49m#{self}\e[0m"
  end

  def light_blue
    "\e[0;94;49m#{self}\e[0m"
  end

  def magenta
    "\e[95m#{self}\e[0m"
  end

  def light_magenta
    "\e[0;95;49m#{self}\e[0m"
  end

end