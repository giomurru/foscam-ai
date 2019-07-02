This is a framework for running deep learning models on iOS and OSX platforms on a live camera feed. 
An example Xcode project is for using the framework on the live camera feed of a Foscam IP camera.

In order to run the project you first need to:
1) Create a `LoginConstants.swift` file containing the login information of the live camera feed in a struct called LoginCostants. This is an example of how this file should look like:
```
struct LoginConstants {
static let domain = "192.168.1.100"
static let user = "admin"
static let pwd = "password"
}
```
2) Download the models for Gender, Age and Emotion classification and copy them in the Models folder located inside the repository's root directory. 
These are the links to download the models:
- GenderNet [Download](https://drive.google.com/file/d/0B1ghKa_MYL6mYkNsZHlyc2ZuaFk/view?usp=sharing)
- AgeNet [Download](https://drive.google.com/file/d/0B1ghKa_MYL6mT1J3T1BEeWx4TWc/view?usp=sharing)
- EmotionNet [Download](https://drive.google.com/file/d/0B1ghKa_MYL6mTlYtRGdXNFlpWDQ/view?usp=sharing)
