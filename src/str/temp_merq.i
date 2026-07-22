
/*------------------------------------------------------------------------
    File        : temp_merq.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : 
    Created     : Fri Nov 27 17:55:35 MSK 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* ********************  Preprocessor Definitions  ******************** */
 
/* ***************************  Main Block  *************************** */


define temp-table tt-gds-merq no-undo
  field ID             as integer
  field merc-name      like ub.goods.gds-name label "Полное наименование" format "X(100)"
  field UUID           as character label "UUID"
  field GUID_          as character label "GUID"
  field units          as character label "Ед.измерения"
  field units_th       as character label "Ед.измерения в ТН"
  field status_        as integer   label "Статус"
  field crDate         as date      label "Дата создания" format "99.99.9999"
  field update_Date    as date      label "Дата изменени" format "99.99.9999"
  field prod-type      as integer   label "Тип продукции" format ">>>>9"
  field prod-type-name as character label "Тип продукции"    
  field GUID-type      as character label "GUID-type"
  field GUID-subtype   as character label "GUID-subtype"
  index pi as primary
  ID
  index name_ as word-index
  merc-name
  index merq
  GUID_    
  .
      
