import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import sklearn
import matplotlib

matplotlib.use('TkAgg',force = True)

from sklearn.datasets import make_classification
X, y = make_classification(n_samples = 1000, n_classes = 2, random_state = 1)
X.shape

from sklearn.model_selection import train_test_split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.5, random_state=2)
X_train.shape, X_test.shape, y_train.shape, y_test.shape

from sklearn.linear_model import LogisticRegression
model = LogisticRegression().fit(X_train, y_train)
y_pred_proba = model.predict_proba(X_test)

model.classes

from sklearn.metrics import roc_curve
from sklearn.metrics import roc_auc_score
fpr, tpr, threshold = roc_curve(y_test, y_pred_proba[: , 1])

plt.plot([0, 1], [0, 1], linestyle='--')
plt.plot(fpr, tpr, marker='.', label = "Logistic-regression")
plt.show()

roc_auc_score(y_test, y_pred_proba[:, 1])

from sklearn.neighbors import KNeighborsClassifier
model2 = KNeighborsClassifier(n_neighbors=250).fit(X_train, y_train)
y_pred2_proba = model2.predict_proba(X_test)
fpr, tpr, _ = roc_curve(y_test, y_pred2_proba[:, 1])

plt.plot([0, 1], [0, 1], linestyle='--')
plt.plot(fpr, tpr, marker='.', label = "KNN")
plt.legend()
plt.show()

from sklearn.metrics import roc_curve, roc_auc_score, precision_recall_curve
precision, recall, _ = precision_recall_curve(y_test, y_pred_proba[:, 1])
no_skill = len(y[y==1]) / len(y)
plt.plot([0, 1], [no_skill, no_skill], linestyle='--')
plt.plot(recall, precision, marker='.')
plt.show()
