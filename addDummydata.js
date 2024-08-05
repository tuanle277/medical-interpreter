const admin = require('firebase-admin');

// Initialize the Firebase Admin SDK
const serviceAccount = require('./keys/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const firestore = admin.firestore();

async function addDummyData() {
  const conversations = [
    {
      patient_id: 'P001',
      timestamp: admin.firestore.Timestamp.fromDate(new Date('2024-08-01T14:30:00.000Z')),
      doctor_id: 'D001',
      user_message: 'I have been feeling nauseous and weak.',
      translated_message: 'Tôi cảm thấy buồn nôn và yếu đuối.',
      understanding_level: 0.9,
      emotion_summary: 'Patient appears slightly anxious, mild discomfort detected.',
      diagnostics: 'Possible conditions: Dehydration, Gastroenteritis. Suggested tests: Blood test, hydration status check.',
      summary: 'The patient reports nausea and weakness with mild discomfort. Suggested dehydration or gastroenteritis. Recommended tests include blood tests and hydration status check.'
    },
    {
      patient_id: 'P002',
      timestamp: admin.firestore.Timestamp.fromDate(new Date('2024-08-02T10:15:00.000Z')),
      doctor_id: 'D002',
      user_message: 'My chest hurts, and I have trouble breathing.',
      translated_message: 'Tôi bị đau ngực và khó thở.',
      understanding_level: 0.75,
      emotion_summary: 'Patient shows significant anxiety, moderate to high discomfort detected.',
      diagnostics: 'Possible myocardial infarction. Suggested immediate ECG, administration of aspirin.',
      summary: 'The patient reports chest pain and difficulty breathing, with moderate to high anxiety. Possible myocardial infarction. Recommended immediate ECG and aspirin administration.'
    },
    {
      patient_id: 'P003',
      timestamp: admin.firestore.Timestamp.fromDate(new Date('2024-08-03T16:45:00.000Z')),
      doctor_id: 'D003',
      user_message: 'I have a persistent cough and mild fever.',
      translated_message: 'Tôi bị ho kéo dài và sốt nhẹ.',
      understanding_level: 0.8,
      emotion_summary: 'Patient is calm, mild discomfort detected.',
      diagnostics: 'Possible upper respiratory infection or COVID-19. Suggested PCR test, chest X-ray.',
      summary: 'The patient reports a persistent cough and mild fever, with calm demeanor. Possible upper respiratory infection or COVID-19. Recommended PCR test and chest X-ray.'
    },
    // Add more dummy data here
  ];

  const batch = firestore.batch();

  conversations.forEach((conversation, index) => {
    const docRef = firestore.collection('conversations').doc(`conversation_${index + 1}`);
    batch.set(docRef, conversation);
  });

  try {
    await batch.commit();
    console.log('Dummy data added to Firestore successfully.');
  } catch (error) {
    console.error('Failed to add dummy data to Firestore:', error);
  }
}

addDummyData().catch(console.error);
