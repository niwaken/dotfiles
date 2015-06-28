(set-language-environment 'Japanese)
(prefer-coding-system 'utf-8)


;; load-path用の関数
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

;; Macのみの設定
(when (eq system-type 'darwin)
  ;; CmdとOptionの入替
  (setq ns-command-modifier (quote meta))
  (setq ns-alternate-modifier (quote super))
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
         '(width . 160) ;; ウィンドウ幅
         '(height . 65) ;; ウィンドウの高さ
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
(set-face-underline-p 'show-paren-match-face "yellow")

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
(require 'helm-config)
(helm-mode 1)


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
(add-hook 'haskell-mode-hook 'haskell-indent-mode)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)