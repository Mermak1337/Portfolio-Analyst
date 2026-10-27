import pandas as pd
import numpy as np

np.random.seed(42)
n = 1000
df = pd.DataFrame({
    'Product': np.random.choice(['Air Max', 'Jordan', 'Pegasus', 'Dunk', 'Huarache'], n),
    'Region': np.random.choice(['Europe', 'North America', 'Asia'], n),
    'Units_Sold': np.random.randint(10, 500, n),
    'Price': np.random.uniform(80, 200, n).round(2),
    'Discount': np.random.choice([0, 0, 0.1, 0.2, 0.3], n)
})

print(df.head())
df.info()

df['Revenue'] = (df['Units_Sold'] * df['Price'] * (1 - df['Discount'])).round(2)
df['Profit'] = (df['Revenue'] - (df['Units_Sold'] * df['Price'] * 0.6)).round(2)
df['Is_Big_Deal'] = np.where(df['Revenue'] > 5000, 'Yes', 'No')

df.loc[0:5, 'Discount'] = np.nan 
df['Discount'] = df['Discount'].fillna(0)

product_stats = df.groupby('Product').agg(
    Total_Units=('Units_Sold', 'sum'),
    Total_Revenue=('Revenue', 'sum'),
    Avg_Discount=('Discount', 'mean'),
    Total_Profit=('Profit', 'sum')
).sort_values(by='Total_Revenue', ascending=False)
print(product_stats)

region_filter = df[df['Units_Sold'] > 100]
avg_check = region_filter.groupby('Region')['Revenue'].mean().round(2)
print(avg_check)

revenues = df['Revenue'].values

print(np.mean(revenues))
print(np.median(revenues))
print(np.std(revenues))
print(np.max(revenues))

correlation = np.corrcoef(df['Discount'], df['Profit'])[0, 1]
print(correlation)

mean_rev = np.mean(revenues)
std_rev = np.std(revenues)
outliers = df[np.abs(df['Revenue'] - mean_rev) > 3 * std_rev]
print(len(outliers))

pivot = pd.pivot_table(
    df, 
    values='Revenue', 
    index='Region', 
    columns='Product', 
    aggfunc='sum', 
    fill_value=0
)
print(pivot.round(0))
