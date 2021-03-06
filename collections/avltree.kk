public module collections/avltree;
import std/core/types;

type avlnode<a> {
    con Empty
    con Branch ( l: avlnode<a>, x: a, r: avlnode<a>, k: int )
} 

private fun min ( tree: avlnode<a> ) : maybe<a> {
    match ( tree ) {
        Empty -> Nothing
        Branch ( Empty, x, _, _ ) -> Just ( x )
        Branch ( l, _, _, _ ) -> min ( l )
    }
}

private fun balance ( target: ( avlnode<a>, int ) ) : ( avlnode<a>, int ) {
    match ( target ) {

        ( Branch ( Branch ( Branch ( a, x, b, dx ), y, c, -1 ), z, d, -2 ), dh ) ->
            ( Branch ( Branch ( a, x, b, dx ), y, Branch ( c, z, d, 0 ), 0 ), dh - 1 )

        ( Branch ( a, x, Branch ( b, y, Branch ( c, z, d, dz ), 1 ), 2 ), dh ) ->
            ( Branch ( Branch ( a, x, b, 0 ), y, Branch ( c, z, d, dz ), 0 ), dh - 1 )

        ( Branch ( Branch ( a, x, Branch ( b, y, c, dy ), 1 ), z, d, -2 ), dh ) ->
            ( Branch ( Branch ( a, x, b, if ( dy == 1 ) then -1 else 0 )
                     , y
                     , Branch ( c, z, d, if ( dy == -1 ) then 1 else 0 )
                     , 0 ), dh - 1 ) 
                
        ( Branch ( a, x, Branch ( Branch ( b, y, c, dy ), z, d, -1 ), 2 ) , dh ) ->
            ( Branch ( Branch ( a, x, b, if ( dy == 1 ) then -1 else 0 )
                     , y
                     , Branch ( c, z, d, if ( dy == -1 ) then 1 else 0 )
                     , 0 ), dh - 1 ) 
        
        ( Branch ( Branch ( a, x, b, dx ), y, c, -2 ), dh ) ->
            ( Branch ( a, x, Branch ( b, y, c, -1 ), dx + 1 ) , dh )

        ( Branch ( a, x, Branch ( b, y, c, dy ), 2 ), dh ) ->
            ( Branch ( Branch ( a, x, b, 1 ), y, c, dy - 1 ) , dh )

        _ -> target
    }
} 

private fun delta-height(d: int, d': int, dl: int, dr: int) : int {
    if ( d >= 0 && d' >= 0 )
    then dr
    elif ( d <= 0 && d' >= 0 )
    then d + dr
    elif ( d >= 0 && d' <= 0 )
    then dl - d
    else dl
}

private fun node ( p: (avlnode<a>, int), ele: a, p' : (avlnode<a>, int), d: int) : (avlnode<a>, int) {
    val d' = d + p'.snd - p.snd
    balance ((
        Branch ( p.fst, ele, p'.fst, d' ),
        delta-height ( d, d', p.snd, p'.snd )
    ))
}

private fun ins ( t: avlnode<a>, x: a, compare: (a, a) -> order ) : ( avlnode<a>, int ) {
    match ( t ) {
        Empty -> ( Branch ( Empty, x, Empty, 0 ), 1 )
        Branch ( l, k, r, d ) ->
            match ( compare ( x, k ) ) {
                Lt -> node ( ins( l, x, compare ), k, ( r, 0 ), d )
                Eq -> (Branch ( l, k, r, d ), 0 )
                _  -> node ( ( l, 0 ), k, ins ( r, x, compare ), d )
            }
    }
}

private fun del ( t: avlnode<a>, x: a, compare: (a, a) -> order ) : (avlnode<a>, int) {
    match ( t ) {
        Empty ->  ( Empty, 0 )
        Branch ( l, k, r, d ) ->
            match ( compare ( x, k ) ) {
                Lt -> node ( l.del(x, compare), k, (r, 0), d )
                Gt -> node ( ( l, 0 ), k, r.del(x, compare), d )
                Eq -> 
                    if (l.is-empty) then (r, -1)      
                    elif (r.is-empty) then (l, -1)
                    else match ( r.del-min ) {
                        (r', d', Just ( k' ) ) -> node ( ( l, 0 ), k', (r', d'), d )
                        _ -> ( t, 0 )
                    }
            }
    }
}

private fun del-min ( t: avlnode<a> ) : ( avlnode<a>, int, maybe<a> ) {
    match ( t ) {
        Empty -> ( Empty, 0, Nothing )
        Branch ( Empty, k, r, _ ) -> ( r, -1, Just(k) )
        Branch ( l, k, r, d ) -> { 
            val (l', d', x) = l.del-min
            val (s, w) = node ( (l', d'), k, (r, 0), d )
            ( s, w, x )
        }
    }
}

private fun contains ( t: avlnode<a>, x: a, compare: (a, a) -> order ) : bool {
    match ( t ) {
        Empty -> False
        Branch ( l, k, r, _ ) -> 
            match ( compare ( x, k ) ) {
                Eq -> True
                Lt -> l.contains(x, compare)
                Gt -> r.contains(x, compare)
            }
    }
}
 
pub type avltree <a> {
    con AVLTree( root: avlnode<a> , compare: (a, a) -> order )
}

pub fun new( compare: (a, a) -> order ) : avltree<a> {
    AVLTree ( Empty, compare )
}

pub fun insert ( t: avltree<a>, x: a ) : avltree<a> {
    AVLTree ( t.root.ins(x, t.compare).fst, t.compare )
}

pub fun delete ( t: avltree<a>, x: a ) : avltree<a> {
    AVLTree ( t.root.del(x, t.compare).fst, t.compare )
}

pub fun min ( t: avltree<a> ) : maybe<a> {
    t.root.min
}

pub fun contains ( t: avltree<a>, x: a ) : bool {
    t.root.contains(x, t.compare)
}

pub fun insert-list ( t : avltree<a>, xs: list<a> ) : avltree<a> {
    match ( xs ) {
        Nil -> t 
        Cons(x, xs') -> insert-list( t.insert(x), xs' )
    }
}

pub fun avltree ( xs: list<a>, compare: (a, a) -> order ) : avltree<a> {
    new(compare).insert-list(xs)
}

private fun to-list ( t: avlnode<a>, xs: list<a> ) : div list<a> {
    match ( t ) {
        Empty -> xs
        _     -> match ( t.del-min ) {
            ( t', _, Just (x) ) -> to-list ( t', Cons( x, xs ))
            _                   -> xs
        }
    }
}

pub fun to-list ( t: avltree<a> ) : div list<a> {
    t.root.to-list( Nil )
}
