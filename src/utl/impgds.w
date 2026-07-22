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

Импорт карточек товаров

Автор: Белоусов Илья Александрович
Дата создания: 04/12/06
Author: Ilia Belousov
Creation date: 04/12/06

Input:

Output:

*/
/*          This .W file was created with the Progress UIB.             */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc    as handle           no-undo.

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Импорт карточек товаров".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ utl/impgds.i   }
{ gbl/is-num.i   }
{ ref/grplib.i   }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }

define variable v-store-type    as character    no-undo.
define variable v-store-code    as integer      no-undo.

define variable v-host-code     as integer      no-undo.
define variable v-db-num        as integer      no-undo.

define variable v-today         as date         no-undo.
define variable v-time          as integer      no-undo.

define variable dif-pdbc as logical no-undo initial no.
define variable pbc-veto  as logical no-undo.


define variable v-impgds-last-rate-code    as integer      no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit bt-read bt-import b-help ed-log ~
fi-log
&Scoped-Define DISPLAYED-OBJECTS ed-log fi-log

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

DEFINE BUTTON bt-import
     LABEL "&Импорт"
     SIZE 10 BY 1.

DEFINE BUTTON bt-read
     LABEL "&Чтение"
     SIZE 10 BY 1.

DEFINE VARIABLE ed-log AS CHARACTER
     VIEW-AS EDITOR LARGE
     SIZE 97.88 BY 19.79
     FGCOLOR 1  NO-UNDO.

DEFINE VARIABLE fi-log AS CHARACTER FORMAT "X(256)":U
      VIEW-AS TEXT
     SIZE 97.75 BY .79
     FGCOLOR 9  NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     bt-read AT ROW 1 COL 11
     bt-import AT ROW 1 COL 21
     b-help AT ROW 1 COL 89 WIDGET-ID 2
     ed-log AT ROW 3.21 COL 1.13 NO-LABEL
     fi-log AT ROW 2.29 COL 1.38 NO-LABEL
     SPACE(0.74) SKIP(20.54)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт товаров".


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: DIALOG-BOX
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

ASSIGN
       ed-log:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN fi-log IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Импорт товаров */
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


&Scoped-define SELF-NAME bt-import
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-import Dialog-Frame
ON CHOOSE OF bt-import IN FRAME Dialog-Frame /* Импорт */
DO:
    output stream impgds-log to {&impgds-log-filename} append .
    disable
        bt-import
    with frame {&frame-name} .
    run import-data in this-procedure (
          input fi-log :handle in frame {&frame-name}
        , input ed-log :handle
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка импорта."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    output stream impgds-log close.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME bt-read
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL bt-read Dialog-Frame
ON CHOOSE OF bt-read IN FRAME Dialog-Frame /* Чтение */
DO:
    define variable v-import-available    as logical      no-undo.

    output stream impgds-log to {&impgds-log-filename} .
    run read-data in this-procedure (
          input fi-log :handle in frame {&frame-name}
        , input ed-log :handle
        , output v-import-available
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка чтения данных."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return no-apply .
    end.
    output stream impgds-log close.
    if v-import-available = yes
    then do:
        enable
            bt-import
        with frame {&frame-name} .
    end.
    else do:
        message
            "Были ошибки при проверке считанных данных."
            skip(1)
            skip "Импорт невозможен."
        view-as alert-box error.
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
  run init-fields in this-procedure .
  RUN enable_UI.
  disable all with frame {&frame-name} .
  run init-enable in this-procedure .

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-gds Dialog-Frame
PROCEDURE check-gds :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-gds-code       as character        no-undo.
define input parameter p-gds-name       as character        no-undo.
define output parameter p-have-error    as logical          no-undo.
define output parameter p-error-text    as character        no-undo.

    define variable v-temp-integer    as integer      no-undo.
do
on error undo, return error
:
    if p-gds-name = ""
    then do:
        assign
            p-have-error = yes
            p-error-text = "Название товара пусто."
        .
    end.
    if index( p-gds-name, {&double-quote}) > 0
    and r-index( p-gds-name, {&double-quote} ) = index( p-gds-name, {&double-quote} )
    then do:
        assign
            p-have-error = yes
            p-error-text = "Название товара содержит непарную кавычку."
        .
    end.
    assign
        v-temp-integer = integer( p-gds-code )
    no-error.
    if error-status :error
    then do:
        assign
            p-have-error = yes
            p-error-text = "Код товара не может быть преобразован в число."
        .
    end.
    else do:
        if v-temp-integer <= 0
        then do:
            assign
                p-have-error = yes
                p-error-text = "Код товара меньше или равен 0."
            .
        end.
    end.
end.
END PROCEDURE. /* check-gds */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
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

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
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
  DISPLAY ed-log fi-log
      WITH FRAME Dialog-Frame.
  ENABLE b-exit bt-read bt-import b-help ed-log fi-log
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-barcodes-for-goods Dialog-Frame
PROCEDURE import-barcodes-for-goods :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-temp-goods-gds-code  as integer        no-undo.
define input parameter p-temp-goods-unit-cli  as character      no-undo.
define input parameter p-gds-prt-node-code    as integer        no-undo.

    define variable v-is-new    as logical      no-undo.
    define variable l-is-weight as logical no-undo .
    define variable l-is-pgweight as logical no-undo .
    define variable l-is-petrolium as logical no-undo .

    define buffer buf_bar-code          for ub.bar-code.
    define buffer buf_temp_bar-codes    for temp_bar-codes.
    define buffer buf_prod-bc           for ub.prod-bc.
    define buffer buf_goods             for ub.goods.
do
for buf_bar-code
  , buf_temp_bar-codes
  , buf_prod-bc
  , buf_goods
on error undo, return error
:
    /*  Создаем основной бар-код для товара */
    find first buf_bar-code no-lock
         where buf_bar-code.b-code   = p-temp-goods-gds-code
    no-error.
    if not available buf_bar-code
    then do:
        find first buf_goods no-lock
             where buf_goods.gds-code = p-temp-goods-gds-code
        .
        { gbl/barcodcr.i
            p-temp-goods-gds-code
            p-gds-prt-node-code
            "''"
            "''"
            buf_goods.unit-cli
            buf_goods.cli-base-rate
            v-is-new
            buf_bar-code
        }
    end.
    /*  Создаем дополнительные бар-коды для товара, если они были во входном файле*/
    _buf_temp-bar-codes:
    for each buf_temp_bar-codes
       where buf_temp_bar-codes.gds-code = p-temp-goods-gds-code
    :
       { gbl/prodbctv.i
          buf_temp_bar-codes.b-str
          buf_bar-code.unit-cli
          buf_goods.unit-base
          'weight=request':u
          l-is-weight
       }

       { gbl/prodbctv.i
          buf_temp_bar-codes.b-str
          buf_bar-code.unit-cli
          buf_goods.unit-base
          'pgweight=request':u
          l-is-pgweight
       }

       { gbl/prodbctv.i
          buf_temp_bar-codes.b-str
          buf_bar-code.unit-cli
          buf_goods.unit-base
          'petrolium=request':u
          l-is-petrolium
       }

        if (l-is-weight
        or l-is-pgweight
        or l-is-petrolium
        ) then do:
          next _buf_temp-bar-codes.
        end.
        find first buf_prod-bc no-lock
             where buf_prod-bc.b-code   = p-temp-goods-gds-code
               and buf_prod-bc.b-str    = buf_temp_bar-codes.b-str
        no-error.
        if not available buf_prod-bc
        then do:
          define variable v-b-str as character no-undo .
          define variable rid as recid no-undo .
          v-b-str = buf_temp_bar-codes.b-str.
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
                              ,input p-temp-goods-gds-code
                              ,input-output v-b-str
                              ,output rid
                              ) no-error.
         if error-status :error
         then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Fatal err: Ошибка при сохраненеии ДопБК: &1 для товара:&2&3"
                                    , buf_temp_bar-codes.b-str
                                    , error-status:get-message(1)
                                    , return-value
                                  )
            ).

         end.
         else if rid = ? then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "No-fatal err: Не удалось сохранить ДОпБК: &1 для товара: &2"
                                    , buf_temp_bar-codes.b-str
                                    , return-value
                                  )
            ).
         end.
        end.
        else do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "No-fatal err: Дополнительный бар-код: &1 для товара: &2 уже есть."
                                    , buf_temp_bar-codes.b-str
                                    , p-temp-goods-gds-code
                                  )
            ).
        end.
    end.

