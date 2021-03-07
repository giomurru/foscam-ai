This is a framework for running deep learning models on a live camera feed using iOS and OSX platforms.
An example Xcode project is provided for performing age, gender and emotion classification using the live camera feed of a Foscam IP camera. Note that a simple controller for the Foscam camera is included, allowing you to pan/tilt the camera and enable/disable IR night vision. Please note that this controller has been tested on a Foscam FI8910W Wireless IP camera only, but it is possible it can work with other Foscam camera models. 

Note. I am not the maintainer of the CoreML models used in the demo for age, gender and emotion classification. You can download them by using the links below or you are free to use yours.

In order to run the example project you need to
1) Have a Foscam IP Camera Model FI8910W. Note: if you have another IP camera that supports MJPEG you can create a custom CameraControl object such as `FoscamControl.swift`.
2) Create a `LoginConstants.swift` file containing the login information of the live camera feed in a struct called LoginCostants. This is an example of how this file should look like:
```
struct LoginConstants {
static let domain = "192.168.1.100"
static let user = "admin"
static let pwd = "password"
}
```
3) Download the models for Gender, Age and Emotion classification and copy them in the Models folder located inside the repository's root directory. 

Age classification:

- Paper [Download](http://www.openu.ac.il/home/hassner/projects/cnn_agegender/)

- CoreML model [Download](https://drive.google.com/file/d/1PLkI4Jyg086JlvTzwHHI5EbGWgJI-Atv/view?usp=sharing)

Gender classification:

- Paper [Download](http://www.openu.ac.il/home/hassner/projects/cnn_agegender/)

- CoreML model [Download](https://drive.google.com/file/d/1IxU0E1EDjuL-sbY3wd5Wh6BsXTbYTScb/view?usp=sharing)

Emotion Recognition:

- Paper [Download](http://www.openu.ac.il/home/hassner/projects/cnn_emotions/)

- CoreML model [Download](https://drive.google.com/file/d/1ElCJvnEvhtIxZkyEzVUAFPJAMgyBXo57/view?usp=sharing)
