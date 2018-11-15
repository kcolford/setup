;;; init.el -- emacs initialization

;;; Commentary:

;;; Code:
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (rust-mode magit helm company-clang protobuf-mode graphviz-dot-mode ecb semi direnv ggtags use-package-chords diminish edit-server lorem-ipsum auto-package-update yasnippet-snippets go-snippets js2-mode prettier-js less-css-mode flycheck use-package-ensure-system-package use-package pkgbuild-mode company-ghc yasnippet company-try-hard clang-format cmake-mode company company-auctex auctex company-c-headers company-dict company-flx company-go company-irony company-irony-c-headers company-shell company-statistics company-web csv-mode docker-compose-mode dockerfile-mode editorconfig elpy flycheck-irony gitconfig-mode gitignore-mode go-mode google google-c-style haskell-mode hc-zenburn-theme irony irony-eldoc json-mode markdown-mode projectile ssh-config-mode systemd web-mode yaml-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(defmacro define-save-minor-mode (fn &optional after)
  "Define a minor mode `FN-mode' that triggers FN every time a file is saved.
The command will run after the save if AFTER is not nil."
  (let ((mode (intern (format "%s-mode" fn)))
	(hook (if after 'after-save-hook 'before-save-hook)))
    `(progn
       (define-minor-mode ,mode "" nil nil nil
	 (if ,mode
	     (add-hook (quote ,hook) (quote ,fn) nil t)
	   (remove-hook (quote ,hook) (quote ,fn) t)))
       (add-to-list 'safe-local-eval-forms '(,mode 0)))))

(defmacro req (&rest pkgs)
  "Force download but not loading of PKGS."
  (cons 'progn (mapcar (lambda (pkg) `(use-package ,pkg :ensure t :defer t)) pkgs)))

;; reduce garbage collection at startup
(setq gc-cons-threshold 64000000)
(add-hook 'after-init-hook #'(lambda ()
			       (setq gc-cons-threshold 800000)))

;; initialize packages
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
			 ("melpa-stable" . "https://stable.melpa.org/packages/")
			 ("gnu" . "http://elpa.gnu.org/packages/")))
(package-initialize)