end.
END PROCEDURE. /* import-barcodes-for-goods */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-clients Dialog-Frame
PROCEDURE import-clients :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input parameter p-cnt-handle as handle           no-undo.

    define variable v-group-code    as integer      no-undo.
    define variable v-clients-recid as recid        no-undo.

    define buffer buf_cli-grp       for ub.cli-grp.
    define buffer buf_clients       for ub.clients.
    define buffer buf_temp_clients  for temp_clients.
    define buffer buf_firm          for ub.firm.
do
for buf_clients
  , buf_temp_clients
  , buf_firm
on error undo, return error
:
    find first buf_cli-grp no-lock
         where buf_cli-grp.node-name = {&all-klients-group}
    no-error.
    if error-status :error
    then do:
        message
            substitute( "Не найдена группа клиентов '&2'.&1Импорт контрагентов невозможен."
                        , {&new-line}
                        , {&all-klients-group}
                      )
        view-as alert-box error
        title "Импорт товаров из Trade в Trade House"
        .
        undo, return error.
    end.
    else do:
        assign
            v-group-code = buf_cli-grp.node-code
        .
    end.
    for each buf_temp_clients
    on error undo, return error
    :
        find first buf_clients no-lock
             where buf_clients.obj-type = {&cmp}
               and buf_clients.obj-code = buf_temp_clients.obj-code
        no-error.
        if not available buf_clients
        then do:
            run ref/firm1.p (
                  input parparentproc
                , input-output v-clients-recid
                , input {&add-def}
                , input "":U                            /* p-callpoint      */
                , input no                              /* p-silent         */
                , input ( - abs(buf_temp_clients.obj-code))       /* p-firm-code      */
                , input 0                               /* p-stts           */
                , input buf_temp_clients.obj-name       /* p-obj-name       */
                , input "":U                            /* p-lim-kr         */
                , input buf_temp_clients.ps             /* p-PS             */
                , input v-group-code                    /* p-grp-code       */
                , input substring( buf_temp_clients.address, 1, 50 )
                        + substring( buf_temp_clients.address, 101, 50 )
                        + substring( buf_temp_clients.address, 151 )        /* p-addres1        */
                , input substring( buf_temp_clients.address, 51, 50 )       /* p-addres2        */
                , input "":U                            /* p-city           */
                , input "":U                            /* p-contact-psn    */
                , input buf_temp_clients.director       /* p-director       */
                , input buf_temp_clients.email          /* p-e-mail         */
                , input "":U                            /* p-engl-name      */
                , input buf_temp_clients.fax            /* p-fax            */
                , input "":U                            /* p-given-by       */
                , input "":U                            /* p-ind            */
                , input buf_temp_clients.inn            /* p-inn            */
                , input no                              /* p-no-check-inn   */
                , input no                              /* p-is-pboul       */
                , input buf_temp_clients.kpp            /* p-kpp            */
                , input buf_temp_clients.okonh          /* p-okonh          */
                , input buf_temp_clients.okpo           /* p-okpo           */
                , input "":U                            /* p-passp-num      */
                , input "":U                            /* p-passp-ser      */
                , input buf_temp_clients.phone          /* p-phone          */
                , input "":U                            /* p-phone1-note    */
                , input "":U                            /* p-post-addr1     */
                , input "":U                            /* p-post-addr2     */
                , input "":U                            /* p-post-city      */
                , input 0                               /* p-post-ind       */
                , input 0                               /* p-reg-code       */
                , input "":U                            /* p-telex          */
                , input 0                               /* p-tobj-code      */
                , input no                              /* p-turnover-buyer    */
                , input no                              /* p-turnover-buyer-gds*/
            ).
        end.
        else do:
            undo, return error
                    substitute( "Err: Попытка повторного импорта объекта: &1 &2"
                                , buf_clients.obj-code
                                , buf_clients.obj-name )
            .
        end.
        if buf_temp_clients.obj-code < {&impgds-max-firm-code}
        and current-value( s-fmgb-code, {&db-name_schema} ) < buf_temp_clients.obj-code
        then do:
            assign
                current-value( s-fmgb-code, {&db-name_schema} ) = buf_temp_clients.obj-code
            .
        end.
        run impgds-write-cnt in this-procedure (
              input p-cnt-handle
            , input substitute( "Импортирован объект: &1 &2 &3"
                                , {&cmp}
                                , buf_temp_clients.obj-code
                                , buf_temp_clients.obj-name )
        ).

    end.        /* for each buf_temp_gds-grp */
end.
END PROCEDURE. /* import-clients */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-data Dialog-Frame
PROCEDURE import-data :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-cnt-handle     as handle           no-undo.
define input parameter p-log-handle     as handle           no-undo.
do
on error undo, return error
:
/* Объекты */
    run impgds-write-cnt in this-procedure (
          input p-cnt-handle
        , input " ":U
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input "Импорт контрагентов..."
    ).
    run import-clients  in this-procedure (
        input p-cnt-handle
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка импорта контрагентов."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input "Импорт контрагентов завершен."
    ).
    run impgds-write-cnt in this-procedure (
          input p-cnt-handle
        , input " ":U
    ).
