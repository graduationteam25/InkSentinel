import os
import uuid
import hashlib
import time
import logging
import secrets
import re
from datetime import datetime, timedelta
from functools import wraps
from pathlib import Path
from typing import Optional, Dict, Any, Tuple
import sys

import numpy as np
import torch
import torch.nn.functional as F
import torchvision.transforms as transforms
from PIL import Image, ImageOps
import requests

from flask import Flask, request, jsonify, abort
from flask_cors import CORS
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address
from werkzeug.utils import secure_filename
import jwt

from langchain_community.llms import Ollama
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain

# Configure logging with UTF-8 encoding
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('unified_api.log', encoding='utf-8'),
        logging.StreamHandler(stream=sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Ensure StreamHandler uses UTF-8 encoding
for handler in logger.handlers:
    if isinstance(handler, logging.StreamHandler):
        handler.setStream(sys.stdout)
        handler.stream.reconfigure(encoding='utf-8')

# Initialize Flask app
app = Flask(__name__)
CORS(app, resources={
    r"/api/*": {
        "origins": ["http://localhost:3000", "http://127.0.0.1:3000"],
        "methods": ["GET", "POST", "OPTIONS"],
        "allow_headers": ["Content-Type", "Authorization", "X-API-Key"]
    }
})

# Security Configuration
app.config.update({
    'SECRET_KEY': os.environ.get('SECRET_KEY', secrets.token_hex(32)),
    'MAX_CONTENT_LENGTH': 10 * 1024 * 1024,  # 10MB max file size
    'UPLOAD_FOLDER': 'temp_uploads',
    'JWT_SECRET_KEY': os.environ.get('JWT_SECRET_KEY', secrets.token_hex(32)),
    'API_KEY': os.environ.get('API_KEY', 'your-secure-api-key-here'),
    'OLLAMA_BASE_URL': os.environ.get('OLLAMA_BASE_URL', 'http://localhost:11434')
})

# Rate limiting
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=["200 per hour", "50 per minute"],
    storage_uri="memory://"
)
limiter.init_app(app)

# Ensure upload directory exists
Path(app.config['UPLOAD_FOLDER']).mkdir(exist_ok=True)

# Global configuration
DEFAULT_LANGUAGE = "Arabic"
SUPPORTED_LANGUAGES = ["English", "Arabic"]
MODEL_PATH = "siamese_model_script.pt"
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg', 'webp'}
MAX_IMAGE_DIMENSION = 2048
MIN_IMAGE_DIMENSION = 32

# Model configuration for LLM
LLM_CONFIG = {
    'model_name': 'llama3.2:latest',
    'temperature': 0.3,
    'num_ctx': 4096,
    'top_p': 0.9,
    'repeat_penalty': 1.1
}

# Set device for PyTorch
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
logger.info(f"Using device: {device}")

