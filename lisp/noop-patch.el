;;; lisp/noop-patch.el -*- lexical-binding: t; -*-

(unless (fboundp 'org-restart-font-lock)
  (defun org-restart-font-lock (&rest _)
    "[noop] stub to fix Emacs 30+ crash in Doom."
    (message "[patch] Ignored missing org-restart-font-lock.")))
