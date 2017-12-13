module Zebra
  module Exceptions

    class UnknownPrinter < StandardError
      def initialize(printer)
        super("Could not find a printer named #{printer}")
      end
    end

  end
end