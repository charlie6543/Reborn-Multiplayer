# The SCRIPTS constant is initialized in game's respective Bootstrap.rb file which is loaded before this one.
# Note that ScriptLoader needs to be loaded using Scripts.rxdata. Loading it using preloadScript in mkxp.json breaks F12 reset.

# macOS version of mkxp-z has the standard libraries located elsewhere but they're in load path by default.
$:.push('stdlib') unless System.platform[/macOS/]
# Fix loading of rbconfig gem.
$:.push('stdlib/x64-mingw32') if System.platform[/Windows/]
$:.push('stdlib/x86_64-linux') if System.platform[/Linux/]
$:.push('../Resources/Ruby/3.1.0/x86_64-darwin') if System.platform[/macOS/]
# Add external gems to load path.
$:.push('gems')

# Let Net::HTTP know where to look for cacert file
ENV['SSL_CERT_FILE'] = 'cacert.pem'

# JoiPlay RPG Maker Plugin 1.20.51 completely broke require so we have to hack the path to make it work.
def gem(name)
  if $joiplay
    require File.expand_path("../gems/" + name + ".rb", __FILE__)
  else
    require name
  end
end

def fileExists?(file)
  # System.file_exist? respects paths defined in "patches" directive in mkxp.json, unlike File.exist?.
  return System.file_exist?(file) if defined?(System.file_exist?)

  # JoiPlay however doesn't use mkxp.json, nor does it have a System.file_exist? so we need to use ugly workaround.
  return File.exist?(file) || File.exist?("patch/" + file)
end

def logError(e)
  btrace = ""
  if e.backtrace
    maxlength = $INTERNAL ? 25 : 10
    e.backtrace[0, maxlength].each do |i|
      btrace = btrace + "#{i}\n"
    end
  end
  message = "[#{GAMETITLE} #{GAMEVERSION}]\nException: #{e.class}\nMessage: #{e.message}\n#{btrace}\n"
  errorlog = "errorlog.txt"
  if (Object.const_defined?(:RTP) rescue false)
    errorlog = RTP.getSaveFileName("errorlog.txt")
  end
  File.open(errorlog, "ab") { |f| f.write(message) }
end

if $DEBUG
  begin
    gem 'pp'
  rescue LoadError
  end
end

if $joiplay
  if !File.exist?("Game.exe") || File.size("Game.exe") > 0
    print "Please download the JoiPlay version of the game instead of the Windows version."
    exit
  end

  plugin = MKXP.plugin_version.to_i rescue 0
  if plugin < 12053
    print "Upgrade JoiPlay RPG Maker Plugin to version 1.20.53 or newer."
    exit
  end
end

if Dir.pwd.downcase.include?("/temp/")
  print "Please extract the game before playing it.\n- RebornVerse Team"
  exit
end

SCRIPTS.each do |path|
  begin
    next if path.nil?

    # scripttime = Time.now
    code = File.open('Scripts/' + path + '.rb', 'r') { |f| f.read }
    # MKXP.run_postload(code) if $joiplay
    code = MKXP.apply_overrides(code) if $joiplay
    eval(code, nil, path)
    # scripttimes.append(Time.now-scripttime)
    # scripttimes.append(script[1])
    # scripttimes.append("\n")
  rescue
    # pbPrintException($!)
    e = $!
    btrace = ""
    if e.backtrace
      maxlength = $INTERNAL ? 25 : 10
      e.backtrace[0, maxlength].each do |i|
        btrace = btrace + "#{i}\n"
      end
    end
    message = "[#{GAMETITLE} #{GAMEVERSION}]\nException: #{e.class}\nMessage: #{e.message}\n#{btrace}"
    errorlog = "errorlog.txt"
    if (Object.const_defined?(:RTP) rescue false)
      errorlog = RTP.getSaveFileName("errorlog.txt")
    end
    errorlogline = errorlog.sub(Dir.pwd + "\\", "").sub(Dir.pwd + "/", "")
    if errorlogline.length > 20
      errorlogline = "\n" + errorlogline
    end
    File.open(errorlog, "ab") { |f| f.write(message) }
    print("#{message}\nThis exception was logged in #{errorlogline}.\nPress Ctrl+C to copy this message to the clipboard.")
  end
end

# Prevents game from forcibly closing after an error so you can restart using F12.
loop do
  Graphics.update
  Input.update
end