/* Группы товаров */
    run impgds-write-cnt in this-procedure (
          input p-cnt-handle
        , input " ":U
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input "Импорт групп товаров..."
    ).
    run import-gds-grp  in this-procedure (
        input p-cnt-handle
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка импорта групп товаров."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input "Импорт групп товаров завершен."
    ).
    run impgds-write-cnt in this-procedure (
          input p-cnt-handle
        , input " ":U
    ).
/* Товары */
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input "Импорт карточек товаров..."
    ).
    run import-goods in this-procedure (
        input p-cnt-handle
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка импорта товаров."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input "Импорт карточек товаров завершен."
    ).
    run impgds-write-cnt in this-procedure (
          input p-cnt-handle
        , input " ":U
    ).

end.
END PROCEDURE. /* import-data */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-gds-grp Dialog-Frame
PROCEDURE import-gds-grp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define input parameter p-cnt-handle as handle           no-undo.

    define buffer buf_gds-grp           for ub.gds-grp.
    define buffer buf_temp_gds-grp      for temp_gds-grp.
do
for buf_gds-grp
  , buf_temp_gds-grp
on error undo, return error
:
    for each buf_temp_gds-grp
    by buf_temp_gds-grp.upper-code
    on error undo, return error
    :
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = buf_temp_gds-grp.node-code
        no-error.
        if not available buf_gds-grp
        then do:
            run utl/impgrptx.p (
                  input {&add-def}
                , input buf_temp_gds-grp.node-code
                , input buf_temp_gds-grp.upper-code
                , input buf_temp_gds-grp.node-name
                , input v-host-code
                , input v-store-type
                , input v-store-code
            ) no-error.
            if error-status :error
            then do:
                message
                         vss-workfile vss-revision vss-description
                    skip(1)
                    skip "Ошибка создания группы товаров."
                    skip(1)
                    skip "Код группы:" buf_temp_gds-grp.node-code
                    skip "Имя группы:" buf_temp_gds-grp.node-name
                    skip return-value
                    skip trim(error-status :get-message(1))
                         trim(error-status :get-message(2))
                         trim(error-status :get-message(3))
                view-as alert-box error.
                undo, return error .
            end.
            else do:
                if current-value( s-gds-grp, {&db-name_schema} ) < buf_temp_gds-grp.node-code
                then do:
                    assign
                        current-value( s-gds-grp, {&db-name_schema} ) = buf_temp_gds-grp.node-code
                    .
                end.
                run impgds-write-cnt in this-procedure (
                      input p-cnt-handle
                    , input substitute( "Импортирована группа: &1 &2"
                                        , buf_temp_gds-grp.node-code
                                        , buf_temp_gds-grp.node-name )
                ).
            end.
        end.
        else do:
            undo, return error
                    substitute( "Err: Попытка повторного импорта группы: &1 &2"
                                , buf_temp_gds-grp.node-code
                                , buf_temp_gds-grp.node-name )
            .
        end.
    end.        /* for each buf_temp_gds-grp */
end.
END PROCEDURE. /* import-gds-grp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE import-goods Dialog-Frame
PROCEDURE import-goods :
define input parameter p-cnt-handle     as handle           no-undo.

/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-goods-parameter-dif-nam1  as logical      init yes    no-undo.
    define variable v-goods-parameter-dif-nam2  as logical      init no     no-undo.
    define variable v-par-value                 as character                no-undo.
    define variable v-par-type                  as character                no-undo.
    define variable v-vat-rate-code             as integer                  no-undo.
    define variable v-slt-rate-code             as integer                  no-undo.
    define variable v-goods-recid               as recid                    no-undo.
    define variable v-gds-code                  as integer                  no-undo.
    define variable v-last-gds-code             as integer                  no-undo.
    define variable v-tax-rate-recid            as recid                    no-undo.
    define variable v-tax-rate-value-recid      as recid                    no-undo.
    define variable v-goods-unit-cli            as character                no-undo.
    define variable v-param-type                as character                no-undo.
    define variable v-value-character           as character                no-undo.
    define variable v-value-date                as date                     no-undo.
    define variable v-value-decimal             as decimal                  no-undo.
    define variable v-value-integer             as INTEGER                  no-undo.
    define variable v-value-logical             AS LOGICAL                  no-undo.
    define variable v-tth                       as handle                   no-undo.


    define buffer buf_goods         for ub.goods.
    define buffer buf_units         for ub.units.
    define buffer buf_temp_goods    for temp_goods.
    define buffer buf_gds-prt       for ub.gds-prt.
    define buffer buf_temp_tax      for temp_tax.
do
for buf_goods
  , buf_units
  , buf_temp_goods
  , buf_gds-prt
  , buf_temp_tax
on error undo, return error
:
    { gbl/working.i }
    for each buf_temp_goods
    by buf_temp_goods.gds-code descending
    :
        assign
            v-last-gds-code = buf_temp_goods.gds-code
        .
        leave.
    end.
    if v-last-gds-code >= current-value( s-bcgb-code, {&db-name_schema} )
    then do:
        assign
            current-value( s-bcgb-code, {&db-name_schema} ) = v-last-gds-code + 1
        .
    end.
    import-goods:
    for each buf_temp_goods
    on error undo, return error
    :
        find first buf_goods no-lock
             where buf_goods.gds-code = buf_temp_goods.gds-code
        no-error.
        if available buf_goods
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Невозможно создать товар с кодом, который есть у товара в БД: &1"
                        , buf_temp_goods.gds-code )
            ).
            next import-goods.
        end.
        find first buf_units no-lock
             where buf_units.unit-name = buf_temp_goods.unit-base
        .
        find first buf_gds-prt no-lock
             where buf_gds-prt.node-name = {&empty-scale}
        no-error.
        if not available buf_gds-prt
        then do:
            undo, return error "import-product: Не найден код пустой шкалы для товара." + {&new-line} + return-value.
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
        find first buf_temp_tax
             where buf_temp_tax.tax-code   = integer( {&vat-tax-code} )
               and buf_temp_tax.rate-value = buf_temp_goods.VAT-pc
        no-error.
        if not available buf_temp_tax
        then do:
            assign
                v-impgds-last-rate-code = v-impgds-last-rate-code + 1
            .
            create buf_temp_tax.
            assign
                buf_temp_tax.tax-code       = integer( {&vat-tax-code} )
                buf_temp_tax.rate-value     = buf_temp_goods.VAT-pc
                buf_temp_tax.rate-code      = v-impgds-last-rate-code
            .
            run ref/taxrati1.p (
                  input-output v-tax-rate-recid
                , input {&add-def}
                , input yes /* p-silent */
                , input integer( {&vat-tax-code} )
                , input v-impgds-last-rate-code
                , input substitute( "НДС &1", buf_temp_goods.VAT-pc  )
                , input {&current-status}
            ) no-error .
            if error-status :error
            then do:
                run impgds-write-log in this-procedure (
                      input 1
                    , input substitute( "Fatal err: Ошибка при сохраненеии ставки налога для товара.&1&2&1&3"
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                      )
            ).
            end.

            run ref/taxvali1.p (
                  input-output v-tax-rate-value-recid
                , input {&add-def}
                , input yes /* p-silent */
                , input integer( {&vat-tax-code} )
                , input v-impgds-last-rate-code
                , input buf_temp_tax.rate-value
                , input v-today
                , input 0       /* v-host-code */
                , input "":U    /* v-store-type */
                , input 0       /* v-store-code */
                , input {&current-status}
            ).
