#import "./theme/fcb.typ": *
#import "@preview/cades:0.3.1": qr-code
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#show: codly-init.with()
// #codly(zebra-fill: none)
#codly(number-format: none) // #codly(number-format: it => [#it])
#codly(languages: codly-languages)

#let background = white
#let foreground = navy
#let link-background = maroon // eastern
#let header-footer-foreground = maroon.lighten(50%)

#let hl(body) = {
  text(link-background)[#body]
}

#show: fcb-theme.with(
  aspect-ratio: "16-9", // "4-3",
  header: [],
  footer: [_Federico Bruzzone --- University of Milan_],
  background: background,
  foreground: foreground,
  link-background: link-background,
  header-footer-foreground: header-footer-foreground,
)

#let tiny-size = 0.4em
#let small-size = 0.7em
#let normal-size = 1em
#let large-size = 1.3em
#let huge-size = 1.6em

// #set text(font: "Fira Mono")
// #show raw: it => block(
//   inset: 8pt,
//   text(fill: foreground, font: "Fira Mono", it),
//   radius: 5pt,
//   fill: rgb("#1d2433"),
// )

#title-slide[
  = Matheuristic Variants of DSATUR for the Vertex Coloring Problem

  #toolbox.side-by-side(columns: (5fr, 1fr))[
    Federico Bruzzone, #footnote[
      ADAPT Lab -- Università degli Studi di Milano, \
      #h(1.5em) Website: #link("https://federicobruzzone.github.io/")[federicobruzzone.github.io], \
      #h(1.5em) Github: #link("https://github.com/FedericoBruzzone")[github.com/FedericoBruzzone], \
      #h(1.5em) Email: #link("mailto:federico.bruzzone@unimi.it")[federico.bruzzone\@unimi.it] \
      #h(1.5em) Slides: TODO
    ] PhD Candidate

    // Milan, Italy -- #datetime.today().display("[day] [month repr:long] [year repr:full]")
    Milan, Italy -- 4 December 2025
  ][
    #move(dy: 10pt, dx: -50pt)[
      #qr-code("TODO", width: 6cm, color: foreground)
    ]
  ]
]

#simple-slide[
  = Notation

  #v(2em)

  - $G = (V, E)$ is an undirected graph with vertex set $V = {v_1, ..., v_n}$ and edge set $E$, and denote $I = [|1;n|] = [1;n] inter ZZ$.

  - An edge $e = (v_i, v_j) in E$ with $i < j$ links the underlying vertices #hl[(_for *VCP* there is no sense to consider loop/multiple edges_)].

  - For $i in I$, $delta_i$ denotes the set of neighbors of vertex $v_i$, and $d_i = |delta_i| = {j in I | "ngb"(v_i, v_j) = 1}$, where $"ngb"(v_i, v_j) = 1 italic("iif") (v_i, v_j) in E$.#footnote[
    ngb stands for "neighbor".
  ]
]

#simple-slide[
  = A $k$-coloring of $G$

  #v(2em)

  - It is an assignment of colors to vertices such that no two adjacent vertices share the same color.

  - *VCP* consists in finding a $k$-coloring of $G$ using the minimum number of colors $k$ (the _chromatic number_ $chi(G)$).

  - A valid $k$-coloring $(c)$ fulfills: $forall i < j, (v_i, v_j) in E ==> c_i != c_j$ where $c_i = [|1;k|]$ is the color of $v_i$.

]

#simple-slide[
  = A partial $k$-coloring of $G$

  #v(1em)

  - If a vertex may not be colored, we set $c_i = -1 italic("s.t.") c_i in [|1;k|] union {-1}$

  - A partial $k$-coloring $(c)$ is _feasible_ if $forall i < j, (v_i, v_j) in E ==> c_i != c_j or c_i = c_j = -1$.

  - Given $v_i$ the #hl[saturation table] $S_i$ is the set of colors assigned to its colored neighbors: $S_i = union.big_(j in delta_i)^(n) {c_j} \\ {-1}$, and $s_i = |S_i|$ is the #hl[saturation degree].

  - A total order $eq.succ$ over $V$ is defined as: $v_i eq.succ v_j <==> s_i > s_j or (s_i = s_j and d_i >= d_j)$
]

