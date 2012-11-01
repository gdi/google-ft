class GoogleFT
  class Table
    class Column
      attr_accessor :name, :type

      def initialize(name, type = 'string')
        # Cleanup the column name.
        self.name = name.gsub(/[^a-zA-Z0-9_\-]/, '_')

        # Store type and make sure it's valid.
        self.type = type.upcase
        raise ArgumentError unless ['STRING','NUMBER','DATETIME','LOCATION'].include?(self.type)
      end
    end
  end
end
