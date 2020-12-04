public module collections/avltree;
import std/core/types;

type avlnode<a> {
    con Empty
    con Branch ( l: avlnode<a>, x: a, r: avlnode<a>, k: int )
} 

fun min ( tree: avlnode<a> ) : maybe<a> {
    match ( tree ) {
        Empty -> Nothing
        Branch ( Empty, x, _, _ ) -> Just ( x )
        Branch ( l, _, _, _ ) -> min ( l )
    }
}

fun balance ( target: ( avlnode<a>, int ) ) : ( avlnode<a>, int ) {
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

fun delta-height(d: int, d': int, dl: int, dr: int) : int {
    if ( d >= 0 && d' >= 0 )
    then dr
    elif ( d <= 0 && d' >= 0 )
    then d + dr
    elif ( d >= 0 && d' <= 0 )
    then dl - d
    else dl
}

fun node ( p: (avlnode<a>, int), ele: a, p' : (avlnode<a>, int), d: int) : (avlnode<a>, int) {
    val d' = d + p'.snd - p.snd
    balance ((
        Branch ( p.fst, ele, p'.fst, d' ),
        delta-height ( d, d', p.snd, p'.snd )
    ))
}

fun ins ( t: avlnode<a>, x: a, compare: (a, a) -> order ) : ( avlnode<a>, int ) {
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

fun del ( t: avlnode<a>, x: a, compare: (a, a) -> order ) : ( avlnode<a>, int) {
    match ( t ) {
        Empty ->  ( Empty, 0 )
        Branch ( l, k, r, d ) ->
            match ( compare ( x, k ) ) {
                Lt -> node ( l.del(x, compare), k, (r, 0), d )
                Gt -> node ( ( l, 0 ), k, r.del(x, compare), d )
                Eq -> 
                    if (l.is-empty) then (r, -1)      
                    elif (r.is-empty) then (l, -1)
                    else match ( r.min ) {
                        Just ( k' ) -> node ( ( l, 0 ), k', r.del(k', compare), d )
                        _ -> ( t, 0 )
                    }
            }
    }
}
 
type avltree <a> {
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