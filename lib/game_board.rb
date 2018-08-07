require "csv"
class GameBoard
	@@save_column_headers = ["secret_word", "guesses_left", "guess_slots", "guessed_letters"]
	attr_accessor :guessed_letters
	attr_reader :game_over
	attr_reader :guesses_left
	attr_reader :secret_word
	attr_reader :guess_slots
	def initialize(secret_word, guesses_left = 6, guess_slots = {}, 
				   guessed_letters = [])
		@secret_word = secret_word.split('')
		@guesses_left = guesses_left
		@guess_slots = guess_slots
		@guessed_letters = guessed_letters
		@game_over = false
		if @guess_slots.length == 0
			@secret_word.each do |letter|
				@guess_slots[letter] = false
			end
		end
	end

	def save_data
		#add encryption later for secret word?
		data = @secret_word.join('') + ";" +
			   @guesses_left.to_s + ";" +
			   @guess_slots.to_a.to_s + ";" +
			   guessed_letters.join
		return data
	end

	def already_used(letter)
		return @guessed_letters.include? letter
	end

	def update_slots(letter)
		@guess_slots[letter] = true
	end

	def add_guess(letter)
		@guessed_letters.push(letter)
		if @secret_word.include? letter
			puts "Good guess!"
			update_slots(letter)
		else
			@guesses_left -= 1
			unless @guesses_left == 0
				puts "Nope, try again."
			else
				puts "Hanged man! Too bad, the secret word was: #{secret_word.join('')}"
			end
		end
	end

	def display_slots
		current_display = ''
		@secret_word.each do |letter|
			if @guess_slots[letter]
				current_display += letter + ' '
			else
				current_display += '_ '
			end
		end
		return current_display
	end

	def word_complete
		#if any letter is paired with 'false', return 'false',
		#otherwise, the word is guessed completely, return 'true'
		@guess_slots.values.each do |value|
			if !value
				return false
			end
		end
		return true
	end
end