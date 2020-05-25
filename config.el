;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

(add-to-list 'default-frame-alist '(height . 50))
(add-to-list 'default-frame-alist '(width . 100))
(setq user-full-name    "Zhang Qingbo"
      user-mail-address "ripple0328@gmail.com")

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
  jiralib-url "https://cbgdata.atlassian.net"
  jiralib-token
   '("Cookie" . "cloud.session.token=eyJraWQiOiJzZXNzaW9uLXNlcnZpY2VcL3Nlc3Npb24tc2VydmljZSIsImFsZyI6IlJTMjU2In0.eyJhc3NvY2lhdGlvbnMiOltdLCJzdWIiOiI1YjY3Zjk0MGJiOWQ3ZTI5ZmQ5NjYyYWUiLCJlbWFpbERvbWFpbiI6InRob3VnaHR3b3Jrcy5jb20iLCJpbXBlcnNvbmF0aW9uIjpbXSwicmVmcmVzaFRpbWVvdXQiOjE1NjY4Mjg3MTEsImlzcyI6InNlc3Npb24tc2VydmljZSIsImRvbWFpbnMiOltdLCJzZXNzaW9uSWQiOiI0YmE0YmI0Ni1kNGZmLTQ2NDItYWQyOS1mMTA3NGYxMzhhYmQiLCJhdWQiOiJhdGxhc3NpYW4iLCJuYmYiOjE1NjY4MjgxMTEsImV4cCI6MTU2OTQyMDExMSwiaWF0IjoxNTY2ODI4MTExLCJlbWFpbCI6InFiemhhbmdAdGhvdWdodHdvcmtzLmNvbSIsImp0aSI6IjRiYTRiYjQ2LWQ0ZmYtNDY0Mi1hZDI5LWYxMDc0ZjEzOGFiZCJ9.pu2a4OOdJWgQwBZvAmzm0KRXIEC5dfAYjyDHNkEV6BLH3nN9-j2_60VUgj3KBo-rz2mqD5y1NoT5yRSdu1FJ2PranwWYJI1FSOL9G0leSVnZGxoQPg0_KdjpQ9cyHSAk6ccPVFR6ClcaOi2dIvNYJYz9LzshJfVejQDnvPHHNOXNq_c1ejVDO52uXKDd-USbhAGer4q6J_AXwvL-x_dNzsR_an8z_GVt0CxrSrk2Whnodktyk6kzh3u-kPiW2QW7Ik-Vxb2HFru3UZJ_n0O_-DM9f_XqyXqWjubQ2lQCWx7xCihMRSKQvy1mKiomeHEm-MWXQr2YDJQYGhZff1aG1Q")
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
