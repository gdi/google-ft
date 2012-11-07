require 'json'
require 'curb-fu'
require 'google-sa-auth'
require 'google-ft/table'
require 'google-ft/table/column'
require 'google-ft/table/permission'

# Quick and dirty method to symbolize keys of a hash.
class Hash
  def symbolize
    self.inject({}){|item,(k,v)| item[k.to_sym] = v; item}
  end
end

class GoogleFT
  class << self
    # Method to convert values into google-compatible format.
    def to_google_ft_format(value)
      if value.class == String
        bytes = value.bytes.each.collect {|l| l.chr.gsub(/\\|'/) { |c| "\\#{c}" }.gsub('&', '%26').gsub("\b", '\\b').gsub("\f", '\\f').gsub("\n", '\\n').gsub("\r", '\\r').gsub("\t",'\\t')}
        "'#{bytes.join}'"
      elsif value.class == Array
        "'#{value.first} #{value.last}'"
      else
        value.to_json
      end
    end

    # Quick wrapper method for utilizing curb-fu.
    def get_and_parse_response(args)        
      response = GoogleSAAuth::Client.run(args)

      # Make sure we get a 20* status.
      unless response.status.to_s =~ /^20/
        puts response.body.to_s
        raise RuntimeError
      end

      # Return the symbolized hash of the response body.
      begin
        JSON.parse(response.body).symbolize
      rescue
        response.body
      end
    end
  end

  attr_accessor :authorization, :token

  def get_auth_token(args)
    # Make sure the token wasn't already set and hasn't yet expired.
    @authorization = nil unless has_auth?

    # (Re)create the authorization.
    @authorization ||= GoogleSAAuth.new(args)

    # Save the token.
    @token = @authorization.token
    @authorization
  end

  def show_tables
    require_auth
    GoogleFT::Table.show_tables(@authorization.token_string)
  end

  def create_table(args)
    require_auth

    # Create the table and save it.
    args[:token] = @authorization.token_string
    table = GoogleFT::Table.new(args)
    table.save
    table
  end

  def delete_table(table_id)
    require_auth
    GoogleFT::Table.get_table_by_id(table_id, @authorization.token_string).delete
  end

  def get_table(table_id)
    require_auth
    GoogleFT::Table.get_table_by_id(table_id, @authorization.token_string)
  end

private
  def has_auth?
    return false unless @token
    @token.expired? ? false : true
  end

  def require_auth
    raise RuntimeError unless has_auth?
  end
end
