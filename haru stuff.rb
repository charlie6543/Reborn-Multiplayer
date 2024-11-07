#############
# Game Window Mover - Haru
#
# SetWindowPos sets the window position based on:
#   l: window object (in C, HWND)
#   i: don't care put it as 0
#   i: x pos int
#   i: y pos int
#   i: width int
#   i: height int
#   p: don't care put it as zero (pointer)
# FindWindowEx gets the game window using GAMETITLE (Defined in SystemConstants.rb for Reborn-Essentials games):
#   l: parent window object
#   l: child window object
#   p: class pointer
#   p: title pointer (pointers are typically packed 'l4' strings for MiniFFI/Win32API)
# AdjustWindowRectEx adjusts given rect bounds so MiniFFI/Win32API doesn't royally screw it up:
#   p: bounds to convert [left, top, right, bottom]
#   l: style long. don't change this unless you know the proper hex values
#   i: does the window have a menu? prolly not, leave as 0
#   p: extended window pointer. why is this not a long? why is the other not a pointer? don't touch it again.
# GetWindowRect gets the current window position"
#   l: window object
#   p: packed string to store data into
#
# (0,0) may not be top left corner depending on the monitor. Sucks.
#############
if Rejuv
  if System.platform[/Windows/]
    SetWindowPos        = Win32API.new 'user32', 'SetWindowPos', ['l', 'i', 'i', 'i', 'i', 'i', 'p'], 'i'
    FindWindowEx        = Win32API.new 'user32', 'FindWindowEx', ['l', 'l', 'p', 'p'], 'i'
    AdjustWindowRectEx  = Win32API.new 'user32', 'AdjustWindowRectEx', ['p', 'l', 'i', 'p'], 'i'
    GetWindowRect       = Win32API.new 'user32', 'GetWindowRect', ['l', 'p'], 'i'
  end
end

def moveWindow(x = 0, y = 0, forceNonWindows = false)
  return if $Settings.photosensitive == 1

  if !defined?(SetWindowPos) || forceNonWindows
    $game_screen.start_shake(10, 10, 10) if $game_screen.shake == 0
    return
  end
  window = FindWindowEx.call(0, 0, 0, GAMETITLE)

  posStr = [0, 0, 0, 0].pack('l4') # empty
  GetWindowRect.call(window, posStr)
  pos = posStr.unpack('l4')
  # puts pos.inspect

  rect = [0, 0, pos[2] - pos[0] - 17, pos[3] - pos[1] - 40].pack('l4') # left, top, right, bottom
  style = 0x00CF0000 # WS_OVERLAPPEDWINDOW
  hasMenu = 0 # false
  styleEx = 0x00000200 # WS_EX_CLIENTEDGE
  AdjustWindowRectEx.call(rect, style, hasMenu, styleEx)
  newrect = rect.unpack('l4')
  # puts newrect.inspect


  SetWindowPos.call(window, 0, pos[0] + x, pos[1] + y, newrect[2] - newrect[0] - 3, newrect[3] - newrect[1] - 3, 0)
end

def shakeScreen1
  moveWindow(20, -20)
end

def shakeScreen2
  moveWindow(-20, 40)
end

def shakeScreen3
  moveWindow(30, -30)
end

def shakeScreen4
  moveWindow(-30, 10)
end

def shakeScreen5
  moveWindow(10, -5)
end

def shakeScreen6
  moveWindow(-10, 5)
end

def shakeScreen
  shakeScreen1
  sleep(1.0 / 5.0)
  shakeScreen2
  sleep(1.0 / 5.0)
  shakeScreen3
  sleep(1.0 / 5.0)
  shakeScreen4
  sleep(1.0 / 5.0)
  shakeScreen5
  sleep(1.0 / 5.0)
  shakeScreen6
end

def cprint(value) # i didn't want to type out $stdout.print every time lol
  $stdout.print(value)
  $stdout.flush
end

def deep_copy(obj)
  return Marshal.load(Marshal.dump(obj))
end

def toProperCase(str)
  str = str.to_s if str.is_a?(Symbol)
  split = str.split(" ")
  ret = ""
  split.each { |s|
    ret += s[0].upcase + s[1, s.length].downcase
    ret += " " if split.length != 1
  }
  return ret
end

def extractFormProc(data, key) # string of file contents from reading, specific hash proc value
  basefile = ""
  game = GAMEFOLDER
  game = $gamefolder if $gamefolder
  File.open(scripts_path + "/#{game}/montext.rb") { |f|
    basefile = f.read
  }
  basefilearr = basefile.split(/\n/)
  loc1 = data.source_location
  contents = basefilearr
  ret = contents[loc1[1] - 1]
  ret = ret[ret.index("p")..]

  return ret.chop if ret[-2..] == "},"

  for line in loc1[1]...contents.length
    line = contents[line].gsub(/\s+/, " ")
    ret += "\n#{line}"

    break if checkStringBracketSyntax(ret, key)
  end
  ret.chop! if ret[-1] == ","
  return ret
