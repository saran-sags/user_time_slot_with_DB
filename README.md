# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...



Create a REST API using ROR application which will allow the users to
create time based slots. That should accepts various parameters in
payload: start_time, end_time, and total_capacity.
Divide all the capacities during the entered start and end time. And if
some capacities are exceeding the rounding values then divide the slot
capacities to the last slots.
Example: User has entered the start time as tomorrow at start time 11:00
AM and end time as 12:00 noon. And the total capacity as 6. So, the 15
mins slots will be created as:
Timing Capacity
11:00 AM - 11:15 AM 1
11:15 AM - 11:30 AM 1
11:30 AM - 11:45 AM 2
11:45 AM - 12:00 AM 2
Points to notice:
* The total minutes should be categorised by 15 mins, say during 11 to 12,
the minutes select option should be 15, 30, 45, 60. So, it should accept
user values accordingly and give relevant errors to the user.
* Other parameters should be restricted
* Add required validations:
- Capacity should not accept decimal values, only integers an positive
numbers are allowed as an input
- Start date and time should not be in past
- End date and tine should be greater than the start time.
- Use proper associtations
* The code must be DRY, reusable, scalable and robust, use design
patterns where it is required.

Example response:
{
"slot": {
"id": 1,
"start_time": "2022-08-22 11:00:00",
"end_time": "2022-08-22 12:00:00",
"total_capacity": 6,
"slot_collections": [
{
"id": 1,
"slot_id": 1,
"capacity": 1,
"start_time": "2022-08-22 11:00:00",
"end_time": "2022-08-22 11:15:00"
},
{
"id": 2,
"slot_id": 1,
"capacity": 1,
"start_time": "2022-08-22 11:15:00",
"end_time": "2022-08-22 11:30:00"
},
{
"id": 3,
"slot_id": 1,
"capacity": 2,
"start_time": "2022-08-22 11:30:00",
"end_time": "2022-08-22 11:45:00"
},
{
"id": 4,
"slot_id": 1,
"capacity": 2,
"start_time": "2022-08-22 11:45:00",
"end_time": "2022-08-22 12:00:00"
}
]
}
}