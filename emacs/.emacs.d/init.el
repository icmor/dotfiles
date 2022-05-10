;;; -*- lexical-binding: t; -*-
;;; packages
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)

;;;; package list
(setq package-selected-packages
      '(
	avy
	bash-completion
	;; eglot
	gcmh
	hide-mode-line
	imenu-list
	;; lsp-mode
	;; lsp-java
	magit
	markdown-mode
	minions
	no-littering
	org-contrib
	org-roam
	pdf-tools
	racket-mode
	rfc-mode
	transpose-frame
	tree-sitter
	tree-sitter-langs
	vterm
	which-key
	ws-butler
	))
(package-install-selected-packages)
;; (setq package-native-compile t)

;;;; litter
(require 'no-littering)
(setq custom-file (no-littering-expand-etc-file-name "custom.el"))
(setq auto-save-list-file-prefix
      (no-littering-expand-var-file-name "auto-save-list/.saves-"))
(setq backup-directory-alist
      `((".*" . ,(no-littering-expand-var-file-name "backup"))))
(setq tramp-backup-directory-alist backup-directory-alist)
(setq version-control t)
(setq kept-new-versions 4)
(setq kept-old-versions 2)
(setq delete-old-versions t)
;; (load custom-file t)

;;; general
(setq find-function-C-source-directory
      "/home/pink/.cache/yay/emacs-git/src/emacs-git/src")
(setq native-comp-async-report-warnings-errors 'silent)

;;;; doom hacks
(gcmh-mode)
(setq gcmh-idle-delay 'auto
      gcmh-auto-idle-delay-factor 10
      gcmh-high-cons-threshold (* 16 1024 1024))
(setq read-process-output-max (* 1024 1024))
(setq auto-mode-case-fold nil)

;;;; functions
(defun my/shell-toggle (arg)
  "Toggle a shell window"
  (interactive "P")
  (if (and (eq major-mode 'shell-mode) (not arg))
      (previous-buffer)
    (shell (if (not arg) nil
	     (format "*s%d*" (prefix-numeric-value arg))))))

(defun my/shell-other-window (arg)
  "Jump to a shell in other window"
  (interactive "P")
    (if (and (eq major-mode 'shell-mode) (not arg))
      (delete-window)
      (shell (pop-to-buffer
	      (if (not arg) "*shell*"
		(format "*s%d*" (prefix-numeric-value arg)))))))

(defun my/vterm-toggle (arg)
  "Toggle a vterm window"
  (interactive "P")
  (if (and (eq major-mode 'vterm-mode)
	   (not arg))
      (previous-buffer)
    (call-interactively #'vterm)))

(defun my/project-stdlibs ()
  (interactive)
  (let ((dir
	 (cdr (assq major-mode (if (boundp 'stdlibs) stdlibs nil)))))
    (if dir (project-switch-project dir))))

(defun my/org-sort (arg)
  (interactive "P")
  (org-map-entries
   (lambda () (org-sort-entries nil ?a))
   (concat "LEVEL=" (number-to-string (or arg 1)))))

(defun dired-find-file-other-frame ()
  "In Dired, visit this file or directory in another frame."
  (interactive)
  (dired--find-file #'find-file-other-frame (dired-get-file-for-visit)))

;;; bindings
;;;; prefix maps
(define-prefix-command 'km/roam)
(global-set-key (kbd "C-c n") 'km/roam)

;;;; global
(global-set-key (kbd "<f2>") #'my/vterm-toggle)
(global-set-key (kbd "C-<f2>") #'vterm-other-window)
(global-set-key (kbd "C-x p l") #'my/project-stdlibs)
(global-set-key (kbd "M-o") 'avy-goto-char-timer)
(global-set-key (kbd "S-<f11>") #'hide-mode-line-mode)
(global-set-key (kbd "C-h C-m") #'man)	; same as C-h RET

;;;; better defaults
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

;;;; org
(global-set-key (kbd "C-c a") #'org-agenda-list)
(global-set-key (kbd "C-c c") #'org-capture)

;;; terminal vs gui
(if (or (daemonp) (display-graphic-p))
    (global-unset-key (kbd "C-z"))
  (progn
    (global-set-key (kbd "<f2>") #'my/shell-toggle)
    (global-set-key (kbd "C-<f2>") #'my/shell-other-window)))

;;; org-mode
;;;; general
(setq org-directory "~/org/")
(setq org-agenda-files '("~/org/gtd/"))
(setq org-preview-latex-image-directory
      (no-littering-expand-var-file-name "ltximg/"))
(setq org-modules '(ol-man ol-info org-habit))
(setq org-log-into-drawer t)
(setq org-return-follows-link t)
(setq org-capture-bookmark nil)
(setq org-list-allow-alphabetical t)
(setq org-refile-targets '((nil . (:maxlevel . 3))
			   (org-agenda-files . (:level . 1))))

;;;; visual
(add-hook 'org-mode-hook #'visual-line-mode)
(add-hook 'org-mode-hook #'ws-butler-mode)
(setq org-adapt-indentation nil)
(add-hook 'org-mode-hook (lambda () (setq fill-column 100)))
(setq org-startup-with-inline-images t)
(setq org-image-actual-width 250)
(setq org-latex-inputenc-alist '(("utf8" . "utf8x")))
(with-eval-after-load 'org
  (setq org-format-latex-options
	(plist-put org-format-latex-options :scale 1.5)))

;;;; capture
(setq org-capture-templates
      '(("t" "Tasks" entry (file+headline "gtd/gtd.org" "Tasks")
         "* TODO %?\n")
	("h" "Homework" entry (file+headline "gtd/gtd.org" "Homework")
         "* TODO %?\n")
	("e" "Events" entry (file+headline "gtd/gtd.org" "Events")
         "* TODO %?\n")
	("i" "Inbox" entry (file+headline "gtd/inbox.org" "Inbox")
	 "* TODO %?\n")
	("d" "Ideas" entry (file+headline "gtd/inbox.org" "Ideas")
	 "* %?\n")
	("b" "Buy" entry (file+headline "gtd/purchase.org" "Things")
	 "* TODO %?\n")
	("c" "Programs" entry (file+headline "gtd/projects.org" "Program Ideas")
	 "* %?\n")
	("p" "Projects" entry (file+headline "gtd/projects.org" "Projects")
	 "* %?\n")
	("j" "Journal" plain (file+olp+datetree "life/journal.org.gpg")
	 "%?")
	("u" "Quotes" plain (file "art/quotes.txt")
	 "%?\n%")))

;;;; org-roam
(setq org-roam-directory (file-truename "~/roam"))
(with-eval-after-load 'org-roam-mode
  (org-roam-db-autosync-enable))
(define-key km/roam (kbd "a") #'org-roam-alias-add)
(define-key km/roam (kbd "c") #'org-roam-capture)
(define-key km/roam (kbd "f") #'org-roam-node-find)
(define-key km/roam (kbd "g") #'org-roam-graph)
(define-key km/roam (kbd "i") #'org-roam-node-insert)
(define-key km/roam (kbd "l") #'org-roam-buffer-toggle)

(setq org-roam-capture-templates
      '(("d" "default" plain "%?" :target
	 (file+head "${slug}.org" "#+title: ${title}")
	 :unnarrowed t)))
(setq org-roam-node-display-template "${title}")

;;; essentials
;;;; security
(setq auth-sources '("~/.authinfo.gpg"))

;;;; dired
(setq dired-dwim-target t)
(setq dired-free-space nil)
(setq dired-hide-details-hide-symlink-targets nil)
(setq wdired-allow-to-change-permissions t)
(setq dired-listing-switches "-lhA")
(setq image-dired-thumbnail-storage 'standard-x-large)
(add-hook 'dired-mode-hook #'dired-hide-details-mode)
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-M-o") #'dired-find-file-other-frame)
  (define-key dired-mode-map (kbd "C-c f") #'find-dired))

;;;; which-key
(setq which-key-idle-delay 0.5)
(setq which-key-idle-secondary-delay 0.05)
(which-key-mode)

;;;; avy
(setq avy-timeout-seconds 0.2)

;;;; comint
(setq comint-prompt-read-only t)

;;;; shell
(setq shell-command-prompt-show-cwd t)
(setq ansi-color-for-comint-mode t)
(bash-completion-setup)

;;;; vterm
(setq vterm-max-scrollback 10000)
(with-eval-after-load 'vterm
  (define-key vterm-mode-map [f2] nil)
  (define-key vterm-mode-map (kbd "C-M-v") nil)
  (define-key vterm-mode-map (kbd "C-S-M-v") nil)
  (define-key vterm-mode-map (kbd "C-u") #'vterm--self-insert)
  (define-key vterm-mode-map (kbd "C-{") #'vterm--self-insert)
  (define-key vterm-mode-map (kbd "C-SPC") #'vterm-copy-mode)
  (define-key vterm-copy-mode-map (kbd "C-c C-c") #'vterm-copy-mode-done)
  (define-key vterm-copy-mode-map (kbd "C-w") #'vterm-copy-mode-done)
  (define-key vterm-copy-mode-map (kbd "M-w") #'vterm-copy-mode-done))

;;;; magit
(global-set-key (kbd "C-x g") #'magit)
(global-set-key (kbd "C-x M-g") #'magit-file-dispatch)

;;;; pdf-tools
(pdf-loader-install)
(setq pdf-view-continuous nil)
(setq pdf-view-resize-factor 1.1)

;;;; mail
(setq user-full-name "Iñaki Cornejo")
(setq user-mail-address "cornejodlm@ciencias.unam.mx")
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

;;;; calc
;; (setq calc-prefer-frac t)

;;;; eww
(setq eww-search-prefix "https://www.google.com/search?q=")

;;; programming
;;;; general
(global-tree-sitter-mode)
(show-paren-mode)
(setq show-paren-delay 0)
(setq show-paren-style 'mixed)
(setq show-paren-context-when-offscreen t)
(setq outline-minor-mode-cycle t)
(add-hook 'prog-mode-hook #'electric-pair-local-mode)
(add-hook 'prog-mode-hook #'ws-butler-mode)

;;;; stdlibs
(setq stdlibs '((c-mode . "/usr/include")
		   (python-mode . "/usr/lib/python3.10/")
		   (java-mode . "~/.local/opt/jdk11")))

;;;; eglot
;; (setq eglot-events-buffer-size 0)
;; (setq eglot-autoshutdown t)

;;;; elisp
(add-hook 'emacs-lisp-mode-hook #'outline-minor-mode)

;;;; c
(setq c-default-style
      '((java-mode . "linux")
	(awk-mode . "awk")
	(c-mode . "linux")
	(other . "gnu")))

;;;; python
(setq python-indent 4)

;;;; java
;; (add-hook 'java-mode-hook (lambda () (if (not buffer-read-only) (eglot-ensure))))
(add-hook 'java-mode-hook #'subword-mode)
(add-to-list 'exec-path (file-truename "~/.emacs.d/var/jdtls/bin") t)

;;;; markdown
(setq markdown-fontify-code-blocks-natively t)
(add-hook 'markdown-mode-hook 'visual-line-mode)
(add-hook 'rst-mode-hook 'visual-line-mode)
(add-hook 'conf-mode-hook 'visual-line-mode)

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
(setq ring-bell-function 'ignore)
(setq disabled-command-function nil)
(setq read-buffer-completion-ignore-case t)
(setq completions-format 'one-column)
(setq dabbrev-check-all-buffers nil)

;;;; files
(setq auto-save-default nil)
(setq backup-by-copying t)
(setq create-lockfiles nil)
(setq vc-follow-symlinks nil)
(setq delete-by-moving-to-trash t)

;;;; visual
(add-to-list 'default-frame-alist
	     '(font . "Source Code Pro-14"))
(load-theme 'modus-vivendi t)
(setq bookmark-set-fringe-mark nil)
(blink-cursor-mode -1)
(tooltip-mode -1)
(minions-mode)
(setq minions-mode-line-lighter "λ")

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

;;;; etc
(setq initial-scratch-message
      (concat (replace-regexp-in-string "^" ";; " (cookie "~/org/art/quotes.txt"))
       "\n\n"))

;;; attic
;; (global-set-key (kbd "C-<next>") #'tab-next)
;; (global-set-key (kbd "C-<prior>") #'tab-previous)
;; (set-face-attribute 'mode-line-active nil :inherit 'mode-line)
;; (set-face-attribute 'mode-line-inactive nil :inherit 'mode-line)
