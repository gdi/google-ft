class GoogleFT
  class Table
    # Base URI for the fusion tables API.
    $FT_BASE_URI = 'https://www.googleapis.com/fusiontables/v1/tables'

    class << self
      # Show a list of tables, requires the authentication token.
      def show_tables(token)
        args = {
          :uri => "#{$FT_BASE_URI}",
          :method => 'get',
          :headers => {
            'Authorization' => "Bearer #{token}"
          }
        }
        result = GoogleFT.get_and_parse_response(args)
        return [] if result[:items].nil?
        result[:items].each.collect do |table|
          table = table.symbolize
          GoogleFT::Table.new(
            :token => token,
            :id => table[:tableId],
            :name => table[:name],
            :columns => table[:columns],
            :description => table[:description],
            :exportable => table[:isExportable]
          )
        end
      end

      # Get a table by it's ID and return a table object.
      def get_table_by_id(table_id, token = nil)
        args = {
          :uri => "#{$FT_BASE_URI}/#{table_id}",
          :method => 'get'
        }

        # Add the auth token if it was provided.
        args[:headers] = {'Authorization' => "Bearer #{token}"} unless token.nil?

        # Get and parse results.
        result = GoogleFT.get_and_parse_response(args)
        GoogleFT::Table.new(
          :token => token,
          :id => result[:tableId],
          :name => result[:name],
          :columns => result[:columns],
          :description => result[:description],
          :exportable => result[:isExportable]
        )
      end
    end


    # Accessors.
    attr_accessor :columns, :id, :name, :description, :exportable, :token
    attr_accessor :permissions

    # Create a new table object.
    def initialize(args = {})
      # Clean-up args.
      args = args.symbolize.delete_if {|k,v| ![:id, :name, :columns, :description, :exportable, :token].include?(k)}

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

    # Delete a table.
    def delete
      args = {
        :uri => "#{$FT_BASE_URI}/#{self.id}",
        :headers => {
          'Authorization' => "Bearer #{self.token}",
        },
        :data => '',
        :method => 'delete'
      }
      GoogleFT.get_and_parse_response(args)
      true
    end

    # Save this table to Google.
    #   Used for creating or updating tables.
    def save
      # If ID exists, we are updating a table,
      #  otherwise, we are creating it.
      method = self.id.nil? ? 'post' : 'put'
      uri = 'https://www.googleapis.com/fusiontables/v1/tables'
      uri += "/#{self.id}" unless self.id.nil?
      args = {
        :uri => uri,
        :headers => {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{self.token}"
        },
        :data => post_args,
        :method => method
      }
      result = GoogleFT.get_and_parse_response(args)
      self.id = result[:tableId]
      result
    end

    # Set permissions for a table.
    def set_permissions(permission)
      args = {
        :uri => "https://www.googleapis.com/drive/v2/files/#{self.id}/permissions",
        :headers => {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{self.token}"
        },
        :method => 'post',
        :data => permission.post_args
      }
      GoogleFT.get_and_parse_response(args)
    end

    # Return the JSON string of our table arguments.
    #   Used for creating and updating tables.
    def post_args
      {
        :name => self.name,
        :columns => self.columns.each.collect {|col| {:name => col.name, :type => col.type}},
        :isExportable => self.exportable,
        :description => self.description
      }.to_json
    end

    # Insert rows into a table.
    def insert(rows)
      # Get the SQL-ish statement from arg hash.
      inserts = []

      # Go through each row.
      rows.each do |row|

        # Get all of the column/value pairs.
        columns = []
        values = []
        row.each do |column,value|
          columns.push(column)
          values.push(value)
        end

        # Add this insert line.
        inserts.push("INSERT INTO #{self.id} (#{columns.join(',')}) VALUES (#{values.each.collect {|v| GoogleFT.to_google_ft_format(v)}.join(',')});")
      end

      # Post the insert's to Google.
      args = {
        :uri => 'https://www.googleapis.com/fusiontables/v1/query',
        :headers => {
          'Authorization' => "Bearer #{self.token}"
        },
        :method => 'post',
        :data => "sql=#{inserts.join("\n")}"
      }
      GoogleFT.get_and_parse_response(args)
    end
  end
end