# Knowledge Bases
KNOWLEDGE_BASE_EN = """
I am Ink Sentinel, your intelligent signature verification assistant. I use advanced AI technology to help you verify signatures quickly and accurately.

## How I Verify Signatures:
1. Advanced AI Technology
   - I use a specialized neural network trained on thousands of signatures
   - I analyze signature patterns and characteristics
   - I compare signatures with high precision
   - I adapt to different writing styles and languages

2. Verification Process
   - Upload or capture your signature
   - I analyze key features like:
     * Stroke patterns and pressure
     * Signature shape and flow
     * Writing style characteristics
   - I compare with reference signature
   - I provide clear results with confidence scores

3. Accuracy and Reliability
   - I achieve high accuracy in detecting genuine signatures
   - I am effective at identifying skilled forgeries
   - I work with various signature styles
   - I adapt to different writing conditions

4. Security Features
   - I ensure secure signature storage
   - I use encrypted data transmission
   - I focus on privacy-focused processing
   - I never share signature data

## What Makes Me Special:
1. Smart Technology
   - I use advanced AI to learn signature patterns
   - I adapt to different writing styles
   - I work with multiple languages
   - I handle various signature formats

2. User-Friendly Experience
   - I provide a simple upload process
   - I deliver clear results presentation
   - I support multiple languages
   - I work on all devices

3. Professional Features
   - I offer quick verification
   - I provide detailed analysis
   - I maintain history tracking
   - I ensure secure storage

## How I Can Help You Today:
1. Signature Verification
   - I can help you upload signatures
   - I can compare signatures for you
   - I can provide detailed analysis
   - I can show you verification history

2. Account Management
   - I assist with secure login
   - I help with password management
   - I manage privacy settings
   - I handle language preferences

3. Support and Guidance
   - I provide usage instructions
   - I share best practices
   - I help with troubleshooting
   - I offer security tips

How may I assist you today? Do you have a signature that needs verification?

Handwritten Signature Forgery - Comprehensive Detection and Analysis Guide

## Definition of Signature Forgery:
Signature forgery is the process of imitating or simulating another person's signature with intent to deceive for financial or legal fraud. I can help you understand that it is considered a serious crime in criminal law and is punishable by imprisonment and fines.

## Types of Signature Forgery That I Can Help You Identify:

### 1. Simple Forgery:
- I can detect attempts to imitate signatures without an original sample for reference
- I find these easy to detect with my specialized analysis
- I notice clear hesitation and lack of fluency in hand movement
- I identify when signatures are done freehand without any reference

### 2. Simulated Forgery (Traced Forgery):
- I can identify when forgers use an original signature sample for imitation and copying
- I detect unnatural slowness in the writing process
- I notice clear differences in pressure and speed compared to genuine signatures
- I can identify tracing over originals or copying techniques

### 3. Skilled Forgery:
- I can analyze professional forgeries performed by specialists
- I use advanced scientific analysis to detect what's difficult to see with naked eye
- I employ sophisticated analysis tools for detection
- I can identify signs of extensive practice and study of target signatures

## Detection Signs That I Look For:

### Physical Characteristics:
- I notice changes in pen pressure on paper
- I detect differences in writing speed from natural speed
- I identify unnatural stops during signature writing
- I observe changes in line direction and fluidity
- I spot irregularities in line thickness and stroke quality

### Kinematic Characteristics:
- I detect loss of natural fluency in hand movement
- I identify clear hesitation at the beginning and end of letters
- I notice differences in natural rhythm of the writing process
- I spot inconsistency in connections connected letters
- I detect tremor or shaking in stroke execution

### Microscopic Evidence That I Analyze:
- I identify pen lifts in unexpected locations
- I detect double strokes or overwriting
- I find guide lines or preparation marks
- I analyze inconsistent ink flow patterns

## My Scientific Analysis Methods:
- I perform advanced visual analysis using digital magnification
- I conduct digital analysis using specialized image analysis software
- I analyze ink type and paper composition
- I provide comparative analysis with known genuine samples
- I perform statistical measurement of signature parameters

## My Advanced Detection Techniques:
- I use spectral analysis of ink composition
- I perform 3D microscopic examination of stroke depth
- I conduct temporal analysis of writing dynamics
- I analyze pressure pattern variations
- I perform frequency domain analysis of handwriting

## Legal Information I Can Provide:
- I can inform you about imprisonment penalties from one year to fifteen years depending on jurisdiction
- I can explain substantial financial fines based on crime severity
- I can discuss compensation for financial damages to victims
- I can explain permanent criminal record implications

## Prevention Measures I Recommend:
- I suggest using security features in important documents
- I recommend multiple signature samples for comparison
- I advise witness verification during signing
- I recommend digital signature alternatives for high-security transactions
"""