/*            message*/
/*                     vss-workfile vss-revision vss-description*/
/*                skip(1)*/
/*                skip "Ошибка привязки товара к ставке налога."*/
/*                skip "В файле импорта указана несуществующая ставка налога"*/
/*                skip "НДС - " buf_temp_goods.VAT-pc*/
/*                skip (1)*/
/*                skip "Код товара: " buf_temp_goods.gds-code*/
/*                skip return-value*/
/*                skip trim(error-status :get-message(1))*/
/*                     trim(error-status :get-message(2))*/
/*                     trim(error-status :get-message(3))*/
/*            view-as alert-box error.*/
/*            undo, return error .*/
        end.
        assign
            v-vat-rate-code = buf_temp_tax.rate-code
        .
        find first buf_temp_tax
             where buf_temp_tax.tax-code   = integer( {&slt-tax-code} )
               and buf_temp_tax.rate-value = buf_temp_goods.SLT-pc
        no-error.
        if not available buf_temp_tax
        then do:
            assign
                v-impgds-last-rate-code = v-impgds-last-rate-code + 1
            .
            create buf_temp_tax.
            assign
                buf_temp_tax.tax-code       = integer( {&slt-tax-code} )
                buf_temp_tax.rate-value     = buf_temp_goods.SLT-pc
                buf_temp_tax.rate-code      = v-impgds-last-rate-code
            .
            run ref/taxrati1.p (
                  input-output v-tax-rate-recid
                , input {&add-def}
                , input yes /* p-silent */
                , input integer( {&slt-tax-code} )
                , input v-impgds-last-rate-code
                , input substitute( "НП &1", buf_temp_goods.SLT-pc  )
                , input {&current-status}
            ) no-error .
            if error-status :error
            then do:
                run impgds-write-log in this-procedure (
                      input 1
                    , input substitute( "Fatal err: Ошибка при сохраненеии ставки налога для товара.&1&2&1&3"
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                      )
            ).
            end.
            run ref/taxvali1.p (
                  input-output v-tax-rate-value-recid
                , input {&add-def}
                , input yes /* p-silent */
                , input integer( {&slt-tax-code} )
                , input v-impgds-last-rate-code
                , input buf_temp_tax.rate-value
                , input v-today
                , input 0       /* v-host-code */
                , input "":U    /* v-store-type */
                , input 0       /* v-store-code */
                , input {&current-status}
            ).
/*            message*/
/*                     vss-workfile vss-revision vss-description*/
/*                skip(1)*/
/*                skip "Ошибка привязки товара к ставке налога."*/
/*                skip "В файле импорта указана несуществующая ставка налога"*/
/*                skip "НП - " buf_temp_goods.SLT-pc*/
/*                skip (1)*/
/*                skip "Код товара: " buf_temp_goods.gds-code*/
/*                skip return-value*/
/*                skip trim(error-status :get-message(1))*/
/*                     trim(error-status :get-message(2))*/
/*                     trim(error-status :get-message(3))*/
/*            view-as alert-box error.*/
/*            undo, return error .*/
        end.
        assign
            v-slt-rate-code = buf_temp_tax.rate-code
        .
        run utl/impgdstx.p (
              input {&add-def}                  /*{&add-def} или {&update}*/
            , input v-vat-rate-code
            , input v-slt-rate-code
            , input no                          /*копирование с другого товара - тогда par-copy-rec - должен быть задан*/
            , input 0                           /*нужно ли вводить ДОП БК вместе с товаром*/
            , input no                          /*мз карточки товара - yes*/
            , input yes                         /*ругаемся вслух или ?*/
            , input no                          /*идет импоррт из файла - из карточки товара*/
            , input yes                         /*надо сохранить только одну запись - потом выход в справ*/
            , input v-host-code
            , input v-store-type
            , input v-store-code
            , input yes                         /*товар - yes услуга no*/
            , input 0                           /*recid записи с которой копируем*/
            , input buf_temp_goods.gds-code
            , input buf_temp_goods.artic
            , input {&cmp}                      /* buf_temp_goods.prod-type */
            , input buf_temp_goods.prod-code
            , input buf_gds-prt.node-code
            , input buf_temp_goods.grp-code
            , input buf_temp_goods.gds-name
            , input ""                          /* par-saved-name */
            , input buf_temp_goods.engl-name
            , input buf_temp_goods.gds-name
            , input replace( replace( buf_temp_goods.gds-name, chr( 39 ), "" ), chr( 34 ), "" )
            , input "XX":U                      /* country */
            , input buf_units.unit-name
            , input buf_units.unit-name
            , input 0.0
            , input 0.0
            , input 1
            , input 1                           /* par-qnty-cart */
            , input 0                           /* par-ms-cart */
            , input 0                           /* par-wt-cart */
            , input {&pr-calc-grp}
            , input 0
            , input no                          /* par-NegRest */
            , input 0                           /* par-obj-price-base */
            , input 0                           /* par-obj-price-rubl */
            , input ""                          /* par-okdp */
            , input ""                          /* par-destin          */
            , input ""                          /* par-attrib          */
            , input ""                          /* par-user-rule       */
            , input ""                          /* par-sert            */
            , input ""                          /* par-struct          */
            , input 0                           /* par-deadline        */
            , input ""                          /* par-sort            */
            , input 0.0                         /* par-proof           */
            , input 0                           /* par-normal-wastage  */
            , input 0                           /* par-normal-waste    */
            , input ""                          /* par-tnved           */
            , input ""                          /* par-nationality     */
            , input ""                          /* par-unit-cst        */
            , input 0                           /* par-cst-base-rate   */
            , input ""                          /* par-PS              */
            , input no                          /* par-unq-artc настройка*/
            , input no                          /* par-is-jwlr в системе разрешены ювелирные изделия */
            , input no                          /* par-is-bttl в системе разрешена стеклотара        */
            , input no                          /* par-is-ptrl в системе разрешено топливо           */
            , input "no"                        /*в системе разрешена таможня */
            , input v-goods-parameter-dif-nam1  /*настройка*/
            , input v-goods-parameter-dif-nam2  /*настройка*/
            , input no                         /*автоматический артикул*/
            , input 2                          /*главный код товара берется из кода товара */
            , input-output v-goods-recid
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
            undo, return error "Err: Ошибка создания товара в базе данных."
                                + {&new-line} + "Код товара: " + string( buf_temp_goods.gds-code )
                                + {&new-line} + trim(error-status :get-message(1))
                                + {&new-line} + return-value
            .
        end.
        assign
            v-goods-unit-cli = ( if buf_temp_goods.unit-base = {&oil-unit-base}
                                 then {&oil-unit-cli}
                                 else buf_temp_goods.unit-base )
        .
        find first buf_gds-prt no-lock
             where buf_gds-prt.node-name = {&empty-scale}
        no-error.
        if error-status :error
        then do:
            message
                "Err: Не найден корневой узел для шкалы товаров. Импорт товаров невозможен."
            view-as alert-box.
            undo, return error.
        end.
        run import-barcodes-for-goods in this-procedure (
              input buf_temp_goods.gds-code
            , input v-goods-unit-cli
            , input buf_gds-prt.node-code
        ) no-error.
        if error-status :error
        then do:
            undo, return error "Err: Ошибка при создании бар-кодов для товара: "
                        + " " + string( buf_temp_goods.gds-code )
                        + " " + string( buf_temp_goods.gds-name )
                        + {&new-line}
            .
        end.
        else do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "OK: Товар &1. Бар-коды созданы."
                                    , buf_temp_goods.gds-code
                                  )
            ).
        end.
        run impgds-write-cnt in this-procedure (
              input p-cnt-handle
            , input substitute( "Импортирован товар: &1 &2", buf_temp_goods.gds-code, buf_temp_goods.gds-name )
        ).
    end.        /* for each buf_temp_goods */
    run impgds-write-cnt in this-procedure (
          input p-cnt-handle
        , input substitute( " ":U )
    ).
    { gbl/stopwork.i }

  run adm/restseqr.p
      ( input "rest-no-msg":U
       ,input "":U
       ,input yes
    ) no-error .
  if error-status :error then do:
    return error return-value .
  end.
