(set-option :incremental false)
(set-info :status unsat)
(set-logic QF_BV)
(declare-fun v1 () (_ BitVec 4))
(check-sat-assuming ( (let ((_let_0 (ite (bvslt v1 (_ bv0 4)) (_ bv1 1) (_ bv0 1)))) (= (bvnot _let_0) (bvneg _let_0))) ))