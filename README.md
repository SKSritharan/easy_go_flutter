# easy_go_v1

A new Flutter project.

### System Requirements

- Dart SDK Version 2.18.0 or greater.
- Flutter SDK Version 3.3.0 or greater.

## Technology Stack

### Selection of Development Framework

- Flutter

### Architecture

- Flutter Getx Architecture

### Programming Language

- Dart

### Libraries

- flutter_polyline_points: ^1.0.0
- cached_network_image: ^3.2.3
- google_maps_flutter: ^2.2.5
- location: ^4.4.0
- flutter_bloc: ^8.1.2
- permission_handler: ^10.2.0
- firebase_core: ^2.10.0
- cloud_firestore: ^4.5.2
- firebase_auth: ^4.4.2
- get: ^4.6.5
- json_theme: ^4.0.3+2
- image_picker: ^0.8.7+4
- firebase_storage: ^11.1.1

### IDE

- VS Code / Android Studio

### Project Structure

```
.
├── android                         - contains files and folders required for running the application on an Android operating system.
├── assets                          - contains all images and fonts of your application.
├── ios                             - contains files required by the application to run the dart code on iOS platforms.
├── lib                             - Most important folder in the project, used to write most of the Dart code.
    ├── main.dart                   - starting point of the application
    ├── utils
    │   ├── constants               - contains all constants classes
    │   └── widgets                 - contains all custom widget classes
    ├── models
    │   └── models                  - contains request/response models
    ├── modules                     - contains all screens and screen controllers
    │   └── screens                 - contains all screens
    ├── routes                      - contains all the routes of application
    └── theme                       - contains app theme and decoration classes
    └── widgets                     - contains all custom widget classes
```
