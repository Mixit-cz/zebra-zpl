module Zebra
  class PrintJob

    attr_reader :printer

    def initialize(printer, check_printer = false)
      check_existent_printers printer if check_printer
      @printer = printer
    end

    def print(label, ip)
      @remote_ip = ip
      tempfile = label.persist
      send_to_printer tempfile.path
    end

    def raw_print(zpl, ip)
      @remote_ip = ip
      tempfile = Tempfile.new "zebra_label"
      tempfile << zpl
      tempfile.close
      @tempfile = tempfile
      send_to_printer tempfile.path
    end

    private

    def check_existent_printers(printer)
      existent_printers = Cups.show_destinations
      raise UnknownPrinter.new(printer) unless existent_printers.include?(printer)
    end

    def send_to_printer(path)
      platform_detector = PlatformDetector.new
      puts "* * * * * * * * * * * * Sending file to printer #{@printer_name} at #{@remote_ip.present? ? @remote_ip : 'default location'} * * * * * * * * * * "
      case platform_detector.os
        when :windows
          system(windows_command(path))
        else
          system(unix_command(path))
      end
    end

    def unix_command(path)
      cmd = "lp -d #{@printer_name} -o raw #{path}"
      cmd + " -h #{@remote_ip}" if @remote_ip
    end

    def windows_command(path)
      cmd = "rlpr -P #{@printer_name} -o raw #{path} 2>&1"
      cmd + " -H #{@remote_ip}" if @remote_ip
    end
  end
end
