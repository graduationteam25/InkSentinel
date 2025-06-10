# InkSentinel: AI-Powered Handwritten Signature Verification

InkSentinel is a revolutionary mobile application that uses advanced artificial intelligence to verify handwritten signatures with forensic precision. Designed for industries vulnerable to fraud like banking, legal services, and education, our solution delivers 90%+ accuracy in under 30 milliseconds—dramatically outperforming traditional verification methods.

## Key Features
✅ **Lightning-Fast Verification**  
90.83% accuracy in <30ms using Siamese Neural Networks with EfficientNet-Lite

✅ **Multi-Platform Support**  
Native iOS and Android experience built with Flutter

✅ **Bilingual AI Assistant**  
Real-time forensic guidance in English/Arabic using Ollama's LLaMA3.2:latest

✅ **Military-Grade Security**  
AES-256 encryption, GDPR compliance, and Firebase authentication

✅ **Offline Capability**  
TorchScript-optimized model works without internet (<200ms inference)

✅ **Dynamic Analytics**  
Verification history with search/filter and visual similarity reports

## Technologies Used
**Core Stack**  
`Flutter` `Firebase` `Python` `PyTorch` `Flask` `Ollama`

**AI Models**  
- Signature Verification: Siamese Network with EfficientNet-Lite0
- Chatbot: Meta's LLaMA3.2:latest (3B parameter LLM)

**Security**  
`AES-256` `Firebase Auth` `Role-Based Access Control` `GDPR Compliance`

## Installation & Setup
### Mobile Application
1. **Download APK**  
   [Download Latest Release](https://github.com/graduationteam25/InkSentinel) (Android)

2. **Enable Unknown Sources**  
   Go to Settings → Security → Enable "Install unknown apps"

3. **Install & Launch**  
   Open the APK file and follow installation prompts

### Development Environment
```bash
# Clone repository
git clone https://github.com/graduationteam25/InkSentinel

# Install dependencies
cd inksentinel && flutter pub get

# Run Flutter app
flutter run

# Start backend server
cd API_model && pip install -r requirements.txt
python app.py
```

## Dataset
Our AI model was trained on the **CEDAR Signature Verification Dataset**:  
[Download Dataset](https://www.kaggle.com/datasets/robinreni/signature-verification-dataset)

```
Dataset Structure
├── original
│   ├── original_1.png
│   └── ... 
└── forged
    ├── forged_1.png
    └── ...
```

## Chatbot Integration
InkSentinel's bilingual assistant runs locally using:  
[Ollama Framework](https://ollama.com/)  

```python
# Sample Ollama API call
import ollama

response = ollama.chat(
  model='llama3.2:latest',
  messages=[{'role': 'user', 'content': 'Explain signature forgery types'}]
)
print(response['message']['content'])
```

## Future Roadmap
- **Accuracy Boost** → 95%+ target with ensemble models
- **Liveness Detection** → Prevent screenshot spoofing
- **Blockchain Integration** → Immutable verification records
- **Enterprise API** → RESTful service for document workflows
- **Cross-Platform Expansion** → Web and desktop versions
- **Multi-Signature Analysis** → Contract verification support

## Contributors
- Mostafa Kamal (Team Lead & AI Leader)
- Mostafa Mohamed (Acting Team Lead &Security Architecture & Mobile Development Leader)
- Amr Ashraf, Shahd Mahmoud, Maria Kamal (Mobile Development)
- Amira Mohamed, Alaa Ayman (AI Development)


**Supervised by**  
Dr. Khaled Wasser & Eng. Rofida Abdelhafez  
Egyptian E-Learning University (EELU)
