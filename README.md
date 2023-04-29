### Plant Classifier
Plant Classifier is an iOS app that uses machine learning to classify a plant's species from an image of its leaves. The app uses a pre-trained Core ML model to predict the plant's species, and then fetches information about the plant from Wikipedia's API.

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
