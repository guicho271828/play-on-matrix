(in-package :play-on-matrix)

(defun simple-gemm-k (ma mb mc)
  (declare (optimize (speed 3) (debug 0) (safety 0) (space 0)))
  (declare (type matrix ma mb mc))
  (let ((rows (array-dimension ma 0))
        (cols (array-dimension mb 1)))
    (declare (type fixnum rows cols))
    (dotimes (row rows)
      (dotimes (k cols)
        (dotimes (col cols)
          (incf (aref mc row col)
                (* (aref ma row k) (aref mb k col))))))
    mc))

(defun cache-gemm-k (ma mb mc)
  (declare (optimize (speed 3) (debug 0) (safety 0) (space 0)))
  (declare (type matrix ma mb mc))
  (let ((rows (array-dimension ma 0))
        (cols (array-dimension mb 1)))
    (declare (type fixnum rows cols))
    (dotimes (row rows)
      (dotimes (k cols)
        (let ((cell (aref ma row k)))
          (dotimes (col cols)
            (incf (aref mc row col)
                  (* cell (aref mb k col)))))))
    mc))

(defun rm-gemm-k (ma mb mc)
  (declare (optimize (speed 3) (debug 0) (safety 0) (space 0)))
  (declare (type matrix ma mb mc))
  (let ((rows (array-dimension ma 0))
        (cols (array-dimension mb 1)))
    (declare (type fixnum rows cols))
    (dotimes (row rows)
      (dotimes (k cols)
        (let ((cell (aref ma row k))
              (mb-index (array-row-major-index mb k 0))
              (mc-index (array-row-major-index mc row 0)))
          (dotimes (col cols)
            (incf (row-major-aref mc mc-index)
                  (* cell (row-major-aref mb mb-index)))
            (incf mb-index)
            (incf mc-index)))))
    mc))


(defun rm-gemm+static-size-k (ma mb mc)
  (declare (optimize (speed 3) (debug 0) (safety 0) (space 0)))
  (declare (type (matrix 500 500) ma mb mc))
  (let ((rows (array-dimension ma 0))
        (cols (array-dimension mb 1)))
    (declare (type fixnum rows cols))
    (dotimes (row rows)
      (dotimes (k cols)
        (let ((cell (aref ma row k))
              (mb-index (array-row-major-index mb k 0))
              (mc-index (array-row-major-index mc row 0)))
          (dotimes (col cols)
            (incf (row-major-aref mc mc-index)
                  (* cell (row-major-aref mb mb-index)))
            (incf mb-index)
            (incf mc-index)))))
    mc))

(defun rm-gemm+static-size+unroll2-k1 (ma mb mc)
  "didnt work"
  (declare (optimize (speed 3) (debug 0) (safety 0) (space 0)))
  (declare (type (matrix 500 500) ma mb mc))
  (let ((rows (array-dimension ma 0))
        (cols (array-dimension mb 1)))
    (declare (type fixnum rows cols))
    (dotimes (row rows)
      (dotimes (k cols)
        (let ((cell (aref ma row k)))
          (dotimes-unroll2 (col cols 2) ((mb-index (array-row-major-index mb k 0))
                                         (mc-index (array-row-major-index mc row 0)))
            (incf (row-major-aref mc mc-index)
                  (* cell (row-major-aref mb mb-index)))))))
    mc))

(defun rm-gemm+static-size+unroll2-k2 (ma mb mc)
  "worked"
  (declare (optimize (speed 3) (debug 0) (safety 0) (space 0)))
  (declare (type (matrix 500 500) ma mb mc))
  (let ((rows (array-dimension ma 0))
        (cols (array-dimension mb 1)))
    (declare (type fixnum rows cols))
    (dotimes (row rows)
      (dotimes (k cols)
        (let ((cell (aref ma row k))
              (mb-index (array-row-major-index mb k 0))
              (mc-index (array-row-major-index mc row 0)))
          (declare (fixnum mb-index mc-index))
          (dotimes (col (/ cols 2))
            (sb-kernel:data-vector-set-with-offset
             (sb-kernel:%array-data-vector mc) mc-index 0
             (+ (sb-kernel:data-vector-ref-with-offset
                 (sb-kernel:%array-data-vector mc) mc-index 0)
                (* cell (sb-kernel:data-vector-ref-with-offset
                         (sb-kernel:%array-data-vector mb) mb-index 0))))
            (sb-kernel:data-vector-set-with-offset
             (sb-kernel:%array-data-vector mc) mc-index 1
             (+ (sb-kernel:data-vector-ref-with-offset
                 (sb-kernel:%array-data-vector mc) mc-index 1)
                (* cell (sb-kernel:data-vector-ref-with-offset
                         (sb-kernel:%array-data-vector mb) mb-index 1))))
            (incf mb-index 2)
            (incf mc-index 2)))))
    mc))

