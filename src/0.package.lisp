#|
  This file is a part of play-on-matrix project.
  Copyright (c) 2016 Masataro Asai (guicho2.71828@gmail.com)
|#

(in-package :cl-user)
(defpackage play-on-matrix
  (:use :cl :priority-queue :trivia :alexandria :iterate
        :sb-c)
  (:shadowing-import-from :sb-c :defoptimizer :optimizer))
(in-package :play-on-matrix)

