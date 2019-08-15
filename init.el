;;; init.el -*- lexical-binding: t; -*-

;; copy this file to ~/.doom.d/init.el or ~/.config/doom/init.el ('doom
;; quickstart' will do this for you). the `doom!' block below controls what
;; modules are enabled and in what order they will be loaded. remember to run
;; 'doom refresh' after modifying it.
;;
;; more information about these modules (and what flags they support) can be
;; found in modules/readme.org.

(doom! :input
       chinese
       ;;japanese

       :completion
       company           ; the ultimate code completion backend
       ;;helm              ; the *other* search engine for love and life
       ;;ido               ; the other *other* search engine...
       ivy               ; a search engine for love and life

       :ui
       ;;deft              ; notational velocity for emacs
       doom              ; what makes doom look the way it does
       doom-dashboard    ; a nifty splash screen for emacs
       doom-quit         ; doom quit-message prompts when you quit emacs
       ;;fill-column       ; a `fill-column' indicator
       hl-todo           ; highlight todo/fixme/note tags
       ;;indent-guides     ; highlighted indent columns
       modeline          ; snazzy, atom-inspired modeline, plus api
       nav-flash         ; blink the current line after jumping
       ;;neotree           ; a project drawer, like nerdtree for vim
       ophints           ; highlight the region an operation acts on
       (popup            ; tame sudden yet inevitable temporary windows
        +all             ; catch all popups that start with an asterix
        +defaults)       ; default popup rules
       ;;pretty-code       ; replace bits of code with pretty symbols
       ;;tabbar            ; fixme an (incomplete) tab bar for emacs
       treemacs          ; a project drawer, like neotree but cooler
       unicode           ; extended unicode support for various languages
       vc-gutter         ; vcs diff in the fringe
       vi-tilde-fringe   ; fringe tildes to mark beyond eob
       window-select     ; visually switch windows
       workspaces        ; tab emulation, persistence & separate workspaces

       :editor
       (evil +everywhere); come to the dark side, we have cookies
       file-templates    ; auto-snippets for empty files
       fold              ; (nigh) universal code folding
       ;;(format +onsave)  ; automated prettiness
       ;;lispy             ; vim for lisp, for people who dont like vim
       multiple-cursors  ; editing in many places at once
       ;;objed             ; text object editing for the innocent
       ;;parinfer          ; turn lisp into python, sort of
       rotate-text       ; cycle region at point between text candidates
       snippets          ; my elves. they type so i don't have to

       :emacs
       (dired            ; making dired pretty [functional]
       ;;+ranger         ; bringing the goodness of ranger to dired
       +icons          ; colorful icons for dired-mode
        )
       electric          ; smarter, keyword-based electric-indent
       vc                ; version-control and emacs, sitting in a tree

       :term
       ;;eshell            ; a consistent, cross-platform shell (wip)
       shell             ; a terminal repl for emacs
       ;; term              ; terminals in emacs
       ;;vterm             ; another terminals in emacs

       :tools
       ;;ansible
       ;;debugger          ; fixme stepping through code, to help you add bugs
       ;;direnv
       ;;docker
       editorconfig      ; let someone else argue about tabs vs spaces
       ein               ; tame jupyter notebooks with emacs
       eval              ; run code, run (also, repls)
       flycheck          ; tasing you for every semicolon you forget
       ;;flyspell          ; tasing you for misspelling mispelling
       ;;gist              ; interacting with github gists
       (lookup           ; helps you navigate your code and documentation
        +docsets)        ; ...or in dash docsets locally
       ;;lsp
       ;;macos             ; macos-specific commands
       magit             ; a git porcelain for emacs
       ;;make              ; run make tasks from emacs
       ;;pass              ; password manager for nerds
       pdf               ; pdf enhancements
       ;;prodigy           ; fixme managing external services & code builders
       ;;rgb               ; creating color strings
       ;;terraform         ; infrastructure as code
       ;;tmux              ; an api for interacting with tmux
       ;;upload            ; map local to remote projects via ssh/ftp
       wakatime

       :lang
       ;;agda              ; types of types of types of types...
       ;;assembly          ; assembly for fun or debugging
       ;;cc                ; c/c++/obj-c madness
       ;;clojure           ; java with a lisp
       ;;common-lisp       ; if you've seen one lisp, you've seen them all
       ;;coq               ; proofs-as-programs
       ;;crystal           ; ruby at the speed of c
       ;;csharp            ; unity, .net, and mono shenanigans
       data              ; config/data formats
       ;;erlang            ; an elegant language for a more civilized age
       elixir            ; erlang done right
       ;;elm               ; care for a cup of tea?
       emacs-lisp        ; drown in parentheses
       ;;ess               ; emacs speaks statistics
       ;;fsharp           ; ml stands for microsoft's language
       ;;go                ; the hipster dialect
       ;;(haskell +intero) ; a language that's lazier than i am
       ;;hy                ; readability of scheme w/ speed of python
       ;;idris             ;
       (java +meghanada) ; the poster child for carpal tunnel syndrome
       javascript        ; all(hope(abandon(ye(who(enter(here))))))
       ;;julia             ; a better, faster matlab
       kotlin            ; a better, slicker java(script)
       ;;latex             ; writing papers in emacs has never been so fun
       ;;ledger            ; an accounting system in emacs
       ;;lua               ; one-based indices? one-based indices
       markdown          ; writing docs for people to ignore
       ;;nim               ; python + lisp at the speed of c
       ;;nix               ; i hereby declare "nix geht mehr!"
       ;;ocaml             ; an objective camel
       (org              ; organize your plain life in plain text
        +dragndrop       ; file drag & drop support
        +ipython         ; ipython support for babel
        +pandoc          ; pandoc integration into org's exporter
        +present)        ; using emacs for presentations
       ;;perl              ; write code no one else can comprehend
       ;;php               ; perl's insecure younger brother
       plantuml          ; diagrams for confusing people more
       ;;purescript        ; javascript, but functional
       python            ; beautiful is better than ugly
       ;;qt                ; the 'cutest' gui framework ever
       ;;racket            ; a dsl for dsls
       ;;rest              ; emacs as a rest client
       ;; ruby              ; 1.step {|i| p "ruby is #{i.even? ? 'love' : 'life'}"}
       ;;rust              ; fe2o3.unwrap().unwrap().unwrap().unwrap()
       scala             ; java, but good
       ;;scheme            ; a fully conniving family of lisps
       sh                ; she sells {ba,z,fi}sh shells on the c xor
       ;;solidity          ; do you need a blockchain? no.
       ;;swift             ; who asked for emoji variables?
       ;;terra             ; earth and moon in alignment for performance.
       web               ; the tubes
       ;;vala              ; gobjective-c

       :email
       ;;(mu4e +gmail)       ; wip
       ;;notmuch             ; wip
       ;;(wanderlust +gmail) ; wip

       ;; applications are complex and opinionated modules that transform emacs
       ;; toward a specific purpose. they may have additional dependencies and
       ;; should be loaded late.
       :app
       ;;calendar
       ;;irc              ; how neckbeards socialize
       ;;(rss +org)        ; emacs as an rss reader
       ;; twitter           ; twitter client https://twitter.com/vnought
       ;;(write            ; emacs as a word processor (latex + org + markdown)
       ;; +wordnut         ; wordnet (wn) search
       ;; +langtool)       ; a proofreader (grammar/style check) for emacs

       :collab
       ;;floobits          ; peer programming for a price
       ;; impatient-mode    ; show off code over HTTP

       :config
       ;; For literate config users. This will tangle+compile a config.org
       ;; literate config in your `doom-private-dir' whenever it changes.
       literate

       ;; The default module sets reasonable defaults for Emacs. It also
       ;; provides a Spacemacs-inspired keybinding scheme and a smartparens
       ;; config. Use it as a reference for your own modules.
       (default +bindings +smartparens))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(debug-on-error t)
 '(mouse-wheel-progressive-speed nil)
 '(mouse-wheel-scroll-amount (quote (1 ((shift) . 5) ((control)))))
 '(wakatime-api-key "4a6bb692-ecb1-4a87-b177-46c29f24a451"))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
