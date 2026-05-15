# Project: byol-node-express

This project is a "Bring Your Own Language" (BYOL) starter for a Node.js + Express application that needs to be adapted for AWS Lambda. The goal is to move the existing Express application to a serverless architecture with minimal code or configuration changes.

## Project Overview

- **Purpose:** Adapt a framework-pure Express application to run on AWS Lambda.
- **Main Technologies:**
    - **Node.js 22.x:** The runtime environment.
    - **Express 4.x:** The web framework for application logic.
    - **AWS SAM (Serverless Application Model):** For building and deploying the serverless stack.
    - **AWS Lambda:** The target compute service.
- **Architecture:**
    - `app.js`: Contains the Express application logic. It is intentionally kept independent of Lambda-specific code.
    - `server.js`: A local development runner that starts a standard HTTP server on port 3000.
    - `template.yaml`: The AWS SAM template that defines the Lambda function, HTTP API, and logs. It contains `TODO` markers for integration strategies.

## Building and Running

### Local Development

1. **Install Dependencies:**
   ```bash
   npm install
   ```

2. **Start Local Server:**
   ```bash
   npm start
   ```
   The application will be accessible at `http://localhost:3000`.

3. **Smoke Test Local:**
   ```bash
   curl http://localhost:3000/
   curl http://localhost:3000/api/hello/Lan
   curl -X POST http://localhost:3000/api/echo -H 'Content-Type: application/json' -d '{"hi":"there"}'
   ```

### Serverless Deployment (AWS SAM)

1. **Build the Application:**
   ```bash
   sam build
   ```

2. **Deploy (First Time):**
   ```bash
   sam deploy --guided
   ```
   *Note: Ensure the region is set to `us-west-2`.*

3. **Subsequent Deploys:**
   ```bash
   sam deploy
   ```

4. **Teardown:**
   ```bash
   sam delete --stack-name byol-node-express --region us-west-2
   ```

## Development Conventions

- **Separation of Concerns:** Keep `app.js` "framework-pure." Do not import Lambda-specific adapters or handlers within this file.
- **Adaptation Strategy:** Use an entrypoint file (e.g., `lambda.js`) or the AWS Lambda Web Adapter to bridge Express and Lambda.
- **Naming Conventions:**
    - Main app logic: `app.js`
    - Local runner: `server.js`
    - AWS SAM template: `template.yaml`
- **Region:** The project is configured for `us-west-2` by default.

## Deployment Strategies (from README)

- **Strategy A:** `serverless-http` adapter (Requires a new `lambda.js` file).
- **Strategy B:** `@vendia/serverless-express` adapter (Requires a new file).
- **Strategy C:** **AWS Lambda Web Adapter** (Requires editing `template.yaml` to include a Layer and setting `AWS_LWA_PORT`).
- **Strategy D:** Roll your own manual event translation.
