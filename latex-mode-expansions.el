;;; latex-mode-expansions.el --- LaTeX-specific expansions for expand-region

;; Copyright (C) 2012 Ivan Andrus

;; Author: Ivan Andrus
;; Based on js-mode-expansions by: Magnar Sveen <magnars@gmail.com>
;; Keywords: marking region

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This is for AUCTeX, not the builtin latex-mode.

;; Feel free to contribute any other expansions for LaTeX at
;;
;;     https://github.com/magnars/expand-region.el

;;; Code:

(require 'expand-region-core)

(defun er/mark-LaTeX-inside-environment ()
  "Like `LaTeX-mark-environment' but marks the inside of the environment.
Skips past [] and {} arguments to the environment."
  (interactive)
  (LaTeX-mark-environment)
  (when (looking-at "\\\\begin{")
    (forward-sexp 2)
    ;; Assume these are arguments
    (while (looking-at "[ \t\n]*[{[]")
      (forward-sexp 1))
    ;; Go to next line if there is nothing interesting on this one
    (skip-syntax-forward " ") ;; newlines are ">" i.e. end comment
    (when (looking-at "%\\|$")
      (forward-line))
    ;; Clean up the end portion
    (exchange-point-and-mark)
    (backward-sexp 2)
    (skip-syntax-backward " ")
    (exchange-point-and-mark)))

(defun er/mark-LaTeX-environment ()
  (if (not (looking-at "\\\\begin{"))
      (LaTeX-mark-environment)
    (set-mark (point))
    (forward-char)
    (LaTeX-find-matching-end)
    (exchange-point-and-mark)))

(defun er/mark-LaTeX-math ()
  "Mark current math environment."
  (interactive)
  (cond
   ((texmathp)
    (let* ((string (car texmathp-why))
           (pos (cdr texmathp-why))
           (reason (assoc string texmathp-tex-commands1))
           (type (cadr reason)))
      (cond
       ((eq type 'env-on) ;; environments equation, align, etc.
        (er/mark-LaTeX-inside-environment))
       ((eq type 'arg-on) ;; \ensuremath etc.
        (goto-char pos)
        (set-mark (point))
        (forward-sexp 2)
        (exchange-point-and-mark))
       ((eq type 'sw-toggle) ;; $ and $$
        (goto-char pos)
        (set-mark (point))
        (forward-sexp 1)
        (exchange-point-and-mark))
       ((eq type 'sw-on) ;; \( and \[
        (re-search-forward texmathp-onoff-regexp)
        (set-mark pos)
        (exchange-point-and-mark))
       (t (error (format "Unknown reason to be in math mode: %s" type))))))
   ((looking-at "\\$")
    (forward-char)
    (er/mark-LaTeX-math))
   ((looking-back "\\$")
    (backward-sexp)
    (er/mark-LaTeX-math))))

(defun er/add-latex-mode-expansions ()
  "Adds expansions for buffers in latex-mode"
  (set (make-local-variable 'er/try-expand-list)
       (append
        er/try-expand-list
        '(er/mark-LaTeX-environment
          ;;LaTeX-mark-section
          er/mark-LaTeX-inside-environment
          er/mark-LaTeX-math))))

(er/enable-mode-expansions 'LaTeX-mode 'er/add-latex-mode-expansions)

(provide 'latex-mode-expansions)

;; latex-mode-expansions.el ends here
