import UIKit
import CoreML
import CoreVideo
import Vision
import Accelerate
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageDisplayView: UIImageView!
    @IBOutlet weak var outputLabel: UILabel!
    @IBOutlet weak var discription: UILabel!
    
    let imagePicker = UIImagePickerController()
    let model = PlantModel()
    let wikiUrl = "https://en.wikipedia.org/w/api.php"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary //.photolibrary for library access
        imagePicker.allowsEditing = true
        outputLabel.backgroundColor = .blue
        
    }
    
    private func predict(_ input: CGImage) -> MLMultiArray {
        guard let raks = try? PlantModelInput(input_1With: input) else {
            fatalError("Unable to build Model")
        }
        guard let modelPrediction = try? model.prediction(input: raks) else {
            fatalError("Unable to make prediction")
        }
        print(modelPrediction.Identity)
        let arr = convertToArray(from: modelPrediction.Identity)
        let topK = Math.topK(arr: arr , k: 2)
        //        let stream = InputStream(fileAtPath: "/Users/rakesh.kota/Documents/sample apps/Plant Classifier/Classifier/plantslabelmap.csv")!
        //        let csv = try! CSVReader(stream: stream)
        //        while let row = csv.next() {
        //            print("\(row)")
        //        }
        print("RaksSads \(topK)")
        requestInfo(plantName: String(Labels.outputLabelsArray[topK.indexes[0]]))
        navigationItem.title = "\(topK.indexes) \(Labels.outputLabelsArray[topK.indexes[0]])"
        return modelPrediction.Identity
    }
    
    func convertToArray(from mlMultiArray: MLMultiArray) -> [Double] {
        
        // Init our output array
        var array: [Double] = []
        
        // Get length
        let length = mlMultiArray.count
        
        // Set content of multi array to our out put array
        for i in 0...length - 1 {
            array.append(Double(truncating: mlMultiArray[[0,NSNumber(value: i)]]))
        }
        
        return array
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageDisplayView.image = pickedImage
            print("imagesize \(pickedImage.size)")
            //let resizedImage = pickedImage.scalePreservingAspectRatio(targetSize: CGSize(width: 80, height: 80))
            //print("imagesize \(resizedImage.size)")
            //let resizedImage = resize(pickedImage.cgImage!)
            //let sads = pixelBuffer(forImage: resizedImage.cgImage!)
            //let saddy = predict(sads!)
            let saddy = predict(pickedImage.cgImage!)
            print("RaksSAds \(saddy)")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func pixelBuffer (forImage image:CGImage) -> CVPixelBuffer? {
        
        //let frameSize = CGSize(width: image.width, height: image.height)
        let frameSize = CGSize(width: 224, height: 224)
        print("imagesize \(frameSize)")
        var pixelBuffer:CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
        
        if status != kCVReturnSuccess {
            return nil
            
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(data: data, width: Int(frameSize.width), height: Int(frameSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        
        context?.draw(image, in: CGRect(x: 0, y: 0, width: image.width, height: image.height))
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
        
    }
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        present(imagePicker, animated: true) {}
    }
    
    func requestInfo(plantName: String) {
        let parameters: [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts",
            "exintro" : "",
            "explaintext" : "",
            "titles" : plantName,
            "indexpageids" : "",
            "redirects" : "1",
        ]
        AF.request(wikiUrl, method: .get, parameters: parameters).responseJSON { response in
            print(response)
            switch response.result {
            case .success(let plantJson):
                let result = JSON(plantJson)//as! NSDictionary
                let pageId = result["query"]["pageids"][0].stringValue
                let dispalyText = result["query"]["pages"][pageId]["extract"]
                self.discription.text = dispalyText.stringValue
                print("raki \(pageId) \(dispalyText)")
            case .failure(let error):
                print("Request Error \(error)")
            }
        }
    }
    
    
    func resize(_ image: CGImage) -> CGImage? {
        var ratio: Float = 0.0
        let imageWidth = Float(image.width)
        let imageHeight = Float(image.height)
        let maxWidth: Float = 224.0
        let maxHeight: Float = 224.0
        
        // Get ratio (landscape or portrait)
        if (imageWidth > imageHeight) {
            ratio = maxWidth / imageWidth
        } else {
            ratio = maxHeight / imageHeight
        }
        
        // Calculate new size based on the ratio
        if ratio > 1 {
            ratio = 1
        }
        
        let width = imageWidth * ratio
        let height = imageHeight * ratio
        
        guard let colorSpace = image.colorSpace else { return nil }
        guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: image.bitsPerComponent, bytesPerRow: image.bytesPerRow, space: colorSpace, bitmapInfo: image.alphaInfo.rawValue) else { return nil }
        
        // draw image to context (resizing it)
        context.interpolationQuality = .high
        context.draw(image, in: CGRect(x: 0, y: 0, width: Int(width), height: Int(height)))
        
        // extract resulting image from context
        return context.makeImage()
        
    }
    
}

//extension Double: MultiArrayType {
//  public static var multiArrayDataType: MLMultiArrayDataType { return .double }
//  public var toUInt8: UInt8 { return UInt8(self) }
//}
extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )
        
        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )
        
        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}
