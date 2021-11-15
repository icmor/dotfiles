;;; -*- lexical-binding: t; -*-

;;; init.el --- icmor's Emacs
;;;; Commentary
;; Got inspired to start a new Emacs journey based on the
;; philosophy of Protesilaos Stavrou. Basically, put in
;; the effort to discover Emacs the "Emacs Way". Sacrificing
;; temporary convenience in exchange of really learning
;; the tools I use and achieving autonomy through power,
;; knowledge and humility.

;;; No littering
;;;; General
(setq user-var-dir (concat user-emacs-directory "var/"))
(setq user-etc-dir (concat user-emacs-directory "etc/"))
(setq emacs-source-dir "/home/pink/.cache/yay/emacs-git/src/emacs-git/src")

;;;; Backups and Auto-save files
(setq auto-save-list-file-prefix (concat user-var-dir "auto-save-list/.saves-"))
(setq backup-directory-alist `((".*" . ,(concat user-var-dir "backup"))))
(setq tramp-backup-directory-alist backup-directory-alist)
(setq version-control t)
(setq kept-new-versions 4)
(setq kept-old-versions 2)
(setq delete-old-versions t)

;;;; Litter
(setq bookmark-default-file		(concat user-var-dir "bookmark-default.el"))
(setq custom-file			(concat user-etc-dir "custom.el"))
(setq eshell-directory-name		(concat user-var-dir "eshell/"))
(setq nsm-settings-file                 (concat user-var-dir "network-security.data"))
(setq org-preview-latex-image-directory (concat user-var-dir "ltximg/"))
(setq project-list-file			(concat user-var-dir "projects"))
(setq savehist-file			(concat user-var-dir "savehist"))
(setq speed-type-gb-dir			(concat user-var-dir "speed-type/"))
(setq tramp-persistency-file-name	(concat user-var-dir "tramp/persistency.el"))
(setq transient-history-file		(concat user-var-dir "transient/history.el"))
(setq transient-levels-file		(concat user-etc-dir "transient/levels.el"))
(setq transient-values-file		(concat user-etc-dir "transient/values.el"))
(setq url-cache-directory		(concat user-var-dir "url/cache/"))
(setq url-configuration-directory	(concat user-var-dir "url/configuration/"))
(load custom-file t)

;;; Package Configuration
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)
(setq package-native-compile t)
(package-install-selected-packages)

;;; Functions
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

;;; Global Bindings
(global-set-key [f2] #'my/vterm-toggle)
(global-set-key (kbd "C-<f2>") #'vterm-other-window)
(global-set-key (kbd "C-h C-m") #'man)	; same as C-h RET
(global-set-key (kbd "C-x r w") #'burly-bookmark-windows)
(global-set-key (kbd "C-x r f") #'burly-bookmark-frames)
(global-set-key (kbd "C-s-k") #'windmove-swap-states-up)
(global-set-key (kbd "C-s-j") #'windmove-swap-states-down)
(global-set-key (kbd "C-s-h") #'windmove-swap-states-left)
(global-set-key (kbd "C-s-l") #'windmove-swap-states-right)

;;; Org-mode
;;;; General
(setq org-directory "~/org/")
(setq org-agenda-files '("~/org/gtd/"))
(setq org-refile-targets '((nil . (:maxlevel . 3))
			   (org-agenda-files . (:level . 1))))
(setq org-log-into-drawer t)
(setq org-return-follows-link t)
(setq org-capture-bookmark nil)

;;;; Visual
(add-hook 'org-mode-hook 'visual-line-mode)
(setq org-adapt-indentation nil)
(add-hook 'org-mode-hook (lambda () (setq fill-column 100)))
(setq org-startup-with-inline-images t)
(setq org-image-actual-width 750)
(eval-after-load 'org
  (lambda () (setq org-format-latex-options
		   (plist-put org-format-latex-options :scale 2.0))))

;;;; Agenda
(eval-after-load 'org '(add-to-list 'org-modules 'org-habit t))
(global-set-key (kbd "C-c a") #'org-agenda-list)
(global-set-key (kbd "C-c c") #'org-capture)

;;;; Capture
(setq org-capture-templates
      '(("t" "Tasks" entry (file+headline "gtd/gtd.org" "Tasks")
         "* TODO %?\n")
	("h" "Homework" entry (file+headline "gtd/gtd.org" "Homework")
         "* TODO %?\n")
	("e" "Events" entry (file+headline "gtd/gtd.org" "Events")
         "* TODO %?\n")
	("i" "Inbox" entry (file+headline "gtd/inbox.org" "Inbox")
	 "* TODO %?\n")
	("b" "Buy" entry (file+headline "gtd/inbox.org" "Things to Buy")
	 "* %?\n")
	("d" "Ideas" entry (file+headline "gtd/inbox.org" "Ideas")
	 "* %?\n")
	("j" "Journal" plain (file+olp+datetree "life/journal.org.gpg")
	 "%?")
	("u" "Quotes" plain (file "roam/quotes.txt")
	 "%?\n%")))

;;;; Babel
(org-babel-do-load-languages 'org-babel-load-languages
                             '((emacs-lisp . t)
			       (python . t)))
(setq org-src-preserve-indentation t)
(setq org-confirm-babel-evaluate nil)

;;; Essentials
;;;; Security
(setq auth-sources '("~/.authinfo.gpg"))

;;;; Dired
(setq dired-dwim-target t)
(setq dired-hide-details-hide-symlink-targets nil)
(add-hook 'dired-mode-hook #'dired-hide-details-mode)
(setq dired-listing-switches "-Alh")
(setq image-dired-thumbnail-storage 'standard-x-large)

;;;; Which-Key
(setq which-key-idle-delay 0.5)
(setq which-key-idle-secondary-delay 0.05)
(which-key-mode)

;;;; Avy
(global-set-key (kbd "M-o") 'avy-goto-char-timer)
(setq avy-timeout-seconds 0.15)

;;;; Vterm
(setq vterm-max-scrollback 10000)
(eval-after-load 'vterm
  '(progn
     (define-key vterm-mode-map (kbd "C-u") #'vterm--self-insert)
     (define-key vterm-mode-map (kbd "C-SPC") #'vterm-copy-mode)
     (define-key vterm-mode-map (kbd "C-M-v") nil)
     (define-key vterm-mode-map (kbd "C-S-M-v") nil)
     (define-key vterm-mode-map [f2] nil)))

;;;; Mail
(require 'smtpmail)
(setq message-send-mail-function 'smtpmail-send-it)
(setq smtpmail-smtp-server "smtp.gmail.com")
(setq smtpmail-stream-type 'starttls)
(setq smtpmail-smtp-service 587)
(setq starttls-use-gnutls t)

;;;; Magit
(global-set-key (kbd "C-x g") 'magit)

;;;; Pdf-Tools
(pdf-loader-install)
(setq pdf-view-continuous nil)

;;;; IRC
(setq rcirc-default-nick "icmor")
(setq rcirc-default-user-name "icmor")
(setq rcirc-server-alist
      '(("irc.libera.chat"
	 :port 6697
	 :encryption tls)))

;;;; Calc
(setq calc-prefer-frac t)

;;;; Burly
(setq burly-bookmark-prefix nil)

;;; Programming
;;;; General
(show-paren-mode 1)
(setq show-paren-delay 0)
(setq show-paren-style 'mixed)
(setq outline-minor-mode-cycle t)
(add-hook 'prog-mode-hook #'electric-pair-local-mode)
(add-hook 'prog-mode-hook #'auto-fill-mode)

;;;; Eglot
(setq eglot-events-buffer-size 0)
(setq eglot-autoshutdown t)

;;;; Comint
(setq shell-command-prompt-show-cwd t)
(setq comint-prompt-read-only t)

;;;; Python
(setq python-indent-offset 4)

;;;; C
(setq c-default-style
      '((java-mode . "java")
	(awk-mode . "awk")
	(c-mode . "k&r")
	(other . "gnu")))

;;;; Java
(add-hook 'java-mode-hook #'eglot-ensure)
(setenv "CLASSPATH" ":/home/pink/.emacs.d/var/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar")

;;; Miscellaneous
;;;; General
(setq user-mail-address "cornejodlm@ciencias.unam.mx")
(setq user-full-name "Iñaki Cornejo")

;;;; Better defaults
(setq kill-whole-line t)
(global-set-key (kbd "C-s") #'isearch-forward-regexp)
(global-set-key (kbd "C-r") #'isearch-backward-regexp)
(global-set-key (kbd "C-x C-b") #'ibuffer)
(global-set-key (kbd "M-z") #'zap-up-to-char)
(global-set-key (kbd "C-x l") #'count-words)
(global-set-key (kbd "C-x r m") #'bookmark-set-no-overwrite)
(global-set-key (kbd "C-x r M") #'bookmark-set)
(global-set-key (kbd "C-o") #'split-line)
(global-set-key (kbd "C-M-o") #'open-line)

;;;; Visual
(add-to-list 'default-frame-alist
	     '(font . "Source Code Pro-14"))
(load-theme 'modus-vivendi t)
(setq bookmark-set-fringe-mark nil)
(blink-cursor-mode -1)
(tooltip-mode -1)

;;;; Completion
(setq read-buffer-completion-ignore-case t)
(setq completions-format 'one-column)
(setq dabbrev-check-all-buffers nil)
(setq completions-detailed t)

;;;; Bookmarks
(setq bookmark-save-flag 1)
(setq bookmark-search-size 8)

;;;; Window Management
(winner-mode)

;;;; History
(savehist-mode 1)
(setq history-length 1000)
(setq history-delete-duplicates t)

;;;; Documents
(setq doc-view-resolution 400)

;;;; Text
(prefer-coding-system 'utf-8)
(add-hook 'org-mode-hook #'ws-butler-mode)
(add-hook 'prog-mode-hook #'ws-butler-mode)
(setq sentence-end-double-space nil)
(setq require-final-newline t)
(setq save-interprogram-paste-before-kill t)
(setq-default fill-column 80)

;;;; Files
(setq auto-save-default nil)
(setq backup-by-copying t)
(setq create-lockfiles nil)
(setq vc-follow-symlinks nil)
(setq delete-by-moving-to-trash t)

;;;; Etc
(setq use-short-answers t)
(setq find-file-suppress-same-file-warnings t)
(setq native-comp-async-report-warnings-errors 'silent)
(setq ring-bell-function 'ignore)
(setq disabled-command-function nil)
(setq initial-scratch-message
      (concat
       (replace-regexp-in-string "^" ";; " (cookie "~/org/roam/quotes.txt"))
       "\n\n"))
