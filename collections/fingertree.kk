public module collections/fingertree

type node<a> { 
    con Node1 (size: int, x: a) // this will not appear as branches; instead, it is only data wrappers
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
        Node1(_, a) -> a -< init
        Node2(_, a, b) -> a -< (b -< init)
        Node3(_, a, b, c) -> a -< (b -< (c -< init))
    }
}

fun foldl(xs: node<a>, init: b, (>-): (b, a) -> e b): e b {
    match (xs) {
        Node1(_, a) -> init >- a
        Node2(_, a, b) -> (init >- a) >- b
        Node3(_, a, b, c) -> ((init >- a) >- b) >- c
    }
}

fun foldr(xs: tree<a>, init: b, func: (a, b) -> e b): e b {
    match ( xs ) {
        Empty -> init
        Leaf (x) -> func(x, init)
        Deep (_, f, m, r) -> {
            foldr(f, foldr(m, foldr(r, init, func), fn (n, y) { n.foldr(y, func) } ), func)
        }
    }
}

fun foldl(xs: tree<a>, init: b, func: (b, a) -> e b): e b {
    match ( xs ) {
        Empty -> init
        Leaf (x) -> func(init, x)
        Deep (_, f, m, r) -> {
            foldl(f, foldl(m, foldl(r, init, func), fn (y, n) { n.foldl(y, func) } ), func)
        }
    }
}

fun digit(n : node<a>) : digit<a> {
    match(n) {
        Node1(_, x) -> One(x)
        Node2(_, x, y) -> Two(x, y)
        Node3(_, x, y, z) -> Three(x, y, z)
    }
}

fun node2(a: node<a>, b: node<a>): node<node<a>> {
    Node2(a.size + b.size, a, b)
}

fun node3(a: node<a>, b: node<a>, c: node<a>): node<node<a>> {
    Node3(a.size + b.size + c.size, a, b, c)
}

alias ndigit<a> = digit<node<a>>
alias ntree<a> = tree<node<a>>

fun deep(f: ndigit<a>, m: ntree<node<a>>, r: ndigit<a>) : ntree<a> {
    Deep (f.size + m.size + r.size, f, m, r)
}

type left-view<s, a> {
    con NilL
    con VCons(x: a, xs: s<a>)
}

