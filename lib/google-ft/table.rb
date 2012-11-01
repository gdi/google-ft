class GoogleFT
  class Table
    attr_accessor :columns, :id, :name, :description, :exportable, :token

    class << self
      def get_table_by_id(table_id, token = nil)
        args = {
          :uri => "https://www.googleapis.com/fusiontables/v1/tables/#{table_id}",
          :method => 'get'
        }
        args[:headers] = {'Authorization' => "Bearer #{token}"} if token
        response = GoogleSAAuth::Client.run(args)

        # Make sure we get a 200 response.
        raise RuntimeError unless response.status == 200

        # Parse response.
        result = JSON.parse(response.body)
        GoogleFT::Table.new(
          :token => token,
          :id => result['tableId'],
          :name => result['name'],
          :columns => result['columns'],
          :description => result['description'],
          :exportable => result['isExportable']
        )
      end
    end

    def initialize(args = {})
      # Clean-up args.
      args = args.inject({}){|item,(k,v)| item[k.to_sym] = v; item}
      args = args.delete_if {|k,v| ![:id, :name, :columns, :description, :exportable, :token].include?(k)}

      # Create nicely formated columns.
      self.columns = args[:columns].nil? ? [] : args[:columns].each.collect do |col|
        name = col[:name] || col['name']
        type = col[:type] || col['type']
        GoogleFT::Table::Column.new(name, type)
      end

      # Set other attributes.
      self.token = args[:token]
      self.id = args[:id]
      self.name = args[:name].gsub(/[^a-zA-Z0-9_\-]/, '_')
      self.description = args[:description] || ''
      self.exportable = args[:exportable].nil? ? false : args[:exportable]
    end

    def save
      # Attempt to save this table to google via curb-fu post.
      method = self.id.nil? ? 'post' : 'put'
      uri = 'https://www.googleapis.com/fusiontables/v1/tables'
      uri += "/#{self.id}" unless self.id.nil?
      args = {
        :uri => uri,
        :headers => {
          'Content-Type' => 'application/json',
        },
        :data => post_args,
        :method => method
      }
      args[:headers]['Authorization'] = "Bearer #{self.token}" unless self.token.nil?
      response = GoogleSAAuth::Client.run(args)

      # Make sure we got a 200 response.
      raise RuntimeError unless response.status == 200

      # Parse the results.
      result = JSON.parse(response.body).inject({}){|item,(k,v)| item[k.to_sym] = v; item}
      self.id = result[:tableId]
      result
    end

  private
    def post_args
      # Return the JSON string of our table arguments.
      args = {
        :name => self.name,
        :columns => self.columns.each.collect {|col| {:name => col.name, :type => col.type}},
        :isExportable => self.exportable,
        :description => self.description
      }
      args.to_json
    end
  end
end
