import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

df = pd.read_csv('Nike_Sales_Uncleaned.csv')

print(df.head())
print(df.info())
print(df.describe())
print(df.isnull().sum())

df['Size'] = df['Size'].fillna(df['Size'].mode()[0])
df['Units_Sold'] = df['Units_Sold'].fillna(df['Units_Sold'].median())
df['MRP'] = df['MRP'].fillna(df['MRP'].median())
df['Discount_Applied'] = df['Discount_Applied'].fillna(0)

df = df.dropna(subset=['Order_Date'])
df = df[df['Units_Sold'] >= 0]

print(df.info())
print(df.describe())
print(df.isnull().sum())

numeric_columns = ['Units_Sold', 'MRP', 'Discount_Applied', 'Revenue', 'Profit']

for col in numeric_columns:
    plt.figure(figsize=(6, 4))
    sns.histplot(df[col], kde=True, bins=30)
    plt.title(f'Распределение признака {col}')
    plt.xlabel(col)
    plt.ylabel('Частота')
    plt.grid(True)
    plt.show()


from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.tree import DecisionTreeRegressor
from sklearn.ensemble import GradientBoostingRegressor


def calculate_metrics(y_test, y_pred):
    mae = np.mean(np.abs(y_test - y_pred))
    mse = np.mean((y_test - y_pred) ** 2)
    rmse = np.sqrt(mse)
    r2 = 1 - (np.sum((y_test - y_pred) ** 2) / np.sum((y_test - np.mean(y_test)) ** 2))
    return mae, mse, rmse, r2

X = df[['Revenue']]
y = df['Profit']

X_train, X_test, y_train, y_test = train_test_split(
    X, y,
    test_size=0.2,
    random_state=42
)

model = LinearRegression()
model.fit(X_train, y_train)
y_pred = model.predict(X_test)

print('Парная линейная регрессия')
print('Коэффициент:', model.coef_[0])
print('Свободный член:', model.intercept_)

mae, mse, rmse, r2 = calculate_metrics(y_test, y_pred)

print('MAE:', mae)
print('MSE:', mse)
print('RMSE:', rmse)
print('R2:', r2)

plt.figure(figsize=(6, 4))
plt.scatter(X_test, y_test)
plt.plot(X_test, y_pred)
plt.xlabel('Revenue')
plt.ylabel('Profit')
plt.title('Парная линейная регрессия: Revenue и Profit')
plt.grid(True)
plt.show()


X = df[['Revenue', 'Units_Sold', 'MRP', 'Discount_Applied']]
y = df['Profit']

print(X.shape, y.shape)

X_train, X_test, y_train, y_test = train_test_split(
    X, y,
    test_size=0.2,
    random_state=42
)

multi_model = LinearRegression()
multi_model.fit(X_train, y_train)
y_pred_multi = multi_model.predict(X_test)

print('Множественная линейная регрессия')
print('Коэффициенты:', multi_model.coef_)
print('Свободный член:', multi_model.intercept_)

mae_multi, mse_multi, rmse_multi, r2_multi = calculate_metrics(y_test, y_pred_multi)

print('MAE множественной регрессии:', mae_multi)
print('MSE множественной регрессии:', mse_multi)
print('RMSE множественной регрессии:', rmse_multi)
print('R2 множественной регрессии:', r2_multi)

plt.figure(figsize=(7, 5))
plt.scatter(y_test, y_pred_multi, alpha=0.7)
plt.plot(
    [y_test.min(), y_test.max()],
    [y_test.min(), y_test.max()],
    'r--',
    linewidth=2,
    label='Идеальный прогноз'
)

plt.xlabel('Реальные значения Profit')
plt.ylabel('Предсказанные значения Profit')
plt.title('Множественная линейная регрессия')
plt.legend()
plt.grid(True)
plt.show()

X = df[['Revenue', 'Units_Sold', 'MRP', 'Discount_Applied']]
y = df['Profit']

X_train, X_test, y_train, y_test = train_test_split(
    X, y,
    test_size=0.2,
    random_state=42
)

tree_model = DecisionTreeRegressor(max_depth=3, random_state=42)
tree_model.fit(X_train, y_train)

y_pred_tree = tree_model.predict(X_test)
mae_tree, mse_tree, rmse_tree, r2_tree = calculate_metrics(y_test, y_pred_tree)

print('Дерево решений')
print('MAE дерева решений:', mae_tree)
print('MSE дерева решений:', mse_tree)
print('RMSE дерева решений:', rmse_tree)
print('R2 дерева решений:', r2_tree)

plt.figure(figsize=(6, 4))
plt.scatter(y_test, y_pred_tree)
plt.xlabel('Реальные значения Profit')
plt.ylabel('Предсказанные значения Profit')
plt.title('Дерево решений')
plt.grid(True)
plt.show()


X = df[['Revenue', 'Units_Sold', 'MRP', 'Discount_Applied']]
y = df['Profit']

X_train, X_test, y_train, y_test = train_test_split(
    X, y,
    test_size=0.2,
    random_state=42
)

boost_model = GradientBoostingRegressor(
    n_estimators=100,
    learning_rate=0.1,
    max_depth=3,
    random_state=42
)

boost_model.fit(X_train, y_train)

y_pred_boost = boost_model.predict(X_test)

mae_boost, mse_boost, rmse_boost, r2_boost = calculate_metrics(y_test, y_pred_boost)

print('Градиентный бустинг')
print('MAE градиентного бустинга:', mae_boost)
print('MSE градиентного бустинга:', mse_boost)
print('RMSE градиентного бустинга:', rmse_boost)
print('R2 градиентного бустинга:', r2_boost)

plt.figure(figsize=(6, 4))
plt.scatter(y_test, y_pred_boost)
plt.plot(
    [y_test.min(), y_test.max()],
    [y_test.min(), y_test.max()],
    'r--'
)
plt.xlabel('Реальные значения Profit')
plt.ylabel('Предсказанные значения Profit')
plt.title('Градиентный бустинг')
plt.grid(True)
plt.show()

results = pd.DataFrame({
    'Модель': [
        'Парная линейная регрессия',
        'Множественная линейная регрессия',
        'Дерево решений',
        'Градиентный бустинг'
    ],
    'MAE': [mae, mae_multi, mae_tree, mae_boost],
    'MSE': [mse, mse_multi, mse_tree, mse_boost],
    'RMSE': [rmse, rmse_multi, rmse_tree, rmse_boost],
    'R2': [r2, r2_multi, r2_tree, r2_boost]
})
print(results)
best_model = results.loc[results['R2'].idxmax()]
print('\nЛучшая модель по R2:')
print(best_model)
