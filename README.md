## **CloudWalk Backoffice Analyst Test**

🎯 This repository contains a Ruby on Rails application that provides solutions to the tasks of the CloudWalk Backoffice Analyst Test. The application is designed to test the candidate's understanding of the payments industry and their ability to analyze data using SQL.

#### **🔧 Prerequisites:**
Before running the application, you must have the following installed:

- Ruby 3.1.3
- Rails 7.0.4.3
- SQLite

#### **🔧 Installation:**
To run the application, perform the following steps:

1. Clone the repository:
```
git clone git@github.com:yasmincrisostom/backoffice-analyst.git
```
2. Change to the repository directory:
```
cd backoffice-analyst
```
3. Install the required gems:
```
bundle install
```
4. Create the database:
```
rails db:create
```
5. Run the database migrations:
```
rails db:migrate
```
6. Start the application:
```
rails server
```
7. Open your web browser and navigate to http://localhost:3000 to view the application.

#### **🔧 Results:**
The application provides solutions to the tasks of the CloudWalk Backoffice Analyst Test, including:

- A list of all the CNPJs, the dates of purchase, and how long it took to approve each merchant (in hours and in minutes).
- The average time of approval.
- The maximum time of approval.
- The minimum time of approval.

The results are displayed in an easy-to-read table that can be filtered by CNPJ.
