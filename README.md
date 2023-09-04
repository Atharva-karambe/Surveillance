# SafeZone

SafeZone is a cutting-edge project that employs real-time video analytics to bolster industrial safety in diverse industrial environments. The project's primary objective is to monitor and swiftly identify potential safety hazards, including unauthorized access to restricted areas, equipment malfunctions, and non-compliance with safety protocols. By harnessing advanced computer vision techniques and machine learning algorithms, SafeZone scrutinizes live video feeds from strategically placed surveillance cameras within the industrial facility. The system adeptly recognizes objects, activities, and behaviors, providing real-time alerts to prevent accidents and enhance overall workplace safety. SafeZone is an invaluable tool that proactively safeguards workers and assets in industrial settings.

## Project Structure

The SafeZone project consists of three main components:

1. **Node Server**: The Node.js server component handles real-time video analytics and communication between the surveillance cameras and the Flask server.

2. **Flask Server**: The Flask server component manages the application's backend, including user authentication, room creation, and communication with the MongoDB database.

3. **APK Client**: The APK client is a mobile app for end-users to access SafeZone features, view live camera feeds, and receive real-time safety alerts.

## Getting Started

To run the SafeZone project locally, follow these steps:

### Prerequisites

1. **Node.js**: Ensure you have Node.js installed on your system.

2. **MongoDB**: Install and set up MongoDB locally. You will need it for data storage.

### Installation

1. **Node Server**:

   ```shell
   cd node
   npm install
   npm start
   
2. **Flask Server**:

   ```shell
    cd flask
    python main.py
