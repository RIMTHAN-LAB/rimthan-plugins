Create a new Express middleware following team conventions.

Please generate:

1. Middleware function with TypeScript
2. Proper typing for Request/Response/NextFunction
3. Error handling with proper error propagation
4. Unit tests with supertest or similar
5. JSDoc documentation with usage examples

Middleware specifications:
- Name: {{name}}
- Location: src/middleware/{{name}}.ts
- Include proper TypeScript types
- Handle errors gracefully
- Add logging for debugging
- Write comprehensive unit tests
- Include usage examples in comments

The middleware should:
- Follow Express middleware signature: (req, res, next)
- Call next() appropriately (or pass errors to error handler)
- Handle async operations properly
- Include proper error handling
- Be reusable and configurable
- Include thorough documentation

Test the middleware with various scenarios:
- Success cases
- Error cases
- Edge cases
- Async operation handling
