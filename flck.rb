#!/usr/bin/ruby
## ----------------------------------------------------------------------
## ----------------------------------------------------------------------
##
## File:      flck.rb
## Author:    mgrosso 
## Created:   Sun Nov  7 01:52:40 PDT 2010 on caliban
## Copyright:   
## Project:   
## Purpose:   
## 
## $Id$
## ----------------------------------------------------------------------
## ----------------------------------------------------------------------

require 'flickraw'
require 'yaml'
CFG_FILE = "~/.flck.yml"
@cfg_data = {:img_dir => "~/img/camera/2009/100canon/",
            :browser => "/usr/bin/firefox",
            :format => "img_%04d.jpg",
            :logyml => "~/.flck-log.yml" }
@logfile = nil
def output( s )
    [ $stdout, @logfile ].each do |f| 
        f.puts s
        f.flush
    end
    true
end
def doinit
    @cfg_data.merge!(YAML::load_file(File.expand_path(CFG_FILE)))
    #FIXME: :key fails, but "key" works.
    @logfile = File.open(File.expand_path(@cfg_data[:logyml]), "a" )
    FlickRaw.api_key = @cfg_data["key"]
    FlickRaw.shared_secret = @cfg_data["secret"]
    flickr.access_token = @cfg_data["oauth_token"]
    flickr.access_secret = @cfg_data["oauth_token_secret"]

    #@access_token = flickr.get_access_token( @cfg_data['oauth_token'], @cfg_data['oauth_token_secret'], verify)
    #output "access_token: #{@access_token}"
    @login = flickr.test.login
    output "login: #{@login}"

    #######################################################################
    #######################################################################
    #the following long commented out section is needed the first time around with a new key
    #but breaks if included when you have one.
    #
    #TODO: fix this mess.  who knows, maybe write a test case or two...
    #######################################################################
    #######################################################################

    #if @cfg_data.include?(:token)
    #    begin
    #        @auth = flickr.auth.checkToken :auth_token => @cfg_data[:token]
    #        return
    #    rescue
    #        p "oops, need new key, hit return to continue"
    #        STDIN.gets 
    #    end
    #end
    #request_token = flickr.get_request_token
    #

    #auth_url = flickr.get_authorize_url(request_token['oauth_token'], :perms => 'delete')
    #ignore=%x[#{@cfg_data[:browser]} \"#{auth_url}\"]
    #output "# launched #{@cfg_data[:browser]} to view \"#{auth_url} for #{request_token}\""
    #output "# input the 9 digit code with dashes and hit return after you have logged into the url and approved the app"
    #@verify = STDIN.gets.strip
    #begin
    #    login = flickr.test.login
    #    p ["login",login].inspect
    #rescue
    #    p "test login failed"
    #end
    #begin
    #    @access_token = flickr.get_access_token(request_token['oauth_token'], request_token['oauth_token_secret'], @verify)
    #    @cfg_data.merge! @access_token
    #    File.open(File.expand_path(CFG_FILE), 'w') { |f| YAML.dump(@cfg_data, f) }
    #rescue
    #    p "get access token failed"
    #end
    #@auth = flickr.auth.getToken :frob => frob
end
def find_file(n,format_keys)
    format_keys.each do |fmtkey|
        f=sprintf @cfg_data[fmtkey], n
        photo_path=File.expand_path(@cfg_data[:img_dir] + f )
        if ( File.exists?( photo_path ) )
            return [f,photo_path]
        end
    end
    [nil, nil]
end
def upl( n )
    start=Time.now
    f, photo_path = find_file(n,[:format,:alt_format])
    if(f.nil?)
        output "#skipping #{f} which does not exist." 
        return nil
    end
    id=flickr.upload_photo photo_path, :title => f, :hidden => 1, :is_public => 0, :is_family => 0, :is_friend => 0
    output "#{f}: { id: #{id}, elapsed: \"#{Time.now-start}\", size: #{File.size(photo_path)}}"
end

if( ARGV.length != 2 )
    puts "usage: $0 <start number> <stop number>"
    exit!( 1 )
end

doinit
puts "---"
$stdout.flush
( ARGV[0] .. ARGV[1] ).each{ |n| upl n }





