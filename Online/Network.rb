require 'socket'

NETWORK_HOST = '45.55.245.165'
NETWORK_PORT = 1338

def localServer?
  return ["localhost", "127.0.0.1", "::1"].include?(NETWORK_HOST)
end

################################################################################
#-------------------------------------------------------------------------------
# Author: Alexandre
# Main Network procedures
#-------------------------------------------------------------------------------
################################################################################
class Network
  attr_accessor :loggedin
  attr_accessor :socket
  attr_accessor :username

  ################################################################################
  #-------------------------------------------------------------------------------
  # Let's start the scene and initialise the socket variable.
  #-------------------------------------------------------------------------------
  ################################################################################
  def initialize
    @loggedin = false
    @socket = nil
    @username = ""
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Open's a connection to the server.
  #-------------------------------------------------------------------------------
  ################################################################################
  def open
    begin; File.delete(RTP.getSaveFolder + '/network.log'); rescue; end
    @socket = TCPSocket.new(NETWORK_HOST, NETWORK_PORT)
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Sends a disconnect confirm to the server and closes the socket.
  #-------------------------------------------------------------------------------
  ################################################################################
  def close
    @loggedin = false
    @socket.send("<DSC>", 0) if @socket != nil && !@socket.closed?
    @socket.close if @socket != nil
    @socket = nil
  end

################################################################################
#-------------------------------------------------------------------------------
# Listen's for any incoming messages from the server.
#-------------------------------------------------------------------------------
################################################################################
=begin
def listen
  updatelistenarray
  if $listenarray[0] != nil
    ret = $listenarray[0]
    $listenarray.delete_at(0)
    return ret
  end
end


def updatelistenarray
  message=listenserver
  $listenarray=Array.new if $listenarray==nil || !$listenarray.is_a?(Array)
  $listenarray.push(message) if message != ""
end
=end

  def listen
    return "<DSC reason=missing network socket>" if @socket.nil?

    begin
      return "" if IO.select([@socket], nil, nil, 0.01) == nil

      buffer = @socket.recv(0xFFFF)
      buffer = buffer.split("\n", -1)
      if @previous_chunk != nil
        buffer[0] = @previous_chunk + buffer[0]
        @previous_chunk = nil
      end
      last_chunk = buffer.pop
      @previous_chunk = last_chunk if last_chunk != ''
      buffer.each { |message|
        message.force_encoding(Encoding::UTF_8)
        case message
          when /<PNG>/ then next
        else
          self.log "IN " + mask(message) if message.to_s != ""
          return message
        end
      }
    rescue Errno::ECONNRESET, Errno::ECONNABORTED, Errno::EPIPE, IOError => e
      @loggedin = false
      @socket.close if @socket != nil
      logError(e)

      btrace = ""
      if e.backtrace
        maxlength = $INTERNAL ? 25 : 10
        e.backtrace[0, maxlength].each do |i|
          btrace = btrace + "#{i}\n"
        end
      end
      File.write(RTP.getSaveFolder + '/network.log', "#{e.class}\n#{e.message}\n#{btrace}", mode: 'a+')

      return "<DSC reason=#{e.class} #{e}>"
    end
  end

  ################################################################################
  #-------------------------------------------------------------------------------
  # Sends a message with a newline character.
  #-------------------------------------------------------------------------------
  ################################################################################
  def send(message)
    self.log "OUT " + mask(message) if message != "<BEAT>"
    begin
      @socket.send(message + "\n", 0)
    rescue Errno::ECONNRESET, Errno::ECONNABORTED, Errno::EPIPE, IOError => e
      @loggedin = false
      @socket.close if @socket != nil
      logError(e)
    end
  end

  def log(message)
    puts message
    File.write(RTP.getSaveFolder + '/network.log', Time.now.to_s + " " + message + "\n", mode: 'a+')
  end
end

def mask(message)
  mask = "[HIDDEN]"

  patterns = {
    /<REG user=(.*) pass=(.*)>/ => ->(_) { "<REG user=#{$1} pass=#{mask}>" },
    /<LOG user=(.*) pass=(.*) gametitle=(.*) gameversion=(.*)>/ => ->(_) { "<LOG user=#{$1} pass=#{mask} gametitle=#{$3} gameversion=#{$4}>" },
    /<TRA party=(.*)>/ => ->(_) { "<TRA party=#{mask}>" },
    /<TRA offer=(.*) index=(.*)>/ => ->(_) { "<TRA offer=#{mask} index=#{$2}>" },
    /<WONTRA species=(.*) p_id=(.*) insert=(.*) delete=(.*)>/ => ->(_) { "<WONTRA species=#{$1} p_id=#{$2} insert=#{mask} delete=#{$4}>" },
    /<WONTRA pokemon=(.*) user=(.*) id=(.*)>/ => ->(_) { "<WONTRA pokemon=#{mask} user=#{$2} id=#{$3}>" },
    /<BATCHAL user=(.*) trainer=(.*) name=(.*)>/ => ->(_) { "<BATCHAL user=#{$1} trainer=#{mask} name=#{$3}>" },
    /<BATHOST user=(.*) trainer=(.*) field=(.*) name=(.*)>/ => ->(_) { "<BATHOST user=#{$1} trainer=#{mask} field=#{$3} name=#{$4}>" },
    /<BATHOST opponent=(.*) result=(.*) field=(.*) name=(.*)>/ => ->(_) { "<BATHOST opponent=#{mask} result=#{$2} field=#{$3} name=#{$4}" },
    /<BAT choices=(.*) rseed=(.*) special=(.*)>/ => ->(_) { "<BAT choices=#{mask} rseed=#{mask} special=#{$3}>" },
    /<BEAT>/ => ->(_) { return }
  }

  patterns.each do |pattern, formatter|
    if message =~ pattern
      message = formatter.call(message)
      break
    end
  end

  return message
end
