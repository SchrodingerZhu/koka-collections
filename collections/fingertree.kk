public module collections/fingertree

private type node<a> { 
    con Node1 (size: int, x: a) // this will not appear as branches; instead, it is only data wrappers
    con Node2 (size: int, x: a, y: a)
    con Node3 (size: int, x: a, y: a, z: a)
}

private type digit<a> {
    con Zero
    con One   (a: a)
    con Two   (a: a, b: a)
    con Three (a: a, b: a, c: a)
    con Four  (a: a, b: a, c: a, d: a)
}

private type tree<a> {
    con Empty
    con Leaf (element: a)
    con Deep (
        size: int,
        front: digit<a>,
        mid: tree<node<a>>,
        rear: digit<a>
    )
}

private fun size ( xs: digit<node<a>> ): int {
    match (xs) {
        Zero -> 0
        One(a) -> a.size
        Two(a, b) -> a.size + b.size
        Three(a, b, c) -> a.size + b.size + c.size
        Four(a, b, c, d) -> a.size + b.size + c.size + d.size
    }
}

private fun size ( xs: tree<node<a>> ): int {
    match (xs) {
        Empty -> 0
        Leaf (a) -> a.size
        Deep(s, _, _, _) -> s
    }
}

private fun foldr(xs: digit<a>, init: b, (-<): (a, b) -> e b): e b {
    match (xs) {
        Zero -> init
        One(a) -> a -< init
        Two(a, b) -> a -< (b -< init)
        Three(a, b, c) -> a -< (b -< (c -< init))
        Four(a, b, c, d) -> a -< (b -< (c -< (d -< init)))
    }
}

private fun foldl(xs: digit<a>, init: b, (>-): (b, a) -> e b): e b {
    match (xs) {
        Zero -> init
        One(a) -> init >- a
        Two(a, b) -> (init >- a) >- b
        Three(a, b, c) -> ((init >- a) >- b) >- c
        Four(a, b, c, d) -> (((init >- a) >- b) >- c) >- d
    }
}

private fun foldr(xs: node<a>, init: b, (-<): (a, b) -> e b): e b {
    match (xs) {
        Node1(_, a) -> a -< init
        Node2(_, a, b) -> a -< (b -< init)
        Node3(_, a, b, c) -> a -< (b -< (c -< init))
    }
}

private fun foldl(xs: node<a>, init: b, (>-): (b, a) -> e b): e b {
    match (xs) {
        Node1(_, a) -> init >- a
        Node2(_, a, b) -> (init >- a) >- b
        Node3(_, a, b, c) -> ((init >- a) >- b) >- c
    }
}

private fun foldr(xs: tree<a>, init: b, func: (a, b) -> e b): e b {
    match ( xs ) {
        Empty -> init
        Leaf (x) -> func(x, init)
        Deep (_, f, m, r) -> {
            foldr(f, foldr(m, foldr(r, init, func), fn (n, y) { n.foldr(y, func) } ), func)
        }
    }
}

private fun foldl(xs: tree<a>, init: b, func: (b, a) -> e b): e b {
    match ( xs ) {
        Empty -> init
        Leaf (x) -> func(init, x)
        Deep (_, f, m, r) -> {
            foldl(f, foldl(m, foldl(r, init, func), fn (y, n) { n.foldl(y, func) } ), func)
        }
    }
}

private fun digit(n : node<a>) : digit<a> {
    match(n) {
        Node1(_, x) -> One(x)
        Node2(_, x, y) -> Two(x, y)
        Node3(_, x, y, z) -> Three(x, y, z)
    }
}

private fun node1(a: node<a>): node<node<a>> {
    Node1(a.size, a)
}

private fun node2(a: node<a>, b: node<a>): node<node<a>> {
    Node2(a.size + b.size, a, b)
}

private fun node3(a: node<a>, b: node<a>, c: node<a>): node<node<a>> {
    Node3(a.size + b.size + c.size, a, b, c)
}

alias ndigit<a> = digit<node<a>>
alias ntree<a> = tree<node<a>>

