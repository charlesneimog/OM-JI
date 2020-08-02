;;            OM-JI
;;
;;      by Charles K. Neimog 
;; collab with reddit users 
;; Universidade Federal de Juiz de Fora (2019-2020)
           
(in-package :om)

(compile&load (om-relative-path '("sources") "OM-JI"))

(om::fill-library '(


("Just-intonation" nil nil (rt->mc range-reduce octave-reduce filter-ac-inst modulation-notes modulation-notes-fund choose rt-octave) nil)

("Harry Partch" nil  nil (Diamond Diamond-Identity otonal-inverse utonal-inverse) nil)   

("Erv Wilson"
          (("MOS" nil nil (MOS MOS-verify MOS-check) nil)
           ("CPS-Hexany" nil nil (Hexany Hexany-triads hexany-connections) nil)
           ("CPS-Eikosany" nil nil (eikosany eikosany-triads eikosany-tetrads eikosany-connections) nil))
      	    Nil (cps->identity cps->ratio) Nil)
       
("Ben Johnston" nil nil (interval-sob arith-mean arith-mean-sob johnston-sob) nil)

                    

                    ("Others"
          (("Math" nil nil (prime-decomposition) nil)
           ("Max-Integration" nil nil (midicents->midi send-max gizmo) nil)
           ("Temperament" nil nil (mk-temperament) nil))
      	    Nil Nil Nil)

		    )) 

(print 
 "
                                              OM-JI

      by Charles K. Neimog | charlesneimog.com  
            collab with reddit users 
      Universidade Federal de Juiz de Fora (2019-2020)
"
)               
                    

