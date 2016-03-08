#|
  This file is a part of play-on-matrix project.
  Copyright (c) 2016 Masataro Asai (guicho2.71828@gmail.com)
|#


(in-package :cl-user)
(defpackage play-on-matrix.test-asd
  (:use :cl :asdf))
(in-package :play-on-matrix.test-asd)


(defsystem play-on-matrix.test
  :author "Masataro Asai"
  :mailto "guicho2.71828@gmail.com"
  :description "Test system of play-on-matrix"
  :license "LLGPL"
  :depends-on (:play-on-matrix
               :fiveam)
  :components ((:module "t"
                :components
                ((:file "package"))))
  :perform (test-op :after (op c) (eval (read-from-string "(every #'fiveam::TEST-PASSED-P (5am:run! :play-on-matrix))"))
))
