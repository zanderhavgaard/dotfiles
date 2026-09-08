; Helix highlight queries for KCL (https://github.com/kcl-lang/tree-sitter-kcl).
;
; Adapted from the grammar's own queries/highlights.scm (written for neovim).
; Helix uses its own capture names, and when several patterns capture the same
; node the FIRST one in this file wins — so specific patterns come before the
; generic fallbacks at the bottom.

; --- strings / comments -------------------------------------------------------

(comment) @comment

; schema docstring: a bare string as the first statement of the schema body
(schema_stmt
  body: (block
    .
    (string
      (string_content) @comment.block.documentation)))

; second argument is a regex in all regex functions with at least two arguments
(call_expr
  function: (selector_expr
    (identifier) @_regex)
  arguments: (argument_list
    (_)
    .
    (string
      (string_content) @string.regexp))
  (#eq? @_regex "regex"))

; first argument is a regex in `regex.compile`
(call_expr
  .
  function: (selector_expr
    (identifier) @_regex
    (select_suffix
      (identifier) @_fn
      (#eq? @_fn "compile")))
  arguments: (argument_list
    (string
      (string_content) @string.regexp))
  (#eq? @_regex "regex"))

(escape_sequence) @constant.character.escape

(string) @string

(interpolation
  "${" @punctuation.special
  "}" @punctuation.special)

; --- imports / namespaces -----------------------------------------------------

(import_stmt
  (dotted_name
    (identifier) @namespace)
  (identifier) @namespace)

(import_stmt
  (dotted_name
    (identifier) @namespace))

; --- types --------------------------------------------------------------------

(basic_type) @type.builtin

(schema_type
  (dotted_name
    (identifier) @namespace
    (identifier) @type))

(schema_type
  (dotted_name
    (identifier) @type))

(schema_expr
  (identifier) @type)

(protocol_stmt
  (identifier) @type)

(rule_stmt
  (identifier) @type)

(schema_stmt
  (identifier) @type)

; --- functions / attributes / members ----------------------------------------

(decorator
  (identifier) @attribute)

(call_expr
  function: (identifier) @function)

(call_expr
  function: (selector_expr
    (select_suffix
      (identifier) @function)))

(lambda_expr
  (typed_parameter
    (identifier) @variable.parameter))

(lambda_expr
  (identifier) @variable.parameter)

(selector_expr
  (select_suffix
    (identifier) @variable.other.member))

; --- literals -----------------------------------------------------------------

(integer) @constant.numeric.integer

(float) @constant.numeric.float

[
  (true)
  (false)
] @constant.builtin.boolean

[
  (none)
  (undefined)
] @constant.builtin

; --- keywords -----------------------------------------------------------------

[
  "if"
  "elif"
  "else"
] @keyword.control.conditional

"for" @keyword.control.repeat

[
  "import"
  "as"
] @keyword.control.import

"lambda" @keyword.function

[
  "schema"
  "protocol"
  "rule"
  "mixin"
  "type"
] @keyword.storage.type

[
  "all"
  "any"
  "filter"
  "map"
  "assert"
  "check"
] @keyword

[
  "and"
  "or"
  "not"
  "in"
  "is"
] @keyword.operator

; --- operators / punctuation --------------------------------------------------

[
  "+"
  "-"
  "*"
  "**"
  "/"
  "//"
  "%"
  "<<"
  ">>"
  "&"
  "|"
  "^"
  "<"
  ">"
  "~"
  "<="
  ">="
  "=="
  "!="
  "@"
  "="
  ":"
] @operator

[
  "("
  ")"
  "["
  "]"
  "{"
  "}"
] @punctuation.bracket

; --- fallback -----------------------------------------------------------------

(identifier) @variable
