# Lab 3: FleetBook — Vehicle Booking with Service Bus, Logic Apps & Functions

## Akash Nadackanal Vinod (041156265)

## Demo Video
- https://youtu.be/4JLDoM3vxic

## Overview
FleetBook is a serverless Azure application that handles vehicle bookings. It uses a small frontend to send requests to an Azure Service Bus queue, which triggers a Logic App. The Logic App passes the data over to a Python Azure Function to calculate availability and pricing, and then sends the final result back to the Service Bus topic for the frontend to pick up.

## Project Structure
- `client.html`: A simple vanilla JS frontend that interacts with Azure Service Bus using the REST API and a SAS token.
- `function_app.py`: The core Python Azure Function that handles the business logic (checking fleet availability and calculating prices).
- `test-function.http`: Helpful HTTP snippets to test the function locally.
- `local.settings.example.json`: Starter template for your local Azure Functions environment.
- `requirements.txt`: Python dependencies.

## Setup Instructions

1. **Azure Infrastructure**:
   - Create a Resource Group `rg-serverless-lab3`.
   - Provision an Azure Service Bus (Standard tier is required for topics).
   - Create a queue named `booking-queue`.
   - Create a topic named `booking-results` with two subscriptions: `confirmed-sub` and `rejected-sub`. Set up SQL filters on these subscriptions so they only catch messages where `sys.label = 'confirmed'` or `sys.label = 'rejected'`.

2. **Azure Function Deployment**:
   - Create a Linux Consumption Function App running Python 3.12.
   - Deploy the `function_app.py` code to it.
   - You can verify it's working by running the tests in `test-function.http` locally or against the live URL.
   
3. **Logic App Workflow**:
   - Create a Logic App that triggers when a new message hits the `booking-queue`.
   - Send the message payload over to your Azure Function via an HTTP POST action.
   - Add a Condition block to check if the function returned a "confirmed" or "rejected" status.
   - Add an Outlook/Office365 action to send a summary email to the customer.
   - Add a Service Bus "Send message" action to drop the response into the `booking-results` topic. Be sure to set the system property Label to either "confirmed" or "rejected" so the proper subscription filter catches it.

4. **Running the Frontend**:
   - Just double-click `client.html` to open it in your browser.
   - Expand the configuration panel at the top.
   - Drop in your Service Bus namespace and the Primary Key (from the `RootManageSharedAccessKey` policy).
   - Try booking a car and watch the dashboard update in real-time!

## AI Disclosure Statement
Used ChatGPT to draft and organize the summary/analysis and to help identify relevant official documentation sources for Azure Durable Functions. I reviewed and edited the text for accuracy and ensured all claims are supported by citations.

