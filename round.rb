class Round

  def initialize(user, interface)
    @user = user
    @interface = interface
    @dealer = Dealer.new
    @deck_for_game = Deсk.new
    @bank = Bank.new
  end

  def run
    @user.reset_points
    @user.hand.cards.clear
    @deck_for_game.create_deck
    @deck_for_game.cards.shuffle!
    cards_for_players
    @bank.take_bet(@dealer)
    @bank.take_bet(@user)
    cards
    dealing
  end

  private

  def cards
    user_cards
    @interface.unknown_dealer_cards
  end

  def dealing
    if full_hands?
      open_cards
    else
      @interface.user_chioce
      @choice = @interface.choice
      case @choice.to_i
      when 1
        dealer_turn
      when 2
        @user.take_card(@deck_for_game)
        raise 'You can add only one card' if @user.hand.cards.count > 3
        dealer_turn
      when 3
        open_cards
      else
        @interface.wrong_try_again
        exit
      end
    end
  end

  def full_hands?
    @dealer.hand.cards.count == 3 && @user.hand.cards.count == 3
  end

  def dealer_turn
    @dealer.take_card(@deck_for_game) if can_add_card?
    dealing
  end

  def can_add_card?
    @dealer.hand.sum < 17 && @dealer.hand.cards.count != 3
  end

  def user_cards
    @interface.user_cards_message(@user)
    @user.hand.points
    @interface.user_points_message(@user)
  end

  def dealer_cards
    @interface.dealer_cards_message(@dealer)
    @dealer.hand.points
    @interface.dealer_points_message(@dealer)
  end

  def cards_for_players
    2.times do
      @user.take_card(@deck_for_game)
      @dealer.take_card(@deck_for_game)
    end
  end

  def open_cards
    user_cards
    dealer_cards
    verify
  end

  def verify
    if @user.hand.sum > 21 || @user.hand.sum < @dealer.hand.sum && @dealer.hand.sum <= 21
      lose
    elsif @user.hand.sum > @dealer.hand.sum || @dealer.hand.sum > 21
      win
    else
      draw
    end
  end

  def lose
    @interface.defeat_report
    @bank.get_money(@dealer)
  end

  def win
    @interface.victory_report
    @bank.get_money(@user)
  end

  def draw
    @interface.draw_report
    @bank.split_money(@user, @dealer)
  end

end
