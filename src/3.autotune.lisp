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

(defun evaluate-unrolling (generator x y z)
  (let ((f (funcall generator x y z)))
    (benchmark (10) (funcall f *ma* *mb* *mc*))))

(defun search-best-unrolling (generator)
  (let ((q (make-pqueue #'< :key-type 'float :value-type 'list))
        (close nil))
    (format t "~&testing ~a ..." '(1 1 1))
    (let* ((f (funcall #'generator 1 1 1))
           (basetime (benchmark (10) (funcall f *ma* *mb* *mc*))))
      (format t " ~a (sec). " basetime)
      (push (cons '(1 1 1) basetime) close)
      (pqueue-push '(1 1 1) basetime q))
    (iter (until (pqueue-empty-p q))
          (for (values parameters time) = (pqueue-pop q))
          (finding (cons parameters time) minimizing time)
          (iter (for new-parameters in (children parameters))
                (when (member new-parameters close :key #'car :test #'equal)
                  ;; duplicate detection
                  (next-iteration))
                (format t "~&testing ~a ..." new-parameters)
                (for newtime = (apply #'evaluate-unrolling new-parameters))
                (format t " ~a (sec). " newtime)
                (push (cons new-parameters newtime) close)
                (for (time . best-parent) =
                     (iter (for parent in (parents new-parameters))
                           (for time = (cdr (assoc parent close :test #'equal)))
                           (when time
                             (finding (cons time parent) minimizing time))))
                (when (< newtime time)
                  (format t "Improved from the best result by parent ~a: ~a." best-parent time)
                  (pqueue-push new-parameters newtime q))))))

