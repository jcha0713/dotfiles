
;; Query to extract require paths from local variable declarations
(variable_declaration
  (assignment_statement
    (expression_list
      (function_call
        name: (identifier) @func_name (#eq? @func_name "require")
        arguments: (arguments
          (string
            content: (string_content) @import.name)))))) @import.decl
