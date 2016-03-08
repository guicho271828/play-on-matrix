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



(def-suite :play-on-matrix)
(in-suite :play-on-matrix)

;; run test with (run! test-name) 

(test play-on-matrix

  )

(dotimes-unroll (i 10 3)
  (format t "~%~a" i))
(dotimes-unroll (i 1 3)
  (format t "~%~a" i))


(defparameter *ma* (make-matrix 500 500))
(defparameter *mb* (make-matrix 500 500))
(defparameter *mc* (make-matrix 500 500))

(benchmark (10)
  (simple-gemm *ma* *mb* *mc*)
  ;; Evaluation took:
  ;;   7.020 seconds of real time
  ;;   7.020000 seconds of total run time (7.020000 user, 0.000000 system)
  ;;   100.00% CPU
  ;;   21,061,255,674 processor cycles
  ;;   65,536 bytes consed
  )


(benchmark (10)
  ;; Evaluation took:
  ;;   3.115 seconds of real time
  ;;   3.116000 seconds of total run time (3.116000 user, 0.000000 system)
  ;;   100.03% CPU
  ;;   9,347,123,164 processor cycles
  ;;   55,072 bytes consed
  (row-major-gemm *ma* *mb* *mc*))

(benchmark (10)
  (rm-gemm+static-size *ma* *mb* *mc*)
  ;; Evaluation took:
  ;;   2.773 seconds of real time
  ;;   2.772000 seconds of total run time (2.772000 user, 0.000000 system)
  ;;   99.96% CPU
  ;;   8,318,453,469 processor cycles
  ;;   0 bytes consed
  )



(benchmark (10)
  ;; best so far, on AMD Phenom(tm) II X6 1075T Processor
  (rm-gemm+static-size+unroll *ma* *mb* *mc*)
  ;; Evaluation took:
  ;;   2.203 seconds of real time
  ;;   2.200000 seconds of total run time (2.200000 user, 0.000000 system)
  ;;   99.86% CPU
  ;;   6,609,926,012 processor cycles
  ;;   0 bytes consed
  )

(search-best-unrolling)

(dotimes-unroll2 (i 10 3) ((j j-init))
  (format t "~%~a ~a" i j))

(print (benchmark (10) (simple-gemm *ma* *mb* *mc*)))
(print (benchmark (10) (simple-gemm-k *ma* *mb* *mc*)))

(benchmark (10)
  ;; Evaluation took:
  ;;   5.084 seconds of real time
  ;;   5.084000 seconds of total run time (5.080000 user, 0.004000 system)
  ;;   100.00% CPU
  ;;   15,252,688,222 processor cycles
  ;;   30,224 bytes consed
  (cache-gemm-k *ma* *mb* *mc*))



(benchmark (10)
  ;; Evaluation took:
  ;;   2.701 seconds of real time
  ;;   2.708000 seconds of total run time (2.708000 user, 0.000000 system)
  ;;   100.26% CPU
  ;;   8,102,781,155 processor cycles
  ;;   487,504 bytes consed
  (rm-gemm-k *ma* *mb* *mc*))




(benchmark (10 t)
  ;; Evaluation took:
  ;;   2.696 seconds of real time
  ;;   2.696000 seconds of total run time (2.696000 user, 0.000000 system)
  ;;   100.00% CPU
  ;;   8,088,876,210 processor cycles
  ;;   33,056 bytes consed
  (rm-gemm+static-size-k *ma* *mb* *mc*))

(benchmark (10 t)
  ;; Evaluation took:
  ;;   2.262 seconds of real time
  ;;   2.260000 seconds of total run time (2.260000 user, 0.000000 system)
  ;;   99.91% CPU
  ;;   6,785,072,819 processor cycles
  ;;   32,784 bytes consed
  (rm-gemm+static-size+unroll2-k *ma* *mb* *mc*))
