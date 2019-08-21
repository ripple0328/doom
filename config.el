;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here
(setq
  doom-font (font-spec :family "mononoki" :size 16)
  doom-big-font (font-spec :family "mononoki" :size 30)
  avy-all-windows t
  evil-escape-key-sequence "fd"
  gnutls-verify-error nil
  wakatime-cli-path "/usr/local/bin/wakatime"
)

(def-package! org-fancy-priorities
  :hook (org-mode . org-fancy-priorities-mode)
  :config
  (setq org-fancy-priorities-list '("⚡" "⬆" "⬇" "☕") ))

(after! org
  (map! :map org-mode-map
        :n "M-j" #'org-metadown
        :n "M-k" #'org-metaup)
  (setq org-directory "Shared/Notes/"
        org-agenda-files (directory-files-recursively "~/Shared/Notes/" "\.org$")
        org-log-done 'time
        org-tags-column -80
        org-ellipsis " ⤵"
        org-bullets-bullet-list '("·:")
        org-todo-keywords '((sequence "TODO(t)" "INPROGRESS(i)" "WAITING(w)" "|" "DONE(d)" "CANCELLED(c)"))
        org-todo-keyword-faces
        '(
           ("TODO" :foreground "#7c7c75" :weight normal :underline t)
           ("WAITING" :foreground "#9f7efe" :weight normal :underline t)
           ("INPROGRESS" :foreground "#0098dd" :weight normal :underline t)
           ("DONE" :foreground "#50a14f" :weight normal :underline t)
           ("CANCELLED" :foreground "#ff6480" :weight normal :underline t)
           )
  )
  (set-face-attribute 'org-link nil
                      :weight 'normal
                      :background nil)
  (set-face-attribute 'org-code nil
                      :foreground "#a9a1e1"
                      :background nil)
  (set-face-attribute 'org-date nil
                      :foreground "#5B6268"
                      :background nil)
  (set-face-attribute 'org-level-1 nil
                      :foreground "steelblue2"
                      :background nil
                      :height 1.2
                      :weight 'normal)
  (set-face-attribute 'org-level-2 nil
                      :foreground "slategray2"
                      :background nil
                      :height 1.0
                      :weight 'normal)
  (set-face-attribute 'org-level-3 nil
                      :foreground "SkyBlue2"
                      :background nil
                      :height 1.0
                      :weight 'normal)
  (set-face-attribute 'org-level-4 nil
                      :foreground "DodgerBlue2"
                      :background nil
                      :height 1.0
                      :weight 'normal)
  (set-face-attribute 'org-level-5 nil
                      :weight 'normal)
  (set-face-attribute 'org-level-6 nil
                      :weight 'normal)
  (set-face-attribute 'org-document-title nil
                      :foreground "SlateGray1"
                      :background nil
                      :height 1.75
                      :weight 'bold)
)