end.
END PROCEDURE. /* import-goods */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-enable Dialog-Frame
PROCEDURE init-enable :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:
    enable
        b-exit
        bt-read
        ed-log
    with frame {&frame-name} .
end.
END PROCEDURE. /* init-enable */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-fields Dialog-Frame
PROCEDURE init-fields :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-param-type                as character                no-undo.
define variable v-value-character           as character                no-undo.
define variable v-value-date                as date                     no-undo.
define variable v-value-decimal             as decimal                  no-undo.
define variable v-value-integer             as INTEGER                  no-undo.
define variable v-value-logical             AS LOGICAL                  no-undo.
define variable v-tth                       as handle                   no-undo.

do
on error undo, return error
:
    { gbl/getcntxt.i get  }
    assign
        v-store-type = v-cntxt-obj-type
        v-store-code = v-cntxt-obj-code
    .
    { gbl/hostcode.i
        v-store-type
        v-store-code
        v-host-code
    }
    { gbl/curdbnum.i
        v-db-num
    }
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
      ,input  {&attr-gds-ref_dif-pdbc} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output pbc-veto
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error.
  delete object v-tth.


    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
end.
END PROCEDURE. /* init-fields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read-bcodes-file Dialog-Frame
PROCEDURE read-bcodes-file :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-gds-code      as character    no-undo.
    define variable v-b-str         as character    no-undo.

    define variable v-temp-integer  as integer      no-undo.

    define buffer buf_temp_bar-codes    for temp_bar-codes.
    define buffer buf_prod-bc           for ub.prod-bc.
do
for buf_temp_bar-codes
  , buf_prod-bc
on error undo, return error
:
    { gbl/working.i }
    run impgds-write-log in this-procedure (
          input 0
        , input fill( "=", 80 )
    ).
    run impgds-write-log in this-procedure (
          input 1
        , input substitute( "Чтение бар-кодов из файла &1"
                        , {&impgds-barcode-filename} )
    ).
    input stream impgds-in from {&impgds-barcode-filename} .
    import-clients-string:
    repeat
    :
        assign
            v-gds-code      = "":U
            v-b-str         = "":U
        .
        import stream impgds-in
            v-gds-code
            v-b-str
        .
        if v-gds-code = "":U
        then do:
            next import-clients-string.
        end.
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame {&frame-name}
            , input v-impgds-last-rec-no + 1
            , input "gds-code":U
            , input v-gds-code
            , output v-temp-integer
        ).
        find first buf_temp_bar-codes no-lock
             where buf_temp_bar-codes.gds-code = v-temp-integer
               and buf_temp_bar-codes.b-str    = v-b-str
        no-error.
        if available buf_temp_bar-codes
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Повторное чтение бар-кода &2 для товара с кодом &1", v-temp-integer, v-b-str )
            ).
            assign
                v-impgds-repeated-records = v-impgds-repeated-records + 1
            .
            next import-clients-string.
        end.
        find first buf_prod-bc no-lock
             where buf_prod-bc.b-code   = v-temp-integer
               and buf_prod-bc.b-str    = v-b-str
        no-error.
        if available buf_prod-bc
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Чтение бар-кода &2, который есть у товара &1 в БД."
                        , v-temp-integer, v-b-str )
            ).
            assign
                v-impgds-existed-records  = v-impgds-existed-records + 1
            .
            next import-clients-string.
        end.
        create buf_temp_bar-codes.
        assign
            v-impgds-last-rec-no    = v-impgds-last-rec-no + 1
        .
        assign
            buf_temp_bar-codes.rec-no           = v-impgds-last-rec-no
            buf_temp_bar-codes.gds-code         = v-temp-integer
            buf_temp_bar-codes.b-str            = v-b-str
        .
    end.        /* repeat */
    input stream impgds-in close.
    { gbl/stopwork.i }
end.
END PROCEDURE. /* read-bcodes-file */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read-clients-file Dialog-Frame
PROCEDURE read-clients-file :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-obj-code      as character    no-undo.
    define variable v-obj-name      as character    no-undo.
    define variable v-address       as character    no-undo.
    define variable v-phone         as character    no-undo.
    define variable v-fax           as character    no-undo.
    define variable v-director      as character    no-undo.
    define variable v-email         as character    no-undo.
    define variable v-okonh         as character    no-undo.
    define variable v-okpo          as character    no-undo.
    define variable v-inn           as character    no-undo.
    define variable v-kpp           as character    no-undo.
    define variable v-ps            as character    no-undo.

    define variable v-temp-integer     as integer      no-undo.

    define buffer buf_temp_clients  for temp_clients.
    define buffer buf_clients       for ub.clients.
do
for buf_temp_clients
  , buf_clients
