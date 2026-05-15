# BYOL Node.js Express Deployment Notes

## Strategy Selected
**Strategy C: AWS Lambda Web Adapter**

## Reasoning
This strategy was chosen because it is the most non-intrusive method for adapting an existing web application to AWS Lambda.
- **Zero JS Code Changes:** The core application logic in `app.js` and `server.js` remains untouched.
- **Portability:** The application can still be run locally or on traditional servers without any Lambda-specific dependencies.
- **Ease of Use:** It leverages a Lambda Layer to handle the translation between Lambda events and standard HTTP requests, allowing Express to function as intended.

## Cold Start Measurement
Based on CloudWatch logs (`REPORT` line):
- **Init Duration:** 393.35 ms

## Deployment Details
- **Tooling:** AWS SAM (installed via pip)
- **Runtime:** Node.js 22.x
- **Architecture:** arm64
- **API URL:** https://x44i9e7wk1.execute-api.us-west-2.amazonaws.com/
