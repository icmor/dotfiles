;;; -*- lexical-binding: t; outline-minor-mode: t -*-
;;; packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setq package-selected-packages
      '(
	auctex
	bash-completion
	cdlatex
	dumb-jump
	gcmh
	haskell-mode
	imenu-list
	magit
	markdown-mode
	minions
	no-littering
	pdf-tools
	proof-general
	pyvenv
	racket-mode
	saveplace-pdf-view
	tmr
	transpose-frame
	vterm
	which-key
	ws-butler
	))
(package-install-selected-packages)
(if (daemonp) (mapc #'require package-selected-packages))

;;; general
(setq package-native-compile t)
(setq native-comp-async-report-warnings-errors 'silent)
(add-to-list 'safe-local-variable-values ' (outline-minor-mode . t))

;;;; litter
(setq auto-save-list-file-prefix
      (no-littering-expand-var-file-name "auto-save-list/.saves-"))
(setq backup-directory-alist
      `((".*" . ,(no-littering-expand-var-file-name "backup"))))
(setq org-preview-latex-image-directory
      (no-littering-expand-var-file-name "ltximg/"))
(setq custom-file (no-littering-expand-etc-file-name "custom.el"))
(setq tramp-backup-directory-alist backup-directory-alist)
(setq version-control t)
(setq kept-new-versions 4)
(setq kept-old-versions 2)
(setq delete-old-versions t)

;;;; doom hacks
(gcmh-mode)
(setq gcmh-idle-delay 'auto)
(setq gcmh-auto-idle-delay-factor 10)
(setq gcmh-high-cons-threshold (* 16 1024 1024))
(setq read-process-output-max (* 1024 1024))

;;;; functions
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

(defun my-org-sort (&optional level)
  "Sort org headlines alphabetically at LEVEL (default 1)."
  (interactive "P")
  (org-map-entries
   (lambda nil (org-sort-entries nil ?a))
   (concat "LEVEL=" (number-to-string (or level 1)))))

(defun my-project-find-library ()
  "Call project-switch-project on language-specific directory"
  (interactive)
  (let ((dir
	 (cdr (assq major-mode (if (boundp 'project-libs) project-libs nil)))))
    (if dir (project-switch-project dir))))

(defun my-project-refresh ()
  "Populate project--list."
  (interactive)
  (project-forget-zombie-projects)
  (project-remember-projects-under "~/dotfiles/")
  (project-remember-projects-under "~/Dropbox/code/" t)
  (project-remember-projects-under "~/Dropbox/universidad/" t))

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

(defun my-shell-toggle (&optional arg)
  "Toggle a shell window (with ARG name it *s<arg>*)."
  (interactive "P")
  (if (and (eq major-mode 'shell-mode) (not arg))
      (previous-buffer)
    (shell (if (not arg) nil
	     (format "*s%d*" (prefix-numeric-value arg))))))

(defun my-shell-other-window (&optional arg)
  "Jump to shell number ARG in other window (close current shell window)."
  (interactive "P")
  (if (and (eq major-mode 'shell-mode) (not arg))
      (delete-window)
    (shell (pop-to-buffer
	    (if (not arg) "*shell*"
	      (format "*s%d*" (prefix-numeric-value arg)))))))

(defun my-vterm-toggle (&optional arg)
  "Toggle vterm window number ARG."
  (interactive "P")
  (if (and (eq major-mode 'vterm-mode)
	   (not arg))
      (previous-buffer)
    (call-interactively #'vterm)))

;;; bindings
;;;; prefix maps
(keymap-global-set "C-x 4" #'other-window-prefix)
(keymap-global-set "C-x 5" #'other-frame-prefix)

;;;; global
(keymap-global-set "<f2>" #'my-shell-toggle)
(keymap-global-set "C-<f2>" #'my-shell-other-window)
(keymap-global-set "M-g l" #'imenu-list-smart-toggle)
(keymap-global-set "C-c a" #'org-agenda-list)
(keymap-global-set "C-c c" #'org-capture)
(keymap-global-set "C-;" (lambda nil (interactive) (switch-to-buffer nil)))
(if (or (daemonp) window-system)
    (progn (keymap-global-set "<f1>" #'my-vterm-toggle)
	   (keymap-global-set "C-<f1>" #'vterm-other-window)))

;;;; better defaults
(keymap-global-unset "C-x C-z")
(keymap-global-set "C-x f" #'find-file)
(keymap-global-set "C-x C-b" #'ibuffer)
(keymap-global-set "C-x k" #'kill-current-buffer)
(keymap-global-set "C-x K" #'kill-buffer)
(keymap-global-set "M-o" #'other-window-alternating)
(keymap-global-set "M-z" #'zap-up-to-char)
(keymap-global-set "M-/" #'hippie-expand)
(keymap-global-set "C-x l" #'count-words)
(keymap-global-set "C-x r m" #'bookmark-set-no-overwrite)
(keymap-global-set "C-x r M" #'bookmark-set)
(keymap-global-set "C-o" #'split-line)
(keymap-global-set "C-M-o" #'open-line)
(keymap-global-set "C-h C-m" #'man)
(keymap-global-set "C-x C-c" #'save-buffers-kill-emacs)
(keymap-global-set "<left>" #'windmove-left)
(keymap-global-set "<right>" #'windmove-right)
(keymap-global-set "<up>" #'windmove-up)
(keymap-global-set "<down>" #'windmove-down)
(keymap-global-set "C-x C-<left>" #'windmove-swap-states-left)
(keymap-global-set "C-x C-<right>" #'windmove-swap-states-right)
(keymap-global-set "C-x C-<up>" #'windmove-swap-states-up)
(keymap-global-set "C-x C-<down>" #'windmove-swap-states-down)

;;; org
;;;; general
(setq org-use-speed-commands t)
(setq org-startup-folded 'show2levels)
(setq org-agenda-files '("~/org/gtd.org" "~/org/inbox.org" "~/org/things.org"))
(setq org-modules '(org-habit ol-man ol-info))
(setq org-log-repeat nil)
(setq org-return-follows-link t)
(setq org-cycle-include-plain-lists 'integrate)
(setq org-capture-bookmark nil)
(setq org-archive-default-command nil)
(setq org-list-allow-alphabetical t)
(setq org-hierarchical-todo-statistics nil)
(setq org-refile-targets '((nil . (:maxlevel . 3))
			   (org-agenda-files . (:level . 1))))
(with-eval-after-load 'org
  (keymap-set org-mode-map "M-{" #'backward-paragraph)
  (keymap-set org-mode-map "M-}" #'forward-paragraph))

;;;; visual
(setq org-adapt-indentation nil)
(setq org-startup-with-inline-images t)
(setq org-image-actual-width 250)
(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'org-mode-hook #'ws-butler-mode)

;;;; org + latex
(setq org-latex-packages-alist
      '(("margin=2.5cm" "geometry" nil)
	("" "xcolor" nil)))
(setq org-latex-hyperref-template "\\hypersetup{
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

  (setq calendar-holidays (append holiday-solar-holidays
				  holiday-mexican-holidays
				  holiday-mexican-festivities)))
(setq org-agenda-include-diary t)

;;;; capture
(setq org-capture-templates
      '(("i" "Inbox")
	("ii" "Inbox" entry (file+headline "inbox.org" "Inbox")
	 "* %?\n")
	("iw" "Waiting" entry (file+headline "inbox.org" "Waiting")
	 "* %?\n")
	("id" "Ideas" entry (file+headline "inbox.org" "Ideas")
	 "* %?\n")
	("c" "Tasks" entry (file+headline "gtd.org" "Tasks")
         "* TODO %?\n")
	("h" "Homework" entry (file+headline "gtd.org" "Homework")
         "* TODO %?\n")
	("x" "Exams" entry (file+headline "gtd.org" "Exams")
         "* %?\n")
	("e" "Events" entry (file+headline "gtd.org" "Events")
         "* %?\n")
	("t" "Things" entry (file+headline "things.org" "Purchase")
	 "* TODO %?\n")))

;;;; babel
(setq org-confirm-babel-evaluate nil)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)
   (dot . t)))

;;; essentials
;;;; auth-source
(setq epg-pinentry-mode 'loopback)
(setq auth-sources '("~/.authinfo.gpg"))

;;;; dired
(setq dired-dwim-target t)
(setq dired-free-space nil)
(setq dired-listing-switches "-lhA")
(setq dired-vc-rename-file t)
(setq wdired-allow-to-change-permissions t)
(setq image-dired-thumbnail-storage 'standard-large)
(setq image-use-external-converter t)
(add-hook 'dired-mode-hook #'dired-hide-details-mode)
(with-eval-after-load 'dired
  (keymap-set dired-mode-map "C-M-o" #'dired-find-file-other-frame))

;;;; which-key
(setq which-key-idle-delay 0.5)
(setq which-key-idle-secondary-delay 0.05)
(which-key-mode)

;;;; comint
(setq comint-prompt-read-only t)
(setq ansi-color-for-comint-mode t)
(setq comint-input-ring-size 10000)
(add-hook 'comint-mode-hook #'electric-pair-local-mode)

;;;; shell
(setq shell-command-prompt-show-cwd t)
(bash-completion-setup)
(add-hook 'shell-mode-hook
	  (defun my-shell-history-hook ()
	    (setq comint-input-ring-file-name "~/.local/state/bash/history")
	    (comint-read-input-ring t)))

;; https://emacs.stackexchange.com/a/48307
(add-hook 'shell-mode-hook
	  (defun my-shell-exit-hook ()
	    "Custom `shell-mode' behaviours."
	    (let* ((proc (get-buffer-process (current-buffer)))
		   (sentinel (process-sentinel proc)))
	      (set-process-sentinel
	       proc
	       `(lambda (process signal)
		  (funcall #',sentinel process signal)
		  (and (memq (process-status process) '(exit signal))
		       (buffer-live-p (process-buffer process))
		       (kill-buffer (process-buffer process))))))))
(with-eval-after-load 'shell
  (keymap-set shell-mode-map "M-." #'comint-insert-previous-argument))

;;;; vterm
(setq vterm-max-scrollback 100000)
(with-eval-after-load 'vterm
  (keymap-set vterm-mode-map "<f1>" nil)
  (keymap-set vterm-mode-map "M-!" nil)
  (keymap-set vterm-mode-map "C-M-v" nil)
  (keymap-set vterm-mode-map "C-M-S-v" nil)
  (keymap-set vterm-mode-map "<f2>" nil)
  (keymap-set vterm-mode-map "<f11>" nil)
  (keymap-set vterm-mode-map "C-u" #'vterm--self-insert)
  (keymap-set vterm-mode-map "C-SPC" #'vterm-copy-mode)
  (keymap-set vterm-copy-mode-map "C-w" #'vterm-copy-mode-done)
  (keymap-set vterm-copy-mode-map "M-w" #'vterm-copy-mode-done))

;;;; outline-minor-mode
(setq outline-minor-mode-cycle t)

;;;; auctex
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq TeX-view-program-selection '((output-pdf "PDF Tools")))
(setq TeX-source-correlate-start-server t)
(setq LaTeX-default-environment "align*")
(setq preview-auto-cache-preamble t)
(setq-default TeX-output-dir "auctex")
(setq-default TeX-auto-local "auctex")
(add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)
(with-eval-after-load 'latex
  (keymap-set TeX-mode-map "C-c C-x C-l" #'my-preview-dwim))

;;;; pdf-tools
(if  (or (daemonp) window-system) (pdf-loader-install))
(setq pdf-view-resize-factor 1.1)
(setq pdf-view-continuous nil)
(add-hook 'pdf-view-mode-hook #'save-place-local-mode)
(add-hook 'pdf-annot-list-mode-hook #'pdf-annot-list-follow-minor-mode)
(with-eval-after-load 'pdf-tools
  (keymap-set pdf-view-mode-map "D" #'pdf-annot-delete)
  (keymap-set pdf-view-mode-map "M" #'pdf-view-midnight-minor-mode)
  (keymap-set pdf-view-mode-map "S" #'save-buffer)
  (keymap-set pdf-view-mode-map "L" #'pdf-annot-list-annotations)
  (keymap-set pdf-view-mode-map "T" #'pdf-annot-add-highlight-markup-annotation)
  (keymap-set pdf-view-mode-map "<prior>" #'pdf-view-scroll-down-or-previous-page)
  (keymap-set pdf-view-mode-map "<next>" #'pdf-view-scroll-up-or-next-page))
(with-eval-after-load 'pdf-annot
  (keymap-set pdf-annot-list-mode-map "RET" #'tablist-quit)
  (add-to-list 'pdf-annot-default-annotation-properties
	       '(highlight (color . "DarkSeaGreen1"))))

;;;; ibuffer
(with-eval-after-load 'ibuffer
  (keymap-set ibuffer-mode-map "* n" #'ibuffer-mark-common-buffers)
  (keymap-set ibuffer-mode-map "* w" #'ibuffer-mark-eww-buffers))

;;;; proced
(setq proced-auto-update-flag t)
(setq proced-auto-update-interval 1)
(setq proced-goal-attribute nil)
(setq proced-enable-color-flag t)
(with-eval-after-load 'proced
  (add-to-list 'proced-format-alist
	       '(custom user pid pcpu pmem rss state tree (args comm)))
  (setq-default proced-filter 'all)
  (setq-default proced-format 'custom))

;;;; calc
(setq calc-group-digits t)

;;;; irc
(setq rcirc-default-nick "icmor")
(setq rcirc-default-user-name "icmor")
(setq rcirc-server-alist
      '(("irc.libera.chat"
	 :port 6697
	 :encryption tls)))

;;; programming
;;;; general
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)
(add-hook 'prog-mode-hook #'electric-pair-local-mode)
(add-hook 'prog-mode-hook #'ws-butler-mode)

;;;; tree-sitter
;; https://github.com/mickeynp/combobulate
(setq treesit-language-source-alist
      '((bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
	(c . ("https://github.com/tree-sitter/tree-sitter-c"))
	(cpp . ("https://github.com/tree-sitter/tree-sitter-cpp"))
	(css . ("https://github.com/tree-sitter/tree-sitter-css"))
	(go . ("https://github.com/tree-sitter/tree-sitter-go"))
	(gomod . ("https://github.com/camdencheek/tree-sitter-go-mod"))
	(java . ("https://github.com/tree-sitter/tree-sitter-java"))
	(javascript . ("https://github.com/tree-sitter/tree-sitter-javascript"))
	(json . ("https://github.com/tree-sitter/tree-sitter-json"))
	(python . ("https://github.com/tree-sitter/tree-sitter-python"))))
(dolist (grammar treesit-language-source-alist)
	(unless (treesit-language-available-p (car grammar))
	  (treesit-install-language-grammar (car grammar))))
(dolist (mapping
         '((bash-mode . bash-ts-mode)
	   (c-mode . c-ts-mode)
	   (c++-mode . c++-ts-mode)
           (css-mode . css-ts-mode)
	   (java . java-ts-mode)
	   (javascript . js-ts-mode)
	   (json . json-ts-mode)
           (python-mode . python-ts-mode)))
  (add-to-list 'major-mode-remap-alist mapping))

;;;; project
(setq project-libs
      `((c-ts-mode . "/usr/include")
	(c++-mode . "/usr/include")
	(java-mode . "/usr/lib/jvm")
	(python-ts-mode . ,(car (file-expand-wildcards "/usr/lib/python3.??")))))
(setq project-kill-buffers-display-buffer-list t)
(keymap-set project-prefix-map "R" #'my-project-refresh)
(keymap-set  project-prefix-map "l" #'my-project-find-library)

;;;; xref
(setq xref-prompt-for-identifier nil)
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)

;;;; imenu-list
(setq imenu-list-focus-after-activation t)
(with-eval-after-load 'imenu-list
  (keymap-set imenu-list-major-mode-map "<tab>" #'hs-toggle-hiding))

;;;; gud
(setq gdb-default-window-configuration-file "~/.config/gdb/gdbwindows.el")
(setq gdb-debuginfod-enable-setting nil)
(setq gdb-many-windows t)
;; https://stackoverflow.com/a/24923325
(defadvice gdb-inferior-filter
    (around gdb-inferior-filter-without-stealing)
  (with-current-buffer (gdb-get-buffer-create 'gdb-inferior-io)
    (comint-output-filter proc string)))
(ad-activate 'gdb-inferior-filter)
(add-hook 'gdb-locals-mode-hook #'gdb-locals-values)

;;;; c
(defun my-set-c-compile-command ()
  (let ((file (file-relative-name buffer-file-name)))
    (setq-local compile-command
		(concat "gcc -Wall -g -o " (file-name-base file) " " file))))
(add-hook 'c-ts-mode-hook #'c-ts-mode-toggle-comment-style)
(add-hook 'c-ts-mode-hook #'my-set-c-compile-command)
(with-eval-after-load 'c-ts-mode
  (keymap-set c-ts-mode-map "C-c C-c" #'compile))

;;;; python
(defun my-set-python-compile-command ()
  (let* ((infile (file-relative-name buffer-file-name))
	 (outfile (string-remove-suffix ".c" infile)))
    (setq-local compile-command (concat "mypy --strict " infile))))
(setq python-indent 4)
(setq python-check-command "flake8 --color=never")
(add-hook 'pyvenv-post-activate-hooks #'pyvenv-mode)
(add-hook 'python-ts-mode-hook #'my-set-python-compile-command)
(add-hook 'python-ts-mode-hook (lambda nil (setq forward-sexp-function nil)))
;; disable new python 3.13 repl
;; https://docs.python.org/3/using/cmdline.html#envvar-PYTHON_BASIC_REPL
(setenv "PYTHON_BASIC_REPL" "1")

;;;; go
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-ts-mode))
(add-to-list 'auto-mode-alist '("/go\\.mod\\'" . go-mod-ts-mode))

;;;; racket
(with-eval-after-load 'racket-mode
  (keymap-set racket-repl-mode-map "C-c M-o"
	      #'racket-repl-clear-leaving-last-prompt))

;;;; html
(with-eval-after-load 'mhtml-mode
  (add-to-list 'html-tag-alist
	       '("html"
		 (n "<head>
" "<title>"
(setq str
      (read-string "Title: "))
"</title>
" "</head>
" "<body>
<h1>" str "</h1>
" _ "
" "</body>"))))

;;;; css
(with-eval-after-load 'css-mode
  (keymap-set css-mode-map "C-c C-l" #'list-colors-display))

;;;; json
(with-eval-after-load 'json (setq js-indent-level 2))

;;;; haskell
(setq haskell-process-suggest-remove-import-lines t)
(setq haskell-process-auto-import-loaded-modules t)
(setq haskell-interactive-popup-errors nil)
(with-eval-after-load 'haskell
  (keymap-set interactive-haskell-mode-map "C-c C-c" #'haskell-process-load-file))
(with-eval-after-load 'haskell-interactive-mode
  (keymap-set haskell-interactive-mode-map "C-c M-o" #'haskell-interactive-mode-clear))
(add-hook 'haskell-mode-hook #'interactive-haskell-mode)
(add-hook 'haskell-interactive-mode-hook #'electric-pair-local-mode)

;;;; java
(add-hook 'java-mode-hook #'subword-mode)

;;;; markdown
(setq markdown-fontify-code-blocks-natively t)
(setq markdown-command "pandoc --quiet -f gfm -s")
(add-hook 'markdown-mode-hook 'visual-line-mode)
(add-hook 'rst-mode-hook #'visual-line-mode)
(add-hook 'conf-mode-hook #'visual-line-mode)

;;;; proof-general
(setq proof-splash-enable nil)

;;;; man
(add-to-list 'display-buffer-alist
	     '("\\`\\*Man .*\\*\\'" .
	       (display-buffer-reuse-mode-window
		(inhibit-same-window . nil)
		(mode . Man-mode))))

;;; miscellaneous
;;;; better defaults
(setq show-paren-delay 0)
(setq show-paren-style 'mixed)
(setq show-paren-context-when-offscreen t)
(setq view-read-only t)
(setq use-short-answers t)
(setq server-client-instructions nil)
(setq find-file-suppress-same-file-warnings t)
(setq disabled-command-function nil)
(setq ring-bell-function 'ignore)
(setq pgtk-use-im-context-on-new-connection nil)
(global-so-long-mode)
(repeat-mode)
(winner-mode)

;;;; completion
(setq completions-detailed t)
(setq completion-auto-help 'visible)
(setq completions-format 'one-column)
(setq completion-ignore-case t)
(setq read-buffer-completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)
(setq completion-styles '(basic partial-completion substring))
(keymap-set minibuffer-mode-map "C-p" #'minibuffer-previous-completion)
(keymap-set minibuffer-mode-map "C-n" #'minibuffer-next-completion)
(keymap-set completion-in-region-mode-map "C-p" #'minibuffer-previous-completion)
(keymap-set completion-in-region-mode-map "C-n" #'minibuffer-next-completion)

;;;; wsl
(if (string-search "WSL2" (shell-command-to-string "uname -a"))
     (setq
      browse-url-generic-program  "/mnt/c/Windows/System32/cmd.exe"
      browse-url-generic-args '("/c" "start" "")
      browse-url-browser-function 'browse-url-generic))

;;;; files
(setq auto-save-default nil)
(setq backup-by-copying t)
(setq create-lockfiles nil)
(setq vc-follow-symlinks t)
(setq find-file-visit-truename t)
(setq delete-by-moving-to-trash t)

;;;; scrolling
(setq mouse-wheel-progressive-speed nil)
(pixel-scroll-precision-mode)

;;;; visual
(add-to-list 'default-frame-alist '(font . "Source Code Pro-14"))
(setq bookmark-set-fringe-mark nil)
(setq minions-mode-line-lighter "λ")
(load-theme 'modus-vivendi t)
(blink-cursor-mode -1)
(tooltip-mode -1)
(minions-mode)

;;;; bookmarks
(setq bookmark-save-flag 1)
(setq bookmark-search-size 8)

;;;; history
(setq history-length 1000)
(setq history-delete-duplicates t)
(savehist-mode)

;;;; documents
(setq doc-view-resolution 400)

;;;; text
(setq sentence-end-double-space nil)
(setq require-final-newline t)
(setq save-interprogram-paste-before-kill t)
(setq-default fill-column 80)
(set-default-coding-systems 'utf-8)

;;;; cookie
(setq cookie-file "~/org/cookie.org")
(setq initial-scratch-message
      (concat (replace-regexp-in-string
	       "^" ";; " (cookie cookie-file)) "\n\n"))