end

def checkStringBracketSyntax(string, key)
  stack = []
  convert = { "[" => "]", "{" => "}", "(" => ")" }
  for char in 0...string.length
    stack.push(string[char]) if string[char] == "[" || string[char] == "{" || string[char] == "("
    if string[char] == "]" || string[char] == "}" || string[char] == ")"
      if string[char] != convert[stack.last]
        raise "#{key} syntax error, check your code"
        break
      end
      stack.pop
    end
  end
  return stack.empty?
end

class TrueClass
  def to_i
    return 1
  end
end

class FalseClass
  def to_i
    return 0
  end
end

def fieldSymFromGraphic(graphic)
  return :INDOOR if graphic == nil

  $cache.FEData.each { |key, data|
    return key if data.graphic.include?(graphic)
  }
  return :INDOOR
end

def rbgToHSL(red, green, blue)
  red /= 255.0
  green /= 255.0
  blue /= 255.0
  max = [red, green, blue].max
  min = [red, green, blue].min
  hue = (max + min) / 2.0
  sat = (max + min) / 2.0
  light = (max + min) / 2.0

  if (max == min)
    hue = 0
    sat = 0
  else
    d = max - min;
    sat = light >= 0.5 ? d / (2.0 - max - min) : d / (max + min)
    case max
      when red
        hue = (green - blue) / d + (green < blue ? 6.0 : 0)
      when green
        hue = (blue - red) / d + 2.0
      when blue
        hue = (red - green) / d + 4.0
    end
    hue /= 6.0
  end
  return [(hue * 360), (sat * 100), (light * 100)]
end

def hslToRGB(hue, sat, light)
  hue = hue / 360.0
  sat = sat / 100.0
  light = light / 100.0

  red = 0.0
  green = 0.0
  blue = 0.0

  if (sat == 0.0)
    red = light.to_f
    green = light.to_f
    blue = light.to_f
  else
    q = light < 0.5 ? light * (1 + sat) : light + sat - light * sat
    p = 2 * light - q
    red = hueToRGB(p, q, hue + 1 / 3.0)
    green = hueToRGB(p, q, hue)
    blue = hueToRGB(p, q, hue - 1 / 3.0)
  end

  return [(red * 255), (green * 255), (blue * 255)]
end

def hueToRGB(p, q, t)
  t += 1 if (t < 0)
  t -= 1                                  if (t > 1)
  return (p + (q - p) * 6 * t)            if (t < 1 / 6.0)
  return q                                if (t < 1 / 2.0)
  return (p + (q - p) * (2 / 3.0 - t) * 6) if (t < 2 / 3.0)

  return p
end

def checkAbilDescs
  $cache.abil.each { |abil, data|
    puts "#{abil},\n" if data.desc.length > 50
  }
end

def enforceTrainerType
  $cache.trainertypes.each { |sym, data|
    $Trainer.trainertype = sym if data.checkFlag?(:ID) == $Trainer.trainertype
  }
  $Trainer.trainertype = $cache.trainertypes.keys[0] if $Trainer.trainertype.is_a?(Integer)
end

def convertMapPos(pos) # REJUV
  return pos if !Rejuv
  return pos if pos[0] == 0 || pos[0] == 1
  return pos if pos[0] == 2 && pos[1] > 15

  pos[0] += 1
  return pos
end

def convertTownMap
  mapdat = $cache.town_map
  exporttext = "TOWNMAP={\n"
  for i in 0...mapdat.length
    region = mapdat[i]
    exporttext += "  #{i} => {\n"
    exporttext += "    :name => #{region[0].inspect},\n"
    exporttext += "    :filename => #{region[1].inspect},\n"
    exporttext += "    :points => {\n"
    if !region[2].nil?
      region[2].each { |arr|
        pos = [i, arr[0], arr[1]]
        pos = convertMapPos(pos) if Rejuv
        exporttext += "      [#{pos[1]}, #{pos[2]}] => {\n"
        exporttext += "        :name => \"#{arr[2]}\",\n"
        exporttext += "        :poi => #{arr[3].nil? ? "nil" : "\"#{arr[3]}\""},\n"
        exporttext += "        :flyData => ["
        exporttext += "#{arr[4]}, #{arr[5]}, #{arr[6]}" if arr[4]
        exporttext += "], # mapid, x, y\n"
        exporttext += "      },\n"
      }
    end
    exporttext += "    },\n"
    exporttext += "  },\n"
  end
  exporttext += "}\n"

  File.open(scripts_path + "/#{GAMEFOLDER}/townmap.rb", "w") { |f|
    f.write(exporttext)
  }
