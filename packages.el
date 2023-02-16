;; -*- no-byte-compile: t; -*-
;;; ~/.doom.d/packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:fetcher github :repo "username/repo"))
;; (package! builtin-package :disable t)
(package! easy-hugo)
(package! wakatime-mode)
(package! presentation)
(package! org-jira)
(package! org-modern)
(package! command-log-mode)
(package! just-mode)
(package! good-scroll)
(package! sxhkdrc-mode)
(package! jest-test-mode)
(package! transient
      :pin "c2bdf7e12c530eb85476d3aef317eb2941ab9440"
      :recipe (:host github :repo "magit/transient"))

(package! with-editor
          :pin "bbc60f68ac190f02da8a100b6fb67cf1c27c53ab"
          :recipe (:host github :repo "magit/with-editor"))
