/// Module: whot
module whot::whot;

const EAlreadyFull: u64 = 0;

/// A single game of Whot.
/// The game is played by at least 2 players, so we use the shared state.
public struct Whot has key {
    id: UID,
    deck: vector<Card>,
    players: vector<Player>,
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

#[test]
fun test_new_deck() {
    use std::unit_test::assert_eq;

    let deck = new_deck();
    assert_eq!(deck.length(), 108);
}
