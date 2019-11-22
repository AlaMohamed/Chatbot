require 'sinatra' # Import af libraries 
require 'json' 
require 'sqlite3'
 
set :port, 5000 # Lytter til porten
 
match = false;

before do 
  @params = JSON.parse(request.body.read) 
end 
 

post '/' do 
  content_type :json 
  puts @params
  if @params['action']['slug'] == 'bookingroom' # kig på cancel room --> altså else-if
    # Forbindelse til DB her for at spørge DB om 
    roombooking = "The room " + @params['roomnumber']['raw'] + " has been booked"

 #nyt
    / else  match 
    roombooking = "The room" + @params ['cancel'] ['raw'] +  " has been cancelled"
 /
  end 
  { 
    replies: [{ type: 'text', content: roombooking }], 
    conversation: { 
      memory: { 
        key: 'value' 
      }
    } 
  }.to_json 
end 

post '/bookingroom' do
  puts @params
    roomnumber = @params['roomnumber']['value']
    buildingnumber = roomnumber.split(".")
    buildingexist = true
    responsetext = ""

    # ALL THESE CHECKS ABOUT THE BUILDING THAT THE USER WILL BOOK 
    begin
      db = SQLite3::Database.open "Chatbot.db"
      stm = db.prepare "SELECT COUNT (building_id) FROM BUILDING WHERE building_number = " + buildingnumber[0]
      rs = stm.execute 
  
      buildingcount = rs.next

      if (buildingcount[0] == 0) then 
        puts "doesnt exist" 
        buildingexist = false
      end
  
    rescue SQLite3::Exception => e 
      puts "Exception occurred"
      puts e
    ensure
      stm.close if stm
      db.close if db
    end

    if (buildingexist) then 
      responsetext = "Room has been booked"
      # INSTEAD OF THIS. WE WILL INSERT THE USER BOOKING INTO OUR DATABASE WHEN THE USER WRITE. INSTEAD FOR JUST PRINT "THE ROOM HAS BEEN BOOKED"

    elsif 
      responsetext = "The building does not exist"
    end
    
    content_type :json 
    { 
      replies: [{ type: 'text', content: responsetext }], 
      conversation: { 
        memory: { 
          key: 'value' 
        } 
      } 
    }.to_json 
  end

post '/errors' do 
  puts @params 
 
  200 
end

post '/testdb' do
  begin
    db = SQLite3::Database.open "Chatbot.db"
    stm = db.prepare "SELECT * FROM BUILDING"
    rs = stm.execute 

    rs.each do |row|
      puts row.join "\s"
    end
  rescue SQLite3::Exception => e 
    puts "Exception occurred"
    puts e
  ensure
    stm.close if stm
    db.close if db
  end
  
  200
end