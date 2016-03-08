#|
  This file is a part of play-on-matrix project.
  Copyright (c) 2016 Masataro Asai (guicho2.71828@gmail.com)
|#

#|
  playing on matrix gemm

  Author: Masataro Asai (guicho2.71828@gmail.com)
|#



(in-package :cl-user)
(defpackage play-on-matrix-asd
  (:use :cl :asdf))
(in-package :play-on-matrix-asd)


(defsystem play-on-matrix
  :version "0.1"
  :author "Masataro Asai"
  :mailto "guicho2.71828@gmail.com"
  :license "LLGPL"
  :depends-on (:priority-queue :trivia :alexandria :iterate)
  :components ((:module "src"
                :components
                ((:file "0.package")
                 (:file "1.base")
                 (:file "2.impl")
                 (:file "2.impl-ikj")
                 (:file "3.autotune")
                 (:file "4.generators"))))
  :description "playing on matrix gemm"
  :in-order-to ((test-op (test-op :play-on-matrix.test))))
