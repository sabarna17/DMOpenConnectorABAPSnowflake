# DMOpenConnectorABAPSnowflake
Data migration from ABAP to Snowflake using SAP Cloud Platform Open Connectors

Steps ->
1. Create a Snowflake Account and create a Table.
2. Then create the open connector configurations.
3. Test the open connector configuration from ( inbuilt SWAGGER )/ ( External POSTMAN ).
4. Now Create the RFC Destionation in ABAP SM59 tcode.
5. Ceck the file - "callmethod.abap" and use similar code and create a test ABAP program to send the data.
6. Write a logic for SE11-table retrivation and convert it to CSV.
7. Then use the concept of "point 5" and create a program to post the data to an API. remember to create a background job while calling the program.
