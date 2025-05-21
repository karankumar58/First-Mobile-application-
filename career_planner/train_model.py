import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestClassifier
from sklearn.pipeline import Pipeline
import joblib

# Load data
df = pd.read_csv('career_dataset.csv')

# Combine inputs
df['combined'] = df['skills'] + " " + df['interests'] + " " + df['marks'].astype(str)

# Encode output
le = LabelEncoder()
y = le.fit_transform(df['career'])

# Pipeline: Text → Vectors → Model
model = Pipeline([
    ('vectorizer', CountVectorizer()),
    ('classifier', RandomForestClassifier())
])

# Train model
model.fit(df['combined'], y)

# Save both model and label encoder
joblib.dump(model, 'models/career_model.pkl')
joblib.dump(le, 'models/label_encoder.pkl')

print("✅ Model trained and saved.")