KNOWLEDGE_BASE_AR = """
أنا Ink Sentinel، مساعدك الذكي في التحقق من التوقيع. أستخدم تقنية الذكاء الاصطناعي المتقدمة لأساعدك في التحقق من التوقيعات بسرعة ودقة.

## كيف أقوم بالتحقق من التوقيعات:
1. تقنية ذكاء اصطناعي متقدمة
   - أستخدم شبكة عصبية متخصصة مدربة على آلاف التوقيعات
   - أحلل أنماط وخصائص التوقيع
   - أقارن التوقيعات بدقة عالية
   - أتكيف مع مختلف أنماط الكتابة واللغات

2. عملية التحقق
   - ارفع أو التقط توقيعك
   - أقوم بتحليل الميزات الرئيسية مثل:
     * أنماط الخطوط والضغط
     * شكل التوقيع وتدفقه
     * خصائص أسلوب الكتابة
   - أقارن مع التوقيع المرجعي
   - أقدم نتائج واضحة مع درجات الثقة

3. الدقة والموثوقية
   - أحقق دقة عالية في اكتشاف التوقيعات الأصلية
   - أنا فعال في تحديد التزوير الماهر
   - أعمل مع مختلف أنماط التوقيع
   - أتكيف مع ظروف الكتابة المختلفة

4. ميزات الأمان
   - أضمن تخزيناً آمناً للتوقيعات
   - أستخدم نقل البيانات المشفر
   - أركز على معالجة تحمي الخصوصية
   - لا أشارك بيانات التوقيع أبداً

## ما الذي يميزني:
1. تقنية ذكية
   - أستخدم ذكاءً اصطناعياً متقدماً لتعلم أنماط التوقيع
   - أتكيف مع مختلف أنماط الكتابة
   - أعمل مع لغات متعددة
   - أتعامل مع تنسيقات توقيع مختلفة

2. تجربة سهلة الاستخدام
   - أوفر عملية رفع بسيطة
   - أقدم عرضاً واضحاً للنتائج
   - أدعم لغات متعددة
   - أعمل على جميع الأجهزة

3. ميزات احترافية
   - أقدم تحققاً سريعاً
   - أوفر تحليلاً مفصلاً
   - أحتفظ بسجل التاريخ
   - أضمن تخزيناً آمناً

## كيف يمكنني مساعدتك اليوم:
1. التحقق من التوقيع
   - يمكنني مساعدتك في رفع التوقيعات
   - يمكنني مقارنة التوقيعات لك
   - يمكنني تقديم تحليل مفصل
   - يمكنني عرض سجل التحقق لك

2. إدارة الحساب
   - أساعد في تسجيل الدخول الآمن
   - أساعد في إدارة كلمة المرور
   - أدير إعدادات الخصوصية
   - أتعامل مع تفضيلات اللغة

3. الدعم والتوجيه
   - أقدم تعليمات الاستخدام
   - أشارك أفضل الممارسات
   - أساعد في حل المشاكل
   - أقدم نصائح الأمان

كيف يمكنني مساعدتك اليوم؟ هل لديك توقيع يحتاج إلى التحقق؟

تزوير الإمضاء بخط اليد - دليل شامل للكشف والتحليل

## تعريف تزوير الإمضاء:
تزوير الإمضاء هو عملية تقليد أو محاكاة إمضاء شخص آخر بقصد الخداع أو الاحتيال المالي أو القانوني. يمكنني مساعدتك في فهم أنه يُعتبر من الجرائم الخطيرة في القانون الجنائي ويُعاقب عليه بالحبس والغرامة.

## أنواع تزوير الإمضاء التي يمكنني مساعدتك في تحديدها:

### 1. التزوير البسيط:
- يمكنني كشف محاولات تقليد الإمضاء دون وجود نموذج أصلي للمحاكاة
- أجد هذا النوع سهل الكشف بتحليلي المتخصص
- ألاحظ تردداً وعدم طلاقة واضحة في حركة اليد
- أحدد عندما تتم الإمضاءات بشكل حر دون أي مرجع

### 2. التزوير بالمحاكاة:
- يمكنني تحديد عندما يستخدم المزورون نموذجاً أصلياً من الإمضاء للمحاكاة والتقليد
- أكتشف البطء غير الطبيعي في عملية الكتابة
- ألاحظ اختلافات واضحة في الضغط والسرعة مقارنة بالإمضاءات الأصلية
- يمكنني تحديد التتبع فوق الأصول أو تقنيات النسخ

### 3. التزوير المتقن:
- يمكنني تحليل التزوير الاحترافي الذي يقوم به متخصصون
- أستخدم تحليلاً علمياً متقدماً لكشف ما يصعب رؤيته بالعين المجردة
- أوظف أدوات تحليل متطورة للكشف
- يمكنني تحديد علامات الممارسة المكثفة ودراسة التوقيعات المستهدفة

## علامات الكشف التي أبحث عنها:

### الخصائص الفيزيائية:
- ألاحظ التغيرات في ضغط القلم على الورق
- أكتشف الاختلافات في سرعة الكتابة عن السرعة الطبيعية
- أحدد التوقفات غير الطبيعية أثناء كتابة الإمضاء
- أراقب التغيرات في اتجاه وانسيابية الخطوط
- أكتشف عدم الانتظام في سماكة الخط وجودة الضربة

### الخصائص الحركية:
- أكتشف فقدان الطلاقة الطبيعية في حركة اليد
- أحدد التردد الواضح في بداية ونهاية الحروف
- ألاحظ الاختلافات في الإيقاع الطبيعي لعملية الكتابة
- أكتشف عدم التناسق في التوصيلات بين الحروف
- أكتشف الرعشة أو الاهتزاز في تنفيذ الضربات

### الأدلة المجهرية التي أحللها:
- أحدد رفع القلم في أماكن غير متوقعة
- أكتشف الضربات المزدوجة أو إعادة الكتابة
- أجد خطوط الدليل أو علامات التحضير
- أحلل أنماط تدفق الحبر غير المتسقة

## طرق التحليل العلمي التي أستخدمها:
- أقوم بالتحليل البصري المتقدم باستخدام التكبير الرقمي
- أجري التحليل الرقمي باستخدام برامج تحليل الصور المتخصصة
- أحلل نوع الحبر وتركيب الورق
- أقدم التحليل المقارن مع عينات أصلية معروفة
- أقوم بالقياس الإحصائي لمعاملات الإمضاء

## تقنيات الكشف المتقدمة التي أستخدمها:
- أستخدم التحليل الطيفي لتركيب الحبر
- أقوم بالفحص المجهري ثلاثي الأبعاد لعمق الضربة
- أجري التحليل الزمني لديناميكيات الكتابة
- أحلل تنوعات أنماط الضغط
- أقوم بتحليل المجال الترددي للخط اليدوي

## المعلومات القانونية التي يمكنني تقديمها:
- يمكنني إعلامك بعقوبات الحبس من سنة واحدة إلى خمسة عشر سنة حسب الولاية القضائية
- يمكنني شرح الغرامات المالية الكبيرة حسب جسامة الجريمة
- يمكنني مناقشة تعويض الأضرار المالية للمتضررين
- يمكنني شرح تأثيرات السجل الجنائي الدائم

## إجراءات الوقاية التي أنصح بها:
- أقترح استخدام ميزات الأمان في المستندات المهمة
- أنصح بعينات إمضاء متعددة للمقارنة
- أنصح بالتحقق من الشهود أثناء التوقيع
- أنصح ببدائل التوقيع الرقمي للمعاملات عالية الأمان
"""

# Custom Exception Classes
class SecurityError(Exception):
    """Custom exception for security-related errors"""
    pass

class ValidationError(Exception):
    """Custom exception for validation errors"""
    pass

