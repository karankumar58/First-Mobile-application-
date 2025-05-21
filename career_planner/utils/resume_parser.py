import fitz  # PyMuPDF

def extract_text_from_pdf(pdf_path):
    text = ""
    doc = fitz.open(pdf_path)
    for page in doc:
        text += page.get_text()
    return text

def score_resume(resume_text, required_keywords):
    resume_text = resume_text.lower()
    matched_keywords = [kw for kw in required_keywords if kw.lower() in resume_text]
    score = int((len(matched_keywords) / len(required_keywords)) * 100) if required_keywords else 0
    suggestions = [kw for kw in required_keywords if kw.lower() not in resume_text]
    return score, suggestions