end

def grayscale(col, method)
  case method
    when :L # luminance
      return (col.red * 0.2989 + col.green * 0.587 + col.blue * 0.114).floor
    when :A # average
      return ([col.red, col.green, col.blue].sum / 3).floor
    when :S # sight
      return (0.2126 * col.red + 0.7152 * col.green + 0.0722 * col.blue).floor
    else
      return col
  end
end

def fonttester(num = 22)
  str = "The quick brown fox jumps over the lazy dog."
  Kernel.pbMessage("\\gsc#{str}\n<fn=Garufan><fs=36>stupid</fs></fn> fox.\\egsc")
end

def thegif
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  spr = Sprite.new()
  spr.bitmap = Bitmap.new(".karma.gif")
  spr.viewport = viewport
  spr.bitmap.play
end

def theogv
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  spr = Sprite.new()
  Graphics.play_movie("out.ogv")
end

def fixShadowConversion
  File.open(scripts_path + "/#{GAMEFOLDER}/movetext.rb") { |f| eval(f.read) }
  for mon in $Trainer.party
    next if !mon.isShadow?

    fixShadowconvertMon(mon)
  end
  for box in 0...$PokemonStorage.maxBoxes
    for index in 0...$PokemonStorage[box].length
      mon = $PokemonStorage[box, index]
      next if !mon
      next if !mon.isShadow?

      fixShadowconvertMon(mon)
    end
  end
  if $PokemonGlobal.daycare[0][0] && $PokemonGlobal.daycare[0][0].isShadow?
    fixShadowconvertMon($PokemonGlobal.daycare[0][0])
  end
  if $PokemonGlobal.daycare[1][0] && $PokemonGlobal.daycare[1][0].isShadow?
    fixShadowconvertMon($PokemonGlobal.daycare[1][0])
  end
  remove_const(:MOVEHASH)
end

def fixShadowConvertMon(mon)
  if mon.shadowmoves
    newShadows = []
    for move in mon.shadowmoves
      if move == 0
        newShadows.push(0)
        next
      end
      for i in MOVEHASH.keys
        if MOVEHASH[i][:ID] == move
          newShadows.push(i)
          break
        end
      end
    end
    mon.shadowmoves = newShadows
  end
end

class Bitmap
  def pixel(x, y)
    return x + (y * self.width)
  end
end

class Color
  def to_i
    return self.alpha.to_i << 24 | self.blue.to_i << 16 | self.green.to_i << 8 | self.red.to_i
  end
end

class Integer
  def to_color
    a = self >> 24
    b = self >> 16 & 0xff
    g = self >> 8 & 0xff
    r = self & 0xff
    return Color.new(r, g, b, a)
  end
end

def getFossilMon(fossil)
  hash = {
    :HELIXFOSSIL => :OMANYTE, :DOMEFOSSIL => :KABUTO,
    :OLDAMBER => :AERODACTYL,
    :ROOTFOSSIL => :LILEEP,     :CLAWFOSSIL => :ANORITH,
    :SKULLFOSSIL => :CRANIDOS,  :ARMORFOSSIL => :SHIELDON,
    :COVERFOSSIL => :TIRTOUGA,  :PLUMEFOSSIL => :ARCHEN,
    :JAWFOSSIL => :TYRUNT,      :SAILFOSSIL => :AMAURA
  }
  # fossil bird + drake => dracozolt
  # fossil bird + dino  => arctozolt
  # fossil fish + drake => dracovish
  # fossil fish + dino  => arctovish
  $game_variables[:Fossil] = hash[fossil]
end

def getValidFields
  fieldsDisp = ["No Field"]
  fields = [0]
  $cache.FEData.each { |field, data|
    next if !data.name || data.name == "" || fieldsDisp.include?(data.name)

    fieldsDisp.push(data.name)
    fields.push(field)
  }
  return fields, fieldsDisp
end

def getRandomField
  fields, display = getValidFields
  return fields[rand(fields.length - 1) + 1]
end

def selectField
  fields, fieldsDisp = getValidFields
  fieldsDisp.push("Random")
  fields.push(:RAND)
  selected = Kernel.pbMessage("Choose a field to face your challenger on.", fieldsDisp)
  if fields[selected] == :RAND
    selected = rand(fields.length - 1) + 1
  end
  $game_variables[:Forced_Field_Effect] = fields[selected]
end

