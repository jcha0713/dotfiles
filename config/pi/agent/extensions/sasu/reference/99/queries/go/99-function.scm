(function_declaration) @context.function
(method_declaration) @context.function
(func_literal) @context.function

(function_declaration
  body: (block) @context.body)

(method_declaration
  body: (block) @context.body)

(func_literal
  body: (block) @context.body)
