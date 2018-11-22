require 'exceptions/uknown_printer'

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

    private

    def check_existent_printers(printer)
      existent_printers = Cups.show_destinations
      raise UnknownPrinter.new(printer) unless existent_printers.include?(printer)
    end

    def send_to_printer(path)
      puts "* * * * * * * * * * * * Sending file to printer #{@printer} at #{@remote_ip} * * * * * * * * * * "
      result = system("rlpr -H #{@remote_ip} -P #{@printer} -o #{path} 2>&1") # try printing to LPD on windows machine first
      system("lp -h #{@remote_ip} -d #{@printer} -o raw #{path}") if !result # print to unix (CUPS) if rlpr failed
    end
  end
end
