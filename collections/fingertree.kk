public module collections/fingertree

type node<a> { 
    con Node2 (size: int, x: a, y: a)
    con Node3 (size: int, x: a, y: a, z: a)
}

type digit<a> {
    con Zero
    con One   (a: a)
    con Two   (a: a, b: a)
    con Three (a: a, b: a, c: a)
    con Four  (a: a, b: a, c: a, d: a)
}

type tree<a> {
    con Empty
    con Leaf (element: a)
    con Deep (
        size: int,
        front: digit<a>,
        mid: tree<node<a>>,
        rear: digit<a>
    )
}

fun size ( xs: digit<node<a>> ): int {
    match (xs) {
        Zero -> 0
        One(a) -> a.size
        Two(a, b) -> a.size + b.size
        Three(a, b, c) -> a.size + b.size + c.size
        Four(a, b, c, d) -> a.size + b.size + c.size + d.size
    }
}

fun size ( xs: tree<node<a>> ): int {
    match (xs) {
        Empty -> 0
        Leaf (a) -> a.size
        Deep(s, _, _, _) -> s
    }
}

fun cons ( xs: digit<a>, a: a ) : digit<a> {
    match (xs) {
        Zero -> One(a)
        One(b) -> Two(a, b)
        Two(b, c) -> Three(a, b, c)
        Three(b, c, d) -> Four(a, b, c, d)
        _ -> xs
    }
}

fun foldr(xs: digit<a>, init: b, (-<): (a, b) -> e b): e b {
    match (xs) {
        Zero -> init
        One(a) -> a -< init
        Two(a, b) -> a -< (b -< init)
        Three(a, b, c) -> a -< (b -< (c -< init))
        Four(a, b, c, d) -> a -< (b -< (c -< (d -< init)))
    }
}

fun foldl(xs: digit<a>, init: b, (>-): (b, a) -> e b): e b {
    match (xs) {
        Zero -> init
        One(a) -> init >- a
        Two(a, b) -> (init >- a) >- b
        Three(a, b, c) -> ((init >- a) >- b) >- c
        Four(a, b, c, d) -> (((init >- a) >- b) >- c) >- d
    }
}

fun foldr(xs: node<a>, init: b, (-<): (a, b) -> e b): e b {
    match (xs) {
        Node2(_, a, b) -> a -< (b -< init)
        Node3(_, a, b, c) -> a -< (b -< (c -< init))
    }
}

fun foldl(xs: node<a>, init: b, (>-): (b, a) -> e b): e b {
    match (xs) {
        Node2(_, a, b) -> (init >- a) >- b
        Node3(_, a, b, c) -> ((init >- a) >- b) >- c
    }
}