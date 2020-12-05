import collections/avltree
import std/num/random

fun is-avl( tree: avlnode<a> ) : bool {
    match ( tree ) {
        Empty -> True
        Branch (l, _, r, d) ->
            l.is-avl && r.is-avl && d == r.height - l.height && d.abs <= 1
    }
} 

fun height ( tree: avlnode<a> ) : int {
    match ( tree ) {
        Empty -> 0
        Branch ( l, _, r, _ ) -> 1 + max(l.height, r.height)
    }
}

fun validate-delta ( tree: avlnode<a> ) : bool {
    match ( tree ) {
        Empty -> True
        Branch ( l, _, r, d ) ->
            l.validate-delta && r.validate-delta && d == r.height - l.height
    }
}

fun random-list ( size: int, acc: list<int> ) : <div, ndet> list<int> {
    if ( size <= 0 )
    then acc
    else random-list ( size - 1, Cons ( random/srandom-int(), acc ) )
}

fun merge ( a: list<int>, b: list<int> ) : div list<int> {
    match ( ( a, b ) ) {
        ( x, Nil ) -> x
        ( Nil, y ) -> y
        ( Cons( x, xs ), Cons ( y, ys ) ) ->
            if ( x >= y )
            then Cons ( x, merge ( xs, b ) )
            else Cons ( y, merge ( a, ys ) )
    } 
}

fun odd-even-split ( a: list<int>, odd: list<int>, even: list<int> ) : ( list<int>, list<int> ) {
    match ( a ) {
        Nil -> ( odd, even )
        [x] -> ( Cons(x, odd ), even )
        Cons(x, Cons( y, t )) -> odd-even-split ( t, Cons ( x, odd ), Cons ( y, even ) )
    }
}

fun sort ( xs: list<int> ) : div list<int> {
    match ( xs ) {
        Nil -> Nil
        [x] -> [x]
        _   -> {
            val ( m, n ) = odd-even-split ( xs, Nil, Nil )
            merge ( m.sort, n.sort )
        }
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

fun random-select ( xs : list<int>, acc: list<int>, del: list<int> ) : ndet (list<int>, list<int>) {
    match ( xs ) {
        Nil -> ( acc, del )
        Cons( x, xs' ) ->
            if ( random/srandom-bool() )
            then random-select ( xs', acc, Cons ( x, del ) )
            else random-select ( xs', Cons( x, acc ), del )
    }
}

fun delete-list( xs: list<int>, t: avltree<int> ) : avltree<int> {
    match ( xs ) {
        Nil -> t
        Cons ( x, xs' ) ->
            delete-list ( xs', t.delete(x) )
    }
}

fun dedup ( xs: list<int>, last: maybe<int> ) : div list<int> {
    match ( ( xs, last ) ) {
        ( Nil, _ ) -> Nil
        ( Cons(y, ys), Nothing ) -> Cons ( y, dedup ( ys, Just (y) ) )
        ( Cons(y, ys), Just ( x ) ) ->
            if ( x == y )
            then dedup ( ys, last )
            else Cons ( y, dedup ( ys, Just (y) ) )
    }
}

fun main() {
    val data   = random-list(391111, Nil)
    val sorted = data.sort().dedup(Nothing)
    val tree   = data.avltree(compare)
    val data'  = tree.to-list()
    var flag  := True
    
    if ( !list-eq ( sorted, data' ) ) {
        flag := False
        println("not equal")
    }

    if ( !validate-delta ( tree.root ) ) {
        flag := False
        println("delta failure")
    }

    if ( !is-avl ( tree.root ) ) {
        flag := False
        println("avl failure")
    }

    val ( rem, del ) = random-select ( sorted.dedup(Nothing), Nil, Nil )
    val deleted = delete-list ( del, tree )
    val tree-list = deleted.to-list()
    
    if ( !validate-delta ( deleted.root ) ) {
        flag := False
        println("del delta failure")
    }

    if ( !is-avl ( deleted.root ) ) {
        flag := False
        println("del avl failure")
    }

    if ( !list-eq( rem.sort().dedup(Nothing), tree-list) ) {
        flag := False
        println("del not equal")
    }

    if (flag)
    then println("success")
    else println("failure")
}