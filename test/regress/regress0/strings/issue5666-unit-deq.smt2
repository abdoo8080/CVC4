(set-logic ALL)
(set-info :status sat)
(declare-fun s () (Seq Int))
(declare-fun x () Int)
(assert (= s (seq.unit 0)))
(assert (not (= s (seq.unit x))))
(check-sat)
