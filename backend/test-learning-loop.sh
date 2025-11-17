#!/bin/bash

# Test Learning Loop API endpoint
# Make sure the server is running first: node server.js

echo "🧠 Testing Learning Loop Generation API..."
echo ""

curl -X POST http://localhost:3001/api/learning-loop/generate \
  -H "Content-Type: application/json" \
  -d '{
    "clinical_text": "Patient presented with acute onset of progressive ataxia over 18 months. Clinical examination revealed slow saccadic eye movements and mild peripheral neuropathy. MRI brain showed significant cerebellar atrophy, particularly of the vermis. Family history was positive for similar neurological symptoms in the father. Based on the clinical presentation and imaging findings, I suspected spinocerebellar ataxia (SCA) type 2 or 3. I ordered a comprehensive genetic testing panel for SCAs. The genetic testing confirmed SCA type 3. The patient was referred to neurology for ongoing management and genetic counselling was arranged for family members."
  }' \
  | python3 -m json.tool

echo ""
echo "✅ Test complete!"
echo ""
echo "Expected response:"
echo "- success: true"
echo "- learning_loop with 7 sections:"
echo "  - gate"
echo "  - observation_action"
echo "  - encoding"
echo "  - prediction"
echo "  - feedback"
echo "  - reflection_bias"
echo "  - update_rule"


