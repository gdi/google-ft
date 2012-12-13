google_ft
===============

Google Fusion Tables API for ruby.

```ruby
require 'google-ft'

# Create a new GoogleFT instance.
fusion_tables = GoogleFT.new

# Get the authorization token (must be service account)
puts "Getting authorization token."
token = fusion_tables.get_auth_token(
  :email_address => 'youraddress@developer.gserviceaccount.com',
  :scope => ['fusiontables','drive'],
  :key => File.read('/path/to/yourprivatekeyfromgoogle.p12'),
  :password => 'notasecret'
).token_string
puts "Token: #{token}"

# Create a table.
puts "Creating a table."
table = fusion_tables.create_table(
  :name => 'NewMap1',
  :columns => [
    {
      :name => 'TestColumn1',
      :type => 'string'
    },
    {
      :name => 'TestColumn2',
      :type => 'number'
    },
    {
      :name => 'IPLocation',
      :type => 'location'
    }
  ],
  :description => 'This is a test.',
  :exportable => true
)
puts "Table ID: #{table.id}"

# Get a table by ID.
puts "Getting table by ID."
table = fusion_tables.get_table(table.id)
puts "Table: #{table.post_args}"

# Create a new permission for the table.
puts "Creating permissions for table."
permissions = GoogleFT::Table::Permission.new(
  :role => 'reader',
  :type => 'anyone',
  :value => 'me',
  :require_link => true
)
table.set_permissions(permissions)

# Insert some rows into the table.
puts "Inserting rows."
begin
puts table.insert([
  {'TestColumn1' => 'This is row 1 column 1', 'TestColumn2' => 10, 'IPLocation' => [0.00, 0.00]},
  {'TestColumn1' => "Testing a row with tricky characters: ; ? \\ & ' \\' \n", 'TestColumn2' => 20, 'IPLocation' => [-4.034,4.035]},
  {'TestColumn1' => 'Bar', 'TestColumn2' => 30, 'IPLocation' => [10.0, -10.0]}
])
rescue => e
puts "Error: #{e}"
end

# Show all tables.
puts "All tables"
tables = fusion_tables.show_tables

# Delete this table.
#puts "Deleting table: #{table.delete}"
```