#centered-slide[
  = Compact ILP Formulations #footnote[
      Efficient formulations: extended  column generation by Furini and Malaguti @Furini12, and reduced formulation to MWSSP by Cornaz et al. @Cornaz17.
    ], #text(small-size)[feasible _iif_ $chi(G) <= k$]

  #v(1em)

  #align(horizon)[
    #toolbox.side-by-side(columns: (15%, 50%, 30%))[
      #text(small-size)[
        $z_(i, c) in {0,1}$ indicates if vertex $v_i$ is assigned color $c$.

        $y_c in {0,1}$ indicates if color $c$ is used in the coloring.
      ]
    ][
    $
         & min attach(sum, t: k, b: c=1) y_c  \
    s.t. & min attach(sum, t: k, b: c=1) z_(i, c) = 1 & quad & forall i in I  \
         & z_(i,c) + z_(j,c) <= y_c                   & quad & forall (v_i, v_j) in E, \
         &                                            &      & forall c in [|1;k|]
         $
    ][
      #text(small-size)[
        #v(2em)

        The objective minimizes the number of used colors.

        #v(1em)

        The 1st set ensures that each vertex is assigned exactly one color.

        #v(1em)

        The 2nd set ensures that adjacent vertices do not share the same color.
      ]
    ]
  ]
]

#focus-slide[#text(small-size)[
  = Observations

  - Having an upper bound of the chromatic number as the initial value $k$ (or simply $k = |V|$) guarantees the optimality of the solution.

  - The size of $k$ strongly affects the performance of ILP solvers.

  - Symmetries in the model (e.g., colors are permutable) enlarge the search space for Branch-and-Bound algorithms #text(small-size)[(the same solution can be represented in multiple ways)]
]]


#centered-slide[
  = Representative ILP Model#footnote[A vertex is representative of its color class if it has the minimum index among the vertices sharing the same color.
  ],  #text(tiny-size)[asymmetric and easily to LP-relax]

  #v(1em)

  #align(horizon)[
    #toolbox.side-by-side(columns: (15%, 50%, 30%))[
      #text(small-size)[
        $x_(i, i') in {0,1}$, $forall i, i' in V s.t. i <= i'$, indicates if verticies $v_i$ and $v_i'$ share the same color and $i$ is the minimum index of its color class.
      ]
    ][
    $
         & min_z attach(sum, t: n, b: i=1) x_(i, i) \
    s.t. & attach(sum, b: i' <= i) x_(i', i) >= 1 & quad & forall i in I  \
         & x_(j, i) + x_(j, i') <= x_(j,j)                  & quad & forall (v_i, v_i') in E, \
         &                                                  &      & forall j <= i
    $
    ][
      #text(small-size)[
        The objective counts the number of representative vertices (i.e., used colors).

        The 1st set ensures either $x_(i, i) = 1$ or $v_i$ shares the color with a vertex $v_i'$ with $i' < i$.

        The 2nd set expresses the color incompatibility between adjacent vertices and $x_(j,i) = 1$ implies that $x_(j,j) = 1$
      ]
    ]
  ]
]

#simple-slide[
  ===== Standard DSATUR Algorithm

  #toolbox.side-by-side(columns: (70%, 30%))[
    #image("images/standard-dsatur.png") // , width: 70%)
  ][ #text(small-size)[
        - DSATUR is an #hl[adaptive greedy heuristic] proposed by Brélaz @Brelaz79, which colors vertices iteratively.

        - Selection of the uncolored verex to color is given with order $eq.succ$, maximizing first the saturation degree and secondly the degree.

        - Coloring a new vertex updates saturation, the iteration order of vertices is thus adaptive.
      ]
  ]
]

#focus-slide[
  = DASTUR Matheuristic Variants#footnote[#text(small-size)[N. Dupin, “Matheuristic Variants of DSATUR for the Vertex Coloring Problem,” in _Metaheuristics_ 2024 @Dupin24]]
]

