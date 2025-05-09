::  /common/zose: vendored types from zuse
::  #  %zose
::
::    This library contains cryptographic primitives and utilities
::    vendored from zuse.hoon. It includes various cryptosuites,
::    number theory operations, and specific implementations like
::    AES and elliptic curve cryptography. Also includes translation
::    utilities for working with various formats.
::
/=  zeke  /common/zeke
~%  %zose  ..stark-engine-jet-hook:zeke  ~
|%
+|  %types
::
+$  octs  (pair @ud @)                                  ::  octet-stream
+$  desk  @tas
::
+|  %conversion
++  wrap  ^?
  |%
  ::  +as-octs: atom to octet-stream
  ::
  ++  as-octs
      |=  tam=@  ^-  octs
      [(met 3 tam) tam]
  ::  +as-octt: tape to octet-stream
  ::
  ++  as-octt
      |=  tep=tape  ^-  octs
      (as-octs (rap 3 tep))
  ++  base58
    |%
    ++  de  de-base58:zeke
    ++  en  en-base58:zeke
    --
  --
::
++  format  ^?
  |%
  ::
  ++  of-wall                                           ::  line list to tape
    |=  a=wall  ^-  tape
    ?~(a ~ "{i.a}\0a{$(a t.a)}")
  ::
  --
::
++  number  ^?
  |%
  ::                                                    ::  ++fu:number
  ++  fu                                                ::  modulo (mul p q)
    |=  a=[p=@ q=@]
    =+  b=?:(=([0 0] a) 0 (~(inv fo p.a) (~(sit fo p.a) q.a)))
    |%
    ::                                                  ::  ++dif:fu:number
    ++  dif                                             ::  subtract
      |=  [c=[@ @] d=[@ @]]
      [(~(dif fo p.a) -.c -.d) (~(dif fo q.a) +.c +.d)]
    ::                                                  ::  ++exp:fu:number
    ++  exp                                             ::  exponent
      |=  [c=@ d=[@ @]]
      :-  (~(exp fo p.a) (mod c (dec p.a)) -.d)
      (~(exp fo q.a) (mod c (dec q.a)) +.d)
    ::                                                  ::  ++out:fu:number
    ++  out                                             ::  garner's formula
      |=  c=[@ @]
      %+  add  +.c
      %+  mul  q.a
      %+  ~(pro fo p.a)  b
      (~(dif fo p.a) -.c (~(sit fo p.a) +.c))
    ::                                                  ::  ++pro:fu:number
    ++  pro                                             ::  multiply
      |=  [c=[@ @] d=[@ @]]
      [(~(pro fo p.a) -.c -.d) (~(pro fo q.a) +.c +.d)]
    ::                                                  ::  ++sum:fu:number
    ++  sum                                             ::  add
      |=  [c=[@ @] d=[@ @]]
      [(~(sum fo p.a) -.c -.d) (~(sum fo q.a) +.c +.d)]
    ::                                                  ::  ++sit:fu:number
    ++  sit                                             ::  represent
      |=  c=@
      [(mod c p.a) (mod c q.a)]
    --  ::fu
  ::                                                    ::  ++curt:number
  ++  curt                                              ::  curve25519
    |=  [a=@ b=@]
    =>  %=    .
            +
          =>  +
          =+  =+  [p=486.662 q=(sub (bex 255) 19)]
              =+  fq=~(. fo q)
              [p=p q=q fq=fq]
          |%
          ::                                            ::  ++cla:curt:number
          ++  cla                                       ::
            |=  raw=@
            =+  low=(dis 248 (cut 3 [0 1] raw))
            =+  hih=(con 64 (dis 127 (cut 3 [31 1] raw)))
            =+  mid=(cut 3 [1 30] raw)
            (can 3 [[1 low] [30 mid] [1 hih] ~])
          ::                                            ::  ++sqr:curt:number
          ++  sqr                                       ::
            |=(a=@ (mul a a))
          ::                                            ::  ++inv:curt:number
          ++  inv                                       ::
            |=(a=@ (~(exp fo q) (sub q 2) a))
          ::                                            ::  ++cad:curt:number
          ++  cad                                       ::
            |=  [n=[x=@ z=@] m=[x=@ z=@] d=[x=@ z=@]]
            =+  ^=  xx
                ;:  mul  4  z.d
                  %-  sqr  %-  abs:si
                  %+  dif:si
                    (sun:si (mul x.m x.n))
                  (sun:si (mul z.m z.n))
                ==
            =+  ^=  zz
                ;:  mul  4  x.d
                  %-  sqr  %-  abs:si
                  %+  dif:si
                    (sun:si (mul x.m z.n))
                  (sun:si (mul z.m x.n))
                ==
            [(sit.fq xx) (sit.fq zz)]
          ::                                            ::  ++cub:curt:number
          ++  cub                                       ::
            |=  [x=@ z=@]
            =+  ^=  xx
                %+  mul
                  %-  sqr  %-  abs:si
                  (dif:si (sun:si x) (sun:si z))
                (sqr (add x z))
            =+  ^=  zz
                ;:  mul  4  x  z
                  :(add (sqr x) :(mul p x z) (sqr z))
                ==
            [(sit.fq xx) (sit.fq zz)]
          --  ::
        ==
    =+  one=[b 1]
    =+  i=253
    =+  r=one
    =+  s=(cub one)
    |-
    ?:  =(i 0)
      =+  x=(cub r)
      (sit.fq (mul -.x (inv +.x)))
    =+  m=(rsh [0 i] a)
    ?:  =(0 (mod m 2))
       $(i (dec i), s (cad r s one), r (cub r))
    $(i (dec i), r (cad r s one), s (cub s))
  ::                                                    ::  ++ga:number
  ++  ga                                                ::  GF (bex p.a)
    |=  a=[p=@ q=@ r=@]                                 ::  dim poly gen
    =+  si=(bex p.a)
    =+  ma=(dec si)
    =>  |%
        ::                                              ::  ++dif:ga:number
        ++  dif                                         ::  add and sub
          |=  [b=@ c=@]
          ~|  [%dif-ga a]
          ?>  &((lth b si) (lth c si))
          (mix b c)
        ::                                              ::  ++dub:ga:number
        ++  dub                                         ::  mul by x
          |=  b=@
          ~|  [%dub-ga a]
          ?>  (lth b si)
          ?:  =(1 (cut 0 [(dec p.a) 1] b))
            (dif (sit q.a) (sit (lsh 0 b)))
          (lsh 0 b)
        ::                                              ::  ++pro:ga:number
        ++  pro                                         ::  slow multiply
          |=  [b=@ c=@]
          ?:  =(0 b)
            0
          ?:  =(1 (dis 1 b))
            (dif c $(b (rsh 0 b), c (dub c)))
          $(b (rsh 0 b), c (dub c))
        ::                                              ::  ++toe:ga:number
        ++  toe                                         ::  exp+log tables
          =+  ^=  nu
              |=  [b=@ c=@]
              ^-  (map @ @)
              =+  d=*(map @ @)
              |-
              ?:  =(0 c)
                d
              %=  $
                c  (dec c)
                d  (~(put by d) c b)
              ==
          =+  [p=(nu 0 (bex p.a)) q=(nu ma ma)]
          =+  [b=1 c=0]
          |-  ^-  [p=(map @ @) q=(map @ @)]
          ?:  =(ma c)
            [(~(put by p) c b) q]
          %=  $
            b  (pro r.a b)
            c  +(c)
            p  (~(put by p) c b)
            q  (~(put by q) b c)
          ==
        ::                                              ::  ++sit:ga:number
        ++  sit                                         ::  reduce
          |=  b=@
          (mod b (bex p.a))
        --  ::
    =+  toe
    |%
    ::                                                  ::  ++fra:ga:number
    ++  fra                                             ::  divide
      |=  [b=@ c=@]
      (pro b (inv c))
    ::                                                  ::  ++inv:ga:number
    ++  inv                                             ::  invert
      |=  b=@
      ~|  [%inv-ga a]
      =+  c=(~(get by q) b)
      ?~  c  !!
      =+  d=(~(get by p) (sub ma u.c))
      (need d)
    ::                                                  ::  ++pow:ga:number
    ++  pow                                             ::  exponent
      |=  [b=@ c=@]
      =+  [d=1 e=c f=0]
      |-
      ?:  =(p.a f)
        d
      ?:  =(1 (cut 0 [f 1] b))
        $(d (pro d e), e (pro e e), f +(f))
      $(e (pro e e), f +(f))
    ::                                                  ::  ++pro:ga:number
    ++  pro                                             ::  multiply
      |=  [b=@ c=@]
      ~|  [%pro-ga a]
      =+  d=(~(get by q) b)
      ?~  d  0
      =+  e=(~(get by q) c)
      ?~  e  0
      =+  f=(~(get by p) (mod (add u.d u.e) ma))
      (need f)
    -- ::ga
  -- ::number
