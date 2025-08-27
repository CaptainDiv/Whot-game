module users::users;

use std::string::String;

/// Object of type `my_package::users::User`.
public struct User has store { name: String }

public struct Users key {
    id: UID,
    table: Table<String, User>,
}

/// Create a new `User` object in a `Users` object.
public fun new(users: &mut Users, name: String, ctx: &mut TxContext) {
    let user = User { name };
    table::add(users.table, name, user);
}

/// Do something with the `User` object.
public fun do_something(users: &mut Users, name: String, ctx: &mut TxContext) {
    let user = table::borrow(users.table, name);
    abort
}
