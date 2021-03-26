;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

(add-to-list 'default-frame-alist '(height . 50))
(add-to-list 'default-frame-alist '(width . 100))
(setq user-full-name    "Zhang Qingbo"
      user-mail-address "ripple0328@gmail.com"
      message-send-mail-function 'smtpmail-send-it
      starttls-use-gnutls t
      smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))
      mu4e-maildir-shortcuts '((
                                :maildir "/inbox" :key ?i))
      smtpmail-auth-credentials
      '(("smtp.gmail.com" 587 "ripple0328@gmail.com" nil))
      smtpmail-default-smtp-server "smtp.gmail.com"
      smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587)
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
  doom-theme 'doom-dracula
  doom-font (font-spec :family "mononoki" :size 16)
  doom-variable-pitch-font (font-spec :family "mononoki" :size 16)
  doom-big-font (font-spec :family "mononoki" :size 30)
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
)

(use-package! org-fancy-priorities
  :hook (org-mode . org-fancy-priorities-mode)
  :config
  (setq org-fancy-priorities-list '("⚡" "⬆" "⬇" "☕") ))

(after! org
  (map! :map org-mode-map
        :n "M-j" #'org-metadown
        :n "M-k" #'org-metaup)
  (setq org-directory "~/Shared/Notes/"
        org-agenda-files (directory-files-recursively "~/Shared/Notes/" "\.org$")
        org-roam-directory "~/Shared/org-roam/"
        org-log-done 'time
        org-tags-column -80
        org-ellipsis "⚡⚡⚡"
        org-bullets-bullet-list (quote ("◉" "◆" "✚" "☀" "○"))
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
