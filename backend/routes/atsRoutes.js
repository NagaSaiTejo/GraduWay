const express = require('express');
const multer = require('multer');
const pdf = require('pdf-parse');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const router = express.Router();

// Keep uploads in memory to avoid temp file management for small PDFs.
const storage = multer.memoryStorage();
const upload = multer({
  storage,
  limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
});

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || '');
// Note: If you get a 404, ensure "Generative Language API" is enabled in your Google Cloud Console
const model = genAI.getGenerativeModel({ model: 'gemini-1.5-flash' });

const cleanJsonFence = (text) =>
  text.replace(/```json/g, '').replace(/```/g, '').trim();

router.post('/score', upload.single('resume'), async (req, res) => {
  try {
    const { jd } = req.body;

    if (!req.file) {
      return res.status(400).json({ message: 'Please upload a resume (PDF)' });
    }

    if (!jd || jd.trim().length < 20) {
      return res.status(400).json({ message: 'Please provide a detailed JD' });
    }

    if (!process.env.GEMINI_API_KEY) {
      return res.status(500).json({
        message: 'GEMINI_API_KEY is not configured on the server',
      });
    }

    const pdfData = await pdf(req.file.buffer);
    const resumeText = pdfData.text || '';

    const prompt = `
Act as an experienced ATS. Analyze the Resume against the Job Description.

Job Description:
"${jd}"

Resume:
"${resumeText}"

Return ONLY a valid JSON object with this exact structure:
{
  "score": 0-100,
  "strengths": ["..."],
  "weaknesses": ["..."],
  "missingKeywords": ["..."],
  "summary": "2-3 sentences"
}
`;

    // Smart Fallback: Try multiple models until one works
    const modelNames = ['gemini-1.5-flash', 'gemini-1.5-flash-latest', 'gemini-pro', 'gemini-2.0-flash', 'gemini-2.5-flash'];
    let result;
    let lastError;

    for (const modelName of modelNames) {
      try {
        console.log(`Trying model: ${modelName}...`);
        const tempModel = genAI.getGenerativeModel({ model: modelName });
        result = await tempModel.generateContent(prompt);
        if (result) break; // Success!
      } catch (e) {
        lastError = e;
        console.warn(`${modelName} failed, trying next...`);
      }
    }

    if (!result) throw lastError; // None of the models worked

    const response = await result.response;
    const raw = response.text();
    const cleaned = cleanJsonFence(raw);

    const analysis = JSON.parse(cleaned);
    return res.status(200).json(analysis);
  } catch (error) {
    console.error('ATS Error:', error);
    let errorMessage = error.message;
    if (error.status === 404) {
      errorMessage = 'Gemini Model not found. Check model name or API availability.';
    } else if (error.status === 429) {
      errorMessage = 'AI Speed Limit Reached. Please wait 60 seconds and try again.';
    } else if (error.message.includes('fetch failed')) {
      errorMessage = 'Network error: Backend could not reach Google AI servers.';
    }
    return res.status(500).json({
      message: 'Server error while analyzing resume',
      error: errorMessage,
    });
  }
});

module.exports = router;
