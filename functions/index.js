const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

//begins taking snap shot of the new or updated alert document from the firestore database
exports.sendNotificationToTopic = functions.firestore.document('/alerts/{id}').onWrite((snap, event) => {

//saves alert to snapshot and then grabs the alert's topic
const alert = snap.after.data();
var categories = alert.ops;
var s = "";

//use .includes() on the line below
Object.keys(categories).forEach(e =>
    s += `key=${e}  value=${categories[e]}`
);

console.log(s);
var d = new Date(alert.created.toDate().toString());
var result = d.toLocaleString('en-US',{month:'long'})+" "+d.getDate()+", "+d.getFullYear();

//configuration of push notification payload for each topic begins here:
    
if(s.includes("Weather")){
     const payload = {notification: {
         title: 'Weather',
         body: 'A new Alert regarding weather is available!',
         },
         data : {
               "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                        "alert": alert.message.toString(),
                                        "date": result,
                                        "title": 'Weather',
         }
     };

    //sends alert to users subscribed to Weather topic
     return admin.messaging().sendToTopic('Weather',payload)
       .then((response) => {
         // Response is a message ID string.
         return console.log('Successfully sent message:', response);
       })
       .catch((error) => {
         return console.log('Error sending message:', error);
       });
}

if(s.includes("Closure")){
     const payload = {notification: {
         title: 'Closure',
         body: 'A new Alert regarding closures is available!',

         },
                   data : {
                   "click_action": "FLUTTER_NOTIFICATION_CLICK",
                         "alert": alert.message.toString(),
                         "date": result,
                         "title": 'Closure',
                         }

     };

     return admin.messaging().sendToTopic('Closure',payload)
       .then((response) => {
         // Response is a message ID string.
         return console.log('Successfully sent message:', response);
       })
       .catch((error) => {
         return console.log('Error sending message:', error);
       });
}

if(s.includes("School Info")){
     const payload = {notification: {
         title: 'School',
         body: 'A new Alert regarding school is available!',
         },
                  data : {
                      "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                               "alert": alert.message.toString(),
                                               "date": result,
                                               "title": 'School Info',            }
     };

     return admin.messaging().sendToTopic('School',payload)
       .then((response) => {
         // Response is a message ID string.
         return console.log('Successfully sent message:', response);
       })
       .catch((error) => {
         return console.log('Error sending message:', error);
       });
}

if(s.includes("Traffic")){
     const payload = {notification: {
         title: 'Traffic',
         body: 'A new Alert regarding traffic is available!',
         },
                   data : {
                         "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                                  "alert": alert.message.toString(),
                                                  "date": result,
                                                  "title": 'Traffic',                  }
     };

     return admin.messaging().sendToTopic('Traffic',payload)
       .then((response) => {
         // Response is a message ID string.
         return console.log('Successfully sent message:', response);
       })
       .catch((error) => {
         return console.log('Error sending message:', error);
       });
}

if(s.includes("Events")){
     const payload = {notification: {
         title: 'Events',
         body: 'A new Alert regarding events is available!',
         },
                   data : {
                        "click_action": "FLUTTER_NOTIFICATION_CLICK",
                                                 "alert": alert.message.toString(),
                                                 "date": result,
                                                 "title": 'Events',                }
     };

     return admin.messaging().sendToTopic('Events',payload)
       .then((response) => {
         // Response is a message ID string.
         return console.log('Successfully sent message:', response);
       })
       .catch((error) => {
         return console.log('Error sending message:', error);
       });
}

});
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });
