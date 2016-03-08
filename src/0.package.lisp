#|
  This file is a part of play-on-matrix project.
  Copyright (c) 2016 Masataro Asai (guicho2.71828@gmail.com)
|#

(in-package :cl-user)
(defpackage play-on-matrix
  (:use :cl :priority-queue :trivia :alexandria :iterate
        :sb-c)
  (:shadowing-import-from :sb-c :defoptimizer :optimizer)
  (:export
   #:make-matrix
   #:matrix
   #:benchmark
   #:dotimes-unroll
   #:dotimes-unroll2
   #:dotimes-inline
   #:simple-gemm
   #:cache-gemm
   #:row-major-gemm
   #:rm-gemm+static-size
   #:rm-gemm+static-size+unroll2
   #:rm-gemm+static-size+unroll8
   #:simple-gemm-k
   #:cache-gemm-k
   #:rm-gemm-k
   #:rm-gemm+static-size-k
   #:rm-gemm+static-size+unroll2-k1
   #:rm-gemm+static-size+unroll2-k2
   #:rm-gemm+static-size+unroll2-k3
   #:search-best-unrolling
   #:rm-gemm+static-size+unroll8-k
   #:rm-gemm+static-size+unroll8-k2
   #:make-unroll-gemm
   #:make-unroll-gemm-k
   #:make-unroll-gemm-k2
   #:rm-gemm+static-size+unroll-1-2-8-k2
   #:rm-gemm+static-size+unroll-1-2-8-k
   #:rm-gemm+static-size+unroll-k-best
   #:rm-gemm+static-size+unroll-k2-best))
(in-package :play-on-matrix)

