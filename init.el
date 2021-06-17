;; Set the size of the initial window, width in chars, height in rows 
(setq initial-frame-alist '((width . 100) (height . 30)))

(require 'package)
(add-to-list 'package-archives
         '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; This is for back-compatible for Emacs24 configs
(when (not (fboundp 'make-variable-frame-local)) (defun make-variable-frame-local (variable) variable))

(require 'auto-complete)
(global-auto-complete-mode t)

;; ;;(global-linum-mode t)
;; ;; Disable the menu bars, etc 
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(show-paren-mode 1)

;; ;; make paragraph wider 
(setq-default fill-column 80)
(global-set-key (kbd "C-x C-p") 'fill-paragraph)

(require 'autopair)
(autopair-global-mode) ;; to enable in all buffers
(show-paren-mode t)
(setq show-paren-style 'expression)

;; ;; disable the init global company mode
(add-hook 'after-init-hook 'global-company-mode)
(semantic-mode 1)

(add-hook 'c-mode-hook (lambda () (c-toggle-comment-style -1)))

;;(setq frame-title-format "%b")
(setq frame-title-format
      (list (format "%s %%S: %%j " (system-name))
            '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

(setq-default indent-tabs-mode nil) 
(setq x-select-enable-clipboard t)

;; switching buffers uing arrows
;; use Shift+arrow_keys to move cursor around split panes
(windmove-default-keybindings)
;; when cursor is on edge, move to the other side, as in a toroidal space
(setq windmove-wrap-around t )

;; enable ascii colos in shell mode.
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;; turn off the start-up screen
;; (setq inhibit-splash-screen t)
(setq inhibit-startup-message t)
(fset 'yes-or-no-p 'y-or-n-p)

;; comment, uncomment 
(global-set-key (kbd "C-;") 'comment-region)
(global-set-key (kbd "C-'") 'uncomment-region) 
(global-set-key (kbd "C-x C-l") 'python-indent-shift-left)
(global-set-key (kbd "C-x C-r") 'python-indent-shift-right)
(global-set-key (kbd "C-x C-a") 'align-regexp)

;; navigate parentheses
(global-set-key (kbd "C-(") 'backward-sexp)
(global-set-key (kbd "C-)") 'forward-sexp)

;; make open .h, .hpp files in c++-mode 
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.hpp\\'" . c++-mode))

(require 'highlight-symbol)
(global-set-key [(control f3)] 'highlight-symbol)
(global-set-key [f3] 'highlight-symbol-next)
(global-set-key [(shift f3)] 'highlight-symbol-prev)
(global-set-key [(meta f3)] 'highlight-symbol-query-replace)
(global-set-key [(control f2)] 'bm-toggle)

(require 'yasnippet)
(yas-global-mode 1)

;; Tabbar
(require 'tabbar)
;; Tabbar settings
(set-face-attribute
 'tabbar-default nil
 :background "gray20"
 :foreground "gray20"
 :box '(:line-width 1 :color "gray20" :style nil))
(set-face-attribute
 'tabbar-unselected nil
 :background "gray30"
 :foreground "white"
 :box '(:line-width 5 :color "gray30" :style nil))
(set-face-attribute
 'tabbar-selected nil
 :background "gray75"
 :foreground "black"
 :box '(:line-width 5 :color "gray75" :style nil))
(set-face-attribute
 'tabbar-highlight nil
 :background "white"
 :foreground "black"
 :underline nil
 :box '(:line-width 5 :color "white" :style nil))
(set-face-attribute
 'tabbar-button nil
 :box '(:line-width 1 :color "gray20" :style nil))
(set-face-attribute
 'tabbar-separator nil
 :background "gray20"
 :height 0.6)

;; Show all files in one group belongs to one git repo
(defun find-git-dir (dir)
  "Search up the directory tree looking for a .git folder."
  (cond
   ((eq major-mode 'dired-mode) "Dired")
   ((not dir) "process")
   ((string= dir "/") "no-git")
   ((file-exists-p (concat dir "/.git")) dir)
   (t (find-git-dir (directory-file-name (file-name-directory dir))))))

(defun git-tabbar-buffer-groups ()
  "Groups tabs in tabbar-mode by the git repository they are in."
  (list (find-git-dir (buffer-file-name (current-buffer)))))
(setq tabbar-buffer-groups-function 'git-tabbar-buffer-groups)

(defun tabbar-move-current-tab-one-place-left ()
  "Move current tab one place left, unless it's already the leftmost."
  (interactive)
  (let* ((bufset (tabbar-current-tabset t))
         (old-bufs (tabbar-tabs bufset))
         (first-buf (car old-bufs))
         (new-bufs (list)))
    (if (string= (buffer-name) (format "%s" (car first-buf)))
        old-bufs ; the current tab is the leftmost
      (setq not-yet-this-buf first-buf)
      (setq old-bufs (cdr old-bufs))
      (while (and
              old-bufs
              (not (string= (buffer-name) (format "%s" (car (car old-bufs))))))
        (push not-yet-this-buf new-bufs)
        (setq not-yet-this-buf (car old-bufs))
        (setq old-bufs (cdr old-bufs)))
      (if old-bufs ; if this is false, then the current tab's buffer name is mysteriously missing
          (progn
            (push (car old-bufs) new-bufs) ; this is the tab that was to be moved
            (push not-yet-this-buf new-bufs)
            (setq new-bufs (reverse new-bufs))
            (setq new-bufs (append new-bufs (cdr old-bufs))))
        (error "Error: current buffer's name was not found in Tabbar's buffer list."))
      (set bufset new-bufs)
      (tabbar-set-template bufset nil)
      (tabbar-display-update))))

(defun tabbar-move-current-tab-one-place-right ()
  "Move current tab one place right, unless it's already the rightmost."
  (interactive)
  (let* ((bufset (tabbar-current-tabset t))
         (old-bufs (tabbar-tabs bufset))
         (first-buf (car old-bufs))
         (new-bufs (list)))
    (while (and
            old-bufs
            (not (string= (buffer-name) (format "%s" (car (car old-bufs))))))
      (push (car old-bufs) new-bufs)
      (setq old-bufs (cdr old-bufs)))
    (if old-bufs ; if this is false, then the current tab's buffer name is mysteriously missing
        (progn
          (setq the-buffer (car old-bufs))
          (setq old-bufs (cdr old-bufs))
          (if old-bufs ; if this is false, then the current tab is the rightmost
              (push (car old-bufs) new-bufs))
          (push the-buffer new-bufs)) ; this is the tab that was to be moved
      (error "Error: current buffer's name was not found in Tabbar's buffer list."))
    (setq new-bufs (reverse new-bufs))
    (setq new-bufs (append new-bufs (cdr old-bufs)))
    (set bufset new-bufs)
    (tabbar-set-template bufset nil)
    (tabbar-display-update)))

;; Key sequences "C-S-PgUp" and "C-S-PgDn" move the current tab to the left and to the right.
(global-set-key (kbd "C-S-<prior>") 'tabbar-move-current-tab-one-place-left)
(global-set-key (kbd "C-S-<next>") 'tabbar-move-current-tab-one-place-right)
(global-set-key (kbd "C-x C-<prior>") 'tabbar-backward-group)
(global-set-key (kbd "C-x C-<next>") 'tabbar-forward-group)
(global-set-key (kbd "C-x C-<right>") 'tabbar-forward)
(global-set-key (kbd "C-x C-<left>") 'tabbar-backward)

(setq tabbar-cycle-scope (quote tabs))
(setq table-time-before-update 0.1)
(setq tabbar-use-images t)
(tabbar-mode 1)

(add-to-list 'load-path "/home/rvbust/.emacs.d/neotree")
(require 'neotree)
(global-set-key [f8] 'neotree-toggle)

;; (speedbar 1)

;; (with-eval-after-load 'python
;;   (defun python-shell-completion-native-try ()
;;     "Return non-nil if can trigger native completion."
;;     (let ((python-shell-completion-native-enable t)
;;           (python-shell-completion-native-output-timeout
;;            python-shell-completion-native-try-output-timeout))
;;       (python-shell-completion-native-get-completions
;;        (get-buffer-process (current-buffer))
;;        nil "_"))))

;; (when (executable-find "ipython")
;;   (setq python-shell-interpreter "ipython"))

;; Change padding of the tabs
;; we also need to set separator to avoid overlapping tabs by highlighted tabs
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(package-selected-packages
   (quote
    (neotree cargo lsp-mode color-theme-modern flycheck-rust toml-mode rust-mode clang-format+ highlight-doxygen multiple-cursors irony-eldoc yasnippet use-package tabbar sphinx-doc solarized-theme smartparens popup-complete matlab-mode markdown-mode magit lua-mode json-mode jedi iedit idle-highlight-mode highlight-symbol google-c-style go-mode flymake-python-pyflakes flymake-json flymake-cursor flycheck-irony flx-ido fill-column-indicator f diminish company-irony cmake-mode cmake-ide clang-format bm autopair)))
 '(show-paren-mode t)
 '(tool-bar-mode nil))

(defun my-c++-mode-hook ()
  (setq c-basic-offset 4)
  (c-set-offset 'substatement-open 0))
(add-hook 'c++-mode-hook 'my-c++-mode-hook)

(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)

(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
;;replace the `completion-at-point' and `complete-symbol' bindings in
;;irony-mode's buffers by irony-mode's asynchronous function
(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)

;; ;; (require 'rtags) ;; optional, must have rtags installed
;; ;; (cmake-ide-setup)

(require 'cc-mode)
(require 'google-c-style)

(defun my-build-tab-stop-list (width)
  (let ((num-tab-stops (/ 80 width))
        (counter 1)
        (ls nil))
    (while (<= counter num-tab-stops)
      (setq ls (cons (* width counter) ls))
      (setq counter (1+ counter)))
    (set (make-local-variable 'tab-stop-list) (nreverse ls))))

;; Use  M-x c-set-offset to get the config and append it below 
(defun my-c-mode-common-hook ()
  (setq tab-width 4)
  (my-build-tab-stop-list tab-width)
  (setq c-basic-offset tab-width)
  (setq indent-tabs-mode nil) ;; force only spaces for indentation
  (local-set-key "\C-o" 'ff-get-other-file)
  (c-set-offset 'innamespace 0)
  (c-set-offset 'substatement-open 0)
  (c-set-offset 'brace-list-open 0)
  (c-set-offset 'brace-list-intro tab-width)
  )

;; google sytle is defined in above function
(add-hook 'c-mode-common-hook 'my-c-mode-common-hook)
(add-hook 'c++-mode-common-hook 'my-c-mode-common-hook)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

(add-hook 'c-mode-common-hook
	  (lambda()
	    (c-set-offset 'inextern-lang 0)))
(add-hook 'c++-mode-common-hook
	  (lambda()            
	    (c++-set-offset 'inextern-lang 0)))

(defun format-and-save()
  (interactive)
  (clang-format-buffer)
  (save-buffer))


;; (highlight-doxygen-global-mode 1)

(defvar hs1-regexp
  "\\(\n[[:blank:]]*///\\|///<\\).*$"
  "List of regular expressions of blocks to be hidden.")

(define-minor-mode hs1-mode
  "Hide/show predefined blocks."
  :lighter " hs1"
  (if hs1-mode
      (let (ol)
    (save-excursion
      (goto-char (point-min))
      (while (search-forward-regexp hs1-regexp nil 'noErr)
        (when (eq (syntax-ppss-context (syntax-ppss (match-end 1))) 'comment)
          (setq ol (make-overlay (match-beginning 0) (match-end 0)))
          (overlay-put ol 'hs1 t)
          (overlay-put ol 'invisible t)
          ))))
    (remove-overlays (point-min) (point-max) 'hs1 t)
    ))

(add-hook 'c++-mode-hook '(lambda () (local-set-key (kbd "C-c C-c") 'hs1-mode)))
(add-hook 'c-mode-hook '(lambda () (local-set-key (kbd "C-c C-c") 'hs1-mode)))


(define-key c-mode-base-map (kbd "C-x C-s") 'format-and-save)

(add-hook 'c-common-mode-hook 
          (lambda ()
            (add-hook (make-local-variable 'before-save-hook)
                      'clang-format-buffer)))


(add-hook 'rust-mode-hook (lambda () (setq indent-tabs-mode nil)))

(use-package flycheck
  :hook (prog-mode . flycheck-mode))

(use-package company
  :hook (prog-mode . company-mode)
  :config (setq company-tooltip-align-annotations t)
          (setq company-minimum-prefix-length 1))

(use-package lsp-mode
  :commands lsp
  :config (require 'lsp-clients))

(use-package toml-mode)

;; (use-package rust-mode
;;   :hook (rust-mode . lsp))

(setq rust-rustfmt-bin "/home/rvbust/.cargo/bin/rustfmt")
(setq rust-format-on-save t)

;; Add keybindings for interacting with Cargo
(use-package cargo
  :hook (rust-mode . cargo-minor-mode))

(use-package flycheck-rust
  :config (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(defun duplicate-line()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (yank))

(global-set-key (kbd "M-n") 'duplicate-line)

(add-hook 'python-mode-hook (lambda ()
                              (require 'sphinx-doc)
                              (sphinx-doc-mode t)))

;; ;; hightlight current line
(global-hl-line-mode -1)

(add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++14")))
(add-hook 'c++-mode-hook (lambda () (setq flycheck-clang-language-standard "c++14")))

;; delete selection
(delete-selection-mode 1)
;; linek by line scrolling
(setq scroll-step 1)

;; turn off Tab
(setq-default indent-tabs-mode nil)
(setq tab-width 4)

(add-hook 'python-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil)
            (setq tab-width 4)
            (setq python-indent 4)))
(make-variable-frame-local 'my-frame-state)

;; don't need backup files
(setq make-backup-files nil)

;; enable column number
(column-number-mode 1)

(blink-cursor-mode 1)
(setq-default cursor-type '(bar . 4)) 
(set-cursor-color "#4445cc")

(load-theme 'calm-forest t t)
(enable-theme 'calm-forest)

(load-file "~/.emacs.d/hl-tags-mode.el")
(require 'hl-tags-mode)
(add-hook 'sgml-mode-hook (lambda () (hl-tags-mode 1)))
(add-hook 'nxml-mode-hook (lambda () (hl-tags-mode 1)))

;; create dir automatically ceate new file
(defadvice find-file (before make-directory-maybe (filename &optional wildcards) activate)
  "Create parent directory if not exists while visiting file."
  (unless (file-exists-p filename)
    (let ((dir (file-name-directory filename)))
      (unless (file-exists-p dir)
        (make-directory dir)))))

;; (add-hook 'python-mode-hook '(lambda () (flymake-mode)))

(defface paren-face
  '((((class color) (background dark))
     (:foreground "grey50"))
    (((class color) (background light))
     (:foreground "grey50")))
  "Face used to dim parentheses.")

(defface paren-face-2
  '((((class color) (background dark))
     (:foreground "grey50"))
    (((class color) (background light))
     (:foreground "grey50")))
  "Face used to dim parentheses.")

(setq fixme-modes '(markdown-mode cmake-mode text-mode c++-mode c-mode emacs-lisp-mode python-mode shell-script-mode sh-mode))

(make-face 'font-lock-todo-face)
(make-face 'font-lock-fixme-face)
(make-face 'font-lock-note-face)
(make-face 'font-lock-done-face)
(make-face 'font-lock-study-face)

(mapc (lambda (mode)
        (font-lock-add-keywords
         mode
         '(("\\<\\(TODO\\)" 1 'font-lock-todo-face t)
           ("\\<\\(todo\\)" 1 'font-lock-todo-face t)
           ("\\<\\(FIXME\\)" 1 'font-lock-fixme-face t)
           ("\\<\\(fixme\\)" 1 'font-lock-fixme-face t)
           ("\\<\\(NOTE\\)" 1 'font-lock-note-face t)
           ("\\<\\(note\\)" 1 'font-lock-note-face t)
           ("\\<\\(DONE\\)" 1 'font-lock-done-face t)
           ("\\<\\(done\\)" 1 'font-lock-done-face t)
           ("\\<\\(STUDY\\)" 1 'font-lock-study-face t)
           ("\\<\\(study\\)" 1 'font-lock-study-face t)
           )
         ))
      fixme-modes)

(modify-face 'font-lock-fixme-face "Red" nil nil t nil t nil nil)
(modify-face 'font-lock-todo-face "Orange" nil nil t nil t nil nil)
(modify-face 'font-lock-note-face "Green" nil nil t nil t nil nil)
(modify-face 'font-lock-done-face "Green" nil nil t nil t nil nil)
(modify-face 'font-lock-study-face "Blue" nil nil t nil t nil nil)


(add-hook 'c-mode-common-hook (lambda () (font-lock-add-keywords nil 
                                                                 '(("(\\|)" . 'paren-face)
                                                                   ("\\[\\|]" . 'paren-face)
                                                                   ("{\\|}" . 'paren-face-2)))))
(add-hook 'c++-mode-common-hook (lambda () (font-lock-add-keywords nil 
                                                                   '(("(\\|)" . 'paren-face)
                                                                     ("\\[\\|]" . 'paren-face)

                                                                     ("{\\|}" . 'paren-face-2)))))


(add-hook 'python-mode-common-hook (lambda () (font-lock-add-keywords nil 
                                                                      '(("(\\|)" . 'paren-face)
                                                                        ("\\[\\|]" . 'paren-face)

                                                                        ("{\\|}" . 'paren-face-2)))))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Fira Code" :foundry "CTDB" :slant normal :weight normal :height 120 :width normal))))
 '(highlight ((t (:background "dim gray"))))
 '(hl-line ((t (:background "#898989"))))
 '(hl-tags-face ((t (:inherit highlight))))
 '(region ((t (:background "dimgray"))))
 '(show-paren-match ((t (:background "#404040")))))
(put 'upcase-region 'disabled nil)



;;===================
;; Path to nano emacs modules (mandatory)
;;(add-to-list 'load-path "./nano-emacs")
;;(add-to-list 'load-path ".")

;; Window layout (optional)
;;(require 'nano-layout)

;; ;; Theming Command line options (this will cancel warning messages)
;; (add-to-list 'command-switch-alist '("-dark"   . (lambda (args))))
;; (add-to-list 'command-switch-alist '("-light"  . (lambda (args))))
;; (add-to-list 'command-switch-alist '("-default"  . (lambda (args))))

;; (cond
;;  ((member "-default" command-line-args) t)
;;  ((member "-light" command-line-args) (require 'nano-theme-light))
;;  (t (require 'nano-theme-dark)))

;; ;; Customize support for 'emacs -q' (Optional)
;; ;; You can enable customizations by creating the nano-custom.el file
;; ;; with e.g. `touch nano-custom.el` in the folder containing this file.
;; (let* ((this-file  (or load-file-name (buffer-file-name)))
;;        (this-dir  (file-name-directory this-file))
;;        (custom-path  (concat this-dir "nano-custom.el")))
;;   (when (and (eq nil user-init-file)
;;              (eq nil custom-file)
;;              (file-exists-p custom-path))
;;     (setq user-init-file this-file)
;;     (setq custom-file custom-path)
;;     (load custom-file)))

;; Theme
;; (require 'nano-faces)
;; (nano-faces)

;; (require 'nano-theme)
;; (nano-theme)

;; Nano default settings (optional)
;;(require 'nano-defaults)

;; Nano session saving (optional)
;;(require 'nano-session)

;; Nano header & mode lines (optional)
;;(require 'nano-modeline)

;; Nano key bindings modification (optional)
;;(require 'nano-bindings)

;; Nano counsel configuration (optional)
;; Needs "counsel" package to be installed (M-x: package-install)
;; (require 'nano-counsel)

;; ;; Welcome message (optional)
;; (let ((inhibit-message t))
;;   (message "Welcome to GNU Emacs / N Λ N O edition")
;;   (message (format "Initialization time: %s" (emacs-init-time))))

;; ;; Splash (optional)
;; (add-to-list 'command-switch-alist '("-no-splash" . (lambda (args))))
;; (unless (member "-no-splash" command-line-args)
;;   (require 'nano-splash))

;; ;; Help (optional)
;; (add-to-list 'command-switch-alist '("-no-help" . (lambda (args))))
;; (unless (member "-no-help" command-line-args)
;;   (require 'nano-help))

;;(provide 'nano)
;;===================