on error undo, return error
:
    { gbl/working.i }
    run impgds-write-log in this-procedure (
          input 0
        , input fill( "=", 80 )
    ).
    run impgds-write-log in this-procedure (
          input 1
        , input substitute( "Чтение контрагентов из файла &1"
                        , {&impgds-clients-filename} )
    ).
    input stream impgds-in from {&impgds-clients-filename} .
    import-clients-string:
    repeat
    :
        assign
            v-obj-code      = "":U
            v-obj-name      = "":U
        .
        import stream impgds-in
            v-obj-code
            v-obj-name
            v-address
            v-phone
            v-fax
            v-director
            v-email
            v-okonh
            v-okpo
            v-inn
            v-kpp
            v-ps
        .
        if v-obj-code = "":U
        then do:
            next import-clients-string.
        end.
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame {&frame-name}
            , input v-impgds-last-rec-no + 1
            , input "obj-code":U
            , input v-obj-code
            , output v-temp-integer
        ).
        find first buf_temp_clients
             where buf_temp_clients.obj-code = v-temp-integer
        no-error.
        if available buf_temp_clients
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Повторное чтение объекта с кодом &1", v-temp-integer )
            ).
            assign
                v-impgds-repeated-records = v-impgds-repeated-records + 1
            .
            next import-clients-string.
        end.
        find first buf_clients no-lock
             where buf_clients.obj-type = {&cmp}
               and buf_clients.obj-code = v-temp-integer
        no-error.
        if available buf_clients
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Чтение объекта с кодом, который есть у объекта в БД: &1"
                        , v-temp-integer )
            ).
            assign
                v-impgds-existed-records  = v-impgds-existed-records + 1
            .
            next import-clients-string.
        end.
        create buf_temp_clients.
        assign
            v-impgds-last-rec-no    = v-impgds-last-rec-no + 1
        .
        assign
            buf_temp_clients.rec-no           = v-impgds-last-rec-no
            buf_temp_clients.obj-code         = v-temp-integer
            buf_temp_clients.obj-name         = v-obj-name
            buf_temp_clients.address          = v-address
            buf_temp_clients.phone            = v-phone
            buf_temp_clients.fax              = v-fax
            buf_temp_clients.director         = v-director
            buf_temp_clients.email            = v-email
            buf_temp_clients.okonh            = v-okonh
            buf_temp_clients.okpo             = v-okpo
            buf_temp_clients.inn              = v-inn
            buf_temp_clients.kpp              = v-kpp
            buf_temp_clients.ps               = v-ps
        .
    end.        /* repeat */
    input stream impgds-in close.
    { gbl/stopwork.i }
end.
END PROCEDURE. /* read-clients-file */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read-data Dialog-Frame
PROCEDURE read-data :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-cnt-handle         as handle           no-undo.
define input parameter p-log-handle         as handle           no-undo.
define output parameter p-import-available  as logical          no-undo.

do
on error undo, return error
:
    define variable v-data-have-error    as logical      no-undo.

    assign
        v-data-have-error = no
    .
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input "Чтение данных для импорта."
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input substitute( "Лог-файл:      &1", {&impgds-log-filename} )
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 1
        , input substitute( "Файл ошибок:   &1", {&impgds-err-filename} )
    ).
/* Объекты */
    assign
        v-impgds-last-rec-no        = 0
        v-impgds-repeated-records   = 0
        v-impgds-existed-records    = 0
        v-impgds-error-records      = 0
    .
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла контрагентов &1...", {&impgds-clients-filename}  )
    ).
    disable
        bt-read
    with frame {&frame-name} .
    run read-clients-file in this-procedure
    no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка чтения файла контрагентов."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла контрагентов завершено." )
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Считано &1 записей.", v-impgds-last-rec-no )
    ).
    if v-impgds-repeated-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Повторно считано &1 контрагентов (вторая запись не будет импортирована).", v-impgds-repeated-records )
        ).
    end.
    if v-impgds-existed-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 контрагентов, уже существующих в базе данных (не будут импортированы).", v-impgds-existed-records )
        ).
    end.
    if v-impgds-error-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 контрагентов с ошибками. Импорт невозможен.", v-impgds-error-records )
        ).
        assign
            v-data-have-error = yes
        .
    end.
/* Группы товаров */
    assign
        v-impgds-last-rec-no        = 0
        v-impgds-repeated-records   = 0
        v-impgds-existed-records    = 0
        v-impgds-error-records      = 0
    .
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла групп товаров &1...", {&impgds-gds-grp-filename}  )
    ).
    run read-gds-grp-file in this-procedure (
        input p-log-handle
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка чтения файла групп товаров."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла групп товаров завершено." )
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Считано &1 записей.", v-impgds-last-rec-no )
    ).
    if v-impgds-repeated-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Повторно считано &1 групп товаров (вторая запись не будет импортирована).", v-impgds-repeated-records )
        ).
    end.
    if v-impgds-existed-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 групп товаров, уже существующих в базе данных (не будут импортированы).", v-impgds-existed-records )
        ).
    end.
    if v-impgds-error-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 групп товаров с ошибками. Импорт невозможен.", v-impgds-error-records )
        ).
        assign
            v-data-have-error = yes
        .
    end.
/* Товары */
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input "Чтение таблицы налогов из базы данных..."
    ).
    run read-tax-in-base in this-procedure
    no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка чтения ставок налогов."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input "Чтение таблицы налогов из базы данных завершено."
    ).
    assign
        v-impgds-last-rec-no        = 0
        v-impgds-repeated-records   = 0
        v-impgds-existed-records    = 0
        v-impgds-error-records      = 0
    .
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла товаров &1...", {&impgds-goods-filename}  )
    ).
    run read-goods-file in this-procedure (
          input p-cnt-handle
        , input p-log-handle
    ) no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка чтения файла товаров."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла товаров завершено." )
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Считано &1 записей.", v-impgds-last-rec-no )
    ).
    if v-impgds-repeated-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Повторно считано &1 кодов товаров (вторая запись не будет импортирована).", v-impgds-repeated-records )
        ).
    end.
    if v-impgds-existed-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 кодов товаров, уже существующих в базе данных (не будут импортированы).", v-impgds-existed-records )
        ).
    end.
    if v-impgds-error-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 товаров с ошибками. Импорт невозможен.", v-impgds-error-records )
        ).
        assign
            v-data-have-error = yes
        .
    end.
/* Бар-коды */
    assign
        v-impgds-last-rec-no        = 0
        v-impgds-repeated-records   = 0
        v-impgds-existed-records    = 0
        v-impgds-error-records      = 0
    .
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла бар-кодов &1...", {&impgds-barcode-filename}  )
    ).
    run read-bcodes-file in this-procedure
    no-error.
    if error-status :error
    then do:
        message
                 vss-workfile vss-revision vss-description
            skip(1)
            skip "Ошибка чтения файла бар-кодов."
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Чтение файла бар-кодов завершено." )
    ).
    run impgds-write-edt in this-procedure (
          input p-log-handle
        , input 2
        , input substitute( "Считано &1 записей.", v-impgds-last-rec-no )
    ).
    if v-impgds-repeated-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Повторно считано &1 бар-кодов (вторая запись не будет импортирована).", v-impgds-repeated-records )
        ).
    end.
    if v-impgds-existed-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 бар-кодов, уже существующих в базе данных (не будут импортированы).", v-impgds-existed-records )
        ).
    end.
    if v-impgds-error-records <> 0
    then do:
        run impgds-write-edt in this-procedure (
              input p-log-handle
            , input 2
            , input substitute( "Считано &1 бар-кодов с ошибками. Импорт невозможен.", v-impgds-error-records )
        ).
        assign
            v-data-have-error = yes
        .
    end.
    if v-data-have-error = no
    then do:
        assign
            p-import-available = yes
        .
    end.
