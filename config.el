;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

(add-to-list 'default-frame-alist '(height . 50))
(add-to-list 'default-frame-alist '(width . 100))
(setq user-full-name    "Zhang Qingbo"
      user-mail-address "ripple0328@gmail.com"
      auth-sources '("~/.authinfo.gpg")
      auth-source-cache-expiry nil
      message-send-mail-function 'smtpmail-send-it
      starttls-use-gnutls t
      display-time-mode 1   ; Enable time in the mode-line
      tool-bar-mode -1
      mac-right-option-modifier 'meta
      global-subword-mode 1 ; Iterate through CamelCase words
      smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))
      mu4e-maildir-shortcuts '((
                                :maildir "/inbox" :key ?i))
      smtpmail-auth-credentials
      '(("smtp.gmail.com" 587 "ripple0328@gmail.com" nil))
      smtpmail-default-smtp-server "smtp.gmail.com"
      smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587)
(setq-default
 delete-by-moving-to-trash t                      ; Delete files to trash
 window-combination-resize t                      ; take new window space from all other windows (not just current)
 x-stretch-cursor t
 major-mode 'org-mode
 )
(set-email-account! "Gmail"
  '((mu4e-sent-folder       . "/Gmail/Sent Mail")
    (mu4e-drafts-folder     . "/Gmail/Drafts")
    (mu4e-trash-folder      . "/Gmail/Trash")
    (mu4e-refile-folder     . "/Gmail/All Mail")
    (smtpmail-smtp-user     . "ripple0328@gmail.com")
    (mu4e-get-mail-command  . "mbsync --all")
    (user-mail-address      . "ripple0328@gmail.com")    ;; only needed for mu < 1.4
    (mu4e-compose-signature . "---\n Qingbo Zhang"))
  t)
(setq
  doom-theme 'modus-vivendi
  doom-font (font-spec :family "Iosevka Term SS04" :size 16 :weight 'light)
  doom-variable-pitch-font (font-spec :family "Iosevka Term SS04" :size 16)
  doom-big-font (font-spec :family "Iosevka Term SS04" :size 36)
  avy-all-windows t
  evil-escape-key-sequence "fd"
  gnutls-verify-error nil
  wakatime-cli-path "/usr/local/bin/wakatime"
  wakatime-api-key "4a6bb692-ecb1-4a87-b177-46c29f24a451"
  treemacs-follow-mode t
  easy-hugo-basedir "~/Shared/Personal/blog/"
  easy-hugo-default-ext ".org"
  easy-hugo-org-header t
  easy-hugo-previewtime "300"
  easy-hugo-server-flags "-D"
  easy-hugo-url "https://blog.qingbo.tech"
  jiralib-url "https://rba.atlassian.net"
)

(use-package! org-fancy-priorities
  :hook (org-mode . org-fancy-priorities-mode)
  :config
  (setq org-fancy-priorities-list '("⚡" "⬆" "⬇" "☕") ))

(after! org
  (map! :map org-mode-map
        :n "M-j" #'org-metadown
        :n "M-k" #'org-metaup)
  (setq org-directory "~/Documents/notes/"
        org-agenda-files (directory-files-recursively "~/Documents/notes/" "\\.org$")
        org-roam-directory "~/Documents/org-roam/"
        org-log-done 'time
        org-agenda-start-with-log-mode t
        org-log-into-drawer t
        org-tags-column -80
        org-ellipsis "⚡⚡⚡"
        org-superstar-headline-bullets-list '("⁖" "◉" "○" "✸" "✿")
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
 )
(use-package org-journal
  :defer t
  :config
  (setq org-journal-dir "~/Documents/notes/journal/"
        org-journal-file-type 'monthly
        org-journal-file-format "%Y-%m-%d.org"
        org-journal-date-format "%Y-%m-%d [%a]")
  )

(map! :leader
      :desc "other window"
      "w o" #'other-window)

