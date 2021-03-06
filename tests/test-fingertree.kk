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

fun split-eq(length: int, seq: seq<int>, l: list<int>): <console, div> bool {
    if (length < -1)
    then True
    else {
        val seq-split = seq.split(length)
        val list-split = l.split(length)
        if (list-eq(list(seq-split.fst), list-split.fst) && list-eq(list(seq-split.snd), list-split.snd)) 
        then split-eq(length - 1, seq, l)
        else {
            print("split at ")
            print(length)
            println(" failed")
            False
        }
    }
}

fun lookup-eq(length: int, seq: seq<int>, l: list<int>): <console, div> bool {
    if (length < 0)
    then True
    else {
        if (l.list-at(length) !== seq.at(length)) 
        then {
            print("look up not eq at ")
            length.println
            False
        }
        else lookup-eq(length - 1, seq, l)
    }
}

fun randomized-eq (x: list<int>, y: seq<int>, cnt: int): <ndet, div> bool {
    if (cnt == 0)
    then list-eq(x, y.list)
    else match (random/srandom-int() % 10) {
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
        7 -> {
            val index = 5000 + random/srandom-int() % (y.size + 1);
            randomized-eq(x.split(index).fst, y.split(index).fst, cnt - 1)
        }
        8 -> {
            randomized-eq(x.reverse, y.reverse, cnt - 1)
        }
        _ -> {
            val x' = random-list(100, Nil)
            val y' = x'.seq
            randomized-eq(x'.append(x), y'.merge(y), cnt - 1)
        }
    }
}

fun list-at(l: list<a>, index: int): maybe<a> { // index should not be larger than length
    l.take(index + 1).last
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

    if ( !list-eq ( data.reverse, data.seq.reverse.list ) ) {
        flag := False
        println("reverse not equal")
    }

    if ( !list-eq ( data.map(fn (x) { x - 1 }), data.seq.map(fn (x) { x - 1 }).list ) ) {
        flag := False
        println("map not equal")
    }

    if ( data.seq.foldl(0, (+)) != data.foldl(0, (+)) ) {
        flag := False
        println("foldl not equal")
    }

    if ( data.seq.foldr(0, (+)) != data.foldr(0, (+)) ) {
        flag := False
        println("foldr not equal")
    }

    val split-test = random-list(500, Nil)
    if ( !split-eq(501, split-test.seq, split-test) ) {
        flag := False
        println("split not equal")
    }

    val test = random-list(10000, Nil)
    if ( !lookup-eq(9999, test.seq, test) ) {
        flag := False
        println("lookup not equal")
    }
    if ( !randomized-eq(test, test.seq, 30000) ) {
        flag := False
        println("randomized not equal")
    }

    if (flag)
    then println("success")
    else println("failure")
}