;;; -*- lexical-binding: t; -*-
;;; packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(setq package-selected-packages
      '(
	avy
	auctex
	bash-completion
	dumb-jump
	ess
	gcmh
	haskell-mode
	hide-mode-line
	imenu-list
	magit
	markdown-mode
	minions
	no-littering
	pdf-tools
	proof-general
	pyvenv
	racket-mode
	rfc-mode
	saveplace-pdf-view
	transpose-frame
	vterm
	which-key
	ws-butler
	))

(package-install-selected-packages)
(if (daemonp) (mapc #'require package-selected-packages))

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

;;; general
(setq package-native-compile t)
(setq native-comp-async-report-warnings-errors 'silent)

;;;; doom hacks
(gcmh-mode)
(setq gcmh-idle-delay 'auto)
(setq gcmh-auto-idle-delay-factor 10)
(setq gcmh-high-cons-threshold (* 16 1024 1024))
(setq read-process-output-max (* 1024 1024))

;;;; functions
(defun dired-find-file-other-frame ()
  "In Dired, visit this file or directory in another frame"
  (interactive)
  (dired--find-file #'find-file-other-frame (dired-get-file-for-visit)))

(defun my-org-sort (level)
  "Sort org headlines alphabetically at level (default 1)"
  (interactive "P")
  (org-map-entries
   (lambda nil (org-sort-entries nil ?a))
   (concat "LEVEL=" (number-to-string (or level 1)))))

(defun my-pdf-save-position ()
  (interactive)
  (message "Position saved")
  (pdf-view-position-to-register ?x))

(defun my-pdf-jump-to-position ()
  (interactive)
  (pdf-view-jump-to-register ?x))

(defun my-project-find-library ()
  "Call project-switch-project on language-specific directory"
  (interactive)
  (let ((dir
	 (cdr (assq major-mode (if (boundp 'my-libs) my-libs nil)))))
    (if dir (project-switch-project dir))))

(defun my-project-refresh ()
  "Populate project--list"
  (interactive)
  (project-forget-zombie-projects)
  (project-remember-projects-under "~/dotfiles/")
  (project-remember-projects-under "~/Dropbox/code/" t)
  (project-remember-projects-under "~/Dropbox/universidad/" t))

(defun my-preview-dwim (&optional arg)
  "Preview latex in auctex buffers based on org-latex-preview"
  (interactive "P")
  (cond
   ((equal arg '(64))
    (preview-clearout-document))
   ((equal arg '(16))
    (preview-document))
   ((equal arg '(4))
    (preview-clearout-section))
   ((preview-at-point))))

(defun my-launch (command)
  "Launch external programs - taken from EXWM"
  (interactive (list (read-shell-command "$ ")))
  (start-process-shell-command command nil command))

(defun my-shell-toggle (&optional arg)
  "Toggle a shell window (with arg name it *s<arg>*)"
  (interactive "P")
  (if (and (eq major-mode 'shell-mode) (not arg))
      (previous-buffer)
    (shell (if (not arg) nil
	     (format "*s%d*" (prefix-numeric-value arg))))))

(defun my-shell-other-window (&optional arg)
  "Jump to a shell in other window (close current shell window)"
  (interactive "P")
  (if (and (eq major-mode 'shell-mode) (not arg))
      (delete-window)
    (shell (pop-to-buffer
	    (if (not arg) "*shell*"
	      (format "*s%d*" (prefix-numeric-value arg)))))))

(defun my-vterm-toggle (&optional arg)
  "Toggle a vterm window"
  (interactive "P")
  (if (and (eq major-mode 'vterm-mode)
	   (not arg))
      (previous-buffer)
    (call-interactively #'vterm)))

;;; bindings
;;;; global
(global-set-key (kbd "C-x g") #'magit)
(global-set-key (kbd "C-x M-g") #'magit-file-dispatch)
(global-set-key (kbd "<f2>") #'my-shell-toggle)
(global-set-key (kbd "C-<f2>") #'my-shell-other-window)
(global-set-key (kbd "C-c SPC") #'my-launch)
(global-set-key (kbd "C-c a") #'org-agenda-list)
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "M-o") 'avy-goto-char-timer)
(global-set-key (kbd "S-<f11>") #'hide-mode-line-mode)
(if (or (daemonp) window-system)
    (progn (global-set-key (kbd "<f1>") #'my-vterm-toggle)
	   (global-set-key (kbd "C-<f1>") #'vterm-other-window)))

;;;; better defaults
(global-unset-key (kbd "C-x C-z"))
(global-set-key (kbd "C-x f") #'find-file)
(global-set-key (kbd "C-x C-b") #'ibuffer)
(global-set-key (kbd "C-x k") #'kill-current-buffer)
(global-set-key (kbd "C-x K") #'kill-buffer)
(global-set-key (kbd "M-z") #'zap-up-to-char)
(global-set-key (kbd "C-x l") #'count-words)
(global-set-key (kbd "C-x r m") #'bookmark-set-no-overwrite)
(global-set-key (kbd "C-x r M") #'bookmark-set)
(global-set-key (kbd "C-o") #'split-line)
(global-set-key (kbd "C-M-o") #'open-line)
(global-set-key (kbd "C-h M-m") #'man)
(global-set-key (kbd "C-x C-c") #'save-buffers-kill-emacs)
(global-set-key (kbd "C-x C-<left>") #'windmove-swap-states-left)
(global-set-key (kbd "C-x C-<right>") #'windmove-swap-states-right)
(global-set-key (kbd "C-x C-<up>") #'windmove-swap-states-up)
(global-set-key (kbd "C-x C-<down>") #'windmove-swap-states-down)

;;; org
;;;; general
(setq org-agenda-files '("~/org/gtd.org" "~/org/inbox.org" "~/org/things.org"))
(setq org-modules '(ol-man ol-info))
(setq org-log-repeat nil)
(setq org-return-follows-link t)
(setq org-capture-bookmark nil)
(setq org-archive-default-command nil)
(setq org-list-allow-alphabetical t)
(setq org-hierarchical-todo-statistics nil)
(setq org-refile-targets '((nil . (:maxlevel . 3))
			   (org-agenda-files . (:level . 1))))

;;;; visual
(setq org-adapt-indentation nil)
(setq org-startup-with-inline-images t)
(setq org-image-actual-width 250)
(setq org-latex-inputenc-alist '(("utf8" . "utf8x")))
(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'org-mode-hook #'ws-butler-mode)

;;;; calendar
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
	 "* TODO %?\n")
	("j" "Journal" plain (file+olp+datetree "journal.org"))))

;;;; babel
(setq org-confirm-babel-evaluate nil)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (python . t)
   (dot . t)
   (C . t)))

;;; essentials
;;;; auth-source
(setq epg-pinentry-mode 'loopback)
(setq auth-sources '("~/.authinfo.gpg"))

;;;; dired
(setq dired-dwim-target t)
(setq dired-free-space nil)
(setq dired-listing-switches "-lhA")
(setq wdired-allow-to-change-permissions t)
(setq image-dired-thumbnail-storage 'standard-large)
(setq image-use-external-converter t)
(add-hook 'dired-mode-hook #'dired-hide-details-mode)
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-M-o") #'dired-find-file-other-frame)
  (define-key dired-mode-map (kbd "C-c f") #'find-dired))

;;;; which-key
(setq which-key-idle-delay 0.5)
(setq which-key-idle-secondary-delay 0.05)
(which-key-mode)

;;;; outline-minor-mode
(setq outline-minor-mode-cycle t)

;;;; avy
(setq avy-timeout-seconds 0.3)

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
	    (setq comint-input-ring-file-name "~/.bash_history")
	    (comint-read-input-ring t)))
(add-hook 'shell-mode-hook
	  (defun my-shell-exit-hook ()
	    "Custom `shell-mode' behaviours."
	    ;; Kill the buffer when the shell process exits.
	    (let* ((proc (get-buffer-process (current-buffer)))
		   (sentinel (process-sentinel proc)))
	      (set-process-sentinel
	       proc
	       `(lambda (process signal)
		  ;; Call the original process sentinel first.
		  (funcall #',sentinel process signal)
		  ;; Kill the buffer on an exit signal.
		  (and (memq (process-status process) '(exit signal))
		       (buffer-live-p (process-buffer process))
		       (kill-buffer (process-buffer process))))))))

;;;; vterm
(setq vterm-max-scrollback 100000)
(with-eval-after-load 'vterm
  (define-key vterm-mode-map [f1] nil)
  (define-key vterm-mode-map (kbd "M-!") nil)
  (define-key vterm-mode-map (kbd "C-M-v") nil)
  (define-key vterm-mode-map (kbd "C-S-M-v") nil)
  (define-key vterm-mode-map (kbd "<f2>") nil)
  (define-key vterm-mode-map (kbd "<f11>") nil)
  (define-key vterm-mode-map (kbd "C-u") #'vterm--self-insert)
  (define-key vterm-mode-map (kbd "C-SPC") #'vterm-copy-mode)
  (define-key vterm-copy-mode-map (kbd "C-w") #'vterm-copy-mode-done)
  (define-key vterm-copy-mode-map (kbd "M-w") #'vterm-copy-mode-done))

;;;; auctex
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq TeX-view-program-selection '((output-pdf "PDF Tools")))
(setq TeX-source-correlate-start-server t)
(setq LaTeX-default-environment "align*")
(setq preview-auto-cache-preamble t)
(setq-default TeX-output-dir "auctex")
(setq-default TeX-auto-local "auctex")
(with-eval-after-load 'preview
  (setq preview-scale-function
	(lambda nil (* 1.25 (funcall (preview-scale-from-face))))))
(add-hook 'TeX-mode-hook #'electric-pair-local-mode)
(add-hook 'TeX-after-compilation-finished-functions
          #'TeX-revert-document-buffer)
(with-eval-after-load 'latex
  (define-key TeX-mode-map (kbd "C-c C-x C-l") #'my-preview-dwim)
  (define-key LaTeX-mode-map (kbd "C-c C-e") #'latex-close-block))

;;;; pdf-tools
(if  (or (daemonp) window-system) (pdf-loader-install))
(setq pdf-view-resize-factor 1.1)
(setq pdf-view-continuous nil)
(add-hook 'pdf-view-mode-hook #'save-place-local-mode)
(add-hook 'pdf-annot-list-mode-hook #'pdf-annot-list-follow-minor-mode)
(with-eval-after-load 'pdf-tools
  (define-key pdf-view-mode-map (kbd "D") #'pdf-annot-delete)
  (define-key pdf-view-mode-map (kbd "M") #'pdf-view-midnight-minor-mode)
  (define-key pdf-view-mode-map (kbd "S") #'save-buffer)
  (define-key pdf-view-mode-map (kbd "T") #'pdf-annot-add-highlight-markup-annotation)
  (define-key pdf-view-mode-map (kbd "L") #'pdf-annot-list-annotations)
  (define-key pdf-view-mode-map (kbd "C-SPC") #'my-pdf-save-position)
  (define-key pdf-view-mode-map (kbd "C-U C-SPC") #'my-pdf-jump-to-position)
  (advice-add 'pdf-annot-list-annotations :before 'my-pdf-save-position)
  (advice-add 'pdf-outline :before 'my-pdf-save-position))
(with-eval-after-load 'pdf-annot
  (define-key pdf-annot-list-mode-map (kbd "RET") #'tablist-quit)
  (add-to-list 'pdf-annot-default-annotation-properties
	       '(highlight (color . "DarkSeaGreen1"))))

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
(setq my-libs
      `((c-ts-mode . "/usr/include")
	(c++-mode . "/usr/include")
	(java-mode . "/usr/lib/jvm")
	(python-ts-mode . ,(car (file-expand-wildcards "/usr/lib/python3.??")))))
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)
(add-hook 'prog-mode-hook #'electric-pair-local-mode)
(add-hook 'prog-mode-hook #'ws-butler-mode)

;;;; project
(setq project-kill-buffers-display-buffer-list t)
(add-to-list 'project-switch-commands '(project-shell "Shell") t)
(define-key project-prefix-map (kbd "R") #'my-project-refresh)
(define-key project-prefix-map (kbd "l") #'my-project-find-library)

;;;; tree-sitter
(setq treesit-language-source-alist
      '((bash . ("https://github.com/tree-sitter/tree-sitter-bash"))
	(c . ("https://github.com/tree-sitter/tree-sitter-c"))
	(cpp . ("https://github.com/tree-sitter/tree-sitter-cpp"))
	(css . ("https://github.com/tree-sitter/tree-sitter-css"))
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

;;;; xref
(setq xref-prompt-for-identifier nil)
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)

;;;; gud
;; https://stackoverflow.com/a/24923325
(defadvice gdb-inferior-filter
    (around gdb-inferior-filter-without-stealing)
  (with-current-buffer (gdb-get-buffer-create 'gdb-inferior-io)
    (comint-output-filter proc string)))
(ad-activate 'gdb-inferior-filter)
(add-hook 'gdb-locals-mode-hook #'gdb-locals-values)
(setq gdb-default-window-configuration-file "~/.config/gdb/gdbwindows.el")
(setq gdb-debuginfod-enable-setting nil)
(setq gdb-many-windows t)

;;;; c
(setq c-default-style
      '((java-ts-mode . "linux")
	(awk-mode . "awk")
	(c-ts-mode . "linux")
	(other . "gnu")))
(add-hook 'c-mode-hook #'c-toggle-comment-style)

;;;; python
(setq python-indent 4)
(setq python-check-command "flake8 --color=never")
(add-hook 'python-ts-mode-hook
	  (lambda nil
	    (setq-local compile-command (concat "mypy " buffer-file-name))))
(with-eval-after-load 'python
  (pyvenv-mode))

;;;; racket
(with-eval-after-load 'racket-mode
  (define-key racket-repl-mode-map (kbd "C-c M-o")
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
  (define-key css-mode-map (kbd "C-c C-l") #'list-colors-display))

;;;; json
(with-eval-after-load 'json
  (setq js-indent-level 2))

;;;; haskell
(setq haskell-process-type 'stack-ghci)
(setq haskell-process-suggest-remove-import-lines t)
(setq haskell-process-auto-import-loaded-modules t)
(setq haskell-process-log t)
(add-hook 'interactive-haskell-mode-hook #'electric-pair-local-mode)

;;;; java
(add-hook 'java-mode-hook #'subword-mode)

;;;;; asm
(setq asm-comment-char ?\#)

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

;;;; rfc
(add-to-list 'display-buffer-alist
	     '("\\`\\*rfc.*\\*\\'" .
	       (display-buffer-reuse-mode-window
		(inhibit-same-window . nil)
		(mode . rfc-mode))))
(with-eval-after-load 'rfc-mode
  (define-key rfc-mode-map (kbd "m") #'rfc-mode-browse))

;;; miscellaneous
;;;; better defaults
(setq show-paren-delay 0)
(setq show-paren-style 'mixed)
(setq show-paren-context-when-offscreen t)
(setq view-read-only t)
(setq use-short-answers t)
(setq find-file-suppress-same-file-warnings t)
(setq disabled-command-function nil)
(setq ring-bell-function 'ignore)
(setq dabbrev-check-all-buffers nil)
(global-so-long-mode)
(repeat-mode)
(winner-mode)

;;;; minibuffer completion
(setq completions-detailed t)
(setq completions-format 'one-column)
(setq read-buffer-completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)
(setq completion-styles '(basic partial-completion substring))
(define-key minibuffer-mode-map (kbd "C-p") #'minibuffer-previous-completion)
(define-key minibuffer-mode-map (kbd "C-n") #'minibuffer-next-completion)

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
