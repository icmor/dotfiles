;;; -*- lexical-binding: t; -*-

;;; init.el --- icmor's Emacs
;;;; Commentary
;; Got inspired to start a new Emacs journey based on the
;; philosophy of Protesilaos Stavrou. Basically, put in
;; the effort to discover Emacs the "Emacs Way". Sacrificing
;; temporary convenience in exchange of really learning
;; the tools I use and achieving autonomy through power,
;; knowledge and humility.

;;; no littering
;;;; general
(setq user-var-dir (concat user-emacs-directory "var/"))
(setq user-etc-dir (concat user-emacs-directory "etc/"))
(setq source-directory "/home/pink/.cache/yay/emacs-git/src/emacs-git/src")

;;;; backups and auto-save files
(setq auto-save-list-file-prefix (concat user-var-dir "auto-save-list/.saves-"))
(setq backup-directory-alist `((".*" . ,(concat user-var-dir "backup"))))
(setq tramp-backup-directory-alist backup-directory-alist)
(setq version-control t)
(setq kept-new-versions 4)
(setq kept-old-versions 2)
(setq delete-old-versions t)

;;;; litter
(setq bookmark-default-file		(concat user-var-dir "bookmark-default.el"))
(setq custom-file			(concat user-etc-dir "custom.el"))
(setq eshell-directory-name		(concat user-var-dir "eshell/"))
(setq multisession-directory            (concat user-var-dir "multisession/"))
(setq nsm-settings-file                 (concat user-var-dir "network-security.data"))
(setq org-id-locations-file             (concat user-var-dir "org-id-locations"))
(setq org-preview-latex-image-directory (concat user-var-dir "ltximg/"))
(setq org-roam-db-location 		(concat user-var-dir "org-roam.db"))
(setq project-list-file			(concat user-var-dir "projects"))
(setq racket-repl-history-directory     (concat user-var-dir "racket-mode"))
(setq rfc-mode-directory 		(concat user-var-dir "rfc"))
(setq savehist-file			(concat user-var-dir "savehist"))
(setq speed-type-gb-dir			(concat user-var-dir "speed-type/"))
(setq tramp-persistency-file-name	(concat user-var-dir "tramp/persistency.el"))
(setq transient-history-file		(concat user-var-dir "transient/history.el"))
(setq transient-levels-file		(concat user-etc-dir "transient/levels.el"))
(setq transient-values-file		(concat user-etc-dir "transient/values.el"))
(setq url-cache-directory		(concat user-var-dir "url/cache/"))
(setq url-configuration-directory	(concat user-var-dir "url/configuration/"))

(load custom-file t)

;;; package configuration
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)
(setq package-native-compile t)
(package-install-selected-packages)

;;; functions
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

(defun my/org-sort (arg)
  (interactive "P")
  (org-map-entries
   (lambda () (org-sort-entries nil ?a))
   (concat "LEVEL=" (number-to-string (or arg 1)))))

(defun dired-find-file-other-frame ()
  "In Dired, visit this file or directory in another frame."
  (interactive)
  (dired--find-file #'find-file-other-frame (dired-get-file-for-visit)))

(defun advise-once (symbol where function &optional props)
  (advice-add symbol :after (lambda (&rest _) (advice-remove symbol function)))
  (advice-add symbol where function props))

;;;; doom hacks
(gcmh-mode)
(setq gcmh-idle-delay 'auto
      gcmh-auto-idle-delay-factor 10
      gcmh-high-cons-threshold (* 16 1024 1024))
(setq read-process-output-max (* 1024 1024))
(setq auto-mode-case-fold nil)

;;; global bindings
(global-set-key (kbd "<f2>") #'my/vterm-toggle)
(global-set-key (kbd "C-<f2>") #'vterm-other-window)
(global-set-key (kbd "S-<f11>") #'hide-mode-line-mode)
(global-set-key (kbd "C-h C-m") #'man)	; same as C-h RET
(global-set-key (kbd "C-x C-c") #'save-buffers-kill-emacs)
(global-set-key (kbd "C-x C-<left>") #'windmove-swap-states-left)
(global-set-key (kbd "C-x C-<right>") #'windmove-swap-states-right)
(global-set-key (kbd "C-x C-<up>") #'windmove-swap-states-up)
(global-set-key (kbd "C-x C-<down>") #'windmove-swap-states-down)

;;;; better defaults
(global-unset-key (kbd "C-z"))
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

;;; org-mode
;;;; general
(setq org-directory "~/org/")
(setq org-agenda-files '("~/org/gtd/"))
(setq org-modules '(ol-man ol-info org-habit))

(setq org-refile-targets '((nil . (:maxlevel . 3))
			   (org-agenda-files . (:level . 1))))
(setq org-log-into-drawer t)
(setq org-return-follows-link t)
(setq org-capture-bookmark nil)
(setq org-list-allow-alphabetical t)

;;;; visual
(add-hook 'org-mode-hook 'visual-line-mode)
(setq org-adapt-indentation nil)
(add-hook 'org-mode-hook (lambda () (setq fill-column 100)))
(setq org-startup-with-inline-images t)
(setq org-image-actual-width 250)
(setq org-latex-inputenc-alist '(("utf8" . "utf8x")))
(with-eval-after-load 'org
  (setq org-format-latex-options
	(plist-put org-format-latex-options :scale 1.5)))

;;;; agenda
(global-set-key (kbd "C-c a") #'org-agenda-list)
(global-set-key (kbd "C-c c") #'org-capture)

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
(setq org-roam-node-display-template "${title}")
(global-set-key (kbd "C-c n f") #'org-roam-node-find)
(global-set-key (kbd "C-c n l") #'org-roam-buffer-toggle)
(global-set-key (kbd "C-c n i") #'org-roam-node-insert)
(global-set-key (kbd "C-c n a") #'org-roam-alias-add)
(global-set-key (kbd "C-c n c") #'org-roam-capture)
(global-set-key (kbd "C-c n g") #'org-roam-graph)
(global-set-key (kbd "C-c n d") (lambda () (interactive)
				  (org-roam-db-autosync-mode -1)))
(setq org-roam-capture-templates
      '(("d" "default" plain "%?" :target
	 (file+head "${slug}.org" "#+title: ${title}")
	 :unnarrowed t)))

(with-eval-after-load 'org-roam-mode
  (org-roam-db-autosync-enable))

;;;; babel
(org-babel-do-load-languages 'org-babel-load-languages
                             '((emacs-lisp . t)
			       (shell . t)
			       (python . t)))
(setq org-src-preserve-indentation t)
(setq org-confirm-babel-evaluate nil)

;;; essentials
;;;; security
(setq auth-sources '("~/.authinfo.gpg"))

;;;; dired
(setq dired-dwim-target t)
(setq dired-free-space nil)
(setq dired-hide-details-hide-symlink-targets nil)
(setq wdired-allow-to-change-permissions t)
(add-hook 'dired-mode-hook #'dired-hide-details-mode)
(setq dired-listing-switches "-lhA")
(setq image-dired-thumbnail-storage 'standard-x-large)
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "C-M-o") #'dired-find-file-other-frame)
  (define-key dired-mode-map (kbd "C-c f") #'find-dired))

;;;; which-key
(setq which-key-idle-delay 0.5)
(setq which-key-idle-secondary-delay 0.05)
(which-key-mode)

;;;; avy
(global-set-key (kbd "M-o") 'avy-goto-char-timer)
(setq avy-timeout-seconds 0.2)

;;;; ace-window
;; (global-set-key (kbd "C-c o") #'ace-window)
;; (setq aw-scope 'frame)
;; (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))

;;;; comint
(setq comint-prompt-read-only t)

;;;; shell
(setq shell-command-prompt-show-cwd t)
(setq ansi-color-for-comint-mode t)
;; (define-key shell-mode-map (kbd "C-c r") #'bash-completion-refresh)
;; (define-key shell-mode-map (kbd "C-c C-r") #'bash-completion-refresh)
;; (setq bash-completion-use-separate-processes t)
;; (bash-completion-setup)

;;;; vterm
(setq vterm-max-scrollback 10000)
(add-hook 'vterm-mode-hook #'hide-mode-line-mode)
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

;;;; mail
(setq user-mail-address "cornejodlm@ciencias.unam.mx")
(require 'smtpmail)
(setq message-send-mail-function 'smtpmail-send-it)
(setq smtpmail-smtp-server "smtp.gmail.com")
(setq smtpmail-stream-type 'starttls)
(setq smtpmail-smtp-service 587)
(setq starttls-use-gnutls t)

;;;; magit
(global-set-key (kbd "C-x g") #'magit)
(global-set-key (kbd "C-x M-g") #'magit-file-dispatch)

;;;; pdf-tools
(pdf-loader-install)
(setq pdf-view-continuous nil)
(setq pdf-view-resize-factor 1.1)

;;;; irc
(setq rcirc-default-nick "icmor")
(setq rcirc-default-user-name "icmor")
(setq rcirc-server-alist
      '(("irc.libera.chat"
	 :port 6697
	 :encryption tls)))

;;;; calc
(setq calc-prefer-frac nil)

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

;;;; eglot
(setq eglot-events-buffer-size 0)
(setq eglot-autoshutdown t)

;;;; markdown
(add-hook 'markdown-mode-hook 'visual-line-mode)
(setq markdown-fontify-code-blocks-natively t)

(add-hook 'rst-mode-hook 'visual-line-mode)
(add-hook 'conf-mode-hook 'visual-line-mode)

;;;; python
(setq python-indent 4)
(with-eval-after-load 'python
  (define-key python-mode-map (kbd "C-x p l")
	      (lambda () (interactive)
		(project-switch-project "/usr/lib/python3.10/"))))


;;;; c
(setq c-default-style
      '((java-mode . "linux")
	(awk-mode . "awk")
	(c-mode . "linux")
	(other . "gnu")))

(with-eval-after-load 'cc-mode
  (define-key c-mode-map (kbd "C-x p l")
	      (lambda () (interactive)
		(project-switch-project "/usr/include/"))))

;;;; java
(add-hook 'java-mode-hook (lambda () (if (not buffer-read-only) (eglot-ensure))))
(add-hook 'java-mode-hook #'subword-mode)
(add-to-list 'exec-path (file-truename "~/.emacs.d/var/jdtls/bin") t)
(with-eval-after-load 'cc-mode
  (define-key java-mode-map (kbd "C-x p l")
	      (lambda () (interactive)
		(project-switch-project "~/.local/opt/jdk11"))))


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
;;;; general
(setq user-full-name "Iñaki Cornejo")

;;;; better defaults
(repeat-mode)
(setq view-read-only t)
(global-so-long-mode)

;;;; visual
(add-to-list 'default-frame-alist
	     '(font . "Source Code Pro-14"))
(load-theme 'modus-vivendi t)
(setq bookmark-set-fringe-mark nil)
(blink-cursor-mode -1)
(tooltip-mode -1)
(minions-mode)
(setq minions-mode-line-lighter "λ")
(set-face-attribute 'mode-line-active nil :inherit 'mode-line)
(set-face-attribute 'mode-line-inactive nil :inherit 'mode-line)

;;;; completion
(setq completions-detailed t)
(setq read-buffer-completion-ignore-case t)
(setq completions-format 'one-column)
(setq dabbrev-check-all-buffers nil)

;;;; bookmarks
(setq bookmark-save-flag 1)
(setq bookmark-search-size 8)

;;;; window management
(winner-mode)

;;;; history
(savehist-mode)
(setq history-length 1000)
(setq history-delete-duplicates t)

;;;; documents
(setq doc-view-resolution 400)

;;;; text
(add-hook 'org-mode-hook #'ws-butler-mode)
(add-hook 'prog-mode-hook #'ws-butler-mode)
(setq sentence-end-double-space nil)
(setq require-final-newline t)
(setq save-interprogram-paste-before-kill t)
(setq-default fill-column 80)

;;;;; coding system
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)

;;;; files
(setq auto-save-default nil)
(setq backup-by-copying t)
(setq create-lockfiles nil)
(setq vc-follow-symlinks nil)
(setq delete-by-moving-to-trash t)

;;;; etc
(setq use-short-answers t)
(setq find-file-suppress-same-file-warnings t)
(setq native-comp-async-report-warnings-errors 'silent)
(setq ring-bell-function 'ignore)
(setq disabled-command-function nil)
(setq initial-scratch-message
      (concat
       (replace-regexp-in-string "^" ";; " (cookie "~/org/art/quotes.txt"))
       "\n\n"))
