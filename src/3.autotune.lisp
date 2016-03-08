(in-package :play-on-matrix)

(defun children (parameters)
  (destructuring-bind (x y z) parameters
    (list (list x y (* z 2))
          (list x (* y 2) z)
          (list (* x 2) y z))))

(defun parents (parameters)
  (destructuring-bind (x y z) parameters
    (remove-if-not (lambda (parameters)
                     (every #'integerp parameters))
                   (list (list x y (/ z 2))
                         (list x (/ y 2) z)
                         (list (/ x 2) y z)))))

(defun evaluate-unrolling (generator inputs parameters)
  (format t "~&testing ~a ..." parameters)
  (let* ((f (apply generator parameters))
         (time (benchmark (20) (apply f inputs))))
    (prog1 time
           (format t " ~a (sec). " time))))

(defun search-best-unrolling (generator &rest inputs)
  (let ((q (make-pqueue #'< :key-type 'float :value-type 'list))
        (close nil))
    (let ((basetime (evaluate-unrolling generator inputs '(1 1 1))))
      (push (cons '(1 1 1) basetime) close)
      (pqueue-push '(1 1 1) basetime q))
    (iter (until (pqueue-empty-p q))
          (for (values parameters time) = (pqueue-pop q))
          (finding (cons parameters time) minimizing time)
          (iter (for new-parameters in (children parameters))
                (when (member new-parameters close :key #'car :test #'equal)
                  ;; duplicate detection
                  (next-iteration))
                (for newtime = (evaluate-unrolling generator inputs new-parameters))
                (push (cons new-parameters newtime) close)
                (for (time . best-parent) =
                     (iter (for parent in (parents new-parameters))
                           (for time = (cdr (assoc parent close :test #'equal)))
                           (when time
                             (finding (cons time parent) minimizing time))))
                (when (< newtime time)
                  (format t "Improved from the best result by parent ~a: ~a." best-parent time)
                  (pqueue-push new-parameters newtime q))))))

