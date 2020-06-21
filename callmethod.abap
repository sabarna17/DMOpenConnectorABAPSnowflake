  method TESTOPENCONNECTOR.
    DATA: lo_http_client     TYPE REF TO if_http_client,
         lo_rest_client     TYPE REF TO cl_rest_http_client,
         lo_request     TYPE REF TO     if_rest_entity,
         lv_url             TYPE        string,
         http_status        TYPE        string,
         lv_body            TYPE        string.
    DATA : tokennumber TYPE STRING.
   BREAK-POINT.

   cl_http_client=>create_by_destination(
    EXPORTING
      destination              = 'OPENCONNECTORTEST'    " Logical destination (specified in function call)
    IMPORTING
      client                   = lo_http_client    " HTTP Client Abstraction
    EXCEPTIONS
      argument_not_found       = 1
      destination_not_found    = 2
      destination_no_authority = 3
      plugin_not_active        = 4
      internal_error           = 5
      OTHERS                   = 6
  ).

    tokennumber = 'XXXXXXXX'.

    CREATE OBJECT lo_rest_client
     EXPORTING
       io_http_client = lo_http_client.

   BREAK-POINT.
* Set Payload or body ( JSON or XML)
     lv_body = '{"script":"SELECT * FROM MATERIAL"}'.
     lo_request = lo_rest_client->if_rest_client~create_request_entity( ).
     lo_request->set_content_type( iv_media_type = if_rest_media_type=>gc_appl_json ).
     lo_request->set_string_data( lv_body ).



*  lo_request->
  CALL METHOD lo_rest_client->if_rest_client~set_request_header
       EXPORTING
         iv_name  = 'Authorization'
         iv_value = tokennumber.

* POST
     lo_rest_client->if_rest_resource~post( lo_request ).

     DATA: lo_json        TYPE REF TO cl_clb_parse_json,
           lo_response    TYPE REF TO if_rest_entity,
           lo_sql         TYPE REF TO cx_sy_open_sql_db,
           status         TYPE  string,
           reason         TYPE  string,
           response       TYPE  string,
           content_length TYPE  string,
           location       TYPE  string,
           content_type   TYPE  string,
           lv_status      TYPE  i.

* Collect response
     lo_response = lo_rest_client->if_rest_client~get_response_entity( ).
     http_status = lv_status = lo_response->get_header_field( '~status_code' ).
     content_length = lo_response->get_header_field( 'content-length' ).
     content_type = lo_response->get_header_field( 'content-type' ).
     response = lo_response->get_string_data( ).

  endmethod.
