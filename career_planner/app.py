from flask import Flask, render_template, request, redirect, url_for, session, flash
from flask_sqlalchemy import SQLAlchemy
from werkzeug.utils import secure_filename
import os
import joblib
import random
import smtplib
from email.mime.text import MIMEText
from utils.personality_analyzer import analyze_personality
from utils.skill_resources import career_skills
from utils.resume_parser import extract_text_from_pdf, score_resume

# Initialize Flask app
app = Flask(__name__)
app.secret_key = 'your_secret_key'

# Database and upload config
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///C:/Users/ESHOP/career_planner/instance/database.db'
app.config['UPLOAD_FOLDER'] = 'resume_uploads'
db = SQLAlchemy(app)

# Email configuration - fill with your email credentials
EMAIL_ADDRESS = 'karankakreja1@gmail.com'  # Replace with your email
EMAIL_PASSWORD = 'zmzw mfik smyo wgvj'    # Replace with your app password (for Gmail)

# Load ML model and label encoder
career_model = joblib.load('models/career_model.pkl')
label_encoder = joblib.load('models/label_encoder.pkl')

# Create necessary folders if they don't exist
os.makedirs('instance', exist_ok=True)
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)

# ---------------- Database Model ---------------- #
class User(db.Model):
    __tablename__ = 'user'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    email = db.Column(db.String(100), unique=True)
    password = db.Column(db.String(100))
    skills = db.Column(db.Text)
    marks = db.Column(db.String(20))
    interests = db.Column(db.Text)
    resume_filename = db.Column(db.String(200))
    personality_paragraph = db.Column(db.Text)

reset_codes = {}

def send_otp_email(to_email, otp):
    subject = "Your OTP Code for Password Reset"
    body = f"Hello,\n\nYour OTP code to reset your password is: {otp}\n\nIf you didn't request this, please ignore this email."
    msg = MIMEText(body)
    msg['Subject'] = subject
    msg['From'] = EMAIL_ADDRESS
    msg['To'] = to_email

    try:
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as smtp:
            smtp.login(EMAIL_ADDRESS, EMAIL_PASSWORD)
            smtp.send_message(msg)
        return True
    except Exception as e:
        print("Failed to send email:", e)
        return False

# ---------------- Routes ---------------- #

@app.route('/')
def home():
    return render_template('index.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        user = User(
            name=request.form['name'],
            email=request.form['email'],
            password=request.form['password'],
            skills=request.form['skills'],
            marks=request.form['marks'],
            interests=request.form['interests'],
            personality_paragraph=request.form['personality_paragraph']
        )
        db.session.add(user)
        db.session.commit()
        return redirect(url_for('login'))
    return render_template('register.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        user = User.query.filter_by(
            email=request.form['email'],
            password=request.form['password']
        ).first()
        if user:
            session['user_id'] = user.id
            return redirect(url_for('dashboard'))
        else:
            flash('Invalid email or password')
    return render_template('login.html')

@app.route('/logout')
def logout():
    session.pop('user_id', None)
    return redirect(url_for('login'))

@app.route('/dashboard')
def dashboard():
    if 'user_id' not in session:
        return redirect(url_for('login'))

    user = User.query.get(session['user_id'])
    input_text = f"{user.skills} {user.interests} {user.marks}"
    prediction = career_model.predict([input_text])
    career = label_encoder.inverse_transform(prediction)[0]
    traits = analyze_personality(user.personality_paragraph)

    user_skills = [s.strip().lower() for s in user.skills.split(',')]
    required_skills = [s.lower() for s in career_skills.get(career, {}).get("required", [])]
    missing_skills = [s for s in required_skills if s not in user_skills]
    resources = career_skills.get(career, {}).get("resources", [])

    return render_template('dashboard.html', user=user, career=career,
                           missing_skills=missing_skills, resources=resources,
                           resume_score=None, resume_tips=None,
                           personality_traits=traits)

@app.route('/upload_resume', methods=['POST'])
def upload_resume():
    if 'user_id' not in session:
        return redirect(url_for('login'))

    file = request.files['resume']
    if file and file.filename.endswith('.pdf'):
        filename = secure_filename(file.filename)
        filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
        file.save(filepath)

        user = User.query.get(session['user_id'])
        input_text = f"{user.skills} {user.interests} {user.marks}"
        prediction = career_model.predict([input_text])
        career = label_encoder.inverse_transform(prediction)[0]

        required_keywords = career_skills.get(career, {}).get("required", [])
        resume_text = extract_text_from_pdf(filepath)
        resume_score, suggestions = score_resume(resume_text, required_keywords)

        user_skills = [s.strip().lower() for s in user.skills.split(',')]
        required_skills = [s.lower() for s in required_keywords]
        missing_skills = [s for s in required_skills if s not in user_skills]
        resources = career_skills.get(career, {}).get("resources", [])
        traits = analyze_personality(user.personality_paragraph)

        return render_template('dashboard.html', user=user, career=career,
                               missing_skills=missing_skills, resources=resources,
                               resume_score=resume_score, resume_tips=suggestions,
                               personality_traits=traits)

    return "Please upload a valid PDF file.", 400


@app.route('/forgot_password', methods=['GET', 'POST'])
def forgot_password():
    if request.method == 'POST':
        email = request.form['email']
        user = User.query.filter_by(email=email).first()
        if user:
            otp = str(random.randint(100000, 999999))
            reset_codes[email] = otp

            # Send the OTP via email
            send_otp_email(email, otp)  # ← Yeh line add karo

            flash('OTP has been sent to your email.')
            return redirect(url_for('reset_password', email=email))
        else:
            flash('Email not found.')
    return render_template('forgot_password.html')



@app.route('/reset_password/<email>', methods=['GET', 'POST'])
def reset_password(email):
    if request.method == 'POST':
        otp = request.form['otp']
        new_password = request.form['new_password']
        confirm_password = request.form['confirm_password']

        if email in reset_codes and reset_codes[email] == otp:
            if new_password == confirm_password:
                user = User.query.filter_by(email=email).first()
                user.password = new_password
                db.session.commit()
                flash('Password has been reset successfully.')
                return redirect(url_for('login'))
            else:
                flash('Passwords do not match.')
        else:
            flash('Invalid OTP.')
    return render_template('reset_password.html', email=email)

# ---------------- Main ---------------- #
if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)
