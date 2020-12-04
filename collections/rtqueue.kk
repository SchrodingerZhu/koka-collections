public module collections/rtqueue
import std/core/types;

private type state<a> {
    con Empty
    con Reverse(n: int, xs: list<a>, fs: list<a>, ys: list<a>, rs: list<a>)
    con Concat(n: int, xs: list<a>, ys: list<a>)
    con Done(xs: list<a>)
}

pub type rtqueue<a>  {
    con RTQueue (
        f: list<a>,
        f_size: int,
        s: state<a>,
        r: list<a>,
        r_size: int
    )
}

private fun next(state: state<a>) : total state<a> {
    match (state) {
        Reverse(n, Cons(x, xs), f, Cons(y, ys), r)  ->
            Reverse(n + 1, xs, Cons(x, f),  ys, Cons(y, r))
        Reverse(n, _, f, [y], r) ->
            Concat(n, f, Cons(y, r))
        Concat(0, _, acc) ->
            Done(acc)
        Concat(n, Cons(x, xs), acc) ->
            Concat(n - 1, xs, Cons(x, acc))
        _ -> state
    }
}

private fun abort(state: state<a>) : total state<a> {
    match (state) {
        Concat(0, _, Cons(_, xs)) ->
            Done(xs)
        Concat(n, f, acc) ->
            Concat(n - 1, f, acc)
        Reverse(n, f, f', r, r') ->
            Reverse(n - 1, f, f', r, r')
        _ -> state
    }
}

private fun step(f : list<a>, f_size: int, s: state<a>, r: list<a>, r_size: int) : total rtqueue<a> {
    match (
        if   ( f.is-empty  )
        then { s.next.next }
        else { s.next      }
    ) {
        Done(f') -> RTQueue(f', f_size, Empty, r, r_size)
        s'       -> RTQueue(f, f_size, s', r, r_size)
    }
}

private fun balance(f : list<a>, f_size: int, s: state<a>, r: list<a>, r_size: int) : total rtqueue<a> {
    if (r_size <= f_size)
    then { step(f, f_size, s, r, r_size) }
    else { step(f, f_size + r_size, Reverse(0, f, Nil, r, Nil), Nil, 0) }
}

pub fun new() : total rtqueue<a> {
    RTQueue(Nil, 0, Empty, Nil, 0)
}

pub fun is-empty(q: rtqueue<a>) : total bool {
    q.f_size == 0
}

pub fun push(q: rtqueue<a>, x: a) : total rtqueue<a> {
    balance(q.f, q.f_size, q.s, Cons(x, q.r), q.r_size + 1)
}

pub fun front(q: rtqueue<a>) : total maybe<a> {
    match (q.f) {
        Nil -> Nothing
        Cons(x, _) -> Just(x)
    }
}

pub fun pop(q: rtqueue<a>): total rtqueue<a> {
    match (q) {
        RTQueue(Cons(_, xs), fs, s, r, rs) ->
            balance(xs, fs - 1, s.abort, r, rs)
        _ -> q
    }
}
