;;; -*- lexical-binding: t; -*-
;;; packages
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;;;; package list
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
	org-contrib
	org-roam
	pdf-tools
	proof-general
	pyvenv
	racket-mode
	rfc-mode
	transpose-frame
	vterm
	which-key
	ws-butler
	))
(package-install-selected-packages)

;;;; litter
(require 'no-littering)
(setq custom-file (no-littering-expand-etc-file-name "custom.el"))
(setq auto-save-list-file-prefix
      (no-littering-expand-var-file-name "auto-save-list/.saves-"))
(setq backup-directory-alist
      `((".*" . ,(no-littering-expand-var-file-name "backup"))))
(setq org-preview-latex-image-directory
      (no-littering-expand-var-file-name "ltximg/"))
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
(setq auto-mode-case-fold nil)

;;;; functions
(defun my-shell-toggle (arg)
  "Toggle a shell window"
  (interactive "P")
  (if (and (eq major-mode 'shell-mode) (not arg))
      (previous-buffer)
    (shell (if (not arg) nil
	     (format "*s%d*" (prefix-numeric-value arg))))))

(defun my-shell-other-window (arg)
  "Jump to a shell in other window"
  (interactive "P")
  (if (and (eq major-mode 'shell-mode) (not arg))
      (delete-window)
    (shell (pop-to-buffer
	    (if (not arg) "*shell*"
	      (format "*s%d*" (prefix-numeric-value arg)))))))

(defun my-vterm-toggle (arg)
  "Toggle a vterm window"
  (interactive "P")
  (if (and (eq major-mode 'vterm-mode)
	   (not arg))
      (previous-buffer)
    (call-interactively #'vterm)))

(defun my-project-find-library ()
  (interactive)
  (let ((dir
	 (cdr (assq major-mode (if (boundp 'my-libs) my-libs nil)))))
    (if dir (project-switch-project dir))))

(defun my-project-refresh ()
  (interactive)
  (progn
    (project-forget-zombie-projects)
    (project-remember-projects-under "~/Dropbox" t)
    (project-remember-projects-under "~/dotfiles/")))

(defun my-org-sort (arg)
  (interactive "P")
  (org-map-entries
   (lambda () (org-sort-entries nil ?a))
   (concat "LEVEL=" (number-to-string (or arg 1)))))

(defun dired-find-file-other-frame ()
  "In Dired, visit this file or directory in another frame."
  (interactive)
  (dired--find-file #'find-file-other-frame (dired-get-file-for-visit)))

(defun my-preview-dwim (arg)
  "Preview latex based on org-latex-preview"
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
  (interactive (list (read-shell-command "$ ")))
  (start-process-shell-command command nil command))

;;; bindings
;;;; prefix maps
(define-prefix-command #'my-km-roam)
(global-set-key (kbd "C-c n") #'my-km-roam)

;;;; global
(global-set-key (kbd "C-c SPC") #'my-launch)
(global-set-key (kbd "M-o") 'avy-goto-char-timer)
(global-set-key (kbd "S-<f11>") #'hide-mode-line-mode)
(global-set-key (kbd "C-h C-m") #'man)	; same as C-h RET
(global-set-key (kbd "<f2>") #'my-shell-toggle)
(global-set-key (kbd "C-<f2>") #'my-shell-other-window)

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
(global-set-key (kbd "C-x C-c") #'save-buffers-kill-emacs)
(global-set-key (kbd "C-x C-<left>") #'windmove-swap-states-left)
(global-set-key (kbd "C-x C-<right>") #'windmove-swap-states-right)
(global-set-key (kbd "C-x C-<up>") #'windmove-swap-states-up)
(global-set-key (kbd "C-x C-<down>") #'windmove-swap-states-down)

;;;; terminal vs gui
(if (or (daemonp) window-system)
    (progn
      (global-set-key (kbd "<f1>") #'my-vterm-toggle)
      (global-set-key (kbd "C-<f1>") #'vterm-other-window)
      (pdf-loader-install)))

;;; org
(global-set-key (kbd "C-c a") #'org-agenda-list)
(global-set-key (kbd "C-c c") #'org-capture)

;;;; general
(setq org-agenda-files '("~/org/gtd.org"
			 "~/org/inbox.org"
			 "~/org/things.org"))
(setq org-clock-sound "/opt/zoom/sip/ring_pstn.wav")
(setq org-modules '(ol-man ol-info org-habit))
(setq org-log-repeat nil)
(setq org-return-follows-link t)
(setq org-capture-bookmark nil)
(setq org-archive-default-command nil)
(setq org-list-allow-alphabetical t)
(setq org-habit-preceding-days 30)
(setq org-hierarchical-todo-statistics nil)
(setq org-refile-targets '((nil . (:maxlevel . 3))
			   (org-agenda-files . (:level . 1))))

;;;; visual
(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'org-mode-hook #'ws-butler-mode)
(setq org-adapt-indentation nil)
(setq org-startup-with-inline-images t)
(setq org-image-actual-width 250)
(setq org-latex-inputenc-alist '(("utf8" . "utf8x")))

;;;; org + latex
(with-eval-after-load 'org
  (setq org-format-latex-options
	(plist-put org-format-latex-options :scale 1.5))
  (define-key org-mode-map (kbd "$") #'TeX-insert-dollar)
  (define-key org-mode-map (kbd "C-c ~") #'LaTeX-math-mode)
  (define-key org-mode-map (kbd "C-c [") #'LaTeX-environment))
(autoload #'TeX-insert-dollar "tex")
(autoload #'LaTeX-math-mode "latex")
(autoload #'LaTeX-environment "latex")

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
	("t" "Buy" entry (file+headline "things.org" "Purchase")
	 "* TODO %?\n")))

;;;; babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (dot . t)
   (python . t)
   (C . t)))

(setq org-confirm-babel-evaluate nil)

;;;; org-roam
(setq org-roam-directory (file-truename "~/roam"))
(with-eval-after-load 'org-roam-mode (org-roam-db-autosync-enable))
(define-key my-km-roam (kbd "a") #'org-roam-alias-add)
(define-key my-km-roam (kbd "c") #'org-roam-capture)
(define-key my-km-roam (kbd "f") #'org-roam-node-find)
(define-key my-km-roam (kbd "g") #'org-roam-graph)
(define-key my-km-roam (kbd "i") #'org-roam-node-insert)
(define-key my-km-roam (kbd "l") #'org-roam-buffer-toggle)
(define-key my-km-roam (kbd "n") #'org-roam-db-sync)
(define-key my-km-roam (kbd "p") #'(lambda () (interactive)
				     (ido-find-file-in-dir "~/roam/textbooks")))

(setq org-roam-capture-templates
      '(("d" "default" plain "%?" :target
	 (file+head "${slug}.org" "#+title: ${title}")
	 :unnarrowed t)))
(setq org-roam-node-display-template "${title}")

;;; essentials
;;;; auth-source
(setq epg-pinentry-mode 'loopback)
(setq auth-sources '("~/.authinfo.gpg"))

;;;; dired
(setq dired-dwim-target t)
(setq dired-free-space nil)
(setq wdired-allow-to-change-permissions t)
(setq dired-listing-switches "-lhA")
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
(add-hook 'comint-mode-hook #'electric-pair-local-mode)

;;;; shell
(setq shell-command-prompt-show-cwd t)
(setq ansi-color-for-comint-mode t)
(setq comint-input-ring-size 10000)
(bash-completion-setup)
(add-hook 'shell-mode-hook
	  (defun my-shell-mode-hook ()
	    (setq comint-input-ring-file-name "~/.bash_history")
	    (comint-read-input-ring t)))
(add-hook 'shell-mode-hook
	  (defun my-shell-mode-hook ()
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
  (define-key vterm-mode-map (kbd "C-{") #'vterm--self-insert)
  (define-key vterm-mode-map (kbd "C-SPC") #'vterm-copy-mode)
  (define-key vterm-copy-mode-map (kbd "C-w") #'vterm-copy-mode-done)
  (define-key vterm-copy-mode-map (kbd "M-w") #'vterm-copy-mode-done))

;;;; magit
(global-set-key (kbd "C-x g") #'magit)
(global-set-key (kbd "C-x M-g") #'magit-file-dispatch)

;;;; auctex
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq TeX-output-dir "auctex")
(setq TeX-auto-local "auctex")
(setq TeX-view-program-selection '((output-pdf "PDF Tools")))
(setq TeX-source-correlate-start-server t)
(setq TeX-electric-math '("\\(" . "\\)"))
(setq LaTeX-default-environment "align*")
(add-hook 'TeX-after-compilation-finished-functions
          #'TeX-revert-document-buffer)
(with-eval-after-load 'tex
  (define-key TeX-mode-map (kbd "C-c [") #'LaTeX-environment)
  (define-key TeX-mode-map (kbd "C-c C-x C-l") #'my-preview-dwim))
(with-eval-after-load 'latex
    (define-key LaTeX-mode-map (kbd "C-c C-e") #'latex-close-block))


;;;; pdf-tools
(setq pdf-view-continuous nil)
(setq pdf-view-resize-factor 1.1)
(with-eval-after-load 'pdf-tools
    (define-key pdf-view-mode-map  (kbd "M") #'pdf-view-midnight-minor-mode))

;;;; calc
(setq calc-group-digits t)

;;;; mail
(setq user-full-name "Iñaki Cornejo")
(setq user-mail-address "icornejomora@gmail.com")
(setq message-send-mail-function 'smtpmail-send-it)
(with-eval-after-load 'message
  (require 'smtpmail)
  (setq smtpmail-smtp-server "smtp.gmail.com")
  (setq smtpmail-stream-type 'starttls)
  (setq smtpmail-smtp-service 587)
  (setq starttls-use-gnutls t))

;;;; irc
(setq rcirc-default-nick "icmor")
(setq rcirc-default-user-name "icmor")
(setq rcirc-server-alist
      '(("irc.libera.chat"
	 :port 6697
	 :encryption tls)))

;;;; eww
(setq eww-search-prefix "https://www.google.com/search?q=")

;;; programming
;;;; general
(setq show-paren-delay 0)
(setq show-paren-style 'mixed)
(setq show-paren-context-when-offscreen t)
(add-hook 'prog-mode-hook #'electric-pair-local-mode)
(add-hook 'prog-mode-hook #'ws-butler-mode)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;;;; project
(setq project-kill-buffers-display-buffer-list t)
(setq my-libs '((c-ts-mode . "/usr/include/")
		(python-ts-mode . "/usr/lib/python3.10/")))
(define-key project-prefix-map (kbd "R") #'my-project-refresh)
(define-key project-prefix-map (kbd "l") #'my-project-find-library)

;;;; tree-sitter
(when (treesit-ready-p 'python t)
  (add-to-list 'major-mode-remap-alist '(python-mode . python-ts-mode)))
(when (treesit-ready-p 'bash t)
  (add-to-list 'major-mode-remap-alist '(sh-mode . bash-ts-mode)))
(when (treesit-ready-p 'c t)
  (add-to-list 'major-mode-remap-alist '(c-mode . c-ts-mode)))

;;;; xref
(setq xref-prompt-for-identifier nil)
(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)

;;;; c
(setq c-default-style
      '((java-mode . "linux")
	(awk-mode . "awk")
	(c-ts-mode . "linux")
	(other . "gnu")))

;;;; python
(setq python-indent 4)
(setq python-check-command "flake8 --color=never")
(with-eval-after-load 'python
  (pyvenv-mode))

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
(repeat-mode)
(winner-mode)
(global-so-long-mode)
(setq view-read-only t)
(setq completions-detailed t)
(setq use-short-answers t)
(setq find-file-suppress-same-file-warnings t)
(setq disabled-command-function nil)
(setq read-buffer-completion-ignore-case t)
(setq ring-bell-function 'ignore)
(setq completions-format 'one-column)
(setq dabbrev-check-all-buffers nil)

;;;; files
(setq auto-save-default nil)
(setq backup-by-copying t)
(setq create-lockfiles nil)
(setq vc-follow-symlinks t)
(setq find-file-visit-truename t)
(setq delete-by-moving-to-trash t)

;;;; scrolling
(pixel-scroll-precision-mode)
(setq mouse-wheel-progressive-speed nil)

;;;; visual
(add-to-list 'default-frame-alist
	     '(font . "Source Code Pro-14"))
(load-theme 'modus-vivendi t)
(setq bookmark-set-fringe-mark nil)
(setq minions-mode-line-lighter "λ")
(blink-cursor-mode -1)
(tooltip-mode -1)
(minions-mode)

;;;; bookmarks
(setq bookmark-save-flag 1)
(setq bookmark-search-size 8)

;;;; history
(savehist-mode)
(setq history-length 1000)
(setq history-delete-duplicates t)

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

;;; attic
;; (global-set-key (kbd "C-<next>") #'tab-next)
;; (global-set-key (kbd "C-<prior>") #'tab-previous)
;; (load custom-file t)
;; (setq calc-prefer-frac t)
;; (add-hook 'emacs-lisp-mode-hook #'outline-minor-mode)
;; (setq dired-hide-details-hide-symlink-targets nil)
;; (show-paren-mode)
