&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обмен данными с РКС

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 09/09/05
Author: Victor Guntner
Creation date: 09/09/05

Input:

Output:

*/
/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc    as handle           no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Обмен данными с РКС".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ rcs/rcsimp.i   }
{ rcs/rcsfunc.i  }
{ gbl/xmlparse.i }
{ gbl/xmlvalid.i }
{ trg/new-bcod.i }
{ gbl/cur-time.i }
{ ref/grplib.i   }
{ str/doc-code.i }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ cmp/gds-list.i gds-list def }
{ gbl/getcntxt.i def }
{ str/getctxtp.i def }
{ gbl/gbclcode.i }
{ str/prcreate.i }
{ cmp/showinf.i  }
{ trg/check-bc.i }
define input  parameter dif-pdbc as logical no-undo initial no.
define input  parameter pbc-veto  as logical no-undo.




/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit bt-config bt-import bt-export b-help ~
ed-log
&Scoped-Define DISPLAYED-OBJECTS fi-dir-imp fi-dir-exp fi-log ed-log

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-exit
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "Помощ&ь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON bt-config
     LABEL "&Настройки"
     SIZE 10 BY 1.

DEFINE BUTTON bt-export
     LABEL "&Экспорт"
     SIZE 10 BY 1.

DEFINE BUTTON bt-import
     LABEL "&Импорт"
     SIZE 10 BY 1.

DEFINE VARIABLE ed-log AS CHARACTER
     VIEW-AS EDITOR NO-WORD-WRAP SCROLLBAR-HORIZONTAL SCROLLBAR-VERTICAL LARGE
     SIZE 97 BY 15.92 NO-UNDO.

DEFINE VARIABLE fi-dir-exp AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 35.5 BY 1 NO-UNDO.

DEFINE VARIABLE fi-dir-imp AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 36.88 BY 1 NO-UNDO.

DEFINE VARIABLE fi-log AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 97 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1.17 COL 2
     bt-config AT ROW 1.17 COL 12
     bt-import AT ROW 1.17 COL 40
     bt-export AT ROW 1.17 COL 51
     b-help AT ROW 1.17 COL 89
     fi-dir-imp AT ROW 2.38 COL 13.13 NO-LABEL
     fi-dir-exp AT ROW 2.38 COL 63.5 NO-LABEL
     fi-log AT ROW 3.5 COL 2 NO-LABEL
     ed-log AT ROW 4.67 COL 2 NO-LABEL
     "Импорт из:" VIEW-AS TEXT
          SIZE 10.88 BY 1.08 AT ROW 2.29 COL 2.25
     "Экспорт в:" VIEW-AS TEXT
          SIZE 11.5 BY 1.08 AT ROW 2.29 COL 51.88
     SPACE(36.49) SKIP(17.41)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Обмен данными с РКС".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS


/* ***************  Runtime Attributes and UIB Settings  ************** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       ed-log:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN fi-dir-exp IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-dir-imp IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* SETTINGS FOR FILL-IN fi-log IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME






/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Обмен данными с РКС */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
ON CHOOSE OF b-exit IN FRAME Dialog-Frame /* Выход */
DO:
    apply "WINDOW-CLOSE" TO FRAME {&FRAME-NAME} .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-config
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-config Dialog-Frame
ON CHOOSE OF bt-config IN FRAME Dialog-Frame /* Настройки */
DO:
    run rcs/rcsconf.w (
        input parparentproc
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка при изменении параметров обмена данными с системой RCS."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    run init-fields in this-procedure no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка присвоения начальных значений полей формы."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-export
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-export Dialog-Frame
ON CHOOSE OF bt-export IN FRAME Dialog-Frame /* Экспорт */
DO:
    run export-rcs in this-procedure (
          input fi-log :handle
        , input ed-log :handle
        , input fi-dir-exp :screen-value
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка экспорта."
        skip return-value
        skip trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-import Dialog-Frame
ON CHOOSE OF bt-import IN FRAME Dialog-Frame /* Импорт */
DO:
    run import-rcs in this-procedure (
          input fi-log :handle
        , input ed-log :handle
        , input fi-dir-imp :screen-value
    ) no-error .
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка импорта."
        skip return-value
        skip trim( error-status :get-message( 1 ) )
        trim( error-status :get-message( 2 ) )
        trim( error-status :get-message( 3 ) )
        view-as alert-box error.
        run write-to-log-editor(
              input ed-log :handle
            , input 1
            , input substitute( "Ошибка импорта. &1. &2."
                                        , return-value
                                        , trim( error-status :get-message( 1 ) )
                              )
        ).
        undo, return no-apply .
    end.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

{ gbl/app_help.i }

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    { gbl/getcntxt.i get " " parparentproc }
    { str/getctxtp.i get parparentproc }
    RUN enable_UI.
    run init-fields in this-procedure no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка вычисления начальных значений для полей формы."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb-xmlparse-tag-end-mail {&FRAME-NAME}
PROCEDURE cb-xmlparse-tag-end-mail :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    assign
        v-mail-parameters-start = no
    .
end.
END PROCEDURE. /* cb-xmlparse-tag-end-mail */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb-xmlparse-tag-start-mail {&FRAME-NAME}
PROCEDURE cb-xmlparse-tag-start-mail :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    assign
        v-mail-parameters-start = yes
    .
end.
END PROCEDURE. /* cb-xmlparse-tag-start-mail */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb-xmlparse-tag-start-DESTINATION_ROID Dialog-Frame
PROCEDURE cb-xmlparse-tag-start-DESTINATION_ROID :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-param as character    no-undo.

    define buffer buf_rcs-destn     for rcs-destn.

    find first buf_rcs-destn no-lock
         where buf_rcs-destn.destination_rowid = p-param
           and buf_rcs-destn.status_ = '{&delim-flt}'
    no-error.
    if available buf_rcs-destn
    then do:
        assign
            v-selected-object-start = yes
            v-selected-object-name  = buf_rcs-destn.name
        .
    end.
    else do:
        assign
            v-selected-object-start = no
        .
    end.
end.
END PROCEDURE. /* cb-xmlparse-tag-start-DESTINATION_ROID */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb-xmlparse-tag-start-ROW Dialog-Frame
PROCEDURE cb-xmlparse-tag-start-ROW :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-param as character    no-undo.

    if v-selected-object-start = yes
    then do:
        run create-temp-table-record in this-procedure (
              input v-selected-object-name
            , input v-xmlvalid-tag-value    /* значение прочитанного тэга */
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Ошибка создания записи временной таблицы." + {&new-line} + return-value.
        end.
    end.
end.
END PROCEDURE. /* cb-xmlparse-tag-start-ROW */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE cb-xmlvalid-procedure-not-found Dialog-Frame
PROCEDURE cb-xmlvalid-procedure-not-found :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-type       as character    no-undo.
define input parameter p-value      as character    no-undo.
define input parameter p-parameters as character    no-undo.

    case p-type
    :
        when "tag-end"
        then do:
            run fill-temp-table-record in this-procedure (
                  input v-selected-object-name
                , input p-value                 /* имя прочитанного тэга */
                , input v-xmlvalid-tag-value    /* значение прочитанного тэга */
            ) no-error .
            if error-status :error
            then do:
                undo, return error "Ошибка заполнения временной таблицы." + {&new-line} + return-value.
            end.
        end.
        when "tag-start"
        then do:
            if p-value = "DESTINATION_ROID"
            then do:
                assign
                    v-selected-object-start = no
                .
                run cb-xmlparse-tag-start-DESTINATION_ROID in this-procedure ( input p-parameters ).
            end.
        end.
        when "text"
        then do:
            /* */
        end.
        otherwise do:
            /* */
        end.
    end case.
end.
END PROCEDURE. /* cb-xmlvalid-procedure-not-found */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-base-record-from-temp-table Dialog-Frame
PROCEDURE create-base-record-from-temp-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-rcs-name   as character    no-undo.
define input parameter p-ed         as handle       no-undo.
    case p-rcs-name
    :
        when "BILL"
        then do:
            for each temp_rcs-retail1bill
            :
                run import-bill in this-procedure (
                      input temp_rcs-retail1bill.id
                    , input p-ed
                ) no-error.
                if error-status :error
                then do:
                    undo, return error "Ошибка импорта товаров." + {&new-line} + return-value.
                end.
            end.
        end.
        when "BILL_ITEM"
        then do:
        end.
        when "RETAIL1_SUBJECT"
        then do:
            for each temp_rcs-retail1subject
            :
                run import-subject in this-procedure (
                      input temp_rcs-retail1subject.id
                    , input p-ed
                ) no-error.
                if error-status :error
                then do:
                    undo, return error "Ошибка импорта поставщика." + {&new-line} + return-value.
                end.
            end.
        end.
        when "RETAIL1_ATTR"
        then do:
            for each temp_rcs-retail1attr
            :
                run import-attr in this-procedure (
                      input temp_rcs-retail1attr.id
                    , input p-ed
                ) no-error.
                if error-status :error
                then do:
                    undo, return error "Ошибка импорта справочников (attr)." + {&new-line} + return-value.
                end.
            end.
        end.
        when "RETAIL1_PRODUCT"
        then do:
            for each temp_rcs-retail1product
            :
                run import-product in this-procedure (
                      input temp_rcs-retail1product.id
                    , input p-ed
                ) no-error.
                if error-status :error
                then do:
                    undo, return error "Ошибка импорта товаров." + {&new-line} + return-value.
                end.
            end.
        end.
        when "RETAIL1_PRICE_ITEM"
        then do:
        end.
        when "RETAIL1_PRICE"
        then do:
            for each temp_rcs-retail1price
            :
                run import-price in this-procedure (
                      input temp_rcs-retail1price.price_id
                    , input p-ed
                ) no-error.
                if error-status :error
                then do:
                    undo, return error "Ошибка импорта прайс-листа с ID = " + temp_rcs-retail1price.price_id + {&new-line} + return-value.
                end.
            end.
        end.
        when "RETAIL1_BARCODE"
        then do:
            for each temp_rcs-retail1barcode
            :
                run import-barcode in this-procedure (
                      input temp_rcs-retail1barcode.id
                    , input p-ed
                ) no-error.
                if error-status :error
                then do:
                    undo, return error "Ошибка импорта бар-кода с ID = " + temp_rcs-retail1barcode.id + {&new-line} + return-value.
                end.
            end.
        end.
        when "RETAIL1_DELETE"
        then do:
            for each temp_rcs-retail1delete
            :
                run delete-record in this-procedure (
                      input temp_rcs-retail1delete.name
                    , input temp_rcs-retail1delete.id
                ) no-error.
                if error-status :error
                then do:
                    undo, return error "Ошибка удаления '" + temp_rcs-retail1delete.name + "'" + " с ID '" + temp_rcs-retail1delete.id + "'" + {&new-line} + return-value.
                end.
            end.
        end.
        otherwise do:
          /* нет такого id */
        end.
    end case.
end.
END PROCEDURE. /* create-base-record-from-temp-table */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-temp-table-record Dialog-Frame
PROCEDURE create-temp-table-record :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-rcs-name   as character    no-undo.
define input parameter p-tag-value  as character    no-undo.
    case p-rcs-name
    :
        when "BILL"
        then do:
            find first temp_rcs-retail1bill
                 where temp_rcs-retail1bill.id = ""
            no-error .
            if available temp_rcs-retail1bill
            then do:
                undo, return error "Неопределенный идентификатор ID таблицы BILL при импорте." + {&new-line} + return-value.
            end.
            else do:
                create temp_rcs-retail1bill.
                assign
                    temp_rcs-retail1bill.id = ""
                .
            end.
        end.
        when "BILL_ITEM"
        then do:
            find first temp_rcs-retail1billitem
                 where temp_rcs-retail1billitem.bill_id    = ""
                   and temp_rcs-retail1billitem.product_id = ""
            no-error .
            if available temp_rcs-retail1billitem
            then do:
                undo, return error "Неопределенные идентификаторы таблицы BILL_ITEM при импорте." + {&new-line} + return-value.
            end.
            else do:
                create temp_rcs-retail1billitem .
                assign
                    temp_rcs-retail1billitem.bill_id    = ""
                    temp_rcs-retail1billitem.product_id = ""
                .
            end.
        end.
        when "RETAIL1_BANK"
        then do:
            find first temp_rcs-retail1bank
                 where temp_rcs-retail1bank.id = ""
            no-error .
            if available temp_rcs-retail1bank
            then do:
                undo, return error "Неопределенные идентификаторы таблицы RETAIL1_BANK при импорте." + {&new-line} + return-value.
            end.
            else do:
                create temp_rcs-retail1bank.
                assign
                    temp_rcs-retail1bank.id = ""
                    temp_rcs-retail1bank.bank-code = 0
                .
            end.
        end.
        when "RETAIL1_SUBJECT"
        then do:
            find first temp_rcs-retail1subject
                 where temp_rcs-retail1subject.id = ""
            no-error .
            if available temp_rcs-retail1subject
            then do:
                undo, return error "Неопределенные идентификаторы таблицы RETAIL1_SUBJECT при импорте." + {&new-line} + return-value.
            end.
            else do:
                create temp_rcs-retail1subject.
                assign
                    temp_rcs-retail1subject.id = ""
                    temp_rcs-retail1subject.obj-type = ""
                    temp_rcs-retail1subject.obj-code = 0
                .
            end.
        end.
        when "RETAIL1_ATTR"
        then do:
            find first temp_rcs-retail1attr
                 where temp_rcs-retail1attr.id = ""
            no-error .
            if available temp_rcs-retail1attr
            then do:
                undo, return error "Неопределенный идентификатор ID таблицы RETAIL1_ATTR при импорте." + {&new-line} + return-value.
            end.
            else do:
                create temp_rcs-retail1attr.
                assign
                    temp_rcs-retail1attr.id = ""
                .
            end.
        end.
        when "RETAIL1_PRODUCT"
        then do:
            find first temp_rcs-retail1product
                 where temp_rcs-retail1product.id = ""
            no-error .
            if available temp_rcs-retail1product
            then do:
                undo, return error "Неопределенный идентификатор ID таблицы RETAIL1_PRODUCT при импорте." + {&new-line} + return-value.
            end.
            else do:
                create temp_rcs-retail1product.
                assign
                    temp_rcs-retail1product.id = ""
                    temp_rcs-retail1product.gds-code = 0
                .
            end.
        end.
        when "RETAIL1_PRICE"
        then do:
            find first temp_rcs-retail1price
                 where temp_rcs-retail1price.price_id = ""
            no-error .
            if available temp_rcs-retail1price
            then do:
                undo, return error "Неопределенный идентификатор ID таблицы RETAIL1_PRICE при импорте." + {&new-line} + return-value.
            end.
            else do:
                create temp_rcs-retail1price.
                assign
                    temp_rcs-retail1price.price_id = ""
                .
            end.
        end.
        when "RETAIL1_PRICE_ITEM"
        then do:
            find first temp_rcs-retail1priceitem
                 where temp_rcs-retail1priceitem.price_id   = ""
                   and temp_rcs-retail1priceitem.id         = ""
            no-error .
            if available temp_rcs-retail1priceitem
            then do:
                undo, return error "Неопределенные идентификаторы таблицы RETAIL1_PRICE_ITEM при импорте." + {&new-line} + return-value.
            end.
            else do:
                create temp_rcs-retail1priceitem .
                assign
                    temp_rcs-retail1priceitem.price_id   = ""
                    temp_rcs-retail1priceitem.id         = ""
                .
            end.
        end.
        when "RETAIL1_BARCODE"
        then do:
            find first temp_rcs-retail1barcode
                 where temp_rcs-retail1barcode.id = ""
            no-error .
            if available temp_rcs-retail1barcode
            then do:
                undo, return error "Неопределенный идентификатор ID таблицы RETAIL1_BARCODE при импорте." + {&new-line} + return-value.
            end.
            else do:
                create temp_rcs-retail1barcode.
                assign
                    temp_rcs-retail1barcode.id = ""
                .
            end.
        end.
        when "RETAIL1_DELETE"
        then do:
            create temp_rcs-retail1delete.
            assign
                temp_rcs-retail1delete.name = ""
                temp_rcs-retail1delete.id = ""
            .
        end.
        when "RETAIL1_CONVOLUTION"
        then do:
            find first temp_rcs-retail1convolution
                 where temp_rcs-retail1convolution.site_id  = ""
                   and temp_rcs-retail1convolution.docdate  = ?
                   and temp_rcs-retail1convolution.tov      = ""
            no-error .
            if available temp_rcs-retail1convolution
            then do:
                undo, return error "Неопределенные идентификаторы таблицы RETAIL1_CONVOLUTION при импорте." + {&new-line} + return-value.
            end.
            else do:
                create temp_rcs-retail1convolution.
                assign
                    temp_rcs-retail1convolution.site_id  = ""
                    temp_rcs-retail1convolution.docdate  = ?
                    temp_rcs-retail1convolution.tov      = ""
                .
            end.
        end.
        otherwise do:
          /* нет такого id */
        end.
    end case.
end.
END PROCEDURE. /* create-temp-table-record */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame _DEFAULT-ENABLE
PROCEDURE enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  DISPLAY fi-dir-imp fi-dir-exp fi-log ed-log
      WITH FRAME Dialog-Frame.
  ENABLE b-exit bt-config bt-import bt-export b-help ed-log
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE export-rcs Dialog-Frame
PROCEDURE export-rcs :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-fi     as handle       no-undo.
define input parameter p-ed     as handle       no-undo.
define input parameter p-dir    as character    no-undo.

define variable v-date-from         as date             no-undo. /* начало периода экспорта */
define variable v-date-to           as date             no-undo. /* конец  периода экспорта */
define variable v-range             as integer          no-undo.
define variable v-obj-list          as character        no-undo.
define variable v-pay-type-list     as character        no-undo.
define variable v-pay-code          as logical          no-undo.  /* надо ли экспортировать суммы по касс. платежам */
define variable v-cst               as logical          no-undo.  /* надо ли экспортировать ГТД в строке товара */
define variable v-xml-file-name     as character        no-undo.
define variable v-log-file-name     as character        no-undo.
define variable v-counter           as integer          no-undo.


    /* период экспорта */
    define variable v-host-code     as integer      no-undo.
    define variable v-doc-type-list as character    no-undo.
    define variable v-cancel        as logical      no-undo.
    define variable v-void-logical  as logical      no-undo.
    run bge/bge-dper.w (
          input parparentproc
        , input 1
        , input "":U
        , output v-date-from
        , output v-date-to
        , output v-range
        , output v-host-code
        , output v-obj-list
        , OUTPUT v-pay-type-list
        , output v-doc-type-list
        , output v-pay-code
        , output v-cst
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-void-logical
        , output v-cancel
    ) no-error .
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка ввода параметров выгрузки документов."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    if v-cancel = yes
    then do:
        undo, return.
    end.
    /*---START--------- Сгенерировать имя файла и создать пустой файл для экспорта ---------------------*/
    generate-filename:
    do while true
    :
        assign
            v-counter = v-counter + 1
            v-xml-file-name = p-dir + {&back-slash-char} + "out" + string( v-counter )
        .
        if search ( v-xml-file-name + ".xml" ) = ?
        then do:
            leave generate-filename.
        end.
    end.

    ASSIGN v-log-file-name = v-xml-file-name + ".log".

    output to value( v-xml-file-name + ".xm1" ) convert target "1251" .
    output close.
    /*---END----------- Сгенерировать имя файла и создать пустой файл для экспорта ---------------------*/

    if v-date-from = ? or v-date-to = ? then return error. /* отказ */

    run write-to-log-editor( p-ed, 1, "Экспорт документов"
                                + ", диапазон дат " + string(v-date-from, "99.99.99")
                                + " - " + string(v-date-to, "99.99.99")
                      ).
    run write-to-log-editor( p-ed, 1, "Диапазон:"
                                + ( if v-range = 1
                                    then " по всем фирмам"
                                    else ( if v-range = 2
                                           then " по всем объектам текущей фирмы"
                                           else " по объектам: " + v-obj-list ) )
                      ).
    if v-pay-code = yes
    then do:
        run write-to-log-editor( p-ed, 1, "С кодами оплаты в документах" ).
    end.
    if v-cst = yes
    then do:
        run write-to-log-editor( p-ed, 1, "Со строкой ГТД в документах" ).
    end.
    process events.

    run rcs/rcs-docs.p (
          input parparentproc
        , input p-dir + {&back-slash-char} + {&export-oper-head-filename}
        , input p-dir + {&back-slash-char} + {&export-oper-body-filename}
        , input v-date-from
        , input v-date-to
        , input v-range
        , input v-obj-list
        , input v-pay-code
        , input v-cst
        , input p-ed
        , input p-fi
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка экспорта документов"
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    run write-to-log-editor( p-ed, 1, "Копирование в файл экспорта." ).
    os-append value( p-dir + {&back-slash-char} + {&export-oper-head-filename} + ".xm1" ) value( v-xml-file-name + ".xm1" ).
    if os-error <> 0
    then do:
        run write-to-log-editor( p-ed, 1, "Ошибка копирования файла шапок документов. Код ошибки " + string( os-error ) + ". Данные остались во временном файле." ).
    end.
    os-append value( p-dir + {&back-slash-char} + {&export-oper-body-filename} + ".xm1" ) value( v-xml-file-name + ".xm1" ).
    if os-error <> 0
    then do:
        run write-to-log-editor( p-ed, 1, "Ошибка копирования файла строк документов. Код ошибки " + string( os-error ) + ". Данные остались во временном файле." ).
    end.
    run write-to-log-editor( p-ed, 1, "Экспорт документов завершен." ).
    run write-to-log-editor( p-ed, 1, "Экспорт свертки"
                                + " за дату " + string(v-date-to, "99.99.99")
                      ).
    run rcs/rcs-day.p (
          input parparentproc
        , input p-dir + {&back-slash-char} + {&export-day-filename}
        , input v-date-to
        , input v-range
        , input v-obj-list
        , input p-ed
        , input p-fi
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка экспорта свертки."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    run write-to-log-editor( p-ed, 1, "Копирование в файл экспорта." ).
    os-append value( p-dir + {&back-slash-char} + {&export-day-filename} + ".xm1" ) value( v-xml-file-name + ".xm1" ).
    if os-error <> 0
    then do:
        run write-to-log-editor( p-ed, 1, "Ошибка копирования файла свертки. Код ошибки " + string( os-error ) + ". Данные остались во временном файле." ).
    end.
    run write-to-log-editor( p-ed, 1, "Экспорт свертки завершен." ).
    run write-to-log-editor( p-ed, 1, "Экспорт весовых бар-кодов." ).
    run rcs/rcs-bcod.p (
          input parparentproc
        , input p-dir + {&back-slash-char} + {&export-bcod-filename}
        , input v-date-to
        , input v-range
        , input v-obj-list
        , input p-ed
        , input p-fi
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка экспорта весовых бар-кодов."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
               trim(error-status :get-message(4))
               trim(error-status :get-message(5))
        view-as alert-box error.
        undo, return error .
    end.
    run write-to-log-editor( p-ed, 1, "Копирование в файл экспорта." ).
    os-append value( p-dir + {&back-slash-char} + {&export-bcod-filename} + ".xm1" ) value( v-xml-file-name + ".xm1" ).
    if os-error <> 0
    then do:
        run write-to-log-editor( p-ed, 1, "Ошибка копирования файла весовых бар-кодов. Код ошибки " + string( os-error ) + ". Данные остались во временном файле." ).
    end.
    run write-to-log-editor( p-ed, 1, "Экспорт весовых бар-кодов завершен.").
    os-rename value( v-xml-file-name + ".xm1" ) value( v-xml-file-name + ".xml" ).
    if os-error = 999       /* OS не позволяет переименовать файл. Тогда копировать. */
    then do:
        os-copy value( v-xml-file-name + ".xm1" ) value( v-xml-file-name + ".xml" ).
        if os-error = 0 then do:
            os-delete value( v-xml-file-name + ".xm1" ) .
        end.
    end.
end.
END PROCEDURE. /* export-rcs */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-table-record Dialog-Frame
PROCEDURE fill-temp-table-record :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-rcs-name   as character    no-undo.
define input parameter p-tag-name   as character    no-undo.
define input parameter p-tag-value  as character    no-undo.

    if v-mail-parameters-start = yes
    then do:
        case p-tag-name
        :
            when "X-ReportType"
            then do:
                assign
                    v-mail-ReportType = p-tag-value
                .
            end.
            when "X-IDChannel"
            then do:
                assign
                    v-mail-IDChannel = p-tag-value
                .
            end.
            when "X-ReportNumber"
            then do:
                assign
                    v-mail-ReportNumber = p-tag-value
                .
            end.
        end case.
    end.        /* v-mail-parameters-start = yes */
    else do:
        case p-rcs-name
        :
            when "BILL"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1bill      for temp_rcs-retail1bill.
                        define buffer buf_del_temp_rcs-retail1billitem  for temp_rcs-retail1billitem.
                        find first buf_del_temp_rcs-retail1bill
                             where buf_del_temp_rcs-retail1bill.id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1bill
                        then do:
                            run write-to-log-editor in this-procedure (
                                  input ed-log :handle in frame {&frame-name}
                                , input 1
                                , input substitute( "Повторные данные о приходе с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                   )
                            ).
                            delete buf_del_temp_rcs-retail1bill.
                            for each buf_del_temp_rcs-retail1billitem
                               where buf_del_temp_rcs-retail1billitem.bill_id = p-tag-value
                            :
                                delete buf_del_temp_rcs-retail1billitem.
                            end.
                        end.
                        assign
                            temp_rcs-retail1bill.id = p-tag-value
                        .
                    end.
                    when "DOCNOMER"
                    then do:
                        assign
                            temp_rcs-retail1bill.docnomer = p-tag-value
                        .
                    end.
                    when "DOCDATE"
                    then do:
                        assign
                            temp_rcs-retail1bill.docdate = date( integer( substring( p-tag-value, 5, 2 ) )
                                                                , integer( substring( p-tag-value, 7, 2 ) )
                                                                , integer( substring( p-tag-value, 1, 4 ) ) )
                        .
                    end.
                    when "SUBJECT_ID"
                    then do:
                        assign
                            temp_rcs-retail1bill.subject_id = p-tag-value
                        .
                    end.
                    when "DOC_TYPE_ID"
                    then do:
                        assign
                            temp_rcs-retail1bill.doc_type_id = integer( p-tag-value )
                        .
                    end.
                    when "SITE_ID"
                    then do:
                        assign
                            temp_rcs-retail1bill.site_id = p-tag-value
                        .
                    end.
                    otherwise do:

                    end.
                end case.
            end.
            when "RETAIL1_BANK"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1bank      for temp_rcs-retail1bank.
                        find first buf_del_temp_rcs-retail1bank
                             where buf_del_temp_rcs-retail1bank.id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1bank
                        then do:
                            run write-to-log-editor in this-procedure (
                                  input ed-log :handle in frame {&frame-name}
                                , input 1
                                , input substitute( "Повторные данные о банке с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                   )
                            ).
                            delete buf_del_temp_rcs-retail1bank.
                        end.
                        assign
                            temp_rcs-retail1bank.id = p-tag-value
                        .
                    end.
                    when "BANK_ADDRESS"
                    then do:
                        assign
                            temp_rcs-retail1bank.bank_address = p-tag-value
                        .
                    end.
                    when "BANK_NAME"
                    then do:
                        assign
                            temp_rcs-retail1bank.bank_name = p-tag-value
                        .
                    end.
                    when "BIC"
                    then do:
                        assign
                            temp_rcs-retail1bank.bic = p-tag-value
                        .
                    end.
                    when "CORRESPONDING_ACCOUNT"
                    then do:
                        assign
                            temp_rcs-retail1bank.corresponding_account = p-tag-value
                        .
                    end.
                end case.
            end.
            when "RETAIL1_SUBJECT"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1subject      for temp_rcs-retail1subject.
                        find first buf_del_temp_rcs-retail1subject
                             where buf_del_temp_rcs-retail1subject.id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1subject
                        then do:
                            run write-to-log-editor in this-procedure (
                                    input ed-log :handle in frame {&frame-name}
                                , input 1
                                , input substitute( "Повторные данные о поставщике с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                    )
                            ).
                            delete buf_del_temp_rcs-retail1subject.
                        end.
                        assign
                            temp_rcs-retail1subject.id = p-tag-value
                        .
                    end.
                    when "CNAME"
                    then do:
                        assign
                            temp_rcs-retail1subject.cname = p-tag-value
                        .
                    end.
                    when "RETAIL_SUBJECT_TYPE"
                    then do:
                        assign
                            temp_rcs-retail1subject.retail_subject_type = p-tag-value
                        .
                    end.
                    when "INN"
                    then do:
                        assign
                            temp_rcs-retail1subject.inn = p-tag-value
                        .
                    end.
                    when "OFFICIAL_ADDRESS"
                    then do:
                        assign
                            temp_rcs-retail1subject.official_address = p-tag-value
                        .
                    end.
                    when "BANK_ID"
                    then do:
                        assign
                            temp_rcs-retail1subject.bank_id = p-tag-value
                        .
                    end.
                    when "BANK_ACCOUNT"
                    then do:
                        assign
                            temp_rcs-retail1subject.bank_account = p-tag-value
                        .
                    end.
                end case.
            end.
            when "RETAIL1_ATTR"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1attr      for temp_rcs-retail1attr.
                        find first buf_del_temp_rcs-retail1attr
                             where buf_del_temp_rcs-retail1attr.id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1attr
                        then do:
                            run write-to-log-editor in this-procedure (
                                  input ed-log :handle in frame {&frame-name}
                                , input 1
                                , input substitute( "Повторные данные об атрибуте с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                   )
                            ).
                            delete buf_del_temp_rcs-retail1attr.
                        end.
                        assign
                            temp_rcs-retail1attr.id = p-tag-value
                        .
                    end.
                    when "RETAIL_ATTR_TYPE"
                    then do:
                        assign
                            temp_rcs-retail1attr.retail_attr_type = integer( p-tag-value )
                        .
                    end.
                    when "NAME"
                    then do:
                        assign
                            temp_rcs-retail1attr.name = p-tag-value
                        .
                    end.
                end case.
            end.
            when "RETAIL1_PRODUCT"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1product      for temp_rcs-retail1product.
                        find first buf_del_temp_rcs-retail1product
                             where buf_del_temp_rcs-retail1product.id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1product
                        then do:
                            run write-to-log-editor in this-procedure (
                                  input ed-log :handle in frame {&frame-name}
                                , input 1
                                , input substitute( "Повторные данные о товаре с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                    )
                            ).
                            delete buf_del_temp_rcs-retail1product.
                        end.
                        assign
                            temp_rcs-retail1product.id = p-tag-value
                        .
                    end.
                    when "FULL_NAME"
                    then do:
                        assign
                            temp_rcs-retail1product.full_name = p-tag-value
                        .
                    end.
                    when "SHORT_NAME"
                    then do:
                        assign
                            temp_rcs-retail1product.short_name = p-tag-value
                        .
                    end.
                    when "RETAIL_PACK_ID"
                    then do:
                        assign
                            temp_rcs-retail1product.retail_pack_id = p-tag-value
                        .
                    end.
                    when "RETAIL_MARK_ID"
                    then do:
                        assign
                            temp_rcs-retail1product.retail_mark_id = p-tag-value
                        .
                    end.
                    when "RETAIL_PLACE_ID"
                    then do:
                        assign
                            temp_rcs-retail1product.retail_place_id = p-tag-value
                        .
                    end.
                    when "WEIGHT_FLAG"
                    then do:
                        assign
                            temp_rcs-retail1product.weight_flag = integer( p-tag-value )
                        .
                    end.
                    when "ACTIVE"
                    then do:
                        assign
                            temp_rcs-retail1product.active = p-tag-value
                        .
                    end.
                    when "RETAIL_PRODUCER_ID"
                    then do:
                        assign
                            temp_rcs-retail1product.retail_producer_id = p-tag-value
                        .
                    end.
                    when "RETAIL_LABEL_ID"
                    then do:
                        assign
                            temp_rcs-retail1product.retail_label_id = p-tag-value
                        .
                    end.
                    when "RETAIL_CITY_ID"
                    then do:
                        assign
                            temp_rcs-retail1product.retail_city_id = p-tag-value
                        .
                    end.
                    when "RETAIL_COUNTRY_ID"
                    then do:
                        assign
                            temp_rcs-retail1product.retail_country_id = p-tag-value
                        .
                    end.
                end case.
            end.
            when "RETAIL1_PRICE_ITEM"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        assign
                            temp_rcs-retail1priceitem.id = p-tag-value
                        .
                    end.
                    when "PRICE_COST"
                    then do:
                        assign
                            temp_rcs-retail1priceitem.price_cost = decimal( p-tag-value )
                        .
                    end.
                    when "PRICE_ID"
                    then do:
                        assign
                            temp_rcs-retail1priceitem.price_id = p-tag-value
                        .
                    end.
                    when "ACTIVE"
                    then do:
                        assign
                            temp_rcs-retail1priceitem.active = p-tag-value
                        .
                    end.
                end case.
            end.
            when "RETAIL1_PRICE"
            then do:
                case p-tag-name
                :
                    when "PRICE_ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1price      for temp_rcs-retail1price.
                        define buffer buf_del_temp_rcs-retail1priceit    for temp_rcs-retail1priceitem.
                        find first buf_del_temp_rcs-retail1price
                             where buf_del_temp_rcs-retail1price.price_id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1price
                        then do:
                            run write-to-log-editor in this-procedure (
                                  input ed-log :handle in frame {&frame-name}
                                , input 1
                                , input substitute( "Повторные данные о переоценке с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                    )
                            ).
                            delete buf_del_temp_rcs-retail1price.
                            for each buf_del_temp_rcs-retail1priceit
                               where buf_del_temp_rcs-retail1priceit.price_id = p-tag-value
                            :
                                delete buf_del_temp_rcs-retail1price.
                            end.
                        end.
                        assign
                            temp_rcs-retail1price.price_id = p-tag-value
                        .
                    end.
                    when "DDAT"
                    then do:
                        assign
                            temp_rcs-retail1price.ddat = date( integer( substring( p-tag-value, 5, 2 ) )
                                                            , integer( substring( p-tag-value, 7, 2 ) )
                                                            , integer( substring( p-tag-value, 1, 4 ) ) )
                        .
                    end.
                    when "DOC_TYPE"
                    then do:
                        assign
                            temp_rcs-retail1price.doc_type = p-tag-value
                        .
                    end.
                    when "STAD"
                    then do:
                        assign
                            temp_rcs-retail1price.stad = p-tag-value
                        .
                    end.
                    when "DOC_MODE"
                    then do:
                        assign
                            temp_rcs-retail1price.doc-mode = p-tag-value
                        .
                    end.
                    when "CORR"
                    then do:
                        assign
                            temp_rcs-retail1price.corr = p-tag-value
                        .
                    end.
                    when "SITE_ID"
                    then do:
                        assign
                            temp_rcs-retail1price.site_id = p-tag-value
                        .
                    end.
                end case.
            end.
            when "RETAIL1_BARCODE"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1barcode      for temp_rcs-retail1barcode.
                        find first buf_del_temp_rcs-retail1barcode
                             where buf_del_temp_rcs-retail1barcode.id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1barcode
                        then do:
                            run write-to-log-editor in this-procedure (
                                  input ed-log :handle in frame {&frame-name}
                                , input 1
                                , input substitute( "Повторные данные о бар-коде с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                    )
                            ).
                            delete buf_del_temp_rcs-retail1barcode.
                        end.
                        assign
                            temp_rcs-retail1barcode.id = p-tag-value
                        .
                    end.
                    when "RETAIL_PRODUCT_ID"
                    then do:
                        assign
                            temp_rcs-retail1barcode.retail_product_id = p-tag-value
                        .
                    end.
                    when "BARCODE"
                    then do:
                        assign
                            temp_rcs-retail1barcode.barcode = p-tag-value
                        .
                    end.
                end case.
            end.
            when "RETAIL1_DELETE"
            then do:
                case p-tag-name
                :
                    when "ID"
                    then do:
                        define buffer buf_del_temp_rcs-retail1delete      for temp_rcs-retail1delete.
                        find first buf_del_temp_rcs-retail1delete
                             where buf_del_temp_rcs-retail1delete.id = p-tag-value
                        no-error.
                        if available buf_del_temp_rcs-retail1delete
                        then do:
                            run write-to-log-editor in this-procedure (
                                  input ed-log :handle in frame {&frame-name}
                                , input 1
                                , input substitute( "Повторные данные об удалении записи с id: &1. Данные будут загружены из файла: &2"
                                                    , p-tag-value
                                                    , temp_file.name
                                                    )
                            ).
                            delete buf_del_temp_rcs-retail1delete.
                        end.
                        assign
                            temp_rcs-retail1delete.id = p-tag-value
                        .
                    end.
                    when "NAME"
                    then do:
                        assign
                            temp_rcs-retail1delete.name = p-tag-value
                        .
                    end.
                end case.
            end.
            when "BILL_ITEM"
            then do:
                case p-tag-name
                :
                    when "BILL_ID"
                    then do:
                        assign
                            temp_rcs-retail1billitem.bill_id = p-tag-value
                        .
                    end.
                    when "PRODUCT_ID"
                    then do:
                        assign
                            temp_rcs-retail1billitem.product_id = p-tag-value
                        .
                    end.
                    when "COUNT1"
                    then do:
                        assign
                            temp_rcs-retail1billitem.count1 = decimal( p-tag-value )
                        .
                    end.
                    when "COST1"
                    then do:
                        assign
                            temp_rcs-retail1billitem.cost1 = decimal( p-tag-value )
                        .
                    end.
                end case.
            end.
            otherwise do:
            /* нет такого id */
            end.
        end case.
    end.        /* v-mail-parameters-start = no */

end.
END PROCEDURE. /* fill-temp-table-record */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-rcs Dialog-Frame
PROCEDURE import-rcs :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-fi     as handle       no-undo.
define input parameter p-ed     as handle       no-undo.
define input parameter p-dir    as character    no-undo.

    define variable v-not-first     as logical  init no  no-undo.
    define variable v-counter       as integer           no-undo.
    define variable v-filename      as character         no-undo.
    define variable v-par-value     as character         no-undo.
    define variable v-par-type      as character         no-undo.

    define buffer buf_rcs-destn     for rcs-destn.
    define buffer buf_usr-flt       for ubflt.usr-flt.

    run get-default-value in this-procedure (
          input {&group}
        , output v-par-value
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана группа по определению для товара." + {&new-line} + return-value.
    end.
    assign
        v-default-gds-grp-node-code = integer( v-par-value )
    .
    run get-default-value in this-procedure (
          input {&clients-group}
        , output v-par-value
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана группа по определению для поставщика ." + {&new-line} + return-value.
    end.
    assign
        v-default-cli-grp-node-code = integer( v-par-value )
    .
    run get-default-value in this-procedure (
          input {&pieces}
        , output v-unit-pieces
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана единица измерения для штучного товара." + {&new-line} + return-value.
    end.
    run get-default-value in this-procedure (
          input {&divisional}
        , output v-unit-divisional
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана единица измерения для дробного товара." + {&new-line} + return-value.
    end.
    run get-default-value in this-procedure (
          input {&weight}
        , output v-unit-weight
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана единица измерения для весового товара." + {&new-line} + return-value.
    end.

    run get-default-value in this-procedure (
          input {&preparation}
        , output v-par-value
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана единица измерения для штучного товара." + {&new-line} + return-value.
    end.
    assign
        v-default-wrkr = integer( v-par-value )
    .
    run get-default-value in this-procedure (
          input {&permission}
        , output v-par-value
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана единица измерения для штучного товара." + {&new-line} + return-value.
    end.
    assign
        v-default-agnt = integer( v-par-value )
    .
    run get-default-value in this-procedure (
          input {&shipping}
        , output v-par-value
    ) no-error .
    if error-status :error
    then do:
        undo, return error "import-rcs: Не задана единица измерения для штучного товара." + {&new-line} + return-value.
    end.
    assign
        v-default-boss = integer( v-par-value )
    .
    for each temp_rcs-retail1bill
    :
        delete temp_rcs-retail1bill.
    end.
    for each temp_rcs-retail1billitem
    :
        delete temp_rcs-retail1billitem.
    end.
    for each temp_rcs-retail1subject
    :
        delete temp_rcs-retail1subject.
    end.
    for each temp_rcs-retail1bank
    :
        delete temp_rcs-retail1bank.
    end.
    for each temp_rcs-retail1attr
    :
        delete temp_rcs-retail1attr.
    end.
    for each temp_rcs-retail1product
    :
        delete temp_rcs-retail1product.
    end.
    for each temp_rcs-retail1price
    :
        delete temp_rcs-retail1price.
    end.
    for each temp_rcs-retail1priceitem
    :
        delete temp_rcs-retail1priceitem.
    end.
    for each temp_rcs-retail1barcode
    :
        delete temp_rcs-retail1barcode.
    end.
    for each temp_rcs-retail1convolution
    :
        delete temp_rcs-retail1convolution.
    end.
    run write-to-log-editor( p-ed, 1, "Импорт из файлов:" ).
    assign
        v-import-record-count   = 0
    .
    input stream dirstream from os-dir( p-dir ).
    read-file:
    repeat
    :
        find first temp_file no-error.
        if not available temp_file
        then do:
            create temp_file.
        end.
        import stream dirstream temp_file.
        if temp_file.type = "F":U
        then do:
            define variable v-new-filename-full     as character         no-undo.
            run write-to-log-editor( p-ed, 4, temp_file.name ).
            process events.
            assign
                v-selected-object-start = no
            .
            run read-file in this-procedure ( input p-fi, input p-ed, input temp_file.fullname ) no-error.
            if error-status :error
            then do:
                undo, return error "import-rcs: Ошибка чтения файла." + {&new-line} + return-value.
            end.
            else do: /* Переместить импортированный файл в подкаталог OLD. Создать OLD, если его нет */
                run check-and-create-subdir in this-procedure ( input p-dir, input "old" ) no-error.
                if error-status :error
                then do:
                    run write-to-log-editor( p-ed, 4, "Не удалось создать подкаталог OLD. Импортированный файл не будет удален." ).
                    next read-file.
                end.
                run get-or-generate-filename in this-procedure (
                      input p-dir + {&back-slash-char} + "old"
                    , input temp_file.name
                    , output v-new-filename-full
                ) no-error.
                if error-status :error
                then do:
                    run write-to-log-editor( p-ed, 4, "Невозможно получить имя файла для переименования. Импортированный файл не будет удален." ).
                    next read-file.
                end.
                os-rename value( temp_file.fullname ) value( v-new-filename-full ).
                if os-error <> 0
                then do:
                    run write-to-log-editor( p-ed, 4, "Невозможно переименовать файл. Импортированный файл не будет удален." ).
                    next read-file.
                end.
            end.
        end.
    end.
    run write-to-log-editor( p-ed, 1, "Чтение файлов завершено." ).

    run adm/shattri.p (
        input "get":U
        ,input  '':U /*p-obj-type*/
        ,input  0 /*p-obj-code*/
        ,input  {&attr-gds-ref}
        ,input  {&attr-gds-ref_dif-nam1} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-goods-parameter-dif-nam1
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error.
    delete object v-tth.
    run adm/shattri.p (
        input "get":U
        ,input  '':U /*p-obj-type*/
        ,input  0 /*p-obj-code*/
        ,input  {&attr-gds-ref}
        ,input  {&attr-gds-ref_dif-nam2} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-goods-parameter-dif-nam2
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error.
    delete object v-tth.
    run adm/shattri.p (
        input "get":U
        ,input  '':U /*p-obj-type*/
        ,input  0 /*p-obj-code*/
        ,input  {&attr-gds-ref}
        ,input  {&attr-gds-ref_dif-pdbc} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output dif-pdbc
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error.
    delete object v-tth.
    run adm/shattri.p (
        input "get":U
        ,input  '':U /*p-obj-type*/
        ,input  0 /*p-obj-code*/
        ,input  {&attr-gds-ref}
        ,input  {&attr-gds-ref_pbc-veto} /*p-param-code*/
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output pbc-veto
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error.
    delete object v-tth.

    for each buf_rcs-destn no-lock
       where buf_rcs-destn.status_ = '{&delim-flt}'
    by buf_rcs-destn.chanel
    :
        run write-to-log-editor( p-ed, 1, buf_rcs-destn.name ).
        run create-base-record-from-temp-table in this-procedure (
            input buf_rcs-destn.name
            , input p-ed
        ) no-error .
        if error-status :error
        then do:
            undo, return error "Ошибка создания записи базы данных." + {&new-line} + return-value.
        end.
    end.
    if v-import-record-count = 0
    then do:
        run write-to-log-editor( p-ed, 1, "Не было импортировано ни одной записи." ).
    end.
    else do:
        run write-to-log-editor( p-ed, 1, "Количество новых записей: " + string( v-import-record-count ) ).
    end.
    run write-to-log-editor( p-ed, 1, "Импорт завершен." ).

end.
END PROCEDURE. /* import-rcs */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-subject Dialog-Frame
PROCEDURE import-subject :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-firm-id    as character    no-undo.
define input parameter p-ed         as handle       no-undo.

    define variable v-firm-code     as integer           no-undo.
    define variable v-bank-num      as integer           no-undo.
    define variable v-today         as date      no-undo.
    define variable v-time          as integer   no-undo.


    define buffer buf_clients                   for clients.
    define buffer buf_cli-grp                   for cli-grp.
    define buffer buf_firm                      for firm.
    define buffer buf_fin-bank                  for fin-bank.
    define buffer buf_rcs-retail1bank           for rcs-retail1bank.
    define buffer buf_rcs-retail1subject        for rcs-retail1subject.
    define buffer buf_temp_rcs-retail1subject   for temp_rcs-retail1subject.
    define buffer buf_temp_rcs-retail1bank      for temp_rcs-retail1bank.
    define buffer buf_rcs-clients               for rcs-clients.

    find first buf_temp_rcs-retail1subject
         where buf_temp_rcs-retail1subject.id = p-firm-id
    no-error.
    if not available buf_temp_rcs-retail1subject
    then do:
        undo, return error "import-subject: Ошибка поиска во временной таблице." + {&new-line} + return-value.
    end.
    find first buf_rcs-retail1subject no-lock
         where buf_rcs-retail1subject.id = p-firm-id
    no-error.
    if available buf_rcs-retail1subject
    then do:
        run write-to-log-editor in this-procedure (
              input p-ed
            , input 1
            , input "Поставщик с ID = " + p-firm-id  + " уже был импортирован."
        ).
    end.
    else do:
        find first buf_cli-grp no-lock
             where buf_cli-grp.node-code = v-default-cli-grp-node-code
        no-error.
        if not available buf_cli-grp
        then do:
            undo, return error "import-subject: Ошибка поиска группы для поставщика." + {&new-line} + return-value.
        end.
        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        do transaction
        :
            run create-firm in this-procedure (
                  input ""                                              /* city          */
                , input 0                                               /* ind           */
                , input buf_temp_rcs-retail1subject.official_address    /* addres1       */
                , input ""                                              /* addres2       */
                , input ""                                              /* director      */
                , input ""                                              /* gen-acct      */
                , input ""                                              /* phone         */
                , input ""                                              /* fax           */
                , input ""                                              /* engl-name     */
                , input ""                                              /* contact-psn   */
                , input 0                                               /* tobj-code     */
                , input buf_temp_rcs-retail1subject.inn                 /* inn           */
                , input ""                                              /* okpo          */
                , input ""                                              /* okonh         */
                , input ""                                              /* phone1-note   */
                , input ""                                              /* e-mail        */
                , input ""                                              /* post-addr1    */
                , input ""                                              /* post-addr2    */
                , input ""                                              /* telex         */
                , input ""                                              /* main-obj-type */
                , input 0                                               /* main-obj-code */
                , output v-firm-code                                    /* firm-code     */
            ) no-error .
            if error-status :error
            then do:
                undo, return error "import-subject: Ошибка создания записи фирмы поставщика." + {&new-line} + return-value.
            end.
            run create-clients in this-procedure (
                  input {&cmp}                              /* p-obj-type */
                , input v-firm-code                         /* p-obj-code */
                , input buf_temp_rcs-retail1subject.cname   /* p-obj-name */
                , input buf_cli-grp.node-code               /* p-grp-code */
                , input -1                                  /* p-db-num   */
                , input 0                                   /* p-stts     */
                , input ""                                  /* p-PS       */
                , input buf_cli-grp.node-name               /* p-grp-name */
                , input 0                                   /* p-num_podr */
                , input no                                  /* p-is-prod  */
                , input yes                                 /* p-sup-gds  */
                , input no                                  /* p-sup-serv */
                , input no                                  /* p-buy-gds  */
                , input no                                  /* p-buy-serv */
                , input no                                  /* p-buy-cons */
                , input no                                  /* p-sup-cons */
                , input 0                                   /* p-lim-kr   */
            ) no-error .
            if error-status :error
            then do:
                undo, return error "import-subject: Ошибка создания записи поставщика." + {&new-line} + return-value.
            end.
            create buf_rcs-retail1subject.
            assign
                buf_rcs-retail1subject.id                   = p-firm-id
                buf_rcs-retail1subject.obj-code             = v-firm-code
                buf_rcs-retail1subject.obj-type             = {&cmp}
                buf_rcs-retail1subject.file-name            = fi-dir-imp :screen-value in frame {&frame-name}
                buf_rcs-retail1subject.cname                = buf_temp_rcs-retail1subject.cname
                buf_rcs-retail1subject.imp-date             = v-today
                buf_rcs-retail1subject.imp-time             = v-time
                buf_rcs-retail1subject.imp-user             = v-cntxt-userid
                buf_rcs-retail1subject.inn                  = buf_temp_rcs-retail1subject.inn
                buf_rcs-retail1subject.official_address     = buf_temp_rcs-retail1subject.official_address
                buf_rcs-retail1subject.retail_subject_type  = buf_temp_rcs-retail1subject.retail_subject_type
                v-import-record-count                       = v-import-record-count + 1
            .
            create buf_rcs-clients.
            assign
                buf_rcs-clients.id          = p-firm-id
                buf_rcs-clients.obj-type    = {&cmp}
                buf_rcs-clients.obj-code    = v-firm-code
                buf_rcs-clients.name        = buf_temp_rcs-retail1subject.cname
            .
            find first buf_temp_rcs-retail1bank no-lock
                 where buf_temp_rcs-retail1bank.id = buf_temp_rcs-retail1subject.bank_id
            no-error .
            if available buf_temp_rcs-retail1bank
            then do:
                create buf_fin-bank.
                run genscode-generate-num-bank in this-procedure ( output v-bank-num ) no-error .
                if error-status :error
                then do:
                    undo, return error "import-subject: Ошибка генерации уникального кода для банка." + {&new-line} + return-value.
                end.
                assign
                    buf_fin-bank.host-code = v-firm-code
                    buf_fin-bank.code-bank = integer( buf_temp_rcs-retail1bank.bic )
                .
                create buf_rcs-retail1bank.
                assign
                    buf_rcs-retail1bank.id                      = buf_temp_rcs-retail1bank.id
                    buf_rcs-retail1bank.bank_address            = buf_temp_rcs-retail1bank.bank_address
                    buf_rcs-retail1bank.bank_name               = buf_temp_rcs-retail1bank.bank_name
                    buf_rcs-retail1bank.corresponding_account   = buf_temp_rcs-retail1bank.corresponding_account
                    buf_rcs-retail1bank.bic                     = buf_temp_rcs-retail1bank.bic
                    buf_rcs-retail1bank.bank-num                = v-bank-num
                    buf_rcs-retail1bank.file-name               = fi-dir-imp :screen-value in frame {&frame-name}
                    buf_rcs-retail1bank.imp-date                = v-today
                    buf_rcs-retail1bank.imp-time                = v-time
                    buf_rcs-retail1bank.imp-user                = v-cntxt-userid
                .
            end.
            process events.
            assign
                fi-log :screen-value in frame {&frame-name} = "Импортирован поставщик: "
                                                + buf_temp_rcs-retail1subject.id
                                                + "   " + string( v-firm-code )
                                                + "   " + buf_temp_rcs-retail1subject.cname
            .
        end.
    end.
end.
END PROCEDURE. /* import-subject */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    define variable v-dir     as character         no-undo.
    define buffer buf_usr-flt       for ubflt.usr-flt.

    define variable v-cancel     as logical           no-undo.
    define variable v-param-type                as character                no-undo.
    define variable v-value-character           as character                no-undo.
    define variable v-value-date                as date                     no-undo.
    define variable v-value-decimal             as decimal                  no-undo.
    define variable v-value-integer             as INTEGER                  no-undo.
    define variable v-value-logical             AS LOGICAL                  no-undo.
    define variable v-tth                       as handle                   no-undo.


    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = {&rcsimp-import-directory}
    no-error .
    if not available buf_usr-flt
    then do:
        run select-dir in this-procedure (
              input {&rcsimp-import-directory}
            , output v-dir
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора каталога." + {&new-line} + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-dir-imp :screen-value in frame {&frame-name} = v-dir
            .
        end.
    end.
    else do:
        assign
            fi-dir-imp :screen-value in frame {&frame-name} = buf_usr-flt.Naim
        .
    end.
    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = {&rcsimp-export-directory}
    no-error .
    if not available buf_usr-flt
    then do:
        run select-dir in this-procedure (
              input {&rcsimp-export-directory}
            , output v-dir
            , output v-cancel
        ) no-error .
        if error-status :error
        then do:
            undo, return error "init-fields: Ошибка выбора каталога." + {&new-line} + return-value.
        end.
        if v-cancel = no
        then do:
            assign
                fi-dir-exp :screen-value in frame {&frame-name} = v-dir
            .
        end.
    end.
    else do:
        assign
            fi-dir-exp :screen-value in frame {&frame-name} = buf_usr-flt.Naim
        .
    end.
        run adm/shattri.p (
            input "get":U
            ,input  '':U /*p-obj-type*/
            ,input  0 /*p-obj-code*/
            ,input  {&attr-gds-ref}
            ,input  {&attr-gds-ref_dif-nam1} /*p-param-code*/
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-goods-parameter-dif-nam1
            ,output v-param-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error.
        delete object v-tth.
        run adm/shattri.p (
            input "get":U
            ,input  '':U /*p-obj-type*/
            ,input  0 /*p-obj-code*/
            ,input  {&attr-gds-ref}
            ,input  {&attr-gds-ref_dif-nam2} /*p-param-code*/
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-goods-parameter-dif-nam2
            ,output v-param-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error.
        delete object v-tth.

end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE objects-tuning Dialog-Frame
PROCEDURE objects-tuning :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    run rcs/rcsimpd.w no-error .
    if error-status :error
    then do:
        undo, return error "objects-tuning: Ошибка настройки объектов rcs." + {&new-line} + return-value.
    end.
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read-file Dialog-Frame
PROCEDURE read-file :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-fi     as handle       no-undo.
define input parameter p-ed     as handle       no-undo.
define input parameter p-filename as character    no-undo.

    define variable v-xml-bufer     as character         no-undo.
    define variable v-counter       as integer           no-undo.

    input stream istream from value( p-filename ).
    repeat :
        import stream istream unformatted
            v-xml-bufer
        .
        assign
            v-counter = v-counter + 1
        .
        if v-selected-object-start = yes
            or index( v-xml-bufer, "DESTINATION_ROID" ) <> 0
        then do:
            run xmlvalid in this-procedure (
                input this-procedure :handle
                , input v-xml-bufer
                , input 'fatal':u
            ) no-error .
            if error-status :error
            then do:
                undo, return error "read-file: Ошибка импорта из файла '" + p-filename + "'" + {&new-line} + return-value.
            end.
        end.
        if v-counter mod 100 = 0
        then do:
            assign
                p-fi :screen-value  = "Файл: " + p-filename + ". Прочитано строк: " + string( v-counter )
            .
        end.
    end.
    input stream istream close.
end.
END PROCEDURE. /* read-file */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE select-dir Dialog-Frame
PROCEDURE select-dir :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-impexp-type    as character    no-undo.
define output parameter p-dir           as character    no-undo.
define output parameter p-cancel        as logical      no-undo.

    define variable v-dir-type  as character    no-undo.
    define variable v-can-write as logical      no-undo.

    define buffer buf_usr-flt       for ubflt.usr-flt.

    run gbl/dir-sel.p (
                    output p-dir
                  , output v-dir-type
                  , output v-can-write
    ) no-error .
    if error-status :error
    then do:
        assign
            p-cancel = yes
        .
        undo, return error "Ошибка выбора каталога импортируемых файлов." .
    end.
    else do:
        if v-can-write = no
        then do:
            assign
                p-cancel = yes
            .
            /* Отказ от выбора или выбран read-only каталог */
        end.
        else do:
            find first buf_usr-flt exclusive-lock
                 where buf_usr-flt.user-name    = {&all}
                   and buf_usr-flt.call-point   = p-impexp-type
            no-error .
            if not available buf_usr-flt
            then do:
                create buf_usr-flt.
                assign
                    buf_usr-flt.user-name    = {&all}
                    buf_usr-flt.call-point   = p-impexp-type
                .
            end.
            assign
                buf_usr-flt.Naim = p-dir
                p-cancel = no
            .
        end.
    end.
end.
END PROCEDURE. /* select-dir */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE write-to-log-editor {&FRAME-NAME}
PROCEDURE write-to-log-editor :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
  def input parameter hedt as handle no-undo.
  def input parameter iloglevel as integer  no-undo.
  def input parameter stowrite  as char     no-undo.
/*
  Процедура выводит запись в EDITOR, определенный параметром hEDT.
  Запись выглядит следующим образом:
     <Текущая дата><Пробелы, определяемые параметром iLogLevel><sToWrite>
  Специальные значения для iLogLevel:
       0 - не выводить дату (1 - без отступа)
  Специальные значения для sToWrite:
      "&Line"  - Вывести разделительную линию из символов "-"
      "&DLine" - Вывести разделительную линию из символов "="
    Длина разделительных линий задается в LogLineSize.
*/
    if valid-handle ( hedt )
    then do:
        hedt :move-to-eof().
        hedt :insert-string( if ( iloglevel = 0
                             or stowrite = "&dline"
                             or stowrite = "&line" )
                             then ""
                             else cur-time-string-sec() + " "
                           ).
        hedt :insert-string( if stowrite = "&line"
                             then fill("-", {&loglinesize} )
                             else if stowrite = "&dline"
                             then fill("=", {&loglinesize})
                             else fill(" ", iloglevel) + stowrite).
        hedt :insert-string({&new-line}).
    end.
    output to {&rcsimp-logfilename} append.
    put unformatted
        skip {&new-line} cur-time-string-sec() fill(" ", iloglevel) stowrite
    .
    output close.
end.
END PROCEDURE. /* write-to-log-editor */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-attr {&FRAME-NAME}
PROCEDURE import-attr :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-attr-id as character    no-undo.
define input parameter p-ed         as handle       no-undo.

    define variable v-today         as date      no-undo.
    define variable v-time          as integer   no-undo.
    define variable v-firm-code     as integer   no-undo.
    define variable v-root-code     as integer   no-undo.

    define buffer buf_temp_rcs-retail1attr  for temp_rcs-retail1attr.
    define buffer buf_rcs-retail1attr       for rcs-retail1attr.
    define buffer buf_rcs-pack              for rcs-pack.
    define buffer buf_rcs-mark              for rcs-mark.
    define buffer buf_rcs-place             for rcs-place.
    define buffer buf_rcs-country           for rcs-country.
    define buffer buf_rcs-clients           for rcs-clients.
    define buffer buf_rcs-city              for rcs-city.
    define buffer buf_country               for country.
    define buffer buf_units                 for units.
    define buffer buf_clients               for clients.
    define buffer buf_cli-grp               for cli-grp.
    define buffer buf_firm                  for firm.
    define buffer buf_gds-grp               for gds-grp.

    find first buf_temp_rcs-retail1attr
         where buf_temp_rcs-retail1attr.id = p-attr-id
    no-error.
    if not available buf_temp_rcs-retail1attr
    then do:
        undo, return error "import-attr: Ошибка поиска во временной таблице." + {&new-line} + return-value.
    end.
    find first buf_rcs-retail1attr no-lock
         where buf_rcs-retail1attr.id = p-attr-id
    no-error.
    if available buf_rcs-retail1attr
    then do:
        run write-to-log-editor in this-procedure (
              input p-ed
            , input 1
            , input "Справочник (attr) с идентификатором '" + p-attr-id + "' уже был импортирован."
        ).
    end.        /* if available buf_rcs-retail1attr */
    else do:
        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        case buf_temp_rcs-retail1attr.retail_attr_type
        :
            when 1      /* Импорт упаковок */
            then do:
                find first buf_rcs-pack no-lock
                     where buf_rcs-pack.id = buf_temp_rcs-retail1attr.id
                no-error.
                if available buf_rcs-pack
                then do:
                    run write-to-log-editor in this-procedure ( ed-log :handle in frame {&frame-name}, 1, "Упаковка с идентификатором '" + p-attr-id + "' уже была импортирована." ).
                end.
                else do:
                    do transaction
                    :
                        create buf_rcs-pack.
                        assign
                            buf_rcs-pack.id     = buf_temp_rcs-retail1attr.id
                            buf_rcs-pack.name   = buf_temp_rcs-retail1attr.name
                        .
                        create buf_rcs-retail1attr.
                        assign
                            buf_rcs-retail1attr.id                  = buf_temp_rcs-retail1attr.id
                            buf_rcs-retail1attr.retail_attr_type    = 1
                            buf_rcs-retail1attr.name                = buf_temp_rcs-retail1attr.name
                            buf_rcs-retail1attr.file-name           = fi-dir-imp :screen-value in frame {&frame-name}
                            buf_rcs-retail1attr.imp-date            = v-today
                            buf_rcs-retail1attr.imp-time            = v-time
                            buf_rcs-retail1attr.imp-user            = v-cntxt-userid
                            v-import-record-count                   = v-import-record-count + 1
                        .
                    end.
                end.
            end.
            when 2      /* Импорт маркировок */
            then do:
                find first buf_rcs-mark no-lock
                     where buf_rcs-mark.id = buf_temp_rcs-retail1attr.id
                no-error.
                if available buf_rcs-mark
                then do:
                    run write-to-log-editor in this-procedure ( ed-log :handle in frame {&frame-name}, 1, "Маркировка с идентификатором '" + p-attr-id + "' уже была импортирована." ).
                end.
                else do:
                    do transaction
                    :
                        create buf_rcs-mark.
                        assign
                            buf_rcs-mark.id     = buf_temp_rcs-retail1attr.id
                            buf_rcs-mark.name   = buf_temp_rcs-retail1attr.name
                        .
                        create buf_rcs-retail1attr.
                        assign
                            buf_rcs-retail1attr.id                  = buf_temp_rcs-retail1attr.id
                            buf_rcs-retail1attr.retail_attr_type    = 2
                            buf_rcs-retail1attr.name                = buf_temp_rcs-retail1attr.name
                            buf_rcs-retail1attr.file-name           = fi-dir-imp :screen-value in frame {&frame-name}
                            buf_rcs-retail1attr.imp-date            = v-today
                            buf_rcs-retail1attr.imp-time            = v-time
                            buf_rcs-retail1attr.imp-user            = v-cntxt-userid
                            v-import-record-count                   = v-import-record-count + 1
                        .
                    end.
                end.
            end.
            when 3      /* Импорт мест хранения (корневых групп товаров) */
            then do:
                find first buf_rcs-place no-lock
                     where buf_rcs-place.id = buf_temp_rcs-retail1attr.id
                no-error.
                if available buf_rcs-place
                then do:
                    run write-to-log-editor in this-procedure ( ed-log :handle in frame {&frame-name}, 1, "Упаковка с идентификатором '" + p-attr-id + "' уже была импортирована." ).
                end.
                else do:
                    do transaction
                    :
                        run grplib-get-root-code ( output v-root-code ) no-error .
                        if error-status :error
                        then do:
                            undo, return error "import-attr: Ошибка при вычислении кода корневой группы." + {&new-line} + return-value.
                        end.
                        find first buf_gds-grp no-lock
                             where buf_gds-grp.upper-code = v-root-code
                               and buf_gds-grp.node-name  = buf_temp_rcs-retail1attr.name
                        no-error.
                        if available buf_gds-grp
                        then do:
                            run write-to-log-editor in this-procedure ( ed-log :handle in frame {&frame-name}, 1, "Группа '" + buf_temp_rcs-retail1attr.name + "' уже была импортирована." ).
                        end.
                        else do:
                            create buf_gds-grp.
                            assign
                                buf_gds-grp.node-code   = next-value (s-gds-grp, {&db-name_schema})
                                buf_gds-grp.upper-code  = v-root-code
                                buf_gds-grp.node-name   = buf_temp_rcs-retail1attr.name
                                buf_gds-grp.calc-method = {&pr-calc-cost}
                            .
                            create buf_rcs-place.
                            assign
                                buf_rcs-place.id        = buf_temp_rcs-retail1attr.id
                                buf_rcs-place.name      = buf_temp_rcs-retail1attr.name
                                buf_rcs-place.node-code = buf_gds-grp.node-code
                            .
                            create buf_rcs-retail1attr.
                            assign
                                buf_rcs-retail1attr.id                  = buf_temp_rcs-retail1attr.id
                                buf_rcs-retail1attr.retail_attr_type    = 3
                                buf_rcs-retail1attr.name                = buf_temp_rcs-retail1attr.name
                                buf_rcs-retail1attr.file-name           = fi-dir-imp :screen-value in frame {&frame-name}
                                buf_rcs-retail1attr.imp-date            = v-today
                                buf_rcs-retail1attr.imp-time            = v-time
                                buf_rcs-retail1attr.imp-user            = v-cntxt-userid
                                v-import-record-count                   = v-import-record-count + 1
                            .
                        end.
                    end.
                end.
            end.
            when 4      /* Импорт стран */
            then do:
                find first buf_rcs-country no-lock
                     where buf_rcs-country.id = buf_temp_rcs-retail1attr.id
                no-error.
                if available buf_rcs-country
                then do:
                    run write-to-log-editor in this-procedure ( ed-log :handle in frame {&frame-name}, 1, "Страна с идентификатором '" + buf_temp_rcs-retail1attr.id + "' уже была импортирована." ).
                end.
                else do:
                    do transaction
                    :
                        find first buf_country no-lock
                             where buf_country.short-name = buf_temp_rcs-retail1attr.name
                        no-error.
                        create buf_rcs-country.
                        assign
                            buf_rcs-country.id     = buf_temp_rcs-retail1attr.id
                            buf_rcs-country.name   = buf_temp_rcs-retail1attr.name
                            buf_rcs-country.num-code = ( if available buf_country then buf_country.num-code else 0 )
                        .
                        create buf_rcs-retail1attr.
                        assign
                            buf_rcs-retail1attr.id                  = buf_temp_rcs-retail1attr.id
                            buf_rcs-retail1attr.retail_attr_type    = 4
                            buf_rcs-retail1attr.name                = buf_temp_rcs-retail1attr.name
                            buf_rcs-retail1attr.file-name           = fi-dir-imp :screen-value in frame {&frame-name}
                            buf_rcs-retail1attr.imp-date            = v-today
                            buf_rcs-retail1attr.imp-time            = v-time
                            buf_rcs-retail1attr.imp-user            = v-cntxt-userid
                            v-import-record-count                   = v-import-record-count + 1
                        .
                    end.
                end.
            end.
            when 5      /* Импорт производителей */
            then do:
                find first buf_rcs-clients no-lock
                     where buf_rcs-clients.id = buf_temp_rcs-retail1attr.id
                no-error.
                if available buf_rcs-clients
                then do:
                    run write-to-log-editor in this-procedure ( ed-log :handle in frame {&frame-name}, 1, "Производитель с идентификатором '" + p-attr-id + "' уже был импортирован." ).
                end.
                else do:
                    do transaction
                    :
                        find first buf_cli-grp no-lock
                             where buf_cli-grp.node-code = 3
                        no-error.
                        if not available buf_cli-grp
                        then do:
                            undo, return error "import-attr: Ошибка поиска группы для поставщика." + {&new-line} + return-value.
                        end.
                        run create-firm in this-procedure (
                              input ""                                              /* city          */
                            , input 0                                               /* ind           */
                            , input ""                                              /* addres1       */
                            , input ""                                              /* addres2       */
                            , input ""                                              /* director      */
                            , input ""                                              /* gen-acct      */
                            , input ""                                              /* phone         */
                            , input ""                                              /* fax           */
                            , input ""                                              /* engl-name     */
                            , input ""                                              /* contact-psn   */
                            , input 0                                               /* tobj-code     */
                            , input ""                                              /* inn           */
                            , input ""                                              /* okpo          */
                            , input ""                                              /* okonh         */
                            , input ""                                              /* phone1-note   */
                            , input ""                                              /* e-mail        */
                            , input ""                                              /* post-addr1    */
                            , input ""                                              /* post-addr2    */
                            , input ""                                              /* telex         */
                            , input ""                                              /* main-obj-type */
                            , input 0                                               /* main-obj-code */
                            , output v-firm-code                                    /* firm-code     */
                        ) no-error .
                        if error-status :error
                        then do:
                            undo, return error "import-subject: Ошибка создания записи фирмы поставщика." + {&new-line} + return-value.
                        end.
                        run create-clients in this-procedure (
                              input {&cmp}                              /* p-obj-type */
                            , input v-firm-code                         /* p-obj-code */
                            , input buf_temp_rcs-retail1attr.name       /* p-obj-name */
                            , input buf_cli-grp.node-code               /* p-grp-code */
                            , input -1                                  /* p-db-num   */
                            , input 0                                   /* p-stts     */
                            , input ""                                  /* p-PS       */
                            , input buf_cli-grp.node-name               /* p-grp-name */
                            , input 0                                   /* p-num_podr */
                            , input yes                                 /* p-is-prod  */
                            , input no                                  /* p-sup-gds  */
                            , input no                                  /* p-sup-serv */
                            , input no                                  /* p-buy-gds  */
                            , input no                                  /* p-buy-serv */
                            , input no                                  /* p-buy-cons */
                            , input no                                  /* p-sup-cons */
                            , input 0                                   /* p-lim-kr   */
                        ) no-error .
                        if error-status :error
                        then do:
                            undo, return error "import-subject: Ошибка создания записи поставщика." + {&new-line} + return-value.
                        end.
                        create buf_rcs-clients.
                        assign
                            buf_rcs-clients.id          = buf_temp_rcs-retail1attr.id
                            buf_rcs-clients.name        = buf_temp_rcs-retail1attr.name
                            buf_rcs-clients.obj-type    = {&cmp}
                            buf_rcs-clients.obj-code    = v-firm-code
                        .
                        create buf_rcs-retail1attr.
                        assign
                            buf_rcs-retail1attr.id                  = buf_temp_rcs-retail1attr.id
                            buf_rcs-retail1attr.retail_attr_type    = 5
                            buf_rcs-retail1attr.name                = buf_temp_rcs-retail1attr.name
                            buf_rcs-retail1attr.file-name           = fi-dir-imp :screen-value in frame {&frame-name}
                            buf_rcs-retail1attr.imp-date            = v-today
                            buf_rcs-retail1attr.imp-time            = v-time
                            buf_rcs-retail1attr.imp-user            = v-cntxt-userid
                            v-import-record-count                   = v-import-record-count + 1
                        .
                    end.
                end.
            end.
            when 6      /* Импорт городов */
            then do:
                find first buf_rcs-city no-lock
                     where buf_rcs-city.id = buf_temp_rcs-retail1attr.id
                no-error.
                if available buf_rcs-city
                then do:
                    run write-to-log-editor in this-procedure ( ed-log :handle in frame {&frame-name}, 1, "Город с идентификатором '" + p-attr-id + "' уже был импортирован." ).
                end.
                else do:
                    do transaction
                    :
                        create buf_rcs-city.
                        assign
                            buf_rcs-city.id     = buf_temp_rcs-retail1attr.id
                            buf_rcs-city.name   = buf_temp_rcs-retail1attr.name
                        .
                        create buf_rcs-retail1attr.
                        assign
                            buf_rcs-retail1attr.id                  = buf_temp_rcs-retail1attr.id
                            buf_rcs-retail1attr.retail_attr_type    = 6
                            buf_rcs-retail1attr.name                = buf_temp_rcs-retail1attr.name
                            buf_rcs-retail1attr.file-name           = fi-dir-imp :screen-value in frame {&frame-name}
                            buf_rcs-retail1attr.imp-date            = v-today
                            buf_rcs-retail1attr.imp-time            = v-time
                            buf_rcs-retail1attr.imp-user            = v-cntxt-userid
                            v-import-record-count                   = v-import-record-count + 1
                        .
                    end.
                end.
            end.
        end case.
    end.        /* if NOT available buf_rcs-retail1attr */
end.
END PROCEDURE. /* import-attr */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-product {&FRAME-NAME}
PROCEDURE import-product :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-product-id as character    no-undo.
define input parameter p-ed         as handle       no-undo.

    define variable v-today         as date              no-undo.
    define variable v-time          as integer           no-undo.
    define variable v-host-code     as integer           no-undo.
    define variable v-prod-type     as character         no-undo.
    define variable v-prod-code     as integer           no-undo.
    define variable v-recid         as recid             no-undo.
    define variable v-country       as character         no-undo.
    define variable v-gds-code      as integer           no-undo.
    define variable v-grp-code      as integer           no-undo.
    define variable v-full-name     as character         no-undo.

    define buffer buf_temp_rcs-retail1product   for temp_rcs-retail1product.
    define buffer buf_temp_rcs-retail1attr      for temp_rcs-retail1attr.
    define buffer buf_rcs-retail1product        for rcs-retail1product.
    define buffer buf_goods                     for goods.
    define buffer buf_rcs-clients               for rcs-clients.
    define buffer buf_gds-prt                   for gds-prt.
    define buffer buf_gds-grp                   for gds-grp.
    define buffer buf_units                     for units.
    define buffer buf_rcs-place                 for rcs-place.
    define buffer buf_rcs-country               for rcs-country.
    define buffer buf_country                   for country.

    find first buf_temp_rcs-retail1product
         where buf_temp_rcs-retail1product.id = p-product-id
    no-error.
    if not available buf_temp_rcs-retail1product
    then do:
        undo, return error "import-product: Ошибка поиска во временной таблице." + {&new-line} + return-value.
    end.
    find first buf_rcs-retail1product no-lock
         where buf_rcs-retail1product.id = p-product-id
    no-error.
    if available buf_rcs-retail1product
    then do:
        run write-to-log-editor in this-procedure (
              input p-ed
            , input 1
            , input substitute( "Товар с идентификатором '&1' уже был импортирован. Код товара &2."
                                , p-product-id
                                , buf_rcs-retail1product.gds-code
                              )
        ).
    end.        /* if available buf_rcs-retail1attr */
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    find first buf_rcs-clients no-lock
         where buf_rcs-clients.id = buf_temp_rcs-retail1product.retail_producer_id
    no-error.
    if not available buf_rcs-clients
    then do:
        undo, return error "import-product: Не найден производитель товара с ID "
                            + buf_temp_rcs-retail1product.retail_producer_id
                            + {&new-line} + "    ID товара: " + p-product-id
                            + {&new-line} + return-value
        .
    end.
    else do:
        assign
            v-prod-type = buf_rcs-clients.obj-type
            v-prod-code = buf_rcs-clients.obj-code
        .
    end.
    find first buf_gds-prt no-lock
         where buf_gds-prt.node-name = {&empty-scale}
    no-error.
    if not available buf_gds-prt
    then do:
        undo, return error "import-product: Не найден код пустой шкалы для товара." + {&new-line} + return-value.
    end.
    find first buf_rcs-place no-lock
            where buf_rcs-place.id = buf_temp_rcs-retail1product.retail_place_id
    no-error .
    if not available buf_rcs-place
    then do:        /* Группа не была импортирована. Ставим группу по умолчанию. */
        assign
            v-grp-code = v-default-gds-grp-node-code
        .
    end.
    else do:
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = buf_rcs-place.node-code
        no-error.
        if not available buf_gds-grp
        then do:
            /* Нет такой группы. Ставим группу по умолчанию.*/
            assign
                v-grp-code = v-default-gds-grp-node-code
            .
        end.
        else do:
            assign
                v-grp-code = buf_gds-grp.node-code
            .
        end.
    end.
    find first buf_rcs-country no-lock
         where buf_rcs-country.id = buf_temp_rcs-retail1product.retail_country_id
    no-error .
    if not available buf_rcs-country
    or buf_rcs-country.num-code = 0
    then do:
        assign
            v-country = "XX"
        .
    end.
    else do:
        find first buf_country no-lock
                where buf_country.num-code = buf_rcs-country.num-code
        no-error.
        if not available buf_country
        then do:
            assign
                v-country = "XX"
            .
        end.
        else do:
            assign
                v-country = buf_country.alpha1
            .
        end.
    end.
    case buf_temp_rcs-retail1product.weight_flag :
        when 0
        then do:
            find first buf_units no-lock
                    where buf_units.unit-name = v-unit-pieces
            no-error .
        end.
        when 1
        then do:
            find first buf_units no-lock
                    where buf_units.unit-name = v-unit-divisional
            no-error .
        end.
        when 2
        then do:
            find first buf_units no-lock
                    where buf_units.unit-name = v-unit-weight
            no-error .
        end.
    end case.
    if not available buf_units
    then do:
        undo, return error "import-product: Не найдена единица измерения товара."
                            + {&new-line} + "    ID товара: " + p-product-id
                            + {&new-line} + return-value
        .
    end.
    if buf_temp_rcs-retail1product.full_name = ""
    then do:
        assign
            v-full-name = "без названия"
        .
    end.
    else do:
        assign
            v-full-name = buf_temp_rcs-retail1product.full_name
        .
    end.
    do transaction
    :
        find first buf_rcs-retail1product exclusive-lock
             where buf_rcs-retail1product.id = p-product-id
        no-error.
        if available buf_rcs-retail1product
        then do:
            run write-to-log-editor in this-procedure ( ed-log :handle in frame {&frame-name}, 1, "Товар с идентификатором '" + p-product-id + "' уже был импортирован." ).
            find first buf_goods no-lock
                 where buf_goods.gds-code = buf_rcs-retail1product.gds-code
            no-error.
            if not available buf_goods
            then do:
                run write-to-log-editor in this-procedure ( ed-log :handle in frame {&frame-name}, 1, "В базе данных не найден импортированный ранее товар с идентификатором '" + p-product-id + "'." ).
                undo, return error vss-description + "В базе данных не найден импортированный ранее товар с идентификатором '" + p-product-id + "'.".
            end.
            assign
                v-recid = recid( buf_goods )
            .
            run rcs/rcsgds.p (
                  input parparentproc
                , input {&update}                   /*{&add-def} или {&update}*/
                , input no                          /*копирование с другого товара - тогда par-copy-rec - должен быть задан*/
                , input 0                           /*нужно ли вводить ДОП БК вместе с товаром*/
                , input no                          /*мз карточки товара - yes*/
                , input yes                         /*ругаемся вслух или ?*/
                , input no                          /*идет импоррт из файла - из карточки товара*/
                , input yes                         /*надо сохранить только одну запись - потом выход в справ*/
                , input v-cntxt-host-code-obj
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input yes                         /*товар - yes услуга no*/
                , input 0                           /*recid записи с которой копируем*/
                , input ""
                , input buf_goods.prod-type
                , input buf_goods.prod-code
                , input buf_gds-prt.node-code
                , input v-grp-code
                , input v-full-name
                , input ""                          /* par-saved-name */
                , input v-full-name
                , input v-full-name
                , input replace( replace( v-full-name, chr( 39 ), "" ), chr( 34 ), "" )
                , input v-country
                , input buf_goods.unit-base
                , input buf_goods.unit-base
                , input 0.0
                , input 0.0
                , input 1
                , input 1                           /* par-qnty-cart */
                , input 0                           /* par-ms-base */
                , input 0                           /* par-wt-base */
                , input 0                           /* par-ms-cart */
                , input 0                           /* par-wt-cart */
                , input {&pr-calc-grp}
                , input 0
                , input yes                         /* par-NegRest */
                , input 0                           /* par-obj-price-base */
                , input 0                           /* par-obj-price-rubl */
                , input ""                          /* par-okdp */
                , input ""                          /* par-destin          */
                , input ""                          /* par-attrib          */
                , input ""                          /* par-user-rule       */
                , input ""                          /* par-sert            */
                , input ""                          /* par-struct          */
                , input 0                           /* par-deadline        */
                , input 0                           /* par-cond-keep-code  */
                , input ""                          /* par-sort            */
                , input 0.0                         /* par-proof           */
                , input 0                           /* par-normal-wastage  */
                , input 0                           /* par-normal-waste    */
                , input ""                          /* par-tnved           */
                , input ""                          /* par-nationality     */
                , input ""                          /* par-unit-cst        */
                , input 0                           /* par-cst-base-rate   */
                , input 0                           /* par-fbr-grp-code    */
                , input ""                          /* par-PS              */
                , input no                          /* par-unq-artc настройка*/
                , input no                          /* par-is-jwlr в системе разрешены ювелирные изделия */
                , input no                          /* par-is-bttl в системе разрешена стеклотара        */
                , input no                          /* par-is-ptrl в системе разрешено топливо           */
                , input "no"                        /*в системе разрешена таможня */
                , input v-goods-parameter-dif-nam1  /*настройка*/
                , input v-goods-parameter-dif-nam2  /*настройка*/
                , input yes                         /*автоматический артикул*/
                , input no                          /*главный код товара берется из артикула*/
                , input-output v-recid
                , output v-gds-code                 /*gds-code*/
            ) no-error .
            if error-status :error
            then do:
                message
                  vss-workfile vss-revision vss-description
                  skip "Ошибка изменения товара."
                  skip return-value
                  skip trim(error-status :get-message(1))
                       trim(error-status :get-message(2))
                       trim(error-status :get-message(3))
                       trim(error-status :get-message(4))
                       trim(error-status :get-message(5))
                view-as alert-box error.
                undo, return error "Ошибка создания товара в базе данных."
                                    + {&new-line} + "ID товара: " + p-product-id
                                    + {&new-line} + trim(error-status :get-message(1))
                .
            end.
            assign
                buf_rcs-retail1product.id                   = buf_temp_rcs-retail1product.id
                buf_rcs-retail1product.file-name            = fi-dir-imp :screen-value in frame {&frame-name}
                buf_rcs-retail1product.full_name            = buf_temp_rcs-retail1product.full_name
                buf_rcs-retail1product.gds-code             = v-gds-code
                buf_rcs-retail1product.imp-date             = v-today
                buf_rcs-retail1product.imp-time             = v-time
                buf_rcs-retail1product.imp-user             = v-cntxt-userid
                buf_rcs-retail1product.retail_city_id       = buf_temp_rcs-retail1product.retail_city_id
                buf_rcs-retail1product.retail_country_id    = buf_temp_rcs-retail1product.retail_country_id
                buf_rcs-retail1product.retail_label_id      = buf_temp_rcs-retail1product.retail_label_id
                buf_rcs-retail1product.retail_mark_id       = buf_temp_rcs-retail1product.retail_mark_id
                buf_rcs-retail1product.retail_pack_id       = buf_temp_rcs-retail1product.retail_pack_id
                buf_rcs-retail1product.retail_place_id      = buf_temp_rcs-retail1product.retail_place_id
                buf_rcs-retail1product.retail_producer_id   = buf_temp_rcs-retail1product.retail_producer_id
                buf_rcs-retail1product.short_name           = buf_temp_rcs-retail1product.short_name
                buf_rcs-retail1product.weight_flag          = buf_temp_rcs-retail1product.weight_flag
                buf_rcs-retail1product.active               = buf_temp_rcs-retail1product.active
            .
            assign
                v-import-record-count                       = v-import-record-count + 1
            .
            assign
                fi-log :screen-value in frame {&frame-name} = "Изменен товар: "
                                                + buf_temp_rcs-retail1product.id
                                                + "   " + string( v-gds-code )
                                                + "   " + buf_temp_rcs-retail1product.full_name
            .
        end.
        else do:
            run rcs/rcsgds.p (
                  input parparentproc
                , input {&add-def}                  /*{&add-def} или {&update}*/
                , input no                          /*копирование с другого товара - тогда par-copy-rec - должен быть задан*/
                , input 0                           /*нужно ли вводить ДОП БК вместе с товаром*/
                , input no                          /*мз карточки товара - yes*/
                , input yes                         /*ругаемся вслух или ?*/
                , input no                          /*идет импоррт из файла - из карточки товара*/
                , input yes                         /*надо сохранить только одну запись - потом выход в справ*/
                , input v-cntxt-host-code-obj
                , input v-cntxt-obj-type
                , input v-cntxt-obj-code
                , input yes                         /*товар - yes услуга no*/
                , input 0                           /*recid записи с которой копируем*/
                , input ""
                , input v-prod-type
                , input v-prod-code
                , input buf_gds-prt.node-code
                , input v-grp-code
                , input v-full-name
                , input ""                          /* par-saved-name */
                , input v-full-name
                , input v-full-name
                , input replace( replace( v-full-name, chr( 39 ), "" ), chr( 34 ), "" )
                , input v-country
                , input buf_units.unit-name
                , input buf_units.unit-name
                , input 0.0
                , input 0.0
                , input 1
                , input 1                           /* par-qnty-cart */
                , input 0                           /* par-ms-base */
                , input 0                           /* par-wt-base */
                , input 0                           /* par-ms-cart */
                , input 0                           /* par-wt-cart */
                , input {&pr-calc-grp}
                , input 0
                , input yes                         /* par-NegRest */
                , input 0                           /* par-obj-price-base */
                , input 0                           /* par-obj-price-rubl */
                , input ""                          /* par-okdp */
                , input ""                          /* par-destin          */
                , input ""                          /* par-attrib          */
                , input ""                          /* par-user-rule       */
                , input ""                          /* par-sert            */
                , input ""                          /* par-struct          */
                , input 0                           /* par-deadline        */
                , input 0                           /* par-cond-keep-code  */
                , input ""                          /* par-sort            */
                , input 0.0                         /* par-proof           */
                , input 0                           /* par-normal-wastage  */
                , input 0                           /* par-normal-waste    */
                , input ""                          /* par-tnved           */
                , input ""                          /* par-nationality     */
                , input ""                          /* par-unit-cst        */
                , input 0                           /* par-cst-base-rate   */
                , input 0                           /* par-fbr-grp-code    */
                , input ""                          /* par-PS              */
                , input no                          /* par-unq-artc настройка*/
                , input no                          /* par-is-jwlr в системе разрешены ювелирные изделия */
                , input no                          /* par-is-bttl в системе разрешена стеклотара        */
                , input no                          /* par-is-ptrl в системе разрешено топливо           */
                , input "no"                        /*в системе разрешена таможня */
                , input v-goods-parameter-dif-nam1  /*настройка*/
                , input v-goods-parameter-dif-nam2  /*настройка*/
                , input yes                         /*автоматический артикул*/
                , input no                          /*главный код товара берется из артикула*/
                , input-output v-recid
                , output v-gds-code                 /*gds-code*/
            ) no-error .
            if error-status :error
            then do:
                message
                  vss-workfile vss-revision vss-description
                  skip "Ошибка создания карточки товара."
                  skip return-value
                  skip trim(error-status :get-message(1))
                       trim(error-status :get-message(2))
                       trim(error-status :get-message(3))
                       trim(error-status :get-message(4))
                       trim(error-status :get-message(5))
                view-as alert-box error.
                undo, return error "Ошибка создания товара в базе данных."
                                    + {&new-line} + "ID товара: " + p-product-id
                                    + {&new-line} + trim(error-status :get-message(1))
                                    + {&new-line} + return-value
                .
            end.
            else do:
                create buf_rcs-retail1product.
                assign
                    buf_rcs-retail1product.id                   = buf_temp_rcs-retail1product.id
                    buf_rcs-retail1product.file-name            = fi-dir-imp :screen-value in frame {&frame-name}
                    buf_rcs-retail1product.full_name            = buf_temp_rcs-retail1product.full_name
                    buf_rcs-retail1product.gds-code             = v-gds-code
                    buf_rcs-retail1product.imp-date             = v-today
                    buf_rcs-retail1product.imp-time             = v-time
                    buf_rcs-retail1product.imp-user             = v-cntxt-userid
                    buf_rcs-retail1product.retail_city_id       = buf_temp_rcs-retail1product.retail_city_id
                    buf_rcs-retail1product.retail_country_id    = buf_temp_rcs-retail1product.retail_country_id
                    buf_rcs-retail1product.retail_label_id      = buf_temp_rcs-retail1product.retail_label_id
                    buf_rcs-retail1product.retail_mark_id       = buf_temp_rcs-retail1product.retail_mark_id
                    buf_rcs-retail1product.retail_pack_id       = buf_temp_rcs-retail1product.retail_pack_id
                    buf_rcs-retail1product.retail_place_id      = buf_temp_rcs-retail1product.retail_place_id
                    buf_rcs-retail1product.retail_producer_id   = buf_temp_rcs-retail1product.retail_producer_id
                    buf_rcs-retail1product.short_name           = buf_temp_rcs-retail1product.short_name
                    buf_rcs-retail1product.weight_flag          = buf_temp_rcs-retail1product.weight_flag
                    buf_rcs-retail1product.active               = buf_temp_rcs-retail1product.active
                .
                assign
                    v-import-record-count                       = v-import-record-count + 1
                .
                assign
                    fi-log :screen-value in frame {&frame-name} = "Импортирован товар: "
                                                    + buf_temp_rcs-retail1product.id
                                                    + "   " + string( v-gds-code )
                                                    + "   " + buf_temp_rcs-retail1product.full_name
                .
            end.
        end.
    end.
end.
END PROCEDURE. /* import-product */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-firm {&FRAME-NAME}
PROCEDURE create-firm :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-city            as character    no-undo.
define input parameter p-ind             as integer      no-undo.
define input parameter p-addres1         as character    no-undo.
define input parameter p-addres2         as character    no-undo.
define input parameter p-director        as character    no-undo.
define input parameter p-gen-acct        as character    no-undo.
define input parameter p-phone           as character    no-undo.
define input parameter p-fax             as character    no-undo.
define input parameter p-engl-name       as character    no-undo.
define input parameter p-contact-psn     as character    no-undo.
define input parameter p-tobj-code       as integer      no-undo.
define input parameter p-inn             as character    no-undo.
define input parameter p-okpo            as character    no-undo.
define input parameter p-okonh           as character    no-undo.
define input parameter p-phone1-note     as character    no-undo.
define input parameter p-e-mail          as character    no-undo.
define input parameter p-post-addr1      as character    no-undo.
define input parameter p-post-addr2      as character    no-undo.
define input parameter p-telex           as character    no-undo.
define input parameter p-main-obj-type   as character    no-undo.
define input parameter p-main-obj-code   as integer      no-undo.
define output parameter p-firm-code      as integer      no-undo.

    define buffer buf_firm      for firm.

    run gen-b-code in this-procedure ( input {&gbl-fm-code}, output p-firm-code) no-error .
    if error-status :error
    then do:
        undo, return error "create-firm: Ошибка генерации уникального кода для фирмы поставщика." + {&new-line} + return-value.
    end.
    create buf_firm.
    assign
        buf_firm.firm-code      = p-firm-code
        buf_firm.city           = p-city
        buf_firm.ind            = p-ind
        buf_firm.addres1        = p-addres1
        buf_firm.addres2        = p-addres2
        buf_firm.director       = p-director
        buf_firm.gen-acct       = p-gen-acct
        buf_firm.phone          = p-phone
        buf_firm.fax            = p-fax
        buf_firm.engl-name      = p-engl-name
        buf_firm.contact-psn    = p-contact-psn
        buf_firm.tobj-code      = p-tobj-code
        buf_firm.inn            = p-inn
        buf_firm.okpo           = p-okpo
        buf_firm.okonh          = p-okonh
        buf_firm.phone1-note    = p-phone1-note
        buf_firm.e-mail         = p-e-mail
        buf_firm.post-addr1     = p-post-addr1
        buf_firm.post-addr2     = p-post-addr2
        buf_firm.telex          = p-telex
    .
end.
END PROCEDURE. /* create-firm */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE create-clients {&FRAME-NAME}
PROCEDURE create-clients :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define input parameter p-obj-name  as character    no-undo.
define input parameter p-grp-code  as integer      no-undo.
define input parameter p-db-num    as integer      no-undo.
define input parameter p-stts      as integer      no-undo.
define input parameter p-PS        as character    no-undo.
define input parameter p-grp-name  as character    no-undo.
define input parameter p-num_podr  as integer      no-undo.
define input parameter p-is-prod   as logical      no-undo.
define input parameter p-sup-gds   as logical      no-undo.
define input parameter p-sup-serv  as logical      no-undo.
define input parameter p-buy-gds   as logical      no-undo.
define input parameter p-buy-serv  as logical      no-undo.
define input parameter p-buy-cons  as logical      no-undo.
define input parameter p-sup-cons  as logical      no-undo.
define input parameter p-lim-kr    as decimal      no-undo.

define buffer buf_clients       for clients.

    create buf_clients.
    assign
        buf_clients.obj-type    = p-obj-type
        buf_clients.obj-code    = p-obj-code
        buf_clients.obj-name    = p-obj-name
        buf_clients.grp-code    = p-grp-code
        buf_clients.stts        = p-stts
        buf_clients.PS          = p-PS
        buf_clients.grp-name    = p-grp-name
        buf_clients.num_podr    = p-num_podr
        buf_clients.is-prod     = p-is-prod
        buf_clients.sup-gds     = p-sup-gds
        buf_clients.sup-serv    = p-sup-serv
        buf_clients.buy-gds     = p-buy-gds
        buf_clients.buy-serv    = p-buy-serv
        buf_clients.buy-cons    = p-buy-cons
        buf_clients.sup-cons    = p-sup-cons
        buf_clients.lim-kr      = p-lim-kr
    .
    if p-db-num <> -1
    then do:
        assign
            buf_clients.db-num      = p-db-num
        .
    end.
end.
END PROCEDURE. /* create-clients */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-bill {&FRAME-NAME}
PROCEDURE import-bill :
/*------------------------------------------------------------------------------
  Purpose:      Импорт приходной накладной
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-bill-id    as character    no-undo.
define input parameter p-ed         as handle       no-undo.

    define variable v-today         as date           no-undo.
    define variable v-time          as integer        no-undo.
    define variable v-obj-type      as character      no-undo.
    define variable v-obj-code      as integer        no-undo.
    define variable v-host-code     as integer        no-undo.
    define variable v-host-name     as character      no-undo.
    define variable v-base-code     as integer        no-undo.
    define variable v-down-pay      as integer        no-undo.
    define variable v-doc-code      as character      no-undo.
    define variable v-line-num      as integer        no-undo.
    define variable v-was-moving    as logical        no-undo.

    define variable v-cli-type      as character      no-undo.
    define variable v-cli-code      as integer        no-undo.
    define variable v-cli-name      as character      no-undo.
    define variable v-base-rate     as decimal        no-undo.
    define variable v-base-scale    as integer        no-undo.
    define variable vss-description as character  init "import-bill: "       no-undo.

    define buffer buf_temp_rcs-retail1bill      for temp_rcs-retail1bill.
    define buffer buf_temp_rcs-retail1billitem  for temp_rcs-retail1billitem.
    define buffer buf_rcs-retail1bill           for rcs-retail1bill.
    define buffer buf_rcs-retail1billitem       for rcs-retail1billitem.
    define buffer buf_rcs-retail1product        for rcs-retail1product.
    define buffer buf_rcs-retail1subject        for rcs-retail1subject.
    define buffer buf_pay-type                  for pay-type.
    define buffer buf_trn-doc                   for trn-doc.
    define buffer buf_curr-accnt                for curr-accnt.
    define buffer buf_goods                     for goods.
    define buffer buf_cli-gds                   for cli-gds.

    find first buf_temp_rcs-retail1bill
         where buf_temp_rcs-retail1bill.id = p-bill-id
    no-error.
    if not available buf_temp_rcs-retail1bill
    then do:
        undo, return error vss-description + "Ошибка поиска во временной таблице.".
    end.
    find first buf_rcs-retail1bill no-lock
         where buf_rcs-retail1bill.id = buf_temp_rcs-retail1bill.id
    no-error.
    if available buf_rcs-retail1bill
    then do:
        run write-to-log-editor(
              input p-ed
            , input 1
            , input substitute( "Накладная &1 от &2 уже была импортирована.", buf_rcs-retail1bill.docnomer, buf_rcs-retail1bill.docdate  )
        ).
        undo, return.
    end.
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    run get-shops-type-and-code in this-procedure (
          input buf_temp_rcs-retail1bill.site_id
        , output v-obj-type
        , output v-obj-code
    ) no-error.
    if error-status :error
    then do:
        undo, return error vss-description + "Не определен объект для приходной накладной или не найден объект в настройках.".
    end.
    find first buf_pay-type no-lock
         where buf_pay-type.obj-code = v-cntxp-in-pay
    no-error .
    if not available buf_pay-type
    then do:
        undo, return error vss-description + "В настройках текущего объекта указан вид оплаты прихода: " + string( v-cntxp-in-pay ) + ", которого нет в справочнике!".
    end.
    find first buf_rcs-retail1subject no-lock
         where buf_rcs-retail1subject.id = buf_temp_rcs-retail1bill.subject_id
    no-error .
    if not available buf_rcs-retail1subject
    then do:
        undo, return error vss-description + "Не найден поставщик товара для приходной  накладной.".
    end.
    else do:
        assign
            v-cli-type = buf_rcs-retail1subject.obj-type
            v-cli-code = buf_rcs-retail1subject.obj-code
            v-cli-name = buf_rcs-retail1subject.cname
        .
    end.
    { gbl/basecode.i
        v-cntxt-host-code-obj
        v-base-code
    }
    find last buf_curr-accnt no-lock
        where buf_curr-accnt.curr-code = v-base-code
          and buf_curr-accnt.exch-date <= v-today
    use-index pi
    no-error.
    assign
        v-base-rate  = buf_curr-accnt.exch-rate
        v-base-scale = buf_curr-accnt.exch-scale
    .
    if not available buf_curr-accnt then do:
        message
            "На дату" today "неизвестен курс базовой валюты."
        .
        { gbl/stopwork.i }
        undo, return error.
    end.
    do transaction
    :
        { gbl/curobjdt.i
            v-obj-type
            v-obj-code
            v-today
        }
        { gbl/hostname.i
            v-obj-type
            v-obj-code
            v-host-code
            v-host-name
        }
        { gbl/basecode.i
            v-host-code
            v-base-code
        }
        { gbl/objdnpay.i
            v-obj-type
            v-obj-code
            v-down-pay
        }
        run doc-code in this-procedure (
              input "main"
            , input v-obj-type
            , input v-obj-code
            , input ""
            , output v-doc-code
        ) .
        /*acc-date   */
        /*bge-date   */
        /*base-rate  */
        /*base-scale */
        /*cli-code   */
        /*cli-type   */
        /*cli-name   */
        /*cr-db-num  */
        /*creid      */
        /*discnt-type*/
        /*doc-code   */
        /*doc-date   */
        /*doc-type   */
        /*flag_      */
        /*host-code  */
        /*internal   */
        /*obj-code   */
        /*obj-type   */
        /*office     */
        /*pay-code   */
        /*ps         */
        /*ret-supp   */
        /*slt-type   */
        /*status_    */
        /*vat-type   */
        /*ext-doc-type*/
        /*purch-code*/
        { str/crtrndoc.i
            ?
            ?
            "buf_curr-accnt.exch-rate"
            "buf_curr-accnt.exch-scale"
            v-host-code
            {&cmp}
            v-host-name
            v-cntxt-db-num-obj
            v-cntxt-userid
            "' '"
            v-doc-code
            buf_temp_rcs-retail1bill.docdate
            {&income}
            no
            v-host-code
            no
            v-obj-code
            v-obj-type
            no
            v-cntxp-in-pay
            "'@ Импортировано из RCS'"
            no
            "{&without-SLT}"
            "{&wayb}"
            "{&inc-VAT}"
            {&TDEDT_Pri_Vnesh}
            {&bef-repayment-code}
            no-error
        }
        if error-status:error
        then do:
            message
                "Ошибка при создании складского документа."
            view-as alert-box error.
            { gbl/stopwork.i }
            undo, return error.
        end.
        find first buf_trn-doc exclusive-lock
             where buf_trn-doc.doc-code = v-doc-code
        .
        assign
            buf_trn-doc.exch-date    = buf_temp_rcs-retail1bill.docdate
            buf_trn-doc.exch-code    = 0
            buf_trn-doc.exch-rate    = 1
            buf_trn-doc.exch-scale   = 1
            buf_trn-doc.base-rate    = v-base-rate
            buf_trn-doc.base-scale   = v-base-scale
            buf_trn-doc.print-rubl   = yes
            buf_trn-doc.wrkr         = v-default-wrkr
            buf_trn-doc.agnt         = v-default-agnt
            buf_trn-doc.boss         = v-default-boss
            buf_trn-doc.ret-supp     = no
            buf_trn-doc.cli-type     = v-cli-type
            buf_trn-doc.cli-code     = v-cli-code
            buf_trn-doc.cli-name     = v-cli-name
            buf_trn-doc.ord-num      = buf_temp_rcs-retail1bill.docnomer
            v-line-num               = 1
        .
        { str/tdat-wrt.i
            v-doc-code
            {&trdcattr-nids}
            buf_temp_rcs-retail1bill.docnomer
        }
        for each temp_rcs-retail1billitem
           where temp_rcs-retail1billitem.bill_id = p-bill-id
        :
            find first buf_rcs-retail1product no-lock
                 where buf_rcs-retail1product.id = temp_rcs-retail1billitem.product_id
            no-error .
            if not available buf_rcs-retail1product
            then do:
                undo, return error vss-description + "Не найден товар для строки приходной накладной"
                                + {&new-line} + "ID товара:    " + temp_rcs-retail1billitem.product_id
                                + {&new-line} + "ID накладной: " + temp_rcs-retail1billitem.bill_id
                .
            end.
            else do:
                run rcs/rcscredl.p (
                      input parparentproc
                    , input buf_trn-doc.doc-code
                    , input buf_rcs-retail1product.gds-code
                    , input temp_rcs-retail1billitem.count1
                    , input temp_rcs-retail1billitem.cost1
                    , input v-base-rate
                    , input v-base-scale
                    , input v-line-num
                ) no-error .
                if error-status :error
                then do:
                    undo, return error vss-description + "Ошибка при создании строки документа.".
                end.
                else do:
                    assign
                        v-line-num = v-line-num + 1
                    .
                    create buf_rcs-retail1billitem .
                    assign
                        buf_rcs-retail1billitem.bill_id     = temp_rcs-retail1billitem.bill_id
                        buf_rcs-retail1billitem.cost1       = temp_rcs-retail1billitem.cost1
                        buf_rcs-retail1billitem.count1      = temp_rcs-retail1billitem.count1
                        buf_rcs-retail1billitem.product_id  = temp_rcs-retail1billitem.product_id
                        buf_rcs-retail1billitem.file-name   = fi-dir-imp :screen-value in frame {&frame-name}
                        buf_rcs-retail1billitem.imp-date    = v-today
                        buf_rcs-retail1billitem.imp-time    = v-time
                        buf_rcs-retail1billitem.imp-user    = v-cntxt-userid
                    .
                end.
            end.
        end.
        create buf_rcs-retail1bill.
        assign
            buf_rcs-retail1bill.id          = buf_temp_rcs-retail1bill.id
            buf_rcs-retail1bill.site_id     = buf_temp_rcs-retail1bill.site_id
            buf_rcs-retail1bill.docnomer    = buf_temp_rcs-retail1bill.docnomer
            buf_rcs-retail1bill.docdate     = buf_temp_rcs-retail1bill.docdate
            buf_rcs-retail1bill.doc_type_id = buf_temp_rcs-retail1bill.doc_type_id
            buf_rcs-retail1bill.subject_id  = buf_temp_rcs-retail1bill.subject_id
            buf_rcs-retail1bill.doc-code    = buf_trn-doc.doc-code
            buf_rcs-retail1bill.obj-type    = v-obj-type
            buf_rcs-retail1bill.obj-code    = v-obj-code
            buf_rcs-retail1bill.file-name   = fi-dir-imp :screen-value in frame {&frame-name}
            buf_rcs-retail1bill.imp-date    = v-today
            buf_rcs-retail1bill.imp-time    = v-time
            buf_rcs-retail1bill.imp-user    = v-cntxt-userid
        .
        run gbl/calc-trn.p (
              input parparentproc
            , input recid( buf_trn-doc )
        ).
        assign
            buf_trn-doc.tot-cli = buf_trn-doc.tot-calc
        .
    end.        /* do transaction */
    assign
        v-import-record-count                       = v-import-record-count + 1
    .
    assign
        fi-log :screen-value in frame {&frame-name} = "Закачан документ: ID = " + temp_rcs-retail1bill.id
                                        + "  DOCNOMER = " + temp_rcs-retail1bill.docnomer
                                        + "  DOCDATE = " + string( temp_rcs-retail1bill.docdate )
                                        + "  SUBJECT = " + temp_rcs-retail1bill.subject_id
    .
    do transaction
    on error undo, return error substitute( "&1. &2. &3", return-value, trim(error-status :get-message(1)), trim(error-status :get-message(2)) )
    :
        run str/trn-stat.p (
              input parparentproc
            , input this-procedure
            , input {&close-doc}
            , input buf_trn-doc.doc-code
            , input no
            , input v-cntxt-db-num-obj
            , input v-cntxp-in-ov
            , input v-cntxp-rsrv-time
            , input v-cntxp-load-time
            , input v-cntxp-holidays
            , input yes
            , output v-was-moving
            , output table gds-list
        ) .
    end.        /* do transaction */
end.
END PROCEDURE. /* import-bill */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-price {&FRAME-NAME}
PROCEDURE import-price :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-price-id as character    no-undo.
define input parameter p-ed         as handle       no-undo.

    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-obj-type          as character    no-undo.
    define variable v-obj-code          as integer      no-undo.
    define variable v-price-doc-recid   as recid        no-undo.
    define variable v-update            as logical      no-undo.

    define buffer buf_temp_rcs-retail1price     for temp_rcs-retail1price.
    define buffer buf_temp_rcs-retail1priceitem for temp_rcs-retail1priceitem.
    define buffer buf_rcs-retail1priceitem      for rcs-retail1priceitem.
    define buffer buf_rcs-retail1price          for rcs-retail1price.
    define buffer buf_price-doc                 for price-doc.

    find first buf_temp_rcs-retail1price
         where buf_temp_rcs-retail1price.price_id = p-price-id
    no-error.
    if not available buf_temp_rcs-retail1price
    then do:
        undo, return error "import-price: Ошибка поиска во временной таблице." .
    end.
    find first buf_rcs-retail1price no-lock
         where buf_rcs-retail1price.price_id = buf_temp_rcs-retail1price.price_id
    no-error.
    if available buf_rcs-retail1price
    then do:
        run write-to-log-editor(
              input p-ed
            , input 1
            , input substitute( "Переоценка &1 от &2 уже была импортирована.", buf_rcs-retail1price.doc-num, buf_rcs-retail1price.ddat  )
        ).
        undo, return.
    end.
    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    run get-shops-type-and-code (
          input buf_temp_rcs-retail1price.site_id
        , output v-obj-type
        , output v-obj-code
    ) no-error.
    if error-status :error
    then do:
        undo, return error "import-price: Ошибка вычисления кода объекта для документа переоценки." + {&new-line} + return-value.
    end.
    do transaction :
        run prcreate-new-price-doc in this-procedure (
              input v-cntxt-db-num
            , input v-obj-type
            , input v-obj-code
            , input ?
            , input ?
            , input ?
            , input ?
            , output v-price-doc-recid
        ) no-error.
        if error-status:error
        then do:
            undo, return error "import-price: Не удалось создать документ переоценки." + {&new-line} + return-value.
        end.
        find first buf_price-doc exclusive-lock
             where recid( buf_price-doc ) = v-price-doc-recid
        .
        assign
            buf_price-doc.PS = "@ Импорт RCS"
        .
        for each buf_temp_rcs-retail1priceitem
           where buf_temp_rcs-retail1priceitem.price_id = buf_temp_rcs-retail1price.price_id
        :
            find first rcs-retail1product no-lock
                 where rcs-retail1product.id = buf_temp_rcs-retail1priceitem.id
            no-error .
            if not available rcs-retail1product
            then do:
                undo, return error "create-bill: Не удалось найти товар для строки прайс-листа."
                                + {&new-line} + "ID товара: " + buf_temp_rcs-retail1priceitem.id
                .
            end.
            else do:
                run prcreate-new-price-list in this-procedure (
                      input v-price-doc-recid
                    , input rcs-retail1product.gds-code
                    , input buf_temp_rcs-retail1priceitem.price_cost
                    , output v-update
                ) no-error.
                if error-status:error
                then do:
                    undo, return error substitute( "import-price: Не удалось создать строку документа переоценки для товара с кодом: &1", rcs-retail1product.gds-code ) + {&new-line} + return-value.
                end.
                create buf_rcs-retail1priceitem.
                assign
                    buf_rcs-retail1priceitem.id         = buf_temp_rcs-retail1priceitem.id
                    buf_rcs-retail1priceitem.price_id   = buf_temp_rcs-retail1priceitem.price_id
                    buf_rcs-retail1priceitem.price_cost = buf_temp_rcs-retail1priceitem.price_cost
                    buf_rcs-retail1priceitem.active     = buf_temp_rcs-retail1priceitem.active
                    buf_rcs-retail1priceitem.file-name  = fi-dir-imp :screen-value in frame {&frame-name}
                    buf_rcs-retail1priceitem.imp-date   = v-today
                    buf_rcs-retail1priceitem.imp-time   = v-time
                    buf_rcs-retail1priceitem.imp-user   = v-cntxt-userid
                .
            end.
        end.
        create buf_rcs-retail1price.
        assign
            buf_rcs-retail1price.price_id   = buf_temp_rcs-retail1price.price_id
            buf_rcs-retail1price.site_id    = buf_temp_rcs-retail1price.site_id
            buf_rcs-retail1price.ddat       = buf_temp_rcs-retail1price.ddat
            buf_rcs-retail1price.corr       = buf_temp_rcs-retail1price.corr
            buf_rcs-retail1price.stad       = buf_temp_rcs-retail1price.stad
            buf_rcs-retail1price.doc-mode   = buf_temp_rcs-retail1price.doc-mode
            buf_rcs-retail1price.doc_type   = buf_temp_rcs-retail1price.doc_type
            buf_rcs-retail1price.doc-num    = buf_price-doc.doc-num
            buf_rcs-retail1price.obj-type   = buf_price-doc.obj-type
            buf_rcs-retail1price.obj-code   = buf_price-doc.obj-code
            buf_rcs-retail1price.file-name  = fi-dir-imp :screen-value in frame {&frame-name}
            buf_rcs-retail1price.imp-date   = v-today
            buf_rcs-retail1price.imp-time   = v-time
            buf_rcs-retail1price.imp-user   = v-cntxt-userid
        .
    end.
    assign
        v-import-record-count                       = v-import-record-count + 1
    .
    assign
        fi-log :screen-value in frame {&frame-name} = "Закачана переоценка: ID = " + buf_rcs-retail1price.price_id
                                        + "  DDAT = " + string( buf_rcs-retail1price.ddat )
                                        + "  DOCNUM = " + string( buf_rcs-retail1price.doc-num )
    .
end.
END PROCEDURE. /* import-price */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-default-value {&FRAME-NAME}
PROCEDURE get-default-value :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-value-type as character    no-undo.
define output parameter p-value     as character    no-undo.

define buffer buf_usr-flt   for ubflt.usr-flt.

    find first buf_usr-flt no-lock
         where buf_usr-flt.user-name    = {&all}
           and buf_usr-flt.call-point   = p-value-type
    no-error .
    if not available buf_usr-flt
    then do:
        undo, return error "get-default-value: Ошибка получения значения по умолчанию.".
    end.
    else do:
        assign
            p-value = buf_usr-flt.Naim
        .
    end.

end.
END PROCEDURE. /* get-default-value */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-barcode {&FRAME-NAME}
PROCEDURE import-barcode :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-barcode-id as character    no-undo.
define input parameter p-ed         as handle       no-undo.

    define variable v-unit-name     as character        no-undo.
    define variable v-today         as date             no-undo.
    define variable v-time          as integer          no-undo.
    define variable v-go-next       as logical  init no no-undo.
    define variable l-is-weight as logical no-undo .
    define variable l-is-pgweight as logical no-undo .
    define variable l-is-petrolium as logical no-undo .


    define buffer buf_temp_rcs-retail1barcode   for temp_rcs-retail1barcode.
    define buffer buf_rcs-retail1product        for rcs-retail1product.
    define buffer buf_rcs-retail1barcode        for rcs-retail1barcode.
    define buffer buf_prod-bc                   for prod-bc.
    define buffer buf_goods                     for goods.
    define buffer buf_gds-prt                   for gds-prt.

    find first buf_temp_rcs-retail1barcode
         where buf_temp_rcs-retail1barcode.id = p-barcode-id
    no-error.
    if not available buf_temp_rcs-retail1barcode
    then do:
        undo, return error "import-barcode: Ошибка поиска во временной таблице." .
    end.
    find first buf_rcs-retail1product no-lock
         where buf_rcs-retail1product.id = buf_temp_rcs-retail1barcode.retail_product_id
    no-error.
    if not available buf_rcs-retail1product
    then do:
        undo, return error "import-barcode: Не был закачан товар для привязки бар-кода." .
    end.
    else do:
        find first buf_prod-bc no-lock
             where buf_prod-bc.b-str = buf_temp_rcs-retail1barcode.barcode
        no-error.
        if available buf_prod-bc
        then do:        /* См. письмо 14.11.02, aeremin@planeta-m.ru  - если бар-код есть в базе, его пропускаем. */
/*            undo, return error "import-barcode: Бар-код с ID '" + p-barcode-id + "' ( barcode = '" + buf_temp_rcs-retail1barcode.barcode + "' ) уже есть в базе данных." .*/
            run write-to-log-editor( p-ed, 5, "import-barcode: Бар-код с ID '" + p-barcode-id + "' ( barcode = '" + buf_temp_rcs-retail1barcode.barcode + "' ) уже есть в базе данных." ).
            assign
                v-go-next = yes
            .
        end.
        else do:
            find first buf_goods no-lock
                 where buf_goods.gds-code = buf_rcs-retail1product.gds-code
            no-error.
            if not available buf_goods
            then do:
                undo, return error "import-barcode: Нет закачанного товара для привязки бар-кода." .
            end.
            else do:
                find first buf_gds-prt no-lock
                     where buf_gds-prt.upper-code = buf_goods.prt-root
                no-error .
                if not available buf_gds-prt
                then do:
                    undo, return error "import-barcode: В карточке товара неверно задан код шкалы."
                                    + {&new-line} + "Артикул товара: " + string( buf_goods.artic )
                                    + {&new-line} + "Производитель : " + string( buf_goods.prod-type )
                                    + {&new-line} + "                " + string( buf_goods.prod-code )
                    .
                end.
                else do:
                    case buf_rcs-retail1product.weight_flag
                    :
                        when 0
                        then do:
                            assign
                                v-unit-name = v-unit-pieces
                            .
                        end.
                        when 1
                        then do:
                            assign
                                v-unit-name = v-unit-divisional
                            .
                        end.
                        when 2
                        then do:
                            assign
                                v-unit-name = v-unit-weight
                            .
                        end.
                        otherwise do:
                            undo, return error "import-barcode: Товар с ID '" + buf_rcs-retail1product.id + "был импортирован с неверным значением единицы измерения".
                        end.
                    end case.
                    if v-unit-name <> buf_goods.unit-base
                    then do:
                        undo, return error "import-barcode: Единица измерения для бар-кода не соответствует импортируемой для товара с ID '" + buf_rcs-retail1product.id + "' ( кодом '" + string( buf_rcs-retail1product.gds-code ) + "' ) ".
                    end.
                end.        /* available buf_gds-prt  */
            end.        /* available buf_goods  */
        end.        /* not available buf_prod-bc  */
    end.        /* available buf_rcs-retail1product */
    if v-go-next = no
    then do:
       { gbl/prodbctv.i
          buf_temp_rcs-retail1barcode.barcode
          buf_goods.unit-base
          buf_goods.unit-base
          'weight=request':u
          l-is-weight
       }

       { gbl/prodbctv.i
          buf_temp_rcs-retail1barcode.barcode
          buf_goods.unit-base
          buf_goods.unit-base
          'pgweight=request':u
          l-is-pgweight
       }

       { gbl/prodbctv.i
          buf_temp_rcs-retail1barcode.barcode
          buf_goods.unit-base
          buf_goods.unit-base
          'petrolium=request':u
          l-is-petrolium
       }
        if (l-is-weight
        or l-is-pgweight
        or l-is-petrolium
        ) then do:
          undo, return error "import-barcode: Невоможно импортировать весовой или топливный бар-код для товара с ID '" + buf_rcs-retail1product.id + "' ( кодом '" + string( buf_rcs-retail1product.gds-code ) + "' ) ".
        end.


        run cur-time in this-procedure (
              output v-today
            , output v-time
        ).
        do transaction :
          define variable v-b-str as character no-undo .
          define variable rid as recid no-undo .
          v-b-str = buf_temp_rcs-retail1barcode.barcode.
          rid = ?.
          run trg/prod-bc1.p (
                              input  parparentproc
                              ,input yes /*p-silent*/
                              ,input dif-pdbc /* dif-pdbc */
                              ,input pbc-veto /*pbc-veto*/
                              ,input no /*send-ref*/
                              ,input '' /*cdrg-type*/
                              ,input ""
                              ,buffer buf_goods
                              ,input buf_rcs-retail1product.gds-code
                              ,input-output v-b-str
                              ,output rid
                              ) no-error.
           if error-status :error then do:
             undo, return error "import-barcode: Ошибка при  импорте бар-кода для товара с ID '" + buf_rcs-retail1product.id + "' ( кодом '" + string( buf_rcs-retail1product.gds-code ) + "' ) ".
           end.
           else if rid = ? then do:
             undo, return error "import-barcode: Невоможно импортировать бар-код для товара с ID '" + buf_rcs-retail1product.id + "' ( кодом '" + string( buf_rcs-retail1product.gds-code ) + "' ) ".
           end.
            create buf_rcs-retail1barcode.
            assign
                buf_rcs-retail1barcode.id                   = buf_temp_rcs-retail1barcode.id
                buf_rcs-retail1barcode.barcode              = buf_temp_rcs-retail1barcode.barcode
                buf_rcs-retail1barcode.retail_product_id    = buf_temp_rcs-retail1barcode.retail_product_id
                buf_rcs-retail1barcode.b-code               = buf_goods.gds-code
                buf_rcs-retail1barcode.b-str                = buf_temp_rcs-retail1barcode.barcode
                buf_rcs-retail1barcode.file-name            = fi-dir-imp :screen-value in frame {&frame-name}
                buf_rcs-retail1barcode.imp-date             = v-today
                buf_rcs-retail1barcode.imp-time             = v-time
                buf_rcs-retail1barcode.imp-user             = v-cntxt-userid
            .
        end.
        assign
            v-import-record-count                       = v-import-record-count + 1
        .
        assign
            fi-log :screen-value in frame {&frame-name} = "Закачан бар-код: ID = " + buf_rcs-retail1barcode.id
                                            + "  BARCODE = " + string( buf_temp_rcs-retail1barcode.barcode )
        .
    end.
end.
END PROCEDURE. /* import-barcode */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-shops-id {&FRAME-NAME}
PROCEDURE get-shops-id :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-shops-obj-type as character    no-undo.
define input parameter p-shops-obj-code as integer      no-undo.
define output parameter p-shops-id      as character    no-undo.

    define buffer buf_rcs-shops     for rcs-shops.

    find first buf_rcs-shops no-lock
         where buf_rcs-shops.obj-type = p-shops-obj-type
           and buf_rcs-shops.obj-code = p-shops-obj-code
    no-error.
    if not available buf_rcs-shops
    then do:
        undo, return error "get-shops-id: Не найден ID объекта."
                + {&new-line} + "Тип объекта: " + p-shops-obj-type
                + {&new-line} + "Код объекта: " + string( p-shops-obj-code )
        .
    end.
    else do:
        assign
            p-shops-id = buf_rcs-shops.id
        .
    end.
end.
END PROCEDURE. /* get-shops-id */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-and-create-subdir {&FRAME-NAME}
PROCEDURE check-and-create-subdir :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-parent-dir as character    no-undo.
define input parameter p-subdir     as character    no-undo.

    define variable v-dir-exists     as logical init no   no-undo.

    find first temp_dir no-error.
    if not available temp_dir
    then do:
        create temp_dir.
    end.
    input from os-dir( p-parent-dir ).
    search-dir:
    repeat
    :
        import temp_dir.
        if temp_dir.type = "D"
        then do:
            if caps( temp_file.name ) = "OLD"
            then do:
                assign
                    v-dir-exists = yes
                .
                leave search-dir.
            end.
            else do:
                assign
                    v-dir-exists = no
                .
            end.
        end.
    end.
    input close.
    if v-dir-exists = no
    then do:
        os-create-dir value( p-parent-dir + {&back-slash-char} + p-subdir ) .
        if os-error <> 0
        then do:
            undo, return error "Ошибка создания подкаталога OLD".
        end.
    end.
end.
END PROCEDURE. /* check-and-create-subdir */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE get-or-generate-filename {&FRAME-NAME}
PROCEDURE get-or-generate-filename :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-dir            as character    no-undo.
define input parameter p-filename       as character    no-undo.
define output parameter p-full-filename as character    no-undo.

    define variable v-counter       as integer          no-undo.

    assign
        v-counter = 0
        p-full-filename = p-dir + {&back-slash-char} + p-filename
    .
    if search ( p-full-filename ) <> ?
    then do:
        generate-filename:
        do while true
        :
            assign
                v-counter = v-counter + 1
                p-full-filename = p-dir + {&back-slash-char} + entry( 1, p-filename, "." )   + string( v-counter )
                                        + ( if num-entries( p-filename, "." ) > 1 then entry( 2, p-filename, "." ) else "." )
            .
            if search ( p-full-filename ) = ?
            then do:
                leave generate-filename.
            end.
        end.
    end.
end.
END PROCEDURE. /* get-or-generate-filename */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE delete-record {&FRAME-NAME}
PROCEDURE delete-record :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
define input parameter p-name   as character    no-undo.
define input parameter p-id     as character    no-undo.

define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

define variable vss-description as character init "delete-record: " no-undo.

define buffer buf_bar-code              for bar-code.
define buffer buf_prod-bc               for prod-bc.
define buffer buf_rcs-retail1barcode    for rcs-retail1barcode.
define buffer buf_rcs-retail1delete     for rcs-retail1delete.

case p-name
:
    when "RETAIL1_BARCODE"
    then do:
        find first buf_rcs-retail1barcode no-lock
             where buf_rcs-retail1barcode.id = p-id
        no-error.
        if not available buf_rcs-retail1barcode
        then do:
            undo, return error vss-description + "Попытка удалить не импортированный бар-код.".
        end.
        find first buf_bar-code no-lock
             where buf_bar-code.b-code = buf_rcs-retail1barcode.b-code
        no-error.
        if not available buf_bar-code
        then do:
            undo, return error vss-description + "Не найден основной бар-код товара.".
        end.
        run cur-time in this-procedure ( output v-today
                                       , output v-time
                                       ).
        do transaction :
            find first buf_prod-bc exclusive-lock
                 where buf_prod-bc.b-code           = buf_bar-code.b-code
                   and buf_prod-bc.b-str            = buf_rcs-retail1barcode.b-str
            no-error.
            if error-status :error
            then do:
                undo, return error vss-description + "Не найден дополнительный бар-код товара.".
            end.
            delete buf_prod-bc.
            create buf_rcs-retail1delete.
            assign
                buf_rcs-retail1delete.id            = p-id
                buf_rcs-retail1delete.name          = p-name
                buf_rcs-retail1delete.file-name     = fi-dir-imp :screen-value in frame {&frame-name}
                buf_rcs-retail1delete.imp-date      = v-today
                buf_rcs-retail1delete.imp-time      = v-time
                buf_rcs-retail1delete.imp-user      = v-cntxt-userid
            .
        end.
        assign
            v-import-record-count                       = v-import-record-count + 1
        .
        assign
            fi-log :screen-value in frame {&frame-name} = "Удален бар-код: ID = " + buf_rcs-retail1delete.id
                                            + "  BARCODE = " + string( buf_rcs-retail1barcode.b-str )
        .
    end.
    otherwise do:
        undo, return error vss-description + "Не определено удаление для заданной записи.".
    end.
end case.

end.
END PROCEDURE. /* delete-record */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/*==========================================================================*/
procedure genscode-generate-num-bank :
do
on error undo, return error
:
define output parameter p-bank-num as integer no-undo.
assign
    p-bank-num = next-value( s-bank, {&db-name_schema} )
.
end.
end procedure. /* genscode-generate-num-bank */