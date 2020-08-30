;; Functions by Charles K. Neimog (2019 - 2020) | Universidade Federal de Juiz de Fora | charlesneimog.com

(in-package :om)

;; ======================================== Just-Intonation ==============================

(defmethod! rt->mc ((ratio list) (fundamental number))
:initvals ' ((1/1 11/8 7/4) (6000))
:indoc ' ("Convert list of ratios to midicent." "This will be a note. This note will be the fundamental (reference note) of the list of ratios.") 
:icon 002
:doc "It converts ratio for midicents notes."

(if (let ((foo ratio)) (typep foo 'list-of-lists))

(loop :for cknloop :in ratio :collect (loop :for n :in cknloop :collect (+ fundamental (ratio->cents n))))
(loop :for n :in ratio :collect (+ fundamental (ratio->cents n)))))

;; =================

(defmethod! rt->mc ((ratio number) (fundamental number))
:initvals ' (11/8 6000)
:indoc ' ("Convert list of ratios for midicent." "This will be a note. This note will be the fundamental of the list of ratios.") 
:icon 002
:doc "It converts ratio for midicents notes."

(+ fundamental (ratio->cents ratio)))

;; ===================================================

(defmethod! octave-reduce ((note list) (octave number))
:initvals ' ((4800 7200 6000) 1)
:indoc ' ("List of midicents."  "Octaves of this reduction.")
:icon 002
:doc "This object reduces a list of notes in a determinate space of octaves. The note of the first inlet will be the more down note allowed, and in the second inlet must be the octaves of the higher notes that will be allowed." 

(let* ((range (* octave 1200))
(grave (first (sort-list note))))

(if (let ((foo note)) (typep foo 'list-of-lists))

;; Lista de listas
;; Lista
   
      (loop :for listadelista :in note :collect (mapcar #' (lambda (x) (+ (mod x range) grave)) listadelista))
      (mapcar #' (lambda (x) (+ (mod x range) grave)) note))))


;; ===================================================

(defmethod! range-reduce ((notelist list) (grave number) (aguda number) &optional (octave-r 1))
:initvals ' ((4800 7200 6000) 6000 7902 1)
:indoc ' ("List of midicents" "The lowest note." "The highest note." "It must be used in the reduction of the pitch-range. In which, the reduction will be by + or - of 1200 cents (1), 2400 cents (2), 3600 cents (3); etc...")
:icon 002
:doc "This object reduce a list of notes in a determinate space. The note of the first inlet will be the more lowest note allowed, and the note of the second inlet will be the more higher note allowed."

(let* ((octave-redution (* 1200 octave-r)))
(if (om>= (- aguda grave) 1200)
(if (let ((foo notelist)) (typep foo 'list-of-lists))

(loop :for notelistloop :in notelist :collect
      (mapcar (lambda (x)
	            (loop :for new-val := x :then (if (< new-val aguda)
			            (+ new-val octave-redution)
			            (- new-val octave-redution))
		              :until (and (<= grave new-val)
			            (>= aguda new-val))
		              :finally (return new-val)))
  	          notelistloop))

(mapcar (lambda (x)
	           (loop :for new-val := x :then (if (< new-val aguda)
			           (+ new-val octave-redution)
			            (- new-val octave-redution))
		              :until (and (<= grave new-val)
			            (>= aguda new-val))
		            :finally (return new-val)))
	        notelist)) 
          
(print "RANGE-REDUCE: The difference between the inlet2 e inlet3 must be at least 1200 cents"))))


;;; Do the reduction of a list in this way in two octaves (6000 8400)
; 1. Give the (6000 6552 6900 7300 7600 7800 8300 9100 9500 10400)
; 2. Just in 8400 this will reduce the list of notes to 6000 not to 8400.

;; ===================================================

(defmethod! filter-ac-inst ((notelist list) (approx integer) (temperament integer))
:initvals ' ((6000 6530 7203 5049) 10 2)
:indoc ' ("List of notes (THIS OBJECT DON'T READ LISTS OF LIST.)" "Cents aproximation of a tempered note." "Tempered scale used to compare the note list.") 
:icon 002
:doc "Filter of notes that can be played by an acoustic instrument with quarte tones, eight-tones, or others."

(let* ((filter 
(loop :for cknloop :in notelist :collect 

      (if (om= (om+ 
          (first (list (if (om< (om- cknloop (approx-m cknloop temperament)) approx) 1 0)
                       (if (om> (om- cknloop (approx-m cknloop temperament)) (om- approx (om* approx 2))) 1 0))) 

              (second (list 
                       (if (om<  (om- cknloop (approx-m cknloop temperament)) approx) 1 0) 

                       (if (om> (om- cknloop (approx-m cknloop temperament)) (om- approx (om* approx 2))) 1 0)))) 2) cknloop 0))))


(list-filter #'(lambda (x) (om= x 0)) filter 'reject)))

;; ===================================================

(defmethod! modulation-notes ((listnote list) (listnote2 list) (cents integer))
:initvals ' ((6000 6530) (7203 5049) 2)
:indoc ' ("First notelist of the comparation." "Second notelist of the comparation." "Approximation in cents, in which the object will consider the notes as equal. For example, with the number 5, the object will consider 6000 and 6005 as equal notes.")
:icon 002
:doc "Filter of notes that can be used to do the modulation between tuning regions. This idea appears in the reading of Daniel James Huey (2017) doctoral dissertation. He claims: 'This dissertation shows the importance of common tones between pitches of two tuning areas, and it highlights consonant intervals between the fundamental pitches of the tuning areas as a means of producing a sense of continuity.'"

(let* ((result (loop :for cknloop1 :in listnote :collect (loop :for cknloop2 :in listnote2 :collect 
      (if (om= (+ 
          (if (< (om- (om- cknloop1 cknloop2) (approx-m (om- cknloop1 cknloop2) 2)) cents) 1 0) 
          (if (> (om- (om- cknloop1 cknloop2) (approx-m (om- cknloop1 cknloop2) 2)) (om- cents (* cents 2))) 1 0)) 2) (list cknloop1 cknloop2) 0)))) 

(result2 (remove 0 (flat result 1)))

(result3 (loop :for note :in result2 :collect 
        (if (and (om< (om- 
                       (first (mapcar #' (lambda (x) (+ (mod x 1200) 6000)) note)) 
                       (second (mapcar #' (lambda (x) (+ (mod x 1200) 6000)) note))) cents)
                 (om< (om- cents (om* cents 2)) 
                      (om- (first (mapcar #' (lambda (x) (+ (mod x 1200) 6000)) note)) 
                      (second (mapcar #' (lambda (x) (+ (mod x 1200) 6000)) note))))) note 0)))
(result4 (remove 0 result3)))

(progn (loop :for x in result4 do (print (x-append "The note" (first x) "(of the first inlet)" "can be modulated using the note" (second x) "(of the second inlet)"))) 'finish)))

;; ===================================================

(defmethod! modulation-notes-fund ((listnote list) (listnote2 list) (cents integer) (temperamento integer))
:initvals ' ((6000 6530) (7203 5049) 10 4)
:indoc ' ("First notelist of the comparation" "Second notelist of the comparation" "Aproximação de escala temperada 1/2 1/4 1/8 de tom" "temperament! 2 for 2-DEO 4 for 24-DEO") 
:icon 002
:doc "Filter of notes that can be used to do the modulation between tuning regions changing the fundamental of the second list (second inlet). This object is an update of the object called modulation-notes'"

(let* ((result (loop :for cknloop1 :in listnote :collect 

                     (loop for cknloop2 in listnote2 collect (if (om= (+ 
                                                          (if (< (om- (om- cknloop1 cknloop2) 
                                                                 (approx-m (om- cknloop1 cknloop2) temperamento)) cents) 1 0) 
                                                          (if (> (om- (om- cknloop1 cknloop2) 
                                                                 (approx-m (om- cknloop1 cknloop2) temperamento)) (om- cents (* cents 2))) 1 0)) 2) 
                                                                                                  (list cknloop1 cknloop2) 0))))
(result2 (remove 0 (flat result 1))))

  (loop :for cknloop3 :in result2 :do (print  (let*  
                                               ((result3-2 (om- (first cknloop3) (second cknloop3))))

  (if 
      (or (om= result3-2 0) (om= result3-2 1200) (and (om> 10 result3-2) (om< -10 result3-2))) (x-append cknloop3 "are equal")
      (x-append cknloop3 "will be equal if the second list have has the fundamental with the difference of" (approx-m result3-2 temperamento) 'cents))))) 'end))

;; ===================================================

(defmethod! choose ((notelist list) (chord-n integer))
:initvals ' ((1 2 3 4 5 6 7 8 9 10) 2)
:indoc ' ("List or list of lists of anything" "What element(s) do you want?") 
:icon 002
:doc "This object choose an element in a list; or a list in a list of lists. If you put more that one element in the second inlet this object will choose all the elements that you put in second inlet.
Inlet1: (7 8 9 10 458)
Inlet2: (1 3 5)
Result: (7 9 458)."

(nth (om- chord-n 1) notelist))


(defmethod! choose ((notelist list) (chord-n list))
:initvals ' ((1 2 3 4 5 6 7 8 9 10) (1 7 9))
:indoc ' ("List or list of lists of anything." "What element(s) do you want?") 
:icon 002
:doc "This object choose an element in a list; or a list in a list of lists. If you put more that one element in the second inlet this object will choose all the elements that you put in second inlet.
Inlet1: (7 8 9 10 458)
Inlet2: (1 3 5)
Result: (7 9 458)."

(loop :for cknloop :in chord-n :collect (nth (om- cknloop 1) notelist)))

;; ===================================================

(defmethod! rt-octave ((fraq list) &optional (octave 2))
:initvals ' ((1/3 1 5/3) 2)
:indoc ' ("List of ratios" "2 for one octave; 4 for 2 octaves; 8 for 3; etc...") 
:icon 002
:doc "This object reduce ratios for one octave (or two or others; optional function), your function is similar to the object octave-reduce, but it operates in ratios domain."

(rt-octave-fun fraq octave))


(defmethod! rt-octave ((fraq ratio) &optional (octave 2))
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


;; =================================== Harry Partch ==========================================
(defmethod! Diamond ((limite integer))
:initvals ' (11)      
:indoc ' ("Limit-n for the diamond.")
:outdoc ' ("utonality" "otonality")
:numouts 2 
:icon 003
:doc "Create a Tonality-Diamond according to Harry Partch's Theory. This tonality construct ratios with the identities (odd-numbers) of a limit. This object reproduces the process of the Tonality Diamond find in:

<https://bit.ly/3hAcLh1>. This diamond is a diamond with limit-5, so we have 3 identities (all the odd-numbers until 5) 1, 5, and 3.

In the outlet of the left, the result is the utonal-diamond. Outlet of the right is the otonality-diamond."

(values 
(let* ((ordem-partch (loop :for x :in (sort-list (rt-octave-fun (arithm-ser 1 limite 2) 2)) :collect (numerator x))))
  (loop :for x :in ordem-partch :collect (loop :for y :in ordem-partch :collect (/ x y))))

(let* ((ordem-partch2 (loop :for x :in (sort-list (rt-octave-fun (arithm-ser 1 limite 2) 2)) :collect (numerator x))))
  (loop :for x :in ordem-partch2 :collect (loop :for y :in ordem-partch2 :collect (/ y x))))
)

)

;; ===================================================

(defmethod! Diamond-Identity ((identity list))
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
(defmethod! otonal-inverse ((otonal list))
:initvals ' ((1/1 3/2 5/4))       
:indoc ' ("otonal chord")
:icon 003
:doc "It gives the utonal chord of a otonal chord. In other words, intervals ascendants become intervals descent."

(let* (

(task1 (loop :for y :in otonal :collect (denominator y)))
(task2 (loop :for y :in otonal :collect (numerator y))))
(om/ task1 task2)))

;; ===================================================
-
(defmethod! utonal-inverse ((utonal list))
:initvals ' ((1/1 4/3 6/5))       
:indoc ' ("Utonal chord.")
:icon 003
:doc "It gives the otonal chord of a utonal chord. In other words, intervals descents become intervals ascendants."

(let* (

(task1 (loop :for y :in utonal :collect (numerator y)))
(task2 (loop :for y :in utonal :collect (denominator y))))
(om/ task1 task2)))


;; ;; =================================== Ben Johnston ======================================

(defmethod! interval-sob ((ratio number) (sieve list))
:initvals '(11/8 (2 3 7 11 12))     
:indoc '("Just Intonation interval" "List of sobreposition")
:icon 001
:outdoc '("Utonal sobreposition." "Otonal sobreposition.")
:numouts 2 
:doc "The object interval-sob creates a sobreposition of the same interval. 

OBS.: It was constructed using ascendant ratios intervals (the numerator is greater than the denominator), so if you use an interval that is descent (the denominator is greater than the numerator), the outlet of the left give the Otonal sobreposition (stacking) and the outlet of the right give Utonal Sobreposition (stacking)."

(values 

(let* ((sobreposition (om^ ratio sieve))
(task1 (loop :for y :in sobreposition :collect (denominator y)))
(task2 (loop :for y :in sobreposition :collect (numerator y))))
(om/ task1 task2))

(let* ((sobreposition (om^ ratio sieve))
(task1 (loop :for y :in sobreposition :collect (numerator y)))
(task2 (loop :for y :in sobreposition :collect (denominator y))))
(om/ task1 task2))

))

;; ===================================================

(defmethod! arith-mean ((grave number) (agudo number))
:initvals ' (1/1 2/1)
:indoc ' ("first ratio" "second ratio")
:icon 001
:doc "It gives the arithmetic mean of two ratio. 

This is a procedure used by Ben Johnston in your strings quartets no. 2 and no. 3. See the article Scalar Order as a Compositional Resource (1964)."

(/ (+ grave agudo) 2))

;; ===================================================

(defmethod! arith-mean-sob ((grave number) (agudo number))
:initvals ' (1/1 5/4)
:indoc ' ("First ratio" "Second ratio")
:icon 001
:doc "It gives the arithmetic mean of two ratios, and it does the ascendant sobreposition of the result with the first ratio and the descent sobreposition with the second ratio.

This is a procedure used by Ben Johnston in your strings quartets no. 2 and no. 3. See the article Scalar Order as a Compositional Resource (1964)."

(x-append grave (/ agudo (/ (+ grave agudo) 2)) (* grave (/ (+ grave agudo) 2)) agudo))

;; ===================================================

(defmethod! johnston-sob ((ratio number) (sobreposition number) (fundamental number))
:initvals ' (3/2 3 7200)
:indoc ' ("first ratio" "sobreposition number" "fundamental")
:icon 001
:doc "Gilmore (1995, p. 477) will suggest that Johnston's system is summarizable to a stacking of just intervals above and below the fundamental pitch. This object do this. In first inlet are the ratio that will be stacking. In second inlet the number of stackings above and below. In third inlet the fundamnetal pitch in midicents. "

(let* (
(utonal-sobr (/ (denominator ratio) (numerator ratio)))
(sobr (arithm-ser 1 sobreposition 1))
(otonal (loop :for n :in (om^ ratio sobr) collect (f->mc (om* (mc->f fundamental) n))))
(utonal (loop :for n :in (om^ utonal-sobr sobr) collect (f->mc (om* (mc->f fundamental) n)))))
(x-append utonal fundamental otonal)))


;; =================================== Erv Wilson =========================================

;; ====================== MOS =============================

(defmethod! MOS ((ratio number)(grave number) (aguda number) (sobreposition number))
:initvals ' (4/3 6000 7200 11)     
:indoc ' ("Fundamental note of sobreposition" "Just Intonation interval" "High note" "Number of sobreposition")
:icon 005
:doc "This object creates a Moment of Symmetry without a octave equivalence. For make the octave equivalence use the object Octave-reduce, choose the range of the this MOS. 

MOS is a Theory of the composer Erv Wilson.                  

Wilson coined the term (MOS) to describe those scales resulting from a chain of intervals that produce two (and not three) different-sized intervals. 

These intervals are designated as the small (s) and large (L) intervals (FOR MAKE THIS USE THE OBJECT MOS-type). 

The relative number of s and L intervals in an MOS is co-prime, i.e., they share no common factors other than 1. Fractions are used to represent MOS scales: the numerator shows the size of the generator, and the denominator shows the number of notes in the scale. 

The numerator and denominator of fractions representing MOS are also co-prime. Wilson organizes these fractions hierarchically on the Scale Tree. MOS are not only scales in their own right but also provide a framework or template for constructing a family of Secondary MOS scales. (in NARUSHIMA - Microtonality and the Tuning Systems of Erv Wilson-Routledge)."

(let*  

    ((interval (om- (f->mc (om* (mc->f grave) ratio)) grave))

    (mos-create (loop for n in (arithm-ser 1 sobreposition 1) collect (+ grave (* interval n)))))

(x-append grave 


(let* 
(
(octave-reduction (* (+ 1 (truncate (om- aguda grave) 1200)) 1200))
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
  (octave-reduction2 (* (truncate (om- aguda grave) 1200) 1200)))


 (mapcar (lambda (x)
	  (loop :for new-val := x
		  :then (if (< new-val aguda)
			    (+ new-val octave-reduction2)
			    (- new-val octave-reduction2))
		:until (and (<= grave new-val) (>= aguda new-val))
		:finally (return new-val)))
	reducao-em-oitava)) aguda)))

;; ===================================================

(defmethod! MOS-verify ((notelist list))
:initvals ' ((6754 6308 7062 6616 6178))    
:indoc ' ("list of notes - object-MOS")
:icon 005
:doc "This object do the verification whether a list of notes is a MOS or not. If yes, informs the internal symmetry of your intervals, s for small intervals and L for Large interval. See Microtonality and the Tuning Systems of Erv Wilson-Routledge of NARUSHIMA."


(let* 
    ((action1 (loop :for cknloop :in (x->dx (sort-list (flat notelist)))

        :collect (if (om= cknloop (first (sort-list (remove-dup (x->dx (sort-list (flat notelist))) 'eq 1)))) "s" "L"))))

(if (om= (length (remove-dup (x->dx (sort-list (flat notelist))) 'eq 1)) 2) action1 "This is not a MOS")))

;; ===================================================

(defmethod! MOS-check ((interval number)(fund number) (aguda number) (sobreposition number) (number_of_interval number))
:initvals ' (4/3 6000 7200 11 2)     
:indoc ' ("fundamental note of sobreposition" "Just Intonation interval" "high note" "number of sobreposition" "interval number of the MOS")
:icon 005
:doc "This object creates a Moment of Symmetry without a octave equivalence. For make the octave equivalence use the object Octave-reduce, choose the range of the this MOS. 

MOS is a Theory of the composer Erv Wilson.                  

Wilson coined the term (MOS) to describe those scales resulting from a chain of intervals that produce two (and not three) different-sized intervals. 

These intervals are designated as the small (s) and large (L) intervals (FOR MAKE THIS USE THE OBJECT MOS-verification). 

The relative number of s and L intervals in an MOS is co-prime, i.e., they share no common factors other than 1. Fractions are used to represent MOS scales: the numerator shows the size of the generator, and the denominator shows the number of notes in the scale. 

The numerator and denominator of fractions representing MOS are also co-prime. Wilson organizes these fractions hierarchically on the Scale Tree. MOS are not only scales in their own right but also provide a framework or template for constructing a family of Secondary MOS scales. (in NARUSHIMA - Microtonality and the Tuning Systems of Erv Wilson-Routledge).


THIS OBJECT ARE NOT READY YET. This just work with the fund 6000 and the aguda-note 7200."


(let* ((action1 (loop :for x :in (arithm-ser 1 sobreposition 1) :collect 
                      (if (om= (length (remove-dup (x->dx (x-append fund (sort-list          
                          (mapcar #' (lambda (x) (+ (mod x (- aguda fund)) fund)) 
                            (loop :for n :in (arithm-ser 1 x 1) :collect (+ fund (* (om- (f->mc (om* (mc->f fund) interval)) fund) n))))

                      ) aguda)) 'eq 1)) number_of_interval) x 0)))
      )

(remove 0 action1)))

;; ====================== CPS =============================

(defmethod! cps ((notes list) (quantidade number))
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
  (combinations (cond
            ((<=  quantidade 0) notes) 
            (t (flat-once (cartesian-op notes (combx notes (1- quantidade)) 'x-append)))
                )
  )

  (action1 (loop :for cknloop :in combinations collect (sort-list cknloop)))

  (action2 (remove nil (loop :for cknloop2 :in action1 :collect 
            (if (om= (length (remove-duplicates cknloop2 :test #'equal)) quantidade) 
              (remove-duplicates cknloop2 :test #'equal) nil)))))

(remove-duplicates action2 :test #'equal)))

;; ===================================================

(defmethod! cps->ratio ((hexany list))
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

(defmethod! cps->identity ((cps list))
:initvals ' (1 3 5 7)      
:indoc ' ("Combination products set of a Hexany, Eikosany or others.")
:outdoc ' ("Identities")
:icon 006
:doc "This object converts CPS to identity/identities in the theory of Partch."

(loop :for cknloop :in cps :collect (reduce #'* cknloop)))

;; ===================================================

(defmethod! cps-chords ((vals list) (n number))
:initvals ' ((1 3 5 7) 4)      
:indoc ' ("Hexa" "chord-notes")
:outdoc ' ("chords")
:icon 006
:doc ""

(let* 

((action0 
(loop :for cknloop :in vals :collect (reduce #'* cknloop)))

(ckn-action (loop :for cknloop2 :in action0 :collect (/ cknloop2 (expt 2 (floor (log cknloop2 2))))))

(combinations (let ((n (1- n)))
    (combx ckn-action n)))



  (action1 (loop :for cknloop :in combinations :collect 

        (let* ((ordem (sort-list cknloop))
               (iguais (let ((L()))
                         (loop for x from 0 to (1- (length ordem)) do
                               (when (not (equal (nth (+ x 1) ordem) (nth x ordem)))
                                 (push (nth x ordem) L)))
                         (reverse L)))
          (final (if (om= (length iguais) n) iguais nil))) (remove nil final)))))


(remove-duplicates (remove nil action1) :test #'equal)))


;; ===================================================

(defmethod! CPS-connections ((lista list) (ratio number) (stacking number))
:initvals ' ((209/128 1843/1024 133/128 1067/1024 77/64 679/512) 3 4)    
:indoc ' ("list of ratio of a Hexany, Eikosany or others Wilson's CPS" "choose a ratio for the list in inlet1" "3 for triads; 4 for tetrads; etc")
:icon 006
:doc "This object show the connections of a CPS of Erv Wilson in a list of ratios and a number of stacking - example: Triads, Tetrads etcs..."

(print "not ready yet"))

;; ====================== CPS-HEXANY ========================

(defmethod! Hexany ((Hexany list))
:initvals ' ((5 7 13 17))    
:indoc ' ("List of just four harmonics.")
:icon 006
:doc "This object create a Hexany of the theory of Combination Product-Set of the Composer Erv Wilson."

(if (= 4 (length Hexany)) 

(let* 
(
 (combinations (cond
   ((<=  2 0) Hexany)
   (t (flat-once 
       (cartesian-op Hexany (combx Hexany (1- 2)) 'x-append)))))

 (action1 (loop :for cknloop :in combinations collect (sort-list cknloop)))

 (action2 (remove nil (loop :for cknloop2 :in action1 :collect 
          (if (om= (length (remove-duplicates cknloop2 :test #'equal)) 2) (remove-duplicates cknloop2 :test #'equal) nil)))))

(remove-duplicates action2 :test #'equal))





(print "This is not a Hexany, The CPS Hexany needs 4 numbers: for example 3 7 13 17")))


;; ===================================================

(defmethod! Hexany-triads ((harmonicos list))
:initvals ' (1 3 5 7)      
:indoc ' ("harmonicos")
:outdoc ' ("sub-harmonic" "harmonic")
:numouts 2 
:icon 006
:doc "The object hexany-triads construct the triads of the CPS Hexany. It follows the theory presented by Terumi Narushima in your book Microtonality and the Tuning Systems of Erv Wilson. In the outlet of the left, we have the sub-harmonics triads. In the outlet of the right, we have the harmonic triads."

(values 

(let* ((actionmain (loop for cknloopmain in (arithm-ser 1 (length harmonicos) 1) collect
      (let* 
((combinations (cond
   ((<=  2 0) (remove (choose harmonicos cknloopmain) harmonicos))
   (t (flat-once 
       (cartesian-op (remove (choose harmonicos cknloopmain) harmonicos) (combx (remove (choose harmonicos cknloopmain) harmonicos) (1- 2)) 'x-append)))))


  (action1 (loop for cknloop in combinations collect 

        (let* ((ordem (sort-list cknloop))
               (iguais (let ((L()))
                         (loop for x from 0 to (1- (length ordem)) do
                               (when (not (equal (nth (+ x 1) ordem) (nth x ordem)))
                                 (push (nth x ordem) L)))
                         (reverse L)))
          (final (if (om= (length iguais) 2) iguais nil))) (remove nil final)))))


(remove-duplicates (remove nil action1) :test #'equal))))

(actionmain2 (loop for ckn-loop in actionmain collect (loop for ckn-loop2 in ckn-loop collect (reduce #'* ckn-loop2)))))

(loop :for cknloop2 :in actionmain2 :collect (loop :for cknloop3 in cknloop2 collect (/ cknloop3 (expt 2 (floor (log cknloop3 2)))))))

; ====

(let* ((ratios (loop for cknloop4 in (arithm-ser 1 (length harmonicos) 1) collect 
       (let* ((choose (nth (om- cknloop4 1) harmonicos)))
         (om* choose (remove choose harmonicos))))))

(loop for cknloop2 in ratios collect (loop for cknloop3 in cknloop2 collect (/ cknloop3 (expt 2 (floor (log cknloop3 2)))))))))
     

;; ===================================================

(defmethod! Hexany-connections ((harmonico list) (hexany list))
:initvals ' ((3 13) ((3 5) (3 13) (5 13) (3 21) (5 21) (13 21)))    
:indoc ' ("list of two harmonics" "list of just four harmonics")
:icon 006
:doc "This object shown the Hexany connections of the theory of Combination Product-Set of the Composer Erv Wilson."

(let*
  ((action1 (loop :for cknloop :in hexany
   collect (let*  ((result1 (first harmonico)) (result2 (first cknloop)) (result3 (second harmonico)) (result4 (second cknloop)))
       
             (remove nil 
                     (remove-duplicates (list
                             (if (or  (om= result1 result2) (om= result1 result3)) cknloop nil) 
                             (if (or (om= result3 result2) (om= result3 result4)) cknloop nil)) :test #'equal))))))
        
  (flat (remove nil action1) 1)))

;; ====================== CPS-EIKOSANY ====================

(defmethod! eikosany ((6-notes list))
:initvals ' ((1 3 5 7 9 11))      
:indoc ' ("six harmonic notes | if you don't put 6 notes the result will not be an eikosany.")
:outdoc ' ("harmonic")
:icon 006
:doc "This object will construct a Combination-Product-Set (CPS) with 6 numbers or harmonics. This 6 harmonics will form Twenty ratios."

(cps-eikosany-fun 6-notes))

; ====== Functions 

(defun cps-eikosany-fun (6-notes)

(let* 
(
 (combinations (cond
   ((<=  3 0) 6-notes)
   (t (flat-once 
       (cartesian-op 6-notes (combx 6-notes (1- 3)) 'x-append)))))

 (action1 (loop :for cknloop :in combinations collect (sort-list cknloop)))

 (action2 (remove nil (loop :for cknloop2 :in action1 :collect 
          (if (om= (length (remove-duplicates cknloop2 :test #'equal)) 3) (remove-duplicates cknloop2 :test #'equal) nil)))))

(remove-duplicates action2 :test #'equal)))

;; ===================================================

(defmethod! eikosany-triads ((6-notes list))
:initvals ' ((1 3 5 7 9 11))      
:indoc ' ("three harmonic notes | if you don't put 3 notes the result will not be an eikosany triads.")
:outdoc ' ("sub-harmonic" "harmonic")
:numouts 2
:icon 006
:doc "The object eikosany-triads construct the triads of the CPS eikosany. It follows the theory presented by Terumi Narushima in your book Microtonality and the Tuning Systems of Erv Wilson. In the outlet of the left, we have the sub-harmonics triads. In the outlet of the right, we have the harmonic triads."

(values 

;; subharmonic

(let* ((action1 (cps-fun 6-notes 3))

(action2 (loop for cknloop5 in action1 collect (rt-octave-fun
              (let* ((action2-1 (set-difference 6-notes cknloop5))
                     (action2-2 (cps->ratio-fun (cps-fun cknloop5 2))))
                (loop for cknloop6 in action2-1 collect (om* action2-2 cknloop6))) 2))))
(flat action2 1))


;;harmonic

(let* ((action1 (cps-fun 6-notes 3))

(action2 (loop for cknloop1 in action1 collect (rt-octave-fun
          (let* ((action2-1 (cps->ratio-fun (cps-fun (set-difference 6-notes cknloop1) 2))))
            (loop for cknloop1-1 in action2-1 collect (om* cknloop1 cknloop1-1))) 2))))

(flat action2 1))))

;; ===================================================

(defmethod! eikosany-tetrads ((6-notes list))
:initvals ' ((1 3 5 7 9 11))      
:indoc ' ("three harmonic notes | if you don't put 3 notes the result will not be an eikosany triads.")
:outdoc ' ("sub-harmonic" "harmonic")
:numouts 2
:icon 006
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
          (om* cknloop action2-2)) 2)))))


;; ===================================================

(defmethod! eikosany-connections ((vertice list) (eikosany list))
:initvals ' ((1 3 9) ((1 3 5) (1 3 7) (1 5 7) (3 5 7) (1 3 9) (1 5 9) (3 5 9) (1 7 9) (3 7 9) (5 7 9) (1 3 11) (1 5 11) (3 5 11) (1 7 11) (3 7 11) (5 7 11) (1 9 11) (3 9 11) (5 9 11) (7 9 11)))    
:indoc ' ("list of tree harmonics" "list of the cps-eikosany")
:icon 006
:doc "This object shown the Eikosany connections of the theory of Combination Product-Set of the Composer Erv Wilson."

(defun same-elem-p (lst1 lst2)
  (cond ((not (null lst1))
         (cond ((member (car lst1) lst2)
                (same-elem-p (cdr lst1) lst2))
               (t nil)))
        (t t)))

(let* ((task1 (loop for cknloop in eikosany collect (if
          
      (om<= 2 (reduce #'+ 
                      (x-append
              (if (same-elem-p (list (first vertice)) cknloop) 1 nil)
              (if (same-elem-p (list (second vertice)) cknloop) 1 nil)
              (if (same-elem-p (list (third vertice)) cknloop) 1 nil))))
           cknloop nil))))
(remove nil task1)))

;; ;; =================================== Temperament =======================================

(defmethod! mk-temperament ((fund number)(ratio number) (division number))
:initvals ' (6000 2 24)     
:indoc ' ("inicial-note" "interval: 2 for octave, 3/2 for a fifth division, etc" "divison for the interval, for example: 24 divison of the octave")
:icon 004
:doc "create a temperament"

(let ((Question (print "Temperamented music, really?")))

(x-append fund (f->mc (om* (mc->f fund) (om^ (expt ratio (om/ 1 division)) (arithm-ser 1 division 1)))))))


;; ;; =================================== Math =============================================

(defmethod! Prime-decomposition ((harmonic number))
:initvals ' (9)     
:indoc ' ("number or list of the harmonics/parcials.")
:outdoc ' ("Prime-decomposition" "Prime-decomposition without the 2 that represents the octave interval")
:icon 004
:doc "It does the decomposition of prime numbers. This can be useful with identities by Harry Partch, mainly, when we use the conception of identity by Ben Johnston: 'Each prime number used in deriving a harmonic scale contributes to a characteristic psychoacoustical meaning (JOHNSTON, 2006, p. 27).' Lisp code of https://sholtz9421.wordpress.com/2012/10/08/prime-number-factorization-in-lisp/."
:numouts 2 

(defun factor (n)
  "Return a list of factors of N."
  (when (> n 1)
    (loop with max-d = (isqrt n)
	  for d = 2 then (if (evenp d) (+ d 1) (+ d 2)) do
	  (cond ((> d max-d) (return (list n))) ; n is prime
		((zerop (rem n d)) (return (cons d (factor (truncate n d)))))))))

(values 
 ((factor harmonic)) 
 (let* ((action1 (factor harmonic))) (remove 2 action1))))

(defmethod! Prime-decomposition ((harmonic list))
:initvals ' ((9 18 172))     
:indoc ' ("Number or numbers list.")
:outdoc ' ("Prime-decomposition" "Prime-decomposition without the number 2. It represents the octave interval")
:icon 004
:doc "It does the decomposition of prime numbers. This can be useful with identities by Harry Partch, mainly, when we use the conception of identity by Ben Johnston: 'Each prime number used in deriving a harmonic scale contributes to a characteristic psychoacoustical meaning (JOHNSTON, 2006, p. 27).' Lisp code of https://sholtz9421.wordpress.com/2012/10/08/prime-number-factorization-in-lisp/."
:numouts 2 

(defun factor (n)
  "Return a list of factors of N."
  (when (> n 1)
    (loop with max-d = (isqrt n)
	  for d = 2 then (if (evenp d) (+ d 1) (+ d 2)) do
	  (cond ((> d max-d) (return (list n))) ; n is prime
		((zerop (rem n d)) (return (cons d (factor (truncate n d)))))))))


(values 
(loop :for x :in harmonic :collect (factor x))
(loop :for x :in harmonic :collect (let* ((action1 (factor x))) (remove 2 action1)))))


;; ===================================================


;; ;; =================================== Others =============================================

(defmethod! send-max ((maxlist list))
:initvals ' (6000 2 24)     
:indoc ' ("list")
:icon 007
:doc "Send for MAX/MSP. This work with a list not list of lists. See the patch CKN-OSCreceive in https://github.com/charlesneimog/UFJF-PPGACL/tree/master/MAX-MSP%20Patches"

(osc-send (x-append "om/max" maxlist) "127.0.0.1" 7839))

;; ===================================================

(defmethod! midicents->midi ((maxlist list))
:initvals ' (6000)     
:indoc ' ("list of midicents")
:icon 007
:doc "Convert midicents in MIDI floats for manipulation in MAX/MSP."

(loop for y in maxlist collect (* 0.01 y)))

;; ===================================================

(defmethod! gizmo ((note list) (fund number))
:initvals ' ((6386) (6000))    
:indoc ' ("list of midicents" "fund of the gizmo")
:icon 007
:doc "Convert midicents for the max object gizmo~."

(om* 0.01 (om- note fund)))

;; ===================================================

;; By Jordana Dias Paes Possani de Sousa and Charles K. Neimog | copyright © 2020
(defmethod! apex-vibro ((freq number))
:initvals ' (440)
:indoc ' ("valor da frequência") 
:icon 008
:doc "It gives the distance between the apice of the coclea and the vibration point of a determinate frequence."

(om/ (log (/ freq 165) 10) 0.06))

; =================================== Functions of Others OM libraries ================


; I will put some functions of others Libraries here for do the use more simple for people that don't know how OpenMusic work.

; ===========================================================================

(defun list-of-listp (thing) (and (listp thing) (every #'listp thing)))
(deftype list-of-lists () '(satisfies list-of-listp))

;; Thanks for Reddit user DREWC for code of list-of-listp and list-of-lists.

; ================================= ratio->cents by Mauricio Rodriguez =======

(defun ratio->cents (ratio)
  (* (/ 1200 (log 2)) (log ratio)))

;; DISSONANCE SENSORY => Mauricio Rodriguez after William A. Sethares

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


;; https://stackoverflow.com/questions/25903972/pascal-triangle-in-lisp/25904053


; =================================== COMBINE BY MIKHAIL MALT (IRCAM 1993-1996) ================


(defun cartesian-op (l1 l2 fun) 

  (mapcar #'(lambda (x) (mapcar #'(lambda (y) (funcall fun x y)) (list! l2))) (list! l1))
)

(defun combx (vals n)
  (cond
   ((<=  n 0) vals)
   (t (flat-once 
       (cartesian-op vals (combx vals (1- n)) 'x-append))))
)

(defun removeIt (a lis)
  (if (null lis) 0
      (if (= a (car lis))
          (delete (car lis))
          (removeIt (cdr lis))))
)

; ========================================== OM#-PLAY =======================

(defmethod! play-om# ((ckn VOICE) &optional (number-2 1))
:initvals ' ((nil))       
:indoc ' ("A player for OM#")
:outdoc ' ("PLAY")
:icon 0000
:doc "It is a player for OM# in Windows."

(defun normalize-chord-seq (chrdseq)
  (let* ((xdx (x->dx (lonset chrdseq)))
         (filt-durs1 (mapcar 'list-min (ldur chrdseq)))
         (lst-durs (mapcar 'list xdx filt-durs1))
         (filt-durs2 (mapcar 'list-min lst-durs))
         (newdurs (loop 
                   for pt in (lmidic chrdseq)
                   for drs in filt-durs2
                   collect (repeat-n drs (length pt)))))
    (make-instance 'chord-seq 
                   :lmidic (lmidic chrdseq)
                   :lonset (lonset chrdseq)
                   :ldur newdurs)))

(defun choose-fun (notelist chord-n) (nth (om- chord-n 1) notelist))

(defun numlist-to-string (lst) (when lst (concatenate 'string (write-to-string (car lst)) (numlist-to-string (cdr lst)))))

(let* (

(true-durations 

 (let* ((newchrdseq (if (typep ckn 'note) 
                           (Objfromobjs (Objfromobjs ckn (make-instance 'chord)) (make-instance 'chord-seq))
                           (Objfromobjs ckn (make-instance 'chord-seq))))

         (newcs (normalize-chord-seq newchrdseq))
         (onsets (Lonset newcs))
         (dur (Ldur newcs))
         (newonsets (if (= 2 (length onsets)) (x->dx  onsets) (butlast (x->dx onsets))))
         (newdurs (mapcar 'first dur))
         (resultat1 
          (x-append 
          (flat
           (list (mapcar #'(lambda (x y) (if (= 0 (- x y)) x 
                                             (list x (- x y))))
                         newdurs newonsets)
                 (last newdurs)))
          (last-elem newdurs)))
         (resultat2 (butlast
                     (if (= 0 (first onsets)) resultat1 (cons (* -1 (first onsets)) resultat1)))))
    
   (let ((result (remove nil (mapcar #'(lambda (x) (if (not (or (= x 1) (= x -1))) x ))
          resultat2))))
         (if (= 2 (length onsets)) (list (car result) (second result)) result))
   ))


(ckn-action1  (loop :for ckn-plus :in true-durations :collect (if (plusp ckn-plus) 0 1)))

(ckn-action2 (loop :for cknloop :in ckn-action1 :collect (if (= 0 cknloop) (setq number-2 (+ number-2 1)) nil)))

(ckn-action3 

      (let* (
        (ckn-action3-1 
          (if (equal nil (first ckn-action2)) 0 (first ckn-action2))))
        (if (equal nil (first ckn-action2)) (om+ (om- ckn-action2 ckn-action3-1) -1) (om+ (om- ckn-action2 ckn-action3-1) 1))     
        
      ))

(ckn-action4 
(loop :for cknloop-1 :in ckn-action3 :for cknloop-2 :in (dx->x 0 (loop :for y :in true-durations :collect (abs y))) :for cknloop-3 :in true-durations collect          
        (if (plusp cknloop-3) 
            (x-append 
                     (if (plusp cknloop-3) cknloop-2 nil) "," 
                     (x-append  
                      (choose-fun (get-slot-val (make-value-from-model 'voice ckn nil) "LMIDIC") cknloop-1) 
                      (choose-fun (get-slot-val (make-value-from-model 'voice ckn nil) "lvel") cknloop-1)
                      (if (plusp cknloop-3) cknloop-3 nil) 
                      (choose-fun (get-slot-val (make-value-from-model 'voice CKN nil) "lchan") cknloop-1) ";")) nil))))
                      
(save-as-text ckn-action4 (let* (
 (LISP-FUNCTION (numlist-to-string (x-append 'play (om-random 0 100) '.txt))))


(first (list LISP-FUNCTION (osc-send (list "/note" LISP-FUNCTION) "127.0.0.1" 3002)))))))

; ===========================================================================


(print 
 "
                                              OM-JI
      by Charles K. Neimog | charlesneimog.com  
   Universidade Federal de Juiz de Fora (2019-2020)
"
) 