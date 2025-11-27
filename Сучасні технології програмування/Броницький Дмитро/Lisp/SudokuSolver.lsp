;;;; sudoku.lisp

(defparameter *digits* '(1 2 3 4 5 6 7 8 9))

(defun index (row col)
  (+ (* row 9) col))

(defun make-board-from-rows (rows)
  (make-array 81 :element-type 'fixnum
                 :initial-contents (apply #'append rows)))

(defun board-to-rows (board)
  (loop for r from 0 below 9
        collect (loop for c from 0 below 9
                      collect (aref board (index r c)))))

(defun used-in-row-p (board row value)
  (loop for c from 0 below 9
        when (= (aref board (index row c)) value)
          do (return t)
        finally (return nil)))

(defun used-in-col-p (board col value)
  (loop for r from 0 below 9
        when (= (aref board (index r col)) value)
          do (return t)
        finally (return nil)))

(defun used-in-box-p (board row col value)
  (let ((box-row-start (* 3 (floor row 3)))
        (box-col-start (* 3 (floor col 3))))
    (loop for r from box-row-start below (+ box-row-start 3) do
      (loop for c from box-col-start below (+ box-col-start 3) do
        (when (= (aref board (index r c)) value)
          (return-from used-in-box-p t))))
    nil))

(defun valid-placement-p (board row col value)
  (and (not (used-in-row-p board row value))
       (not (used-in-col-p board col value))
       (not (used-in-box-p board row col value))))

(defun find-empty (board)
  (loop for i from 0 below 81
        when (zerop (aref board i))
          do (return i)
        finally (return nil)))

(defun solve-board-in-place (board)
  (let ((pos (find-empty board)))
    (if (null pos)
        t                                ; немає порожніх — розв’язано
        (multiple-value-bind (row col) (floor pos 9)
          (loop for d in *digits*
                when (valid-placement-p board row col d) do
                  (setf (aref board pos) d)
                  (when (solve-board-in-place board)
                    (return t))
                  ;; відкат
                  (setf (aref board pos) 0)
                finally (return nil))))))

(defun solve-sudoku (rows)
Повертає новий 9x9 список із розв’язком або кидає помилку."
  (let ((board (make-board-from-rows rows)))
    (if (solve-board-in-place board)
        (board-to-rows board)
        (error "Puzzle has no solution."))))

(defun print-board (board)
  (let ((b (if (arrayp board)
               board
               (make-board-from-rows board))))
    (dotimes (r 9)
      (when (and (> r 0) (zerop (mod r 3)))
        (format t "~%------+-------+------~%"))
      (dotimes (c 9)
        (when (and (> c 0) (zerop (mod c 3)))
          (format t " |"))
        (let ((v (aref b (index r c))))
          (format t " ~A" (if (zerop v) "." v))))
      (format t "~%"))))
(defparameter *example-puzzle*
  '((5 3 0 0 7 0 0 0 0)
    (6 0 0 1 9 5 0 0 0)
    (0 9 8 0 0 0 0 6 0)
    (8 0 0 0 6 0 0 0 3)
    (4 0 0 8 0 3 0 0 1)
    (7 0 0 0 2 0 0 0 6)
    (0 6 0 0 0 0 2 8 0)
    (0 0 0 4 1 9 0 0 5)
    (0 0 0 0 8 0 0 7 9)))

(print-board (make-board-from-rows (solve-sudoku *example-puzzle*)))
