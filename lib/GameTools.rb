require 'JSON'

module GameTools

	def clean_filename(filename)
		#remove special characters
		filename.gsub!(/[^0-9A-Za-z]/, '')
		puts "Game save file: #{filename}\n"
		return filename
	end

	def reconstruct(data)
		#places data segments back into original data structures where necessary
		data[1] = (JSON.parse data[1])
		data[2] = (JSON.parse data[2]).to_h
		if data[3] == nil #if the user saved without guessing, create a placeholder
			data << []
		end
		return data
	end

	def parse_data(data)
		#datastream is split into 4 original parts, separated by semicolon
		contents = data.split('')
		parsed_data = []
		place_holder = 0
		contents.each_with_index{|element,index|
			if element != ";"
				next
			else
				parsed_data << (contents[place_holder..(index - 1)].join(''))
				place_holder = index + 1
			end
		}
		return reconstruct(parsed_data)
	end

	def save_game(game, game_name)
		filename = clean_filename(game_name)
		Dir.mkdir("../saved_games") unless Dir.exists? "../saved_games"
		if FileTest.file?("../saved_games/#{filename}.csv")
			puts $rewrite_save_prompt
			response = gets.chomp
			while !valid_option(response)
				puts $invalid_input
				response = gets.chomp
			end
			case response
			when '1'
				data = game.save_data()
				File.open("../saved_games/#{filename}.csv", 'w') {|file| file.write(data)}
			when '2'
				puts "Enter a new filename:\n"
				new_name = gets.chomp
				save_game(game, new_name)
			end
		else
			data = game.save_data()
			File.open("../saved_games/#{filename}.csv", 'w') {|file| file.write(data)}
		end
	end

	def load_game
		#should return params for GameBoard object if file exists
		puts $load_prompt
		filename = gets.chomp.gsub(/[^0-9A-Za-z]/, '')
		unless !FileTest.file?("../saved_games/#{filename}.csv")
			save_data = parse_data(File.read("../saved_games/#{filename}.csv"))
			return save_data
		else
			return false
		end
	end
end
