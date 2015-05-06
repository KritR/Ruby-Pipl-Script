#!/usr/bin/env ruby
require 'csv'
require 'net/http'
@pipl_key = "API_KEY_HERE" #Replace this placeholder API Key with your real one
@pipl_uri = URI('http://api.pipl.com/search/v4/')
csvfile = if ARGV.length > 0
            ARGV[0].to_s
          else
            "input.csv" #Replace this with the desired default input filename + .csv 
          end
@country = "US" #This is the default country, you can replace it with whatever again. Just make sure the country you're referring to has the town specified. 
$outputFilename = if ARGV.length > 1
                    ARGV[1].to_s
                  else
                    "output.json" #Replace this with the desired default input filename/path + .json or .txt ( if you want )
                  end
$outputData = ""

#The following functions prompts user for new filename or to add to existing file                 
def overwritePrompt
  puts "File already exists: type a (new filename) to write to a new file | or | (Y / Enter ) to continue with the operation and add the data to the existing file : " + $outputFilename
  usrInput = $stdin.gets.to_s
  if usrInput.length > 0 and usrInput != "Y"
    $outputFilename = usrInput
    outputFile()
  else
    writeToFile()
  end
end

#The following function writes the output to the desired file
def writeToFile
  File.open($outputFilename.to_s, 'a') {|f| f.write($outputData) }
  puts "Successfully saved File to : " + $outputFilename
end

#The following function sends the output command and is a security check to make sure files aren't overwriting
def outputFile()
  if File.exists?($outputFilename)
    overwritePrompt()
  else
    writeToFile()
  end
end

#The following function sends the data to pipl and then performs desired actions with it.
def get_pipl (line)
  firstName = line[0].to_s
  lastName = line[1].to_s
  city = line[2].to_s
  state = line[3].to_s
  res = Net::HTTP.post_form(@pipl_uri, 'first_name' => firstName, 'last_name' => lastName, 'city' => city, 'state' => state, 'key' => @pipl_key)

  puts res.body #Just add a hashtag at the beginning of this line to not "Print to Terminal"
  $outputData += res.body.to_s
  
end

#The following function scans through the CSV file and makes sure it exists, if there is an error it will output a friendly message and let you call the function again.
begin
  CSV.foreach(csvfile) do |row|
    get_pipl (row)
  end

rescue Errno::ENOENT
   if csvfile == "input.csv"
     puts "There is no file called input.csv (default), please specify the correct filename next time using ./finder.rb (file path here)."
   else
     puts "There is no such file under: " + csvfile + ", please specify the proper file path next time using ./finder.rb (file path here)."
   end 
     # Change "finder.rb" to whatever this ruby file is called 
end

outputFile()    #Just add a hashtag at the beginning of this line to turn off "Saving to File" 
