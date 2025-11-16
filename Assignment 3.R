# 1. Install and load packages
install.packages("RMariaDB")
library(DBI)
library(RMariaDB)
library(data.table)   # optional, for analysis

# 2. Connect to your MySQL Workbench database
con <- dbConnect(
  drv      = MariaDB(),
  host     = "localhost",     # same as Workbench
  port     = 3306,
  user     = "root",          # or your MySQL username
  password = "marqam111", # enter your MySQL password here
  dbname   = "sakila"         # replace with your schema/database name
)

# 3. List all available tables
dbListTables(con)

-------------------------------------------------------------------------------
  
# Assignment 3 Solution 
# 1 : Write a query to display all films that have a rating of PG and a rental duration greater than 5 days.

#Step 1: Load data.table
library(data.table)

# Step 2: Load or convert your film table into a data.table
films <- as.data.table(films)

#Step 3: Filter films with rating = "PG" and rental_duration > 5
result <- films[rating == "PG" & rental_duration > 5,
               .(film_id, title, rating, rental_duration)]

#Step 4: View result
print(result)

------------------------------------------------------------------------------
  
# 2 : Write a query to display the average rental rate of films, grouped by their rating.

#Step 1: Load data.table
library(data.table)

# Step 2: Load or convert your film table into a data.table
films <- as.data.table(films)

# Step 3: Calculate average rental rate grouped by rating
result <- films[, .(avg_rental_rate = mean(rental_rate, na.rm = TRUE)), 
               by = rating]

#Step 4: View result
print(result)

# 3: Write a query to count the total number of films in each language.

#Step 1: Load data.table
library(data.table)

# Step 2: Load the language table from the database & Convert it to data.table
language <- dbReadTable(con, "language")
language <- as.data.table(language)


# Step 3: Join film with language table and count films per language
names(language)
result <- language[films, 
                   on = .(language_id), 
                   .(language = name, total_films = .N), 
                   by = .EACHI]

#Step 4: View result
print(result)

------------------------------------------------------------------------------

  # 4 : List the customers’ names and the store they belong to.

#Step 1: Load data.table
library(data.table)

# Step 2: Load and convert your customer and store table into a data.table
customer <- dbReadTable(con, "customer")
store <- dbReadTable(con, "store")

customer <- as.data.table(customer)
store <- as.data.table(store)

# Step 3: join customers’ names with the store to see that which store they belong to.
result <- customer[store, 
                   on = .(store_id), 
                   .(customer_id,
                     customer_name = paste(first_name, last_name),
                     store_id)]

#Step 4: View result
print(result)


#optional: to show store address and location
result <- customer[store, 
                   on = .(store_id), 
                   .(customer_id,
                     customer_name = paste(first_name, last_name),
                     store_id,
                     store_address_id = address_id)]
#Step 4: View result
print(result)
                      
-------------------------------------------------------------------------------

# 5 : Display the payment amount, payment date, and the staff member who processed each payment.

#Step 1: Load data.table
library(data.table)

# Step 2: Load and convert your payment and staff table into a data.table
payment <- as.data.table(dbReadTable(con, "payment"))
staff <- as.data.table(dbReadTable(con, "staff"))

#staff <- dbReadTable(con, "staff")   # Load staff table from the Sakila database
#staff <- as.data.table(staff)        # Convert it into a data.table

#payment <- dbReadTable(con, "payment")   # Load payment table from the Sakila database
#payment <- as.data.table(payment)        # Convert it into a data.table


# Step 3: Join payment with staff and Display the payment amount, payment date, and the staff member who processed each payment.
result <- payment[staff, 
                  on = .(staff_id), 
                  .(payment_id,
                    amount,
                    payment_date,
                    staff_name = paste(first_name, last_name))]

#Step 4: View result
print(result)

------------------------------------------------------------------------------

# 6 : Find the films that are not rented.

#Step 1: Load data.table
library(data.table)

# Step 2: Load and convert your film ,inventory and rental table into a data.table
film <- as.data.table(dbReadTable(con, "film"))
inventory <- as.data.table(dbReadTable(con, "inventory"))
rental <- as.data.table(dbReadTable(con, "rental"))