end.
END PROCEDURE. /* read-data */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read-gds-grp-file Dialog-Frame
PROCEDURE read-gds-grp-file :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-edt-handle     as handle           no-undo.

    define variable v-node-code       as character    no-undo.
    define variable v-upper-code      as character    no-undo.
    define variable v-node-name       as character    no-undo.

    define variable v-temp-integer     as integer      no-undo.
    define variable v-temp-decimal     as decimal      no-undo.
    define variable v-error-message    as character    no-undo.

    define buffer buf_temp_gds-grp  for temp_gds-grp.
    define buffer buf_gds-grp       for ub.gds-grp.
do
for buf_temp_gds-grp
  , buf_gds-grp
on error undo, return error
:
    { gbl/working.i }
    run impgds-write-log in this-procedure (
          input 0
        , input fill( "=", 80 )
    ).
    run impgds-write-log in this-procedure (
          input 1
        , input substitute( "Чтение групп товаров из файла &1"
                        , {&impgds-gds-grp-filename} )
    ).
    input stream impgds-in from {&impgds-gds-grp-filename} .
    import-gds-grp-string:
    repeat
    :
        assign
            v-node-code      = "":U
            v-upper-code     = "":U
            v-node-name      = "":U
        .
        import stream impgds-in
            v-node-code
            v-upper-code
            v-node-name
        .
        if v-node-code = "":U
        then do:
            next import-gds-grp-string.
        end.
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame {&frame-name}
            , input v-impgds-last-rec-no + 1
            , input "node-code":U
            , input v-node-code
            , output v-temp-integer
        ).
        find first buf_temp_gds-grp no-lock
             where buf_temp_gds-grp.node-code = v-temp-integer
        no-error.
        if available buf_temp_gds-grp
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Повторное чтение группы товара с кодом &1", v-temp-integer )
            ).
            assign
                v-impgds-repeated-records = v-impgds-repeated-records + 1
            .
            next import-gds-grp-string.
        end.
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-temp-integer
        no-error.
        if available buf_gds-grp
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Чтение группы товара с кодом, который есть у группы в БД: &1"
                        , v-temp-integer )
            ).
            assign
                v-impgds-existed-records  = v-impgds-existed-records + 1
            .
            next import-gds-grp-string.
        end.
        create buf_temp_gds-grp.
        assign
            v-impgds-last-rec-no    = v-impgds-last-rec-no + 1
        .
        assign
            buf_temp_gds-grp.rec-no           = v-impgds-last-rec-no
            buf_temp_gds-grp.node-code        = v-temp-integer
            buf_temp_gds-grp.node-name        = v-node-name
        .
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame {&frame-name}
            , input v-impgds-last-rec-no + 1
            , input "upper-code":U
            , input v-upper-code
            , output buf_temp_gds-grp.upper-code
        ).
        run grplib-analyze-grp-name in this-procedure (
              input v-node-name
            , input buf_temp_gds-grp.upper-code
            , output v-error-message
        ).
        if v-error-message <> "":U
        then do:
            run impgds-write-error in this-procedure (
                  input 1
                , input substitute( "Ошибка в имени группы товара &1: &2", buf_temp_gds-grp.node-code, v-error-message )
            ).
            run impgds-write-edt in this-procedure (
                  input ed-log :handle in frame {&frame-name}
                , input 1
                , input substitute( "Ошибка в имени группы &1: &2", buf_temp_gds-grp.node-code, v-error-message )
            ).
            assign
                v-impgds-error-records  = v-impgds-error-records + 1
            .
        end.
    end.        /* repeat */
    input stream impgds-in close.
    { gbl/stopwork.i }
end.
END PROCEDURE. /* read-gds-grp-file */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read-goods-file Dialog-Frame
PROCEDURE read-goods-file :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define input parameter p-cnt-handle     as handle           no-undo.
define input parameter p-log-handle     as handle           no-undo.

    define variable v-gds-code          as character   no-undo.   /* integer */
    define variable v-artic             as character   no-undo.
    define variable v-prod-code         as character   no-undo.   /* integer */
    define variable v-grp-code          as character   no-undo.   /* integer */
    define variable v-unit-base         as character   no-undo.
    define variable v-unit-base-type    as character   no-undo.
    define variable v-gds-type          as character   no-undo.
    define variable v-gds-name          as character   no-undo.
    define variable v-engl-name         as character   no-undo.
    define variable v-VAT-pc            as character   no-undo.   /* decimal */
    define variable v-SLT-pc            as character   no-undo.   /* decimal */
    define variable v-deadline          as character   no-undo.   /* integer */
    define variable v-have-error        as logical      no-undo.
    define variable v-error-message     as character    no-undo.

    define variable v-temp-integer      as integer      no-undo.
    define variable v-temp-decimal      as decimal      no-undo.

    define buffer buf_temp_goods        for temp_goods.
    define buffer buf_rep_temp_goods    for temp_goods.
    define buffer buf_goods             for ub.goods.
do
for buf_temp_goods
  , buf_rep_temp_goods
  , buf_goods