#simple-slide[
  = Initialization

  Defining an initial partial coloring and computing the saturation table for the uncolored vertices, *before* starting the main DSATUR iterations.

  #text(small-size)[
  _Variants_:
  1. `maxDeg`: color the vertex with the maximum degree --- #hl[equivalent to standard DSATUR by definition of $eq.succ$], it would suffer from many ties;
  2. `col`-$n$: cosider $n$ vertices having the maximum degree and color them solving a representative ILP model for the _induced_ subgraph --- #hl[more depth pre-processing], it tries to prevent erroneous decisions in the initial steps of DSATUR;
  3. `clq`: find a maximum clique#footnote[It is NP-hard, an heuristic can be used.] and color it with different colors --- #hl[an exact pre-processing (not heuristic)], it leads to a better initial saturation table $S$ for the uncolored vertices;
  4. `clq-col`-$n$: combine `clq` and `col`-$n$ --- #hl[best of both worlds].
]]

#simple-slide[
  == Local Optimization with Larger Neighborhoods

  Let $(c)$ be a partial $k$-coloring, where $k$ is the number of colors used until now.

  - $C = {i in I | c_i > 0}$ is the set of colored vertices in $(c)$.
  - $U subset {i in I | c_i = -1}$ is a subset of uncolored vertices in $(c)$.

  We want to define an ILP formulation to #hl[assign] a color to each vertex $u in U$ while #hl[preserving] the colors of vertices in $C$.

  An *hybrid* formulation of #hl[assignment]-based and #hl[representative]-based formulations is used.
]

#simple-slide[
  = Matheuristic DSATUR Formulation

  #align(horizon)[
    #toolbox.side-by-side(columns: (70%, 30%))[
    $
                 & min_z attach(sum,  b: u in U) x_(u,u)  \
    s.t. #h(1em) & z_(i,l) + z_(i',l) <= 1                                                                & quad & forall (v_i, v_i') in E_U, \
                 &                                                                                        & quad & forall l in [|1;k|] \
                 & x_(u,i) + x_(u,i') <= x_(u,u)                                                          & quad & forall (v_i, v_i') in E_U, \
                 &                                                                                        & quad & forall u in U, u <= i \
                 & attach(sum,  b: i' in U : i' <= i) x_(i', i) + attach(sum,  b: l in K_u) z_(i, l) >= 1 & quad & forall u in U  \
    $
    ][
      #text(small-size)[
        #only(1)[
          - Binary variables $x_(u, u')$ are defined only for $u <= u' in U$, when considering $E_U = {(v_u, v_u')}_(u < u' in U) subset E$.

          - Binary variables $z_(u,l)$, to #hl[assign previous colors], are defined for $u in U$ and $l in [|1;k|]$ _s.t._ no neighbor $u$ has color $l$ in $(c)$ --- i.e., for all $u in U$ and $l in K_u$, where $K_u = {l in [|1;k|] | forall i in C, c_i = l ==> text("ngb")(i,j) = 0}$
        ]
        #only(2)[
          - It is #hl[assignment]-based for variables $z_(u,l)$, ensuring that vertices in $U$ are assigned either a previous color $l$ in $K_u$ or share the color with another vertex in $U$.

          - It is #hl[representative]-based for variables $x_(i,i')$, ensuring that vertices in $U$ sharing the same color have a representative vertex with the minimum index.
        ]
        #only(3)[
          - The 1st set ensures that adjacent vertices in $U$ do not share the same #hl[existing] color $l$.

          - The 2nd set ensures that two adjacent vertices in $U$ cannot share the same representative color.

          - The 3rd set ensures, $forall i in U$, that either it receives a #hl[previous] color $l$ in $K_u$ or it receives a #hl[new] color represented by another vertex $i'$ in $U$ with $i' <= i$.
        ]
      ]
    ]
  ]
]

#simple-slide[
  ===== Matheuristic DSATUR Algorithm


  #toolbox.side-by-side(columns: (63%, 30%))[
    #image("images/matheuristic-dsatur.png") // , width: 70%)
  ][ #text(small-size)[
        - TODO

        - TODO

        - TODO
      ]
  ]

]

#focus-slide[
  = Thank You!
]

// #hidden-bibliography(
#text(small-size)[
  #bibliography("local.bib")
]
// )
