# Start and set score limit
puts "Hey there, let's play spades!\nWhat's your name?"
name = gets.strip
puts "Brilliant, and what shall we play to?"
score_limit = gets.strip.to_i
puts "Jolly good. Let\'s begin."

# Define the deck
suits = ['H','D','C','S']
numbers = ['2','3','4','5','6','7','8','9','10','J','Q','K','A']
deck = []
suits.each do |suit|
  numbers.each do |number|
    deck.push(:face => (number + suit), :value => numbers.index(number)+1, :suit => suit)
  end
end

# Define players
player1 = {:position => 1, :cards => [], :wager => 0,:round_card => [],:tricks => []}
player2 = {:position => 2, :cards => [], :wager => 0,:round_card => [],:tricks => []}
player3 = {:position => 3, :cards => [], :wager => 0,:round_card => [],:tricks => []}
player4 = {:position => 4, :cards => [], :wager => 0,:round_card => [],:tricks => []}
players = [player1,player2,player3,player4]

# Define teams
team1 = {:bags => 0, :score => 0}
team2 = {:bags => 0, :score => 0}

# Define the players and play order
puts "Ok #{name}, you are Player 1. Your partner is Player 3."
start_player = players.sample
until players[0] == start_player
  players.rotate!
end
puts "Player #{players[0][:position]} will start the game."

# Build the game in a while loop
round_count = 0
while score_limit > team1[:score] && score_limit > team2[:score]
  round_count += 1
  if round_count > 1
      players.rotate!
      puts "Player #{players[0][:position]} will start this round."
  end

  # Shuffle and deal cards to players
  shuffled = deck.shuffle
  until shuffled.empty?
    players[0][:cards] << shuffled.pop
    players[1][:cards] << shuffled.pop
    players[2][:cards] << shuffled.pop
    players[3][:cards] << shuffled.pop
  end

  # Players check cards and place wagers
  players.each do |player|
    if player[:position] == 1
      puts "Your cards:"
      player[:cards].each do |card|
        puts card[:face]
      end
      puts "How many tricks will you wager?"
      wagered_tricks = gets.strip.to_i
      player[:wager] = wagered_tricks
    else
      wagered_tricks = 0
      player[:cards].each do |card|
        if card[:suit] != 'S' and card[:value] >= 12
          wagered_tricks += 1
        end
        if card[:suit] == 'S' and card[:value] >= 10
          wagered_tricks += 1
        end
      end
      player[:wager] = wagered_tricks
    end
    puts "Player #{player[:position]} wagers #{player[:wager]} tricks."
  end
  puts "Ok. That\'s #{player1[:wager] + player3[:wager]} for your team, and #{player2[:wager] + player4[:wager]} for the other. Let\'s begin!"
  puts "Press Enter to continue..."
  continue = gets.strip

  # Play hands
  13.times do |round|
    suit_lock = "B"
    players.each { |player| player[:round_card] = {:face => "", :value => 0, :suit => ""} }
    players.each do |player|
      high_card_player = players.max { |a, b| a[:round_card][:value] <=> b[:round_card][:value] }
      high_card = high_card_player[:round_card]
      if player[:position] == 1
        valid = false
        card_inventory = []
        player[:cards].each do |card|
          card_inventory << card[:face]
        end
        puts "Your cards: #{card_inventory} Your tricks: #{player[:tricks]}"
        puts "Which card will you play?"
        card_choice = gets.strip
        if card_inventory.include? card_choice
          if card_inventory.include? suit_lock
            valid = true
          end
          if !card_inventory.include? suit_lock
            valid = true
          end
        end
        while !valid
          puts "Please select a valid card"
          card_choice = gets.strip
          if card_inventory.include? card_choice
            if card_inventory.to_s.include? suit_lock
              valid = true
              break
            end
            if !card_inventory.to_s.include? suit_lock
              valid = true
              break
            end
          end
        end
        player[:cards].each do |card|
          if card[:face] == card_choice
            player[:round_card] = card
          end
        end
        player[:cards].delete_at(player[:cards].index(player[:round_card]))
        puts "You #{player[:round_card][:face]}"
        if suit_lock == 'B'
          suit_lock = player[:round_card][:suit]
        end
      else
        card_inventory = []
        player[:cards].each do |card|
          if suit_lock != "B" && card[:suit] == suit_lock
            card_inventory << card
          end
          if suit_lock == "B"
            card_inventory << card
          end
        end
        if card_inventory.empty?
          player[:cards].each { |card| card_inventory << card }
        end
        player_max_card = card_inventory.max { |a, b| a[:value] <=> b[:value] }
        player_min_card = card_inventory.min { |a, b| a[:value] <=> b[:value] }
        if player[:position] == 2 || player[:position] == 4
          if player2[:tricks].length + player4[:tricks].length < player2[:wager] + player4[:wager]
            puts "win it!"
            player[:round_card] = player_max_card
            player[:cards].delete_at(player[:cards].index(player[:round_card]))
            puts "Player #{player[:position]}: #{player[:round_card][:face]}"
          end
          if player2[:tricks].length + player4[:tricks].length >= player2[:wager] + player4[:wager]
            puts "lose it!"
            plyer[:round_card] = player_min_card
            player[:cards].delete_at(player[:cards].index(player[:round_card]))
            puts "Player #{player[:position]}: #{player[:round_card][:face]}"
          end
        end
        if player[:position] == 3
          if player1[:tricks].length + player3[:tricks].length < player1[:wager] + player3[:wager]
            puts "win it!"
            player[:round_card] = player_max_card
            player[:cards].delete_at(player[:cards].index(player[:round_card]))
            puts "Player #{player[:position]}: #{player[:round_card][:face]}"
          end
          if player1[:tricks].length + player3[:tricks].length >= player1[:wager] + player3[:wager]
            puts "lose it!"
            player[:round_card] = player_min_card
            player[:cards].delete_at(player[:cards].index(player[:round_card]))
            puts "Player #{player[:position]}: #{player[:round_card][:face]}"
          end
        end
        if suit_lock == "B"
          suit_lock = player[:round_card][:suit]
        end
        puts card_inventory
      end
    end
  end
end
