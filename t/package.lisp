#|
  This file is a part of play-on-matrix project.
  Copyright (c) 2016 Masataro Asai (guicho2.71828@gmail.com)
|#

(in-package :cl-user)
(defpackage :play-on-matrix.test
  (:use :cl
        :play-on-matrix
        :fiveam
        :priority-queue :trivia :alexandria :iterate))
(in-package :play-on-matrix.test)

(declaim (sb-ext:muffle-conditions sb-ext:compiler-note))

(def-suite :play-on-matrix)
(in-suite :play-on-matrix)

;; run test with (run! test-name) 

(test play-on-matrix
  (dotimes-unroll (i 10 3)
    (format t "~%~a" i))
  (dotimes-unroll2 (i 10 3) ((j 3))
    (format t "~%~a ~a" i j))
  (dotimes-inline (i 10)
    (format t "~%~a" i)))

(defparameter *ma* (make-matrix 500 500))
(defparameter *mb* (make-matrix 500 500))
(defparameter *mc* (make-matrix 500 500))

(defmacro test-bench (name)
  `(test ,name
     (finishes
       (format t "~%~a : ~a sec~%"
               ',name
               (benchmark (3 nil 10)
                 (,name *ma* *mb* *mc*))))))

(test-bench simple-gemm)
(test-bench cache-gemm)
(test-bench row-major-gemm)
(test-bench rm-gemm+static-size)
(test-bench rm-gemm+static-size+unroll2)
(test-bench rm-gemm+static-size+unroll8)

;; (search-best-unrolling)

(test-bench simple-gemm-k)
(test-bench cache-gemm-k)
(test-bench rm-gemm-k)
(test-bench rm-gemm+static-size-k)
(test-bench rm-gemm+static-size+unroll2-k1)
(test-bench rm-gemm+static-size+unroll2-k2)
(test-bench rm-gemm+static-size+unroll2-k3)
(test-bench rm-gemm+static-size+unroll8-k)
(test-bench rm-gemm+static-size+unroll8-k2)

(test-bench rm-gemm+static-size+unroll-k2-best)

(test make-unroll-gemm
  (finishes
    (print
     (search-best-unrolling #'make-unroll-gemm *ma* *mb* *mc*))))

(test make-unroll-gemm-k
  (finishes
    (print
     (search-best-unrolling #'make-unroll-gemm-k *ma* *mb* *mc*))))

(test make-unroll-gemm-k2
  (finishes
    (print
     (search-best-unrolling #'make-unroll-gemm-k2 *ma* *mb* *mc*))))