class ModelError(Exception):
    """Custom exception for model-related errors"""
    pass

# Siamese Model Management
class SiameseModelManager:
    def __init__(self):
        self.model = None
        self.transform = transforms.Compose([
            transforms.Grayscale(1),
            transforms.Resize((160, 160)),
            transforms.ToTensor(),
            transforms.Normalize(mean=[0.485], std=[0.229])
        ])
        self.threshold = 0.2152
        
    def load_model(self) -> bool:
        """Load and validate the PyTorch model"""
        try:
            if not os.path.exists(MODEL_PATH):
                logger.error(f"Model file not found: {MODEL_PATH}")
                return False
            
            logger.info(f"Loading Siamese model from {MODEL_PATH}...")
            self.model = torch.jit.load(MODEL_PATH, map_location=device)
            self.model.eval()
            logger.info("Siamese model loaded successfully")
            return True
        except Exception as e:
            logger.error(f"Failed to load Siamese model: {str(e)}")
            return False
    
    def is_loaded(self) -> bool:
        """Check if model is loaded"""
        return self.model is not None
    
    def preprocess_image(self, image_path: str) -> torch.Tensor:
        """Load and preprocess an image with security checks"""
        try:
            Image.MAX_IMAGE_PIXELS = MAX_IMAGE_DIMENSION * MAX_IMAGE_DIMENSION
            
            with Image.open(image_path) as image:
                image = ImageOps.exif_transpose(image)
                image = image.convert("L")
                tensor = self.transform(image).unsqueeze(0).to(device)
                return tensor
                
        except Exception as e:
            logger.error(f"Image preprocessing failed for {image_path}: {str(e)}")
            raise ValidationError(f"Failed to process image: {str(e)}")
    
    def compare_signatures(self, image1_path: str, image2_path: str) -> Dict[str, Any]:
        """Compare two signature images using the Siamese model"""
        if not self.is_loaded():
            raise ModelError("Siamese model is not loaded")
        
        try:
            with torch.no_grad():
                img1 = self.preprocess_image(image1_path)
                img2 = self.preprocess_image(image2_path)

                start_time = time.time()
                output1, output2 = self.model(img1, img2)
                inference_time = time.time() - start_time
                
                distance = F.pairwise_distance(output1, output2).item()
                is_different = distance > self.threshold
                confidence = max(min(1 - (distance / (2 * self.threshold)), 1.0), 0.0)
                similarity_score = max(1.0 - min(distance / (2 * self.threshold), 1.0), 0.0) if distance <= self.threshold else 0.0
                
                return {
                    'status': 'fake' if is_different else 'valid',
                    'distance': round(distance, 6),
                    'threshold': self.threshold,
                    'confidence': round(confidence, 4),
                    'similarity_score': round(similarity_score, 4),
                    'inference_time_ms': round(inference_time * 1000, 2),
                    'model_version': '1.0'
                }
                
        except Exception as e:
            logger.error(f"Siamese model inference failed: {str(e)}")
            raise ModelError(f"Signature verification failed: {str(e)}")