private fun deep(f: ndigit<a>, m: ntree<node<a>>, r: ndigit<a>) : ntree<a> {
    Deep (f.size + m.size + r.size, f, m, r)
}

private type left-view<s, a> {
    con NilL
    con VCons(x: a, xs: s<a>)
}

private type right-view<s, a> {
    con NilR
    con VSnoc(xs: s<a>, x: a)
}


private fun cons ( xs: digit<a>, a: a ) : digit<a> {
    match (xs) {
        Zero -> One(a)
        One(b) -> Two(a, b)
        Two(b, c) -> Three(a, b, c)
        Three(b, c, d) -> Four(a, b, c, d)
        _ -> xs
    }
}

private fun snoc ( xs: digit<a>, a: a ) : digit<a> {
    match (xs) {
        Zero -> One(a)
        One(b) -> Two(b, a)
        Two(c, b) -> Three(c, b, a)
        Three(d, c, b) -> Four(d, c, b, a)
        _ -> xs
    }
}

private fun left-head ( xs: digit<a>) : maybe<a> {
    match (xs) {
        Zero -> Nothing
        One(a) -> Just(a)
        Two(a, _) -> Just(a)
        Three(a, _, _) -> Just(a)
        Four(a, _, _, _) -> Just(a)
    }
}

private fun right-head ( xs: digit<a> ) : maybe<a> {
    match (xs) {
        Zero -> Nothing
        One(a) -> Just(a)
        Two(_, a) -> Just(a)
        Three(_, _, a) -> Just(a)
        Four(_, _, _, a) -> Just(a)
    }
}

private fun left-tail ( xs: digit<a> ) : digit<a> {
    match (xs) {
        Two(_, b) -> One(b)
        Three(_, b, c) -> Two(b, c)
        Four(_, b, c, d) -> Three(b, c, d)
        _                -> Zero
    }
}

private fun right-tail ( xs: digit<a> ) : digit<a> {
    match (xs) {
        Two(b, _) -> One(b)
        Three(c, b, _) -> Two(c, b)
        Four(d, c, b, _) -> Three(d, c, b)
        _                -> Zero
    }
}

private fun left-deep (f: ndigit<a>, m: tree<node<node<a>>>, r: ndigit<a>): div ntree<a> {
    match (f) {
        Zero -> match (m.left-view) {
            NilL -> r.tree
            VCons(n, m') -> deep (n.digit, m', r)
        }
        _ -> deep(f, m, r)
    }
}

private fun right-deep (f: ndigit<a>, m: tree<node<node<a>>>, r: ndigit<a>): div ntree<a> {
    match (r) {
        Zero -> match (m.right-view) {
            NilR -> f.tree
            VSnoc(m', n) -> deep (f, m', n.digit)
        }
        _ -> deep(f, m, r)
    }
}

