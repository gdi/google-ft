class GoogleFT
  class Table
    class Permission
      attr_accessor :role, :type, :value, :require_link
      def initialize(args)
        # Clean up args and make sure we were at least supplied the required ones.
        args = args.symbolize.delete_if {|k,v| ![:role, :type, :value, :require_link].include?(k)}
        raise ArgumentError unless args[:role] && args[:type] 

        # Set defaults.
        args[:value] ||= 'me'
        args[:require_link] ||= false

        # Set the attributes.
        self.role = args[:role]
        self.type = args[:type]
        self.value = args[:value]
        self.require_link = args[:require_link]
      end

      def post_args
        # JSON formatted string for this permission.
        {
          :role => self.role,
          :type => self.type,
          :value => self.value,
          :withLink => self.require_link
        }.to_json
      end
    end
  end
end
