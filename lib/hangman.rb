require './game_board.rb'
require "./GameTools.rb"
require "JSON"

$dict = []
$letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
			'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
$options_prompt = %s{Choose one of the following:
(1): New Game
(2): Load Saved game
(3): Exit
Type the number of the option, then press 'Enter':
}
$turn_prompt = "Type the letter you want to guess and then press 'Enter'.
\nAlternatively, you can type 'save' or 'quit' and then press 'Enter' to perform those actions.\n"
$invalid_input = "Invalid input, please type an option listed above, then press 'Enter':\n"
$letter_used = "You've already guessed that letter. Please try another:\n"
$load_prompt = "Type the name of your save file (no extensions needed) then press 'Enter':\n"
$save_prompt = %s{Type a name for this game using characters and/or digits.
No special characters allowed:\n}
$file_load_error = "\n----No such file found - try another name. Note: File names are case-sensitive.----\n\n"
$rewrite_save_prompt = %s{There already exists a file with that name.  Continuing will overwrite the old save data.
(1): Continue anyway and SAVE
(2): Enter a different filename
(3): Cancel
Type the number of the option, then press 'Enter':}
$win_msg  = "Congratulations, you've guessed the word!"

def load_dict
	#picks words between 5 and 12 chars in length
	File.foreach('../dict.txt') do |line|
		if line.length >= 7 && line.length <= 14
			$dict.push(line.gsub(/\n\r/, ' ').strip.downcase)
		end
	end
end

def select_word
	#randomly select a word
	return $dict[rand($dict.length - 1)]
end

def valid_option(option)
	case option
	when '1', '2', '3'
		return true
	else
		return false
	end
end

def verify_guess(guess, game)
	loop do
		case
		when guess == 'save', guess == 'quit'
			break
		when (!$letters.include? guess)
			puts $invalid_input
			guess = gets.chomp.downcase
		when (($letters.include? guess) && (game.already_used(guess)))
			puts $letter_used
			guess = gets.chomp.downcase
		else
			break
		end
	end
	return guess
end

def turn(game)
	puts $turn_prompt + "Letters already used: " + game.guessed_letters.join(' ') + "\n\n" +
					"Current Word: #{game.display_slots}  ||  Guesses Left: #{(game.guesses_left)}\n"
	guess = gets.chomp.downcase
	guess = verify_guess(guess, game)
	case
	when guess != 'save' && guess != 'quit'
		game.add_guess(guess)
		return true
	when guess == 'save'
		puts $save_prompt
		game_name = gets.chomp
		save_game(game, game_name)
		return true
	when guess == 'quit'
		return false
	end
end

def play(game)
	keep_playing = true
	while game.guesses_left > 0 && keep_playing
		keep_playing = turn(game)
		if game.word_complete 
			puts game.display_slots
			puts $win_msg
			break 
		end
	end
end

def menu
	include GameTools
	loop do
		puts $options_prompt
		response = gets.chomp.downcase
		while !valid_option(response)
			puts $invalid_input
			response = gets.chomp
		end
		case response
		when '1'
			load_dict()
			game = GameBoard.new(select_word())
			play(game)
		when '2'
			load_data = load_game()
			if load_data
				game = GameBoard.new(load_data[0], load_data[1],
									 load_data[2], load_data[3])
				play(game)
			else
				puts $file_load_error
			end
		when '3'
			puts "Goodbye!"
			break
		end
	end
end

menu()