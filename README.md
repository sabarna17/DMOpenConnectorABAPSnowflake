# DMOpenConnectorABAPSnowflake
Data migration from ABAP to Snowflake using SAP Cloud Platform Open Connectors. Check the architecture - (../architecture.PNG)

Steps ->
1. Create a Snowflake Account and create a Table. (../SnowFlake Table.PNG)
2. Then create the open connector configurations. (../Open Connector Snowflake Instances.PNG)
3. Test the open connector configuration from ( inbuilt SWAGGER )/ ( External POSTMAN ).
4. Now Create the RFC Destionation in ABAP SM59 tcode. (../RFC Destinations (SAP ABAP Layer) Tocde - SM59.PNG)
5. Ceck the file - "callmethod.abap" and use similar code and create a test ABAP program to send the data.
6. Write a logic for SE11-table retrivation and convert it to CSV.
   - Dynamic Field Catalog creation
   - Conversion to internal table and selection of the data
   - Convertion of the data to query format
   - Call the ABAP RFC Destination

Note - Changes Can be done easily in ABAP side and create own custom logics.
