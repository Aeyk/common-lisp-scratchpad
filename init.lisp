(load "/etc/default/quicklisp")
(ql:quickload :caveman2)

(caveman2:make-project #P"./backend/"
                       :author "Malik Kennedy")