type right-view<s, a> {
    con NilR
    con VSnoc(xs: s<a>, x: a)
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

fun snoc ( xs: digit<a>, a: a ) : digit<a> {
    match (xs) {
        Zero -> One(a)
        One(b) -> Two(b, a)
        Two(c, b) -> Three(c, b, a)
        Three(d, c, b) -> Four(d, c, b, a)
        _ -> xs
    }
}

fun left-head ( xs: digit<a>) : maybe<a> {
    match (xs) {
        Zero -> Nothing
        One(a) -> Just(a)
        Two(a, _) -> Just(a)
        Three(a, _, _) -> Just(a)
        Four(a, _, _, _) -> Just(a)
    }
}

fun right-head ( xs: digit<a> ) : maybe<a> {
    match (xs) {
        Zero -> Nothing
        One(a) -> Just(a)
        Two(_, a) -> Just(a)
        Three(_, _, a) -> Just(a)
        Four(_, _, _, a) -> Just(a)
    }
}

fun left-tail ( xs: digit<a> ) : digit<a> {
    match (xs) {
        Two(_, b) -> One(b)
        Three(_, b, c) -> Two(b, c)
        Four(_, b, c, d) -> Three(b, c, d)
        _                -> Zero
    }
}

fun right-tail ( xs: digit<a> ) : digit<a> {
    match (xs) {
        Two(b, _) -> One(b)
        Three(c, b, _) -> Two(c, b)
        Four(d, c, b, _) -> Three(d, c, b)
        _                -> Zero
    }
}

fun left-deep (f: ndigit<a>, m: tree<node<node<a>>>, r: ndigit<a>): div ntree<a> {
    match (f) {
        Zero -> match (m.left-view) {
            NilL -> r.tree
            VCons(n, m') -> deep (n.digit, m', r)
        }
        _ -> deep(f, m, r)
    }
}

fun right-deep (f: ndigit<a>, m: tree<node<node<a>>>, r: ndigit<a>): div ntree<a> {
    match (r) {
        Zero -> match (m.right-view) {
            NilR -> f.tree
            VSnoc(m', n) -> deep (f, m', n.digit)
        }
        _ -> deep(f, m, r)
    }
}

fun tree(d: ndigit<a>): div ntree<a> {
    d.foldr(Empty, fn (x, t) { t.cons'(x) })
}

fun cons'(t: ntree<a>, x: node<a>) : div ntree<a> {
    match (t) {
        Empty -> Leaf(x)
        Leaf(y) -> deep(One(x), Empty, One(y))
        Deep(_, Four(a, b, c, d), m, r) ->
            deep(Two(x, a), m.cons'(node3(b, c, d)), r)
        Deep(_, f, m, r) ->
            deep(f.cons(x), m, r)
    }
}

fun snoc'(t: ntree<a>, x: node<a>) : div ntree<a> {
    match (t) {
        Empty -> Leaf(x)
        Leaf(y) -> deep(One(y), Empty, One(x))
        Deep(_, l, m, Four(d, c, b, a)) ->
            deep(l, m.snoc'(node3(d, c, b)), Two(a, x))
        Deep(_, f, m, r) ->
            deep(f, m, r.snoc(x))
    }
}



fun left-view(t: ntree<a>) : div left-view<tree, node<a>> {
    match ( t ) {
        Empty -> NilL
        Leaf(a) -> VCons(a, Empty)
        Deep(_, f, m, r) -> match (left-head(f)) {
            Just(h) -> VCons(h, left-deep(left-tail(f), m, r))
            _       -> NilL
        }
    }
}

fun right-view(t: ntree<a>) : div right-view<tree, node<a>> {
    match ( t ) {
        Empty -> NilR
        Leaf(a) -> VSnoc(Empty, a)
        Deep(_, f, m, r) -> match (right-head(r)) {
            Just(h) -> VSnoc(right-deep(f, m, right-tail(r)), h)
            _       -> NilR
        }
    }
}

fun head(t: ntree<a>): div maybe<node<a>> {
    match (t.left-view) {
        VCons(a, _) -> Just(a)
        _           -> Nothing
    }
}

fun tail(t: ntree<a>): div ntree<a> {
    match (t.left-view) {
        VCons(_, t') -> t'
        _           -> Empty
    }
}

fun last(t: ntree<a>): div maybe<node<a>> {
    match (t.right-view) {
        VSnoc(_, a) -> Just(a)
        _           -> Nothing
    }
}

fun init(t: ntree<a>): div ntree<a> {
    match (t.right-view) {
        VSnoc(t', _) -> t'
        _           -> Empty
    }
}

type seq<a> {
    con Seq(tree: ntree<a>)
}

fun new(): seq<a> {
    Seq(Empty)
}

fun cons(s: seq<a>, x: a): div seq<a> {
    Seq(s.tree.cons'(Node1(1, x)))
}

fun snoc(s: seq<a>, x: a): div seq<a> {
    Seq(s.tree.snoc'(Node1(1, x)))
}

fun size(s: seq<q>) : int {
    s.tree.size
}

fun head(s: seq<a>) : div maybe<a> {
    match (s.tree.left-view) {
        NilL -> Nothing
        VCons(n, _) -> Just(n.x)
    }
}

fun tail(s: seq<a>) : div seq<a> {
    match (s.tree.left-view) {
        NilL -> Seq(Empty)
        VCons(_, t) -> Seq(t)
    }
}

fun last(s: seq<a>) : div maybe<a> {
    match (s.tree.right-view) {
        NilR -> Nothing
        VSnoc(_, n) -> Just(n.x)
    }
}

fun init(s: seq<a>) : div seq<a> {
    match (s.tree.right-view) {
        NilR -> Seq(Empty)
        VSnoc(t, _) -> Seq(t)
    }
}