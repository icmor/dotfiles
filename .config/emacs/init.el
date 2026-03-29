;; -*- lexical-binding: t; outline-minor-mode: t -*-
;;; packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setopt package-selected-packages
	'(
	  auctex
	  bash-completion
	  dumb-jump
	  elfeed
	  gcmh
	  haskell-mode
	  imenu-list
	  magit
	  markdown-mode
	  minions
	  no-littering
	  olivetti
	  pdf-tools
	  popper
	  proof-general
	  pyvenv
	  racket-mode
	  saveplace-pdf-view
	  tmr
	  transpose-frame
	  treesit-auto
	  vterm
	  ws-butler
	  ))
(package-install-selected-packages)
(if (daemonp) (mapc #'require package-selected-packages))

;;; general
(setopt package-native-compile t)
(setopt native-comp-async-report-warnings-errors 'silent)
(setopt safe-local-variable-values '((outline-minor-mode . t)))

;;;; litter
(setopt auto-save-list-file-prefix
	(no-littering-expand-var-file-name "auto-save-list/.saves-"))
(setopt backup-directory-alist
	`((".*" . ,(no-littering-expand-var-file-name "backup"))))
(setopt org-preview-latex-image-directory
	(no-littering-expand-var-file-name "ltximg/"))
(setopt custom-file (no-littering-expand-etc-file-name "custom.el"))
(setopt tramp-backup-directory-alist backup-directory-alist)
(setopt version-control t)
(setopt kept-new-versions 2)
(setopt kept-old-versions 2)
(setopt delete-old-versions t)

;;;; doom hacks
(setopt gcmh-idle-delay 'auto)
(setopt gcmh-auto-idle-delay-factor 10)
(setopt gcmh-high-cons-threshold (* 16 1024 1024))
(setq read-process-output-max (* 1024 1024))
(gcmh-mode)

;;;; functions
(defun describe-symbol-at-point ()
  (interactive)
  (describe-symbol (or (symbol-at-point) (error "No symbol-at-point"))))

(defun dired-find-file-other-frame ()
  "In Dired, visit this file or directory in another frame."
  (interactive)
  (dired--find-file #'find-file-other-frame (dired-get-file-for-visit)))

(defun ibuffer-mark-eww-buffers nil
  """Mark all eww buffers in ibuffer."""
  (interactive)
  (ibuffer-mark-by-mode-regexp "eww"))

(defun ibuffer-mark-common-buffers nil
  """Mark commonly used buffers in ibuffer for ease of use."""
  (interactive)
  (ibuffer-update nil)
  (ibuffer-mark-by-name-regexp "shell")
  (ibuffer-mark-by-name-regexp "vterm")
  (ibuffer-mark-by-name-regexp "Org Agenda")
  (ibuffer-mark-by-name-regexp "scratch"))

(defun mpv-play (url &optional _)
  (let ((sock "/tmp/mpvsocket")
        (cmd  "{\"command\":[\"loadfile\",\"%s\",\"append-play\"]}\n"))
    (condition-case nil
        (let ((proc (make-network-process
		     :name "mpv-ipc"
		     :family 'local
		     :service sock)))
          (process-send-string proc (format cmd url))
	  (delete-process proc))
      (file-error (start-process "mpv" nil "mpv"
				 (concat "--input-ipc-server=" sock) url)))))

;; https://karthinks.com/software/emacs-window-management-almanac/
(defalias 'other-window-alternating
  (let ((direction 1))
    (lambda (&optional arg)
      "Call `other-window', switching directions each time."
      (interactive)
      (if (equal last-command 'other-window-alternating)
          (other-window (* direction (or arg 1)))
        (setq direction (- direction))
        (other-window (* direction (or arg 1)))))))
(put 'other-window 'repeat-map nil)

(defun my-eglot-toggle ()
  "Start eglot in project if not started and shutdown otherwise."
  (interactive)
  (or (fboundp #'eglot-managed-p) (require 'eglot))
  (if (eglot-managed-p)
      (eglot-shutdown-all)
    (eglot-ensure)))

(defun my-gdb-restart ()
  "Kill all running GUD sessions and restart GDB."
  (interactive)
  (dolist (buf (buffer-list))
    (let ((name (buffer-name buf)))
      (when (and name (string-match-p "^\\*gud-?.*\\*$" name))
        (let ((proc (get-buffer-process buf)))
          (when proc
            (kill-process proc)))
        (kill-buffer buf))))
  (call-interactively 'gdb))

(defun my-project-find-library ()
  "Call project-switch-project on language-specific directory"
  (interactive)
  (let ((dir
	 (cdr (assq major-mode (if (boundp 'project-libs) project-libs nil)))))
    (if dir (project-switch-project dir))))

(defun my-preview-dwim (&optional arg)
  "Preview latex in auctex buffers based on org-latex-preview."
  (interactive "P")
  (cond
   ((equal arg '(64))
    (preview-clearout-document))
   ((equal arg '(16))
    (preview-document))
   ((equal arg '(4))
    (preview-clearout-section))
   ((preview-at-point))))

(defun my-shell-other-window (&optional arg)
  "Jump to shell number ARG in other window (close current shell window)."
  (interactive "P")
  (if (and (eq major-mode 'shell-mode) (not arg))
      (delete-window)
    (shell (pop-to-buffer
	    (if (not arg) "*shell*"
	      (format "*s%d*" (prefix-numeric-value arg)))))))

(defun my-shell-toggle (&optional arg)
  "Toggle a shell window (with ARG name it *s<arg>*)."
  (interactive "P")
  (if (and (eq major-mode 'shell-mode) (not arg))
      (previous-buffer)
    (shell (if (not arg) nil
	     (format "*s%d*" (prefix-numeric-value arg))))))

(defun my-vterm-toggle (&optional arg)
  "Toggle vterm window number ARG."
  (interactive "P")
  (if (and (eq major-mode 'vterm-mode)
	   (not arg))
      (previous-buffer)
    (call-interactively #'vterm)))

;;; bindings
;;;; global
(keymap-global-set "<f2>" #'my-shell-toggle)
(keymap-global-set "C-<f2>" #'my-shell-other-window)
(keymap-global-set "M-g l" #'imenu-list-smart-toggle)
(keymap-global-set "C-c a" #'org-agenda-list)
(keymap-global-set "C-c c" #'org-capture)
(keymap-global-set "C-c p" #'proced)
(keymap-global-set "C-c e" #'elfeed)
(keymap-global-set "C-c n" #'remember)
(keymap-global-set "C-c m" #'remember-notes)
(keymap-global-set "C-c s" #'scratch-buffer)
(keymap-global-set "C-c t" #'tmr)

(if (or (daemonp) window-system)
    (progn (keymap-global-set "<f1>" #'my-vterm-toggle)
	   (keymap-global-set "C-<f1>" #'vterm-other-window)))

;; contested bindings
(require 'bind-key)
(bind-key* "M-o" #'other-window-alternating)
(bind-key* "C-;" #'previous-buffer)
(bind-key* "C-'" #'next-buffer)
(bind-key* "C-<up>" #'windmove-up)
(bind-key* "C-<down>" #'windmove-down)
(bind-key* "C-<left>" #'windmove-left)
(bind-key* "C-<right>" #'windmove-right)

;;;; better defaults
(keymap-global-unset "C-x C-z")
(keymap-global-set "C-x f" #'find-file)
(keymap-global-set "C-x C-b" #'ibuffer)
(keymap-global-set "C-x k" #'kill-current-buffer)
(keymap-global-set "C-x K" #'kill-buffer)
(keymap-global-set "M-z" #'zap-up-to-char)
(keymap-global-set "M-/" #'hippie-expand)
(keymap-global-set "C-x l" #'count-words)
(keymap-global-set "C-x r m" #'bookmark-set-no-overwrite)
(keymap-global-set "C-x r M" #'bookmark-set)
(keymap-global-set "C-o" #'split-line)
(keymap-global-set "C-M-o" #'open-line)
(keymap-global-set "C-h C-m" #'man)
(keymap-global-set "C-x C-c" #'save-buffers-kill-emacs)
(keymap-global-set "C-x C-<left>" #'windmove-swap-states-left)
(keymap-global-set "C-x C-<right>" #'windmove-swap-states-right)
(keymap-global-set "C-x C-<up>" #'windmove-swap-states-up)
(keymap-global-set "C-x C-<down>" #'windmove-swap-states-down)

;;; org
;;;; general
(setopt org-agenda-files '("~/org/gtd.org" "~/org/inbox.org"))
(setopt org-modules '(org-habit ol-man ol-info))
(setopt org-cycle-include-plain-lists 'integrate)
(setopt org-list-allow-alphabetical t)
(setopt org-use-speed-commands t)
(setopt org-startup-folded 'fold)
(setopt org-return-follows-link t)
(setopt org-capture-bookmark nil)
(setopt org-archive-default-command nil)
(setopt org-log-repeat nil)
(setopt org-hierarchical-todo-statistics nil)
(setopt org-refile-targets '((nil . (:maxlevel . 3))
			     (org-agenda-files . (:level . 1))))

;;;; visual
(setopt org-adapt-indentation nil)
(setopt org-startup-with-inline-images t)
(setopt org-image-actual-width 250)
(add-hook 'org-mode-hook #'olivetti-mode)
(add-hook 'org-mode-hook #'ws-butler-mode)

;;;; org + latex
(setopt org-latex-packages-alist
	'(("margin=2.5cm" "geometry" nil)
	  ("" "listings" nil)
	  ("" "xcolor" nil)))
(setopt org-export-headline-levels 5)
(setopt org-export-with-section-numbers 2)
(setopt org-latex-toc-command "\\tableofcontents\n\\clearpage\n")
(setopt org-latex-hyperref-template "\\hypersetup{
 pdfauthor={%a},
 pdftitle={%t},
 pdfkeywords={%k},
 pdfsubject={%d},
 pdfcreator={%c},
 pdflang={%L},
 colorlinks,
 linkcolor=black,
 filecolor={purple!80!black},
 citecolor={blue!50!black},
 urlcolor={blue!80!black}}
")
(with-eval-after-load 'org
  (plist-put org-format-latex-options :scale 1.5))

;; https://stackoverflow.com/a/47850858
(defun my-org-export-output-file-name (orig-fun extension &optional subtreep pub-dir)
  (let ((pub-dir (or pub-dir "org-exports")))
    (unless (file-directory-p pub-dir)
      (make-directory pub-dir t))
    (funcall orig-fun extension subtreep pub-dir)))
(advice-add #'org-export-output-file-name
            :around #'my-org-export-output-file-name)

;;;; calendar
;; https://github.com/sggutier/mexican-holidays
(with-eval-after-load 'calendar
  (defvar holiday-mexican-holidays
    '((holiday-fixed 1 1 "Año Nuevo")
      (holiday-fixed 2 5 "Día de la Constitución")
      (holiday-fixed 3 21 "Natalicio de Benito Juárez")
      (holiday-fixed 5 1 "Día del Trabajador")
      (holiday-fixed 5 5 "Aniversario de la Batalla de Puebla")
      (holiday-fixed 9 16 "Aniversario de la Independencia")
      (holiday-fixed 11 20 "Día de la Revolución Mexicana")
      (holiday-fixed 12 25 "Navidad")))
  (defvar holiday-mexican-festivities
    '((holiday-fixed 1 6 "Día de los Reyes Magos")
      (holiday-fixed 2 14 "Día de San Valentín")
      (holiday-easter-etc -7 "Domingo de Ramos")
      (holiday-easter-etc 0 "Día de Pascua")
      (holiday-fixed 4 30 "Día del Niño")
      (holiday-fixed 5 10 "Día de las Madres")
      (holiday-fixed 5 15 "Día del Docente")
      (holiday-fixed 5 23 "Día del Estudiante")
      (holiday-float 6 0 3 "Día del Padre")
      (holiday-fixed 10 31 "Halloween")
      (holiday-fixed 11 2 "Día de Muertos")
      (holiday-fixed 12 24 "Nochebuena")
      (holiday-fixed 12 28 "Día de los Inocentes")
      (holiday-fixed 12 31 "Vispera de Año Nuevo")))
  (setopt calendar-holidays (append holiday-solar-holidays
				    holiday-mexican-holidays
				    holiday-mexican-festivities)))
(setopt org-agenda-include-diary t)

;;;; capture
(setopt org-capture-templates
	'(("i" "Inbox")
	  ("ii" "Inbox" entry (file+headline "inbox.org" "Inbox")
	   "* %?\n")
	  ("is" "School" entry (file+headline "inbox.org" "School")
	   "* %?\n")
	  ("iw" "Waiting" entry (file+headline "inbox.org" "Waiting")
	   "* %?\n")
	  ("c" "Tasks" entry (file+headline "gtd.org" "Tasks")
           "* TODO %?\n")
	  ("h" "Homework" entry (file+headline "gtd.org" "Homework")
           "* TODO %?\n")
	  ("x" "Exams" entry (file+headline "gtd.org" "Exams")
           "* %?\n")
	  ("e" "Events" entry (file+headline "gtd.org" "Events")
           "* %?\n")
	  ("t" "Things" entry (file+headline "things.org" "Comprar")
	   "* TODO %?\n")))

;;;; babel
(setopt org-confirm-babel-evaluate nil)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)
   (dot . t)))

;;; essentials
;;;; auth-source
(setopt epg-pinentry-mode 'loopback)
(setopt auth-sources '("~/.config/emacs/etc/.authinfo.gpg"))
(setopt password-cache-expiry 300)

;;;; tramp
(connection-local-set-profile-variables
 'remote-without-auth-sources '((auth-sources . nil)))
(connection-local-set-profiles
 '(:application tramp) 'remote-without-auth-sources)

;;;; dired
(setopt dired-dwim-target t)
(setopt dired-free-space nil)
(setopt dired-listing-switches "-lhA")
(setopt dired-vc-rename-file t)
(setopt wdired-allow-to-change-permissions t)
(setopt image-dired-thumbnail-storage 'standard-large)
(setopt image-use-external-converter t)
(add-hook 'dired-mode-hook #'dired-hide-details-mode)
(with-eval-after-load 'dired
  (keymap-set dired-mode-map "C-M-o" #'dired-find-file-other-frame))

;;;; which-key
(setopt which-key-idle-delay 0.5)
(setopt which-key-idle-secondary-delay 0.05)
(which-key-mode)

;;;; comint
(setopt comint-prompt-read-only t)
(setopt ansi-color-for-comint-mode t)
(setopt comint-input-ring-size 10000)
(add-hook 'comint-mode-hook #'electric-pair-local-mode)
(add-hook 'comint-output-filter-functions 'comint-osc-process-output)
(with-eval-after-load 'comint
  (keymap-set comint-mode-map "M-." #'comint-insert-previous-argument))

;;;; shell
(setopt shell-command-prompt-show-cwd t)
(setopt shell-kill-buffer-on-exit t)
(add-hook 'shell-mode-hook #'shell-dirtrack-mode)
(defun my-shell-history-hook ()
  (setq-local comint-input-ring-file-name "~/.local/state/bash/history")
  (comint-read-input-ring t))
(add-hook 'shell-mode-hook #'my-shell-history-hook)
(bash-completion-setup)

;;;; vterm
(setopt vterm-max-scrollback 100000)
(with-eval-after-load 'vterm
  (keymap-set vterm-mode-map "<f1>" nil)
  (keymap-set vterm-mode-map "M-!" nil)
  (keymap-set vterm-mode-map "C-M-v" nil)
  (keymap-set vterm-mode-map "C-M-S-v" nil)
  (keymap-set vterm-mode-map "M-:" nil)
  (keymap-set vterm-mode-map "<f2>" nil)
  (keymap-set vterm-mode-map "<f11>" nil)
  (keymap-set vterm-mode-map "C-u" #'vterm--self-insert)
  (keymap-set vterm-mode-map "C-SPC" #'vterm-copy-mode)
  (keymap-set vterm-copy-mode-map "C-w" #'vterm-copy-mode-done)
  (keymap-set vterm-copy-mode-map "M-w" #'vterm-copy-mode-done))

;;;; outline-minor-mode
(setopt outline-minor-mode-cycle t)

;;;; auctex
(setopt TeX-auto-save t)
(setopt TeX-parse-self t)
(setopt TeX-view-program-selection '((output-pdf "PDF Tools")))
(setopt TeX-source-correlate-start-server t)
(setopt LaTeX-default-environment "align*")
(setopt preview-auto-cache-preamble t)
(setopt TeX-output-dir "auctex")
(setopt TeX-auto-local "auctex")
(add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)
(add-hook 'LaTeX-mode-hook #'olivetti-mode)
(add-hook 'LaTeX-mode-hook #'ws-butler-mode)
(with-eval-after-load 'latex
  (keymap-set TeX-mode-map "C-c C-x C-l" #'my-preview-dwim))

;;;; pdf-tools
(if  (or (daemonp) window-system) (pdf-loader-install t))
(setopt pdf-view-resize-factor 1.1)
(setopt pdf-view-continuous nil)
(add-hook 'pdf-view-mode-hook #'save-place-local-mode)
(add-hook 'pdf-annot-list-mode-hook #'pdf-annot-list-follow-minor-mode)
(with-eval-after-load 'pdf-tools
  (keymap-set pdf-view-mode-map "M" #'pdf-view-midnight-minor-mode)
  (keymap-set pdf-view-mode-map "<prior>" #'pdf-view-scroll-down-or-previous-page)
  (keymap-set pdf-view-mode-map "<next>" #'pdf-view-scroll-up-or-next-page))

;;;; magit
(add-hook 'git-commit-mode-hook #'auto-fill-mode)
(add-hook 'git-commit-mode-hook (lambda () (setq-local fill-column 72)))

;;;; ibuffer
(with-eval-after-load 'ibuffer
  (keymap-set ibuffer-mode-map "* n" #'ibuffer-mark-common-buffers)
  (keymap-set ibuffer-mode-map "* w" #'ibuffer-mark-eww-buffers))

;;;; browse-url
(add-to-list 'browse-url-handlers '("youtu\\(\\.be\\|be\\.com\\)" . mpv-play))

;;;; popper
(setopt popper-reference-buffers
	'("\\*Backtrace\\*"
	  "\\*Messages\\*"
	  "\\*Warnings\\*"
          "Output\\*$"
          "\\*Async Shell Command\\*"
          help-mode))
(keymap-global-set "C-<tab>" 'popper-toggle)
(keymap-global-set "M-<tab>" 'popper-cycle)
(keymap-global-set "C-M-<tab>" 'popper-toggle-type)
(popper-mode)

;;;; remember
(setopt remember-data-file "~/notes/remember")
(setopt remember-notes-bury-on-kill nil)

;;;; olivetti-mode
(setopt olivetti-body-width 100)

;;;; proced
(setopt proced-goal-attribute nil)
(setopt proced-enable-color-flag t)
(setopt proced-auto-update-interval 1)
(setopt proced-auto-update-flag 'visible)
(with-eval-after-load 'proced
  (add-to-list 'proced-format-alist
	       '(custom user pid pcpu pmem rss state tree (args comm)))
  (setopt proced-format 'custom)
  (keymap-set proced-mode-map "G" #'proced-toggle-auto-update))

;;;; calc
(setopt calc-group-digits t)

;;;; elfeed
(condition-case nil (load-file (no-littering-expand-var-file-name "feeds.el"))
  ((error nil) (message "feeds.el not found")))
(with-eval-after-load 'elfeed
  (add-hook 'elfeed-new-entry-hook
            (elfeed-make-tagger :feed-url "youtube\\.com/shorts" :add 'read)))
;;;; tmr
(with-eval-after-load 'tmr #'tmr-mode-line-mode)

;;;; irc
(setopt rcirc-default-nick "icmor")
(setopt rcirc-default-user-name "icmor")
(setopt rcirc-server-alist '(("irc.libera.chat" :port 6697 :encryption tls)))

;;; programming
;;;; general
(setopt compilation-read-command nil)
(add-hook 'compilation-filter-hook #'ansi-osc-compilation-filter)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)
(add-hook 'prog-mode-hook #'electric-pair-local-mode)
(add-hook 'prog-mode-hook #'ws-butler-mode)

;;;; treesit-auto
;; https://github.com/renzmann/treesit-auto/issues/44
(require 'treesit-auto)
(setopt treesit-auto-langs
	'(bash
	  c
	  css
	  cmake
	  cpp
	  dockerfile
	  go
	  gomod
	  java
	  javascript
	  json
	  python
	  yaml))
(setopt treesit-auto-install 'prompt)
(treesit-auto-add-to-auto-mode-alist)
(global-treesit-auto-mode)

;;;; project
(defvar project-libs
  `((c-ts-mode . "/usr/include")
    (c++-ts-mode . "/usr/include")
    (java-mode . "/usr/lib/jvm")
    (python-ts-mode . ,(car (file-expand-wildcards "/usr/lib/python3.??")))))
(setopt project-kill-buffers-display-buffer-list t)
(setopt project-vc-extra-root-markers '(".project"))
(keymap-set project-prefix-map "l" #'my-project-find-library)

;;;; eglot
(setopt eglot-ignored-server-capabilities
	'(:documentFormattingProvider
	  :textDocument/publishDiagnostics
	  :documentRangeFormattingProvider
	  :inlayHintProvider))
(setopt eglot-events-buffer-config '(:size 0 :format full))
(setopt eglot-events-buffer-size 0)
(setopt eglot-autoshutdown t)
(fset #'jsonrpc--log-event #'ignore)
(add-hook 'eglot--managed-mode-hook (lambda () (flymake-mode -1)))
(with-eval-after-load 'eglot
  (let ((clang-args
	 `("clangd"
           ,(concat "-j=" (number-to-string (num-processors)))
	   "--log=error"
           "--malloc-trim"
           "--background-index"
           "--cross-file-rename"
           "--completion-style=detailed"
           "--pch-storage=memory"
           "--header-insertion=never"
           "--header-insertion-decorators=0")))
    (add-to-list 'eglot-server-programs
		 `((c-mode c++-mode) . ,clang-args))))

;;;; xref
(setopt xref-prompt-for-identifier nil)
(with-eval-after-load 'xref
  (add-to-list 'xref-backend-functions #'dumb-jump-xref-activate t))

;;;; imenu-list
(setopt imenu-list-focus-after-activation t)
(with-eval-after-load 'imenu-list
  (keymap-set imenu-list-major-mode-map "<tab>" #'hs-toggle-hiding))

;;;; gud
(setopt gdb-default-window-configuration-file "var/gdbwindows.el")
(setopt gdb-debuginfod-enable-setting nil)
(setopt gdb-many-windows t)
(add-hook 'gdb-breakpoints-mode-hook #'toggle-truncate-lines)
(add-hook 'gdb-locals-mode-hook #'toggle-truncate-lines)

;; fixes functions not working because they expect an EVENT (mouse click)
(with-eval-after-load 'gdb-mi
  (keymap-set gdb-memory-mode-map "R"
	      (lambda () (interactive) (gdb-memory-set-rows nil)))
  (keymap-set gdb-memory-mode-map "C"
	      (lambda () (interactive) (gdb-memory-set-columns nil))))
(with-eval-after-load 'gud
  (keymap-set gud-global-map "r" #'gud-run)
  (keymap-set gud-global-map "C-c" #'my-gdb-restart)
  (keymap-set gud-minor-mode-map "C-c C-p" #'comint-previous-prompt)
  (keymap-set gud-minor-mode-map "C-c C-n" #'comint-next-prompt))

;; https://stackoverflow.com/a/24923325
(defun my-gdb-inferior-filter (orig proc string)
  (with-current-buffer (gdb-get-buffer-create 'gdb-inferior-io)
    (comint-output-filter proc string)))
(advice-add 'gdb-inferior-filter :around #'my-gdb-inferior-filter)

;;;; c
(setopt c-ts-mode-indent-offset 4)
(setopt c-ts-mode-indent-style 'linux)
(add-hook 'c-ts-mode-hook #'c-ts-mode-toggle-comment-style)
(with-eval-after-load 'c-ts-mode
  (keymap-set c-ts-mode-map "C-c C-r" #'gdb)
  (keymap-set c-ts-mode-map "C-c C-d" #'man-follow)
  (keymap-set c-ts-mode-map "C-c C-c" #'project-compile))

;;;; python
(defun my-set-python-compile-command ()
  (let ((infile (file-relative-name buffer-file-name)))
    (setq-local compile-command (concat "mypy --strict " infile))))
(setopt python-indent 4)
(setopt python-check-command "flake8 --color=never")
(add-hook 'pyvenv-post-activate-hooks #'pyvenv-mode)
(add-hook 'python-ts-mode-hook #'my-set-python-compile-command)
(add-hook 'python-ts-mode-hook
	  (lambda nil (setq-local forward-sexp-function nil)))
;; disable new python 3.13 repl
;; https://docs.python.org/3/using/cmdline.html#envvar-PYTHON_BASIC_REPL
(setenv "PYTHON_BASIC_REPL" "1")

;;;; racket
(with-eval-after-load 'racket-mode
  (keymap-set racket-repl-mode-map "C-c M-o"
	      #'racket-repl-clear-leaving-last-prompt))

;;;; html
(with-eval-after-load 'mhtml-mode
  (add-to-list
   'html-tag-alist
   '("html"
     (let ((title (read-string "Title: ")))
       (list nil
             "<head>\n<title>" title "</title>\n</head>\n"
             "<body>\n<h1>" title "</h1>\n"
             '_
             "\n</body>")))))

;;;; css
(with-eval-after-load 'css-mode
  (keymap-set css-mode-map "C-c C-l" #'list-colors-display))

;;;; json
(setopt json-ts-mode-indent-offset 2)

;;;; haskell
(setopt haskell-process-suggest-remove-import-lines t)
(setopt haskell-process-auto-import-loaded-modules t)
(setopt haskell-interactive-popup-errors nil)
(with-eval-after-load 'haskell
  (keymap-set interactive-haskell-mode-map "C-c C-c" #'haskell-process-load-file))
(with-eval-after-load 'haskell-interactive-mode
  (keymap-set haskell-interactive-mode-map "C-c M-o" #'haskell-interactive-mode-clear))
(add-hook 'haskell-mode-hook #'interactive-haskell-mode)
(add-hook 'haskell-interactive-mode-hook #'electric-pair-local-mode)

;;;; java
(add-hook 'java-mode-hook #'subword-mode)

;;;; markdown
(setopt markdown-fontify-code-blocks-natively t)
(setopt markdown-command "pandoc --quiet -f gfm -s")
(add-hook 'conf-mode-hook #'ws-butler-mode)
(add-hook 'markdown-mode-hook 'olivetti-mode)
(add-hook 'markdown-mode-hook 'ws-butler-mode)
(add-hook 'rst-mode-hook #'olivetti-mode)
(add-hook 'rst-mode-hook #'ws-butler-mode)

;;;; proof-general
(setopt proof-splash-enable nil)
(with-eval-after-load 'coq-mode
  (keymap-set coq-mode-map "C-c C-c" #'proof-goto-point)
  (keymap-set coq-mode-map "C-M-i" #'proof-script-complete))

;;;; man
(setopt Man-switches "-a")
(setopt Man-notify-method 'aggressive)
(add-to-list 'display-buffer-alist
	     '("\\`\\*Man .*\\*\\'" .
	       (display-buffer-reuse-mode-window
		(inhibit-same-window . nil)
		(mode . Man-mode))))
(add-hook 'Man-cooked-hook
	  (lambda () (ansi-osc-apply-on-region (point-min) (point-max))))

;;; miscellaneous
;;;; better defaults
(setopt show-paren-delay 0)
(setopt show-paren-style 'mixed)
(setopt show-paren-context-when-offscreen t)
(setopt view-read-only t)
(setopt use-short-answers t)
(setopt server-client-instructions nil)
(setopt find-file-suppress-same-file-warnings t)
(setopt disabled-command-function nil)
(setopt ring-bell-function 'ignore)
(setopt pgtk-use-im-context-on-new-connection nil)
(global-so-long-mode)
(repeat-mode)
(winner-mode)

;;;; completion
(setopt completions-detailed t)
(setopt completion-auto-help 'visible)
(setopt completions-format 'one-column)
(setopt completion-ignore-case t)
(setopt read-buffer-completion-ignore-case t)
(setopt read-file-name-completion-ignore-case t)
(setopt completion-styles '(basic partial-completion substring))
(keymap-set minibuffer-mode-map "C-p" #'minibuffer-previous-completion)
(keymap-set minibuffer-mode-map "C-n" #'minibuffer-next-completion)
(keymap-set completion-in-region-mode-map "C-p" #'minibuffer-previous-completion)
(keymap-set completion-in-region-mode-map "C-n" #'minibuffer-next-completion)
(keymap-unset minibuffer-local-completion-map "SPC")
(keymap-unset minibuffer-local-completion-map "?")

;;;; help
;; https://lists.gnu.org/archive/html/emacs-devel/2024-03/msg00080.html
(setopt describe-bindings-outline-rules nil)

;;;; files
(setopt auto-save-default nil)
(setopt backup-by-copying t)
(setopt create-lockfiles nil)
(setopt vc-follow-symlinks t)
(setopt find-file-visit-truename t)
(setopt delete-by-moving-to-trash t)

;;;; scrolling
(setopt mouse-wheel-progressive-speed nil)
(pixel-scroll-precision-mode)

;;;; visual
(setopt bookmark-set-fringe-mark nil)
(setopt minions-mode-line-lighter "λ")
(add-to-list 'default-frame-alist '(font . "Source Code Pro-16"))
(load-theme 'modus-vivendi t)
(blink-cursor-mode -1)
(tooltip-mode -1)
(minions-mode)

;;;; windmove
(defvar my-windmove-repeat-map
  (let ((map (make-sparse-keymap)))
    (keymap-set map "<up>" #'windmove-up)
    (keymap-set map "<down>" #'windmove-down)
    (keymap-set map "<left>" #'windmove-left)
    (keymap-set map "<right>" #'windmove-right)
    map))
(dolist (cmd '(windmove-up windmove-down windmove-left windmove-right))
  (put cmd 'repeat-map 'my-windmove-repeat-map))

;;;; bookmarks
(setopt bookmark-save-flag 1)
(setopt bookmark-search-size 8)

;;;; history
(setopt history-length 1000)
(setopt history-delete-duplicates t)
(savehist-mode)

;;;; documents
(setopt doc-view-resolution 400)

;;;; text
(setopt sentence-end-double-space nil)
(setopt require-final-newline t)
(setopt save-interprogram-paste-before-kill t)
(setopt ispell-dictionary "en_US-large")
(setopt fill-column 80)
(set-default-coding-systems 'utf-8)

;;;; cookie
(setopt cookie-file "~/org/cookie.org")
(setopt initial-scratch-message
	(concat (replace-regexp-in-string
		 "^" ";; " (cookie cookie-file)) "\n\n"))
