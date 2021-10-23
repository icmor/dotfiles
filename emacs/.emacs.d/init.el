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
(setq image-dired-dir			(concat user-var-dir "image-dired/"))
(setq nsm-settings-file                 (concat user-var-dir "network-security.data"))
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

(defun my/lookup-password (&rest keys)
  (let ((result (apply #'auth-source-search keys)))
    (if result
        (funcall (plist-get (car result) :secret)))))

;;; Global Bindings
(global-set-key [f2] #'my/vterm-toggle)
(global-set-key (kbd "C-<f2>") #'vterm-other-window)
(global-set-key (kbd "C-h C-m") #'man)	; same as C-h RET
(global-set-key (kbd "C-s") #'isearch-forward-regexp)
(global-set-key (kbd "C-r") #'isearch-backward-regexp)
(global-set-key (kbd "C-x C-b") #'ibuffer)
(global-set-key (kbd "C-c @ @") #'outline-minor-mode)
(global-set-key (kbd "M-z") #'zap-up-to-char)
(global-set-key (kbd "C-x l") #'count-words)
(global-set-key (kbd "C-x r m") #'bookmark-set-no-overwrite)
(global-set-key (kbd "C-x r M") #'bookmark-set)
(global-set-key (kbd "C-o") #'split-line)
(global-set-key (kbd "C-M-o") #'open-line)


;;; Org-mode
;;;; General
(setq org-directory "~/org/")
(setq org-agenda-files '("~/org/gtd/"))
(setq org-refile-targets '((nil . (:level . 1))
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

;;; Essentials
;;;; Security
(setq auth-sources '("~/.authinfo.gpg"))
(setq auth-source-save-behavior nil)

;;;; Dired
(setq dired-dwim-target t)
(setq dired-hide-details-hide-symlink-targets nil)
(add-hook 'dired-mode-hook #'dired-hide-details-mode)
(setq dired-listing-switches "-Alh")
(setq image-dired-thumb-size 500)
(setq image-dired-thumb-width 500)
(setq image-dired-thumb-height 500)


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

;;;; mu4e
(setq user-mail-address "cornejodlm@ciencias.unam.mx")
(setq user-full-name "Iñaki Cornejo")

(require 'mu4e)
(setq mu4e-get-mail-command "offlineimap")
(setq mu4e-attachment-dir "~/Downloads")
(setq mu4e-update-interval 600)
(setq mu4e-change-filenames-when-moving t)
(setq mu4e-sent-messages-behavior 'delete)
(setq message-kill-buffer-on-exit t)
(add-to-list 'mu4e-bookmarks
	     '("m:/ciencias/INBOX or m:/personal/INBOX" "All Inboxes" ?i))
(setq mu4e-contexts
      `(,(make-mu4e-context
          :name "Ciencias"
          :match-func
          (lambda (msg)
            (when msg
              (string-prefix-p "/ciencias" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "cornejodlm@ciencias.unam.mx")
                  (user-full-name    . "Iñaki Cornejo")
                  (mu4e-drafts-folder  . "/ciencias/[Gmail].Drafts")
                  (mu4e-sent-folder  . "/ciencias/[Gmail].Sent Mail")
                  (mu4e-trash-folder  . "/ciencias/[Gmail].Trash")
		  (smtpmail-smtp-user . "cornejodlm@ciencias.unam.mx")
		  (mu4e-maildir-shortcuts .
					  (("/ciencias/INBOX" .  ?i)
					   ("/ciencias/Uni" . ?u)
					   ("/ciencias/[Gmail].Sent Mail" . ?s)
					   ("/ciencias/[Gmail].Trash" . ?t)))))
	,(make-mu4e-context
          :name "Personal"
          :match-func
          (lambda (msg)
            (when msg
              (string-prefix-p "/personal" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address . "icornejomora@gmail.com")
                  (user-full-name    . "Iñaki Cornejo")
                  (mu4e-drafts-folder  . "/personal/[Gmail].Drafts")
                  (mu4e-sent-folder  . "/personal/[Gmail].Sent Mail")
                  (mu4e-trash-folder  . "/personal/[Gmail].Trash")
		  (smtpmail-smtp-user . "icornejomora@gmail.com")
	  	  (mu4e-maildir-shortcuts .
					  (("/personal/INBOX" .  ?i)
					   ("/personal/[Gmail].Sent Mail" . ?s)
					   ("/personal/[Gmail].Trash" . ?t)))))))

(global-set-key (kbd "C-c m") #'mu4e)

(require 'smtpmail)
(setq message-send-mail-function 'smtpmail-send-it
      starttls-use-gnutls t
      smtpmail-stream-type 'starttls
      smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587)

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

;;; Programming
;;;; General
(show-paren-mode 1)
(setq show-paren-delay 0)
(setq show-paren-style 'mixed)
(setq outline-minor-mode-cycle t)
(add-hook 'prog-mode-hook #'electric-pair-local-mode)
(add-hook 'prog-mode-hook #'auto-fill-mode)

;;;; Comint
(setq shell-command-prompt-show-cwd t)
(setq comint-prompt-read-only t)

;;;; Python
(setq python-indent-offset 4)

;;;; C
(setq c-default-style
      '((java-mode . "linux")
	(awk-mode . "awk")
	(c-mode . "k&r")
	(other . "gnu")))

;;;; Java
(add-hook 'java-mode-hook #'eglot-ensure)
(setenv "CLASSPATH" ":/home/pink/.emacs.d/var/jdtls/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar")

;;; Miscellaneous
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
