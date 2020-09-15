import pandas as pd
import os

# import CSV file
dirname = os.path.dirname(__file__)
filename = os.path.join(dirname, "All_Export_cleaned.csv")
data_file = pd.read_csv(filename)

# debug messages to check if data is in the right format
print(data_file)
print(data_file.columns.values)

# get deviation of "Toutlet Average", "Toutlet Standard Deviation" and "Pressure Drop 1"
for metric_name in ["Pressure Drop 1", "Toutlet Average", "Toutlet Standard Deviation"]:
    values = data_file[metric_name]
    print(metric_name, "max:", values.max(), "; min:", values.min())
    print("Percentage change, min to max:", (values.max()/values.min() - 1)*100.0)
    print("Standard deviation:", values.std())