private fun tree(d: ndigit<a>): div ntree<a> {
    d.foldr(Empty, fn (x, t) { t.cons'(x) })
}

private fun cons'(t: ntree<a>, x: node<a>) : div ntree<a> {
    match (t) {
        Empty -> Leaf(x)
        Leaf(y) -> deep(One(x), Empty, One(y))
        Deep(_, Four(a, b, c, d), m, r) ->
            deep(Two(x, a), m.cons'(node3(b, c, d)), r)
        Deep(_, f, m, r) ->
            deep(f.cons(x), m, r)
    }
}

private fun snoc'(t: ntree<a>, x: node<a>) : div ntree<a> {
    match (t) {
        Empty -> Leaf(x)
        Leaf(y) -> deep(One(y), Empty, One(x))
        Deep(_, l, m, Four(d, c, b, a)) ->
            deep(l, m.snoc'(node3(d, c, b)), Two(a, x))
        Deep(_, f, m, r) ->
            deep(f, m, r.snoc(x))
    }
}



private fun left-view(t: ntree<a>) : div left-view<tree, node<a>> {
    match ( t ) {
        Empty -> NilL
        Leaf(a) -> VCons(a, Empty)
        Deep(_, f, m, r) -> match (left-head(f)) {
            Just(h) -> VCons(h, left-deep(left-tail(f), m, r))
            _       -> NilL
        }
    }
}

private fun right-view(t: ntree<a>) : div right-view<tree, node<a>> {
    match ( t ) {
        Empty -> NilR
        Leaf(a) -> VSnoc(Empty, a)
        Deep(_, f, m, r) -> match (right-head(r)) {
            Just(h) -> VSnoc(right-deep(f, m, right-tail(r)), h)
            _       -> NilR
        }
    }
}

private fun head(t: ntree<a>): div maybe<node<a>> {
    match (t.left-view) {
        VCons(a, _) -> Just(a)
        _           -> Nothing
    }
}

private fun tail(t: ntree<a>): div ntree<a> {
    match (t.left-view) {
        VCons(_, t') -> t'
        _           -> Empty
    }
}

private fun last(t: ntree<a>): div maybe<node<a>> {
    match (t.right-view) {
        VSnoc(_, a) -> Just(a)
        _           -> Nothing
    }
}

private fun init(t: ntree<a>): div ntree<a> {
    match (t.right-view) {
        VSnoc(t', _) -> t'
        _           -> Empty
    }
}

public type seq<a> {
    con Seq(tree: ntree<a>)
}

public fun new(): seq<a> {
    Seq(Empty)
}

public fun cons(s: seq<a>, x: a): div seq<a> {
    Seq(s.tree.cons'(Node1(1, x)))
}

public fun snoc(s: seq<a>, x: a): div seq<a> {
    Seq(s.tree.snoc'(Node1(1, x)))
}

public fun size(s: seq<q>) : int {
    s.tree.size
}

public fun head(s: seq<a>) : div maybe<a> {
    match (s.tree.left-view) {
        NilL -> Nothing
        VCons(n, _) -> Just(n.x)
    }
}

public fun tail(s: seq<a>) : div seq<a> {
    match (s.tree.left-view) {
        NilL -> Seq(Empty)
        VCons(_, t) -> Seq(t)
    }
}

public fun last(s: seq<a>) : div maybe<a> {
    match (s.tree.right-view) {
        NilR -> Nothing
        VSnoc(_, n) -> Just(n.x)
    }
}

public fun init(s: seq<a>) : div seq<a> {
    match (s.tree.right-view) {
        NilR -> Seq(Empty)
        VSnoc(t, _) -> Seq(t)
    }
}

public fun seq(xs: list<a>): div seq<a> {
    xs.foldl(new(), snoc)
}

public fun list(xs: seq<a>): list<a> {
    xs.tree.foldr(Nil, fn (n, acc) { Cons(n.x, acc) })
}

// this part is generated by other programs
private fun nodes(x: ndigit<a>, y: ndigit<a>, z: ndigit<a>): ndigit<node<a>> {
    match ((x, y, z)) {
        (One(a0), Zero, One(a1)) -> One(node2(a0, a1))
        (One(a0), Zero, Two(a1, a2)) -> One(node3(a0, a1, a2))
        (One(a0), Zero, Three(a1, a2, a3)) -> Two(node2(a0, a1), node2(a2, a3))
        (One(a0), Zero, Four(a1, a2, a3, a4)) -> Two(node3(a0, a1, a2), node2(a3, a4))
        (One(a0), One(a1), One(a2)) -> One(node3(a0, a1, a2))
        (One(a0), One(a1), Two(a2, a3)) -> Two(node2(a0, a1), node2(a2, a3))
        (One(a0), One(a1), Three(a2, a3, a4)) -> Two(node3(a0, a1, a2), node2(a3, a4))
        (One(a0), One(a1), Four(a2, a3, a4, a5)) -> Two(node3(a0, a1, a2), node3(a3, a4, a5))
        (One(a0), Two(a1, a2), One(a3)) -> Two(node2(a0, a1), node2(a2, a3))
        (One(a0), Two(a1, a2), Two(a3, a4)) -> Two(node3(a0, a1, a2), node2(a3, a4))
        (One(a0), Two(a1, a2), Three(a3, a4, a5)) -> Two(node3(a0, a1, a2), node3(a3, a4, a5))
        (One(a0), Two(a1, a2), Four(a3, a4, a5, a6)) -> Three(node3(a0, a1, a2), node2(a3, a4), node2(a5, a6))
        (One(a0), Three(a1, a2, a3), One(a4)) -> Two(node3(a0, a1, a2), node2(a3, a4))
        (One(a0), Three(a1, a2, a3), Two(a4, a5)) -> Two(node3(a0, a1, a2), node3(a3, a4, a5))
        (One(a0), Three(a1, a2, a3), Three(a4, a5, a6)) -> Three(node3(a0, a1, a2), node2(a3, a4), node2(a5, a6))
        (One(a0), Three(a1, a2, a3), Four(a4, a5, a6, a7)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7))
        (One(a0), Four(a1, a2, a3, a4), One(a5)) -> Two(node3(a0, a1, a2), node3(a3, a4, a5))
        (One(a0), Four(a1, a2, a3, a4), Two(a5, a6)) -> Three(node3(a0, a1, a2), node2(a3, a4), node2(a5, a6))
        (One(a0), Four(a1, a2, a3, a4), Three(a5, a6, a7)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7))
        (One(a0), Four(a1, a2, a3, a4), Four(a5, a6, a7, a8)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node3(a6, a7, a8))
        (Two(a0, a1), Zero, One(a2)) -> One(node3(a0, a1, a2))
        (Two(a0, a1), Zero, Two(a2, a3)) -> Two(node2(a0, a1), node2(a2, a3))
        (Two(a0, a1), Zero, Three(a2, a3, a4)) -> Two(node3(a0, a1, a2), node2(a3, a4))
        (Two(a0, a1), Zero, Four(a2, a3, a4, a5)) -> Two(node3(a0, a1, a2), node3(a3, a4, a5))
        (Two(a0, a1), One(a2), One(a3)) -> Two(node2(a0, a1), node2(a2, a3))
        (Two(a0, a1), One(a2), Two(a3, a4)) -> Two(node3(a0, a1, a2), node2(a3, a4))
        (Two(a0, a1), One(a2), Three(a3, a4, a5)) -> Two(node3(a0, a1, a2), node3(a3, a4, a5))
        (Two(a0, a1), One(a2), Four(a3, a4, a5, a6)) -> Three(node3(a0, a1, a2), node2(a3, a4), node2(a5, a6))
        (Two(a0, a1), Two(a2, a3), One(a4)) -> Two(node3(a0, a1, a2), node2(a3, a4))
        (Two(a0, a1), Two(a2, a3), Two(a4, a5)) -> Two(node3(a0, a1, a2), node3(a3, a4, a5))
        (Two(a0, a1), Two(a2, a3), Three(a4, a5, a6)) -> Three(node3(a0, a1, a2), node2(a3, a4), node2(a5, a6))
        (Two(a0, a1), Two(a2, a3), Four(a4, a5, a6, a7)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7))
        (Two(a0, a1), Three(a2, a3, a4), One(a5)) -> Two(node3(a0, a1, a2), node3(a3, a4, a5))
        (Two(a0, a1), Three(a2, a3, a4), Two(a5, a6)) -> Three(node3(a0, a1, a2), node2(a3, a4), node2(a5, a6))
        (Two(a0, a1), Three(a2, a3, a4), Three(a5, a6, a7)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7))
        (Two(a0, a1), Three(a2, a3, a4), Four(a5, a6, a7, a8)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node3(a6, a7, a8))
        (Two(a0, a1), Four(a2, a3, a4, a5), One(a6)) -> Three(node3(a0, a1, a2), node2(a3, a4), node2(a5, a6))
        (Two(a0, a1), Four(a2, a3, a4, a5), Two(a6, a7)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7))
        (Two(a0, a1), Four(a2, a3, a4, a5), Three(a6, a7, a8)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node3(a6, a7, a8))
        (Two(a0, a1), Four(a2, a3, a4, a5), Four(a6, a7, a8, a9)) -> Four(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7), node2(a8, a9))
        (Three(a0, a1, a2), Zero, One(a3)) -> Two(node2(a0, a1), node2(a2, a3))
        (Three(a0, a1, a2), Zero, Two(a3, a4)) -> Two(node3(a0, a1, a2), node2(a3, a4))
        (Three(a0, a1, a2), Zero, Three(a3, a4, a5)) -> Two(node3(a0, a1, a2), node3(a3, a4, a5))
        (Three(a0, a1, a2), Zero, Four(a3, a4, a5, a6)) -> Three(node3(a0, a1, a2), node2(a3, a4), node2(a5, a6))
        (Three(a0, a1, a2), One(a3), One(a4)) -> Two(node3(a0, a1, a2), node2(a3, a4))
        (Three(a0, a1, a2), One(a3), Two(a4, a5)) -> Two(node3(a0, a1, a2), node3(a3, a4, a5))
        (Three(a0, a1, a2), One(a3), Three(a4, a5, a6)) -> Three(node3(a0, a1, a2), node2(a3, a4), node2(a5, a6))
        (Three(a0, a1, a2), One(a3), Four(a4, a5, a6, a7)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7))
        (Three(a0, a1, a2), Two(a3, a4), One(a5)) -> Two(node3(a0, a1, a2), node3(a3, a4, a5))
        (Three(a0, a1, a2), Two(a3, a4), Two(a5, a6)) -> Three(node3(a0, a1, a2), node2(a3, a4), node2(a5, a6))
        (Three(a0, a1, a2), Two(a3, a4), Three(a5, a6, a7)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7))
        (Three(a0, a1, a2), Two(a3, a4), Four(a5, a6, a7, a8)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node3(a6, a7, a8))
        (Three(a0, a1, a2), Three(a3, a4, a5), One(a6)) -> Three(node3(a0, a1, a2), node2(a3, a4), node2(a5, a6))
        (Three(a0, a1, a2), Three(a3, a4, a5), Two(a6, a7)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7))
        (Three(a0, a1, a2), Three(a3, a4, a5), Three(a6, a7, a8)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node3(a6, a7, a8))
        (Three(a0, a1, a2), Three(a3, a4, a5), Four(a6, a7, a8, a9)) -> Four(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7), node2(a8, a9))
        (Three(a0, a1, a2), Four(a3, a4, a5, a6), One(a7)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7))
        (Three(a0, a1, a2), Four(a3, a4, a5, a6), Two(a7, a8)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node3(a6, a7, a8))
        (Three(a0, a1, a2), Four(a3, a4, a5, a6), Three(a7, a8, a9)) -> Four(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7), node2(a8, a9))
        (Three(a0, a1, a2), Four(a3, a4, a5, a6), Four(a7, a8, a9, a10)) -> Four(node3(a0, a1, a2), node3(a3, a4, a5), node3(a6, a7, a8), node2(a9, a10))
        (Four(a0, a1, a2, a3), Zero, One(a4)) -> Two(node3(a0, a1, a2), node2(a3, a4))
        (Four(a0, a1, a2, a3), Zero, Two(a4, a5)) -> Two(node3(a0, a1, a2), node3(a3, a4, a5))
        (Four(a0, a1, a2, a3), Zero, Three(a4, a5, a6)) -> Three(node3(a0, a1, a2), node2(a3, a4), node2(a5, a6))
        (Four(a0, a1, a2, a3), Zero, Four(a4, a5, a6, a7)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7))
        (Four(a0, a1, a2, a3), One(a4), One(a5)) -> Two(node3(a0, a1, a2), node3(a3, a4, a5))
        (Four(a0, a1, a2, a3), One(a4), Two(a5, a6)) -> Three(node3(a0, a1, a2), node2(a3, a4), node2(a5, a6))
        (Four(a0, a1, a2, a3), One(a4), Three(a5, a6, a7)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7))
        (Four(a0, a1, a2, a3), One(a4), Four(a5, a6, a7, a8)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node3(a6, a7, a8))
        (Four(a0, a1, a2, a3), Two(a4, a5), One(a6)) -> Three(node3(a0, a1, a2), node2(a3, a4), node2(a5, a6))
        (Four(a0, a1, a2, a3), Two(a4, a5), Two(a6, a7)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7))
        (Four(a0, a1, a2, a3), Two(a4, a5), Three(a6, a7, a8)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node3(a6, a7, a8))
        (Four(a0, a1, a2, a3), Two(a4, a5), Four(a6, a7, a8, a9)) -> Four(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7), node2(a8, a9))
        (Four(a0, a1, a2, a3), Three(a4, a5, a6), One(a7)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7))
        (Four(a0, a1, a2, a3), Three(a4, a5, a6), Two(a7, a8)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node3(a6, a7, a8))
        (Four(a0, a1, a2, a3), Three(a4, a5, a6), Three(a7, a8, a9)) -> Four(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7), node2(a8, a9))
        (Four(a0, a1, a2, a3), Three(a4, a5, a6), Four(a7, a8, a9, a10)) -> Four(node3(a0, a1, a2), node3(a3, a4, a5), node3(a6, a7, a8), node2(a9, a10))
        (Four(a0, a1, a2, a3), Four(a4, a5, a6, a7), One(a8)) -> Three(node3(a0, a1, a2), node3(a3, a4, a5), node3(a6, a7, a8))
        (Four(a0, a1, a2, a3), Four(a4, a5, a6, a7), Two(a8, a9)) -> Four(node3(a0, a1, a2), node3(a3, a4, a5), node2(a6, a7), node2(a8, a9))
        (Four(a0, a1, a2, a3), Four(a4, a5, a6, a7), Three(a8, a9, a10)) -> Four(node3(a0, a1, a2), node3(a3, a4, a5), node3(a6, a7, a8), node2(a9, a10))
        (Four(a0, a1, a2, a3), Four(a4, a5, a6, a7), Four(a8, a9, a10, a11)) -> Four(node3(a0, a1, a2), node3(a3, a4, a5), node3(a6, a7, a8), node3(a9, a10, a11))
        _ -> Zero
    }
}

