# Converting Rails Routes Output into OpenAPI v3.1

In an effort to learn a little bit about Ruby and Rails, I decided a fun project would be to attempt generating a YAML file that aligns with the [OpenAPI v3.1.0 specification](https://spec.openapis.org/oas/v3.1.1.html). This file can then be imported into [Postman](https://www.postman.com/) so you can test Rails routes without manually using the Rails console or the consuming frontend application.

## Quick Start

1. Add the gem to your Gemfile:

```ruby
gem 'rails_routes_to_openapi'
```

2. Install dependencies:

```shell
bundle install
```

3. Run the conversion task:

```shell
bundle exec rake routes_to_openapi:convert
```

This task will internally run `rails routes` on your Rails application and generate an OpenAPI YAML file named similar to `openapi_v3.1_YYYYMMDDHHMMSS.yml` in the project root.

> [!WARNING]
> **Tip:** Ensure you run the task within a Rails project context so that it can properly pull the routes.

## Workflow Overview

1. **Routes Processing**  
   The conversion workflow starts by reading the output of `rails routes`, splitting it into lines, and filtering out header information. A helper module parses each line into a structured `RouteInfo` object that captures the HTTP verb, URI pattern, and the associated controller action.

2. **OpenAPI Generation**  
   The parsed routes are then converted into an OpenAPI compliant hash. The conversion process does the following:

   - It adapts URL parameters (e.g., turning `/a/b/:param/d` into `/a/b/{param}`).
   - For non-GET verbs, it attaches a default request body schema.
   - Finally, it merges the above details into an OpenAPI compliant hash which is then dumped into YAML format.

3. **Output**  
   The generated YAML file contains:
   - OpenAPI version information.
   - Descriptive metadata (title, description, version, etc.).
   - A list of servers.
   - A paths list that maps each route to its HTTP verb and summary (derived from the controller action).

## Example OpenAPI YAML Output

Below is an abbreviated snippet of what the output might look like:

```yaml
openapi: 3.1.0
info:
  title: Rails Routes to OpenAPI
  description: Generate an OpenAPI v3.1 YAML file
  version: "1.1.0"
servers:
  - url: "https://api.example.com"
    description: "Base URL for the API"
paths:
  "/":
    get:
      summary: "home#show"
  "/path/to/authorize/native":
    get:
      summary: "doorkeeper/authorizations#show"
  "/path/to/authorize":
    get:
      summary: "doorkeeper/authorizations#new"
    delete:
      summary: "doorkeeper/authorizations#destroy"
      requestBody:
        required: true
        content:
          "application/json":
            schema:
              type: object
              properties:
                id:
                  type: string
                  format: string
```
