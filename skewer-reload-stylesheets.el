;;; skewer-reload-stylesheets.el --- live-edit CSS stylesheets.

;; This is free and unencumbered software released into the public domain.

;; Author: Nate Eagleson <nate@nateeag.com>
;; Created: November 23, 2013
;; Package-Requires: ((skewer-mode "1.5.3"))
;; Version: 0.1.0

;;; Commentary:

;; This minor mode provides live-editing of CSS stylesheets via skewer.
;; skewer-css works for many cases, but if you're dealing with multiple
;; stylesheets and involved cascading (a.k.a. "legacy code"), it isn't so
;; useful. What you see while live-editing is not what you see when you
;; refresh.

;; Enter this minor mode.

;; Start skewer (see its docs for how) then skewer the browser window you want
;; to live-edit.

;; Next, open a CSS file used on the skewered page, and activate this mode.
;; Make some edits then press `C-x C-r`. The stylesheet will be saved, and the
;; browser will reload it from disk, by updating the query string on the link
;; tag's href attribute.

;; and there you are - cross-browser live-editing for arbitrarily complex
;; stylesheets.

;; Key bindings:

;; * C-x C-r -- `skewer-reload-stylesheets-reload-buffer`

;;; Code:
(require 'skewer-mode)

(defvar skewer-reload-stylesheets-data-root (file-name-directory load-file-name)
  "Location of data files needed by skewer-reload-stylesheets-mode.")

(defun skewer-reload-stylesheets-reload-buffer ()
  "Save current buffer and ask skewer to reload it."

  (declare (obsolete skewer-reload-stylesheets-reload-on-save "0.1.0"))

  (interactive)
  (save-buffer)

  (skewer-reload-stylesheets-reload))

(defun skewer-reload-stylesheets-reload ()
  "Ask browser to reload the stylesheet for the current buffer."

  ;; TODO I tried to use skewer-apply, but it said skewer.reloadStylesheet was
  ;; not a valid function.
  (skewer-eval (concat "skewer.reloadStylesheet(\"" (buffer-file-name) "\");")))

(defun skewer-reload-stylesheets-reload-on-save ()
  "Ask skewer to reload stylesheets immediately after save.

Call this in your css-mode-hook to automatically reload stylesheets on save."

  (add-hook 'after-save-hook
            'skewer-reload-stylesheets-reload
            nil
            t))

(defun skewer-reload-stylesheets-skewer-js-hook ()
  "Skewer hook function to insert JS for reloading CSS files."

  (insert-file-contents
   (expand-file-name "skewer-reload-stylesheets.js" skewer-reload-stylesheets-data-root)))

(add-hook 'skewer-js-hook 'skewer-reload-stylesheets-skewer-js-hook)

;; Minor mode definition

(defvar skewer-reload-stylesheets-mode-map
  (let ((map (make-sparse-keymap)))
    (prog1 map
      (define-key map (kbd "C-x C-r") 'skewer-reload-stylesheets-reload-buffer)))
  "Keymap for skewer-reload-stylesheets-mode.")

;;;###autoload
(define-minor-mode skewer-reload-stylesheets-mode
  "Minor mode for interactively reloading CSS stylesheets."
  :lighter " reload-ss"
  :keymap skewer-reload-stylesheets-mode-map
  :group 'skewer)

(provide 'skewer-reload-stylesheets)
;;; skewer-reload-stylesheets.el ends here
