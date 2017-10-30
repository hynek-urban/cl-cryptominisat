(load "./cryptominisat.lisp")
(in-package :cl-cryptominisat-test)

(plan nil)

(diag "=== encode-literal ===")
(is (cl-cryptominisat::encode-literal '(4)) 8 "should properly encode positive literals")
(is (cl-cryptominisat::encode-literal '(4 T)) 9 "should properly encode negative literals")

(diag "=== create & destroy solver ===")
(is (cl-cryptominisat::destroy-solver (cl-cryptominisat::create-solver)) nil
    "should create and subsequently destroy the solver instance without issues")

(diag "=== get-vars-cnt ===")
(let ((solver (cl-cryptominisat::create-solver)))
  (cl-cryptominisat::add-new-vars solver 22)
  (is (cl-cryptominisat::get-vars-cnt solver) 22 "should return the declared number of variables")
  (cl-cryptominisat::add-new-vars solver 11)
  (is (cl-cryptominisat::get-vars-cnt solver) 33 "should return the total after adding more variables"))

(diag "=== solve ===")
(let ((solver (cl-cryptominisat::create-solver)))
  (cl-cryptominisat::add-new-vars solver 2)
  (cl-cryptominisat::add-clause solver '((0) (1)))
  (cl-cryptominisat::add-clause solver '((0 T) (1)))
  (cl-cryptominisat::set-num-threads solver 1)
  (is (cl-cryptominisat::solve solver) T "should return T when a solution is found")
  (cl-cryptominisat::add-clause solver '((0 T) (1 T)))
  (cl-cryptominisat::add-clause solver '((0) (1 T)))
  (is (cl-cryptominisat::solve solver) NIL "should return NIL when a solution cannot be found")
  (cl-cryptominisat::destroy-solver solver))

(diag "=== solve-with-assumptions ===")
(let ((solver (cl-cryptominisat::create-solver)))
  (cl-cryptominisat::add-new-vars solver 2)
  (cl-cryptominisat::add-clause solver '((0) (1)))
  (cl-cryptominisat::add-clause solver '((0 T) (1)))
  (is (cl-cryptominisat::solve-with-assumptions solver '((1 T))) NIL "should return NIL when a solution cannot be found")
  (is (cl-cryptominisat::solve-with-assumptions solver '((0 T))) T "should return T when a solution is found")
  (cl-cryptominisat::destroy-solver solver))

(diag "=== get-model ===")
(let ((solver (cl-cryptominisat::create-solver)))
  (cl-cryptominisat::add-new-vars solver 2)
  (cl-cryptominisat::add-clause solver '((0 T)))
  (cl-cryptominisat::add-clause solver '((0) (1)))
  (cl-cryptominisat::solve solver)
  (is (cl-cryptominisat::get-model solver) '(NIL T) "should return the assignment of truth values satisfying the SAT problem")
  (cl-cryptominisat::destroy-solver solver))

(diag "=== get-conflict ===")
(let ((solver (cl-cryptominisat::create-solver)))
  (cl-cryptominisat::add-new-vars solver 2)
  (cl-cryptominisat::add-clause solver '((0 T)))
  (cl-cryptominisat::add-clause solver '((0) (1 T)))
  (cl-cryptominisat::solve-with-assumptions solver '((1)))
  (is (cl-cryptominisat::get-conflict solver) '((1 T)) "should return the found conflict")
  (cl-cryptominisat::destroy-solver solver))

(diag "=== add-xor-clause ===")
(let ((solver (cl-cryptominisat::create-solver)))
  (cl-cryptominisat::add-new-vars solver 2)
  (cl-cryptominisat::add-xor-clause solver '(0 1) T)
  (cl-cryptominisat::add-clause solver '((1 T)))
  (cl-cryptominisat::solve solver)
  (is (cl-cryptominisat::get-model solver) '(T NIL) "should add a XOR clause")
  (cl-cryptominisat::destroy-solver solver))

(finalize)