private fun merge'(a: ntree<a>, b: ndigit<a>, c: ntree<a>): div ntree<a> {
    match ((a, b, c)) {
        (Empty, ts, xs) -> foldr(ts, xs, fn (x, t) { t.cons'(x) } )
        (xs, ts, Empty) -> foldl(ts, xs, snoc')
        (Leaf(x), ts, xs) -> foldr(ts, xs, fn (y, t) { t.cons'(y) }).cons'(x)
        (xs, ts, Leaf(x)) -> foldl(ts, xs, snoc').snoc'(x)
        (Deep(_, f1, t1, r1), ts, Deep(_, f2, t2, r2)) ->
            deep(f1, merge'(t1, nodes(r1, ts, f2), t2), r2)
    }
}

private fun merge(x: ntree<a>, y: ntree<a>): div ntree<a> {
    merge'(x, Zero, y)
}

public fun merge(x: seq<a>, y: seq<a>): div seq<a> {
    Seq(x.tree.merge(y.tree))
}

public type split<c, a> {
    con NotFound
    con Split(front: c<a>, mid: a, rear: c<a>)
}

private fun map(digit: digit<a>, f: a -> e b): e digit<b> {
    match (digit) {
        Zero -> Zero
        One(a) -> One(f(a))
        Two(a, b) -> Two(f(a), f(b))
        Three(a, b, c) -> Three(f(a), f(b), f(c))
        Four(a, b, c, d) -> Four(f(a), f(b), f(c), f(d))
    }
}

private fun reverse(digit: digit<a>, f: a -> e b): e digit<b> {
    match (digit) {
        Zero -> Zero
        One(a) -> One(f(a))
        Two(a, b) -> Two(f(b), f(a))
        Three(a, b, c) -> Three(f(c), f(b), f(a))
        Four(a, b, c, d) -> Four(f(d), f(c), f(b), f(a))
    }
}

private fun split'(digit: ndigit<a>, index: int): split<digit, node<a>> {
    match (digit) {
        One(x) -> Split(Zero, x, Zero)
        Two(x, y) -> 
            if (x.size > index) then Split(Zero, x, One(y))
            else Split(One(x), y, Zero)
        Three(x, y, z) -> 
            if (x.size > index) then Split(Zero, x, Two(y, z))
            elif (x.size + y.size > index) then Split(One(x), y, One(z))
            else Split(Two(x, y), z, Zero)
        Four(a, b, c, d) -> 
            if (a.size > index) then Split(Zero, a, Three(b, c, d))
            elif (a.size + b.size > index) Split(One(a), b, Two(c, d))
            elif (a.size + b.size + c.size > index) Split(Two(a, b), c, One(d))
            else Split(Three(a, b, c), d, Zero)
        Zero -> NotFound
    }
}

private fun lookup(digit: ndigit<a>, index: int): maybe<(int, node<a>)> {
    match (digit) {
        One(x) -> Just((0, x))
        Two(x, y) -> 
            if (x.size > index) then Just((0, x))
            else Just((x.size, y))
        Three(x, y, z) -> 
            if (x.size > index) then Just((0, x))
            elif (x.size + y.size > index) then Just((x.size, y))
            else Just((x.size + y.size, z))
        Four(a, b, c, d) -> 
            if (a.size > index) then Just((0, a))
            elif (a.size + b.size > index) Just((a.size, b))
            elif (a.size + b.size + c.size > index) Just((a.size + b.size, c))
            else Just((a.size + b.size + c.size, d))
        Zero -> Nothing
    }
}

private fun split'(node: node<node<a>>, index: int): split<digit, node<a>> {
    match (node) {
        Node1(_, x) -> Split(Zero, x, Zero)
        Node2(_, x, y) -> 
            if ( x.size > index )
            then Split(Zero, x, One(y))
            else Split(One(x), y, Zero)
        Node3(_, x, y, z) -> 
            if (x.size > index) then Split(Zero, x, Two(y, z))
            elif (x.size + y.size > index) then Split(One(x), y, One(z))
            else Split(Two(x, y), z, Zero)
    }
}

private fun lookup(node: node<node<a>>, index: int): maybe<(int, node<a>)> {
    match (node) {
        Node1(_, x) -> Just((0, x))
        Node2(_, x, y) -> 
            if ( x.size > index )
            then Just((0, x))
            else Just((x.size, y))
        Node3(_, x, y, z) -> 
            if (x.size > index) then Just((0, x))
            elif (x.size + y.size > index) then Just((x.size, y))
            else Just((x.size + y.size, z))
    }
}

private fun map(node: node<a>, f: a -> e b): e node<b> {
    match (node) {
        Node1(s, x) -> Node1(s, f(x))
        Node2(s, x, y) -> Node2(s, f(x), f(y))
        Node3(s, x, y, z) -> Node3(s, f(x), f(y), f(z))
    }
}

private fun reverse(node: node<a>, f: a -> e b): e node<b> {
    match (node) {
        Node1(s, x) -> Node1(s, f(x))
        Node2(s, x, y) -> Node2(s, f(y), f(x))
        Node3(s, x, y, z) -> Node3(s, f(z), f(y), f(x))
    }
}


private fun digit-to-tree(digit: ndigit<a>): ntree<a> {
    match (digit) {
        Zero -> Empty
        One(a) -> Leaf(a)
        Two(a, b) -> deep(One(a), Empty, One(b))
        Three(a, b, c) -> deep(Two(a, b), Empty, One(c))
        Four(a, b, c, d) -> deep(Two(a, b), Empty, Two(c, d))
    }
}

private fun split'(tree: ntree<a>, index: int): div split<tree, node<a>> {
    match (tree) {
        Empty -> NotFound
        Leaf(a) -> Split(Empty, a, Empty)
        Deep(_, dl, t, dr) -> {
            if (dl.size > index) then {
                match (dl.split'(index)) {
                    Split (l, a, r) -> Split (l.digit-to-tree, a, left-deep(r, t, dr))
                    _ -> NotFound
                }
            }
            elif (dl.size + t.size > index) then {
                match (t.split'(index - dl.size)) {
                    Split (tl, ta, tr) -> match (ta.split'(index - dl.size - tl.size)) {
                        Split(l, a, r) -> Split (right-deep(dl, tl, l), a, left-deep(r, tr, dr))
                        _ -> NotFound
                    }   
                    _ -> NotFound
                }
            }
            else {
                match (dr.split'(index - dl.size - t.size)) {
                    Split (l, a, r) -> Split (right-deep(dl, t, l), a, r.digit-to-tree)
                    _ -> NotFound
                }
            }
        }
    } 
}

private fun lookup(tree: ntree<a>, index: int): div maybe<(int, node<a>)> {
    match (tree) {
        Empty -> Nothing
        Leaf(a) -> Just((0, a))
        Deep(_, dl, t, dr) -> {
            if (dl.size > index) then dl.lookup(index)
            elif (dl.size + t.size > index) then {
                match (t.lookup(index - dl.size)) {
                    Nothing -> Nothing
                    Just((cnt, m)) -> match (m.lookup(index - dl.size - cnt)) {
                        Nothing -> Nothing
                        Just((cnt', res)) -> Just((dl.size + cnt + cnt', res))
                    }
                }
            }
            else match (dr.lookup(index - dl.size - t.size)) {
                Nothing -> Nothing
                Just((cnt, res)) -> Just((cnt + dl.size + t.size, res))
            }
        }
    } 
}

private fun map(tree: tree<a>, f: a -> e b): e tree<b> {
    match (tree) {
        Empty -> Empty
        Leaf(x) -> Leaf(f(x))
        Deep(s, l, m, r) -> Deep(s, l.map(f), m.map(fn (x) { x.map(f) }), r.map(f))
    }
}

private fun reverse(tree: tree<a>, f: a -> e b): e tree<b> {
    match (tree) {
        Empty -> Empty
        Leaf(x) -> Leaf(f(x))
        Deep(s, l, m, r) -> Deep(s, r.reverse(f), m.reverse(fn (x) { x.reverse(f) }), l.reverse(f))
    }
}

public fun split(seq: seq<a>, index: int) : div (seq<a>, seq<a>) {
    if (seq.tree.is-empty)
    then (new(), new())
    elif (index <= 0)
    then (new(), seq)
    elif (seq.tree.size <= index)
    then (seq, new())
    else match (seq.tree.split'(index)) {
        Split (l, a, r) -> (Seq(l), Seq(r.cons'(a)))
        _ -> (new(), new())
    }
}

public fun at(seq: seq<a>, index: int) : div maybe<a> {
    if (seq.tree.is-empty)
    then Nothing
    elif (index < 0)
    then Nothing
    elif (seq.tree.size <= index)
    then Nothing
    else match (seq.tree.lookup(index)) {
        Just ((_, a)) -> Just (a.x)
        _ -> Nothing
    }
}

public fun show(seq: seq<int>): string {
    "<" + seq.list.show + ">"
}

public fun show(seq: seq<bool>): string {
    "<" + seq.list.show + ">"
}

public fun show(seq: seq<string>): string {
    "<" + seq.list.show + ">"
}

public fun map(seq: seq<a>, f: a -> e b): e seq<b> {
    Seq(seq.tree.map(fn (x) { x.map(f) } ))
}

public fun reverse(seq: seq<a>): seq<a> {
    Seq(seq.tree.reverse(id) )
}

public fun foldl(seq: seq<a>, init: b, f: (b, a) -> e b): e b {
    seq.tree.foldl(init, fn (acc, n) { f(acc, n.x) })
}

public fun foldr(seq: seq<a>, init: b, f: (a, b) -> e b): e b {
    seq.tree.foldr(init, fn (n, acc) { f(n.x, acc) })
}