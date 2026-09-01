; Fold Jinja block constructs and multi-line comments.
; dbt macros ({% macro %}...{% endmacro %}) and {# ... #} doc-comments become
; foldable. SQL-statement folds inside `content` come from the injected sql parser.
[
  (macro_block)
  (if_block)
  (for_block)
  (set_block)
  (call_block)
  (filter_block)
  (block_block)
  (autoescape_block)
  (with_block)
  (raw_block)
  (comment)
] @fold