class String
  def white;          "\e[0m#{self}\e[0m"  end
  def black;          "\e[30m#{self}\e[0m" end
  def red;            "\e[31m#{self}\e[0m" end
  def green;          "\e[32m#{self}\e[0m" end
  def yellow;         "\e[33m#{self}\e[0m" end
  def blue;           "\e[34m#{self}\e[0m" end
  def magenta;        "\e[35m#{self}\e[0m" end
  def cyan;           "\e[36m#{self}\e[0m" end
  def gray;           "\e[37m#{self}\e[0m" end

  def bg_black;       "\e[40m#{self}\e[0m" end
  def bg_red;         "\e[41m#{self}\e[0m" end
  def bg_green;       "\e[42m#{self}\e[0m" end
  def bg_yellow;      "\e[43m#{self}\e[0m" end
  def bg_blue;        "\e[44m#{self}\e[0m" end
  def bg_magenta;     "\e[45m#{self}\e[0m" end
  def bg_cyan;        "\e[46m#{self}\e[0m" end
  def bg_gray;        "\e[47m#{self}\e[0m" end

  def bold;           "\e[1m#{self}\e[22m" end
  def italic;         "\e[3m#{self}\e[23m" end
  def underline;      "\e[4m#{self}\e[24m" end
  def blink;          "\e[5m#{self}\e[25m" end
  def reverse_color;  "\e[7m#{self}\e[27m" end
end

class Window_AdvancedTextPokemon < SpriteWindow_Base
  attr_accessor :fmtchars
  attr_accessor :textchars
end

class ShakingText < BitmapSprite
  def initialize(*args)
    super(*args)
    @original_x = self.x
    @original_y = self.y
  end

  attr_accessor :original_x
  attr_accessor :original_y
  attr_accessor :linePos

  def shake()
    offsetX = rand(-1..1)
    if self.x + offsetX > original_x + 3 || self.x + offsetX < original_x - 3
      self.x = @original_x
    else
      self.x += offsetX
    end

    offsetY = rand(-1..1)
    if self.y + offsetY > original_y + 3 || self.y + offsetY < original_y - 3
      self.y = @original_y
    else
      self.y += offsetY
    end
  end

  def scroll(scroll)
    self.oy += scroll
  end
end

def massEditMons
  $gamefolder = "Reborn"
  cprint "Reading #{$gamefolder}/montext.rb..."
  File.open(scripts_path + "/#{$gamefolder}/montext.rb") { |f|
    eval(f.read)
  }
  cprint "done.\n"
  spacetoclear = 0
  mons = MonDataHash.new()
  MONHASH.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    mons[key] = MonWrapper.new(key, value)
  }
  cprint "Compiled data for #{$gamefolder}/mons.dat#{" " * spacetoclear}\n"
  monDump(mons, game: $gamefolder)

  $gamefolder = "Rejuv"
  cprint "Reading #{$gamefolder}/montext.rb..."
  File.open(scripts_path + "/#{$gamefolder}/montext.rb") { |f|
    eval(f.read)
  }
  cprint "done.\n"
  spacetoclear = 0
  mons = MonDataHash.new()
  MONHASH.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    mons[key] = MonWrapper.new(key, value)
  }
  cprint "Compiled data for #{$gamefolder}/mons.dat#{" " * spacetoclear}\n"
  monDump(mons, game: $gamefolder)

  $gamefolder = "Desolation"
  cprint "Reading #{$gamefolder}/montext.rb..."
  File.open(scripts_path + "/#{$gamefolder}/montext.rb") { |f|
    eval(f.read)
  }
  cprint "done.\n"
  spacetoclear = 0
  mons = MonDataHash.new()
  MONHASH.each { |key, value|
    spacetoclear = key.to_s.length
    cprint "Compiling data for #{key}#{" " * spacetoclear}\r"
    mons[key] = MonWrapper.new(key, value)
  }
  cprint "Compiled data for #{$gamefolder}/mons.dat#{" " * spacetoclear}\n"
  monDump(mons, game: $gamefolder)
end

def checkEvos
  levels = []
  bsts = []
  $cache.pkmn.each { |mon, wrapper|
    wrapper.pokemonData.each { |form, monData|
      next if !monData.evolutions
      next if monData.evolutions.empty?

      evo = monData.evolutions[0]
      next if !(evo[:method] == :Level || evo[:method] == :LevelDay || evo[:method] == :LevelNight)

      species = evo[:species]
      level = evo[:parameter]
      bst = $cache.pkmn[species, 0].BaseStats.sum
      levels.push(level)
      bsts.push(bst)
    }
  }
  puts levels
  puts "BREAK"
  puts bsts
end
