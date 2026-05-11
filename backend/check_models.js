const { GoogleGenerativeAI } = require('@google/generative-ai');
require('dotenv').config();

async function listModels() {
  const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  try {
    console.log('Fetching available models...');
    // Note: listModels is not on the genAI object directly in some versions, 
    // it's a separate discovery step. We'll try to fetch the list via REST if needed.
    // But first, let's try gemini-1.5-flash-latest
    console.log('Testing gemini-1.5-flash-latest...');
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash-latest" });
    const result = await model.generateContent("hi");
    console.log('SUCCESS with gemini-1.5-flash-latest');
  } catch (e) {
    console.log('FAILED with gemini-1.5-flash-latest');
    try {
        console.log('Testing gemini-1.0-pro...');
        const model2 = genAI.getGenerativeModel({ model: "gemini-1.0-pro" });
        const result2 = await model2.generateContent("hi");
        console.log('SUCCESS with gemini-1.0-pro');
    } catch (e2) {
        console.log('FAILED with gemini-1.0-pro');
        console.log('Final Error:', e2.message);
    }
  }
}

listModels();
