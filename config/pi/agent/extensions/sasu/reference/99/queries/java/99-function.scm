(method_declaration) @context.function
(constructor_declaration) @context.function
(lambda_expression) @context.function
(compact_constructor_declaration) @context.function

(method_declaration
  body: (block) @context.body)

(constructor_declaration
  body: (constructor_body) @context.body)

(lambda_expression
  body: (block) @context.body)

(compact_constructor_declaration
  body: (block) @context.body)
