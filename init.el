;;; package --- my init.el
;;; Code:
(set-language-environment 'Japanese)
(prefer-coding-system 'utf-8)


;;; Commentary: load-path用の関数
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
          (expand-file-name (concat user-emacs-directory path))))
    (add-to-list 'load-path default-directory)
    (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
        (normal-top-level-add-subdirs-to-load-path))))))

;; load-pathにディレクトリ追加
(add-to-load-path "elisp" "conf" "public_repos")

;; Package取得先追加
(require 'package)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
;;(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
(package-initialize)


;; init-loader
(require 'init-loader)
(init-loader-load "~/.emacs.d/conf")

;;; emacs 23以下の互換
(when (< emacs-major-version 24)
  (defalias 'prog-mode 'fundamental-mode))


;; Command-Path
(dolist (dir (list
              "/sbin"
              "/usr/sbin"
              "/bin"
              "/usr/bin"
              "/usr/local/bin"
              (expand-file-name "~/bin")
              ))
 (when (and (file-exists-p dir) (not (member dir exec-path)))
   (setenv "PATH" (concat dir ":" (getenv "PATH")))
   (setq exec-path (append (list dir) exec-path))))

;; racer for rust env
(setq racer-rust-src-path "/usr/local/src/rustc-1.11.0/src/")
(setq racer-cmd "/usr/local/rust/racer/target/release/racer")
;;(add-to-list 'load-path "/usr/local/rust/racer/editors/emacs")
(eval-after-load "rust-mode" '(require 'racer))

;; ido-vertical
(require 'ido-vertical-mode)
(ido-mode 1)
(ido-vertical-mode 1)
(setq ido-vertical-define-keys 'C-n-and-C-p-only)

;; Macのみの設定
(when (eq system-type 'darwin)
  ;; CmdとOptionの入替
;;  (setq ns-command-modifier (quote meta))
;;  (setq ns-alternate-modifier (quote super))
  (require 'ucs-normalize)
  (set-file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs))

;; KeyMap関連
(global-set-key (kbd "C-m") 'newline-and-indent) ;;改行と同時にインデント
(define-key global-map (kbd "C-t") 'next-buffer) ;; Ctrl-tでバッファ切り替え

;; WindowSystemのみでの設定
(when window-system
  ;; 表示位置とバックカラー、初期表示サイズなど調整
  (setq initial-frame-alist
    (append (list
         '(foreground-color . "azure3") ;; 文字が白
         '(background-color . "black") ;; 背景は黒
         '(border-color     . "black")
         '(mouse-color      . "white")
         '(cursor-color     . "gray")
         '(cursor-type      . box)
         '(menu-bar-lines . 1)
         '(width . 125) ;; ウィンドウ幅
         '(height . 50) ;; ウィンドウの高さ
         '(top . 0) ;;表示位置
         '(left . 10) ;;表示位置
         )
        initial-frame-alist))
  (setq default-frame-alist initial-frame-alist)
  (tool-bar-mode 0)
  ;;フォントの設定
  (create-fontset-from-ascii-font "Menlo-14:weight=normal:slant=normal" nil "menlokakugo")
  (set-fontset-font "fontset-menlokakugo"
            'unicode
            (font-spec :family "Hiragino Kaku Gothic ProN" :size 14)
            nil
            'append)
  (add-to-list 'default-frame-alist '(font . "fontset-menlokakugo"))

  ;; ファイルのドラッグ&ドロップ
  (define-key global-map [ns-drag-file] 'ns-find-file)
)

;;全角スペースとかに色を付ける
(defface my-face-b-1 '((t (:background "medium aquamarine"))) nil)
(defface my-face-b-1 '((t (:background "dark turquoise"))) nil)
(defface my-face-b-2 '((t (:background "gray30"))) nil)
(defface my-face-b-2 '((t (:background "SeaGreen"))) nil)
(defface my-face-u-1 '((t (:foreground "SteelBlue" :underline t))) nil)
(defvar my-face-b-1 'my-face-b-1)
(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-u-1 'my-face-u-1)
(defadvice font-lock-mode (before my-font-lock-mode ())
            (font-lock-add-keywords
                 major-mode
                    '(
                           ("　" 0 my-face-b-1 append)
                           ("\t" 0 my-face-b-2 append)
                           ("[ ]+$" 0 my-face-u-1 append)
          )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)
(add-hook 'find-file-hooks '(lambda ()
                             (if font-lock-mode
                               nil
                               (font-lock-mode t))));

;; Tab周り設定
(setq-default tab-width 4) ;; tab=4
(setq-default indent-tabs-mode nil) ;; not use tab-character at indent


;; 対応する括弧を光らせる。
(show-paren-mode 1)
(setq show-paren-style 'expression)
(set-face-background 'show-paren-match-face nil)
(set-face-underline-p 'show-paren-match-face "green")
;; 括弧自動挿入
(electric-pair-mode 1)

;; テキスト表示周り設定
(global-hl-line-mode) ;; 編集行のハイライト
(setq require-final-newline t) ;; ファイル末の改行がなければ追加
(setq truncate-partial-width-windows nil) ;; はみ出る文章折り返し

;; 表示周り設定
(column-number-mode t)
(size-indication-mode t)
(setq frame-title-format "%f")
(global-linum-mode t)


;; バックアップファイル作らない
(setq make-backup-files nil)
(setq auto-save-default nil)

;; helm-modeの読込と初期からの有効化
;;(require 'helm-config)
;;(helm-mode 1)


;; auto-complete
(require 'auto-complete)
(require 'auto-complete-config)    ; 必須ではないですが一応
(global-auto-complete-mode t)

;; web-mode
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

;; js2-mode
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

;; flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)

;; magit
(setq magit-auto-revert-mode nil)

;; haskell-mode
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
(add-hook 'haskell-mode-hook 'font-lock-mode)
(add-hook 'haskell-mode-hook 'imenu-add-menubar-index)

(add-hook 'haskell-mode-hook 'haskell-indent-mode)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
(add-to-list 'auto-mode-alist '("\\.hs$" . haskell-mode))
(add-to-list 'auto-mode-alist '("\\.lhs$" . literate-haskell-mode))
(add-to-list 'auto-mode-alist '("\\.cabal\\'" . haskell-cabal-mode))
(add-hook 'haskell-mode-hook 'haskell-indentation)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'font-lock-mode)
(add-hook 'haskell-mode-hook 'imenu-add-menubar-index)
(add-to-list 'interpreter-mode-alist '("runghc" . haskell-mode))
(add-to-list 'interpreter-mode-alist '("runhaskell" . haskell-mode))


;; markdown-mode
(autoload 'markdown-mode "markdown-mode.el" "Major mode for editing Markdown files" t)
(setq auto-mode-alist (cons '("\\.markdown" . markdown-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.md" . markdown-mode) auto-mode-alist))

;; golang
(require 'exec-path-from-shell)
(let ((envs '("PATH" "GOPATH")))
  (exec-path-from-shell-copy-envs envs))
(require 'go-autocomplete)
(require 'auto-complete-config)
(setq gofmt-command "goimports")
(add-hook 'before-save-hook 'gofmt-before-save)


;; racer fook
(add-hook 'rust-mode-hook
  '(lambda ()
     (racer-activate)
     (local-set-key (kbd "M-.") #'racer-find-definition)
     (local-set-key (kbd "TAB") #'racer-complete-or-indent)))

;; for ruby
(autoload 'ruby-mode "enh-ruby-mode"
  "Mode for editing ruby source files" t)
(add-to-list 'auto-mode-alist '("\\.rb$latex " . enh-ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . enh-ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . enh-ruby-mode))

;;(require 'ruby-electric)
;;(add-hook 'ruby-mode-hook '(lambda () (ruby-electric-mode t)))
;;(setq ruby-electric-expand-delimiters-list nil)

;; ruby-block.el --- highlight matching block
(require 'ruby-block)
(ruby-block-mode t)
(setq ruby-block-highlight-toggle t)


;; discover.el set global
(require 'discover)
(global-discover-mode 1)

;; projectile-rails
(require 'projectile)
(projectile-global-mode)
(require 'projectile-rails)
(add-hook 'ruby-mode-hook 'projectile-rails-on)
(add-hook 'projectile-mode-hook 'projectile-rails-on)
;;(add-to-list 'auto-mode-alist '("\\.erb\\'" . projectile-rails-on))

(require 'flymake-ruby)
(add-hook 'enh-ruby-mode-hook 'flymake-ruby-load)

;;(require 'robe)
;;(add-hook 'ruby-mode-hook 'robe-mode)

;;(global-company-mode t)
;;(push 'company-robe company-backends)

;; hydra for rails
(define-key projectile-rails-mode-map (kbd "s-r") 'hydra-projectile-rails/body)

;; for python
(setq py-python-command "python3")

;; smartparens
;;(require 'smartparens-config)
;;(smartparens-global-mode t)


;; for erlang
(add-hook 'erlang-mode-hook 'erlang-font-lock-level-4)

;; for elixir
(require 'elixir-mode)
(require 'alchemist)
(require 'flycheck-elixir)
(add-to-list 'elixir-mode-hook 'ac-alchemist-setup)

;; for docfile
(autoload 'dockerfile-mode "dockerfile-mode" nil t)
(add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))

(require 'inline-string-rectangle)
(global-set-key (kbd "C-x r t") 'inline-string-rectangle)

(require 'mark-more-like-this)
(global-set-key (kbd "C-<") 'mark-previous-like-this)
(global-set-key (kbd "C->") 'mark-next-like-this)
(global-set-key (kbd "C-M-m") 'mark-more-like-this) ; like the other two, but takes an argument (negative is previous)
(global-set-key (kbd "C-*") 'mark-all-like-this)

(provide 'init)
;;;

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (mark-multiple ruby-end flymake-ruby ido-vertical-mode nginx-mode hydra discover guide-key projectile-rails dockerfile-mode yaml-mode web-mode rust-mode ruby-block quickrun python-mode markdown-mode magit js2-mode go-eldoc go-autocomplete flycheck-rust flycheck-haskell flycheck-elixir exec-path-from-shell erlang enh-ruby-mode ac-alchemist))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