(defun rm-gemm+static-size+unroll2-k3 (ma mb mc)
  (declare (optimize (speed 3) (debug 0) (safety 0) (space 0)))
  (declare (type (matrix 500 500) ma mb mc))
  (let ((rows (array-dimension ma 0))
        (cols (array-dimension mb 1)))
    (declare (type fixnum rows cols))
    (dotimes (row rows)
      (dotimes (k cols)
        (let ((cell (aref ma row k))
              (mb-index (array-row-major-index mb k 0))
              (mc-index (array-row-major-index mc row 0)))
          (declare (fixnum mb-index mc-index))
          (symbol-macrolet ((uj 2))
            (multiple-value-bind (quat mod) (floor cols uj)
              (dotimes (col quat)
                (dotimes-inline (offset uj)
                  (sb-kernel:data-vector-set-with-offset
                   (sb-kernel:%array-data-vector mc) mc-index offset
                   (+ (sb-kernel:data-vector-ref-with-offset
                       (sb-kernel:%array-data-vector mc) mc-index offset)
                      (* cell (sb-kernel:data-vector-ref-with-offset
                               (sb-kernel:%array-data-vector mb) mb-index offset)))))
                (incf mb-index uj)
                (incf mc-index uj))
              (dotimes (col mod)
                (sb-kernel:data-vector-set-with-offset
                 (sb-kernel:%array-data-vector mc) mc-index 0
                 (+ (sb-kernel:data-vector-ref-with-offset
                     (sb-kernel:%array-data-vector mc) mc-index 0)
                    (* cell (sb-kernel:data-vector-ref-with-offset
                             (sb-kernel:%array-data-vector mb) mb-index 0))))
                (incf mb-index)
                (incf mc-index)))))))
    mc))

(defun rm-gemm+static-size+unroll8-k (ma mb mc)
  (declare (optimize (speed 3) (debug 0) (safety 0) (space 0)))
  (declare (type (matrix 500 500) ma mb mc))
  (let ((rows (array-dimension ma 0))
        (cols (array-dimension mb 1)))
    (declare (type fixnum rows cols))
    (symbol-macrolet ((uj 8))
      (dotimes (row rows)
        (dotimes (k cols)
          (let ((cell (aref ma row k))
                (mb-index (array-row-major-index mb k 0))
                (mc-index (array-row-major-index mc row 0)))
            (declare (fixnum mb-index mc-index))
            (multiple-value-bind (quat mod) (floor cols uj)
              (dotimes (col quat)
                (dotimes-inline (offset uj)
                  (sb-kernel:data-vector-set-with-offset
                   (sb-kernel:%array-data-vector mc) mc-index offset
                   (+ (sb-kernel:data-vector-ref-with-offset
                       (sb-kernel:%array-data-vector mc) mc-index offset)
                      (* cell (sb-kernel:data-vector-ref-with-offset
                               (sb-kernel:%array-data-vector mb) mb-index offset)))))
                (incf mb-index uj)
                (incf mc-index uj))
              (dotimes (col mod)
                (sb-kernel:data-vector-set-with-offset
                 (sb-kernel:%array-data-vector mc) mc-index 0
                 (+ (sb-kernel:data-vector-ref-with-offset
                     (sb-kernel:%array-data-vector mc) mc-index 0)
                    (* cell (sb-kernel:data-vector-ref-with-offset
                             (sb-kernel:%array-data-vector mb) mb-index 0))))
                (incf mb-index)
                (incf mc-index)))))))
    mc))

(defun rm-gemm+static-size+unroll8-k2 (ma mb mc)
  (declare (optimize (speed 3) (debug 0) (safety 0) (space 0)))
  (declare (type (matrix 500 500) ma mb mc))
  (symbol-macrolet ((ui 2)
                    (uk 2)
                    (uj 8))
    (let ((rows (array-dimension ma 0))
          (cols (array-dimension mb 1)))
      (declare (type fixnum rows cols))
      (dotimes (row rows)
        (dotimes (k cols)
          (let ((cell (aref ma row k))
                (mb-index (array-row-major-index mb k 0))
                (mc-index (array-row-major-index mc row 0)))
            (declare (type fixnum mb-index mc-index))
            (dotimes-unroll3 ((col delta) (cols uj))
                ((incf mb-index delta)
                 (incf mc-index delta))
              (sb-kernel:data-vector-set-with-offset
               (sb-kernel:%array-data-vector mc) mc-index col
               (+ (sb-kernel:data-vector-ref-with-offset
                   (sb-kernel:%array-data-vector mc) mc-index col)
                  (* cell (sb-kernel:data-vector-ref-with-offset
                           (sb-kernel:%array-data-vector mb) mb-index col))))))))))
  mc)

(defun rm-gemm+static-size+unroll-k2-best (ma mb mc)
  (declare (optimize (speed 3) (debug 0) (safety 0) (space 0)))
  (declare (type (matrix 500 500) ma mb mc))
  (symbol-macrolet ((ui 1) (uk 2) (uj 8))
    (let ((rows (array-dimension ma 0))
          (cols (array-dimension mb 1)))
      (declare (type fixnum rows cols))
      (dotimes-unroll3 ((row) (rows ui)) ()
        (dotimes-unroll3 ((k) (cols uk)) ()
          (let ((cell (aref ma row k))
                (mb-index (array-row-major-index mb k 0))
                (mc-index (array-row-major-index mc row 0)))
            (declare (type fixnum mb-index mc-index))
            (dotimes-unroll3 ((col delta) (cols uj))
                ((incf mb-index delta)
                 (incf mc-index delta))
              (sb-kernel:data-vector-set-with-offset
               (sb-kernel:%array-data-vector mc) mc-index col
               (+ (sb-kernel:data-vector-ref-with-offset
                   (sb-kernel:%array-data-vector mc) mc-index col)
                  (* cell (sb-kernel:data-vector-ref-with-offset
                           (sb-kernel:%array-data-vector mb) mb-index col)))))))))))

