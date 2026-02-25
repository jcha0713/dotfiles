(method) @context.function
(singleton_method) @context.function
(lambda) @context.function

(method
  body: (body_statement) @context.body)

(singleton_method
  body: (body_statement) @context.body)

(lambda
  body: (block) @context.body)
