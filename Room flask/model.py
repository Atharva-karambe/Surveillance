import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
from pymongo import MongoClient
import joblib

# Connect to your MongoDB database
client = MongoClient("mongodb+srv://rootboy:toorboy@cluster0.tteb60r.mongodb.net")  # Replace with your MongoDB connection URI
db = client["test"]  # Replace with your database name
collection = db["mod"]  # Replace with your collection name

# Retrieve data from MongoDB
data = list(collection.find({}, {"acc": 1, "gyo": 1, "out": 1}))

max_rows = max(len(doc["acc"]) for doc in data)
max_cols = max(len(doc["acc"][0]) for doc in data)

# Initialize empty lists to store flattened and padded matrices
X = []
y = []

# Flatten and pad 'acc' and 'gyo' matrices and store them in X
for doc in data:
    acc_matrix = np.array(doc["acc"])
    gyo_matrix = np.array(doc["gyo"])
    
    # Pad or reshape matrices to match the maximum dimensions
    acc_matrix = np.pad(acc_matrix, ((0, max_rows - acc_matrix.shape[0]), (0, max_cols - acc_matrix.shape[1])))
    gyo_matrix = np.pad(gyo_matrix, ((0, max_rows - gyo_matrix.shape[0]), (0, max_cols - gyo_matrix.shape[1])))
    
    combined_matrix = np.concatenate((acc_matrix.ravel(), gyo_matrix.ravel()))
    X.append(combined_matrix)
    y.append(doc["out"])

# Convert lists to NumPy arrays
X = np.array(X)
y = np.array(y)

# Split the data into training and testing sets
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Choose a machine learning algorithm (Random Forest Classifier)
model = RandomForestClassifier()

# Train the model
model.fit(X_train, y_train)

# Make predictions on the test set
y_pred = model.predict(X_test)

# Evaluate the model
accuracy = accuracy_score(y_test, y_pred)
print("Accuracy:", accuracy)

# Save the trained model to a file
model_filename = 'model.pkl'
joblib.dump(model, model_filename)

print(f"Model saved as '{model_filename}'")