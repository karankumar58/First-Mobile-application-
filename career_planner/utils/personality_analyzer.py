from textblob import TextBlob

def analyze_personality(text):
    traits = {
        'Openness': 0,
        'Conscientiousness': 0,
        'Extraversion': 0,
        'Agreeableness': 0,
        'Emotional Stability': 0
    }

    text = text.lower()

    if any(word in text for word in ['creative', 'curious', 'imaginative']):
        traits['Openness'] += 1

    if any(word in text for word in ['organized', 'efficient', 'punctual']):
        traits['Conscientiousness'] += 1

    if any(word in text for word in ['outgoing', 'talkative', 'energetic']):
        traits['Extraversion'] += 1

    if any(word in text for word in ['kind', 'empathetic', 'helpful']):
        traits['Agreeableness'] += 1

    if any(word in text for word in ['calm', 'resilient', 'confident']):
        traits['Emotional Stability'] += 1

    sentiment = TextBlob(text).sentiment.polarity
    traits['Positivity'] = round(sentiment * 100, 2)

    return traits
