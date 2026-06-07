// server.js
import express from 'express';
import fetch from 'node-fetch';
import bodyParser from 'body-parser';
import dotenv from 'dotenv';
dotenv.config();

const app = express();
app.use(bodyParser.json({ limit: '1mb' }));

const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
const PORT = process.env.PORT || 3000;

if (!GEMINI_API_KEY) {
  console.error('GEMINI_API_KEY not set in env. Exiting.');
  process.exit(1);
}

// Helper: call Gemini generateContent with responseSchema
async function callGeminiForSummary(briefRecords, commodity, location) {
  const promptText = `
You are a JSON-output assistant. Given the following mandi records for commodity "${commodity ?? 'ALL'}", produce a JSON object with these fields:
{
  "commodity": string,
  "num_markets": integer,
  "avg_price_per_kg": number,
  "top_3_markets": [{"market": string, "price_per_kg": number}],
  "trend": "Up"|"Down"|"Mixed",
  "short_summary": string
}
Records: ${JSON.stringify(briefRecords)}
Only return valid JSON that exactly matches the schema.
`;

  const url =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=' +
    encodeURIComponent(GEMINI_API_KEY);

  const body = {
    contents: [
      {
        role: 'user',
        parts: [{ text: promptText }]
      }
    ],
    // recommend low temperature for deterministic numeric output
    temperature: 0.0,
    maxOutputTokens: 512
  };

  const resp = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });

  const text = await resp.text();
  if (!resp.ok) {
    throw new Error(`Gemini API error ${resp.status}: ${text}`);
  }

  // Try to locate JSON in response text (Gemini responses may wrap text)
  // Try parse as JSON directly
  try {
    const parsed = JSON.parse(text);
    // If result contains outputs, extract likely textual content and parse
    if (parsed?.outputs) {
      // outputs[].content[] may contain text parts
      for (const out of parsed.outputs) {
        if (out.content && Array.isArray(out.content)) {
          for (const part of out.content) {
            const possible = part?.text ?? part?.text?.toString();
            if (possible) {
              try {
                return JSON.parse(possible);
              } catch (_) {
                // continue
              }
            }
          }
        }
      }
    }
    // fallback: if parsed is already the JSON summary, return it
    return parsed;
  } catch (_) {
    // Not direct JSON — try to extract first {...} substring from text
    const first = text.indexOf('{');
    const last = text.lastIndexOf('}');
    if (first !== -1 && last !== -1 && last > first) {
      const sub = text.substring(first, last + 1);
      try {
        return JSON.parse(sub);
      } catch (e) {
        // final fallback: return raw text
        return { raw_text: text };
      }
    }
  }

  return { raw_text: text };
}

app.post('/api/gemini/summarize', async (req, res) => {
  try {
    const { records, commodity, location } = req.body;
    if (!Array.isArray(records) || records.length === 0) {
      return res.status(400).json({ error: 'records (non-empty array) is required' });
    }

    // Prepare briefRecords: keep only the fields we need and limit to 25 items
    const briefRecords = records.slice(0, 25).map((r) => ({
      id: r.id ?? null,
      commodity: r.commodity ?? null,
      market: r.market ?? null,
      state: r.state ?? null,
      modal_price: r.modal_price_raw ?? r.modal_raw ?? null,
      price_per_kg: r.price_per_kg ?? null,
      trend: r.trend ?? null
    }));

    const generated = await callGeminiForSummary(briefRecords, commodity, location);
    return res.json({ ok: true, generated });
  } catch (err) {
    console.error('Error in /api/gemini/summarize', err);
    return res.status(500).json({ ok: false, error: err.toString() });
  }
});

app.get('/', (req, res) => res.send('Mandi Gemini proxy is working'));

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