on error undo, return error
:
    { gbl/working.i }
    run impgds-write-log in this-procedure (
          input 0
        , input fill( "=", 80 )
    ).
    run impgds-write-log in this-procedure (
          input 1
        , input substitute( "Чтение товаров из файла &1"
                        , {&impgds-goods-filename} )
    ).
    input stream impgds-in from {&impgds-goods-filename} .
    import-goods-string:
    repeat
    :
        assign
            v-gds-code       = "":U
            v-artic          = "":U
            v-prod-code      = "":U
            v-grp-code       = "":U
            v-unit-base      = "":U
            v-unit-base-type = "":U
            v-gds-type       = "":U
            v-gds-name       = "":U
            v-engl-name      = "":U
            v-VAT-pc         = "":U
            v-SLT-pc         = "":U
            v-deadline       = "":U
        .
        import stream impgds-in
            v-gds-code
            v-artic
            v-prod-code
            v-grp-code
            v-unit-base
            v-unit-base-type
            v-gds-type
            v-gds-name
            v-engl-name
            v-VAT-pc
            v-SLT-pc
            v-deadline
        .
        if v-gds-code = "":U
        then do:
            next import-goods-string.
        end.
        run check-gds in this-procedure (
              input v-gds-code
            , input v-gds-name
            , output v-have-error
            , output v-error-message
        ).
        if v-have-error = yes
        then do:
            run impgds-write-error in this-procedure (
                  input 1
                , input substitute( "Не прошла проверка товара с кодом &1. &2" , v-gds-code, v-error-message )
            ).
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "*** Ошибка: Не прошла проверка товара с кодом &1. &2" , v-gds-code, v-error-message )
            ).
            run impgds-write-edt in this-procedure (
                  input ed-log :handle in frame {&frame-name}
                , input 1
                , input substitute( "Ошибка товара &1. &2" , v-gds-code, v-error-message )
            ).
            assign
                v-impgds-error-records  = v-impgds-error-records + 1
            .
        end.
        if v-artic = "":U
        then do:
            assign
                v-artic = v-gds-code
            .
        end.
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame {&frame-name}
            , input v-impgds-last-rec-no + 1
            , input "gds-code":U
            , input v-gds-code
            , output v-temp-integer
        ).
        find first buf_temp_goods no-lock
             where buf_temp_goods.gds-code = v-temp-integer
        no-error.
        if available buf_temp_goods
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Повторное чтение товара с кодом &1", v-temp-integer )
            ).
            assign
                v-impgds-repeated-records = v-impgds-repeated-records + 1
            .
            next import-goods-string.
        end.
        find first buf_goods no-lock
             where buf_goods.gds-code = v-temp-integer
        no-error.
        if available buf_goods
        then do:
            run impgds-write-log in this-procedure (
                  input 1
                , input substitute( "Чтение товара с кодом, который есть у товара в БД: &1"
                        , v-temp-integer )
            ).
            assign
                v-impgds-existed-records  = v-impgds-existed-records + 1
            .
            next import-goods-string.
        end.
        create buf_temp_goods.
        assign
            v-impgds-last-rec-no    = v-impgds-last-rec-no + 1
        .
        assign
            buf_temp_goods.rec-no           = v-impgds-last-rec-no
            buf_temp_goods.gds-code         = v-temp-integer
            buf_temp_goods.artic            = v-artic
        .
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame {&frame-name}
            , input v-impgds-last-rec-no + 1
            , input "prod-code":U
            , input v-prod-code
            , output buf_temp_goods.prod-code
        ).
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame {&frame-name}
            , input v-impgds-last-rec-no + 1
            , input "grp-code":U
            , input v-grp-code
            , output buf_temp_goods.grp-code
        ).
        assign
            buf_temp_goods.unit-base        = v-unit-base
            buf_temp_goods.unit-base-type   = v-unit-base-type
            buf_temp_goods.gds-type         = v-gds-type
            buf_temp_goods.gds-name         = v-gds-name
            buf_temp_goods.engl-name        = v-engl-name
        .
        run impgds-assign-decimal in this-procedure (
              input ed-log :handle in frame {&frame-name}
            , input v-impgds-last-rec-no
            , input "VAT-pc":U
            , input v-VAT-pc
            , output buf_temp_goods.VAT-pc
        ).
        run impgds-assign-decimal in this-procedure (
              input ed-log :handle in frame {&frame-name}
            , input v-impgds-last-rec-no
            , input "SLT-pc":U
            , input v-SLT-pc
            , output buf_temp_goods.SLT-pc
        ).
        run impgds-assign-integer in this-procedure (
              input ed-log :handle in frame {&frame-name}
            , input v-impgds-last-rec-no
            , input "deadline":U
            , input v-deadline
            , output buf_temp_goods.deadline
        ).
        run impgds-write-cnt in this-procedure (
              input p-cnt-handle
            , input substitute( "Считан товар: &1 &2", buf_temp_goods.gds-code, buf_temp_goods.gds-name )
        ).
    end.
    input stream impgds-in close.
    { gbl/stopwork.i }
end.
END PROCEDURE. /* read-goods-file */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE read-tax-in-base Dialog-Frame
PROCEDURE read-tax-in-base :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    define variable v-tax-value    as decimal      no-undo.

    define buffer buf_tax-rate-value    for ub.tax-rate-value.
    define buffer buf_temp_tax          for temp_tax.
do
for buf_tax-rate-value
  , buf_temp_tax
on error undo, return error
:
    for each buf_temp_tax
    :
        delete buf_temp_tax.
    end.
    tax-rate-value-string:
    for each buf_tax-rate-value
       where buf_tax-rate-value.tax-code = integer( {&vat-tax-code} )
    :
        if buf_tax-rate-value.status_ <> {&current-status}
        then do:
            if v-impgds-last-rate-code < buf_tax-rate-value.rate-code
            then do:
                assign
                    v-impgds-last-rate-code = buf_tax-rate-value.rate-code
                .
            end.
            next tax-rate-value-string.
        end.
        { gbl/pftaxval.i
            recid(buf_tax-rate-value)
            buf_tax-rate-value.tax-code
            buf_tax-rate-value.rate-code
            ?
            0
            "''"
            0
            v-tax-value
        }
        find first buf_temp_tax
             where buf_temp_tax.tax-code            = buf_tax-rate-value.tax-code
               and buf_temp_tax.rate-code           = buf_tax-rate-value.rate-code
               and buf_tax-rate-value.rate-value    = v-tax-value
        no-error.
        if not available buf_temp_tax
        then do:
            create buf_temp_tax.
            assign
                buf_temp_tax.tax-code       = buf_tax-rate-value.tax-code
                buf_temp_tax.rate-code      = buf_tax-rate-value.rate-code
                buf_temp_tax.rate-value     = v-tax-value
            .
            if v-impgds-last-rate-code < buf_tax-rate-value.rate-code
            then do:
                assign
                    v-impgds-last-rate-code = buf_tax-rate-value.rate-code
                .
            end.
        end.
    end.
    for each buf_tax-rate-value
       where buf_tax-rate-value.tax-code = integer( {&slt-tax-code} )
    :
        { gbl/pftaxval.i
            recid(buf_tax-rate-value)
            buf_tax-rate-value.tax-code
            buf_tax-rate-value.rate-code
            ?
            0
            "''"
            0
            v-tax-value
        }
        find first buf_temp_tax
             where buf_temp_tax.tax-code            = buf_tax-rate-value.tax-code
               and buf_temp_tax.rate-code           = buf_tax-rate-value.rate-code
               and buf_tax-rate-value.rate-value    = v-tax-value
        no-error.
        if not available buf_temp_tax
        then do:
            create buf_temp_tax.
            assign
                buf_temp_tax.tax-code       = buf_tax-rate-value.tax-code
                buf_temp_tax.rate-code      = buf_tax-rate-value.rate-code
                buf_temp_tax.rate-value     = v-tax-value
            .
        end.
    end.
end.
END PROCEDURE. /* read-tax-in-base */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME