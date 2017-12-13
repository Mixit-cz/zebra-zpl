module Zebra
  class PrintJob

    attr_reader :printer

    def initialize(printer, cups_ip = nil)
      @printer_name = printer
      @remote_ip = cups_ip
    end

    def print(label)
      #check_existent_printers @printer_name
      tempfile = label.persist
      send_to_printer tempfile.path
    end

    # Shows existing CUPS printers.
    def cups_printers
      Cups.show_destinations
    end

    private

    def check_existent_printers(printer)
      existent_printers = Cups.show_destinations
      raise Exceptions::UnknownPrinter.new(printer) unless existent_printers.include?(printer)
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
