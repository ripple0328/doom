(setq user-full-name    "Zhang Qingbo"
      user-mail-address "ripple0328@gmail.com"
      auth-sources '("~/.authinfo.gpg")
      auth-source-cache-expiry nil
      starttls-use-gnutls t
      display-time-mode 1   ; Enable time in the mode-line
      tool-bar-mode -1
      mac-right-option-modifier 'meta
      global-subword-mode 1 ; Iterate through CamelCase words
      delete-by-moving-to-trash t                      ; Delete files to trash
      window-combination-resize t                      ; take new window space from all other windows (not just current)
      x-stretch-cursor t
      avy-all-windows t
      evil-escape-key-sequence "fd"
      gnutls-verify-error nil
      major-mode 'org-mode
)

(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
(add-hook! '+doom-dashboard-functions :append
(setq-hook! '+doom-dashboard-mode-hook evil-normal-state-cursor (list nil))
(setq fancy-splash-image (concat doom-user-dir "vagabond.png")))

(add-to-list 'default-frame-alist '(height . 50))
(add-to-list 'default-frame-alist '(width . 100))
(setq doom-theme 'modus-vivendi
  doom-font (font-spec :family "Iosevka Term SS04" :size 16 :weight 'light)
  doom-variable-pitch-font (font-spec :family "Iosevka Term SS04" :size 16)
  doom-big-font (font-spec :family "Iosevka Term SS04" :size 36)

)
(setq-default line-spacing 0.24)
(setq-default mode-line-format
                (cons (propertize "\u200b" 'display '((raise -0.35) (height 1.4))) mode-line-format))

(modify-all-frames-parameters
'((right-divider-width . 10)
 (internal-border-width . 10)))
(dolist (face '(window-divider
               window-divider-first-pixel
                window-divider-last-pixel))
(face-spec-reset-face face)
(set-face-foreground face (face-attribute 'default :background)))
(set-face-background 'fringe (face-attribute 'default :background))
(good-scroll-mode 1)

(use-package! theme-magic
  :commands theme-magic-from-emacs
  :config
  (defadvice! theme-magic--auto-extract-16-doom-colors ()
    :override #'theme-magic--auto-extract-16-colors
    (list
     (face-attribute 'default :background)
     (doom-color 'error)
     (doom-color 'success)
     (doom-color 'type)
     (doom-color 'keywords)
     (doom-color 'constants)
     (doom-color 'functions)
     (face-attribute 'default :foreground)
     (face-attribute 'shadow :foreground)
     (doom-blend 'base8 'error 0.1)
     (doom-blend 'base8 'success 0.1)
     (doom-blend 'base8 'type 0.1)
     (doom-blend 'base8 'keywords 0.1)
     (doom-blend 'base8 'constants 0.1)
     (doom-blend 'base8 'functions 0.1)
     (face-attribute 'default :foreground))))

(setq scroll-margin 2
      auto-save-default t
      display-line-numbers-type nil
      delete-by-moving-to-trash t
      truncate-string-ellipsis "…"
      browse-url-browser-function 'xwidget-webkit-browse-url)
(global-subword-mode 1)

(after! mu4e
  (setq mu4e-index-cleanup nil
        mu4e-index-lazy-check t
        mu4e-update-internal 300
        smtpmail-starttls-credentials '(("smtp.gmail.com" 587 nil nil))
        message-send-mail-function 'smtpmail-send-it
        mu4e-maildir-shortcuts '((
                                :maildir "/inbox" :key ?i))
        smtpmail-auth-credentials '(("smtp.gmail.com" 587 "ripple0328@gmail.com" nil))
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
  )
)

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
  (use-package! org-fancy-priorities
  :hook (org-mode . org-fancy-priorities-mode)
  :config
  (setq org-fancy-priorities-list '("⚡" "⬆" "⬇" "☕") ))
)

(setq treemacs-follow-mode t)

(setq  wakatime-cli-path "/usr/local/bin/wakatime"
  wakatime-api-key "4a6bb692-ecb1-4a87-b177-46c29f24a451"
 )

(setq
  easy-hugo-basedir "~/Shared/Personal/blog/"
  easy-hugo-default-ext ".org"
  easy-hugo-org-header t
  easy-hugo-previewtime "300"
  easy-hugo-server-flags "-D"
  easy-hugo-url "https://blog.qingbo.tech"
  )

(setq
 jiralib-url "https://rba.atlassian.net"
)

(map! :leader
      :desc "other window"
      "w o" #'other-window)
