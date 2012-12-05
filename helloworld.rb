require 'sinatra'   # required for sinatra classic detection in cloud foundry...
require 'rubygems'
require 'bundler'
Bundler.require


# Configure Mongoid
Mongoid.configure do |config|
  name = "testdb"
  host = "localhost"
  config.master = Mongo::Connection.new.db(name)
end

# Model:  Visit contains 1 or many Iprec
class Visit
 include Mongoid::Document
 field :date, :type => String
 field :count, :type => Integer
 embeds_many :iprecs
end

#Model:  Iprec  embeded in Visit
class Iprec
 include Mongoid::Document
 field :ip, :type => String
 field :count, :type => Integer
 embedded_in :visit
end

#Read (GET)
 get '/' do
    puts "page hit!"
    
    @visits= Visit.where(:date => Time.new.strftime("%m-%d-%Y")) 
    
    if (@visits.empty?)
      puts 'add new record'
      rec = Visit.new
      rec.date = Time.new.strftime("%m-%d-%Y")
      rec.count = 1
      rec.save
      rec.iprecs.create(ip: "#{request.ip}")
    else
    #if Visit.where(:date => Time.new.strftime("%m-%d-%Y")).exists?  
      puts 'find existing record'
      @visits[0].iprecs.create(ip: "#{request.ip}")
      puts @visits[0].iprecs.count
    end
    
    erb :index
    
=begin  :  debug showing records in Mongo db
    puts "getting all days"
    puts Visit.count
    Visit.all.each do |member|
      puts "#{member.date}" + "  " + "#{member.iprecs.count}" 
    end 
=end    
    
    
 end



