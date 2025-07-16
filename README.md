# iwealth

## Getting Started

Follow these steps to set up and run the iWealth project on your local machine.

### Prerequisites

	•	Install Flutter on your development machine.
	•	Set up JFrog credentials:
	•	Create a .netrc file at the root of the project.
	•	Add your JFrog credentials to the .netrc file. Example:

```bash
machine identy.jfrog.io
login <username>
password <password>
```



### Adding Licenses

Ensure the Identy licenses are placed in the correct directories:
- Android: Place the license file in the *Assets* directory.
- iOS: Place the license file in the *Resources* folder.

Running the Project

1.	Open a terminal and navigate to the project directory.
2.	Run the usual Flutter commands to get the dependencies and start the project:

```
flutter pub get
flutter run
```

3.	Note: Identy fingerprint capturing functionality requires a physical device (mobile phone) to function correctly. Emulators are not supported for this feature.

Additional Notes
- Make sure all dependencies are correctly set up in your environment.
- For any issues, consult the Flutter documentation or the project’s# itrust-mockup
