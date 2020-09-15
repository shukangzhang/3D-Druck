# Remember to set working direcotry!

# Set number of displayed digits
options(digits=6)

# Import data
csv_all_data = read.csv2("all_export_big_design_study_2020_08_29_cleaned.csv", header = TRUE)
head(csv_all_data)

csv_error_data = read.csv2("all_export_big_design_study_error_2020_09_07_cleaned.csv", header=TRUE)
head(csv_error_data)

# Clean data
keeps = c("Design.", "model_file", "Performance", "Pressure.Drop.1", "Toutlet.Average", "Toutlet.Standard.Deviation")

csv_all_shortened = csv_all_data[keeps]
head(csv_shortened)

csv_error_shortened = csv_error_data[keeps]
head(csv_error_shortened)

# Export data
write.csv2(csv_all_shortened, file="csv_all_cleaned_sorted.csv", row.names = FALSE)

write.csv2(csv_error_shortened, file="csv_error_cleaned_sorted.csv", row.names = FALSE)

# Import combined data
combined_data = read.csv2("combined_cleaned_sorted.csv", header=TRUE, stringsAsFactors = FALSE)
head(combined_data)
str(combined_data)

# Set data types to numeric
combined_data[, c(3,4,5,6)] <- apply(combined_data[, c(3,4,5,6)], 2, as.numeric)
str(combined_data)

# Order data by Performance, highest first
head(combined_data[order(combined_data$Performance, decreasing=TRUE),])