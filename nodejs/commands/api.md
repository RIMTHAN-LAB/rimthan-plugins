Create a new API endpoint following team conventions.

Please generate:

1. Express route handler with TypeScript
2. Request validation middleware (using Zod, Joi, or express-validator)
3. Response schemas with proper typing
4. Error handling
5. Unit and integration tests
6. OpenAPI/Swagger documentation

Endpoint specifications:
- Route: {{route}}
- Method: {{method}}
- Location: src/routes/{{name}}.ts
- Include proper TypeScript types
- Add request validation
- Implement comprehensive error handling
- Add rate limiting configuration
- Include OpenAPI/Swagger docs
- Write comprehensive tests

Additional considerations:
- Authentication/authorization middleware
- Input sanitization and validation
- Response formatting (consistent structure)
- Request logging
- Performance optimization (caching if applicable)

Follow RESTful API best practices and team coding standards.
