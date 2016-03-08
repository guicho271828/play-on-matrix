(in-package :play-on-matrix)

(defun make-matrix (rows cols)
  (make-array (list rows cols) :element-type 'single-float))

(deftype matrix (&optional a b)
  `(simple-array single-float (,a ,b)))

(defmacro benchmark ((times &optional time-p (times2 times)) &body body)
  (once-only (times times2)
    (with-gensyms (i start end)
      `(progn
         (dotimes (,i ,times)
           ,@body)
         (let ((,start (get-internal-run-time)))
           (,(if time-p 'time 'progn)
             (dotimes (,i ,times2)
               ,@body))
           (let ((,end (get-internal-run-time)))
             (float (/ (- ,end ,start)
                       internal-time-units-per-second))))))))


(defmacro dotimes-unroll ((i n unroll) &body body)
  (check-type i symbol)
  (assert (and (constantp unroll) (numberp unroll)))
  (if (= 1 unroll)
      `(dotimes (,i ,n)
         ,@body)
      (once-only (n)
        `(locally
             (declare (fixnum ,n))
           (do ((,i 0))
               ((< ,n (the fixnum (+ ,unroll ,i)))
                (do ((,i ,i (the fixnum (1+ ,i))))
                    ((< ,n (the fixnum (1+ ,i))))
                  ,@body))
             (declare (fixnum ,i))
             ,@(loop :repeat unroll :append (append body `((incf ,i)))))))))



(defmacro dotimes-unroll2 ((var n unroll) parameters &body body)
  (check-type var symbol)
  (assert (and (constantp unroll) (numberp unroll)))
  (with-gensyms (limit1 i) ; i is the true counter
    (let (varlist bindings)
      (dolist (p parameters)
        (ematch (ensure-list p)
          ((list x)
           (with-gensyms (y)
             (push (list x y) bindings)
             (push (list y 0 `(the fixnum (+ ,unroll ,y))) varlist)))
          ((list x start)
           (with-gensyms (y)
             (push (list x y) bindings)
             (push (list y start `(the fixnum (+ ,unroll ,y))) varlist)))))
      (push (list var i) bindings)
      (push (list i 0 `(+ ,unroll ,i)) varlist)
      (once-only (n)
        `(locally (declare (fixnum ,n))
           (let ((,limit1 (the fixnum (- ,n ,unroll))))
             (declare (fixnum ,limit1))
             (do (,@varlist)
                 ((< ,limit1 ,i)
                  (do (,@(mapcar (lambda-match
                                   ((list y _ _) `(,y ,y (the fixnum (1+ ,y)))))
                                 varlist))
                      ((<= ,n ,i))
                    (declare (fixnum ,@(mapcar #'first varlist)))
                    (symbol-macrolet (,@bindings)
                      ,@body)))
               (declare (fixnum ,@(mapcar #'first varlist)))
               ,@(iter (for j below unroll)
                       (collect
                           `(symbol-macrolet (,@(mapcar (lambda-match
                                                          ((list x y) `(,x (the fixnum (+ ,y ,j)))))
                                                  bindings))
                              ,@body))))))))))

(defmacro dotimes-inline ((var count &optional result-form) &body body &environment env)
  (check-type var symbol)
  (let ((count (macroexpand count env)))
    (assert (and (constantp count) (numberp count)))
    (iter (for c to count)
          (when (first-iteration-p)
            (collect 'progn))
          (collect
              (if (< c count)
                  `(symbol-macrolet ((,var ,c))
                     ,@body)
                  result-form)))))


