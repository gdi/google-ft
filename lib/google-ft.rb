require 'json'
require 'curb-fu'
require 'google-sa-auth'
require 'google-ft/table'
require 'google-ft/table/column'

class GoogleFT
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

  def create_table(args)
    # Make sure we have an authentication token.
    raise RuntimeError 'Must authenticate!' unless has_auth?

    # Create the table and save it.
    table = GoogleFT::Table.new(args)
    table.save(@authorization.token_string)
    table
  end

  def get_table(table_id)
    # Make sure we have an authentication token.
    raise RuntimeError 'Must authenticate!' unless has_auth?

    # Load the table.
    GoogleFT::Table.get_table_by_id(table_id, @authorization.token_string)
  end

private
  def has_auth?
    return false unless @token
    @token.expired? ? false : true
  end
end
