; extends

; Highlight embedded SQL: the raw text between Jinja tags is exposed as `content`.
((content) @injection.content
  (#set! injection.language "sql"))
