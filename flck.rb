#!/usr/bin/ruby
## ----------------------------------------------------------------------
## ----------------------------------------------------------------------
##
## File:      flck.rb
## Author:    mgrosso 
## Created:   Sun Nov  7 01:52:40 PDT 2010 on caliban
## Copyright:   Copyright  
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
    if @cfg_data.include?(:token)
        @auth = flickr.auth.checkToken :auth_token => @cfg_data[:token]
    else
        frob = flickr.auth.getFrob
        auth_url = FlickRaw.auth_url :frob => frob, :perms => 'write'
        ignore=%x[#{@cfg_data[:browser]} \"#{auth_url}\"]
        output "# launched #{@cfg_data[:browser]} to view \"#{auth_url}\""
        output "# hit return after you have logged into the url and approved the app"
        STDIN.getc
        @auth = flickr.auth.getToken :frob => frob
        @cfg_data[:token] = @auth.token
        File.open(File.expand_path(CFG_FILE), 'w') { |f| YAML.dump(@cfg_data, f) }
    end
end
def upl( n )
    start=Time.now
    f=sprintf @cfg_data[:format], n
    photo_path=File.expand_path(@cfg_data[:img_dir] + f )
    if ( ! File.exists?( photo_path ) )
        return output "#skipping #{f} which does not exist." 
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