# Step 3: use joins to connect tables and Find the films that are not rented.
# S1: Get all inventory items that have been rented
rented_inventory <- unique(rental$inventory_id)

# S2: Find inventory items that were never rented
unrented_inventory <- inventory[!inventory_id %in% rented_inventory]

# S3: Get film details for those unrented items
unrented_films <- film[film_id %in% unrented_inventory$film_id,
                       .(film_id, title, rental_duration, rating)]

#Step 4: View result
print(unrented_films)

----------------------------------------------------------------------------

# 7 : Plot any graph of your choice.
  
library(data.table)
library(ggplot2)


# Step 1: Load or convert all table into a data.table
film <- as.data.table(dbReadTable(con, "film"))
language <- as.data.table(dbReadTable(con, "language"))
payment <- as.data.table(dbReadTable(con, "payment"))
staff <- as.data.table(dbReadTable(con, "staff"))
customer <- as.data.table(dbReadTable(con, "customer"))
rental <- as.data.table(dbReadTable(con, "rental"))
inventory <- as.data.table(dbReadTable(con, "inventory"))
store <- as.data.table(dbReadTable(con, "store"))


# Step 3: Graph 1: Average Rental Rate by Film Rating
# Compute average rental rate per rating
avg_rate <- film[, .(avg_rental_rate = mean(rental_rate, na.rm = TRUE)), by = rating]

#Step 4: Plot
ggplot(avg_rate, aes(x = rating, y = avg_rental_rate, fill = rating)) +
  geom_bar(stat = "identity") +
  labs(title = "Average Rental Rate by Film Rating",
       x = "Film Rating",
       y = "Average Rental Rate") +
  theme_minimal()

---------------------------------------------------------------

#Graph 2: Total Payment Amount Collected by Each Staff Member

# Join payment with staff to aggregate totals
  staff_payments <- payment[staff, on = .(staff_id),
                            .(staff_name = paste(first_name, last_name), amount)]

staff_totals <- staff_payments[, .(total_collected = sum(amount, na.rm = TRUE)), by = staff_name]

# Plot
ggplot(staff_totals, aes(x = staff_name, y = total_collected, fill = staff_name)) +
  geom_bar(stat = "identity") +
  labs(title = "Total Payment Collected by Each Staff Member",
       x = "Staff Member",
       y = "Total Payment Amount") +
  theme_minimal()

---------------------------------------------------------------

# Graph 3: Most Rented Films (Top 10)

# Join rental -> inventory -> film to get film titles
  rental_film <- rental[inventory, on = .(inventory_id), nomatch = 0L]
  rental_film <- rental_film[film, on = .(film_id), nomatch = 0L]

# Count rentals per film
top_films <- rental_film[, .N, by = title][order(-N)][1:10]

# Plot
ggplot(top_films, aes(x = reorder(title, N), y = N, fill = title)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(title = "Top 10 Most Rented Films",
       x = "Film Title",
       y = "Number of Rentals") +
  theme_minimal()

---------------------------------------------------------------------------

#  Graph 4: Total Rentals by City
  
# Step 1: Load or convert all table into a data.table
address <- as.data.table(dbReadTable(con, "address"))
city <- as.data.table(dbReadTable(con, "city"))

# Join rental -> inventory -> store -> address -> city
rental_city <- rental[inventory, on = .(inventory_id), nomatch = 0L]
rental_city <- rental_city[store, on = .(store_id), nomatch = 0L]
rental_city <- rental_city[address, on = .(address_id), nomatch = 0L]
rental_city <- rental_city[city, on = .(city_id), nomatch = 0L]

# Step 3: Count total (# Top 10 cities) rentals per city
rentals_by_city <- rental_city[, .N, by = city][order(-N)][1:10]

# Before plotting, remove any NA values from your dataset:
rentals_by_city <- na.omit(rentals_by_city)

#Step 4: Plot total rentals by city
    ggplot(rentals_by_city, aes(x = reorder(city, N), y = N, fill = city)) +
       geom_bar(stat = "identity") +
       coord_flip() +
        labs(title = "Top 10 Cities by Total Rentals",
             x = "City",
             y = "Number of Rentals") +
      theme_minimal()













