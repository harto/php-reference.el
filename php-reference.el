;;; Emacs support for php-reference (https://github.com/harto/php-reference)

(defvar php-reference-cmd "php-reference"
  "Command used by `php-reference' to generate Markdown-formatted PHP reference
   documentation. Called with one argument (the designated PHP builtin).")

(defvar php-reference-cmd-opts '()
  "List of options to pass to `php-reference-cmd'.")

(defvar php-reference-buffer "*PHP Reference*"
  "Output buffer for `php-reference' command.")

(defun php-reference-read-symbol ()
  "Prompts for a PHP symbol, defaulting to symbol at point."
  (let* ((default-symbol (if (region-active-p)
                             (buffer-substring-no-properties (region-beginning)
                                                             (region-end))
                           (symbol-at-point)))
         (entered-symbol (read-from-minibuffer
                          (format "View docs for (default \"%s\"): "
                                  default-symbol))))
    (if (string-equal entered-symbol "")
        default-symbol
      entered-symbol)))

;;;###autoload
(defun php-reference (symbol)
  "Generates reference documentation for a PHP builtin using `php-reference-cmd'
   and displays it in `php-reference-buffer'. When called interactively, prompts
   for the PHP symbol to fetch docs for, default to symbol at point."
  (interactive
   (list (php-reference-read-symbol)))
  (message "Fetching PHP documentation for `%s'..." symbol)
  (shell-command (format "%s %s %s"
                         php-reference-cmd
                         (mapconcat #'identity php-reference-cmd-opts " ")
                         symbol)
                 php-reference-buffer)
  ;; Use markdown-mode where available
  (if (require 'markdown-mode nil t)
      (save-excursion
        (set-buffer php-reference-buffer)
        (markdown-mode)))
  (view-buffer-other-window php-reference-buffer nil #'kill-buffer))

(provide 'php-reference)
