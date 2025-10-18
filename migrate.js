const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

async function initializeTakenSeats() {
  const eventsRef = db.collection('events');
  const snapshot = await eventsRef.get();

  const batch = db.batch();
  let updated = 0;
  snapshot.forEach(doc => {
    const data = doc.data();
    if (!data.takenSeats) {
      batch.update(doc.ref, { takenSeats: [] });
      updated++;
    }
    if (!data.categoryCapacities) {
      batch.update(doc.ref, {
        categoryCapacities: { 'vip': 10, 'premium': 20, 'regular': 30 }
      });
      updated++;
    }
  });

  if (updated > 0) {
    await batch.commit();
    console.log(`Updated ${updated} events with takenSeats and categoryCapacities`);
  } else {
    console.log('No updates needed');
  }
}

initializeTakenSeats().catch(console.error);