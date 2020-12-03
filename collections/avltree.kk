import std/core/types;

type avltree<a> {
    con Empty
    con Branch ( l: avltree<a>, x: a, r: avltree<a>, k: int )
} 

pub fun min ( tree: avltree<a> ) : maybe<a> {
    match ( tree ) {
        Empty -> Nothing
        Branch ( Empty, x, _, _ ) -> Just ( x )
        Branch ( l, _, _, _ ) -> min ( l )
    }
}

fun balance ( target: ( avltree<a>, int ) ) : ( avltree<a>, int ) {
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
                
        
        // TODO: not yet finished

        _ -> target
    }
} 



