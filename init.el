;; Set the size of the initial window, width in chars, height in rows 
(setq initial-frame-alist '((width . 100) (height . 30)))


(require 'package) (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
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

(with-eval-after-load 'python
  (defun python-shell-completion-native-try ()
    "Return non-nil if can trigger native completion."
    (let ((python-shell-completion-native-enable t)
          (python-shell-completion-native-output-timeout
           python-shell-completion-native-try-output-timeout))
      (python-shell-completion-native-get-completions
       (get-buffer-process (current-buffer))
       nil "_"))))

(when (executable-find "ipython")
  (setq python-shell-interpreter "ipython"))

;; Change padding of the tabs
;; we also need to set separator to avoid overlapping tabs by highlighted tabs
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (clang-format+ highlight-doxygen multiple-cursors irony-eldoc yasnippet use-package tabbar sphinx-doc solarized-theme smartparens popup-complete matlab-mode markdown-mode magit lua-mode json-mode jedi iedit idle-highlight-mode highlight-symbol google-c-style go-mode flymake-python-pyflakes flymake-json flymake-cursor flycheck-irony flx-ido fill-column-indicator f diminish company-irony color-theme-sanityinc-solarized color-theme cmake-mode cmake-ide clang-format bm autopair))))

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


(define-key
  c-mode-base-map
  (kbd "C-x C-s")
  'format-and-save)

;; (add-hook 'c-common-mode-hook 
;;           (lambda ()
;;             (add-hook (make-local-variable 'before-save-hook)
;;                       'clang-format-buffer)))

;; create dir automatically ceate new file
(defadvice find-file (before make-directory-maybe (filename &optional wildcards) activate)
  "Create parent directory if not exists while visiting file."
  (unless (file-exists-p filename)
    (let ((dir (file-name-directory filename)))
      (unless (file-exists-p dir)
        (make-directory dir)))))


(defun duplicate-line()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (yank)
  )

;; Open files and goto lines like we see from g++ etc. i.e. file:line#
;; (to-do "make `find-file-line-number' work for emacsclient as well")
;; (to-do "make `find-file-line-number' check if the file exists")
(defadvice find-file (around find-file-line-number
                             (filename &optional wildcards)
                             activate)
  "Turn files like file.cpp:14 into file.cpp and going to the 14-th line."
  (save-match-data
    (let* ((matched (string-match "^\\(.*\\):\\([0-9]+\\):?$" filename))
           (line-number (and matched
                             (match-string 2 filename)
                             (string-to-number (match-string 2 filename))))
           (filename (if matched (match-string 1 filename) filename)))
      ad-do-it
      (when line-number
        ;; goto-line is for interactive use
        (goto-char (point-min))
        (forward-line (1- line-number))))))

(global-set-key (kbd "M-n") 'duplicate-line)

(add-hook 'python-mode-hook (lambda ()
                              (require 'sphinx-doc)
                              (sphinx-doc-mode t)))

;; ;; hightlight current line
;; ;; (global-hl-line-mode 1)

(add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++14")))
(add-hook 'c++-mode-hook (lambda () (setq flycheck-clang-language-standard "c++14")))

;; delete selection
(delete-selection-mode 1)
;; line by line scrolling
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

(require 'color-theme)
(color-theme-initialize)
;;(load-theme solarized-dark)
;; (color-theme-deep-blue)
(color-theme-calm-forest)
;; (load-theme 'tango-plus t)
;; (load-theme 'hemisu-light t)
;; (load-theme 'hemisu-dark t)
;;(load-file "~/.emacs.d/color-theme-almost-monokai.el")
;;(color-theme-almost-monokai)
;;(color-theme-emacs-21)

;; ;; (load-file "~/.emacs.d/hl-tags-mode.el")
;; ;; (require 'hl-tags-mode)
;; ;; (add-hook 'sgml-mode-hook (lambda () (hl-tags-mode 1)))
;; ;; (add-hook 'nxml-mode-hook (lambda () (hl-tags-mode 1)))

;; ;; (add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
;; ;; (load-theme 'spolsky t)

;; ;;(package-initialize)
;; ;;(load-theme 'solarized-dark t)

;; ;;(load-file "~/.emacs.d/.el")
;; ;;(load-theme 'material t)

;; create dir automatically ceate new file
(defadvice find-file (before make-directory-maybe (filename &optional wildcards) activate)
  "Create parent directory if not exists while visiting file."
  (unless (file-exists-p filename)
    (let ((dir (file-name-directory filename)))
      (unless (file-exists-p dir)
        (make-directory dir)))))

;; ;; Set as a minor mode for Python
;; ;;(add-hook 'python-mode-hook '(lambda () (flymake-mode)))

(defface paren-face
  '((((class color) (background dark))
     (:foreground "grey30"))
    (((class color) (background light))
     (:foreground "grey30")))
  "Face used to dim parentheses.")

(defface paren-face-2
  '((((class color) (background dark))
     (:foreground "grey30"))
    (((class color) (background light))
     (:foreground "grey30")))
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
           ("\\<\\(FIXME\\)" 1 'font-lock-fixme-face t)
           ("\\<\\(NOTE\\)" 1 'font-lock-note-face t)
           ("\\<\\(DONE\\)" 1 'font-lock-done-face t)
           ("\\<\\(STUDY\\)" 1 'font-lock-study-face t))))
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
 '(default ((t (:family "Fira Code" :foundry "unknown" :slant normal :weight normal :height 120 :width normal))))
 '(highlight ((t (:background "dim gray"))))
 '(hl-line ((t (:background "#898989"))))
 '(hl-tags-face ((t (:inherit highlight))))
 '(region ((t (:background "dimgray"))))
 '(show-paren-match ((t (:background "#404040")))))
(put 'upcase-region 'disabled nil)
