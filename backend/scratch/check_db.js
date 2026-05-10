const mongoose = require('mongoose');
require('dotenv').config();

async function checkData() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Connected to MongoDB');
    
    const db = mongoose.connection.db;
    const collections = await db.listCollections().toArray();
    console.log('Collections in database:', collections.map(c => c.name));
    
    for (const col of collections) {
      const count = await db.collection(col.name).countDocuments();
      console.log(`Collection ${col.name} has ${count} documents`);
      if (count > 0) {
        const docs = await db.collection(col.name).find().limit(5).toArray();
        console.log(`Sample docs from ${col.name}:`, docs.map(d => ({ id: d._id, email: d.email, name: d.name })));
      }
    }
    
    await mongoose.disconnect();
  } catch (err) {
    console.error('Error checking data:', err);
  }
}

checkData();
