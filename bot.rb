require 'sinatra' # Import af libraries 
require 'json' 
require 'sqlite3'
 
set :port, 6000 # Lytter til porten

before do 
  @params = JSON.parse(request.body.read) 
end 
 

post '/' do 
  content_type :json 
  puts @params
  if @params['action']['slug'] == 'bookingroom' # kig på cancel room --> altså else-if
    # Forbindelse til DB her for at spørge DB om 
    roombooking = "The room " + @params['roomnumber']['raw'] + " has been booked"

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
    roomnumber = @params['conversation']['memory']['roomnumber']['value']
    buildingnumber = roomnumber.split(".") # Splitter det op i et array 
    buildingexist = true
    responsetext = ""

    # ALL THESE CHECKS IF THE BUILDING EXIST
    begin
      db = SQLite3::Database.open "ProjectDB.db"
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

    if (buildingexist == true) then 
      responsetext = "The room exist! \nWhen do you want to book the room? Please give me a specific date"
    
    elsif 
      responsetext == "The building does not exist. Try another building and room"
    end
    
    content_type :json 
    { 
      replies: [{ type: 'text', content: responsetext }], 
      conversation: { 
        memory: { 
          'roomnumber': roomnumber 
        } 
      } 
    }.to_json 
  end

  #TILFØJET
  post '/bookingagreement' do
    puts @params 
      bookingdate = @params['conversation']['memory']['date']['raw']
      #bookingdate = "13-12-2019"
      #userroomnumber = "27.1-001"
      userroomnumber = @params['conversation']['memory']['roomnumber']
      roomnumber = userroomnumber.split(".")
      #puts roomnumber[1]
      #puts bookingdate

    begin
       db = SQLite3::Database.open "ProjectDB.db"
       strSql = "INSERT INTO BOOKING (room_number, date) VALUES ('#{roomnumber[1]}', '#{bookingdate}')"
       # puts strSql 
       stm = db.prepare(strSql) 
       stm.execute
       puts "FULDFØRT"
       # konvetereter til en string den
    rescue SQLite3::Exception => e 
      puts "Exception occurred"
      puts e
    ensure
      stm.close if stm
      db.close if db
    end
    # if sætning ændre content til variable
      content_type :json 
      { 
        replies: [{ type: 'text', content: "I got your booking and your bookingId is ..." }], 
        conversation: { 
          memory: { 
            key: 'value'  # skift denne
          } 
        } 
      }.to_json 
    end
  
# SLUT

post '/cancel' do 
  puts @params 
  # USER: "I would like to cancel"
end

# Modify (changing the booking of the date or room)

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