+|  %crypto
::
++  crypto  ^?
  |%
  ::                                                    ::
  ::::                    ++aes:crypto                  ::  (2b1) aes, all sizes
    ::                                                  ::::
  ++  aes    !.
    |%
    ::                                                  ::  ++ahem:aes:crypto
    ++  ahem                                            ::  kernel state
      |=  [nnk=@ nnb=@ nnr=@]
      =>
        =+  =>  [gr=(ga:number 8 0x11b 3) few==>(fe .(a 5))]
            [pro=pro.gr dif=dif.gr pow=pow.gr ror=ror.few]
        =>  |%                                          ::
            ++  cipa  $_  ^?                            ::  AES params
              |%
              ++  co  *[p=@ q=@ r=@ s=@]                ::  column coefficients
              ++  ix  |~(a=@ *@)                        ::  key index
              ++  ro  *[p=@ q=@ r=@ s=@]                ::  row shifts
              ++  su  *@                                ::  s-box
              --  ::cipa
            --  ::
        |%
        ::                                              ::  ++pen:ahem:aes:
        ++  pen                                         ::  encrypt
          ^-  cipa
          |%
          ::                                            ::  ++co:pen:ahem:aes:
          ++  co                                        ::  column coefficients
            [0x2 0x3 1 1]
          ::                                            ::  ++ix:pen:ahem:aes:
          ++  ix                                        ::  key index
            |~(a=@ a)
          ::                                            ::  ++ro:pen:ahem:aes:
          ++  ro                                        ::  row shifts
            [0 1 2 3]
          ::                                            ::  ++su:pen:ahem:aes:
          ++  su                                        ::  s-box
            0x16bb.54b0.0f2d.9941.6842.e6bf.0d89.a18c.
              df28.55ce.e987.1e9b.948e.d969.1198.f8e1.
              9e1d.c186.b957.3561.0ef6.0348.66b5.3e70.
              8a8b.bd4b.1f74.dde8.c6b4.a61c.2e25.78ba.
              08ae.7a65.eaf4.566c.a94e.d58d.6d37.c8e7.
              79e4.9591.62ac.d3c2.5c24.0649.0a3a.32e0.
              db0b.5ede.14b8.ee46.8890.2a22.dc4f.8160.
              7319.5d64.3d7e.a7c4.1744.975f.ec13.0ccd.
              d2f3.ff10.21da.b6bc.f538.9d92.8f40.a351.
              a89f.3c50.7f02.f945.8533.4d43.fbaa.efd0.
              cf58.4c4a.39be.cb6a.5bb1.fc20.ed00.d153.
              842f.e329.b3d6.3b52.a05a.6e1b.1a2c.8309.
              75b2.27eb.e280.1207.9a05.9618.c323.c704.
              1531.d871.f1e5.a534.ccf7.3f36.2693.fdb7.
              c072.a49c.afa2.d4ad.f047.59fa.7dc9.82ca.
              76ab.d7fe.2b67.0130.c56f.6bf2.7b77.7c63
          --
        ::                                              ::  ++pin:ahem:aes:
        ++  pin                                         ::  decrypt
          ^-  cipa
          |%
          ::                                            ::  ++co:pin:ahem:aes:
          ++  co                                        ::  column coefficients
            [0xe 0xb 0xd 0x9]
          ::                                            ::  ++ix:pin:ahem:aes:
          ++  ix                                        ::  key index
            |~(a=@ (sub nnr a))
          ::                                            ::  ++ro:pin:ahem:aes:
          ++  ro                                        ::  row shifts
            [0 3 2 1]
          ::                                            ::  ++su:pin:ahem:aes:
          ++  su                                        ::  s-box
            0x7d0c.2155.6314.69e1.26d6.77ba.7e04.2b17.
              6199.5383.3cbb.ebc8.b0f5.2aae.4d3b.e0a0.
              ef9c.c993.9f7a.e52d.0d4a.b519.a97f.5160.
              5fec.8027.5910.12b1.31c7.0788.33a8.dd1f.
              f45a.cd78.fec0.db9a.2079.d2c6.4b3e.56fc.
              1bbe.18aa.0e62.b76f.89c5.291d.711a.f147.
              6edf.751c.e837.f9e2.8535.ade7.2274.ac96.
              73e6.b4f0.cecf.f297.eadc.674f.4111.913a.
              6b8a.1301.03bd.afc1.020f.3fca.8f1e.2cd0.
              0645.b3b8.0558.e4f7.0ad3.bc8c.00ab.d890.
              849d.8da7.5746.155e.dab9.edfd.5048.706c.
              92b6.655d.cc5c.a4d4.1698.6886.64f6.f872.
              25d1.8b6d.49a2.5b76.b224.d928.66a1.2e08.
              4ec3.fa42.0b95.4cee.3d23.c2a6.3294.7b54.
              cbe9.dec4.4443.8e34.87ff.2f9b.8239.e37c.
              fbd7.f381.9ea3.40bf.38a5.3630.d56a.0952
          --
        ::                                              ::  ++mcol:ahem:aes:
        ++  mcol                                        ::
          |=  [a=(list @) b=[p=@ q=@ r=@ s=@]]
          ^-  (list @)
          =+  c=[p=*@ q=*@ r=*@ s=*@]
          |-  ^-  (list @)
          ?~  a  ~
          =>  .(p.c (cut 3 [0 1] i.a))
          =>  .(q.c (cut 3 [1 1] i.a))
          =>  .(r.c (cut 3 [2 1] i.a))
          =>  .(s.c (cut 3 [3 1] i.a))
          :_  $(a t.a)
          %+  rep  3
          %+  turn
            %-  limo
            :~  [[p.c p.b] [q.c q.b] [r.c r.b] [s.c s.b]]
                [[p.c s.b] [q.c p.b] [r.c q.b] [s.c r.b]]
                [[p.c r.b] [q.c s.b] [r.c p.b] [s.c q.b]]
                [[p.c q.b] [q.c r.b] [r.c s.b] [s.c p.b]]
            ==
          |=  [a=[@ @] b=[@ @] c=[@ @] d=[@ @]]
          :(dif (pro a) (pro b) (pro c) (pro d))
        ::                                              ::  ++pode:ahem:aes:
        ++  pode                                        ::  explode to block
          |=  [a=bloq b=@ c=@]  ^-  (list @)
          =+  d=(rip a c)
          =+  m=(met a c)
          |-
          ?:  =(m b)
            d
          $(m +(m), d (weld d (limo [0 ~])))
        ::                                              ::  ++sube:ahem:aes:
        ++  sube                                        ::  s-box word
          |=  [a=@ b=@]  ^-  @
          (rep 3 (turn (pode 3 4 a) |=(c=@ (cut 3 [c 1] b))))
        --  ::
      |%
      ::                                                ::  ++be:ahem:aes:crypto
      ++  be                                            ::  block cipher
        |=  [a=? b=@ c=@H]  ^-  @uxH
        ~|  %be-aesc
        =>  %=    .
                +
              =>  +
              |%
              ::                                        ::  ++ankh:be:ahem:aes:
              ++  ankh                                  ::
                |=  [a=cipa b=@ c=@]
                (pode 5 nnb (cut 5 [(mul (ix.a b) nnb) nnb] c))
              ::                                        ::  ++sark:be:ahem:aes:
              ++  sark                                  ::
                |=  [c=(list @) d=(list @)]
                ^-  (list @)
                ?~  c  ~
                ?~  d  !!
                [(mix i.c i.d) $(c t.c, d t.d)]
              ::                                        ::  ++srow:be:ahem:aes:
              ++  srow                                  ::
                |=  [a=cipa b=(list @)]  ^-  (list @)
                =+  [c=0 d=~ e=ro.a]
                |-
                ?:  =(c nnb)
                  d
                :_  $(c +(c))
                %+  rep  3
                %+  turn
                  (limo [0 p.e] [1 q.e] [2 r.e] [3 s.e] ~)
                |=  [f=@ g=@]
                (cut 3 [f 1] (snag (mod (add g c) nnb) b))
              ::                                        ::  ++subs:be:ahem:aes:
              ++  subs                                  ::
                |=  [a=cipa b=(list @)]  ^-  (list @)
                ?~  b  ~
                [(sube i.b su.a) $(b t.b)]
              --
            ==
        =+  [d=?:(a pen pin) e=(pode 5 nnb c) f=1]
        =>  .(e (sark e (ankh d 0 b)))
        |-
        ?.  =(nnr f)
          =>  .(e (subs d e))
          =>  .(e (srow d e))
          =>  .(e (mcol e co.d))
          =>  .(e (sark e (ankh d f b)))
          $(f +(f))
        =>  .(e (subs d e))
        =>  .(e (srow d e))
        =>  .(e (sark e (ankh d nnr b)))
        (rep 5 e)
      ::                                                ::  ++ex:ahem:aes:crypto
      ++  ex                                            ::  key expand
        |=  a=@I  ^-  @
        =+  [b=a c=0 d=su:pen i=nnk]
        |-
        ?:  =(i (mul nnb +(nnr)))
          b
        =>  .(c (cut 5 [(dec i) 1] b))
        =>  ?:  =(0 (mod i nnk))
              =>  .(c (ror 3 1 c))
              =>  .(c (sube c d))
              .(c (mix c (pow (dec (div i nnk)) 2)))
            ?:  &((gth nnk 6) =(4 (mod i nnk)))
              .(c (sube c d))
            .
        =>  .(c (mix c (cut 5 [(sub i nnk) 1] b)))
        =>  .(b (can 5 [i b] [1 c] ~))
        $(i +(i))
      ::                                                ::  ++ix:ahem:aes:crypto
      ++  ix                                            ::  key expand, inv
        |=  a=@  ^-  @
        =+  [i=1 j=*@ b=*@ c=co:pin]
        |-
        ?:  =(nnr i)
          a
        =>  .(b (cut 7 [i 1] a))
        =>  .(b (rep 5 (mcol (pode 5 4 b) c)))
        =>  .(j (sub nnr i))
        %=    $
            i  +(i)
            a
          %+  can  7
          :~  [i (cut 7 [0 i] a)]
              [1 b]
              [j (cut 7 [+(i) j] a)]
          ==
        ==
      --
    ::                                                  ::  ++ecba:aes:crypto
    ++  ecba                                            ::  AES-128 ECB
      ~%  %ecba  +>  ~
      |_  key=@H
      ::                                                ::  ++en:ecba:aes:crypto
      ++  en                                            ::  encrypt
        ~/  %en
        |=  blk=@H  ^-  @uxH
        =+  (ahem 4 4 10)
        =:
          key  (~(net fe 7) key)
          blk  (~(net fe 7) blk)
        ==
        %-  ~(net fe 7)
        (be & (ex key) blk)
      ::                                                ::  ++de:ecba:aes:crypto
      ++  de                                            ::  decrypt
        ~/  %de
        |=  blk=@H  ^-  @uxH
        =+  (ahem 4 4 10)
        =:
          key  (~(net fe 7) key)
          blk  (~(net fe 7) blk)
        ==
        %-  ~(net fe 7)
        (be | (ix (ex key)) blk)
      --  ::ecba
    ::                                                  ::  ++ecbb:aes:crypto
    ++  ecbb                                            ::  AES-192 ECB
      ~%  %ecbb  +>  ~
      |_  key=@I
      ::                                                ::  ++en:ecbb:aes:crypto
      ++  en                                            ::  encrypt
        ~/  %en
        |=  blk=@H  ^-  @uxH
        =+  (ahem 6 4 12)
        =:
          key  (rsh 6 (~(net fe 8) key))
          blk  (~(net fe 7) blk)
        ==
        %-  ~(net fe 7)
        (be & (ex key) blk)
      ::                                                ::  ++de:ecbb:aes:crypto
      ++  de                                            ::  decrypt
        ~/  %de
        |=  blk=@H  ^-  @uxH
        =+  (ahem 6 4 12)
        =:
          key  (rsh 6 (~(net fe 8) key))
          blk  (~(net fe 7) blk)
        ==
        %-  ~(net fe 7)
        (be | (ix (ex key)) blk)
      --  ::ecbb
    ::                                                  ::  ++ecbc:aes:crypto
    ++  ecbc                                            ::  AES-256 ECB
      ~%  %ecbc  +>  ~
      |_  key=@I
      ::                                                ::  ++en:ecbc:aes:crypto
      ++  en                                            ::  encrypt
        ~/  %en
        |=  blk=@H  ^-  @uxH
        =+  (ahem 8 4 14)
        =:
          key  (~(net fe 8) key)
          blk  (~(net fe 7) blk)
        ==
        %-  ~(net fe 7)
        (be & (ex key) blk)
      ::                                                ::  ++de:ecbc:aes:crypto
      ++  de                                            ::  decrypt
        ~/  %de
        |=  blk=@H  ^-  @uxH
        =+  (ahem 8 4 14)
        =:
          key  (~(net fe 8) key)
          blk  (~(net fe 7) blk)
        ==
        %-  ~(net fe 7)
        (be | (ix (ex key)) blk)
      --  ::ecbc
    ::                                                  ::  ++cbca:aes:crypto
    ++  cbca                                            ::  AES-128 CBC
      ~%  %cbca  +>  ~
      |_  [key=@H prv=@H]
      ::                                                ::  ++en:cbca:aes:crypto
      ++  en                                            ::  encrypt
        ~/  %en
        |=  txt=@  ^-  @ux
        =+  pts=?:(=(txt 0) `(list @)`~[0] (flop (rip 7 txt)))
        =|  cts=(list @)
        %+  rep  7
        ::  logically, flop twice here
        |-  ^-  (list @)
        ?~  pts
          cts
        =+  cph=(~(en ecba key) (mix prv i.pts))
        %=  $
          cts  [cph cts]
          pts  t.pts
          prv  cph
        ==
      ::                                                ::  ++de:cbca:aes:crypto
      ++  de                                            ::  decrypt
        ~/  %de
        |=  txt=@  ^-  @ux
        =+  cts=?:(=(txt 0) `(list @)`~[0] (flop (rip 7 txt)))
        =|  pts=(list @)
        %+  rep  7
        ::  logically, flop twice here
        |-  ^-  (list @)
        ?~  cts
          pts
        =+  pln=(mix prv (~(de ecba key) i.cts))
        %=  $
          pts  [pln pts]
          cts  t.cts
          prv  i.cts
        ==
      --  ::cbca
    ::                                                  ::  ++cbcb:aes:crypto
    ++  cbcb                                            ::  AES-192 CBC
      ~%  %cbcb  +>  ~
      |_  [key=@I prv=@H]
      ::                                                ::  ++en:cbcb:aes:crypto
      ++  en                                            ::  encrypt
        ~/  %en
        |=  txt=@  ^-  @ux
        =+  pts=?:(=(txt 0) `(list @)`~[0] (flop (rip 7 txt)))
        =|  cts=(list @)
        %+  rep  7
        ::  logically, flop twice here
        |-  ^-  (list @)
        ?~  pts
          cts
        =+  cph=(~(en ecbb key) (mix prv i.pts))
        %=  $
          cts  [cph cts]
          pts  t.pts
          prv  cph
        ==
      ::                                                ::  ++de:cbcb:aes:crypto
      ++  de                                            ::  decrypt
        ~/  %de
        |=  txt=@  ^-  @ux
        =+  cts=?:(=(txt 0) `(list @)`~[0] (flop (rip 7 txt)))
        =|  pts=(list @)
        %+  rep  7
        ::  logically, flop twice here
        |-  ^-  (list @)
        ?~  cts
          pts
        =+  pln=(mix prv (~(de ecbb key) i.cts))
        %=  $
          pts  [pln pts]
          cts  t.cts
          prv  i.cts
        ==
      --  ::cbcb
    ::                                                  ::  ++cbcc:aes:crypto
    ++  cbcc                                            ::  AES-256 CBC
      ~%  %cbcc  +>  ~
      |_  [key=@I prv=@H]
      ::                                                ::  ++en:cbcc:aes:crypto
      ++  en                                            ::  encrypt
        ~/  %en
        |=  txt=@  ^-  @ux
        =+  pts=?:(=(txt 0) `(list @)`~[0] (flop (rip 7 txt)))
        =|  cts=(list @)
        %+  rep  7
        ::  logically, flop twice here
        |-  ^-  (list @)
        ?~  pts
          cts
        =+  cph=(~(en ecbc key) (mix prv i.pts))
        %=  $
          cts  [cph cts]
          pts  t.pts
          prv  cph
        ==
      ::                                                ::  ++de:cbcc:aes:crypto
      ++  de                                            ::  decrypt
        ~/  %de
        |=  txt=@  ^-  @ux
        =+  cts=?:(=(txt 0) `(list @)`~[0] (flop (rip 7 txt)))
        =|  pts=(list @)
        %+  rep  7
        ::  logically, flop twice here
        |-  ^-  (list @)
        ?~  cts
          pts
        =+  pln=(mix prv (~(de ecbc key) i.cts))
        %=  $
          pts  [pln pts]
          cts  t.cts
          prv  i.cts
        ==
      --  ::cbcc
    ::                                                  ::  ++inc:aes:crypto
    ++  inc                                             ::  inc. low bloq
      |=  [mod=bloq ctr=@H]
      ^-  @uxH
      =+  bqs=(rip mod ctr)
      ?~  bqs  0x1
      %+  rep  mod
      [(~(sum fe mod) i.bqs 1) t.bqs]
    ::                                                  ::  ++ctra:aes:crypto
    ++  ctra                                            ::  AES-128 CTR
      ~%  %ctra  +>  ~
      |_  [key=@H mod=bloq len=@ ctr=@H]
      ::                                                ::  ++en:ctra:aes:crypto
      ++  en                                            ::  encrypt
        ~/  %en
        |=  txt=@
        ^-  @ux
        =/  encrypt  ~(en ecba key)
        =/  blocks  (add (div len 16) ?:(=((^mod len 16) 0) 0 1))
        ?>  (gte len (met 3 txt))
        %+  mix  txt
        %+  rsh  [3 (sub (mul 16 blocks) len)]
        %+  rep  7
        =|  seed=(list @ux)
        |-  ^+  seed
        ?:  =(blocks 0)  seed
        %=  $
          seed    [(encrypt ctr) seed]
          ctr     (inc mod ctr)
          blocks  (dec blocks)
        ==
      ::                                                ::  ++de:ctra:aes:crypto
      ++  de                                            ::  decrypt
        en
      --  ::ctra
    ::                                                  ::  ++ctrb:aes:crypto
    ++  ctrb                                            ::  AES-192 CTR
      ~%  %ctrb  +>  ~
      |_  [key=@I mod=bloq len=@ ctr=@H]
      ::                                                ::  ++en:ctrb:aes:crypto
      ++  en
        ~/  %en
        |=  txt=@
        ^-  @ux
        =/  encrypt  ~(en ecbb key)
        =/  blocks  (add (div len 16) ?:(=((^mod len 16) 0) 0 1))
        ?>  (gte len (met 3 txt))
        %+  mix  txt
        %+  rsh  [3 (sub (mul 16 blocks) len)]
        %+  rep  7
        =|  seed=(list @ux)
        |-  ^+  seed
        ?:  =(blocks 0)  seed
        %=  $
          seed    [(encrypt ctr) seed]
          ctr     (inc mod ctr)
          blocks  (dec blocks)
        ==
      ::                                                ::  ++de:ctrb:aes:crypto
      ++  de                                            ::  decrypt
        en
      --  ::ctrb
    ::                                                  ::  ++ctrc:aes:crypto
    ++  ctrc                                            ::  AES-256 CTR
      ~%  %ctrc  +>  ~
      |_  [key=@I mod=bloq len=@ ctr=@H]
      ::                                                ::  ++en:ctrc:aes:crypto
      ++  en                                            ::  encrypt
        ~/  %en
        |=  txt=@
        ^-  @ux
        =/  encrypt  ~(en ecbc key)
        =/  blocks  (add (div len 16) ?:(=((^mod len 16) 0) 0 1))
        ?>  (gte len (met 3 txt))
        %+  mix  txt
        %+  rsh  [3 (sub (mul 16 blocks) len)]
        %+  rep  7
        =|  seed=(list @ux)
        |-  ^+  seed
        ?:  =(blocks 0)  seed
        %=  $
          seed    [(encrypt ctr) seed]
          ctr     (inc mod ctr)
          blocks  (dec blocks)
        ==
      ::                                                ::  ++de:ctrc:aes:crypto
      ++  de                                            ::  decrypt
        en
      --  ::ctrc
    ::                                                  ::  ++doub:aes:crypto
    ++  doub                                            ::  double 128-bit
      |=  ::  string mod finite
          ::
          str=@H
      ::
      ::  field (see spec)
      ::
      ^-  @uxH
      %-  ~(sit fe 7)
      ?.  =((xeb str) 128)
        (lsh 0 str)
      (mix 0x87 (lsh 0 str))
    ::                                                  ::  ++mpad:aes:crypto
    ++  mpad                                            ::
      |=  [oct=@ txt=@]
      ::
      ::  pad message to multiple of 128 bits
      ::  by appending 1, then 0s
      ::  the spec is unclear, but it must be octet based
      ::  to match the test vectors
      ::
      ^-  @ux
      =+  pad=(mod oct 16)
      ?:  =(pad 0)  0x8000.0000.0000.0000.0000.0000.0000.0000
      (lsh [3 (sub 15 pad)] (mix 0x80 (lsh 3 txt)))
    ::                                                  ::  ++suba:aes:crypto
    ++  suba                                            ::  AES-128 subkeys
      |=  key=@H
      =+  l=(~(en ecba key) 0)
      =+  k1=(doub l)
      =+  k2=(doub k1)
      ^-  [@ux @ux]
      [k1 k2]
    ::                                                  ::  ++subb:aes:crypto
    ++  subb                                            ::  AES-192 subkeys
      |=  key=@I
      =+  l=(~(en ecbb key) 0)
      =+  k1=(doub l)
      =+  k2=(doub k1)
      ^-  [@ux @ux]
      [k1 k2]
    ::                                                  ::  ++subc:aes:crypto
    ++  subc                                            ::  AES-256 subkeys
      |=  key=@I
      =+  l=(~(en ecbc key) 0)
      =+  k1=(doub l)
      =+  k2=(doub k1)
      ^-  [@ux @ux]
      [k1 k2]
    ::                                                  ::  ++maca:aes:crypto
    ++  maca                                            ::  AES-128 CMAC
      ~/  %maca
      |=  [key=@H oct=(unit @) txt=@]
      ^-  @ux
      =+  [sub=(suba key) len=?~(oct (met 3 txt) u.oct)]
      =+  ^=  pdt
        ?:  &(=((mod len 16) 0) !=(len 0))
          [& txt]
        [| (mpad len txt)]
      =+  ^=  mac
        %-  ~(en cbca key 0)
        %+  mix  +.pdt
        ?-  -.pdt
          %&  -.sub
          %|  +.sub
        ==
      ::  spec says MSBs, LSBs match test vectors
      ::
      (~(sit fe 7) mac)
    ::                                                  ::  ++macb:aes:crypto
    ++  macb                                            ::  AES-192 CMAC
      ~/  %macb
      |=  [key=@I oct=(unit @) txt=@]
      ^-  @ux
      =+  [sub=(subb key) len=?~(oct (met 3 txt) u.oct)]
      =+  ^=  pdt
        ?:  &(=((mod len 16) 0) !=(len 0))
          [& txt]
        [| (mpad len txt)]
      =+  ^=  mac
        %-  ~(en cbcb key 0)
        %+  mix  +.pdt
        ?-  -.pdt
          %&  -.sub
          %|  +.sub
        ==
      ::  spec says MSBs, LSBs match test vectors
      ::
      (~(sit fe 7) mac)
    ::                                                  ::  ++macc:aes:crypto
    ++  macc                                            :: AES-256 CMAC
      ~/  %macc
      |=  [key=@I oct=(unit @) txt=@]
      ^-  @ux
      =+  [sub=(subc key) len=?~(oct (met 3 txt) u.oct)]
      =+  ^=  pdt
        ?:  &(=((mod len 16) 0) !=(len 0))
          [& txt]
        [| (mpad len txt)]
      =+  ^=  mac
        %-  ~(en cbcc key 0)
        %+  mix  +.pdt
        ?-  -.pdt
          %&  -.sub
          %|  +.sub
        ==
      ::  spec says MSBs, LSBs match test vectors
      ::
      (~(sit fe 7) mac)
    ::                                                  ::  ++s2va:aes:crypto
    ++  s2va                                            ::  AES-128 S2V
      ~/  %s2va
      |=  [key=@H ads=(list @)]
      ?~  ads  (maca key `16 0x1)
      =/  res  (maca key `16 0x0)
      %+  maca  key
      |-  ^-  [[~ @ud] @uxH]
      ?~  t.ads
        =/  wyt  (met 3 i.ads)
        ?:  (gte wyt 16)
          [`wyt (mix i.ads res)]
        [`16 (mix (doub res) (mpad wyt i.ads))]
      %=  $
        ads  t.ads
        res  (mix (doub res) (maca key ~ i.ads))
      ==
    ::                                                  ::  ++s2vb:aes:crypto
    ++  s2vb                                            ::  AES-192 S2V
      ~/  %s2vb
      |=  [key=@I ads=(list @)]
      ?~  ads  (macb key `16 0x1)
      =/  res  (macb key `16 0x0)
      %+  macb  key
      |-  ^-  [[~ @ud] @uxH]
      ?~  t.ads
        =/  wyt  (met 3 i.ads)
        ?:  (gte wyt 16)
          [`wyt (mix i.ads res)]
        [`16 (mix (doub res) (mpad wyt i.ads))]
      %=  $
        ads  t.ads
        res  (mix (doub res) (macb key ~ i.ads))
      ==
    ::                                                  ::  ++s2vc:aes:crypto
    ++  s2vc                                            ::  AES-256 S2V
      ~/  %s2vc
      |=  [key=@I ads=(list @)]
      ?~  ads  (macc key `16 0x1)
      =/  res  (macc key `16 0x0)
      %+  macc  key
      |-  ^-  [[~ @ud] @uxH]
      ?~  t.ads
        =/  wyt  (met 3 i.ads)
        ?:  (gte wyt 16)
          [`wyt (mix i.ads res)]
        [`16 (mix (doub res) (mpad wyt i.ads))]
      %=  $
        ads  t.ads
        res  (mix (doub res) (macc key ~ i.ads))
      ==
    ::                                                  ::  ++siva:aes:crypto
    ++  siva                                            ::  AES-128 SIV
      ~%  %siva  +>  ~
      |_  [key=@I vec=(list @)]
      ::                                                ::  ++en:siva:aes:crypto
      ++  en                                            ::  encrypt
        ~/  %en
        |=  txt=@
        ^-  (trel @uxH @ud @ux)
        =+  [k1=(rsh 7 key) k2=(end 7 key)]
        =+  iv=(s2va k1 (weld vec (limo ~[txt])))
        =+  len=(met 3 txt)
        =*  hib  (dis iv 0xffff.ffff.ffff.ffff.7fff.ffff.7fff.ffff)
        :+
          iv
          len
        (~(en ctra k2 7 len hib) txt)
      ::                                                ::  ++de:siva:aes:crypto
      ++  de                                            ::  decrypt
        ~/  %de
        |=  [iv=@H len=@ txt=@]
        ^-  (unit @ux)
        =+  [k1=(rsh 7 key) k2=(end 7 key)]
        =*  hib  (dis iv 0xffff.ffff.ffff.ffff.7fff.ffff.7fff.ffff)
        =+  ^=  pln
          (~(de ctra k2 7 len hib) txt)
        ?.  =((s2va k1 (weld vec (limo ~[pln]))) iv)
          ~
        `pln
      --  ::siva
    ::                                                  ::  ++sivb:aes:crypto
    ++  sivb                                            ::  AES-192 SIV
      ~%  %sivb  +>  ~
      |_  [key=@J vec=(list @)]
      ::                                                ::  ++en:sivb:aes:crypto
      ++  en                                            ::  encrypt
        ~/  %en
        |=  txt=@
        ^-  (trel @uxH @ud @ux)
        =+  [k1=(rsh [6 3] key) k2=(end [6 3] key)]
        =+  iv=(s2vb k1 (weld vec (limo ~[txt])))
        =*  hib  (dis iv 0xffff.ffff.ffff.ffff.7fff.ffff.7fff.ffff)
        =+  len=(met 3 txt)
        :+  iv
          len
        (~(en ctrb k2 7 len hib) txt)
      ::                                                ::  ++de:sivb:aes:crypto
      ++  de                                            ::  decrypt
        ~/  %de
        |=  [iv=@H len=@ txt=@]
        ^-  (unit @ux)
        =+  [k1=(rsh [6 3] key) k2=(end [6 3] key)]
        =*  hib  (dis iv 0xffff.ffff.ffff.ffff.7fff.ffff.7fff.ffff)
        =+  ^=  pln
          (~(de ctrb k2 7 len hib) txt)
        ?.  =((s2vb k1 (weld vec (limo ~[pln]))) iv)
          ~
        `pln
      --  ::sivb
    ::                                                  ::  ++sivc:aes:crypto
    ++  sivc                                            ::  AES-256 SIV
      ~%  %sivc  +>  ~
      |_  [key=@J vec=(list @)]
      ::                                                ::  ++en:sivc:aes:crypto
      ++  en                                            ::  encrypt
        ~/  %en
        |=  txt=@
        ^-  (trel @uxH @ud @ux)
        =+  [k1=(rsh 8 key) k2=(end 8 key)]
        =+  iv=(s2vc k1 (weld vec (limo ~[txt])))
        =*  hib  (dis iv 0xffff.ffff.ffff.ffff.7fff.ffff.7fff.ffff)
        =+  len=(met 3 txt)
        :+
          iv
          len
        (~(en ctrc k2 7 len hib) txt)
      ::                                                ::  ++de:sivc:aes:crypto
      ++  de                                            ::  decrypt
        ~/  %de
        |=  [iv=@H len=@ txt=@]
        ^-  (unit @ux)
        =+  [k1=(rsh 8 key) k2=(end 8 key)]
        =*  hib  (dis iv 0xffff.ffff.ffff.ffff.7fff.ffff.7fff.ffff)
        =+  ^=  pln
          (~(de ctrc k2 7 len hib) txt)
        ?.  =((s2vc k1 (weld vec (limo ~[pln]))) iv)
          ~
        `pln
      --  ::sivc
    --
  ::                                                    ::
  ::::                    ++ed:crypto                   ::  ed25519
    ::                                                  ::::
  ++  ed
    =>
      =+  =+  [b=256 q=(sub (bex 255) 19)]
          =+  fq=~(. fo q)
          =+  ^=  l
               %+  add
                 (bex 252)
               27.742.317.777.372.353.535.851.937.790.883.648.493
          =+  d=(dif.fq 0 (fra.fq 121.665 121.666))
          =+  ii=(exp.fq (div (dec q) 4) 2)
          [b=b q=q fq=fq l=l d=d ii=ii]
      |%
      ::                                                ::  ++norm:ed:crypto
      ++  norm                                          ::
        |=(x=@ ?:(=(0 (mod x 2)) x (sub q x)))
      ::                                                ::  ++xrec:ed:crypto
      ++  xrec                                          ::  recover x-coord
        |=  y=@  ^-  @
        =+  ^=  xx
            %+  mul  (dif.fq (mul y y) 1)
                     (inv.fq +(:(mul d y y)))
        =+  x=(exp.fq (div (add 3 q) 8) xx)
        ?:  !=(0 (dif.fq (mul x x) (sit.fq xx)))
          (norm (pro.fq x ii))
        (norm x)
      ::                                                ::  ++ward:ed:crypto
      ++  ward                                          ::  edwards multiply
        |=  [pp=[@ @] qq=[@ @]]  ^-  [@ @]
        =+  dp=:(pro.fq d -.pp -.qq +.pp +.qq)
        =+  ^=  xt
            %+  pro.fq
              %+  sum.fq
                (pro.fq -.pp +.qq)
              (pro.fq -.qq +.pp)
            (inv.fq (sum.fq 1 dp))
        =+  ^=  yt
            %+  pro.fq
              %+  sum.fq
                (pro.fq +.pp +.qq)
              (pro.fq -.pp -.qq)
            (inv.fq (dif.fq 1 dp))
        [xt yt]
      ::                                                ::  ++scam:ed:crypto
      ++  scam                                          ::  scalar multiply
        |=  [pp=[@ @] e=@]  ^-  [@ @]
        ?:  =(0 e)
          [0 1]
        =+  qq=$(e (div e 2))
        =>  .(qq (ward qq qq))
        ?:  =(1 (dis 1 e))
          (ward qq pp)
        qq
      ::                                                ::  ++etch:ed:crypto
      ++  etch                                          ::  encode point
        |=  pp=[@ @]  ^-  @
        (can 0 ~[[(sub b 1) +.pp] [1 (dis 1 -.pp)]])
      ::                                                ::  ++curv:ed:crypto
      ++  curv                                          ::  point on curve?
        |=  [x=@ y=@]  ^-  ?
        .=  0
            %+  dif.fq
              %+  sum.fq
                (pro.fq (sub q (sit.fq x)) x)
              (pro.fq y y)
            (sum.fq 1 :(pro.fq d x x y y))
      ::                                                ::  ++deco:ed:crypto
      ++  deco                                          ::  decode point
        |=  s=@  ^-  (unit [@ @])
        =+  y=(cut 0 [0 (dec b)] s)
        =+  si=(cut 0 [(dec b) 1] s)
        =+  x=(xrec y)
        =>  .(x ?:(!=(si (dis 1 x)) (sub q x) x))
        =+  pp=[x y]
        ?.  (curv pp)
          ~
        [~ pp]
      ::                                                ::  ++bb:ed:crypto
      ++  bb                                            ::
        =+  bby=(pro.fq 4 (inv.fq 5))
        [(xrec bby) bby]
      --  ::
    ~%  %ed  +  ~
    |%
    ::
    ++  point-add
      ~/  %point-add
      |=  [a-point=@udpoint b-point=@udpoint]
      ^-  @udpoint
      ::
      =/  a-point-decoded=[@ @]  (need (deco a-point))
      =/  b-point-decoded=[@ @]  (need (deco b-point))
      ::
      %-  etch
      (ward a-point-decoded b-point-decoded)
    ::
    ++  scalarmult
      ~/  %scalarmult
      |=  [a=@udscalar a-point=@udpoint]
      ^-  @udpoint
      ::
      =/  a-point-decoded=[@ @]  (need (deco a-point))
      ::
      %-  etch
      (scam a-point-decoded a)
    ::
    ++  scalarmult-base
      ~/  %scalarmult-base
      |=  scalar=@udscalar
      ^-  @udpoint
      %-  etch
      (scam bb scalar)
    ::
    ++  add-scalarmult-scalarmult-base
      ~/  %add-scalarmult-scalarmult-base
      |=  [a=@udscalar a-point=@udpoint b=@udscalar]
      ^-  @udpoint
      ::
      =/  a-point-decoded=[@ @]  (need (deco a-point))
      ::
      %-  etch
      %+  ward
        (scam bb b)
      (scam a-point-decoded a)
    ::
    ++  add-double-scalarmult
      ~/  %add-double-scalarmult
      |=  [a=@udscalar a-point=@udpoint b=@udscalar b-point=@udpoint]
      ^-  @udpoint
      ::
      =/  a-point-decoded=[@ @]  (need (deco a-point))
      =/  b-point-decoded=[@ @]  (need (deco b-point))
      ::
      %-  etch
      %+  ward
        (scam a-point-decoded a)
      (scam b-point-decoded b)
    ::                                                  ::  ++puck:ed:crypto
    ++  puck                                            ::  public key
      ~/  %puck
      |=  sk=@I  ^-  @
      ?:  (gth (met 3 sk) 32)  !!
      =+  h=(shal (rsh [0 3] b) sk)
      =+  ^=  a
          %+  add
            (bex (sub b 2))
          (lsh [0 3] (cut 0 [3 (sub b 5)] h))
      =+  aa=(scam bb a)
      (etch aa)
    ::                                                  ::  ++suck:ed:crypto
    ++  suck                                            ::  keypair from seed
      |=  se=@I  ^-  @uJ
      =+  pu=(puck se)
      (can 0 ~[[b se] [b pu]])
    ::                                                  ::  ++shar:ed:crypto
    ++  shar                                            ::  curve25519 secret
      ~/  %shar
      |=  [pub=@ sek=@]
      ^-  @ux
      =+  exp=(shal (rsh [0 3] b) (suck sek))
      =.  exp  (dis exp (can 0 ~[[3 0] [251 (fil 0 251 1)]]))
      =.  exp  (con exp (lsh [3 31] 0b100.0000))
      =+  prv=(end 8 exp)
      =+  crv=(fra.fq (sum.fq 1 pub) (dif.fq 1 pub))
      (curt:number prv crv)
    ::                                                  ::  ++sign:ed:crypto
    ++  sign                                            ::  certify
      ~/  %sign
      |=  [m=@ se=@]  ^-  @
      =+  sk=(suck se)
      =+  pk=(cut 0 [b b] sk)
      =+  h=(shal (rsh [0 3] b) sk)
      =+  ^=  a
          %+  add
            (bex (sub b 2))
          (lsh [0 3] (cut 0 [3 (sub b 5)] h))
      =+  ^=  r
          =+  hm=(cut 0 [b b] h)
          =+  ^=  i
              %+  can  0
              :~  [b hm]
                  [(met 0 m) m]
              ==
          (shaz i)
      =+  rr=(scam bb r)
      =+  ^=  ss
          =+  er=(etch rr)
          =+  ^=  ha
              %+  can  0
              :~  [b er]
                  [b pk]
                  [(met 0 m) m]
              ==
          (~(sit fo l) (add r (mul (shaz ha) a)))
      (can 0 ~[[b (etch rr)] [b ss]])
    ::                                                  ::  ++veri:ed:crypto
    ++  veri                                            ::  validate
      ~/  %veri
      |=  [s=@ m=@ pk=@]  ^-  ?
      ?:  (gth (div b 4) (met 3 s))  |
      ?:  (gth (div b 8) (met 3 pk))  |
      =+  cb=(rsh [0 3] b)
      =+  rr=(deco (cut 0 [0 b] s))
      ?~  rr  |
      =+  aa=(deco pk)
      ?~  aa  |
      =+  ss=(cut 0 [b b] s)
      =+  ha=(can 3 ~[[cb (etch u.rr)] [cb pk] [(met 3 m) m]])
      =+  h=(shaz ha)
      =((scam bb ss) (ward u.rr (scam u.aa h)))
    --  ::ed
  ::                                                    ::
  ::::                    ++scr:crypto                  ::  (2b3) scrypt
    ::                                                  ::::
  ++  scr
    |%
    ::                                                  ::  ++sal:scr:crypto
    ++  sal                                             ::  salsa20 hash
      |=  [x=@ r=@]                                     ::  with r rounds
      ?>  =((mod r 2) 0)                                ::
      =+  few==>(fe .(a 5))
      =+  ^=  rot
        |=  [a=@ b=@]
        (mix (end 5 (lsh [0 a] b)) (rsh [0 (sub 32 a)] b))
      =+  ^=  lea
        |=  [a=@ b=@]
        (net:few (sum:few (net:few a) (net:few b)))
      =>  |%
          ::                                            ::  ++qr:sal:scr:crypto
          ++  qr                                        ::  quarterround
            |=  y=[@ @ @ @ ~]
            =+  zb=(mix &2.y (rot 7 (sum:few &1.y &4.y)))
            =+  zc=(mix &3.y (rot 9 (sum:few zb &1.y)))
            =+  zd=(mix &4.y (rot 13 (sum:few zc zb)))
            =+  za=(mix &1.y (rot 18 (sum:few zd zc)))
            ~[za zb zc zd]
          ::                                            ::  ++rr:sal:scr:crypto
          ++  rr                                        ::  rowround
            |=  [y=(list @)]
            =+  za=(qr ~[&1.y &2.y &3.y &4.y])
            =+  zb=(qr ~[&6.y &7.y &8.y &5.y])
            =+  zc=(qr ~[&11.y &12.y &9.y &10.y])
            =+  zd=(qr ~[&16.y &13.y &14.y &15.y])
            ^-  (list @)  :~
              &1.za  &2.za  &3.za  &4.za
              &4.zb  &1.zb  &2.zb  &3.zb
              &3.zc  &4.zc  &1.zc  &2.zc
              &2.zd  &3.zd  &4.zd  &1.zd  ==
          ::                                            ::  ++cr:sal:scr:crypto
          ++  cr                                        ::  columnround
            |=  [x=(list @)]
            =+  ya=(qr ~[&1.x &5.x &9.x &13.x])
            =+  yb=(qr ~[&6.x &10.x &14.x &2.x])
            =+  yc=(qr ~[&11.x &15.x &3.x &7.x])
            =+  yd=(qr ~[&16.x &4.x &8.x &12.x])
            ^-  (list @)  :~
              &1.ya  &4.yb  &3.yc  &2.yd
              &2.ya  &1.yb  &4.yc  &3.yd
              &3.ya  &2.yb  &1.yc  &4.yd
              &4.ya  &3.yb  &2.yc  &1.yd  ==
          ::                                            ::  ++dr:sal:scr:crypto
          ++  dr                                        ::  doubleround
            |=  [x=(list @)]
            (rr (cr x))
          ::                                            ::  ++al:sal:scr:crypto
          ++  al                                        ::  add two lists
            |=  [a=(list @) b=(list @)]
            |-  ^-  (list @)
            ?~  a  ~  ?~  b  ~
            [i=(sum:few -.a -.b) t=$(a +.a, b +.b)]
          --  ::
      =+  xw=(rpp 5 16 x)
      =+  ^=  ow  |-  ^-  (list @)
                  ?~  r  xw
                  $(xw (dr xw), r (sub r 2))
      (rep 5 (al xw ow))
    ::                                                  ::  ++rpp:scr:crypto
    ++  rpp                                             ::  rip+filler blocks
      |=  [a=bloq b=@ c=@]
      =+  q=(rip a c)
      =+  w=(lent q)
      ?.  =(w b)
        ?.  (lth w b)  (slag (sub w b) q)
        ^+  q  (weld q (reap (sub b (lent q)) 0))
      q
    ::                                                  ::  ++bls:scr:crypto
    ++  bls                                             ::  split to sublists
      |=  [a=@ b=(list @)]
      ?>  =((mod (lent b) a) 0)
      |-  ^-  (list (list @))
      ?~  b  ~
      [i=(scag a `(list @)`b) t=$(b (slag a `(list @)`b))]
    ::                                                  ::  ++slb:scr:crypto
    ++  slb                                             ::
      |=  [a=(list (list @))]
      |-  ^-  (list @)
      ?~  a  ~
      (weld `(list @)`-.a $(a +.a))
    ::                                                  ::  ++sbm:scr:crypto
    ++  sbm                                             ::  scryptBlockMix
      |=  [r=@ b=(list @)]
      ?>  =((lent b) (mul 2 r))
      =+  [x=(snag (dec (mul 2 r)) b) c=0]
      =|  [ya=(list @) yb=(list @)]
      |-  ^-  (list @)
      ?~  b  (flop (weld yb ya))
      =.  x  (sal (mix x -.b) 8)
      ?~  (mod c 2)
        $(c +(c), b +.b, ya [i=x t=ya])
      $(c +(c), b +.b, yb [i=x t=yb])
    ::                                                  ::  ++srm:scr:crypto
    ++  srm                                             ::  scryptROMix
      |=  [r=@ b=(list @) n=@]
      ?>  ?&  =((lent b) (mul 2 r))
              =(n (bex (dec (xeb n))))
              (lth n (bex (mul r 16)))
          ==
      =+  [v=*(list (list @)) c=0]
      =.  v
        |-  ^-  (list (list @))
        =+  w=(sbm r b)
        ?:  =(c n)  (flop v)
        $(c +(c), v [i=[b] t=v], b w)
      =+  x=(sbm r (snag (dec n) v))
      |-  ^-  (list @)
      ?:  =(c n)  x
      =+  q=(snag (dec (mul r 2)) x)
      =+  z=`(list @)`(snag (mod q n) v)
      =+  ^=  w  |-  ^-  (list @)
                 ?~  x  ~  ?~  z  ~
                 [i=(mix -.x -.z) t=$(x +.x, z +.z)]
      $(x (sbm r w), c +(c))
    ::                                                  ::  ++hmc:scr:crypto
    ++  hmc                                             ::  HMAC-SHA-256
      |=  [k=@ t=@]
      (hml k (met 3 k) t (met 3 t))
    ::                                                  ::  ++hml:scr:crypto
    ++  hml                                             ::  w+length
      |=  [k=@ kl=@ t=@ tl=@]
      =>  .(k (end [3 kl] k), t (end [3 tl] t))
      =+  b=64
      =?  k  (gth kl b)  (shay kl k)
      =+  ^=  q  %+  shay  (add b tl)
       (add (lsh [3 b] t) (mix k (fil 3 b 0x36)))
      %+  shay  (add b 32)
      (add (lsh [3 b] q) (mix k (fil 3 b 0x5c)))
    ::                                                  ::  ++pbk:scr:crypto
    ++  pbk                                             :: PBKDF2-HMAC-SHA256
      ~/  %pbk
      |=  [p=@ s=@ c=@ d=@]
      (pbl p (met 3 p) s (met 3 s) c d)
    ::                                                  ::  ++pbl:scr:crypto
    ++  pbl                                             ::  w+length
      ~/  %pbl
      |=  [p=@ pl=@ s=@ sl=@ c=@ d=@]
      =>  .(p (end [3 pl] p), s (end [3 sl] s))
      =+  h=32
      ::
      ::  max key length 1GB
      ::  max iterations 2^28
      ::
      ?>  ?&  (lte d (bex 30))
              (lte c (bex 28))
              !=(c 0)
          ==
      =+  ^=  l  ?~  (mod d h)
          (div d h)
        +((div d h))
      =+  r=(sub d (mul h (dec l)))
      =+  [t=0 j=1 k=1]
      =.  t  |-  ^-  @
        ?:  (gth j l)  t
        =+  u=(add s (lsh [3 sl] (rep 3 (flop (rpp 3 4 j)))))
        =+  f=0  =.  f  |-  ^-  @
          ?:  (gth k c)  f
          =+  q=(hml p pl u ?:(=(k 1) (add sl 4) h))
          $(u q, f (mix f q), k +(k))
        $(t (add t (lsh [3 (mul (dec j) h)] f)), j +(j))
      (end [3 d] t)
    ::                                                  ::  ++hsh:scr:crypto
    ++  hsh                                             ::  scrypt
      ~/  %hsh
      |=  [p=@ s=@ n=@ r=@ z=@ d=@]
      (hsl p (met 3 p) s (met 3 s) n r z d)
    ::                                                  ::  ++hsl:scr:crypto
    ++  hsl                                             ::  w+length
      ~/  %hsl
      |=  [p=@ pl=@ s=@ sl=@ n=@ r=@ z=@ d=@]
      =|  v=(list (list @))
      =>  .(p (end [3 pl] p), s (end [3 sl] s))
      =+  u=(mul (mul 128 r) z)
      ::
      ::  n is power of 2; max 1GB memory
      ::
      ?>  ?&  =(n (bex (dec (xeb n))))
              !=(r 0)  !=(z 0)
              %+  lte
                  (mul (mul 128 r) (dec (add n z)))
                (bex 30)
              (lth pl (bex 31))
              (lth sl (bex 31))
          ==
      =+  ^=  b  =+  (rpp 3 u (pbl p pl s sl 1 u))
        %+  turn  (bls (mul 128 r) -)
        |=(a=(list @) (rpp 9 (mul 2 r) (rep 3 a)))
      ?>  =((lent b) z)
      =+  ^=  q
        =+  |-  ?~  b  (flop v)
            $(b +.b, v [i=(srm r -.b n) t=v])
        %+  turn  `(list (list @))`-
        |=(a=(list @) (rpp 3 (mul 128 r) (rep 9 a)))
      (pbl p pl (rep 3 (slb q)) u 1 d)
    ::                                                  ::  ++ypt:scr:crypto
    ++  ypt                                             ::  256bit {salt pass}
      |=  [s=@ p=@]
      ^-  @
      (hsh p s 16.384 8 1 256)
    --  ::scr
  ::                                                    ::
  ::::                    ++crub:crypto                 ::  (2b4) suite B, Ed
    ::                                                  ::::
  ++  crub  !:
    ^-  acru
    =|  [pub=[cry=@ sgn=@] sek=(unit [cry=@ sgn=@])]
    |%
    ::                                                  ::  ++as:crub:crypto
    ++  as                                              ::
      |%
      ::                                                ::  ++sign:as:crub:
      ++  sign                                          ::
        |=  msg=@
        ^-  @ux
        (jam [(sigh msg) msg])
      ::                                                ::  ++sigh:as:crub:
      ++  sigh                                          ::
        |=  msg=@
        ^-  @ux
        ?~  sek  ~|  %pubkey-only  !!
        (sign:ed msg sgn.u.sek)
      ::                                                ::  ++sure:as:crub:
      ++  sure                                          ::
        |=  txt=@
        ^-  (unit @ux)
        =+  ;;([sig=@ msg=@] (cue txt))
        ?.  (safe sig msg)  ~
        (some msg)
      ::                                                ::  ++safe:as:crub:
      ++  safe
        |=  [sig=@ msg=@]
        ^-  ?
        (veri:ed sig msg sgn.pub)
      ::                                                ::  ++seal:as:crub:
      ++  seal                                          ::
        |=  [bpk=pass msg=@]
        ^-  @ux
        ?~  sek  ~|  %pubkey-only  !!
        ?>  =('b' (end 3 bpk))
        =+  pk=(rsh 8 (rsh 3 bpk))
        =+  shar=(shax (shar:ed pk cry.u.sek))
        =+  smsg=(sign msg)
        (jam (~(en siva:aes shar ~) smsg))
      ::                                                ::  ++tear:as:crub:
      ++  tear                                          ::
        |=  [bpk=pass txt=@]
        ^-  (unit @ux)
        ?~  sek  ~|  %pubkey-only  !!
        ?>  =('b' (end 3 bpk))
        =+  pk=(rsh 8 (rsh 3 bpk))
        =+  shar=(shax (shar:ed pk cry.u.sek))
        =+  ;;([iv=@ len=@ cph=@] (cue txt))
        =+  try=(~(de siva:aes shar ~) iv len cph)
        ?~  try  ~
        (sure:as:(com:nu:crub bpk) u.try)
      --  ::as
    ::                                                  ::  ++de:crub:crypto
    ++  de                                              ::  decrypt
      |=  [key=@J txt=@]
      ^-  (unit @ux)
      =+  ;;([iv=@ len=@ cph=@] (cue txt))
      %^    ~(de sivc:aes (shaz key) ~)
          iv
        len
      cph
    ::                                                  ::  ++dy:crub:crypto
    ++  dy                                              ::  need decrypt
      |=  [key=@J cph=@]
      (need (de key cph))
    ::                                                  ::  ++en:crub:crypto
    ++  en                                              ::  encrypt
      |=  [key=@J msg=@]
      ^-  @ux
      (jam (~(en sivc:aes (shaz key) ~) msg))
    ::                                                  ::  ++ex:crub:crypto
    ++  ex                                              ::  extract
      |%
      ::                                                ::  ++fig:ex:crub:crypto
      ++  fig                                           ::  fingerprint
        ^-  @uvH
        (shaf %bfig pub)
      ::                                                ::  ++pac:ex:crub:crypto
      ++  pac                                           ::  private fingerprint
        ^-  @uvG
        ?~  sek  ~|  %pubkey-only  !!
        (end 6 (shaf %bcod sec))
      ::                                                ::  ++pub:ex:crub:crypto
      ++  pub                                           ::  public key
        ^-  pass
        (cat 3 'b' (cat 8 sgn.^pub cry.^pub))
      ::                                                ::  ++sec:ex:crub:crypto
      ++  sec                                           ::  private key
        ^-  ring
        ?~  sek  ~|  %pubkey-only  !!
        (cat 3 'B' (cat 8 sgn.u.sek cry.u.sek))
      --  ::ex
    ::                                                  ::  ++nu:crub:crypto
    ++  nu                                              ::
      |%
      ::                                                ::  ++pit:nu:crub:crypto
      ++  pit                                           ::  create keypair
        |=  [w=@ seed=@]
        =+  wid=(add (div w 8) ?:(=((mod w 8) 0) 0 1))
        =+  bits=(shal wid seed)
        =+  [c=(rsh 8 bits) s=(end 8 bits)]
        ..nu(pub [cry=(puck:ed c) sgn=(puck:ed s)], sek `[cry=c sgn=s])
      ::                                                ::  ++nol:nu:crub:crypto
      ++  nol                                           ::  activate secret
        |=  a=ring
        =+  [mag=(end 3 a) bod=(rsh 3 a)]
        ~|  %not-crub-seckey  ?>  =('B' mag)
        =+  [c=(rsh 8 bod) s=(end 8 bod)]
        ..nu(pub [cry=(puck:ed c) sgn=(puck:ed s)], sek `[cry=c sgn=s])
      ::                                                ::  ++com:nu:crub:crypto
      ++  com                                           ::  activate public
        |=  a=pass
        =+  [mag=(end 3 a) bod=(rsh 3 a)]
        ~|  %not-crub-pubkey  ?>  =('b' mag)
        ..nu(pub [cry=(rsh 8 bod) sgn=(end 8 bod)], sek ~)
      --  ::nu
    --  ::crub
  ::                                                    ::
  ::::                    ++crua:crypto                 ::  (2b5) suite B, RSA
    ::                                                  ::::
  ++  crua  !!
  ::                                                    ::
  ::::                    ++test:crypto                 ::  (2b6) test crypto
    ::                                                  ::::
  ++  test  ^?
    |%
    ::                                                  ::  ++trub:test:crypto
    ++  trub                                            ::  test crub
      |=  msg=@t
      ::
      ::  make acru cores
      ::
      =/  ali      (pit:nu:crub 512 (shaz 'Alice'))
      =/  ali-pub  (com:nu:crub pub:ex.ali)
      =/  bob      (pit:nu:crub 512 (shaz 'Robert'))
      =/  bob-pub  (com:nu:crub pub:ex.bob)
      ::
      ::  alice signs and encrypts a symmetric key to bob
      ::
      =/  secret-key  %-  shaz
          'Let there be no duplicity when taking a stand against him.'
      =/  signed-key   (sign:as.ali secret-key)
      =/  crypted-key  (seal:as.ali pub:ex.bob-pub signed-key)
      ::  bob decrypts and verifies
      =/  decrypt-key-attempt  (tear:as.bob pub:ex.ali-pub crypted-key)
      =/  decrypted-key    ~|  %decrypt-fail  (need decrypt-key-attempt)
      =/  verify-key-attempt   (sure:as.ali-pub decrypted-key)
      =/  verified-key     ~|  %verify-fail  (need verify-key-attempt)
      ::  bob encrypts with symmetric key
      =/  crypted-msg  (en.bob verified-key msg)
      ::  alice decrypts with same key
      `@t`(dy.ali secret-key crypted-msg)
    --  ::test
  ::                                                    ::
  ::::                    ++keccak:crypto               ::  (2b7) keccak family
    ::                                                  ::::
  ++  keccak
    |%
    ::
    ::  keccak
    ::
    ++  keccak-224  ~/  %k224  |=(a=octs (keccak 1.152 448 224 a))
    ++  keccak-256  ~/  %k256  |=(a=octs (keccak 1.088 512 256 a))
    ++  keccak-384  ~/  %k384  |=(a=octs (keccak 832 768 384 a))
    ++  keccak-512  ~/  %k512  |=(a=octs (keccak 576 1.024 512 a))
    ::
    ++  keccak  (cury (cury hash keccak-f) padding-keccak)
    ::
    ++  padding-keccak  (multirate-padding 0x1)
    ::
    ::  sha3
    ::
    ++  sha3-224  |=(a=octs (sha3 1.152 448 224 a))
    ++  sha3-256  |=(a=octs (sha3 1.088 512 256 a))
    ++  sha3-384  |=(a=octs (sha3 832 768 384 a))
    ++  sha3-512  |=(a=octs (sha3 576 1.024 512 a))
    ::
    ++  sha3  (cury (cury hash keccak-f) padding-sha3)
    ::
    ++  padding-sha3  (multirate-padding 0x6)
    ::
    ::  shake
    ::
    ++  shake-128  |=([o=@ud i=octs] (shake 1.344 256 o i))
    ++  shake-256  |=([o=@ud i=octs] (shake 1.088 512 o i))
    ::
    ++  shake  (cury (cury hash keccak-f) padding-shake)
    ::
    ++  padding-shake  (multirate-padding 0x1f)
    ::
    ::  rawshake
    ::
    ++  rawshake-128  |=([o=@ud i=octs] (rawshake 1.344 256 o i))
    ++  rawshake-256  |=([o=@ud i=octs] (rawshake 1.088 512 o i))
    ::
    ++  rawshake  (cury (cury hash keccak-f) padding-rawshake)
    ::
    ++  padding-rawshake  (multirate-padding 0x7)
    ::
    ::  core
    ::
    ++  hash
      ::  per:  permutation function with configurable width.
      ::  pad:  padding function.
      ::  rat:  bitrate, size in bits of blocks to operate on.
      ::  cap:  capacity, bits of sponge padding.
      ::  out:  length of desired output, in bits.
      ::  inp:  input to hash.
      |=  $:  per=$-(@ud $-(@ @))
              pad=$-([octs @ud] octs)
              rat=@ud
              cap=@ud
              out=@ud
              inp=octs
          ==
      ^-  @
      ::  urbit's little-endian to keccak's big-endian.
      =.  q.inp  (rev 3 inp)
      %.  [inp out]
      (sponge per pad rat cap)
    ::
    ::NOTE  if ++keccak ever needs to be made to operate
    ::      on bits rather than bytes, all that needs to
    ::      be done is updating the way this padding
    ::      function works. (and also "octs" -> "bits")
    ++  multirate-padding
      ::  dsb:  domain separation byte, reverse bit order.
      |=  dsb=@ux
      ?>  (lte dsb 0xff)
      |=  [inp=octs mut=@ud]
      ^-  octs
      =.  mut  (div mut 8)
      =+  pal=(sub mut (mod p.inp mut))
      =?  pal  =(pal 0)  mut
      =.  pal  (dec pal)
      :-  (add p.inp +(pal))
      ::  padding is provided in lane bit ordering,
      ::  ie, LSB = left.
      (cat 3 (con (lsh [3 pal] dsb) 0x80) q.inp)
    ::
    ++  sponge
      ::  sponge construction
      ::
      ::  preperm:  permutation function with configurable width.
      ::  padding:  padding function.
      ::  bitrate:  size of blocks to operate on.
      ::  capacity:  sponge padding.
      |=  $:  preperm=$-(@ud $-(@ @))
              padding=$-([octs @ud] octs)
              bitrate=@ud
              capacity=@ud
          ==
      ::
      ::  preparing
      =+  bitrate-bytes=(div bitrate 8)
      =+  blockwidth=(add bitrate capacity)
      =+  permute=(preperm blockwidth)
      ::
      |=  [input=octs output=@ud]
      |^  ^-  @
        ::
        ::  padding
        =.  input  (padding input bitrate)
        ::
        ::  absorbing
        =/  pieces=(list @)
          ::  amount of bitrate-sized blocks.
          ?>  =(0 (mod p.input bitrate-bytes))
          =+  i=(div p.input bitrate-bytes)
          |-
          ?:  =(i 0)  ~
          :_  $(i (dec i))
          ::  get the bitrate-sized block of bytes
          ::  that ends with the byte at -.
          =-  (cut 3 [- bitrate-bytes] q.input)
          (mul (dec i) bitrate-bytes)
        =/  state=@
          ::  for every piece,
          %+  roll  pieces
          |=  [p=@ s=@]
          ::  pad with capacity,
          =.  p  (lsh [0 capacity] p)
          ::  xor it into the state and permute it.
          (permute (mix s (bytes-to-lanes p)))
        ::
        ::  squeezing
        =|  res=@
        =|  len=@ud
        |-
        ::  append a bitrate-sized head of state to the
        ::  result.
        =.  res
          %+  con  (lsh [0 bitrate] res)
          (rsh [0 capacity] (lanes-to-bytes state))
        =.  len  (add len bitrate)
        ?:  (gte len output)
          ::  produce the requested bits of output.
          (rsh [0 (sub len output)] res)
        $(res res, state (permute state))
      ::
      ++  bytes-to-lanes
        ::  flip byte order in blocks of 8 bytes.
        |=  a=@
        %^  run  6  a
        |=(b=@ (lsh [3 (sub 8 (met 3 b))] (swp 3 b)))
      ::
      ++  lanes-to-bytes
        ::  unflip byte order in blocks of 8 bytes.
        |=  a=@
        %+  can  6
        %+  turn
          =+  (rip 6 a)
          (weld - (reap (sub 25 (lent -)) 0x0))
        |=  a=@
        :-  1
        %+  can  3
        =-  (turn - |=(a=@ [1 a]))
        =+  (flop (rip 3 a))
        (weld (reap (sub 8 (lent -)) 0x0) -)
      --
    ::
    ++  keccak-f
      ::  keccak permutation function
      |=  [width=@ud]
      ::  assert valid blockwidth.
      ?>  =-  (~(has in -) width)
          (sy 25 50 100 200 400 800 1.600 ~)
      ::  assumes 5x5 lanes state, as is the keccak
      ::  standard.
      =+  size=5
      =+  lanes=(mul size size)
      =+  lane-bloq=(dec (xeb (div width lanes)))
      =+  lane-size=(bex lane-bloq)
      =+  rounds=(add 12 (mul 2 lane-bloq))
      |=  [input=@]
      ^-  @
      =*  a  input
      =+  round=0
      |^
        ?:  =(round rounds)  a
        ::
        ::  theta
        =/  c=@
          %+  roll  (gulf 0 (dec size))
          |=  [x=@ud c=@]
          %+  con  (lsh [lane-bloq 1] c)
          %+  roll  (gulf 0 (dec size))
          |=  [y=@ud c=@]
          (mix c (get-lane x y a))
        =/  d=@
          %+  roll  (gulf 0 (dec size))
          |=  [x=@ud d=@]
          %+  con  (lsh [lane-bloq 1] d)
          %+  mix
            =-  (get-word - size c)
            ?:(=(x 0) (dec size) (dec x))
          %^  ~(rol fe lane-bloq)  0  1
          (get-word (mod +(x) size) size c)
        =.  a
          %+  roll  (gulf 0 (dec lanes))
          |=  [i=@ud a=_a]
          %+  mix  a
          %+  lsh
            [lane-bloq (sub lanes +(i))]
          (get-word i size d)
        ::
        ::  rho and pi
        =/  b=@
          %+  roll  (gulf 0 (dec lanes))
          |=  [i=@ b=@]
          =+  x=(mod i 5)
          =+  y=(div i 5)
          %+  con  b
          %+  lsh
            :-  lane-bloq
            %+  sub  lanes
            %+  add  +(y)
            %+  mul  size
            (mod (add (mul 2 x) (mul 3 y)) size)
          %^  ~(rol fe lane-bloq)  0
            (rotation-offset i)
          (get-word i lanes a)
        ::
        ::  chi
        =.  a
          %+  roll  (gulf 0 (dec lanes))
          |=  [i=@ud a=@]
          %+  con  (lsh lane-bloq a)
          =+  x=(mod i 5)
          =+  y=(div i 5)
          %+  mix  (get-lane x y b)
          %+  dis
            =-  (get-lane - y b)
            (mod (add x 2) size)
          %^  not  lane-bloq  1
          (get-lane (mod +(x) size) y b)
        ::
        ::  iota
        =.  a
          =+  (round-constant round)
          (mix a (lsh [lane-bloq (dec lanes)] -))
        ::
        ::  next round
        $(round +(round))
      ::
      ++  get-lane
        ::  get the lane with coordinates
        |=  [x=@ud y=@ud a=@]
        =+  i=(add x (mul size y))
        (get-word i lanes a)
      ::
      ++  get-word
        ::  get word {n} from atom {a} of {m} words.
        |=  [n=@ud m=@ud a=@]
        (cut lane-bloq [(sub m +((mod n m))) 1] a)
      ::
      ++  round-constant
        |=  c=@ud
        =-  (snag (mod c 24) -)
        ^-  (list @ux)
        :~  0x1
            0x8082
            0x8000.0000.0000.808a
            0x8000.0000.8000.8000
            0x808b
            0x8000.0001
            0x8000.0000.8000.8081
            0x8000.0000.0000.8009
            0x8a
            0x88
            0x8000.8009
            0x8000.000a
            0x8000.808b
            0x8000.0000.0000.008b
            0x8000.0000.0000.8089
            0x8000.0000.0000.8003
            0x8000.0000.0000.8002
            0x8000.0000.0000.0080
            0x800a
            0x8000.0000.8000.000a
            0x8000.0000.8000.8081
            0x8000.0000.0000.8080
            0x8000.0001
            0x8000.0000.8000.8008
        ==
      ::
      ++  rotation-offset
        |=  x=@ud
        =-  (snag x -)
        ^-  (list @ud)
        :~   0   1  62  28  27
            36  44   6  55  20
             3  10  43  25  39
            41  45  15  21   8
            18   2  61  56  14
        ==
      --
    --  ::keccak
  ::                                                    ::
  ::::                    ++hmac:crypto                 ::  (2b8) hmac family
    ::                                                  ::::
  ++  hmac
    =,  sha
    =>  |%
        ++  meet  |=([k=@ m=@] [[(met 3 k) k] [(met 3 m) m]])
        ++  flip  |=([k=@ m=@] [(swp 3 k) (swp 3 m)])
        --
    |%
    ::
    ::  use with @
    ::
    ++  hmac-sha1     (cork meet hmac-sha1l)
    ++  hmac-sha256   (cork meet hmac-sha256l)
    ++  hmac-sha512   (cork meet hmac-sha512l)
    ::
    ::  use with @t
    ::
    ++  hmac-sha1t    (cork flip hmac-sha1)
    ++  hmac-sha256t  (cork flip hmac-sha256)
    ++  hmac-sha512t  (cork flip hmac-sha512)
    ::
    ::  use with byts
    ::
    ++  hmac-sha1l    (cury hmac sha-1l 64 20)
    ++  hmac-sha256l  (cury hmac sha-256l 64 32)
    ++  hmac-sha512l  (cury hmac sha-512l 128 64)
    ::
    ::  main logic
    ::
    ++  hmac
      ::~/  %hmac
      ::  boq: block size in bytes used by haj
      ::  out: bytes output by haj
      |*  [[haj=$-([@u @] @) boq=@u out=@u] key=byts msg=byts]
      ::  ensure key and message fit signaled lengths
      =.  dat.key  (end [3 wid.key] dat.key)
      =.  dat.msg  (end [3 wid.msg] dat.msg)
      ::  keys longer than block size are shortened by hashing
      =?  dat.key  (gth wid.key boq)  (haj wid.key dat.key)
      =?  wid.key  (gth wid.key boq)  out
      ::  keys shorter than block size are right-padded
      =?  dat.key  (lth wid.key boq)  (lsh [3 (sub boq wid.key)] dat.key)
      ::  pad key, inner and outer
      =+  kip=(mix dat.key (fil 3 boq 0x36))
      =+  kop=(mix dat.key (fil 3 boq 0x5c))
      ::  append inner padding to message, then hash
      =+  (haj (add wid.msg boq) (add (lsh [3 wid.msg] kip) dat.msg))
      ::  prepend outer padding to result, hash again
      (haj (add out boq) (add (lsh [3 out] kop) -))
    --  ::  hmac
  ::                                                    ::
  ::::                    ++secp:crypto                 ::  (2b9) secp family
    ::                                                  ::::
  ++  secp  !.
    ::  TODO: as-octs and hmc are outside of jet parent
    =>  :+  .
        hmc=hmac-sha256l:hmac:crypto
        as-octs=as-octs:wrap
    |%
    +$  jacobian   [x=@ y=@ z=@]                    ::  jacobian point
    +$  point      [x=@ y=@]                        ::  curve point
    +$  domain
      $:  p=@                                       ::  prime modulo
          a=@                                       ::  y^2=x^3+ax+b
          b=@                                       ::
          g=point                                   ::  base point
          n=@                                       ::  prime order of g
      ==
    ++  secp
      |_  [bytes=@ =domain]
      ++  field-p  ~(. fo p.domain)
      ++  field-n  ~(. fo n.domain)
      ++  compress-point
        |=  =point
        ^-  @
        %+  can  3
        :~  [bytes x.point]
            [1 (add 2 (cut 0 [0 1] y.point))]
        ==
      ::
      ++  serialize-point
        |=  =point
        ^-  @
        %+  can  3
        :~  [bytes y.point]
            [bytes x.point]
            [1 4]
        ==
      ::
      ++  decompress-point
        |=  compressed=@
        ^-  point
        =/  x=@  (end [3 bytes] compressed)
        ?>  =(3 (mod p.domain 4))
        =/  fop  field-p
        =+  [fadd fmul fpow]=[sum.fop pro.fop exp.fop]
        =/  y=@  %+  fpow  (rsh [0 2] +(p.domain))
                 %+  fadd  b.domain
                 %+  fadd  (fpow 3 x)
                (fmul a.domain x)
        =/  s=@  (rsh [3 bytes] compressed)
        ~|  [`@ux`s `@ux`compressed]
        ?>  |(=(2 s) =(3 s))
        ::  check parity
        ::
        =?  y  !=((sub s 2) (mod y 2))
          (sub p.domain y)
        [x y]
      ::
      ++  jc                                        ::  jacobian math
        |%
        ++  from
          |=  a=jacobian
          ^-  point
          =/  fop   field-p
          =+  [fmul fpow finv]=[pro.fop exp.fop inv.fop]
          =/  z  (finv z.a)
          :-  (fmul x.a (fpow 2 z))
          (fmul y.a (fpow 3 z))
        ::
        ++  into
          |=  point
          ^-  jacobian
          [x y 1]
        ::
        ++  double
          |=  jacobian
          ^-  jacobian
          ?:  =(0 y)  [0 0 0]
          =/  fop  field-p
          =+  [fadd fsub fmul fpow]=[sum.fop dif.fop pro.fop exp.fop]
          =/  s    :(fmul 4 x (fpow 2 y))
          =/  m    %+  fadd
                     (fmul 3 (fpow 2 x))
                   (fmul a.domain (fpow 4 z))
          =/  nx   %+  fsub
                     (fpow 2 m)
                   (fmul 2 s)
          =/  ny  %+  fsub
                    (fmul m (fsub s nx))
                  (fmul 8 (fpow 4 y))
          =/  nz  :(fmul 2 y z)
          [nx ny nz]
        ::
        ++  add
          |=  [a=jacobian b=jacobian]
          ^-  jacobian
          ?:  =(0 y.a)  b
          ?:  =(0 y.b)  a
          =/  fop  field-p
          =+  [fadd fsub fmul fpow]=[sum.fop dif.fop pro.fop exp.fop]
          =/  u1  :(fmul x.a z.b z.b)
          =/  u2  :(fmul x.b z.a z.a)
          =/  s1  :(fmul y.a z.b z.b z.b)
          =/  s2  :(fmul y.b z.a z.a z.a)
          ?:  =(u1 u2)
            ?.  =(s1 s2)
              [0 0 1]
            (double a)
          =/  h     (fsub u2 u1)
          =/  r     (fsub s2 s1)
          =/  h2    (fmul h h)
          =/  h3    (fmul h2 h)
          =/  u1h2  (fmul u1 h2)
          =/  nx    %+  fsub
                      (fmul r r)
                    :(fadd h3 u1h2 u1h2)
          =/  ny    %+  fsub
                      (fmul r (fsub u1h2 nx))
                    (fmul s1 h3)
          =/  nz    :(fmul h z.a z.b)
          [nx ny nz]
        ::
        ++  mul
          |=  [a=jacobian scalar=@]
          ^-  jacobian
          ?:  =(0 y.a)
            [0 0 1]
          ?:  =(0 scalar)
            [0 0 1]
          ?:  =(1 scalar)
            a
          ?:  (gte scalar n.domain)
            $(scalar (mod scalar n.domain))
          ?:  =(0 (mod scalar 2))
            (double $(scalar (rsh 0 scalar)))
          (add a (double $(scalar (rsh 0 scalar))))
        --
      ++  add-points
        |=  [a=point b=point]
        ^-  point
        =/  j  jc
        (from.j (add.j (into.j a) (into.j b)))
      ++  mul-point-scalar
        |=  [p=point scalar=@]
        ^-  point
        =/  j  jc
        %-  from.j
        %+  mul.j
          (into.j p)
        scalar
      ::
      ++  valid-hash
        |=  has=@
        (lte (met 3 has) bytes)
      ::
      ++  in-order
        |=  i=@
        ?&  (gth i 0)
            (lth i n.domain)
        ==
      ++  priv-to-pub
        |=  private-key=@
        ^-  point
        ?>  (in-order private-key)
        (mul-point-scalar g.domain private-key)
      ::
      ++  make-k
        |=  [hash=@ private-key=@]
        ^-  @
        ?>  (in-order private-key)
        ?>  (valid-hash hash)
        =/  v  (fil 3 bytes 1)
        =/  k  0
        =.  k  %+  hmc  [bytes k]
               %-  as-octs
               %+  can  3
               :~  [bytes hash]
                   [bytes private-key]
                   [1 0]
                   [bytes v]
               ==
        =.  v  (hmc bytes^k bytes^v)
        =.  k  %+  hmc  [bytes k]
               %-  as-octs
               %+  can  3
               :~  [bytes hash]
                   [bytes private-key]
                   [1 1]
                   [bytes v]
               ==
        =.  v  (hmc bytes^k bytes^v)
        (hmc bytes^k bytes^v)
      ::
      ++  ecdsa-raw-sign
        |=  [hash=@ private-key=@]
        ^-  [r=@ s=@ y=@]
        ::  make-k and priv-to pub will validate inputs
        =/  k   (make-k hash private-key)
        =/  rp  (priv-to-pub k)
        =*  r   x.rp
        ?<  =(0 r)
        =/  fon  field-n
        =+  [fadd fmul finv]=[sum.fon pro.fon inv.fon]
        =/  s  %+  fmul  (finv k)
               %+  fadd  hash
               %+  fmul  r
               private-key
        ?<  =(0 s)
        [r s y.rp]
      ::  general recovery omitted, but possible
      --
    ++  secp256k1
      ~%  %secp256k1  +  ~
      |%
      ++  t  :: in the battery for jet matching
        ^-  domain
        :*  0xffff.ffff.ffff.ffff.ffff.ffff.ffff.ffff.
            ffff.ffff.ffff.ffff.ffff.fffe.ffff.fc2f
            0
            7
            :-  0x79be.667e.f9dc.bbac.55a0.6295.ce87.0b07.
                  029b.fcdb.2dce.28d9.59f2.815b.16f8.1798
                0x483a.da77.26a3.c465.5da4.fbfc.0e11.08a8.
                  fd17.b448.a685.5419.9c47.d08f.fb10.d4b8
            0xffff.ffff.ffff.ffff.ffff.ffff.ffff.fffe.
              baae.dce6.af48.a03b.bfd2.5e8c.d036.4141
        ==
      ::
      ++  curve             ~(. secp 32 t)
      ++  serialize-point   serialize-point:curve
      ++  compress-point    compress-point:curve
      ++  decompress-point  decompress-point:curve
      ++  add-points        add-points:curve
      ++  mul-point-scalar  mul-point-scalar:curve
      ++  make-k
        ~/  %make
        |=  [hash=@uvI private-key=@]
        ::  checks sizes
        (make-k:curve hash private-key)
      ++  priv-to-pub
        |=  private-key=@
        ::  checks sizes
        (priv-to-pub:curve private-key)
      ::
      ++  ecdsa-raw-sign
        ~/  %sign
        |=  [hash=@uvI private-key=@]
        ^-  [v=@ r=@ s=@]
        =/  c  curve
        ::  raw-sign checks sizes
        =+  (ecdsa-raw-sign.c hash private-key)
        =/  rp=point  [r y]
        =/  s-high  (gte (mul 2 s) n.domain.c)
        =?  s   s-high
          (sub n.domain.c s)
        =?  rp  s-high
          [x.rp (sub p.domain.c y.rp)]
        =/  v   (end 0 y.rp)
        =?  v   (gte x.rp n.domain.c)
          (add v 2)
        [v x.rp s]
      ::
      ++  ecdsa-raw-recover
        ~/  %reco
        |=  [hash=@ sig=[v=@ r=@ s=@]]
        ^-  point
        ?>  (lte v.sig 3)
        =/  c   curve
        ?>  (valid-hash.c hash)
        ?>  (in-order.c r.sig)
        ?>  (in-order.c s.sig)
        =/  x  ?:  (gte v.sig 2)
                 (add r.sig n.domain.c)
               r.sig
        =/  fop  field-p.c
        =+  [fadd fmul fpow]=[sum.fop pro.fop exp.fop]
        =/  ysq   (fadd (fpow 3 x) b.domain.c)
        =/  beta  (fpow (rsh [0 2] +(p.domain.c)) ysq)
        =/  y  ?:  =((end 0 v.sig) (end 0 beta))
                 beta
               (sub p.domain.c beta)
        ?>  =(0 (dif.fop ysq (fmul y y)))
        =/  nz   (sub n.domain.c hash)
        =/  j    jc.c
        =/  gz   (mul.j (into.j g.domain.c) nz)
        =/  xy   (mul.j (into.j x y) s.sig)
        =/  qr   (add.j gz xy)
        =/  qj   (mul.j qr (inv:field-n.c x))
        =/  pub  (from.j qj)
        ?<  =([0 0] pub)
        pub
      ++  schnorr
        ::~%  %schnorr  ..schnorr  ~
        =>  |%
            ++  tagged-hash
              |=  [tag=@ [l=@ x=@]]
              =+  hat=(sha-256:sha (swp 3 tag))
              %-  sha-256l:sha
              :-  (add 64 l)
              (can 3 ~[[l x] [32 hat] [32 hat]])
            ++  lift-x
              |=  x=@I
              ^-  (unit point)
              =/  c  curve
              ?.  (lth x p.domain.c)
                ~
              =/  fop  field-p.c
              =+  [fadd fpow]=[sum.fop exp.fop]
              =/  cp  (fadd (fpow 3 x) 7)
              =/  y  (fpow (rsh [0 2] +(p.domain.c)) cp)
              ?.  =(cp (fpow 2 y))
                ~
              %-  some  :-  x
              ?:  =(0 (mod y 2))
                y
              (sub p.domain.c y)
            --
        |%
        ::
        ++  sign                                        ::  schnorr signature
          ~/  %sosi
          |=  [sk=@I m=@I a=@I]
          ^-  @J
          ?>  (gte 32 (met 3 m))
          ?>  (gte 32 (met 3 a))
          =/  c  curve
          ::  implies (gte 32 (met 3 sk))
          ::
          ?<  |(=(0 sk) (gte sk n.domain.c))
          =/  pp
            (mul-point-scalar g.domain.c sk)
          =/  d
            ?:  =(0 (mod y.pp 2))
              sk
            (sub n.domain.c sk)
          =/  t
            %+  mix  d
            (tagged-hash 'BIP0340/aux' [32 a])
          =/  rand
            %+  tagged-hash  'BIP0340/nonce'
            :-  96
            (rep 8 ~[m x.pp t])
          =/  kp  (mod rand n.domain.c)
          ?<  =(0 kp)
          =/  rr  (mul-point-scalar g.domain.c kp)
          =/  k
            ?:  =(0 (mod y.rr 2))
              kp
            (sub n.domain.c kp)
          =/  e
            %-  mod
            :_  n.domain.c
            %+  tagged-hash  'BIP0340/challenge'
            :-  96
            (rep 8 ~[m x.pp x.rr])
          =/  sig
            %^  cat  8
              (mod (add k (mul e d)) n.domain.c)
            x.rr
          ?>  (verify x.pp m sig)
          sig
        ::
        ++  verify                                      ::  schnorr verify
          ~/  %sove
          |=  [pk=@I m=@I sig=@J]
          ^-  ?
          ?>  (gte 32 (met 3 pk))
          ?>  (gte 32 (met 3 m))
          ?>  (gte 64 (met 3 sig))
          =/  c  curve
          =/  pup  (lift-x pk)
          ?~  pup
            %.n
          =/  pp  u.pup
          =/  r  (cut 8 [1 1] sig)
          ?:  (gte r p.domain.c)
            %.n
          =/  s  (end 8 sig)
          ?:  (gte s n.domain.c)
            %.n
          =/  e
            %-  mod
            :_  n.domain.c
            %+  tagged-hash  'BIP0340/challenge'
            :-  96
            (rep 8 ~[m x.pp r])
          =/  aa
            (mul-point-scalar g.domain.c s)
          =/  bb
            (mul-point-scalar pp (sub n.domain.c e))
          ?:  &(=(x.aa x.bb) !=(y.aa y.bb))             ::  infinite?
            %.n
          =/  rr  (add-points aa bb)
          ?.  =(0 (mod y.rr 2))
            %.n
          =(r x.rr)
        --
      --
    --
  ::
  ++  blake
      ~%  %blake  ..crypto  ~
      |%
      ++  blake3
        =<
          =<  hash  :: cuter API
          =+  [cv=iv flags=0b0]
          ^?  ~/  %blake3
          |%
          ::
          ++  keyed  |=(key=octs hash(cv q.key, flags f-keyedhash))
          ::
          ++  kdf
            |=  [out=@ud ctx=tape seed=octs]
            ^-  @ux
            =/  der  (hash(cv iv, flags f-derivekeyctx) 32 (lent ctx)^(crip ctx))
            (hash(cv der, flags f-derivekeymat) out seed)
          ::
          ++  hash
            ~/  %hash
            |=  [out=@ud msg=octs]
            ^-  @ux
            =/  root  (root-output (turn (split-octs 13 msg) chunk-output))
            %+  end  [3 out]
            %+  rep  9
            %+  turn  (gulf 0 (div out 64))
            |=(i=@ (compress root(counter i)))
          ::
          ++  root-output
            |=  outputs=(list output)
            ^-  output
            %+  set-flag  f-root
            |-
            =/  mid  (div (bex (xeb (dec (lent outputs)))) 2)
            =+  [l=(scag mid outputs) r=(slag mid outputs)]
            ?>  ?=(^ outputs)
            ?~  t.outputs  i.outputs
            %-  parent-output
            [(compress $(outputs l)) (compress $(outputs r))]
          ::
          ++  parent-output
            |=  [l=@ux r=@ux]
            ^-  output
            %+  set-flag  f-parent
            [cv 0 (rep 8 ~[l r]) 64 flags]
          ::
          ++  chunk-output
            ~/  %chunk-output
            |=  [counter=@ chunk=octs]
            ^-  output
            %+  set-flag  f-chunkend
            %+  roll  (split-octs 9 chunk)
            |=  [[i=@ block=octs] prev=output]
            ?:  =(0 i)  [cv counter q.block p.block (con flags f-chunkstart)]
            [(output-cv prev) counter q.block p.block flags]
          --
        ::~%  %blake3-impl  ..blake3  ~
        |%
        ::
        +$  output
          $:  cv=@ux
              counter=@ud
              block=@ux
              blocklen=@ud
              flags=@ub
          ==
        ::
        ++  compress
          ~/  %compress
          |=  output
          ^-  @
          |^
            =/  state  (can32 [8 cv] [4 iv] [2 counter] [1 blocklen] [1 flags] ~)
            =.  state  (round state block)  =.  block  (permute block)
            =.  state  (round state block)  =.  block  (permute block)
            =.  state  (round state block)  =.  block  (permute block)
            =.  state  (round state block)  =.  block  (permute block)
            =.  state  (round state block)  =.  block  (permute block)
            =.  state  (round state block)  =.  block  (permute block)
            =.  state  (round state block)  (mix state (rep 8 ~[(rsh 8 state) cv]))
          ::
          ++  round
            |=  [state=@ block=@]
            ^+  state
            |^
              =.  state  (g 0x0 0x4 0x8 0xc 0x0 0x1)
              =.  state  (g 0x1 0x5 0x9 0xd 0x2 0x3)
              =.  state  (g 0x2 0x6 0xa 0xe 0x4 0x5)
              =.  state  (g 0x3 0x7 0xb 0xf 0x6 0x7)
              =.  state  (g 0x0 0x5 0xa 0xf 0x8 0x9)
              =.  state  (g 0x1 0x6 0xb 0xc 0xa 0xb)
              =.  state  (g 0x2 0x7 0x8 0xd 0xc 0xd)
              =.  state  (g 0x3 0x4 0x9 0xe 0xe 0xf)
              state
            ::
            ++  g
              |=  [a=@ b=@ c=@ d=@ mx=@ my=@]
              ^+  state
              =.  state  (set a :(sum32 (get a) (get b) (getb mx)))
              =.  state  (set d (rox (get d) (get a) 16))
              =.  state  (set c :(sum32 (get c) (get d)))
              =.  state  (set b (rox (get b) (get c) 12))
              =.  state  (set a :(sum32 (get a) (get b) (getb my)))
              =.  state  (set d (rox (get d) (get a) 8))
              =.  state  (set c :(sum32 (get c) (get d)))
              =.  state  (set b (rox (get b) (get c) 7))
              state
            ::
            ++  getb  (curr get32 block)
            ++  get  (curr get32 state)
            ++  set  |=([i=@ w=@] (set32 i w state))
            ++  rox  |=([a=@ b=@ n=@] (ror32 n (mix a b)))
            --
          ::
          ++  permute
            |=  block=@
            ^+  block
            (rep 5 (turn perm (curr get32 block)))
          --
        ::  constants and helpers
        ::
        ++  iv  0x5be0.cd19.1f83.d9ab.9b05.688c.510e.527f.
                  a54f.f53a.3c6e.f372.bb67.ae85.6a09.e667
        ++  perm  (rip 2 0x8fe9.5cb1.d407.a362)
        ++  f-chunkstart    ^~  (bex 0)
        ++  f-chunkend      ^~  (bex 1)
        ++  f-parent        ^~  (bex 2)
        ++  f-root          ^~  (bex 3)
        ++  f-keyedhash     ^~  (bex 4)
        ++  f-derivekeyctx  ^~  (bex 5)
        ++  f-derivekeymat  ^~  (bex 6)
        ++  set-flag  |=([f=@ o=output] o(flags (con flags.o f)))
        ++  fe32   ~(. fe 5)
        ++  ror32  (cury ror:fe32 0)
        ++  sum32  sum:fe32
        ++  can32  (cury can 5)
        ++  get32  |=([i=@ a=@] (cut 5 [i 1] a))
        ++  set32  |=([i=@ w=@ a=@] (sew 5 [i 1 w] a))
        ++  output-cv  |=(o=output `@ux`(rep 8 ~[(compress o)]))
        ++  split-octs
          |=  [a=bloq msg=octs]
          ^-  (list [i=@ octs])
          ?>  ?=(@ q.msg)  :: simplfy jet logic
          =/  per  (bex (sub a 3))
          =|  chunk-octs=(list [i=@ octs])
          =|  i=@
          |-
          ?:  (lte p.msg per)  [[i msg] chunk-octs]
          :-  [i per^(end a q.msg)]
          $(i +(i), msg (sub p.msg per)^(rsh a q.msg))
        --  ::  blake3-impl
      ::
      ::TODO  generalize for both blake2 variants
      ++  blake2b
        ::~/  %blake2b
        |=  [msg=byts key=byts out=@ud]
        ^-  @
        ::  initialization vector
        =/  iv=@
          0x6a09.e667.f3bc.c908.
            bb67.ae85.84ca.a73b.
            3c6e.f372.fe94.f82b.
            a54f.f53a.5f1d.36f1.
            510e.527f.ade6.82d1.
            9b05.688c.2b3e.6c1f.
            1f83.d9ab.fb41.bd6b.
            5be0.cd19.137e.2179
        ::  per-round constants
        =/  sigma=(list (list @ud))
          :~
            :~   0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  ==
            :~  14  10   4   8   9  15  13   6   1  12   0   2  11   7   5   3  ==
            :~  11   8  12   0   5   2  15  13  10  14   3   6   7   1   9   4  ==
            :~   7   9   3   1  13  12  11  14   2   6   5  10   4   0  15   8  ==
            :~   9   0   5   7   2   4  10  15  14   1  11  12   6   8   3  13  ==
            :~   2  12   6  10   0  11   8   3   4  13   7   5  15  14   1   9  ==
            :~  12   5   1  15  14  13   4  10   0   7   6   3   9   2   8  11  ==
            :~  13  11   7  14  12   1   3   9   5   0  15   4   8   6   2  10  ==
            :~   6  15  14   9  11   3   0   8  12   2  13   7   1   4  10   5  ==
            :~  10   2   8   4   7   6   1   5  15  11   9  14   3  12  13   0  ==
            :~   0   1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  ==
            :~  14  10   4   8   9  15  13   6   1  12   0   2  11   7   5   3  ==
          ==
        =>  |%
            ++  get-word-list
              |=  [h=@ w=@ud]
              ^-  (list @)
              %-  flop
              =+  l=(rip 6 h)
              =-  (weld - l)
              (reap (sub w (lent l)) 0)
            ::
            ++  get-word
              |=  [h=@ i=@ud w=@ud]
              ^-  @
              %+  snag  i
              (get-word-list h w)
            ::
            ++  put-word
              |=  [h=@ i=@ud w=@ud d=@]
              ^-  @
              %+  rep  6
              =+  l=(get-word-list h w)
              %-  flop
              %+  weld  (scag i l)
              [d (slag +(i) l)]
            ::
            ++  mod-word
              |*  [h=@ i=@ud w=@ud g=$-(@ @)]
              (put-word h i w (g (get-word h i w)))
            ::
            ++  pad
              |=  [byts len=@ud]
              (lsh [3 (sub len wid)] dat)
            ::
            ++  compress
              |=  [h=@ c=@ t=@ud l=?]
              ^-  @
              ::  set up local work vector
              =+  v=(add (lsh [6 8] h) iv)
              ::  xor the counter t into v
              =.  v
                %-  mod-word
                :^  v  12  16
                (cury mix (end [0 64] t))
              =.  v
                %-  mod-word
                :^  v  13  16
                (cury mix (rsh [0 64] t))
              ::  for the last block, invert v14
              =?  v  l
                %-  mod-word
                :^  v  14  16
                (cury mix 0xffff.ffff.ffff.ffff)
              ::  twelve rounds of message mixing
              =+  i=0
              =|  s=(list @)
              |^
                ?:  =(i 12)
                  ::  xor upper and lower halves of v into state h
                  =.  h  (mix h (rsh [6 8] v))
                  (mix h (end [6 8] v))
                ::  select message mixing schedule and mix v
                =.  s  (snag (mod i 10) sigma)
                =.  v  (do-mix 0 4 8 12 0 1)
                =.  v  (do-mix 1 5 9 13 2 3)
                =.  v  (do-mix 2 6 10 14 4 5)
                =.  v  (do-mix 3 7 11 15 6 7)
                =.  v  (do-mix 0 5 10 15 8 9)
                =.  v  (do-mix 1 6 11 12 10 11)
                =.  v  (do-mix 2 7 8 13 12 13)
                =.  v  (do-mix 3 4 9 14 14 15)
                $(i +(i))
              ::
              ++  do-mix
                |=  [na=@ nb=@ nc=@ nd=@ nx=@ ny=@]
                ^-  @
                =-  =.  v  (put-word v na 16 a)
                    =.  v  (put-word v nb 16 b)
                    =.  v  (put-word v nc 16 c)
                           (put-word v nd 16 d)
                %-  b2mix
                :*  (get-word v na 16)
                    (get-word v nb 16)
                    (get-word v nc 16)
                    (get-word v nd 16)
                    (get-word c (snag nx s) 16)
                    (get-word c (snag ny s) 16)
                ==
              --
            ::
            ++  b2mix
              |=  [a=@ b=@ c=@ d=@ x=@ y=@]
              ^-  [a=@ b=@ c=@ d=@]
              =.  x  (rev 3 8 x)
              =.  y  (rev 3 8 y)
              =+  fed=~(. fe 6)
              =.  a  :(sum:fed a b x)
              =.  d  (ror:fed 0 32 (mix d a))
              =.  c  (sum:fed c d)
              =.  b  (ror:fed 0 24 (mix b c))
              =.  a  :(sum:fed a b y)
              =.  d  (ror:fed 0 16 (mix d a))
              =.  c  (sum:fed c d)
              =.  b  (ror:fed 0 63 (mix b c))
              [a b c d]
            --
        ::  ensure inputs adhere to contraints
        =.  out  (max 1 (min out 64))
        =.  wid.msg  (min wid.msg (bex 128))
        =.  wid.key  (min wid.key 64)
        =.  dat.msg  (end [3 wid.msg] dat.msg)
        =.  dat.key  (end [3 wid.key] dat.key)
        ::  initialize state vector
        =+  h=iv
        ::  mix key length and output length into h0
        =.  h
          %-  mod-word
          :^  h  0  8
          %+  cury  mix
          %+  add  0x101.0000
          (add (lsh 3 wid.key) out)
        ::  keep track of how much we've compressed
        =*  mes  dat.msg
        =+  com=0
        =+  rem=wid.msg
        ::  if we have a key, pad it and prepend to msg
        =?  mes  (gth wid.key 0)
          (can 3 ~[rem^mes 128^(pad key 128)])
        =?  rem  (gth wid.key 0)
          (add rem 128)
        |-
        ::  compress 128-byte chunks of the message
        ?:  (gth rem 128)
          =+  c=(cut 3 [(sub rem 128) 128] mes)
          =.  com   (add com 128)
          %_  $
            rem   (sub rem 128)
            h     (compress h c com |)
          ==
        ::  compress the final bytes of the msg
        =+  c=(cut 3 [0 rem] mes)
        =.  com  (add com rem)
        =.  c  (pad [rem c] 128)
        =.  h  (compress h c com &)
        ::  produce output of desired length
        %+  rsh  [3 (sub 64 out)]
        ::  do some word
        %+  rep  6
        %+  turn  (flop (gulf 0 7))
        |=  a=@
        (rev 3 8 (get-word h a 8))
      --  ::blake
  ::
  ++  argon2
    ~%  %argon  ..crypto  ~
    |%
    ::
    ::  structures
    ::
    +$  argon-type  ?(%d %i %id %u)
    ::
    ::  shorthands
    ::
    ++  argon2-nockchain
    ^-  $-([msg=byts sat=byts] @)
    %:  argon2
        out=32
        typ=%d
        version=0x13
        threads=4
        mem-cost=786.432  ::  6GiB
        time-cost=6
        key=*byts
        extra=*byts
    ==
    ::  argon2 proper
    ::
    ::  main argon2 operation
    ++  argon2
      ::  out:       desired output size in bytes
      ::  typ:       argon2 type
      ::  version:   argon2 version (0x10/v1.0 or 0x13/v1.3)
      ::  threads:   amount of threads/parallelism
      ::  mem-cost:  kb of memory to use
      ::  time-cost: iterations to run
      ::  key:       optional secret
      ::  extra:     optional arbitrary data
      |=  $:  out=@ud
              typ=argon-type
              version=@ux
            ::
              threads=@ud
              mem-cost=@ud
              time-cost=@ud
            ::
              key=byts
              extra=byts
          ==
      ^-  $-([msg=byts sat=byts] @)
      ::
      ::  check configuration sanity
      ::
      ?:  =(0 threads)
        ~|  %parallelism-must-be-above-zero
        !!
      ?:  =(0 time-cost)
        ~|  %time-cost-must-be-above-zero
        !!
      ?:  (lth mem-cost (mul 8 threads))
        ~|  :-  %memory-cost-must-be-at-least-threads
            [threads %times 8 (mul 8 threads)]
        !!
      ?.  |(=(0x10 version) =(0x13 version))
        ~|  [%unsupported-version version %want [0x10 0x13]]
        !!
      ::
      ::  main function
      ::
      ::  msg: the main input
      ::  sat: optional salt
      ~%  %argon2  ..argon2  ~
      |=  [msg=byts sat=byts]
      ^-  @
      ::
      ::  calculate constants and initialize buffer
      ::
      ::  for each thread, there is a row in the buffer.
      ::  the amount of columns depends on the memory-cost.
      ::  columns are split into groups of four.
      ::  a single such quarter section of a row is a segment.
      ::
      ::  blocks:     (m_prime)
      ::  columns:    row length (q)
      ::  seg-length: segment length
      =/  blocks=@ud
        ::  round mem-cost down to the nearest multiple of 4*threads
        =+  (mul 4 threads)
        (mul (div mem-cost -) -)
      =+  columns=(div blocks threads)
      =+  seg-length=(div columns 4)
      ::
      =/  buffer=(list (list @))
        (reap threads (reap columns 0))
      ?:  (lth wid.sat 8)
        ~|  [%min-salt-length-is-8 wid.sat]
        !!
      ::
      ::  h0: initial 64-byte block
      =/  h0=@
        =-  (blake2b:blake - 0^0 64)
        :-  :(add 40 wid.msg wid.sat wid.key wid.extra)
        %+  can  3
        =+  (cury (cury rev 3) 4)
        :~  (prep-wid extra)
            (prep-wid key)
            (prep-wid sat)
            (prep-wid msg)
            4^(- (type-to-num typ))
            4^(- version)
            4^(- time-cost)
            4^(- mem-cost)
            4^(- out)
            4^(- threads)
        ==
      ::
      ::  do time-cost passes over the buffer
      ::
      =+  t=0
      |-
      ?:  (lth t time-cost)
        ::
        ::  process all four segments in the columns...
        ::
        =+  s=0
        |-
        ?.  (lth s 4)  ^$(t +(t))
        ::
        ::  ...of every row/thread
        ::
        =+  r=0
        |-
        ?.  (lth r threads)  ^$(s +(s))
        =;  new=_buffer
          $(buffer new, r +(r))
        %-  fill-segment
        :*  buffer   h0
            t        s          r
            blocks   columns    seg-length
            threads  time-cost  typ         version
        ==
      ::
      ::  mix all rows together and hash the result
      ::
      =+  r=0
      =|  final=@
      |-
      ?:  =(r threads)
        (hash 1.024^final out)
      =-  $(final -, r +(r))
      %+  mix  final
      (snag (dec columns) (snag r buffer))
    ::
    ::  per-segment computation
    ++  fill-segment
      |=  $:  buffer=(list (list @))
              h0=@
            ::
              itn=@ud
              seg=@ud
              row=@ud
            ::
              blocks=@ud
              columns=@ud
              seg-length=@ud
            ::
              threads=@ud
              time-cost=@ud
              typ=argon-type
              version=@ux
          ==
      ::
      ::  fill-segment utilities
      ::
      =>  |%
          ++  put-word
            |=  [rob=(list @) i=@ud d=@]
            %+  weld  (scag i rob)
            [d (slag +(i) rob)]
          --
      ^+  buffer
      ::
      ::  rob:   row buffer to operate on
      ::  do-i:  whether to use prns from input rather than state
      ::  rands: prns generated from input, if we do-i
      =+  rob=(snag row buffer)
      =/  do-i=?
        ?|  ?=(%i typ)
            &(?=(%id typ) =(0 itn) (lte seg 1))
            &(?=(%u typ) =(0 itn) (lte seg 2))
        ==
      =/  rands=(list (pair @ @))
        ?.  do-i  ~
        ::
        ::  keep going until we have a list of :seg-length prn pairs
        ::
        =+  l=0
        =+  counter=1
        |-  ^-  (list (pair @ @))
        ?:  (gte l seg-length)  ~
        =-  (weld - $(counter +(counter), l (add l 128)))
        ::
        ::  generate pseudorandom block by compressing metadata
        ::
        =/  random-block=@
          %+  compress  0
          %+  compress  0
          %+  lsh  [3 968]
          %+  rep  6
          =+  (cury (cury rev 3) 8)
          :~  (- counter)
              (- (type-to-num typ))
              (- time-cost)
              (- blocks)
              (- seg)
              (- row)
              (- itn)
          ==
        ::
        ::  split the random-block into 64-bit sections,
        ::  then extract the first two 4-byte sections from each.
        ::
        %+  turn  (flop (rip 6 random-block))
        |=  a=@
        ^-  (pair @ @)
        :-  (rev 3 4 (rsh 5 a))
        (rev 3 4 (end 5 a))
      ::
      ::  iterate over the entire segment length
      ::
      =+  sin=0
      |-
      ::
      ::  when done, produce the updated buffer
      ::
      ?:  =(sin seg-length)
        %+  weld  (scag row buffer)
        [rob (slag +(row) buffer)]
      ::
      ::  col: current column to process
      =/  col=@ud
        (add (mul seg seg-length) sin)
      ::
      ::  first two columns are generated from h0
      ::
      ?:  &(=(0 itn) (lth col 2))
        =+  (app-num (app-num 64^h0 col) row)
        =+  (hash - 1.024)
        $(rob (put-word rob col -), sin +(sin))
      ::
      ::  c1, c2: prns for picking reference block
      =/  [c1=@ c2=@]
        ?:  do-i  (snag sin rands)
        =+  =-  (snag - rob)
            ?:  =(0 col)  (dec columns)
            (mod (dec col) columns)
        :-  (rev 3 4 (cut 3 [1.020 4] -))
        (rev 3 4 (cut 3 [1.016 4] -))
      ::
      ::  ref-row: reference block row
      =/  ref-row=@ud
        ?:  &(=(0 itn) =(0 seg))  row
        (mod c2 threads)
      ::
      ::  ref-col: reference block column
      =/  ref-col=@ud
        =-  (mod - columns)
        %+  add
          ::  starting index
          ?:  |(=(0 itn) =(3 seg))  0
          (mul +(seg) seg-length)
        ::  pseudorandom offset
        =-  %+  sub  (dec -)
            %+  rsh  [0 32]
            %+  mul  -
            (rsh [0 32] (mul c1 c1))
        ::  reference area size
        ?:  =(0 itn)
          ?:  |(=(0 seg) =(row ref-row))  (dec col)
          ?:  =(0 sin)  (dec (mul seg seg-length))
          (mul seg seg-length)
        =+  sul=(sub columns seg-length)
        ?:  =(ref-row row)   (dec (add sul sin))
        ?:  =(0 sin)  (dec sul)
        sul
      ::
      ::  compress the previous and reference block
      ::  to create the new block
      ::
      =/  new=@
        %+  compress
          =-  (snag - rob)
          ::  previous index, wrap-around
          ?:  =(0 col)  (dec columns)
          (mod (dec col) columns)
        ::  get reference block
        %+  snag  ref-col
        ?:  =(ref-row row)  rob
        (snag ref-row buffer)
      ::
      ::  starting from v1.3, we xor the new block in,
      ::  rather than directly overwriting the old block
      ::
      =?  new  &(!=(0 itn) =(0x13 version))
        (mix new (snag col rob))
      $(rob (put-word rob col new), sin +(sin))
    ::
    ::  compression function (g)
    ++  compress
      ::  x, y: assumed to be 1024 bytes
      |=  [x=@ y=@]
      ^-  @
      ::
      =+  r=(mix x y)
      =|  q=(list @)
      ::
      ::  iterate over rows of r to get q
      ::
      =+  i=0
      |-
      ?:  (lth i 8)
        =;  p=(list @)
          $(q (weld q p), i +(i))
        %-  permute
        =-  (weld (reap (sub 8 (lent -)) 0) -)
        %-  flop
        %+  rip  7
        (cut 10 [(sub 7 i) 1] r)
      ::
      ::  iterate over columns of q to get z
      ::
      =/  z=(list @)  (reap 64 0)
      =.  i  0
      |-
      ::
      ::  when done, assemble z and xor it with r
      ::
      ?.  (lth i 8)
        (mix (rep 7 (flop z)) r)
      ::
      ::  permute the column
      ::
      =/  out=(list @)
        %-  permute
        :~  (snag i q)
            (snag (add i 8) q)
            (snag (add i 16) q)
            (snag (add i 24) q)
            (snag (add i 32) q)
            (snag (add i 40) q)
            (snag (add i 48) q)
            (snag (add i 56) q)
        ==
      ::
      ::  put the result into z per column
      ::
      =+  j=0
      |-
      ?:  =(8 j)  ^$(i +(i))
      =-  $(z -, j +(j))
      =+  (add i (mul j 8))
      %+  weld  (scag - z)
      [(snag j out) (slag +(-) z)]
    ::
    ::  permutation function (p)
    ++  permute
      ::NOTE  this function really just takes and produces
      ::      8 values, but taking and producing them as
      ::      lists helps clean up the code significantly.
      |=  s=(list @)
      ?>  =(8 (lent s))
      ^-  (list @)
      ::
      ::  list inputs as 16 8-byte values
      ::
      =/  v=(list @)
        %-  zing
        ^-  (list (list @))
        %+  turn  s
        |=  a=@
        ::  rev for endianness
        =+  (rip 6 (rev 3 16 a))
        (weld - (reap (sub 2 (lent -)) 0))
      ::
      ::  do permutation rounds
      ::
      =.  v  (do-round v 0 4 8 12)
      =.  v  (do-round v 1 5 9 13)
      =.  v  (do-round v 2 6 10 14)
      =.  v  (do-round v 3 7 11 15)
      =.  v  (do-round v 0 5 10 15)
      =.  v  (do-round v 1 6 11 12)
      =.  v  (do-round v 2 7 8 13)
      =.  v  (do-round v 3 4 9 14)
      ::  rev for endianness
      =.  v  (turn v (cury (cury rev 3) 8))
      ::
      ::  cat v back together into 8 16-byte values
      ::
      %+  turn  (gulf 0 7)
      |=  i=@
      =+  (mul 2 i)
      (cat 6 (snag +(-) v) (snag - v))
    ::
    ::  perform a round and produce updated value list
    ++  do-round
      |=  [v=(list @) na=@ nb=@ nc=@ nd=@]
      ^+  v
      =>  |%
          ++  get-word
            |=  i=@ud
            (snag i v)
          ::
          ++  put-word
            |=  [i=@ud d=@]
            ^+  v
            %+  weld  (scag i v)
            [d (slag +(i) v)]
          --
      =-  =.  v  (put-word na a)
          =.  v  (put-word nb b)
          =.  v  (put-word nc c)
                 (put-word nd d)
      %-  round
      :*  (get-word na)
          (get-word nb)
          (get-word nc)
          (get-word nd)
      ==
    ::
    ::  perform a round (bg) and produce updated values
    ++  round
      |=  [a=@ b=@ c=@ d=@]
      ^-  [a=@ b=@ c=@ d=@]
      ::  operate on 64 bit words
      =+  fed=~(. fe 6)
      =*  sum  sum:fed
      =*  ror  ror:fed
      =+  end=(cury end 5)
      =.  a  :(sum a b :(mul 2 (end a) (end b)))
      =.  d  (ror 0 32 (mix d a))
      =.  c  :(sum c d :(mul 2 (end c) (end d)))
      =.  b  (ror 0 24 (mix b c))
      =.  a  :(sum a b :(mul 2 (end a) (end b)))
      =.  d  (ror 0 16 (mix d a))
      =.  c  :(sum c d :(mul 2 (end c) (end d)))
      =.  b  (ror 0 63 (mix b c))
      [a b c d]
    ::
    ::  argon2 wrapper around blake2b (h')
    ++  hash
      =,  blake
      |=  [byts out=@ud]
      ^-  @
      ::
      ::  msg: input with byte-length prepended
      =+  msg=(prep-num [wid dat] out)
      ::
      ::  if requested size is low enough, hash directly
      ::
      ?:  (lte out 64)
        (blake2b msg 0^0 out)
      ::
      ::  build up the result by hashing and re-hashing
      ::  the input message, adding the first 32 bytes
      ::  of the hash to the result, until we have the
      ::  desired output size.
      ::
      =+  tmp=(blake2b msg 0^0 64)
      =+  res=(rsh [3 32] tmp)
      =.  out  (sub out 32)
      |-
      ?:  (gth out 64)
        =.  tmp  (blake2b 64^tmp 0^0 64)
        =.  res  (add (lsh [3 32] res) (rsh [3 32] tmp))
        $(out (sub out 32))
      %+  add  (lsh [3 out] res)
      (blake2b 64^tmp 0^0 out)
    ::
    ::  utilities
    ::
    ++  type-to-num
      |=  t=argon-type
      ?-  t
        %d    0
        %i    1
        %id   2
        %u   10
      ==
    ::
    ++  app-num
      |=  [byts num=@ud]
      ^-  byts
      :-  (add wid 4)
      %+  can  3
      ~[4^(rev 3 4 num) wid^dat]
    ::
    ++  prep-num
      |=  [byts num=@ud]
      ^-  byts
      :-  (add wid 4)
      %+  can  3
      ~[wid^dat 4^(rev 3 4 num)]
    ::
    ++  prep-wid
      |=  a=byts
      (prep-num a wid.a)
    -- :: argon2
  ::
  ++  ripemd
    |%
    ++  ripemd-160
      ~/  %ripemd160
      |=  byts
      ^-  @
      ::  we operate on bits rather than bytes
      =.  wid  (mul wid 8)
      ::  add padding
      =+  (md5-pad wid dat)
      ::  endianness
      =.  dat  (run 5 dat |=(a=@ (rev 3 4 a)))
      =*  x  dat
      =+  blocks=(div wid 512)
      =+  fev=~(. fe 5)
      ::  initial register values
      =+  h0=0x6745.2301
      =+  h1=0xefcd.ab89
      =+  h2=0x98ba.dcfe
      =+  h3=0x1032.5476
      =+  h4=0xc3d2.e1f0
      ::  i: current block
      =+  [i=0 j=0]
      =+  *[a=@ b=@ c=@ d=@ e=@]       ::  a..e
      =+  *[aa=@ bb=@ cc=@ dd=@ ee=@]  ::  a'..e'
      |^
        ?:  =(i blocks)
          %+  rep  5
          %+  turn  `(list @)`~[h4 h3 h2 h1 h0]
          ::  endianness
          |=(h=@ (rev 3 4 h))
        =:  a  h0     aa  h0
            b  h1     bb  h1
            c  h2     cc  h2
            d  h3     dd  h3
            e  h4     ee  h4
        ==
        ::  j: current word
        =+  j=0
        |-
        ?:  =(j 80)
          %=  ^$
            i   +(i)
            h1  :(sum:fev h2 d ee)
            h2  :(sum:fev h3 e aa)
            h3  :(sum:fev h4 a bb)
            h4  :(sum:fev h0 b cc)
            h0  :(sum:fev h1 c dd)
          ==
        %=  $
          j  +(j)
        ::
          a   e
          b   (fn j a b c d e (get (r j)) (k j) (s j))
          c   b
          d   (rol 10 c)
          e   d
        ::
          aa  ee
          bb  (fn (sub 79 j) aa bb cc dd ee (get (rr j)) (kk j) (ss j))
          cc  bb
          dd  (rol 10 cc)
          ee  dd
        ==
      ::
      ++  get  ::  word from x in block i
        |=  j=@ud
        =+  (add (mul i 16) +(j))
        (cut 5 [(sub (mul blocks 16) -) 1] x)
      ::
      ++  fn
        |=  [j=@ud a=@ b=@ c=@ d=@ e=@ m=@ k=@ s=@]
        =-  (sum:fev (rol s :(sum:fev a m k -)) e)
        =.  j  (div j 16)
        ?:  =(0 j)  (mix (mix b c) d)
        ?:  =(1 j)  (con (dis b c) (dis (not 0 32 b) d))
        ?:  =(2 j)  (mix (con b (not 0 32 c)) d)
        ?:  =(3 j)  (con (dis b d) (dis c (not 0 32 d)))
        ?:  =(4 j)  (mix b (con c (not 0 32 d)))
        !!
      ::
      ++  rol  (cury rol:fev 0)
      ::
      ++  k
        |=  j=@ud
        =.  j  (div j 16)
        ?:  =(0 j)  0x0
        ?:  =(1 j)  0x5a82.7999
        ?:  =(2 j)  0x6ed9.eba1
        ?:  =(3 j)  0x8f1b.bcdc
        ?:  =(4 j)  0xa953.fd4e
        !!
      ::
      ++  kk  ::  k'
        |=  j=@ud
        =.  j  (div j 16)
        ?:  =(0 j)  0x50a2.8be6
        ?:  =(1 j)  0x5c4d.d124
        ?:  =(2 j)  0x6d70.3ef3
        ?:  =(3 j)  0x7a6d.76e9
        ?:  =(4 j)  0x0
        !!
      ::
      ++  r
        |=  j=@ud
        %+  snag  j
        ^-  (list @)
        :~  0  1  2  3  4  5  6  7  8  9  10  11  12  13  14  15
            7  4  13  1  10  6  15  3  12  0  9  5  2  14  11  8
            3  10  14  4  9  15  8  1  2  7  0  6  13  11  5  12
            1  9  11  10  0  8  12  4  13  3  7  15  14  5  6  2
            4  0  5  9  7  12  2  10  14  1  3  8  11  6  15  13
        ==
      ::
      ++  rr  ::  r'
        |=  j=@ud
        %+  snag  j
        ^-  (list @)
        :~  5  14  7  0  9  2  11  4  13  6  15  8  1  10  3  12
            6  11  3  7  0  13  5  10  14  15  8  12  4  9  1  2
            15  5  1  3  7  14  6  9  11  8  12  2  10  0  4  13
            8  6  4  1  3  11  15  0  5  12  2  13  9  7  10  14
            12  15  10  4  1  5  8  7  6  2  13  14  0  3  9  11
        ==
      ::
      ++  s
        |=  j=@ud
        %+  snag  j
        ^-  (list @)
        :~  11  14  15  12  5  8  7  9  11  13  14  15  6  7  9  8
            7  6  8  13  11  9  7  15  7  12  15  9  11  7  13  12
            11  13  6  7  14  9  13  15  14  8  13  6  5  12  7  5
            11  12  14  15  14  15  9  8  9  14  5  6  8  6  5  12
            9  15  5  11  6  8  13  12  5  12  13  14  11  8  5  6
        ==
      ::
      ++  ss  ::  s'
        |=  j=@ud
        %+  snag  j
        ^-  (list @)
        :~  8  9  9  11  13  15  15  5  7  7  8  11  14  14  12  6
            9  13  15  7  12  8  9  11  7  7  12  7  6  15  13  11
            9  7  15  11  8  6  6  14  12  13  5  14  13  13  7  5
            15  5  8  11  14  14  6  14  6  9  12  9  12  5  15  8
            8  5  12  9  12  5  14  6  8  13  6  5  15  13  11  11
        ==
      --
    ::
    ++  md5-pad
      |=  byts
      ^-  byts
      =+  (sub 511 (mod (add wid 64) 512))
      :-  :(add 64 +(-) wid)
      %+  can  0
      ~[64^(rev 3 8 wid) +(-)^(lsh [0 -] 1) wid^dat]
    --
  ::
  ++  pbkdf
    =>  |%
        ++  meet  |=([p=@ s=@ c=@ d=@] [[(met 3 p) p] [(met 3 s) s] c d])
        ++  flip  |=  [p=byts s=byts c=@ d=@]
                  [wid.p^(rev 3 p) wid.s^(rev 3 s) c d]
        --
    |%
    ::
    ::  use with @
    ::
    ++  hmac-sha1     (cork meet hmac-sha1l)
    ++  hmac-sha256   (cork meet hmac-sha256l)
    ++  hmac-sha512   (cork meet hmac-sha512l)
    ::
    ::  use with @t
    ::
    ++  hmac-sha1t    (cork meet hmac-sha1d)
    ++  hmac-sha256t  (cork meet hmac-sha256d)
    ++  hmac-sha512t  (cork meet hmac-sha512d)
    ::
    ::  use with byts
    ::
    ++  hmac-sha1l    (cork flip hmac-sha1d)
    ++  hmac-sha256l  (cork flip hmac-sha256d)
    ++  hmac-sha512l  (cork flip hmac-sha512d)
    ::
    ::  main logic
    ::
    ++  hmac-sha1d    (cury pbkdf hmac-sha1l:hmac 20)
    ++  hmac-sha256d  (cury pbkdf hmac-sha256l:hmac 32)
    ++  hmac-sha512d  (cury pbkdf hmac-sha512l:hmac 64)
    ::
    ++  pbkdf
      ::TODO  jet me! ++hmac:hmac is an example
      |*  [[prf=$-([byts byts] @) out=@u] p=byts s=byts c=@ d=@]
      =>  .(dat.p (end [3 wid.p] dat.p), dat.s (end [3 wid.s] dat.s))
      ::
      ::  max key length 1GB
      ::  max iterations 2^28
      ::
      ~|  [%invalid-pbkdf-params c d]
      ?>  ?&  (lte d (bex 30))
              (lte c (bex 28))
              !=(c 0)
          ==
      =/  l
        ?~  (mod d out)
          (div d out)
        +((div d out))
      =+  r=(sub d (mul out (dec l)))
      =+  [t=0 j=1 k=1]
      =.  t
        |-  ^-  @
        ?:  (gth j l)  t
        =/  u
          %+  add  dat.s
          %+  lsh  [3 wid.s]
          %+  rep  3
          (flop (rpp:scr 3 4 j))
        =+  f=0
        =.  f
          |-  ^-  @
          ?:  (gth k c)  f
          =/  q
            %^  rev  3  out
            =+  ?:(=(k 1) (add wid.s 4) out)
            (prf [wid.p (rev 3 p)] [- (rev 3 - u)])
          $(u q, f (mix f q), k +(k))
        $(t (add t (lsh [3 (mul (dec j) out)] f)), j +(j))
      (rev 3 d (end [3 d] t))
    --
--  ::crypto
::
++  acru  $_  ^?                                      ::  asym cryptosuite
  |%                                                  ::  opaque object
  ++  as  ^?                                          ::  asym ops
    |%  ++  seal  |~([a=pass b=@] *@)                 ::  encrypt to a
        ++  sign  |~(a=@ *@)                          ::  certify as us
        ++  sigh  |~(a=@ *@)                          ::  certification only
        ++  sure  |~(a=@ *(unit @))                   ::  authenticate from us
        ++  safe  |~([a=@ b=@] *?)                    ::  authentication only
        ++  tear  |~([a=pass b=@] *(unit @))          ::  accept from a
    --  ::as                                          ::
  ++  de  |~([a=@ b=@] *(unit @))                     ::  symmetric de, soft
  ++  dy  |~([a=@ b=@] *@)                            ::  symmetric de, hard
  ++  en  |~([a=@ b=@] *@)                            ::  symmetric en
  ++  ex  ^?                                          ::  export
    |%  ++  fig  *@uvH                                ::  fingerprint
        ++  pac  *@uvG                                ::  default passcode
        ++  pub  *pass                                ::  public key
        ++  sec  *ring                                ::  private key
    --  ::ex                                          ::
  ++  nu  ^?                                          ::  reconstructors
    |%  ++  pit  |~([a=@ b=@] ^?(..nu))               ::  from [width seed]
        ++  nol  |~(a=ring ^?(..nu))                  ::  from ring
        ++  com  |~(a=pass ^?(..nu))                  ::  from pass
    --  ::nu                                          ::
  --  ::acru
+|  %system
::  $puth: $pith without faces
::
+$  puth  (pole iota)
::  +pith: pith utilities
::
++  trek
  |^  $+(trek pith)
  ++  en-tape
    |=  pit=$
    (spud (pout pit))
  ++  sub
    |=  [from=$ del=$]
    ~|  pith-sub/[from del]
    !.
    |-  ^+  from
    ?~  del  from
    ?>  ?=(^ from)
    ?>  =(-.del -.from)
    $(del +.del, from +.from)
  ::
  ++  en-cord
    |=  pit=$
    (spat (pout pit))
  ::
  ++  prefix
    =|  res=$
    |=  [long=$ curt=$]
    ^-  (unit _res)
    ?~  curt  `(flop res)
    ?~  long  ~
    ?.  =(i.long i.curt)
      ~
    $(long t.long, curt t.curt, res [i.long res])
  ::
  ++  suffix
    |=  [long=$ curt=$]
    ^-  _curt
    ?~  curt
      long
    ?~  long
      ~
    $(curt t.curt, long t.long)
  ++  sort
    |=  [a=$ b=$]
    (lte (lent a) (lent b))
  --
::  $pave: better path to pith
::
++  pave
  |=  p=path
  ^-  trek
  %+  turn  p
  |=  i=@ta
  (fall (rush i spot:stip) [%ta i])
::  $stip:  better typed path parser
::
++  stip
  =<  swot
  |%
  ++  swot  |=(n=nail `(like trek)`(;~(pfix fas (more fas spot)) n))
  ::
  ++  spot
    %+  sear
      |=  a=*
      ^-  (unit iota)
      ?+  a  ~
        @      ?:(((sane %tas) a) [~ `@tas`a] ~)
        [@ @]  ((soft iota) a)
      ==
    %-  stew
    ^.  stet  ^.  limo
    :~  :-  'a'^'z'  sym
        :-  '$'      (cold [%tas %$] buc)
        :-  '0'^'9'  bisk:so
        :-  '-'      tash:so
        :-  '.'      zust:so
        :-  '~'      ;~(pfix sig ;~(pose (stag %da (cook year when:so)) crub:so (easy [%n ~])))
        :-  '\''     (stag %t qut)  ::'
    ==
  --
++  axal
  |$  [item]
  [fil=(unit item) kid=(map iota $)]
++  axil
  |$  [item]
  [fil=(unit item) kid=(map trek item)]
::
++  of
  =|  fat=(axal)
  |@
  ::
  ++  anc-jab
    |*  [pax=trek fun=$-(* *)]
    ^+  fat
    ?~  pax
      fat
    =?  fil.fat  ?=(^ fil.fat)
      `(fun u.fil.fat)
    fat(kid (~(put by kid.fat) i.pax $(fat (~(got by kid.fat) i.pax), pax t.pax)))
  ::
  ++  anc
    =|  res=(list trek)
    =|  cur=trek
    |=  pax=trek
    ^-  (set trek)
    ?~  pax
      (~(gas in *(set trek)) res)
    =?  res  ?=(^ fil.fat)
      [cur res]
    $(fat (~(got by kid.fat) i.pax), pax t.pax, cur (snoc cur i.pax))
  ::
  ++  parent
    =|  res=(unit trek)
    =|  cur=trek
    |=  pax=trek
    |-  ^+  res
    ?~  pax
      res
    =?  res  ?=(^ fil.fat)
      `cur
    =/  nex  (~(get by kid.fat) i.pax)
    ?~  nex
      res
    $(fat u.nex, pax t.pax, cur (snoc cur i.pax))
  ::
  ++  snip
    |-  ^+  fat
    =*  loop  $
    %_    fat
        kid
      %-  ~(run by kid.fat)
      |=  f=_fat
      ?^  fil.f
        [`u.fil.f ~]
      loop(fat f)
    ==
  ::
  ++  kid
    |=  pax=trek
    ^-  (map trek _?>(?=(^ fil.fat) u.fil.fat))
    =.  fat  (dip pax)
    =.  fat  snip
    =.  fil.fat  ~
    tar
  ::
  ++  kids
    |=  pax=trek
    ^-  (axil _?>(?=(^ fil.fat) u.fil.fat))
    :-  (get pax)
    (kid pax)
  ::
  ++  del
    |=  pax=trek
    ^+  fat
    ?~  pax  [~ kid.fat]
    =/  kid  (~(get by kid.fat) i.pax)
    ?~  kid  fat
    fat(kid (~(put by kid.fat) i.pax $(fat u.kid, pax t.pax)))
  ::
  ::  Descend to the axal at this path
  ::
  ++  dip
    |=  pax=trek
    ^+  fat
    ?~  pax  fat
    =/  kid  (~(get by kid.fat) i.pax)
    ?~  kid  [~ ~]
    $(fat u.kid, pax t.pax)
  ::
  ++  gas
    |*  lit=(list (pair trek _?>(?=(^ fil.fat) u.fil.fat)))
    ^+  fat
    ?~  lit  fat
    $(fat (put p.i.lit q.i.lit), lit t.lit)
  ++  got
    |=  pax=trek
    ~|  missing-path/pax
    (need (get pax))
  ++  gut
    |*  [pax=trek dat=*]
    =>  .(dat `_?>(?=(^ fil.fat) u.fil.fat)`dat, pax `trek`pax)
    ^+  dat
    (fall (get pax) dat)
  ::
  ++  get
    |=  pax=trek
    fil:(dip pax)
  ::  Fetch file at longest existing prefix of the path
  ::
  ++  fit
    |=  pax=trek
    ^+  [pax fil.fat]
    ?~  pax  [~ fil.fat]
    =/  kid  (~(get by kid.fat) i.pax)
    ?~  kid  [pax fil.fat]
    =/  low  $(fat u.kid, pax t.pax)
    ?~  +.low
      [pax fil.fat]
    low
  ::
  ++  has
    |=  pax=trek
    !=(~ (get pax))
  ::  Delete subtree
  ::
  ++  lop
    |=  pax=trek
    ^+  fat
    ?~  pax  fat
    |-
    ?~  t.pax  fat(kid (~(del by kid.fat) i.pax))
    =/  kid  (~(get by kid.fat) i.pax)
    ?~  kid  fat
    fat(kid (~(put by kid.fat) i.pax $(fat u.kid, pax t.pax)))
  ::
  ++  put
    |*  [pax=trek dat=*]
    =>  .(dat `_?>(?=(^ fil.fat) u.fil.fat)`dat, pax `trek`pax)
    |-  ^+  fat
    ?~  pax  fat(fil `dat)
    =/  kid  (~(gut by kid.fat) i.pax ^+(fat [~ ~]))
    fat(kid (~(put by kid.fat) i.pax $(fat kid, pax t.pax)))
  ::
  ++  tap
    =|  pax=trek
    =|  out=(list (pair trek _?>(?=(^ fil.fat) u.fil.fat)))
    |-  ^+   out
    =?  out  ?=(^ fil.fat)  :_(out [pax u.fil.fat])
    =/  kid  ~(tap by kid.fat)
    |-  ^+   out
    ?~  kid  out
    %=  $
      kid  t.kid
      out  ^$(pax (weld pax /[p.i.kid]), fat q.i.kid)
    ==
  ::  Serialize to map
  ::
  ++  tar
    (~(gas by *(map trek _?>(?=(^ fil.fat) u.fil.fat))) tap)
  --
--
