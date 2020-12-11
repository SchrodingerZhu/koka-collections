import collections/fingertree;
import std/num/random

fun random-list(n: int, k: list<int>): <div, ndet> list<int> {
    if (n <= 0) 
    then k
    else random-list(n - 1, Cons(random/srandom-int(), k))
}

fun list-eq ( x: list<int>, y: list<int> ) : div bool {
    match ( (x, y) ) {
        (Nil, Nil) -> True
        (Cons(h, t), Cons(h', t')) -> 
            if ( h == h' ) 
            then list-eq(t, t')
            else False
        _ -> False
    }
}

fun (!==)(a: maybe<int>, b: maybe<int>): bool {
    match (a, b) {
        (Just(x), Just(y)) -> x != y
        (Nothing, Nothing) -> False
        _                  -> True
    }
}

fun randomized-eq (x: list<int>, y: seq<int>, cnt: int): <ndet, div> bool {
    if (cnt == 0)
    then True
    else match (random/srandom-int() % 8) {
        0 -> if (x.head !== y.head) then False else randomized-eq(x, y, cnt - 1)
        1 -> if (x.last !== y.last) then False else randomized-eq(x, y, cnt - 1)
        2 -> randomized-eq(x.tail, y.tail, cnt - 1)
        3 -> randomized-eq(x.init, y.init, cnt - 1)
        4 -> {
            val n = random/srandom-int()
            randomized-eq(x.append([n]), y.snoc(n), cnt - 1)
        }
        5 -> {
            val n = random/srandom-int()
            randomized-eq(Cons(n, x), y.cons(n), cnt - 1)
        }
        6 -> if (!list-eq(x, y.list)) then False else randomized-eq(x, y, cnt - 1)
        _ -> {
            val x' = random-list(100, Nil)
            val y' = x'.seq
            randomized-eq(x'.append(x), y'.merge(y), cnt - 1)
        }
    }
}

fun main() {
    var flag := True
    val data = random-list(100000, Nil)
    if ( !list-eq ( data.seq.list, data ) ) {
        flag := False
        println("data.seq.list != data")
    }
    val data' = random-list(100000, Nil)
    if ( !list-eq ( data.append(data'), data.seq.merge(data'.seq).list ) ) {
        flag := False
        println("merge not equal")
    }
    val test = random-list(10000, Nil)
    if ( !randomized-eq(test, test.seq, 20000) ) {
        flag := False
        println("randomized not equal")
    }
    if (flag)
    then println("success")
    else println("failure")
}