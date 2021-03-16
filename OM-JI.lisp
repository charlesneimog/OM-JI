;;            OM-JI
;;
;;      by Charles K. Neimog 
;; collab with reddit users 
;; Universidade Federal de Juiz de Fora (2019-2020)
           
(defpackage :om-ji
  (:use "OM" "COMMON-LISP" "CL-USER"))

(in-package :om)


(defun lib-src-file (file)
  (merge-pathnames file (om-make-pathname :directory *load-pathname*)))

(mapc #'(lambda (file) (compile&load (lib-src-file file) t t))
      '("sources/om/om-ji"        
        ))


(om::fill-library '(


("Just-intonation Utilities" nil nil (rt->mc  range-reduce  filter-ac-inst  modulation-notes  modulation-notes-fund rt-octave) nil)

("Harry Partch" nil  nil ( Diamond  Diamond-Identity  chord-inverse) nil)   

("Erv Wilson"
          (("MOS" nil nil ( MOS  MOS-verify  MOS-check  MOS-complementary) nil)
           ("CPS-Hexany" nil nil ( Hexany  Hexany-triads  hexany-connections) nil)
           ("CPS-Eikosany" nil nil ( eikosany  eikosany-triads  eikosany-tetrads  eikosany-connections) nil))
      	    Nil ( cps->identity  cps->ratio) Nil)
       
("Ben Johnston" nil nil ( interval-sob  arith-mean  arith-mean-sob  johnston-sob) nil)

                    

       ("Others"
          ( ("Utilities") nil nil (choose))
            ("Math" nil nil ( prime-decomposition) nil)
            ("Max-Integration" nil nil ( midicents->midi  send-max  gizmo) nil)
            ("Temperament" nil nil ( mk-temperament) nil
            
      	    Nil Nil Nil)))

(print 
 "
                                              OM-JI

      by Charles K. Neimog | charlesneimog.com  
            collab with reddit users 
      Universidade Federal de Juiz de Fora (2019-2020)
"
)
                    

