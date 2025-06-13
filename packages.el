;; -*- no-byte-compile: t; -*-
;;; ~/.doom.d/packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:fetcher github :repo "username/repo"))
;; (package! builtin-package :disable t)

;;; ---------------------------------------------------------------------------
;;;  UI / Presentation helpers
;;; ---------------------------------------------------------------------------
(package! presentation        ; Minimalist slides inside Emacs
  )
(package! good-scroll         ; Pixel-perfect, smooth scrolling
  )

;;; ---------------------------------------------------------------------------
;;;  Development workflow tools
;;; ---------------------------------------------------------------------------
(package! command-log-mode    ; Show command/key history (great for demos)
  )
(package! jest-test-mode      ; Run Jest tests from inside Emacs
  )
(package! just-mode           ; Major-mode for Justfile build scripts
  )

;;; ---------------------------------------------------------------------------
;;;  File-manager replacements
;;; ---------------------------------------------------------------------------
(package! dirvish             ; Modern dired UI with extra niceties
  )
(package! sxhkdrc-mode        ; Syntax highlighting for sxhkd hotkey config
  )