# LLM Chat Management
class ChatManager:
    def __init__(self):
        self.ollama_base_url = app.config['OLLAMA_BASE_URL']
    
    def detect_language(self, text: str) -> str:
        """Detect if text is primarily Arabic or English"""
        arabic_chars = len(re.findall(r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF]', text))
        total_chars = len(re.sub(r'\s+', '', text))
        
        if total_chars == 0:
            return DEFAULT_LANGUAGE
        
        arabic_ratio = arabic_chars / total_chars
        return "Arabic" if arabic_ratio > 0.3 else "English"
    
    def check_ollama_running(self) -> bool:
        """Check if Ollama server is running"""
        try:
            response = requests.get(self.ollama_base_url, timeout=5)
            return response.status_code == 200
        except requests.exceptions.RequestException:
            return False
    
    def initialize_ollama(self) -> Ollama:
        """Initialize the Ollama model with enhanced settings"""
        return Ollama(
            base_url=self.ollama_base_url,
            model=LLM_CONFIG['model_name'],
            temperature=LLM_CONFIG['temperature'],
            num_ctx=LLM_CONFIG['num_ctx'],
            top_p=LLM_CONFIG.get('top_p', 0.9),
            repeat_penalty=LLM_CONFIG.get('repeat_penalty', 1.1)
        )
    
    def create_conversation_chain(self, language: str = "English") -> LLMChain:
        """Create the conversation chain with language-specific prompt"""
        llm = self.initialize_ollama()
        
        if language == "Arabic":
            template = """أنا Ink Sentinel، خبير متخصص في تحليل وكشف تزوير الإمضاءات المكتوبة بخط اليد. لدي خبرة واسعة في علوم الطب الشرعي وتحليل الخطوط. أستطيع مساعدتك في جميع أسئلتك المتعلقة بالتوقيعات وكشف التزوير.

قاعدة المعرفة المرجعية:
{knowledge_base}

تعليمات مهمة:
- استخدم فقط المعلومات الموجودة في قاعدة المعرفة المرجعية
- أجب بصفتي Ink Sentinel باستخدام ضمير المتكلم (أنا، يمكنني، أستطيع، أساعد)
- قدم إجابات علمية ومفصلة ومبنية على الأدلة
- اذكر الطرق والتقنيات العلمية التي أستخدمها في التحليل
- اشرح الجوانب القانونية عند الضرورة
- استخدم أمثلة عملية عند الإمكان
- تأكد من أن الإجابة واضحة ومختصرة ودقيقة
- استخدم اللغة العربية الفصحى بشكل كامل
- إذا لم أجد معلومات محددة، اذكر ذلك بوضوح

السؤال: {human_input}

إجابتي كـ Ink Sentinel (باللغة العربية الفصحى):"""
        else:
            template = """I am Ink Sentinel, an expert specialist in analyzing and detecting handwritten signature forgery. I have extensive experience in forensic science and handwriting analysis. I can help you with all your questions related to signatures and forgery detection.

Reference Knowledge Base:
{knowledge_base}

Important Instructions:
- Use only the information provided in the reference knowledge base
- Respond as Ink Sentinel using first-person pronouns (I, I can, I am able to, I help)
- Provide scientific, detailed, and evidence-based answers
- Mention scientific methods and techniques that I use in analysis
- Explain legal aspects when necessary
- Use practical examples when possible
- Ensure the answer is clear, concise, and accurate
- Use professional English throughout
- If I don't find specific information, state that clearly

Question: {human_input}

My answer as Ink Sentinel (in English):"""
        
        prompt = PromptTemplate(
            input_variables=["human_input", "knowledge_base"],
            template=template
        )
        
        return LLMChain(llm=llm, prompt=prompt, verbose=False)
    
    def clean_response(self, response: str, language: str) -> str:
        """Clean and validate response based on language"""
        cleaned = response.strip()
        
        # Remove extra whitespace
        cleaned = re.sub(r'\s+', ' ', cleaned)
        
        # Language-specific cleaning
        if language == "Arabic":
            # Remove common mixed language artifacts for Arabic
            artifacts_to_remove = ['caratterист', 'ทำให', 'แต', 'درجية']
            for artifact in artifacts_to_remove:
                cleaned = cleaned.replace(artifact, '')
        
        return cleaned.strip()
    
    def validate_response_quality(self, response: str, language: str, min_length: int = 30) -> bool:
        """Validate response quality based on language and content"""
        if not response or len(response.strip()) < min_length:
            return False
        
        if language == "Arabic":
            # Check for reasonable Arabic content
            arabic_chars = len(re.findall(r'[\u0600-\u06FF]', response))
            return arabic_chars > 10
        else:
            # Check for reasonable English content
            english_words = len(re.findall(r'[a-zA-Z]+', response))
            return english_words > 5
    
    def generate_response(self, user_input: str, language: str = None) -> Dict[str, Any]:
        """Generate response using LLM"""
        if not language:
            language = self.detect_language(user_input)
        
        if not self.check_ollama_running():
            error_msg = "I apologize, but my Ollama service is not running. Please start the service first so I can assist you." if language == "English" else "أعتذر، لكن خدمة Ollama الخاصة بي غير مُشغلة. يرجى تشغيل الخدمة أولاً حتى أتمكن من مساعدتك."
            raise ModelError(error_msg)
        
        knowledge_base = KNOWLEDGE_BASE_AR if language == "Arabic" else KNOWLEDGE_BASE_EN
        conversation_chain = self.create_conversation_chain(language)
        
        try:
            # Generate response with retry mechanism
            max_retries = 3
            for attempt in range(max_retries):
                try:
                    response = conversation_chain.predict(
                        human_input=user_input,
                        knowledge_base=knowledge_base
                    )
                    
                    # Validate and clean response
                    if self.validate_response_quality(response, language):
                        cleaned_response = self.clean_response(response, language)
                        
                        return {
                            'response': cleaned_response,
                            'detected_language': language,
                            'status': 'success',
                            'attempt': attempt + 1,
                            'assistant': 'Ink Sentinel'
                        }
                    
                except Exception as retry_error:
                    if attempt == max_retries - 1:
                        raise retry_error
                    continue
            
            # If all retries failed
            error_msg = "I apologize, but I failed to generate an appropriate response. Please try again." if language == "English" else "أعتذر، لكنني فشلت في توليد إجابة مناسبة. يرجى المحاولة مرة أخرى."
            raise ModelError(error_msg)
            
        except Exception as e:
            logger.error(f"LLM response generation failed: {str(e)}")
            raise ModelError(f"Failed to generate response: {str(e)}")

# Initialize managers
siamese_manager = SiameseModelManager()
chat_manager = ChatManager()

# Authentication and Security Functions
def require_api_key(f):
    """Decorator to require API key authentication"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        api_key = request.headers.get('X-API-Key') or request.args.get('api_key')
        if not api_key:
            logger.warning(f"API key missing from {get_remote_address()}")
            abort(401, description="API key required")
        
        if not secrets.compare_digest(api_key, app.config['API_KEY']):
            logger.warning(f"Invalid API key attempt from {get_remote_address()}")
            abort(401, description="Invalid API key")
        
        return f(*args, **kwargs)
    return decorated_function

def validate_file_security(file) -> bool:
    """Comprehensive file security validation"""
    if not file or not file.filename:
        raise ValidationError("No file provided")
    
    filename = secure_filename(file.filename.lower())
    if not filename or '.' not in filename:
        raise ValidationError("Invalid filename")
    
    extension = filename.rsplit('.', 1)[1]
    if extension not in ALLOWED_EXTENSIONS:
        raise ValidationError(f"File type not allowed. Allowed: {', '.join(ALLOWED_EXTENSIONS)}")
    
    file.seek(0, os.SEEK_END)
    file_size = file.tell()
    file.seek(0)
    
    if file_size == 0:
        raise ValidationError("Empty file")
    if file_size > app.config['MAX_CONTENT_LENGTH']:
        raise ValidationError("File too large")
    
    return True

def validate_image_content(image_path: str) -> bool:
    """Validate image content and properties"""
    try:
        with Image.open(image_path) as img:
            img.verify()
        
        with Image.open(image_path) as img:
            width, height = img.size
            
            if width < MIN_IMAGE_DIMENSION or height < MIN_IMAGE_DIMENSION:
                raise ValidationError(f"Image too small. Minimum: {MIN_IMAGE_DIMENSION}x{MIN_IMAGE_DIMENSION}")
            
            if width > MAX_IMAGE_DIMENSION or height > MAX_IMAGE_DIMENSION:
                raise ValidationError(f"Image too large. Maximum: {MAX_IMAGE_DIMENSION}x{MAX_IMAGE_DIMENSION}")
            
            if img.mode not in ['RGB', 'RGBA', 'L', 'P']:
                raise ValidationError("Unsupported image mode")
    
    except ValidationError:
        raise
    except Exception as e:
        raise ValidationError(f"Invalid image file: {str(e)}")

def create_secure_temp_file() -> str:
    """Create a secure temporary filename"""
    return os.path.join(
        app.config['UPLOAD_FOLDER'],
        f"{uuid.uuid4().hex}_{int(time.time())}.tmp"
    )

def cleanup_files(*file_paths):
    """Safely cleanup temporary files"""
    for file_path in file_paths:
        try:
            if file_path and os.path.exists(file_path):
                os.remove(file_path)
                logger.debug(f"Cleaned up file: {file_path}")
        except Exception as e:
            logger.warning(f"Failed to cleanup file {file_path}: {str(e)}")

# Error Handlers
@app.errorhandler(413)
def too_large(e):
    return jsonify({
        'error': 'File too large',
        'max_size_mb': app.config['MAX_CONTENT_LENGTH'] // (1024 * 1024),
        'timestamp': datetime.utcnow().isoformat()
    }), 413

@app.errorhandler(429)
def ratelimit_handler(e):
    return jsonify({
        'error': 'Rate limit exceeded',
        'message': str(e.description),
        'timestamp': datetime.utcnow().isoformat()
    }), 429

# API Routes
@app.route('/api/health', methods=['GET'])
def health_check():
    """Comprehensive health check endpoint"""
    return jsonify({
        "status": "healthy",
        "service": "Ink Sentinel - Unified Signature Verification API",
        "version": "4.0",
        "capabilities": {
            "siamese_model_loaded": siamese_manager.is_loaded(),
            "ollama_available": chat_manager.check_ollama_running(),
            "supported_languages": SUPPORTED_LANGUAGES
        },
        "device": str(device),
        "timestamp": datetime.utcnow().isoformat(),
        "message": "I am Ink Sentinel, your intelligent signature verification assistant. How may I help you today?"
    })

@app.route('/api/verify-signature', methods=['POST'])
@limiter.limit("20 per minute")
@require_api_key
def verify_signature():
    """Main signature verification endpoint using Siamese model"""
    request_id = str(uuid.uuid4())[:8]
    logger.info(f"[{request_id}] Signature verification request from {get_remote_address()}")
    
    original_path = None
    current_path = None
    
    try:
        if not siamese_manager.is_loaded():
            raise ModelError("Siamese model is not available")
        
        if 'original' not in request.files or 'current' not in request.files:
            raise ValidationError("Both 'original' and 'current' signature images are required")
        
        original_file = request.files['original']
        current_file = request.files['current']
        
        # Security validation
        validate_file_security(original_file)
        validate_file_security(current_file)
        
        # Create secure temporary files
        original_path = create_secure_temp_file()
        current_path = create_secure_temp_file()
        
        # Save files securely
        original_file.save(original_path)
        current_file.save(current_path)
        
        # Validate image content
        validate_image_content(original_path)
        validate_image_content(current_path)
        
        # Perform verification
        result = siamese_manager.compare_signatures(original_path, current_path)
        result.update({
            'request_id': request_id,
            'timestamp': datetime.utcnow().isoformat(),
            'assistant': 'Ink Sentinel'
        })
        
        logger.info(f"[{request_id}] Verification successful: {result['status']}")
        return jsonify(result), 200
        
    except ValidationError as e:
        logger.warning(f"[{request_id}] Validation error: {str(e)}")
        return jsonify({
            'error': 'Validation failed',
            'message': str(e),
            'request_id': request_id,
            'timestamp': datetime.utcnow().isoformat(),
            'assistant': 'Ink Sentinel'
        }), 400
        
    except ModelError as e:
        logger.error(f"[{request_id}] Model error: {str(e)}")
        return jsonify({
            'error': 'Model error',
            'message': str(e),
            'request_id': request_id,
            'timestamp': datetime.utcnow().isoformat(),
            'assistant': 'Ink Sentinel'
        }), 503
        
    except Exception as e:
        logger.error(f"[{request_id}] Unexpected error: {str(e)}")
        return jsonify({
            'error': 'Internal server error',
            'request_id': request_id,
            'timestamp': datetime.utcnow().isoformat(),
            'assistant': 'Ink Sentinel'
        }), 500
        
    finally:
        cleanup_files(original_path, current_path)

@app.route('/api/chat', methods=['POST'])
@limiter.limit("30 per minute")
def chat():
    """Enhanced bilingual chat endpoint with proper persona"""
    request_id = str(uuid.uuid4())[:8]
    
    try:
        data = request.json
        if not data:
            return jsonify({
                "status": "error",
                "message": "No JSON data provided",
                "request_id": request_id,
                "timestamp": datetime.utcnow().isoformat(),
                "assistant": "Ink Sentinel"
            }), 400
            
        user_input = data.get('message', '').strip()
        specified_language = data.get('language', '').strip()
        
        if not user_input:
            return jsonify({
                "status": "error",
                "message": "Message is required" if not specified_language or specified_language == "English" else "الرسالة مطلوبة",
                "request_id": request_id,
                "timestamp": datetime.utcnow().isoformat(),
                "assistant": "Ink Sentinel"
            }), 400
        
        # Detect or use specified language
        if specified_language and specified_language in SUPPORTED_LANGUAGES:
            language = specified_language
        else:
            language = chat_manager.detect_language(user_input)
        
        # Generate response
        result = chat_manager.generate_response(user_input, language)
        result.update({
            'request_id': request_id,
            'specified_language': specified_language,
            'timestamp': datetime.utcnow().isoformat()
        })
        
        logger.info(f"[{request_id}] Chat response generated successfully in {language}")
        return jsonify(result), 200
        
    except ModelError as e:
        logger.error(f"[{request_id}] Model error: {str(e)}")
        return jsonify({
            "status": "error",
            "message": str(e),
            "request_id": request_id,
            "timestamp": datetime.utcnow().isoformat(),
            "assistant": "Ink Sentinel"
        }), 503
        
    except Exception as e:
        logger.error(f"[{request_id}] Unexpected error: {str(e)}")
        return jsonify({
            "status": "error",
            "message": f"I encountered an error while processing your request: {str(e)}",
            "request_id": request_id,
            "timestamp": datetime.utcnow().isoformat(),
            "assistant": "Ink Sentinel"
        }), 500

@app.route('/api/detect-language', methods=['POST'])
def detect_text_language():
    """Endpoint to detect language of given text"""
    try:
        data = request.json
        text = data.get('text', '').strip()
        
        if not text:
            return jsonify({
                "status": "error",
                "message": "Text is required",
                "assistant": "Ink Sentinel"
            }), 400
        
        detected_lang = chat_manager.detect_language(text)
        
        return jsonify({
            "status": "success",
            "detected_language": detected_lang,
            "text_preview": text[:100] + "..." if len(text) > 100 else text,
            "timestamp": datetime.utcnow().isoformat(),
            "message": f"I detected the language as {detected_lang}",
            "assistant": "Ink Sentinel"
        })
        
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": f"I encountered an error while detecting language: {str(e)}",
            "assistant": "Ink Sentinel"
        }), 500

@app.route('/api/test-response', methods=['POST'])
def test_response():
    """Test endpoint for both languages"""
    data = request.json
    language = data.get('language', 'English') if data else 'English'
    
    if language == "Arabic":
        test_response_text = "أنا Ink Sentinel، وأستطيع مساعدتك في كشف تزوير الإمضاء. تزوير الإمضاء هو عملية تقليد أو محاكاة إمضاء شخص آخر بقصد الخداع أو الاحتيال. أصنفه كجريمة خطيرة في القانون الجنائي. يمكنني كشف التزوير من خلال عدة علامات باستخدام تحليلي العلمي المتخصص، مثل التغيرات في ضغط القلم وسرعة الكتابة والطلاقة الطبيعية للحركة."
    else:
        test_response_text = "I am Ink Sentinel, and I can help you detect signature forgery. Signature forgery is the process of imitating or simulating another person's signature with intent to deceive or commit fraud. I classify it as a serious crime in criminal law. I can detect forgery through several signs using my specialized scientific analysis, such as changes in pen pressure, writing speed, and natural movement fluency."
    
    return jsonify({
        "status": "success",
        "response": test_response_text,
        "language": language,
        "timestamp": datetime.utcnow().isoformat(),
        "assistant": "Ink Sentinel"
    })

@app.route('/api/supported-languages', methods=['GET'])
def get_supported_languages():
    """Get list of supported languages"""
    return jsonify({
        "status": "success",
        "supported_languages": SUPPORTED_LANGUAGES,
        "default_language": DEFAULT_LANGUAGE,
        "timestamp": datetime.utcnow().isoformat(),
        "message": "I support both Arabic and English languages for signature verification assistance.",
        "assistant": "Ink Sentinel"
    })

@app.route('/api/greeting', methods=['GET'])
def greeting():
    """Greeting endpoint in both languages"""
    return jsonify({
        "status": "success",
        "english_greeting": "Hello! I am Ink Sentinel, your intelligent signature verification assistant. I use advanced AI technology to help you verify signatures quickly and accurately. How may I assist you today? Do you have a signature that needs verification?",
        "arabic_greeting": "مرحباً! أنا Ink Sentinel، مساعدك الذكي في التحقق من التوقيع. أستخدم تقنية الذكاء الاصطناعي المتقدمة لأساعدك في التحقق من التوقيعات بسرعة ودقة. كيف يمكنني مساعدتك اليوم؟ هل لديك توقيع يحتاج إلى التحقق؟",
        "supported_languages": SUPPORTED_LANGUAGES,
        "timestamp": datetime.utcnow().isoformat(),
        "assistant": "Ink Sentinel"
    })

@app.route('/api/status', methods=['GET'])
def get_status():
    """Comprehensive status endpoint"""
    ollama_status = chat_manager.check_ollama_running()
    return jsonify({
        "status": "operational",
        "services": {
            "siamese_model": {
                "loaded": siamese_manager.is_loaded(),
                "device": str(device),
                "model_path": MODEL_PATH
            },
            "ollama_chat": {
                "available": ollama_status,
                "base_url": chat_manager.ollama_base_url,
                "model_config": LLM_CONFIG
            }
        },
        "supported_languages": SUPPORTED_LANGUAGES,
        "default_language": DEFAULT_LANGUAGE,
        "api_version": "4.0",
        "endpoints": {
            "signature_verification": "/api/verify-signature",
            "chat_analysis": "/api/chat",
            "language_detection": "/api/detect-language",
            "health_check": "/api/health",
            "test_response": "/api/test-response",
            "supported_languages": "/api/supported-languages",
            "greeting": "/api/greeting"
        },
        "timestamp": datetime.utcnow().isoformat(),
        "message": f"I am {'ready' if ollama_status else 'waiting for Ollama service'} to help you with signature verification.",
        "assistant": "Ink Sentinel"
    })

# Security headers
@app.before_request
def log_request_info():
    """Log incoming requests for security monitoring"""
    if request.endpoint not in ['health_check', 'get_status']:
        logger.info(f"Request: {request.method} {request.path} from {get_remote_address()}")

@app.after_request
def add_security_headers(response):
    """Add security headers to all responses"""
    response.headers.update({
        'X-Content-Type-Options': 'nosniff',
        'X-Frame-Options': 'DENY',
        'X-XSS-Protection': '1; mode=block',
        'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
        'Content-Security-Policy': "default-src 'self'"
    })
    return response

# Initialization
def initialize_services():
    """Initialize all services at startup"""
    logger.info("🚀 Initializing Ink Sentinel - Unified Signature Verification API...")
    
    # Load Siamese model
    if siamese_manager.load_model():
        logger.info("✅ Siamese model loaded successfully")
    else:
        logger.warning("⚠️ Siamese model not available - signature verification disabled")
    
    # Check Ollama availability
    if chat_manager.check_ollama_running():
        logger.info("✅ Ollama service is available")
    else:
        logger.warning("⚠️ Ollama service not available - chat functionality disabled")
    
    logger.info("📊 Available endpoints:")
    logger.info("  GET  /api/health            - Health check")
    logger.info("  GET  /api/status            - System status")
    logger.info("  GET  /api/supported-languages  - Get supported languages")
    logger.info("  GET  /api/greeting         - Bilingual greeting messages")
    logger.info("  POST /api/verify-signature  - Signature verification (requires API key)")
    logger.info("  POST /api/chat             - Signature analysis chat")
    logger.info("  POST /api/detect-language  - Language detection")
    logger.info("  POST /api/test-response    - Test response quality")
    logger.info(f"🌐 Supported Languages: {', '.join(SUPPORTED_LANGUAGES)}")
    logger.info("🤖 Assistant: Ink Sentinel - Your intelligent signature verification assistant")
    logger.info("🔍 API ready at: http://localhost:5000 ")
    logger.info("\n💬 Try these sample messages:")
    logger.info("   English: 'Hello Ink Sentinel, can you help me verify a signature?'")
    logger.info("   Arabic: 'مرحباً، هل يمكنك مساعدتي في التحقق من توقيع؟'")

if __name__ == "__main__":
    initialize_services()
    
    # Production deployment recommendations
    if os.environ.get('FLASK_ENV') == 'production':
        logger.info("Starting in production mode")
        app.run(host="0.0.0.0", port=5000, debug=False, threaded=True)
    else:
        logger.info("Starting in development mode")
        app.run(host="0.0.0.0", port=5000, debug=True)