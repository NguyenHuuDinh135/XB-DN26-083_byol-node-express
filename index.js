// index.js - Dummy handler to satisfy the Node.js runtime. 
// The AWS Lambda Web Adapter wrapper (/opt/bootstrap) will intercept 
// the execution and start the Express server instead.
exports.handler = async (event) => {
  return {
    statusCode: 200,
    body: "Web Adapter failed to intercept request",
  };
};
