import collections/rtqueue;
import std/core/types;
import std/num/random;

fun push_serial( q: rtqueue<int>, cur: int, target: int ) : div rtqueue<int> {
    if ( cur == target ) 
    then q
    else push_serial(q.push(cur), cur + 1, target)
}

fun pop_to_list(  q: rtqueue<a>, acc: list<a> ) : div list<a> {
    match ( q.front ) {
        Just (x) -> pop_to_list(q.pop, Cons(x, acc))
        Nothing -> acc
    }
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

fun create-list(from: int, target: int, acc: list<int>) : div list<int> {
    if (from == target)
    then acc
    else create-list(from + 1, target, Cons(from, acc))
}

fun create-random(count: int, x: list<int>, y: rtqueue<int>) : <div, ndet> (list<int>, list<int>) {
    if ( count == 0 ) 
    then (x, y.pop_to_list(Nil))
    else {
        var t := random/srandom-int()
        if (random/srandom-bool()) 
        then create-random( count - 1, Cons(t, x), y.push(t) )
        else create-random( count - 1, x.init, y.pop )
    }
}

fun main() {
    val a = rtqueue/new()
        .push_serial(1, 100)
        .pop_to_list(Nil);
    val b = create-list(1, 100, Nil)
    var flag := True
    if ( !list-eq( a, b )) {
        println(a.show)
        println(b.show)
        flag := False
    }
    val (x, y) = create-random(20000, Nil, rtqueue/new())
    if ( !list-eq( x, y ) ) {
        println(x.show)
        println(y.show)
        flag := False
    }
    if (flag)
    then println("success")
    else println("false")
}

