;; Functions by Charles K. Neimog (2019 - 2020) | Universidade Federal de Juiz de Fora | charlesneimog.com

;; Necessita de ser carregado dentro do Software OM-Sharp

(in-package :om-ji)

;; ======================================== Just-Intonation ==============================

(om::defmethod! rt->mc ((ratio list) (fundamental number))
:initvals ' ((1/1 11/8 7/4) (6000))
:indoc ' ("Convert list of ratios to midicent." "This will be a note. This note will be the fundamental (reference note) of the list of ratios.") 
:icon 002
:doc "It converts ratio for midicents notes."

(if (let ((foo ratio)) (typep foo 'list-of-lists))

(loop :for cknloop :in ratio :collect (loop :for n :in cknloop :collect (+ fundamental (ratio->cents n))))
(loop :for n :in ratio :collect (+ fundamental (ratio->cents n)))))

;; =================

(om::defmethod! rt->mc ((ratio number) (fundamental number))
:initvals ' (11/8 6000)
:indoc ' ("Convert list of ratios for midicent." "This will be a note. This note will be the fundamental of the list of ratios.") 
:icon 002
:doc "It converts ratio for midicents notes."

(+ fundamental (ratio->cents ratio)))

;; ===================================================

(om::defmethod! octave-reduce ((note list) (octave number))
:initvals ' ((4800 7200 6000) 1)
:indoc ' ("List of midicents."  "Octaves of this reduction.")
:icon 002
:doc "This object reduces a list of notes in a determinate space of octaves. The note of the first inlet will be the more down note allowed, and in the second inlet must be the octaves of the higher notes that will be allowed." 

(let* ((range (om::om* octave 1200))
(grave (first (om::sort-list note))))

(if (let ((foo note)) (typep foo 'list-of-lists))

;; Lista de listas
;; Lista
   
      (loop :for listadelista :in note :collect (mapcar #' (lambda (x) (+ (mod x range) grave)) listadelista))
      (mapcar (lambda (x) (+ (mod x range) grave)) note))))


;; ===================================================

(om::defmethod! range-reduce ((notelist list) (grave number) (aguda number))
:initvals ' ((4800 7200 6000) 6000 7902)
:indoc ' ("List of midicents" "The lowest note." "The highest note.")
:icon 002
:doc "This object reduce a list of notes in a determinate space. The note of the first inlet will be the more lowest note allowed, and the note of the second inlet will be the more higher note allowed."

(let* 
  ((octave-redution (om::om* 1200 (ceiling (/ (- aguda grave) 1200))))
  (aguda-first (+ grave octave-redution)))

(if (>= (- aguda grave) 1200)


(if (let ((foo notelist)) (typep foo 'list-of-lists))

(let* ((redution-octave 
          (loop :for notelistloop :in notelist :collect
            (mapcar (lambda (x)
	              (loop :for new-val := x :then (if (< new-val aguda-first)
			              (+ new-val octave-redution)
			              (- new-val octave-redution))
		                :until (and (<= grave new-val)
			             (>= aguda-first new-val))
		                :finally (return new-val)))
  	            notelistloop))))

       
          (loop :for notelistloop :in redution-octave :collect
            (mapcar (lambda (x)
	              (loop :for new-val := x :then (if (< new-val aguda)
			              (+ new-val 1200)
			              (- new-val 1200))
		                :until (and (<= grave new-val)
			             (>= aguda new-val))
		                :finally (return new-val)))
  	            notelistloop)))

(let* ((redution-octave 
            (mapcar (lambda (x)
	              (loop :for new-val := x :then (if (< new-val aguda-first)
			              (+ new-val octave-redution)
			              (- new-val octave-redution))
		                :until (and (<= grave new-val) 
			             (>= aguda-first new-val))
		                :finally (return new-val)))
  	            notelist)))

            (mapcar (lambda (x)
	              (loop :for new-val := x :then (if (< new-val aguda)
			              (+ new-val 1200)
			              (- new-val 1200))
		                :until (and (<= grave new-val)
			             (>= aguda new-val))
		                :finally (return new-val)))
  	            redution-octave)))
       
          
(print "RANGE-REDUCE: The difference between the inlet2 e inlet3 must be at least 1200 cents"))))


;;; Do the reduction of a list in this way in two octaves (6000 8400)
; 1. Give the (6000 6552 6900 7300 7600 7800 8300 9100 9500 10400)
; 2. Just in 8400 this will reduce the list of notes to 6000 not to 8400.

;; ===================================================

(om::defmethod! filter-ac-inst ((notelist list) (approx integer) (temperament integer))
:initvals ' ((6000 6530 7203 5049) 10 2)
:indoc ' ("List of notes (THIS OBJECT DON'T READ LISTS OF LIST.)" "Cents aproximation of a tempered note." "Tempered scale used to compare the note list.") 
:icon 002
:doc "Filter of notes that can be played by an acoustic instrument with quarte tones, eight-tones, or others."

 (let* (
  (action1 
  (loop :for cknloop :in notelist :collect (if (>= approx (abs (- (om::approx-m cknloop temperament) cknloop))) cknloop nil))))
  (remove nil action1)))

;; ===================================================

(om::defmethod! modulation-notes ((listnote list) (listnote2 list) (cents integer))
:initvals ' ((6000 6530) (7203 5049) 2)
:indoc ' ("First notelist of the comparation." "Second notelist of the comparation." "Approximation in cents, in which the object will consider the notes as equal. For example, with the number 5, the object will consider 6000 and 6005 as equal notes.")
:icon 002
:doc "Filter of notes that can be used to do the modulation between tuning regions. This idea appears in the reading of Daniel James Huey (2017) doctoral dissertation. He claims: 'This dissertation shows the importance of common tones between pitches of two tuning areas, and it highlights consonant intervals between the fundamental pitches of the tuning areas as a means of producing a sense of continuity.'"

(let* ((result (loop :for cknloop1 :in listnote :collect (loop :for cknloop2 :in listnote2 :collect 
      (if (= (+ 
          (if (< (- (- cknloop1 cknloop2) (approx-m (- cknloop1 cknloop2) 2)) cents) 1 0) 
          (if (> (- (- cknloop1 cknloop2) (approx-m (- cknloop1 cknloop2) 2)) (- cents (om::om* cents 2))) 1 0)) 2) (list cknloop1 cknloop2) 0)))) 

(result2 (remove 0 (flat result 1)))

(result3 (loop :for note :in result2 :collect 
        (if (and (< (- 
                       (first (mapcar #' (lambda (x) (+ (mod x 1200) 6000)) note)) 
                       (second (mapcar #' (lambda (x) (+ (mod x 1200) 6000)) note))) cents)
                 (< (- cents (om::om* cents 2)) 
                      (- (first (mapcar #' (lambda (x) (+ (mod x 1200) 6000)) note)) 
                      (second (mapcar #' (lambda (x) (+ (mod x 1200) 6000)) note))))) note 0)))
(result4 (remove 0 result3)))

(loop :for x :in result4 :do (print (concatenate 'string "The pitch " (list->string (list (first x)) " (of the tuning connected in the first inlet) " "can be modulated using the pitch " (list->string (list (second x))) " (of the tuning connected in the first inlet)."))) "Check the listener")))

;; ===================================================

(om::defmethod! modulation-notes-fund ((listnote list) (listnote2 list) (cents integer) (temperamento integer))
:initvals ' ((6000 6530) (7203 5049) 10 4)
:indoc ' ("First notelist of the comparation" "Second notelist of the comparation" "different between two note to be considered equal" "temperament! 2 for 2-DEO 4 for 24-DEO") 
:icon 002
:numouts 2
:doc "Filter of notes that can be used to do the modulation between tuning regions changing the fundamental of the second list (second inlet). This object is an update of the object called modulation-notes'"

(values 
(let* ((result (loop :for cknloop1 :in listnote :collect 

                     (loop :for cknloop2 :in listnote2 :collect (if (om= (+ 
                                                          (if (< (om- (om- cknloop1 cknloop2) 
                                                                 (approx-m (om- cknloop1 cknloop2) temperamento)) cents) 1 0) 
                                                          (if (> (om- (om- cknloop1 cknloop2) 
                                                                 (approx-m (om- cknloop1 cknloop2) temperamento)) (om- cents (* cents 2))) 1 0)) 2) 
                                                                                                  (list cknloop1 cknloop2) 0))))
(result2 (remove 0 (flat result 1))))

  (loop :for cknloop3 :in result2 :do (print  (let*  
                                               ((result3-2 (om- (first cknloop3) (second cknloop3))))

  (if 
      (or (om= result3-2 0) (om= result3-2 1200) (and (om> cents result3-2) (om< (om- cents (om* cents 2)) result3-2))) 
      (concatenate 'string (list->string (list (first cknloop3))) " and " (list->string (list (second cknloop3))) " are equal.")
       (concatenate 'string (list->string (list (first cknloop3))) " and " (list->string (list (second cknloop3))) " will be equal if the fundamental of the second Tuning have has the fundamental with the difference of " (list->string (list (approx-m result3-2 temperamento))) " cents."))))) "Check the listener")

;;;; ========

(let* ((result (loop :for cknloop1 :in listnote :collect 

                     (loop :for cknloop2 :in listnote2 :collect (if (om= (+ 
                                                          (if (< (om- (om- cknloop1 cknloop2) 
                                                                 (approx-m (om- cknloop1 cknloop2) temperamento)) cents) 1 0) 
                                                          (if (> (om- (om- cknloop1 cknloop2) 
                                                                 (approx-m (om- cknloop1 cknloop2) temperamento)) (om- cents (* cents 2))) 1 0)) 2) 
                                                                                                  (list cknloop1 cknloop2) 0))))
(result2 (remove 0 (flat result 1)))

(result3 (loop :for cknloop3 :in result2 :collect 
  (let* (
          (result3-2 (om- (first cknloop3) (second cknloop3))))


(if 
      (or (om= result3-2 0) (om= result3-2 1200) (and (om> cents result3-2) (om< (om- cents (om* cents 2)) result3-2)))
      (concatenate 'string (list->string (list (first cknloop3))) " and " (list->string (list (second cknloop3))) " are equal." "!!!!")
      (x-append cknloop3 "will be equal if the fundamental of the second tuning have has the difference of" (approx-m result3-2 temperamento) "cents"))))))

(om::sort-list (remove nil (mapcar (lambda (x) (if (equal (om::type-of x) 'lispworks:simple-text-string) nil (fourth x))) result3))))))
    


;; ===================================================

(om::defmethod! choose ((notelist list) (chord-n integer))
:initvals ' ((1 2 3 4 5 6 7 8 9 10) 2)
:indoc ' ("List or list of lists of anything" "What element(s) do you want?") 
:icon 002
:doc "This object choose an element in a list; or a list in a list of lists. If you put more that one element in the second inlet this object will choose all the elements that you put in second inlet.
Inlet1: (7 8 9 10 458)
Inlet2: (1 3 5)
Result: (7 9 458)."

(posn-match notelist (om::om- chord-n 1)))


(om::defmethod! choose ((notelist list) (chord-n list))
:initvals ' ((1 2 3 4 5 6 7 8 9 10) (1 7 9))
:indoc ' ("List or list of lists of anything." "What element(s) do you want?") 
:icon 002
:doc "This object choose an element in a list; or a list in a list of lists. If you put more that one element in the second inlet this object will choose all the elements that you put in second inlet.
Inlet1: (7 8 9 10 458)
Inlet2: (1 3 5)
Result: (7 9 458)."

(posn-match notelist (om::om- chord-n 1)))

;; ===================================================

(om::defmethod! rt-octave ((fraq list) &optional (octave 2))
:initvals ' ((1/3 1 5/3) 2)
:indoc ' ("List of ratios" "2 for one octave; 4 for 2 octaves; 8 for 3; etc...") 
:icon 002
:doc "This object reduce ratios for one octave (or two or others; optional function), your function is similar to the object octave-reduce, but it operates in ratios domain."

(rt-octave-fun fraq octave))


(om::defmethod! rt-octave ((fraq number) &optional (octave 2))
:initvals ' (3/2 2)
:indoc ' ("list of ratios" "2 for one octave; 4 for 2 octaves; 8 for 3; etc...") 
:icon 002
:doc "This object reduce ratios for one octave (or two or others; optional function), your function is similar to the object octave-reduce, but it operates in ratios domain."

(/ fraq (expt octave (floor (log fraq octave)))))

; ====== Function 

(defun rt-octave-fun (fraq octave)

(if (let ((foo fraq)) (typep foo 'list-of-lists))

(loop :for cknloop :in fraq :collect (loop :for cknloop2 :in cknloop :collect (/ cknloop2 (expt octave (floor (log cknloop2 octave))))))

(loop :for cknloop2 :in fraq :collect (/ cknloop2 (expt octave (floor (log cknloop2 octave)))))))


;; ===================================================
(om::defmethod! sieve-prime ((your-sieve list))
:initvals ' (11)      
:indoc ' ("Sieve")
:outdoc ' ("utonality" )
:icon 002
:doc "Seleciona os números primos de acordo com a sequencia dos números primos."

(loop :for ckn-loop :in your-sieve :collect (choose-fun (remove 1 (om::prime-ser 99999999999 (last-elem (om::sort-list your-sieve )))) ckn-loop)))

;; =================================== HARRY PARTCH ==========================================
(om::defmethod! Diamond ((limite integer))
:initvals ' (11)      
:indoc ' ("Limit-n for the diamond.")
:outdoc ' ("utonality" "otonality")
:numouts 2 
:icon 003
:doc "Create a Tonality-Diamond according to Harry Partch's Theory. This tonality construct ratios with the identities (odd-numbers) of a limit. This object reproduces the process of the Tonality Diamond find in:

<https://bit.ly/3hAcLh1>. This diamond is a diamond with limit-5, so we have 3 identities (all the odd-numbers until 5) 1, 5, and 3.

In the outlet of the left, the result is the utonal-diamond. Outlet of the right is the otonality-diamond."

(values 
(let* ((ordem-partch (loop :for x :in (om::sort-list (rt-octave-fun (arithm-ser 1 limite 2) 2)) :collect (numerator x))))
  (loop :for x :in ordem-partch :collect (loop :for y :in ordem-partch :collect (/ x y))))

(let* ((ordem-partch2 (loop :for x :in (om::sort-list (rt-octave-fun (arithm-ser 1 limite 2) 2)) :collect (numerator x))))
  (loop :for x :in ordem-partch2 :collect (loop :for y :in ordem-partch2 :collect (/ y x))))
)
)

;; ===================================================

(om::defmethod! Diamond-Identity ((identity list))
:initvals ' ((11 19 97))       
:indoc ' ("limit-n for the diamond")
:outdoc ' ("utonality" "otonality")
:numouts 2
:icon 003
:doc "It creates a Tonality-Diamond with a list of Identities. In this object, I remove the limit theory, so we can use all the identities that we want."

(values 
(loop :for x :in identity :collect (loop :for y :in identity :collect (/ x y))) 
(loop :for x :in identity :collect (loop :for y :in identity :collect (/ y x)))))

;; ===================================================
-
(om::defmethod! chord-inverse ((chord-list list))
:initvals ' ((1/1 3/2 5/4))       
:indoc ' ("otonal chord")
:icon 003
:doc "It gives the utonal chord of a otonal chord and vice-versa. In other words, intervals ascendants become intervals descent and vice-versa."

(mapcar
  (lambda (x) (/ (denominator x) (numerator x)))
  chord-list))


;; ;; =================================== Ben Johnston ======================================

(om::defmethod! interval-sob ((ratio number) (your-sieve list))
:initvals '(11/8 (2 3 7 11 12))     
:indoc '("Just Intonation interval" "List of sobreposition")
:icon 001
:outdoc '("Utonal sobreposition." "Otonal sobreposition.")
:numouts 2 
:doc "The object interval-sob creates a sobreposition of the same interval. 

OBS.: It was constructed using ascendant ratios intervals (the numerator is greater than the denominator), so if you use an interval that is descent (the denominator is greater than the numerator), the outlet of the left give the Otonal sobreposition (stacking) and the outlet of the right give Utonal Sobreposition (stacking)."

(values 

(let* ((sobreposition (om::om^ ratio your-sieve))
(task1 (loop :for y :in sobreposition :collect (denominator y)))
(task2 (loop :for y :in sobreposition :collect (numerator y))))
(om::om/ task1 task2))

(let* ((sobreposition (om::om^ ratio your-sieve))
(task1 (loop :for y :in sobreposition :collect (numerator y)))
(task2 (loop :for y :in sobreposition :collect (denominator y))))
(om::om/ task1 task2))

))

;; ===================================================

(om::defmethod! arith-mean ((grave number) (agudo number))
:initvals ' (1/1 2/1)
:indoc ' ("first ratio" "second ratio")
:icon 001
:doc "It gives the arithmetic mean of two ratio. 

This is a procedure used by Ben Johnston in your strings quartets no. 2 and no. 3. See the article Scalar Order as a Compositional Resource (1964)."

(/ (+ grave agudo) 2))

;; ===================================================

(om::defmethod! arith-mean-sob ((grave number) (agudo number))
:initvals ' (1/1 5/4)
:indoc ' ("First ratio" "Second ratio")
:icon 001
:doc "It gives the arithmetic mean of two ratios, and it does the ascendant sobreposition of the result with the first ratio and the descent sobreposition with the second ratio.

This is a procedure used by Ben Johnston in your strings quartets no. 2 and no. 3. See the article Scalar Order as a Compositional Resource (1964)."

(om::x-append grave (/ agudo (/ (+ grave agudo) 2)) (om::om* grave (/ (+ grave agudo) 2)) agudo))

;; ===================================================

(om::defmethod! johnston-sob ((ratio number) (sobreposition number) (fundamental number))
:initvals ' (3/2 3 7200)
:indoc ' ("first ratio" "sobreposition number" "fundamental")
:icon 001
:doc "Gilmore (1995, p. 477) will suggest that Johnston's System can be summarized by an overlapping of Just Intonation intervals above and below one fundamental pitch. This process is constructed with the Johnston-Sob object. In the first inlet, we have the interval to be overlapped. In the second inlet, the user determines how many intervals will be overlapped above and below. Finally, in the third inlet, the fundamental note must be specified in midicents. "

(let* (
(utonal-sobr (/ (denominator ratio) (numerator ratio)))
(sobr (arithm-ser 1 sobreposition 1))
(otonal (loop :for n :in (om::om^ ratio sobr) collect (f->mc (om::om* (mc->f fundamental) n))))
(utonal (loop :for n :in (om::om^ utonal-sobr sobr) collect (f->mc (om::om* (mc->f fundamental) n)))))
(om::x-append utonal fundamental otonal)))


;; =================================== Erv Wilson =========================================

;; ====================== MOS =============================

(om::defmethod! MOS ((ratio number)(sobreposition number) (range number))
:initvals ' (4/3 11 2/1)     
:indoc ' ("Fundamental note of sobreposition" "Just Intonation interval" "High note" "Number of sobreposition")
:icon 'MOS
:doc "This object creates a Moment of Symmetry without a octave equivalence. For make the octave equivalence use the object Octave-reduce, choose the range of the this MOS. 

MOS is a Theory of the composer Erv Wilson.                  

Wilson coined the term (MOS) to describe those scales resulting from a chain of intervals that produce two (and not three) different-sized intervals. 

These intervals are designated as the small (s) and large (L) intervals (FOR MAKE THIS USE THE OBJECT MOS-type). 

The relative number of s and L intervals in an MOS is co-prime, i.e., they share no common factors other than 1. Fractions are used to represent MOS scales: the numerator shows the size of the generator, and the denominator shows the number of notes in the scale. 

The numerator and denominator of fractions representing MOS are also co-prime. Wilson organizes these fractions hierarchically on the Scale Tree. MOS are not only scales in their own right but also provide a framework or template for constructing a family of Secondary MOS scales. (in NARUSHIMA - Microtonality and the Tuning Systems of Erv Wilson-Routledge)."

(mos-fun-ratio ratio sobreposition range))

;=================

(defun mos-fun-ratio (ratio sobreposition range)

(om::x-append 1 (rt-octave (om::om^ ratio (arithm-ser 1 sobreposition 1)) range) range))


;=================


(defun mos-fun-cents (ratio grave aguda sobreposition)

(let*  

    ((interval (- (f->mc (om::om* (mc->f grave) ratio)) grave))

    (mos-create (loop :for n :in (arithm-ser 1 sobreposition 1) :collect (+ grave (* interval n)))))

(om::x-append grave 


(let* 
(
(octave-reduction (om::om* (+ 1 (truncate (- aguda grave) 1200)) 1200))
(aguda-oitava (+ grave octave-reduction))
(reducao-em-oitava 

    (mapcar (lambda (x)
        (loop :for new-val := x
          :then (if (< new-val aguda-oitava)
              (+ new-val octave-reduction)
              (- new-val octave-reduction))
        :until (and (<= grave new-val) (>= aguda-oitava new-val)
              )
        :finally (return new-val)))
              mos-create))
  (octave-reduction2 (om::om* (truncate (- aguda grave) 1200) 1200)))


 (mapcar (lambda (x)
	  (loop :for new-val := x
		  :then (if (< new-val aguda)
			    (+ new-val octave-reduction2)
			    (- new-val octave-reduction2))
		:until (and (<= grave new-val) (>= aguda new-val))
		:finally (return new-val)))
	reducao-em-oitava)) aguda)))

;; ===================================================

(om::defmethod! MOS-verify ((mos list))
:initvals ' ((1 4/3 16/9 32/27 128/81 256/243 1024/729 4096/2187 8192/6561 32768/19683 65536/59049 262144/177147 2))  
:indoc ' ("list of notes - object-MOS")
:icon 'MOS
:numouts 2
:outdoc ' ("s or L interval" "The ratio of the intervals")
:doc "This object do the verification whether a list of notes is a MOS or not. If yes, informs the internal symmetry of your intervals, s for small intervals and L for Large interval. See Microtonality and the Tuning Systems of Erv Wilson-Routledge of NARUSHIMA."

(values 
    ;OUTPUT1 
     (mos-verify-fun-ratio mos)
          
    ;OUTPUT2
    
      (om::flat (remove nil (loop :for ckn-loop :in (om::arithm-ser 1 (length (om::sort-list mos)) 1) :collect
              (let* (
                (box-sort-list (om::sort-list mos))
                (choose-mos (flat (om::om/ (choose-fun box-sort-list ckn-loop) (list (choose-fun box-sort-list (+ ckn-loop 1)))))))
                (om::sort-list (remove nil choose-mos))))))))




(defun mos-verify-fun-ratio (mos)

      (let* (

          (mos-check-action1 

          (flat (remove nil (loop :for ckn-loop :in (arithm-ser 1 (length (om::sort-list mos)) 1) :collect
              (let* (
                (box-sort-list (om::sort-list mos))
                (choose-mos (flat (om::om/ (choose-fun box-sort-list ckn-loop) (list (choose-fun box-sort-list (+ ckn-loop 1)))))))
                (om::sort-list (remove nil choose-mos)))))))

          (mos-check-action2 (om::sort-list (remove-duplicates mos-check-action1 :test #'equal)))

          (mos-check-action3 (= (length mos-check-action2) 2))

          (mos-check-action4 (loop :for cknloop :in mos-check-action1 :collect
                                  (if (= cknloop (last-elem (om::sort-list (flat mos-check-action2)))) "s" "L"))))

          (if mos-check-action3 mos-check-action4 "This is not a MOS")))


;; ===================================================

(om::defmethod! MOS-check ((ratio number)(sobreposition number) (range number) &optional (intervals 2))
:initvals ' (4/3 60 2)     
:indoc ' ("Just Intonation interval" "sobreposition" "range of check")
:icon 'MOS
:doc "This object creates a Moment of Symmetry without a octave equivalence. For make the octave equivalence use the object Octave-reduce, choose the range of the this MOS. 

MOS is a Theory of the composer Erv Wilson.                  

Wilson coined the term (MOS) to describe those scales resulting from a chain of intervals that produce two (and not three) different-sized intervals. 

These intervals are designated as the small (s) and large (L) intervals (FOR MAKE THIS USE THE OBJECT MOS-verification). 

The relative number of s and L intervals in an MOS is co-prime, i.e., they share no common factors other than 1. Fractions are used to represent MOS scales: the numerator shows the size of the generator, and the denominator shows the number of notes in the scale. 

The numerator and denominator of fractions representing MOS are also co-prime. Wilson organizes these fractions hierarchically on the Scale Tree. MOS are not only scales in their own right but also provide a framework or template for constructing a family of Secondary MOS scales. (in NARUSHIMA - Microtonality and the Tuning Systems of Erv Wilson-Routledge).
"


(let* (
(action1-main 

(mapcar (lambda (sobreposition-mos) 

(let* (

(action1 
(om::sort-list (remove nil (flat (let* (

(action1 (mos-fun-ratio ratio sobreposition-mos range)))

(loop :for ckn-loop :in (arithm-ser 1 (length (om::sort-list action1)) 1) :collect
    (let* (
      (box-sort-list (om::sort-list action1))
      (choose-mos (flat (om::om/ (choose-fun box-sort-list ckn-loop) (list (choose-fun box-sort-list (om::om+ ckn-loop 1)))))))
      (om::sort-list (remove nil choose-mos)))))))))

(action2 (remove-duplicates action1 :test #'equal))

(action3 (= (length action2) intervals)))

(if action3 sobreposition-mos nil))) (arithm-ser 1 sobreposition 1))))

(remove nil action1-main)))




;; ===================================================

(om::defmethod! MOS-complementary ((ratio ratio) (range number) (sobreposition number))
:initvals '(3/2 4 50)    
:indoc ' ("ratio tested" "range (2 for octave) (3 for 10ª + 2¢) etc" "number maximum of sobreposition")
:icon 'MOS
:doc "(ratios fundamental num-mix-max range)"

(let* (
(process (loop :for cknloop :in (arithm-ser 2 sobreposition 1) :collect 

    (let* ( 
        (action1 (mos-fun-ratio ratio cknloop range))
        (action2 (mos-fun-ratio (/ range ratio) cknloop range))
        (action3 (mos-verify-fun-ratio action1))
        (action4 (mos-verify-fun-ratio action2)))
        (if (equal action4 (reverse action3))
(print (om::x-append "interval of" ratio "and its complementary" (/ range ratio) "stacking" cknloop "times are complementary in the range" range)) nil)))))

'end))

;; ====================== CPS =============================

(om::defmethod! cps ((notes list) (quantidade number))
:initvals ' ((1 3 5 7 9 11) 3)
:indoc ' ("This object for make CPS's that are not an Hexany or an Eikosany. " "Number of the combinations of the product.")
:outdoc ' ("harmonics")
:icon 006
:doc "This object makes CPS's that are not an Hexany or an Eikosany. In the first inlet put the harmonic-set. In the second inlet put the number of combinations for each set.

Example: 
      Hebdomekontany: use 8 harmonics and 4 and the 2 inlet.
      Dekanies: Use 3 harmonics and 5 and the 2 inlet.
       "

(cps-fun notes quantidade))

; ====== Functions 

(defun cps-fun (notes quantidade) 

(let* 
(
  (comb (cond
            ((<=  quantidade 0) notes) 
            (t (om::flat-once (malt-cartesian-op notes (malt-combx notes (1- quantidade)) 'om::x-append)))
                )
  )

  (action1 (loop :for cknloop :in comb collect (om::sort-list cknloop)))

  (action2 (remove nil (loop :for cknloop2 :in action1 :collect 
            (if (= (length (remove-duplicates cknloop2 :test #'equal)) quantidade) 
              (remove-duplicates cknloop2 :test #'equal) nil)))))

(remove-duplicates action2 :test #'equal)))

;; ===================================================

(om::defmethod! cps->ratio ((hexany list))
:initvals ' (1 3 5 7)      
:indoc ' ("harmonicos")
:outdoc ' ("List of the combinations of the product/harmonics.")
:icon 006
:doc "This object converts the combination-product set to ratio."

(cps->ratio-fun hexany))

; ====== Functions 

(defun cps->ratio-fun (hexany)
(let* (
  
    (action1 (loop :for cknloop :in hexany :collect (reduce #'* cknloop))))

  (loop :for cknloop2 :in action1 :collect (/ cknloop2 (expt 2 (floor (log cknloop2 2)))))))

;; ===================================================

(om::defmethod! cps->identity ((cps list))
:initvals ' (1 3 5 7)      
:indoc ' ("Combination products set of a Hexany, Eikosany or others.")
:outdoc ' ("Identities")
:icon 006
:doc "This object converts CPS to identity/identities in the theory of Partch."

(loop :for cknloop :in cps :collect (reduce #'* cknloop)))

;; ===================================================

(om::defmethod! cps-chords ((vals list) (n number))
:initvals ' ((1 3 5 7) 4)      
:indoc ' ("Hexa" "chord-notes")
:outdoc ' ("chords")
:icon 006
:doc ""

(let* 

((action0 
(loop :for cknloop :in vals :collect (reduce #'* cknloop)))

(ckn-action (loop :for cknloop2 :in action0 :collect (/ cknloop2 (expt 2 (floor (log cknloop2 2))))))

(comb (let ((n (1- n)))
    (malt-combx ckn-action n)))



  (action1 (loop :for cknloop :in comb :collect 

        (let* ((ordem (om::sort-list cknloop))
               (iguais (let ((L()))
                         (loop :for x :from 0 :to (1- (length ordem)) do
                               (when (not (equal (nth (+ x 1) ordem) (nth x ordem)))
                                 (push (nth x ordem) L)))
                         (reverse L)))
          (final (if (= (length iguais) n) iguais nil))) (remove nil final)))))


(remove-duplicates (remove nil action1) :test #'equal)))


;; ===================================================

(om::defmethod! CPS-connections ((lista list) (ratio number) (stacking number))
:initvals ' ((209/128 1843/1024 133/128 1067/1024 77/64 679/512) 3 4)    
:indoc ' ("list of ratio of a Hexany, Eikosany or others Wilson's CPS" "choose a ratio for the list in inlet1" "3 for triads; 4 for tetrads; etc")
:icon 006
:doc "This object show the connections of a CPS of Erv Wilson in a list of ratios and a number of stacking - example: Triads, Tetrads etcs..."

(print "not ready yet"))

;; ====================== CPS-HEXANY ========================

(om::defmethod! Hexany ((Hexany list))
:initvals ' ((5 7 13 17))    
:indoc ' ("List of just four harmonics.")
:icon 19971997
:doc "This object create a Hexany of the theory of Combination Product-Set of the Composer Erv Wilson."

(if (= 4 (length Hexany)) 

(let* 
(
 (comb (cond
   ((<=  2 0) Hexany)
   (t (om::flat-once 
       (malt-cartesian-op Hexany (malt-combx Hexany (1- 2)) 'om::x-append)))))

 (action1 (loop :for cknloop :in comb :collect (om::sort-list cknloop)))

 (action2 (remove nil (loop :for cknloop2 :in action1 :collect 
          (if (= (length (remove-duplicates cknloop2 :test #'equal)) 2) (remove-duplicates cknloop2 :test #'equal) nil)))))

(remove-duplicates action2 :test #'equal))


(print "This is not a Hexany, The CPS Hexany needs 4 numbers: for example 3 7 13 17")))


;; ===================================================

(om::defmethod! Hexany-triads ((harmonicos list))
:initvals ' (1 3 5 7)      
:indoc ' ("harmonicos")
:outdoc ' ("sub-harmonic" "harmonic")
:numouts 2 
:icon 19971997
:doc "The object hexany-triads construct the triads of the CPS Hexany. It follows the theory presented by Terumi Narushima in your book Microtonality and the Tuning Systems of Erv Wilson. In the outlet of the left, we have the sub-harmonics triads. In the outlet of the right, we have the harmonic triads."

(values 

(let* (
  
  (actionmain (loop :for cknloopmain :in (arithm-ser 1 (length harmonicos) 1) :collect
      (let* (
        
    (comb (cond ((<=  2 0) (remove (choose harmonicos cknloopmain) harmonicos))
   (t (om::flat-once (malt-cartesian-op (remove (choose harmonicos cknloopmain) harmonicos) (malt-combx (remove (choose harmonicos cknloopmain) harmonicos) (1- 2)) 'om::x-append)))))

    (action1 (loop :for cknloop :in comb :collect 

        (let* ((ordem (om::sort-list cknloop))
               (iguais (let ((L()))
                         (loop :for x :from 0 :to (1- (length ordem)) :do
                               (when (not (equal (nth (+ x 1) ordem) (nth x ordem)))
                                 (push (nth x ordem) L)))
                         (reverse L)))
          (final (if (= (length iguais) 2) iguais nil))) (remove nil final)))))


(remove-duplicates (remove nil action1) :test #'equal))))

(actionmain2 (loop :for ckn-loop :in actionmain :collect (loop :for ckn-loop2 :in ckn-loop :collect (reduce #'* ckn-loop2)))))

(loop :for cknloop2 :in actionmain2 :collect (loop :for cknloop3 :in cknloop2 :collect (/ cknloop3 (expt 2 (floor (log cknloop3 2)))))))

; ====

(let* ((ratios (loop :for cknloop4 :in (arithm-ser 1 (length harmonicos) 1) :collect 
       (let* ((choose (nth (- cknloop4 1) harmonicos)))
         (om::om* choose (remove choose harmonicos))))))

(loop :for cknloop2 :in ratios :collect (loop :for cknloop3 :in cknloop2 :collect (/ cknloop3 (expt 2 (floor (log cknloop3 2)))))))))
     

;; ===================================================

(om::defmethod! Hexany-connections ((harmonico list) (hexany list))
:initvals ' ((3 13) ((3 5) (3 13) (5 13) (3 21) (5 21) (13 21)))    
:indoc ' ("list of two harmonics" "list of just four harmonics")
:icon 19971997
:doc "This object shown the Hexany connections of the theory of Combination Product-Set of the Composer Erv Wilson."

(let*
  ((action1 (loop :for cknloop :in hexany
   collect (let*  ((result1 (first harmonico)) (result2 (first cknloop)) (result3 (second harmonico)) (result4 (second cknloop)))
       
             (remove nil 
                     (remove-duplicates (list
                             (if (or  (= result1 result2) (= result1 result3)) cknloop nil) 
                             (if (or (= result3 result2) (= result3 result4)) cknloop nil)) :test #'equal))))))
        
  (flat (remove nil action1) 1)))

;; ====================== CPS-EIKOSANY ====================

(om::defmethod! eikosany ((6-notes list))
:initvals ' ((1 3 5 7 9 11))      
:indoc ' ("six harmonic notes | if you don't put 6 notes the result will not be an eikosany.")
:outdoc ' ("harmonic")
:icon 1997
:doc "This object will construct a Combination-Product-Set (CPS) with 6 numbers or harmonics. This 6 harmonics will form Twenty ratios."

(cps-eikosany-fun 6-notes))

; ====== Functions 

(defun cps-eikosany-fun (6-notes)

(let* 
(
 (comb (cond
   ((<=  3 0) 6-notes)
   (t (om::flat-once 
       (malt-cartesian-op 6-notes (malt-combx 6-notes (1- 3)) 'om::x-append)))))

 (action1 (loop :for cknloop :in comb collect (om::sort-list cknloop)))

 (action2 (remove nil (loop :for cknloop2 :in action1 :collect 
          (if (= (length (remove-duplicates cknloop2 :test #'equal)) 3) (remove-duplicates cknloop2 :test #'equal) nil)))))

(remove-duplicates action2 :test #'equal)))

;; ===================================================

(om::defmethod! eikosany-triads ((6-notes list))
:initvals ' ((1 3 5 7 9 11))      
:indoc ' ("three harmonic notes | if you don't put 3 notes the result will not be an eikosany triads.")
:outdoc ' ("sub-harmonic" "harmonic")
:numouts 2
:icon 1997
:doc "The object eikosany-triads construct the triads of the CPS eikosany. It follows the theory presented by Terumi Narushima in your book Microtonality and the Tuning Systems of Erv Wilson. In the outlet of the left, we have the sub-harmonics triads. In the outlet of the right, we have the harmonic triads."

(values 

;; subharmonic

(let* ((action1 (cps-fun 6-notes 3))

(action2 (loop :for cknloop5 :in action1 :collect (rt-octave-fun
              (let* ((action2-1 (set-difference 6-notes cknloop5))
                     (action2-2 (cps->ratio-fun (cps-fun cknloop5 2))))
                (loop :for cknloop6 :in action2-1 :collect (om::om* action2-2 cknloop6))) 2))))
(flat action2 1))


;;harmonic

(let* ((action1 (cps-fun 6-notes 3))

(action2 (loop :for cknloop1 :in action1 :collect (rt-octave-fun
          (let* ((action2-1 (cps->ratio-fun (cps-fun (set-difference 6-notes cknloop1) 2))))
            (loop :for cknloop1-1 :in action2-1 :collect (om::om* cknloop1 cknloop1-1))) 2))))

(flat action2 1))))

;; ===================================================

(om::defmethod! eikosany-tetrads ((6-notes list))
:initvals ' ((1 3 5 7 9 11))      
:indoc ' ("three harmonic notes | if you don't put 3 notes the result will not be an eikosany triads.")
:outdoc ' ("sub-harmonic" "harmonic")
:numouts 2
:icon 1997
:doc "The object eikosany-tetrads construct the tetrads of the CPS Eikosany. It follows the theory presented by Terumi Narushima in your book Microtonality and the Tuning Systems of Erv Wilson. In the outlet of the left, we have the sub-harmonics tetrads. In the outlet of the right, we have the harmonic tetrads."

(values 
;; sub-harmonic
  (let* (
      (action1 (cps-fun 6-notes 4))
        )
      (loop :for cknloop :in action1 :collect (cps->ratio-fun (cps-fun cknloop 3)))
  )

;; harmonic

(let* (
(action1 (cps-fun 6-notes 4)))

(loop :for cknloop :in action1 :collect 
      (rt-octave-fun (let*
          ((action2-1 (set-difference 6-notes cknloop))
          (action2-2 (reduce #'* action2-1)))
          (om::om* cknloop action2-2)) 2)))))


;; ===================================================

(om::defmethod! eikosany-connections ((vertice list) (eikosany list))
:initvals ' ((1 3 9) ((1 3 5) (1 3 7) (1 5 7) (3 5 7) (1 3 9) (1 5 9) (3 5 9) (1 7 9) (3 7 9) (5 7 9) (1 3 11) (1 5 11) (3 5 11) (1 7 11) (3 7 11) (5 7 11) (1 9 11) (3 9 11) (5 9 11) (7 9 11)))    
:indoc ' ("list of tree harmonics" "list of the cps-eikosany")
:icon 1997
:doc "This object shown the Eikosany connections of the theory of Combination Product-Set of the Composer Erv Wilson."

(defun same-elem-p (lst1 lst2)
  (cond ((not (null lst1))
         (cond ((member (car lst1) lst2)
                (same-elem-p (cdr lst1) lst2))
               (t nil)))
        (t t)))

(let* ((task1 (loop :for cknloop :in eikosany :collect (if
          
      (<= 2 (reduce #'+ 
                      (om::x-append
              (if (same-elem-p (list (first vertice)) cknloop) 1 nil)
              (if (same-elem-p (list (second vertice)) cknloop) 1 nil)
              (if (same-elem-p (list (third vertice)) cknloop) 1 nil))))
           cknloop nil))))
(remove nil task1)))

;; ;; =================================== Charles' Functions =======================================

(om::defmethod! ji-change-notes ((notas list) (afinação list))
:initvals '((6000 6100 6200 6300 6400 6500 6600 6700 6800 6900 7000 7100 7200) (6000 6498 6996 6294 6792 6090 6588 7086 6384 6882 6180 6678 7200))    
:indoc ' ("Some list of notes in midicents" "some tuning system")
:icon 002
:doc "This object change the notes of the first inlet by the nearest notes of the second inlet."

(let* (
(action1 (om::om-abs(loop for x in notas collect (om::om- afinação x))))
(action2 (mapcar (lambda (x) 
                   (let* (
                          (action1 (apply 'min x))
                          (action2 (position action1 x)))
                     (nth action2 afinação))) action1)))
action2))

;; ;; =================================== 

(om::defmethod! ji-range-change-notes ((timbre list) (afinacao list) (range list))
:initvals '((6000 6100 6200 6300 6400 6500 6600 6700 6800 6900 7000 7100 7200) (6000 6498 6996 6294 6792 6090 6588 7086 6384 6882 6180 6678 7200) (30 500))    
:indoc ' ("Some list of notes in midicents" "some tuning system" "range")
:icon 002
:doc "This object change the notes of the first inlet by the nearest notes of the second inlet following the range in cents."

(loop :for x :in timbre 
      :collect (let* (
      
      (action1 (lambda (a) 
                          (if (and  (<= (first range) (abs (om::om- x a))) 
                                    (>= (second range) (abs (om::om- x a)))) a nil)))
      (action2 (mapcar action1 afinacao)))
      (om::nth-random (flat (list (remove nil action2)))))))                             


;; ;; =================================== Temperament =======================================

(om::defmethod! mk-temperament ((fund number)(ratio number) (division number))
:initvals ' (6000 2 24)     
:indoc ' ("inicial-note" "interval: 2 for octave, 3/2 for a fifth division, etc" "divison for the interval, for example: 24 divison of the octave")
:icon 004
:doc "Create a temperament."

(let* () 
(print "Temperamented music, really?")
(om::x-append fund (f->mc (om::om* (mc->f fund) (om::om^ (expt ratio (/ 1 division)) (arithm-ser 1 division 1)))))))


;; ;; =================================== Math =============================================

(om::defmethod! Prime-decomposition ((harmonic list))
:initvals ' ((9 18 172))     
:indoc ' ("Number or numbers list.")
:outdoc ' ("Prime-decomposition" "Prime-decomposition without the number 2. It represents the octave interval")
:icon 004
:doc "It does the decomposition of prime numbers. This can be useful with identities by Harry Partch, mainly, when we use the conception of identity by Ben Johnston: 'Each prime number used in deriving a harmonic scale contributes to a characteristic psychoacoustical meaning (JOHNSTON, 2006, p. 27).'

In this object we can undestand how identities can be connected using the theory of CPS of the Erv Wilson. 

 Lisp code of https://sholtz9421.wordpress.c/2012/10/08/prime-number-factorization-in-lisp/."
:numouts 2 


(values 

;; ============================= SEM EQUIVALENCIA ============

(loop :for x :in harmonic 
      :collect 
      (if (is-prime x) (print (format nil "~d e primo" x))
                 (let* (
                                           (fatoracao (factor x))
                                           (combinations (cps fatoracao (1- (length fatoracao)))))
                                           (loop :for z :in (reverse fatoracao)
                                                  :for loop-combinations :in combinations
                                                  :do (om::om-print (format nil "~d pode ser interpretado como o ~d harmonico de ~d." x z 
                                                                       (reduce (lambda (x y) (om::om* x y)) loop-combinations)) "Sem equivalencia de oitavas"))
                                       fatoracao)))

;; ============================= COM EQUIVALENCIA ============


(let* ()
(print "

==================  COM EQUIVALENCIA DE OITAVAS =======================

")
(loop :for x :in harmonic 
      :collect 
(if (is-prime x) (print (format nil "~d e primo" x))
                                      (let* (
                                        (action1 (factor x))
                                        (action2 (remove 2 action1)))
                                        (if (equal nil action2) (list 1)
                                          (let* (
                                           (combinations (if (om::om< (length (om::list! action2)) 2) (om::list! action2) (cps action2 (1- (length action2))))))
                                           (loop :for z :in (reverse action2)
                                                  :for loop-combinations :in combinations
                                                  :do (om::om-print (format nil "~d pode ser interpretado como o ~d harmonico de ~d." x z 
                                                                       (if (equal 1 (length (om::list! loop-combinations))) loop-combinations 
(reduce (lambda (x y) (om::om* x y)) loop-combinations))) "Com equivalencia de oitavas"))))
                                        action2))))))



;; ;; =================================== Others =============================================

(om::defmethod! send-max ((maxlist list))
:initvals ' (6000 2 24)     
:indoc ' ("list")
:icon 007
:doc "Send for MAX/MSP. This work with a list not list of lists. See the patch CKN-OSCreceive in charlesneimog.com"

(let ((send (om::osc-send (om::x-append "/max" maxlist) "127.0.0.1" 7839)))
(print "Done!")))

;; ===================================================

(om::defmethod! midicents->midi ((maxlist list))
:initvals ' (6000)     
:indoc ' ("list of midicents")
:icon 007
:doc "Convert midicents in MIDI floats for manipulation in MAX/MSP."

(loop for y in maxlist collect (om::om* 0.01 y)))

;; ===================================================

(om::defmethod! gizmo ((note list) (fund number))
:initvals ' ((6386) (6000))    
:indoc ' ("list of midicents" "fund of the gizmo")
:icon 007
:doc "Convert midicents for the max object gizmo~."

(om::om* 0.01 (- note fund))    )

; ========================================== OM#-PLAY =======================

(defun chord->voice (lista-de-notas)

(mktree
 (loop for i from 1 to (length lista-de-notas)
  collect (let* () 1/4))
 (list 4 4)))

(defun normalize-chord-seq (chrdseq)
  (let* ((xdx (om::x->dx (om::lonset chrdseq)))
         (filt-durs1 (mapcar 'list-min (om::ldur chrdseq)))
         (lst-durs (mapcar 'list xdx filt-durs1))
         (filt-durs2 (mapcar 'list-min lst-durs))
         (newdurs (loop 
                   :for pt :in (om::lmidic chrdseq)
                   :for drs :in filt-durs2
                   collect (repeat-n drs (length pt)))))
    (make-instance 'chord-seq 
                   :lmidic (om::lmidic chrdseq)
                   :lonset (om::lonset chrdseq)
                   :ldur newdurs)))

(defun choose-fun (notelist chord-n) (nth (- chord-n 1) notelist))


(defun true-durations (ckn)

 (let* ((newchrdseq (if (typep ckn 'note) 
                           (om::Objfromobjs (om::Objfromobjs ckn (make-instance 'chord)) (make-instance 'chord-seq))
                           (om::Objfromobjs ckn (make-instance 'chord-seq))))

         (newcs (normalize-chord-seq newchrdseq))
         (onsets (om::Lonset newcs))
         (dur (om::Ldur newcs))
         (newonsets (if (= 2 (length onsets)) (om::x->dx  onsets) (butlast (om::x->dx onsets))))
         (newdurs (mapcar 'first dur))
         (resultat1 
          (om::x-append 
          (flat
           (list (mapcar #'(lambda (x y) (if (= 0 (- x y)) x 
                                             (list x (- x y))))
                         newdurs newonsets)
                 (last newdurs)))
          (last-elem newdurs)))
         (resultat2 (butlast
                     (if (= 0 (first onsets)) resultat1 (cons (om::om* -1 (first onsets)) resultat1)))))
    
   (let ((result (remove nil (mapcar #'(lambda (x) (if (not (or (= x 1) (= x -1))) x ))
          resultat2))))
         (if (= 2 (length onsets)) (list (car result) (second result)) result))
   ))


(defun voice->text-fun (ckn number-2)

(let* (
(ckn-action1  (loop :for ckn-plus :in (true-durations ckn) :collect (if (plusp ckn-plus) 0 1)))

(ckn-action2 (loop :for cknloop :in ckn-action1 :collect (if (= 0 cknloop) (setq number-2 (+ number-2 1)) nil)))

(ckn-action3 

      (let* (
        (ckn-action3-1 
          (if (equal nil (first ckn-action2)) 0 (first ckn-action2))))
        (if (equal nil (first ckn-action2)) (om::om+ (om::om- ckn-action2 ckn-action3-1) -1) (om::om+ (om::om- ckn-action2 ckn-action3-1) 1))     
        
      )))

(loop :for cknloop-1 :in ckn-action3 :for cknloop-2 :in (om::dx->x 0 (loop :for y :in (true-durations ckn) :collect (om::abs y))) :for cknloop-3 :in (true-durations ckn) :collect          
        (if (plusp cknloop-3) 
            (om::x-append 
               (if (plusp cknloop-3) cknloop-2 nil) "," 
                  (om::x-append  
                  (choose-fun (flat (om::get-slot-val (om::make-value-from-model 'voice ckn nil) "LMIDIC")) cknloop-1) 
                  (choose-fun (flat (om::get-slot-val (om::make-value-from-model 'voice ckn nil) "lvel")) cknloop-1)
                  (choose-fun (flat (om::get-slot-val (om::make-value-from-model 'voice ckn nil) "lchan")) cknloop-1)
                    (if (plusp cknloop-3) cknloop-3 nil) 
                       ";")) nil))))

(defun voice->text-max (ckn number-2)

(let* (
(ckn-action1  (print (loop :for ckn-plus :in (true-durations ckn) :collect (if (plusp ckn-plus) 0 1))))

(ckn-action2 (print (loop :for cknloop :in ckn-action1 :collect (if (om::om= 0 cknloop) (setq number-2 (om::om+ number-2 1)) nil))))

(ckn-action3 

      (print (let* (
        (ckn-action3-1 
          (if (equal nil (first ckn-action2)) 0 (first ckn-action2))))
        (if (equal nil (first ckn-action2)) (om::om+ (om::om- ckn-action2 ckn-action3-1) -1) (om::om+ (om::om- ckn-action2 ckn-action3-1) 1))     
        
      ))))

(loop :for cknloop-1 :in ckn-action3 :for cknloop-2 :in (om::dx->x 0 (loop :for y :in (true-durations ckn) :collect (abs y))) :for cknloop-3 :in (true-durations ckn) :collect          
        (if (plusp cknloop-3) 
            (om::x-append 
               (if (plusp cknloop-3) cknloop-2 nil)
                  (om::x-append  
                  (choose-fun (om::get-slot-val (om::make-value-from-model 'voice ckn nil) "LMIDIC") cknloop-1) 
                  (choose-fun (om::get-slot-val (om::make-value-from-model 'voice ckn nil) "lvel") cknloop-1)
                  (choose-fun (om::get-slot-val (om::make-value-from-model 'voice ckn nil) "lchan") cknloop-1)
                    (if (plusp cknloop-3) cknloop-3 nil) 
                       )) nil))))


; ===========================================================================

(om::defmethod! play-om# ((voice VOICE))
:initvals ' ((nil))       
:indoc ' ("A player for OM#")
:outdoc ' ("PLAY")
:icon 0000
:numouts 1
:doc "It is a player for OM#. You can download the Max/MSP patch in:  <https://bit.ly/32K0och>.

For the automatic work the folder out-files of OM# must be in the files preferences of the Max/MSP."

  (let* (
    (ckn-action4 (remove nil (voice->text-max voice 1))))

        (let* (
            (action1 
                (progn (om::osc-send (om::x-append '/reset 1) "127.0.0.1" 3003)
                 (loop for cknloop in ckn-action4 :collect (om::osc-send (om::x-append '/note cknloop) "127.0.0.1" 3003))))
            (action2 (om::osc-send (om::x-append '/note-pause 1) "127.0.0.1" 3003)))
      '("play"))))


; ===========================================================================

(om::defmethod! voice->text ((voice VOICE))
:initvals ' ((nil))       
:indoc ' ("A player for OM#")
:outdoc ' ("PLAY")
:icon 0000
:numouts 1
:doc "It is a player for OM#. You can download the Max/MSP patch in:  <https://bit.ly/32K0och>.

For the automatic work the folder out-files of OM# must be in the files preferences of the Max/MSP."
(let
 ((tb (om::make-value 'textbuffer (list (list :contents (voice->text-fun voice 1)))))) 
 (setf (om::reader tb) :lines-cols) tb))

 ; ===========================================================================
 
;; By Jordana Dias Paes Possani de Sousa and Charles K. Neimog | copyright © 2020
(om::defmethod! apex-vibro ((freq number))
:initvals ' (440)
:indoc ' ("valor da frequência") 
:icon 008
:doc "It gives the distance between the apice of the coclea and the vibration point of a determinate frequence."

(/ (log (/ freq 165) 10) 0.06))

; =================================== Functions of Others OM libraries ================


; I will put some functions of others Libraries here for do the use more simple for people that don't know how OpenMusic work.

; ===========================================================================

(defun is-prime (n &optional (d (- n 1))) 
  (if (/= n 1) (or (= d 1)
      (and (/= (rem n d) 0)
           (is-prime  n (- d 1)))) ()))

; ===========================================================================

(defun list-of-listp (thing) (and (listp thing) (every #'listp thing)))
(deftype list-of-lists () '(satisfies list-of-listp))

;; Thanks for Reddit user DREWC for code of list-of-listp and list-of-lists.

; ================================= ratio->cents by Mauricio Rodriguez =======

(defun ratio->cents (ratio)
  (om::om* (/ 1200 (log 2)) (log ratio)))

;; DISSONANCE SENSORY => Mauricio Rodriguez after William A. Sethares

; ================================= list->string =======

(defun list->string (ckn-list)
  (when ckn-list
    (concatenate 'string 
                 (write-to-string (car ckn-list)) (list->string (cdr ckn-list)))))

                
;; Code by "https://gist.github.c/tompurl/5174818"

;; ================== PASCAL TRIANGULE ======================

(defun pascal (n)
   (genrow n '(1)))
 
(defun genrow (n l)
   (when (< 0 n)
       (print l)
       (genrow (1- n) (cons 1 (newrow l)))))
 
(defun newrow (l)
   (if (> 2 (length l))
      '(1)
      (cons (+ (car l) (cadr l)) (newrow (cdr l)))))


;; https://stackoverflow.c/questions/25903972/pascal-triangle-in-lisp/25904053

; =================================== NUMBER ================

(defun classify (n)
  (when (and (integerp n) (plusp n))
    (let ((alq-sum (aliquot-sum n)))
      (cond ((> alq-sum n) "abundant")
            ((< alq-sum n) "deficient")
            (T "perfect")))))

(defun aliquot-sum (n)
  (apply #'+ (factor-list n)))

(defun factor-list (n)
  (loop for i from 1 below n 
     when (zerop (mod n i)) collecting i))

; =================================== NUMBER ================

(defun factor (n)
  "Return a list of factors of N."
  (when (> n 1)
    (loop with max-d = (isqrt n)
	  for d = 2 then (if (evenp d) (+ d 1) (+ d 2)) do
	  (cond ((> d max-d) (return (list n))) ; n is prime
		((zerop (rem n d)) (return (cons d (factor (truncate n d)))))))))


; =================================== COMBINE BY MIKHAIL MALT (IRCAM 1993-1996) ================


(defun malt-cartesian-op (l1 l2 fun) 

  (mapcar #'(lambda (x) (mapcar #'(lambda (y) (funcall fun x y)) (om::list! l2))) (om::list! l1))
      )

(defun malt-combx (vals n)
  (cond
   ((<=  n 0) vals)
   (t (om::flat-once 
       (malt-cartesian-op vals (malt-combx vals (1- n)) 'om::x-append)))))


; ===========================================================================

(defun to-voice (x)

(om::mktree  (loop for i from 1 to (length x) collect (let* () 1/4))  (list 4 4)))


(defun to-play (x)

(om::make-value 'voice (list (list :tree (om-ji::to-voice x)) (list :lmidic x) (list :tempo 40) (list :lchan 9))))




(print 
 "
                                              -JI
      by Charles K. Neimog | charlesneimog.com  
   Universidade Federal de Juiz de Fora (2019-2020)
"
)