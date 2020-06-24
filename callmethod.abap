  METHOD testopenconnector.
/////////////////////////////////////////////////////////   
// IV_TABLE_READ - Importing - String
// IV_STR - Importing - String
/////////////////////////////////////////////////////////

   DATA: lo_http_client TYPE REF TO if_http_client,
          lo_rest_client TYPE REF TO cl_rest_http_client,
          lo_request     TYPE REF TO     if_rest_entity,
          lv_url         TYPE        string,
          http_status    TYPE        string,
          lv_body        TYPE        string.
    DATA : tokennumber TYPE string.

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

    tokennumber = 'User XXXXXXXXXXXXXXXXXXXXXXX, Organization XXXXXXXXXXXXXXXXXXXXX, Element XXXXXXXXXXXXXXXXXXXXX'.

    CREATE OBJECT lo_rest_client
      EXPORTING
        io_http_client = lo_http_client.

* Set Payload or body ( JSON or XML)
    IF iv_table_read IS NOT INITIAL.
      CONCATENATE '{"script":"SELECT * FROM ' iv_table_read  INTO lv_body SEPARATED BY SPACE.
      lv_body = lv_body && '" }'.
    ELSE.
      CONCATENATE '{"script":"INSERT INTO EMPDETAILS VALUES ' iv_str  INTO lv_body SEPARATED BY SPACE.
      lv_body = lv_body && '"}'.
    ENDIF.

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
    cl_demo_output=>display( response ).

  ENDMETHOD.
  
  
  
  METHOD fetchtable.
/////////////////////////////////////////////////////////   
// IV_TABLE - Importing - String
/////////////////////////////////////////////////////////

    FIELD-SYMBOLS: <fs_table> TYPE STANDARD TABLE.
    DATA: iout TYPE TABLE OF string .
    DATA: xout TYPE string.
    FIELD-SYMBOLS: <fs>      TYPE any,<ls_line> TYPE any.

    DATA:
      i_alv_cat  TYPE TABLE OF lvc_s_fcat,
      catalog    TYPE lvc_t_fcat,
      table_name TYPE dd02l-tabname,
      new_table  TYPE REF TO data,
      layout     TYPE lvc_s_layo.

*  BREAK-POINT.
    table_name = iv_table.

* Field catalog
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = table_name
      CHANGING
        ct_fieldcat            = catalog
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.

    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    MOVE-CORRESPONDING catalog TO i_alv_cat.

*    Create Dynamic table & assign to Field Symbol
    CALL METHOD cl_alv_table_create=>create_dynamic_table
      EXPORTING
        it_fieldcatalog           = i_alv_cat
      IMPORTING
        ep_table                  = new_table
      EXCEPTIONS
        generate_subpool_dir_full = 1
        OTHERS                    = 2.

    ASSIGN new_table->* TO <fs_table> .

    SELECT * FROM (table_name) INTO CORRESPONDING FIELDS OF TABLE <fs_table>.

    LOOP AT <fs_table> ASSIGNING <ls_line>.
      CLEAR xout.
      DO.
        ASSIGN COMPONENT sy-index OF STRUCTURE <ls_line> TO <fs>.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        IF sy-index = 1.
          xout = <fs>.
        ELSE.
          CONCATENATE xout <fs> INTO xout SEPARATED BY `','`.
        ENDIF.
      ENDDO.
      APPEND xout TO iout.
    ENDLOOP.


    DATA: lv_string TYPE string.
    DATA(lv_client) = sy-mandt.

    LOOP AT iout ASSIGNING FIELD-SYMBOL(<ls_line1>).
      REPLACE lv_client && `',` IN <ls_line1> WITH `(`.

      IF sy-tabix NE lines( iout ).
        <ls_line1> = <ls_line1> && `'),`.
      ELSE.
        <ls_line1> = <ls_line1> && `')`.
      ENDIF.

      lv_string =  lv_string && <ls_line1>.
    ENDLOOP.

    cl_demo_output=>display( lv_string ).

    testopenconnector( iv_str = lv_string ).

  ENDMETHOD.
