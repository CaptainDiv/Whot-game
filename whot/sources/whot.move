/// Module: whot
module whot::whot;

const EAlreadyFull: u64 = 0;
const ENotEnoughPlayers: u64 = 1;
const EGameOver: u64 = 2;

/// A single game of Whot.
/// The game is played by at least 2 players, so we use the shared state.
public struct Whot has key {
    id: UID,
    deck: vector<Card>,
    players: vector<Player>,
    discard_pile: vector<Card>,
    current_turn: address,
    winner: option::Option<address>,
}

/// A player in the game.
public struct Player has drop, store {
    hand: vector<Card>,
    addr: address,
    score: u64,
}

/// A card in the game.
public enum Card has drop, store {
    Circle(u8),
    Triangle(u8),
    Cross(u8),
    Square(u8),
    Star(u8),
    Whot,
}

/// Create and share a new game.
public fun new_game(ctx: &mut TxContext) {
    transfer::share_object(Whot {
        id: object::new(ctx),
        deck: new_deck(),
    })
}

public fun join_game(game: &mut Whot, ctx: &mut TxContext) {
    assert!(game.players.length() < 4, EAlreadyFull);

    let player = Player {
        hand: 6u64.do!(|_| game.deck.pop_back()),
        addr: ctx.sender(),
        score: 0,
    };

    game.players.push_back(player);
}

fun new_deck(): vector<Card> {
    let mut deck = vector[];

    1u8.range_do!(15, |num| if (num != 9 && num != 6) {
        deck.push_back(Card::Circle(num))
    });

    1u8.range_do!(15, |num| if (num != 9 && num != 6) {
        deck.push_back(Card::Triangle(num))
    });

    1u8.range_do!(15, |num| if (num != 4 && num != 6 && num != 9 && num != 8 && num != 12) {
        deck.push_back(Card::Cross(num))
    });

    1u8.range_do!(15, |num| if (num != 4 && num != 6 && num != 9 && num != 8 && num != 12) {
        deck.push_back(Card::Square(num))
    });
    1u8.range_do!(9, |num| if (num != 6) deck.push_back(Card::Star(num)));
    deck
}

public fun start_game(game: &mut Whot, ctx: &mut Txcontext) {
    assert!(game.players.length() >= 2, ENotEnoughPlayers);

    let first_card = vector::pop_back(&mut game.deck);
    game.discard_pile.push_back(first_card);

    game.current_turn = 0;

    game.winner = option::none<address>();
}

public fun play_card(game: &mut Whot, player_index: u64, card_index: u64, ctx: &mut TxContext) {
    assert!(option::is_none(&game.winner), EGameOver);

    assert!(player_index == game.current_turn, ENotYourTurn);

    let player = &mut game.players[players_index];

    let played_card = vector::remove(&mut player.hand, card_index);

    let top_card = vector::borrow(&game.discard_pile, game.discard_pile.length() - 1);

    assert!(valid_move(&played_card, top_card), EInvalidCard);

    game.discard_pile.push_back(played_card);

    // Check if this player has won
    if (player.hand.length() == 0) {
        game.winner = option::some(ctx.sender());
        return;
    }

    // Move the turn to the next player
    game.current_turn = (game.current_turn + 1) % game.players.length();
}


#[test]
fun test_new_deck() {
    use std::unit_test::assert_eq;

    let deck = new_deck();
    assert_eq!(deck.length(), 108);
}
