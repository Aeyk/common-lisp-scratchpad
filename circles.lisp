(ql:quickload '(:serapeum :closer-mop :uiop :rutils :named-readtables :cl-ppcre :sdl2))
(defpackage :common-lisp-user
	(:use :cl :rutils)
	(:shadowing-import-from :closer-mop :defmethod))
(in-package :common-lisp-user)
(named-readtables:in-readtable rutils-readtable)
(toggle-print-hash-table)

(defparameter *window-width* 200)
(defparameter *window-height* 200)

(defmacro with-window-surface ((window surface) &body body)
  `(sdl2:with-init (:video)
     (sdl2:with-window (,window
                        :title "SDL2 Tutorial 03"
                        :w *window-width*
                        :h *window-height*
                        :flags '(:shown))
       (let ((,surface (sdl2:get-window-surface ,window)))
         ,@body))))

(defmacro with-new-render ((window render) &body body)
	`(let ((,render (sdl2:create-renderer ,window :index -1 :flags '(:accelerated))))
		 ,@body))

;; (sdl2:with-init (:video)
;; 	(sdl2:with-window (window :title "0o0 CIRCLES o0o"
;; 														:w *window-width*
;; 														:h *window-height*
;; 														:flags '(:show))
;; 		(let ((screen-surface (sdl2:get-window-surface window)))
;;       (sdl2:fill-rect screen-surface
;;                       nil
;;                       (sdl2:map-rgb (sdl2:surface-format screen-surface) 255 255 255))
;;       (sdl2:update-window window)
;;       (sdl2:delay 2000))))

(funcall (lambda ()
					 (with-window-surface
							 (window screen-surface)
						 (with-render
								 (window renderer)
								 (sdl2:with-event-loop (:method :poll)
									 (:quit () t)
									 (:idle ()
													(sdl2:set-render-draw-color renderer #xFF #xFF #xFF #xFF)
													(sdl2:render-clear renderer)
													(sdl2:render-fill-rect renderer (sdl2:make-rect 0 0 *window-width* *window-height*))
													(sdl2:render-present renderer)
													(sdl2:delay 33)))))))