;; install basic files on first run
(defun install-and-update-packages ()
  "Install and update all packages."
  (interactive)
  (package-refresh-contents)
  (let ((oldfunc (symbol-function 'y-or-n-p)))
    (fset 'y-or-n-p '(lambda (&rest args) t))
    (package-install-selected-packages)
    (package-install 'use-package)
    (fset 'y-or-n-p oldfunc))
  (auto-package-update-now))

;; setup use-package
(eval-when-compile
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
  (require 'use-package)
  (setq use-package-always-ensure t)
  (setq use-package-verbose t))
(use-package bind-key)
(use-package diminish)
(use-package use-package-chords
  :config (key-chord-mode 1))
(use-package system-packages)

;; some generic settings for emacs as a whole
(scroll-bar-mode 0)
(tool-bar-mode 0)
(save-place-mode)
(global-auto-revert-mode)
(show-paren-mode)
(windmove-default-keybindings)
(xterm-mouse-mode)
(mouse-wheel-mode)
(column-number-mode)
(setq vc-handled-backends '(Git))
(defalias 'yes-or-no-p 'y-or-n-p)
(setq inhibit-startup-screen t)
(setq-default warning-minimum-log-level :error)
(setq completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)
(setq vc-follow-symlinks t)
(setq sentence-end-double-space nil)
(setq confirm-kill-emacs 'yes-or-no-p)
(setq browse-url-browser-function 'browse-url-xdg-open)
(bind-key "C-\\" 'bury-buffer)
(bind-key "C-x C-b" 'ibuffer)
(bind-key "M-]" 'ffap)
(bind-key "C-=" 'start-new-term)
(bind-key "M-p" 'switch-to-prev-buffer)
(bind-key "M-n" 'switch-to-next-buffer)
(define-save-minor-mode whitespace-cleanup)
(add-hook 'prog-mode-hook 'whitespace-cleanup-mode)
(add-hook 'text-mode-hook 'whitespace-cleanup-mode)
(add-to-list 'safe-local-variable-values '(buffer-file-coding-system . dos))
(add-to-list 'auto-mode-alist '("README" . text-mode))

(defun add-mode-line ()
  "Add the current mode to the mode line of a file."
  (interactive)
  (add-file-local-variable-prop-line
   'mode (intern (replace-regexp-in-string
		  "-mode\\'" "" (symbol-name major-mode)))))

(defun global-disable-mode (mode-fn)
  "Disable `MODE-FN' in ALL buffers."
  (interactive "a")
  (dolist (buffer (buffer-list))
    (with-current-buffer buffer
      (funcall mode-fn -1))))

(add-to-list 'display-buffer-alist '("\\*new-term\\*" display-buffer-no-window (allow-no-window . t)))
(defun start-new-term ()
  "Start xterm in local directory."
  (interactive)
  (let ((buf (generate-new-buffer-name "*new-term*"))
	(prog (string-remove-suffix "-256color" (getenv "TERM"))))
    (async-shell-command prog buf buf)))

;; completions
(icomplete-mode)
(ido-mode)
(use-package helm
  :disabled
  :diminish helm-mode
  :config (helm-mode))
(use-package helm-config
  :after helm :ensure helm)

(req protobuf-mode)
(req graphviz-dot-mode)
(req ecb semi)
(req lorem-ipsum)

;; info lookup
(use-package google-this
  :diminish google-this-mode
  :config
  (google-this-mode))

(use-package mu4e
  :ensure nil)

(req haskell-mode)

(req json-mode)

(req markdown-mode)

(req css-mode)

(req less-css-mode)

(req ssh-config-mode)

(req systemd)

;; tag search
(use-package ggtags
  :diminish ggtags-mode
  ;; :hook ((c-mode c++-mode java-mode) . ggtags-mode)
  )
(req ripgrep)

;; prevent annoying windows from popping up out of reach
(setq display-buffer-base-action '((display-buffer-use-some-window display-buffer-same-window) (nil)))
(setq-default Man-notify-method 'pushy)

;; use xclip to copy/paste in emacs-nox
(unless window-system
  (when (getenv "DISPLAY")
    ;; (system-packages-install "xclip")
    (defun xclip-cut-function (text &optional push)
      (with-temp-buffer
	(insert text)
	(call-process-region (point-min) (point-max) "xclip" nil 0 nil "-i" "-selection" "clipboard")))
    (defun xclip-paste-function()
      (let ((xclip-output (shell-command-to-string "xclip -o -selection clipboard")))
	(unless (string= (car kill-ring) xclip-output)
	  xclip-output )))
    (setq interprogram-cut-function 'xclip-cut-function)
    (setq interprogram-paste-function 'xclip-paste-function)))

;; theme
(use-package hc-zenburn-theme
  :ensure hc-zenburn-theme
  :init (load-theme 'hc-zenburn t))

;; check errors
(use-package flycheck
  :diminish flycheck-mode
  :config (global-flycheck-mode))

(use-package flyspell
  :diminish (flyspell-mode flyspell-prog-mode)
  :hook ((text-mode . flyspell-mode)
	 (prog-mode . flyspell-prog-mode))
  :init
  (setq-default flyspell-use-meta-tab nil))

;; make editor play nice
(use-package editorconfig
  :diminish editorconfig-mode
  :config (editorconfig-mode))

;; auto type
(use-package yasnippet
  :after (elisp-mode cc-mode go-mode)
  :config (yas-global-mode))

;; projects
(use-package projectile
  :diminish projectile-mode
  :bind-keymap ("C-c p" . projectile-command-map)
  :config (projectile-mode))

;; config files
(use-package generic-x :ensure nil)
(req gitconfig-mode)
(req gitignore-mode)
(req pkgbuild-mode)
(req csv-mode)
(req docker-compose-mode)
(req yaml-mode)

(use-package auto-package-update
  :config
  (setq auto-package-update-delete-old-versions t)
  (setq auto-package-update-hide-results t))

(use-package company
  :diminish company-mode
  :config (global-company-mode))
(use-package company-statistics
  :after company
  :config (company-statistics-mode))

(defun dired-mark-dotfiles ()
  "Hide all dotfiles in `dired'."
  (interactive)
  (require 'dired)
  (dired-mark-files-regexp "^\\."))
(use-package dired
  :ensure nil
  :bind (:map dired-mode-map
	      ("b" . browse-url-of-dired-file)
	      ("," . dired-mark-dotfiles)))
(use-package dired-x
  :ensure nil
  :after dired)

(use-package org
  :bind (("C-c a" . org-agenda)
	 ("C-c b" . org-iswitchb)
	 ("C-c c" . org-capture)
	 ("C-c l" . org-store-link)))

(use-package tex
  :defer t
  :ensure auctex
  :config
  (setq TeX-auto-save t)
  (setq TeX-parse-self t)
  (setq-default TeX-master 'dwim))
(use-package reftex
  :after tex
  :hook (LaTeX-mode . reftex-mode)
  :hook (latex-mode . reftex-mode))
(use-package company-auctex
  :after (tex company)
  :config (company-auctex-init))

(with-eval-after-load 'elisp-mode
  (bind-key "C-c C-s" 'apropos emacs-lisp-mode-map)
  (bind-key "C-C C-d" 'describe-symbol emacs-lisp-mode-map))
(use-package eldoc
  :diminish eldoc-mode
  :hook (emacs-lisp-mode . eldoc-mode))
(add-hook 'emacs-lisp-mode-hook 'whitespace-cleanup-mode)
(define-save-minor-mode emacs-lisp-byte-compile t)

(define-save-minor-mode gofmt-before-save)
(use-package go-mode
  :mode "\\.go\\'"
  :commands gofmt-before-save
  ;; :ensure-system-package (goimports . "go-tools")
  :init
  (setq gofmt-show-errors nil)
  (setq gofmt-command "goimports")
  (add-hook 'go-mode-hook 'gofmt-before-save-mode))
(use-package company-go
  :after (go-mode company)
  ;; :ensure-system-package (gocode . "gocode-git")
  :config (add-to-list 'company-backends 'company-go))

(use-package python
  :defer t
  :init
  (setq python-shell-interpreter "ipython")
  (setq python-shell-interpreter-args "-i --simple-prompt"))
(define-save-minor-mode elpy-format-code)
(define-save-minor-mode elpy-importmagic-fixup)
(use-package elpy
  :after python
  ;; :ensure-system-package (flake8 autopep8 yapf ipython (true . "python-jedi") (true . "python-rope") (virtualenv . "python-virtualenv"))
  :init
  (setq elpy-rpc-timeout 10)
  ;; (add-hook 'elpy-mode-hook 'elpy-format-code-mode)
  ;; (add-hook 'elpy-mode-hook 'elpy-importmagic-fixup-mode)
  :config
  (elpy-enable))

(use-package company-shell
  :after (sh-script company)
  :config (add-to-list 'company-backends 'company-shell))

(use-package web-mode
  :mode "\\.jsx\\'"
  :mode "\\.phtml\\'"
  :mode "\\.php\\'"
  :mode "\\.erb\\'"
  :mode "\\.mustache\\'"
  :mode "\\.djhtml\\'")
(use-package company-web
  :after (company web-mode)
  :config
  (add-to-list 'company-backends 'company-web-html)
  (add-to-list 'company-backends 'company-web-jade)
  (add-to-list 'company-backends 'company-web-slim))
(use-package js2-mode :mode "\\.js\\'")
(use-package prettier-js
  :hook ((js2-mode js-mode web-mode markdown-mode css-mode less-css-mode json-mode) . prettier-js-mode))

;; (setq-default tramp-default-method "ssh")
;; (setq-default auto-revert-remote-files t)
;; (setq enable-remote-dir-locals t)
(with-eval-after-load 'tramp
  (setq tramp-verbose 0))
(with-eval-after-load 'tramp-sh
  (setq tramp-use-ssh-controlmaster-options nil)
  (setq tramp-histfile-override t)
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path))

(use-package company-clang
  :ensure nil
  :init (setq company-clang-arguments "-std=c++11")
  :config (add-to-list 'company-backends 'company-clang))
(use-package google-c-style
  :hook (c-mode-common . google-set-c-style))
(use-package irony
  ;; :ensure-system-package (cmake clang)
  ;; :hook (c-mode-common . irony-mode)
  :init
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options))
(use-package flycheck-irony
  :after (flycheck irony)
  :config (flycheck-irony-setup))
(defun irony-setup-cmake ()
  "Have cmake export compile commands for irony."
  (interactive)
  ;; the `compile' function allows us to review the command and change
  ;; it if it's incorrect
  (compile "cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ./build")
  (irony-cdb-autosetup-compile-options))
(defun irony-setup-make ()
  "Have make export compile commands for irony."
  (interactive)
  ;; the `compile' function allows us to review the command and change
  ;; it if it's incorrect
  (compile "bear make -B")
  (irony-cdb-autosetup-compile-options))
(use-package irony-eldoc
  :hook irony-mode)
(use-package company-irony
  :after (irony company)
  :init (setq company-irony-ignore-case t)
  :config (add-to-list 'company-backends 'company-irony))
(use-package company-irony-c-headers
  :after (irony company)
  :config (add-to-list 'company-backends 'company-irony-c-headers))
(define-save-minor-mode clang-format-buffer)
;; (add-hook 'c-mode-common-hook 'clang-format-buffer-mode)

(define-save-minor-mode cmake-unscreamify-buffer)
(use-package cmake-mode
  :commands cmake-unscreamify-buffer
  :bind (:map cmake-mode-map
	      ("C-c C-d" . cmake-help))
  :config
  (add-hook 'cmake-mode-hook 'cmake-unscreamify-buffer-mode))

(use-package company-ghc
  :after (haskell-mode company)
  :config (add-to-list 'company-backends 'company-haskell))

(use-package server
  :config
  ;; every emacs is an emacs server so that local shells use the
  ;; current editor to edit
  (if (daemonp)
      (setq server-name (getenv "EMACS_SERVER_NAME"))
    (setq server-name (format "server-%s" (emacs-pid)))
    (setenv "EMACS_SERVER_NAME" server-name)
    (server-start)))
(use-package edit-server
  :if (daemonp)
  :config
  (add-to-list 'edit-server-new-frame-alist '(window-system . x))
  (setq edit-server-default-major-mode 'markdown-mode)
  (edit-server-start t))


(provide 'init)
;;; init.el ends here
