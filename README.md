Pokemon Snap / Bird Watching:
Model Training:
TensorFlow for the image classification model on a dataset of local flora/fauna.
Do transfer learning with a pre-trained model like MobileNetV2 or EfficientNet (both are optimized for mobile devices)
Fine-tune the model on the specific flora/fauna dataset.

Model Conversion:
Once the model is trained and performing well, convert it to TensorFlow Lite format

Flutter with Tflite_flutter:
Develop app Flutter for cross-platform (iOS and Android) on a single codebase.
Use Tflite_flutter plugin to integrate TensorFlow Lite into the app.
Implement camera functionality to capture images and use the loaded model to perform inference on the captured images.
Train the model using TensorFlow on desktop.
Convert model to TensorFlow Lite format.
Integrate the models into the Flutter app using Tflite_flutter then Firebase ML.
Implement camera functionality in flutter and connect to TensorFlow so app has flora/fauna identification.



TensorFlow 
	w/ Tflite_flutter & Firebase ML:
Flora/Fauna Identification: Tflite_flutter
Tflite_flutter for the initial flora/fauna identification.
Plugin allows for fast, on-device inference without internet Ideal for real-time classification with users photos.
Photo Grading: Firebase ML
 More complex models: Aesthetic evaluation is probably too heavy for Tflite_flutter & on-device inference (2024)
 Frequent updates: Firebase ML allows continuous improvements on the grading model based on user feedback or expert input. Firebase for model updates without app updates.
 Cloud processing: Grading doesn't need to be real-time, so you can leverage more powerful cloud-based processing.
 Extras: Firebase Analytics & Firebase Storage.

 Potential workflow:
User takes a photo of flora/fauna
App uses Tflite_flutter to immediately identify flora/fauna
At the end of a hike, a “session”, etc the user can compile photos for scoring
Compilation can be sent out to Firebase ML for grading/scoring. 
Each submission can be scored 1 by 1 with animations; lead:lag on the ML
User receives a trip score or something