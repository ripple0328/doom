(setq user-full-name    "Zhang Qingbo"
      user-mail-address "ripple0328@gmail.com"
      auth-sources '("~/.authinfo.gpg")
      major-mode 'org-mode
)

(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
(add-hook! '+doom-dashboard-functions :append
(setq-hook! '+doom-dashboard-mode-hook evil-normal-state-cursor (list nil))
(setq fancy-splash-image (concat doom-user-dir "doomEmacsTokyoNight.svg")))
(setq initial-frame-alist '((top . 1) (left . 120) (width . 143) (height . 55)))

(if (eq system-type 'darwin)
(setq doom-theme 'modus-vivendi
  doom-font (font-spec :family "Iosevka Term SS04" :size 16 :weight 'light)
  doom-variable-pitch-font (font-spec :family "Iosevka Term SS04" :size 16)
  doom-big-font (font-spec :family "Iosevka Term SS04" :size 36))
(setq doom-theme 'modus-vivendi
  doom-font (font-spec :family "Iosevka Term SS04" :size 32 :weight 'light)
  doom-variable-pitch-font (font-spec :family "Iosevka Term SS04" :size 32)
  doom-big-font (font-spec :family "Iosevka Term SS04" :size 72))
)
(setq-default line-spacing 0.24)

(setq scroll-margin 2
      auto-save-default t
      display-line-numbers-type nil
      auth-source-cache-expiry nil
      starttls-use-gnutls t
      mac-right-option-modifier 'meta
      global-subword-mode t ; Iterate through CamelCase words
      delete-by-moving-to-trash t                      ; Delete files to trash
      window-combination-resize t                      ; take new window space from all other windows (not just current)
      x-stretch-cursor t
      avy-all-windows t
      good-scroll-mode t
      evil-escape-key-sequence "fd"
      gnutls-verify-error nil
      truncate-string-ellipsis "…"
      browse-url-browser-function 'xwidget-webkit-browse-url)

(use-package jest-test-mode
  :ensure t
  :commands jest-test-mode
  :hook (typescript-tsx-mode js-mode typescript-mode))
(map! :leader
      :mode (typescript-tsx-mode js-mode typescript-mode)
      :desc "run test at point"
      "m t t" #'jest-test-run-at-point)

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

;; org modern
(setq ;; Edit settings
 org-auto-align-tags nil
 org-tags-column 0
 org-fold-catch-invisible-edits 'show-and-error
 org-special-ctrl-a/e t
 org-insert-heading-respect-content t

 ;; Org styling, hide markup etc.
 org-hide-emphasis-markers t
 org-pretty-entities t
 org-ellipsis "…"

 ;; Agenda styling
 org-agenda-tags-column 0
 org-agenda-block-separator ?─
 org-agenda-time-grid
 '((daily today require-timed)
   (800 1000 1200 1400 1600 1800 2000)
   " ┄┄┄┄┄ " "┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄")
 org-agenda-current-time-string
 "⭠ now ─────────────────────────────────────────────────")
(global-org-modern-mode)

(setq treemacs-follow-mode t)

(global-wakatime-mode)
(setq  wakatime-cli-path "/opt/homebrew/bin/wakatime-cli"
  wakatime-api-key "waka_4a6bb692-ecb1-4a87-b177-46c29f24a451"
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
