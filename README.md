## Plant Classifier
The Plant Classifier app for iOS employs machine learning to identify the species of a plant based on an image of its leaves. This is achieved through a pre-trained Core ML model, which has been trained using MobileNet V2 and converted from TensorFlow to Core ML format. The model is used to make predictions about the plant's species, and the app then retrieves relevant information about the identified plant species from Wikipedia's API.

## Usage
1. The app has a camera button that allows the user to take a new photo or choose one from the photo library.
2. After choosing a photo, the app will identify the species of the plant in the image and display it in a label.
3. The app will also display an image of the plant's leaves along with the predicted species.
4. Information about the plant will be fetched from Wikipedia's API and displayed in a text field below the label.
5. Overall, the app helps users identify plants and provides them with additional information about the identified plant species.

## Dependencies
* CoreML
* Vision
* Alamofire
* SwiftyJSON

![PlantClassifierGif](https://user-images.githubusercontent.com/47936815/235880579-c7a70a23-52f3-4c28-8331-1f93d4c4b522.gif)
