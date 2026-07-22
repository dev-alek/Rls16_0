&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v8r12 GUI ADM1
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS F-Frame-Win

/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Описание файла

Автор: Комаров Иван Сергеевич
Дата создания: 12/23/09
Author: Ivan Komarov
Creation date: 12/23/09

*/

/* Create an unnamed pool to store all the widgets created
     by this procedure. This is a good default which assures
     that this procedure's triggers and internal procedures
     will execute in this procedure's storage, and that proper
     cleanup will occur on deletion of the procedure. */

CREATE WIDGET-POOL.

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Журнал регистрации полученных счетов фактур" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i new }
{ cmp/operlist.i }
{ str/trdcalib.i }
{ gbl/prn-lib.i  }
{ rep/fmtcli.i   }
{ gbl/cur-time.i }
{ cmp/showinf.i  }

define variable g#report-num as integer   no-undo .
{ gbl/paramls.i  }
{ rep/f-fdec.i   }
{ rep/mcrexcel.i }

{ str/d-supp.i  new }
{ rep/repfrm.i def }

DEFINE VARIABLE parParentProc AS WIDGET-HANDLE NO-UNDO.
ASSIGN
  parParentProc = my-handle
.

define temp-table temp-doc-list no-undo
  field doc-code    as character
  field supp-vat-pc as decimal
  field supp-slt-pc as decimal
  field fact-order  as decimal
  field scf-code    as character /* номер счета фактуры */
  field scf-date    as date      /* дата счета фактуры  */
  field supp-name   as character
  field inn         as character
  field no-vat-rubl as decimal
  field vat-rubl    as decimal
  field acc-rubl    as decimal

  index xpk is primary unique doc-code supp-vat-pc supp-slt-pc
  index xie1 fact-order doc-code supp-vat-pc supp-slt-pc
  .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE SmartObject
&Scoped-define DB-AWARE no

&Scoped-define ADM-CONTAINER FRAME

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME F-Main

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS RECT-cashiers SelectDocument
&Scoped-Define DISPLAYED-OBJECTS SelectDocument

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */


/* Definitions of the field level widgets                               */
DEFINE VARIABLE SelectDocument AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все", "1",
"Кроме межфирменных", "2",
"Межфирменные", "3"
     SIZE 42.63 BY 2.38
     FGCOLOR 0  NO-UNDO.

DEFINE RECTANGLE RECT-cashiers
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 44.5 BY 4.25.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME F-Main
     SelectDocument AT ROW 2.83 COL 2.38 NO-LABEL
     "Документы :" VIEW-AS TEXT
          SIZE 12 BY .92 AT ROW 1.5 COL 2
          FGCOLOR 4
     RECT-cashiers AT ROW 1.25 COL 1.5
    WITH 1 DOWN NO-BOX KEEP-TAB-ORDER OVERLAY
         SIDE-LABELS NO-UNDERLINE THREE-D
         AT COL 1 ROW 1
         SIZE 56.88 BY 11.83.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: SmartObject
   Allow: Basic,Browse,DB-Fields,Smart,Query
   Container Links:
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB)
  CREATE WINDOW F-Frame-Win ASSIGN
         HEIGHT             = 11.88
         WIDTH              = 56.88.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _INCLUDED-LIB F-Frame-Win
/* ************************* Included-Libraries *********************** */

{src/adm/method/containr.i}

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME




/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR WINDOW F-Frame-Win
  VISIBLE,,RUN-PERSISTENT                                               */
/* SETTINGS FOR FRAME F-Main
   NOT-VISIBLE FRAME-NAME                                               */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME


/* Setting information for Queries and Browse Widgets fields            */

&ANALYZE-SUSPEND _QUERY-BLOCK FRAME F-Main
/* Query rebuild information for FRAME F-Main
     _Options          = ""
     _Query            is NOT OPENED
*/  /* FRAME F-Main */
&ANALYZE-RESUME




&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK F-Frame-Win


/* ***************************  Main Block  *************************** */

{ gbl/personly.i }

run get-report-num in parParentProc
  (output g#report-num
  ).

&IF DEFINED(UIB_IS_RUNNING) <> 0 &THEN
   /* Now enable the interface  if in test mode - otherwise this happens when
      the object is explicitly initialized from its container. */
   RUN dispatch IN THIS-PROCEDURE ('initialize':U).
&ENDIF

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-create-objects F-Frame-Win  _ADM-CREATE-OBJECTS
PROCEDURE adm-create-objects :
/*------------------------------------------------------------------------------
  Purpose:     Create handles for all SmartObjects used in this procedure.
               After SmartObjects are initialized, then SmartLinks are added.
  Parameters:  <none>
------------------------------------------------------------------------------*/

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE adm-row-available F-Frame-Win  _ADM-ROW-AVAILABLE
PROCEDURE adm-row-available :
/*------------------------------------------------------------------------------
  Purpose:     Dispatched to this procedure when the Record-
               Source has a new row available.  This procedure
               tries to get the new row (or foriegn keys) from
               the Record-Source and process it.
  Parameters:  <none>
------------------------------------------------------------------------------*/

  /* Define variables needed by this internal procedure.             */
  {src/adm/template/row-head.i}

  /* Process the newly available records (i.e. display fields,
     open queries, and/or pass records on to any RECORD-TARGETS).    */
  {src/adm/template/row-end.i}

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE check-new-page F-Frame-Win
PROCEDURE check-new-page :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-address-num-lines as integer   no-undo .

  do
  on error undo, return error return-value
  :
    if line-counter ( PrnLibStream ) + p-address-num-lines > 42
    then do:
      page stream PrnLibStream .
      put stream PrnLibStream
        cur-time-print() at 5 format "x(35)"
        "Страница " at 100 page-number(PrnLibStream) at 115 format ">>>9" skip
        .
      put stream PrnLibStream
        '-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------':u format "X(185)" skip
        ':       1        :       2        :    3     :                    4                     :        5        :        7        :  8   :     9           :       12        :   10   :  11   :':u format "X(185)" skip
        '-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------':u format "X(185)" skip
        .
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI F-Frame-Win  _DEFAULT-DISABLE
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
  HIDE FRAME F-Main.
  IF THIS-PROCEDURE:PERSISTENT THEN DELETE PROCEDURE THIS-PROCEDURE.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI F-Frame-Win  _DEFAULT-ENABLE
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
  DISPLAY SelectDocument
      WITH FRAME F-Main.
  ENABLE RECT-cashiers SelectDocument
      WITH FRAME F-Main.
  {&OPEN-BROWSERS-IN-QUERY-F-Main}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-Report F-Frame-Win
PROCEDURE My-Report :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

run My-Var in this-procedure .

run PrintProc in this-procedure .

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE My-var F-Frame-Win
PROCEDURE My-var :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
assign
  frame {&frame-name} SelectDocument
.

assign
  STR-obj-type = ''
  STR-obj-code = ''
  STR-obj-name = ''
  STR-obj      = ''
.

for each obj-list no-lock
:
  assign
    STR-obj-type = STR-obj-type + obj-list.obj-type + ','
    STR-obj-code = STR-obj-code + String(obj-list.obj-code) + ','
    STR-obj-name = STR-obj-name + obj-list.obj-name + ','
    STR-obj = STR-obj +  obj-list.obj-type + '#' + string(obj-list.obj-code)  + ','
  .
end.

assign
  ReportName   = "Журнал регистрации полученных счетов-фактур"
  ReportHeader = "Документы : " +
                   radio-label(string(SelectDocument), SelectDocument:radio-buttons) + {&new-line}
.


END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-excel-header F-Frame-Win
PROCEDURE print-excel-header :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-host-code as integer   no-undo .
  define input-output parameter p-excel-line as integer   no-undo .

  do
  on error undo, return error return-value
  :
    run macr_excel_char in this-procedure
      (input  format-excel-text(ReportName)
      ,input  p-excel-line
      ,input  1
      ) .
    assign
      p-excel-line = p-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text(ReportHeader)
      ,input  p-excel-line
      ,input  1
      ) .

    run fmtcli-get-client in this-procedure
      (input  {&cmp}
      ,input  p-host-code
      ) .

    assign
      p-excel-line = p-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text(str1 + " по организации " + v-fmtcli-name )
      ,input  p-excel-line
      ,input  1
      ) .

    define variable v-str-num-entries   as integer   no-undo .
    define variable v-str-entry         as integer   no-undo .
    define variable v-str-text          as character no-undo .
    define variable v-sub-start         as integer   no-undo .
    define variable v-num-lines         as integer   no-undo .
    define variable v-start-length-list as character no-undo .
    define variable v-cur-line          as integer   no-undo .

    assign
      v-str-num-entries = num-entries(str4, {&new-line})
    .
    do v-str-entry = 1 to v-str-num-entries
    :
      assign
        v-str-text = entry(v-str-entry, str4, {&new-line})
      .

      run split-string in this-procedure
        (input  v-str-text
        ,input  60
        ,output v-num-lines
        ,output v-start-length-list
        ) .

      do v-cur-line = 1 to v-num-lines
      :
        assign
          p-excel-line = p-excel-line + 1
        .
        run macr_excel_char in this-procedure
          (input
            format-excel-text
            ( substring
              (v-str-text
              ,integer
                (entry
                  (v-cur-line * 2 - 1
                  ,v-start-length-list
                  ,{&comma-char}
                  )
                )
              ,integer
                (entry
                  (v-cur-line * 2
                  ,v-start-length-list
                  ,{&comma-char}
                  )
                )
              )
            )
          ,input  p-excel-line
          ,input  1
          ) .
      end.
    end.

    assign
      p-excel-line = p-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text(cur-time-print())
      ,input  p-excel-line
      ,input  1
      ) .
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE PrintProc F-Frame-Win
PROCEDURE PrintProc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

  define buffer buf_temp-doc-list for temp-doc-list .
  define buffer buf_obj-list      for obj-list .
  define buffer buf_trn-doc       for ub.trn-doc .
  define buffer buf_clients       for ub.clients .

  define variable v-select-document as logical   no-undo .
  define variable v-is-hold         as logical   no-undo .
  define variable v-scf-code        as character no-undo .
  define variable v-scf-date        as date      no-undo .
  define variable v-scf-date-str    as character no-undo .
  define variable v-parameter-type  as character no-undo .

  define buffer buf_d-slts-vats for d-slts-vats .

  do
  on error undo, return error return-value
  :
    define variable v-host-code as integer   no-undo .

    define variable v-first-obj-type  as character no-undo .
    define variable v-first-obj-code  as integer   no-undo .
    define variable v-other-host-code as integer   no-undo .

    find first buf_obj-list
      no-error .
    if available buf_obj-list
    then do:
      assign
        v-first-obj-type = buf_obj-list.obj-type
        v-first-obj-code = buf_obj-list.obj-code
      .

      { gbl/hostcode.i
        buf_obj-list.obj-type
        buf_obj-list.obj-code
        v-host-code
      }
    end.
    else do:
      message
        "Не выбран объект" skip
        view-as alert-box error .
      return .
    end.

    for each buf_obj-list
    on error undo, return error return-value
    :

      { gbl/hostcode.i
        buf_obj-list.obj-type
        buf_obj-list.obj-code
        v-other-host-code
      }
      if v-other-host-code <> v-host-code
      then do:
        message
          "Нельзя задавать объекты, принадлежащие разным фирмам" skip
          "Объект, принадлежащий одной фирме"
            v-first-obj-type v-first-obj-code skip
          "Объект, принадлежащий другой фирме"
            buf_obj-list.obj-type buf_obj-list.obj-code skip
          view-as alert-box error .
        return .
      end.
    end.

    for each buf_temp-doc-list
    on error undo, return error return-value
    :
      delete buf_temp-doc-list .
    end.

    { rep/repfrm.i on 25 }

    define variable v-total-doc as integer   no-undo .

    for each buf_obj-list
    on error undo, return error return-value
    :
    find first G#CUSTOMER no-error .
      if not available G#CUSTOMER then do :
          for each buf_clients no-lock :
            { rep/r-schfct.i buf_clients }
          end.
      end.
      else do :
          for each G#CUSTOMER no-lock :
            { rep/r-schfct.i G#CUSTOMER }
          end.
      end.
    end.
    run prn-lib-open-stream in this-procedure ( input my-handle, input {&LS_PS_A4}, input yes, input no ).

    assign
      v-total-doc = 0
    .
    { rep/repfrm.i disp v-total-doc }

    define variable v-file-name-ind as integer   no-undo .

    assign
      make-excel      = yes
      v-file-name     = string(session :temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt"
      v-file-name-ind = 1
    .
    output stream macr_excel to value(v-file-name) .

    define variable v-excel-line  as integer   no-undo .
    define variable v-excel-sheet as integer   no-undo .
    define variable v-line        as character no-undo .

    /* напечатать заголовок отчета */
    assign
      v-excel-line  = 1
      v-excel-sheet = 1
    .

    assign
      v-line = fill('-', 185)
    .

    form header
      v-line format "x(185)" at 1 skip
      "Продолжение - на следующей странице" at 30 skip
      with frame bottomframe width 186 page-bottom no-labels no-box
      .
    view stream PrnLibStream frame bottomframe .

    put stream PrnLibStream
      caps(ReportName) format "X(185)" skip
      ReportHeader format "X(185)" skip
      .

    run fmtcli-get-client in this-procedure
      (input  {&cmp}
      ,input  v-host-code
      ) .

    put stream PrnLibStream
      str1 + " по организации " + v-fmtcli-name format "X(185)" skip
      .

    define variable v-str-num-entries as integer   no-undo .
    define variable v-str-entry       as integer   no-undo .
    define variable v-str-text        as character no-undo .
    define variable v-sub-start       as integer   no-undo .

    assign
      v-str-num-entries = num-entries(str4, {&new-line})
    .
    do v-str-entry = 1 to v-str-num-entries
    :
      assign
        v-str-text = entry(v-str-entry, str4, {&new-line})
      .
      do v-sub-start = 1 to length(v-str-text) by 60
      :
        put stream PrnLibStream
          substring(v-str-text, v-sub-start, 60) format "X(185)" skip
          .
      end.
    end.

    put stream PrnLibStream
      cur-time-print() at 5 format "x(35)"
      "Страница " at 100 page-number(PrnLibStream) at 115 format ">>>9" skip
      .

    put stream PrnLibStream
      '-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------':u format "X(185)" skip
      ': N п/п          : N счета-фактуры: Дата     : Наименование поставщика                  : {&abbr_inn_allshift}             : Стоимость       :       НДС              : Всего стоимость :      Акциз     :':u format "X(185)" skip
      ':                :                : выписки  :                                          : поставщика      : поставки        :------:-----------------: {&abbr_rubley}          :--------:-------:':u format "X(185)" skip
      ':                :                : счета-   :                                          :                 : без НДС ({&abbr_rubley}):Ставка:  Сумма          :                 : Ставка : Сумма :':u format "X(185)" skip
      ':                :                : фактуры  :                                          :                 :                 :      :                 :                 :        :       :':u format "X(185)" skip
      '-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------':u format "X(185)" skip
      ':       1        :       2        :    3     :                    4                     :        5        :        7        :  8   :     9           :       12        :   10   :  11   :':u format "X(185)" skip
      '-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------':u format "X(185)" skip
      .

    run print-excel-header in this-procedure
      (input         v-host-code
      ,input-output  v-excel-line
      ) .

    run setup-excel-sheet in this-procedure
      (input-output  v-excel-line
      ) .

    run macr_cell_format in this-procedure
      (input 18           /* p-size   */
      ,input true         /* p-bold   */
      ,input false        /* p-italic */
      ,input ?            /* p-color  */
      ,input 1            /* p-row    */
      ,input 1            /* p-col    */
      ,input ?            /* p-row-2  */
      ,input ?            /* p-col-2  */
      ) .


    define variable v-total-no-vat-rubl as decimal   no-undo .
    define variable v-total-vat-rubl    as decimal   no-undo .
    define variable v-total-acc-rubl    as decimal   no-undo .

    assign
      v-total-no-vat-rubl = 0
      v-total-vat-rubl    = 0
      v-total-acc-rubl    = 0
    .

    for each buf_temp-doc-list
    by buf_temp-doc-list.fact-order
    on error undo, return error return-value
    :
      assign
        v-total-no-vat-rubl = v-total-no-vat-rubl + buf_temp-doc-list.no-vat-rubl
        v-total-vat-rubl    = v-total-vat-rubl    + buf_temp-doc-list.vat-rubl
        v-total-acc-rubl    = v-total-acc-rubl    + buf_temp-doc-list.acc-rubl
      .

      assign
        v-total-doc = v-total-doc + 1
      .
      assign
        v-excel-line = v-excel-line + 1
      .
      { rep/repfrm.i disp v-total-doc }

      run macr_excel_char in this-procedure
        (input  format-excel-text(buf_temp-doc-list.doc-code)
        ,input  v-excel-line
        ,input  1
        ) .
      run macr_excel_char in this-procedure
        (input  format-excel-text(buf_temp-doc-list.scf-code)
        ,input  v-excel-line
        ,input  2
        ) .
      if buf_temp-doc-list.scf-date <> ?
      then do:
        run macr_excel_date in this-procedure
          (input  buf_temp-doc-list.scf-date - date(1, 1, 1900) + 2
          ,input  v-excel-line
          ,input  3
          ) .
      end.
      run macr_excel_char in this-procedure
        (input  format-excel-text(buf_temp-doc-list.supp-name)
        ,input  v-excel-line
        ,input  4
        ) .
      run macr_excel_char in this-procedure
        (input  format-excel-text(buf_temp-doc-list.inn)
        ,input  v-excel-line
        ,input  5
        ) .
      run macr_excel_sum in this-procedure
        (input  buf_temp-doc-list.no-vat-rubl
        ,input  v-excel-line
        ,input  6
        ,input  2
        ) .
      put stream macr_excel unformatted
        substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 6 , v-excel-line, 6 ) + {&new-line}
        'format.number("#,##0.00")':u + {&new-line}
        .

      run macr_excel_sum in this-procedure
        (input  buf_temp-doc-list.supp-vat-pc
        ,input  v-excel-line
        ,input  7
        ,input  2
        ) .
      run macr_excel_sum in this-procedure
        (input  buf_temp-doc-list.vat-rubl
        ,input  v-excel-line
        ,input  8
        ,input  2
        ) .
      put stream macr_excel unformatted
        substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 8 , v-excel-line, 8 ) + {&new-line}
        'format.number("#,##0.00")':u + {&new-line}
        .

      run macr_excel_sum in this-procedure
        (input  buf_temp-doc-list.acc-rubl
        ,input  v-excel-line
        ,input  9
        ,input  2
        ) .
      put stream macr_excel unformatted
        substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 9 , v-excel-line, 9 ) + {&new-line}
        'format.number("#,##0.00")':u + {&new-line}
        .

      /* выравнивание по верхнему краю */
      /* задать границу в виде пунктирной линии */
      put stream macr_excel unformatted
        substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 1 , v-excel-line, 11 ) + {&new-line}
        'alignment(,,1,,)':u + {&new-line}
        'border(4,4,4,4,4,,,,,,)':u + {&new-line}
        .
      put stream macr_excel unformatted
        substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 4 , v-excel-line, 4 ) + {&new-line}
        'alignment(,true,,,)':u + {&new-line}
        .

      if v-excel-line > 30000
      then do:
        /* выбираем верхнюю левую ячейку */
        put stream macr_excel unformatted
          'select("r1c1")':u + {&new-line}
          .
        /* необходимо создать новую страницу в excel*/
        output stream macr_excel close .
        run paramls-write in this-procedure
          (input  "file"
          ,input  string(v-file-name-ind)
          ,input  v-file-name
          ) .

        assign
          v-file-name-ind = v-file-name-ind + 1
          v-excel-line    = 1
        .

        assign
          v-file-name = string(session :temp-directory) + {&DF_Name} + string( g#report-num )  + "_" + string(v-file-name-ind) + ".txt"
        .
        output stream macr_excel to value(v-file-name) .

        run setup-excel-sheet in this-procedure
          (input-output  v-excel-line
          ) .
      end.

      define variable v-address-num-lines as integer   no-undo .
      define variable v-start-length-list as character no-undo .
      define variable v-address-line      as integer   no-undo .

      run split-string in this-procedure
        (input  buf_temp-doc-list.supp-name
        ,input  40
        ,output v-address-num-lines
        ,output v-start-length-list
        ) .

      run check-new-page in this-procedure
        (input  v-address-num-lines
        ) .

      do v-address-line = 1 to v-address-num-lines
      :
        if v-address-line = 1
        then do:
          put stream PrnLibStream
            ": " format "x(2)"
            buf_temp-doc-list.doc-code    format "x(14)"
            " : "                         format "x(3)"
            buf_temp-doc-list.scf-code    format "x(14)"
            " : "                         format "x(3)"
            buf_temp-doc-list.scf-date    format "99.99.99"
            " : "                         format "x(3)"
            substring(buf_temp-doc-list.supp-name
                     ,integer(entry(v-address-line * 2 - 1,v-start-length-list,{&comma-char}))
                     ,integer(entry(v-address-line * 2,v-start-length-list,{&comma-char}))
                     ) format "x(40)"
            " : "                         format "x(3)"
            buf_temp-doc-list.inn         format "x(15)"
            " : "                         format "x(3)"
            buf_temp-doc-list.no-vat-rubl format "->>>,>>>,>>>.99"
            " : "                         format "x(3)"
            buf_temp-doc-list.supp-vat-pc format ">>9.<<"
            " : "                         format "x(3)"
            buf_temp-doc-list.vat-rubl    format "->>>,>>>,>>>.99"
            " : "                         format "x(3)"
            buf_temp-doc-list.acc-rubl    format "->>>,>>>,>>>.99"
            " : "                         format "x(3)"
            " " /* акциз, ставка */       format "x(6)"
            " : "                         format "x(3)"
            " " /* акциз, сумма */        format "x(5)"
            " :"                          format "x(2)"
            skip
            .
        end.
        else do:
          put stream PrnLibStream
            ": " format "x(2)"
            " "                           format "x(14)"
            " : "                         format "x(3)"
            " "                           format "x(14)"
            " : "                         format "x(3)"
            " "                           format "x(8)"
            " : "                         format "x(3)"
            substring(buf_temp-doc-list.supp-name
                     ,integer(entry(v-address-line * 2 - 1,v-start-length-list,{&comma-char}))
                     ,integer(entry(v-address-line * 2,v-start-length-list,{&comma-char}))
                     ) format "x(40)"
            " : "                         format "x(3)"
            " "                           format "x(15)"
            " : "                         format "x(3)"
            " "                           format "x(15)"
            " : "                         format "x(3)"
            " "                           format "x(4)"
            " : "                         format "x(3)"
            " "                           format "x(15)"
            " : "                         format "x(3)"
            " "                           format "x(15)"
            " : "                         format "x(3)"
            " " /* акциз, ставка */       format "x(6)"
            " : "                         format "x(3)"
            " " /* акциз, сумма */        format "x(5)"
            " :"                          format "x(2)"
            skip
            .
        end.
      end.

    end.

    assign
      v-excel-line = v-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text("ИТОГО:")
      ,input  v-excel-line
      ,input  5
      ) .
    run macr_cell_format in this-procedure
      (input 8            /* p-size   */
      ,input true         /* p-bold   */
      ,input false        /* p-italic */
      ,input ?            /* p-color  */
      ,input v-excel-line /* p-row    */
      ,input 5            /* p-col    */
      ,input ?            /* p-row-2  */
      ,input ?            /* p-col-2  */
      ) .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 1 , v-excel-line, 6 ) + {&new-line}
      'border(1,,,,,,,,,,)':u + {&new-line}
      .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 7 , v-excel-line, 7 ) + {&new-line}
      'border(1,,,,,,,,,,)':u + {&new-line}
      .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 8 , v-excel-line, 8 ) + {&new-line}
      'border(1,,,,,,,,,,)':u + {&new-line}
      .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 9 , v-excel-line, 9 ) + {&new-line}
      'border(1,,,,,,,,,,)':u + {&new-line}
      .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 10 , v-excel-line, 10 ) + {&new-line}
      'border(1,,,,,,,,,,)':u + {&new-line}
      .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 11 , v-excel-line, 11 ) + {&new-line}
      'border(1,,,,,,,,,,)':u + {&new-line}
      .

    run macr_excel_sum in this-procedure
      (input  v-total-no-vat-rubl
      ,input  v-excel-line
      ,input  6
      ,input  2
      ) .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 6 , v-excel-line, 6 ) + {&new-line}
      'format.number("#,##0.00")':u + {&new-line}
      .
    run macr_excel_sum in this-procedure
      (input  v-total-vat-rubl
      ,input  v-excel-line
      ,input  8
      ,input  2
      ) .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 8 , v-excel-line, 8 ) + {&new-line}
      'format.number("#,##0.00")':u + {&new-line}
      .
    run macr_excel_sum in this-procedure
      (input  v-total-acc-rubl
      ,input  v-excel-line
      ,input  9
      ,input  2
      ) .
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")' , v-excel-line , 9 , v-excel-line, 9 ) + {&new-line}
      'format.number("#,##0.00")':u + {&new-line}
      .

    define buffer buf_sysconf for ub.sysconf .
    define buffer buf_firm    for ub.firm .

    define variable v-glav-buh  as character no-undo .
    define variable v-director  as character no-undo .

    find first buf_sysconf no-lock
      where buf_sysconf.host-code = v-host-code
      no-error .
    if available buf_sysconf
    then do:
      assign
        v-glav-buh = buf_sysconf.snr-accnt
      .
    end.
    else do:
      assign
        v-glav-buh = ""
      .
    end.

    find first buf_firm no-lock
      where buf_firm.firm-code = v-host-code
      no-error .
    if available buf_firm
    then do:
      assign
        v-director = buf_firm.director
      .
    end.
    else do:
      assign
        v-director = ""
      .
    end.

    assign
      v-excel-line = v-excel-line + 3
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Руководитель организации (физическое лицо):")
      ,input  v-excel-line
      ,input  1
      ) .

    assign
      v-excel-line = v-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text(v-director)
      ,input  v-excel-line
      ,input  1
      ) .
    run macr_cell_format in this-procedure
      (input 8            /* p-size   */
      ,input false        /* p-bold   */
      ,input true         /* p-italic */
      ,input ?            /* p-color  */
      ,input v-excel-line /* p-row    */
      ,input 1            /* p-col    */
      ,input ?            /* p-row-2  */
      ,input ?            /* p-col-2  */
      ) .
    /* подчеркиваем */
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")':u, v-excel-line, 1, v-excel-line, 4) + {&new-line}
      'row.height(20,,,)':u + {&new-line}
      'border(,,,,1,,,,,,)':u + {&new-line}
      .

    assign
      v-excel-line = v-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Ф.И.О., подпись")
      ,input  v-excel-line
      ,input  2
      ) .
    run macr_cell_format in this-procedure
      (input 7            /* p-size   */
      ,input false        /* p-bold   */
      ,input true         /* p-italic */
      ,input ?            /* p-color  */
      ,input v-excel-line /* p-row    */
      ,input 2            /* p-col    */
      ,input ?            /* p-row-2  */
      ,input ?            /* p-col-2  */
      ) .

    assign
      v-excel-line = v-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text("М.П.")
      ,input  v-excel-line
      ,input  4
      ) .

    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")':u, v-excel-line, 4, v-excel-line, 4) + {&new-line}
      'alignment(3,,,,,,,)':u + {&new-line}
      .

    assign
      v-excel-line = v-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Главный бухгалтер организации:")
      ,input  v-excel-line
      ,input  1
      ) .

    assign
      v-excel-line = v-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text(v-glav-buh)
      ,input  v-excel-line
      ,input  1
      ) .
    run macr_cell_format in this-procedure
      (input 8            /* p-size   */
      ,input false        /* p-bold   */
      ,input true         /* p-italic */
      ,input ?            /* p-color  */
      ,input v-excel-line /* p-row    */
      ,input 1            /* p-col    */
      ,input ?            /* p-row-2  */
      ,input ?            /* p-col-2  */
      ) .
    /* подчеркиваем */
    put stream macr_excel unformatted
      substitute('select("r&1c&2:r&3c&4")':u, v-excel-line, 1, v-excel-line, 4) + {&new-line}
      'row.height(20,,,)':u + {&new-line}
      'border(,,,,1,,,,,,)':u + {&new-line}
      .

    assign
      v-excel-line = v-excel-line + 1
    .
    run macr_excel_char in this-procedure
      (input  format-excel-text("Ф.И.О., подпись")
      ,input  v-excel-line
      ,input  2
      ) .
    run macr_cell_format in this-procedure
      (input 7            /* p-size   */
      ,input false        /* p-bold   */
      ,input true         /* p-italic */
      ,input ?            /* p-color  */
      ,input v-excel-line /* p-row    */
      ,input 2            /* p-col    */
      ,input ?            /* p-row-2  */
      ,input ?            /* p-col-2  */
      ) .

    /* выбираем верхнюю левую ячейку */
    put stream macr_excel unformatted
      'select("r1c1")':u + {&new-line}
      .

    { rep/repfrm.i off }

    output stream macr_excel close .
    run paramls-write in this-procedure
      (input  "file"
      ,input  string(v-file-name-ind)
      ,input  v-file-name
      ) .

    run end-proc in this-procedure .       /* промаргивание */


    run check-new-page in this-procedure
      (input  9
      ) .

    hide stream PrnLibStream frame bottomframe .
    put stream PrnLibStream
      v-line format "X(185)" skip .

    put stream PrnLibStream
      ": " format "x(2)"
      " "                           format "x(14)"
      " : "                         format "x(3)"
      " "                           format "x(14)"
      " : "                         format "x(3)"
      " "                           format "x(8)"
      " : "                         format "x(3)"
      " "                           format "x(40)"
      " : "                         format "x(3)"
      "          ИТОГО"             format "x(15)"
      " : "                         format "x(3)"
      v-total-no-vat-rubl           format "->>>,>>>,>>>.99"
      " : "                         format "x(3)"
      " "                           format "x(4)"
      " : "                         format "x(3)"
      v-total-vat-rubl              format "->>>,>>>,>>>.99"
      " : "                         format "x(3)"
      v-total-acc-rubl              format "->>>,>>>,>>>.99"
      " : "                         format "x(3)"
      " " /* акциз, ставка */       format "x(6)"
      " : "                         format "x(3)"
      " " /* акциз, сумма */        format "x(5)"
      " :"                          format "x(2)"
      skip
      .

    put stream PrnLibStream
      v-line format "X(185)" skip .

    put stream PrnLibStream
      "Руководитель организации (физическое лицо):" skip .

    put stream PrnLibStream
      v-director + fill('_', 60) format "X(60)" skip .

    put stream PrnLibStream
      "                        Ф.И.О., подпись                  М.П." skip .

    put stream PrnLibStream
      "Главный бухгалтер организации" skip .

    put stream PrnLibStream
      v-glav-buh + fill('_', 60) format "X(60)" skip .

    put stream PrnLibStream
      "                        Ф.И.О., подпись" skip .

    output stream PrnLibStream close .

   /* run prn-lib-prn-file in this-procedure ( input my-handle, input 8 ). */
   define variable v-user-action   as character no-undo .
   define variable v-printed       as logical   no-undo .
   define variable DisabledOptions as integer   no-undo .
   define variable v-orient-page as character no-undo .


    run gbl/prnfilen.w
         ( input  ""
         , input  8
         , input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
         , input  ReportFontNum
         , output v-user-action
         , output v-printed
         ) .
   os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE send-records F-Frame-Win  _ADM-SEND-RECORDS
PROCEDURE send-records :
/*------------------------------------------------------------------------------
  Purpose:     Send record ROWID's for all tables used by
               this file.
  Parameters:  see template/snd-head.i
------------------------------------------------------------------------------*/

  /* SEND-RECORDS does nothing because there are no External
     Tables specified for this SmartObject, and there are no
     tables specified in any contained Browse, Query, or Frame. */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setup-excel-sheet F-Frame-Win
PROCEDURE setup-excel-sheet :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input-output parameter p-excel-line as integer   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      p-excel-line = p-excel-line + 1
    .
    /* задать шрифт по умолчанию */
    put stream macr_excel unformatted
      'select("c1:c11")':u + {&new-line}
      'format.font(,8,,)':u + {&new-line}
      .
    /* задать размер страницы и заголовки */
    put stream macr_excel unformatted
      'page.setup(,,0.4,0.4,0.4,0.4,,,,,,,80,,,,,,,,)':u + {&new-line}
      substitute('set.print.titles("r&1:r&2",)':u, p-excel-line, p-excel-line + 2) + {&new-line}
      .

    /* задать ширину колонок */
    run macr_cell_size in this-procedure
      (input  8.5    /* p-w ширина */
      ,input  ?      /* p-l длина  */
      ,input  1      /* p-row      */
      ,input  1      /* p-col      */
      ,input  ?      /* p-row-2    */
      ,input  ?      /* p-col-2    */
      ) .
    run macr_cell_size in this-procedure
      (input  8.5    /* p-w ширина */
      ,input  ?      /* p-l длина  */
      ,input  1      /* p-row      */
      ,input  2      /* p-col      */
      ,input  ?      /* p-row-2    */
      ,input  ?      /* p-col-2    */
      ) .
    run macr_cell_size in this-procedure
      (input  6.5    /* p-w ширина */
      ,input  ?      /* p-l длина  */
      ,input  1      /* p-row      */
      ,input  3      /* p-col      */
      ,input  ?      /* p-row-2    */
      ,input  ?      /* p-col-2    */
      ) .
    run macr_cell_size in this-procedure
      (input  23     /* p-w ширина */
      ,input  ?      /* p-l длина  */
      ,input  1      /* p-row      */
      ,input  4      /* p-col      */
      ,input  ?      /* p-row-2    */
      ,input  ?      /* p-col-2    */
      ) .
    run macr_cell_size in this-procedure
      (input  13     /* p-w ширина */
      ,input  ?      /* p-l длина  */
      ,input  1      /* p-row      */
      ,input  5      /* p-col      */
      ,input  ?      /* p-row-2    */
      ,input  ?      /* p-col-2    */
      ) .
    run macr_cell_size in this-procedure
      (input  10     /* p-w ширина */
      ,input  ?      /* p-l длина  */
      ,input  1      /* p-row      */
      ,input  6      /* p-col      */
      ,input  ?      /* p-row-2    */
      ,input  ?      /* p-col-2    */
      ) .
    run macr_cell_size in this-procedure
      (input  5.5    /* p-w ширина */
      ,input  ?      /* p-l длина  */
      ,input  1      /* p-row      */
      ,input  7      /* p-col      */
      ,input  ?      /* p-row-2    */
      ,input  ?      /* p-col-2    */
      ) .
    run macr_cell_size in this-procedure
      (input  5.5    /* p-w ширина */
      ,input  ?      /* p-l длина  */
      ,input  1      /* p-row      */
      ,input  10     /* p-col      */
      ,input  ?      /* p-row-2    */
      ,input  ?      /* p-col-2    */
      ) .
    run macr_cell_size in this-procedure
      (input  5.5    /* p-w ширина */
      ,input  ?      /* p-l длина  */
      ,input  1      /* p-row      */
      ,input  11     /* p-col      */
      ,input  ?      /* p-row-2    */
      ,input  ?      /* p-col-2    */
      ) .

    /* задать заголовки колонок */
    run macr_cell_format in this-procedure
      (input  8            /* p-size   */
      ,input  false        /* p-bold   */
      ,input  false        /* p-italic */
      ,input  ?            /* p-color  */
      ,input  p-excel-line /* p-row    */
      ,input  1            /* p-col    */
      ,input  p-excel-line /* p-row-2  */
      ,input  11           /* p-col-2  */
      ) .
    run macr_excel_char in this-procedure
      (input  format-excel-text("N п/п")
      ,input  p-excel-line
      ,input  1
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  1            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("N счета-фактуры")
      ,input  p-excel-line
      ,input  2
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  2            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("Дата выписки счета-фактуры")
      ,input  p-excel-line
      ,input  3
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  3            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("Наименование поставщика")
      ,input  p-excel-line
      ,input  4
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  4            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("{&abbr_inn_allshift} поставщика")
      ,input  p-excel-line
      ,input  5
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  5            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("Стоимость поставки без НДС, {&abbr_rubley}")
      ,input  p-excel-line
      ,input  6
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  6            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("НДС")
      ,input  p-excel-line
      ,input  7
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  7            /* p-col   */
      ,input  p-excel-line /* p-row-2 */
      ,input  8            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("Всего стоимость ({&abbr_rubley})")
      ,input  p-excel-line
      ,input  9
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  9            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("Акциз")
      ,input  p-excel-line
      ,input  10
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  10           /* p-col   */
      ,input  p-excel-line /* p-row-2 */
      ,input  11           /* p-col-2 */
      ) .

    assign
      p-excel-line = p-excel-line + 1
    .

    run macr_cell_format in this-procedure
      (input  8            /* p-size   */
      ,input  false        /* p-bold   */
      ,input  false        /* p-italic */
      ,input  ?            /* p-color  */
      ,input  p-excel-line /* p-row    */
      ,input  1            /* p-col    */
      ,input  p-excel-line /* p-row-2  */
      ,input  11           /* p-col-2  */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("")
      ,input  p-excel-line
      ,input  1
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  1            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("")
      ,input  p-excel-line
      ,input  2
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  2            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("")
      ,input  p-excel-line
      ,input  3
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  3            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("")
      ,input  p-excel-line
      ,input  4
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  4            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("")
      ,input  p-excel-line
      ,input  5
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  5            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("")
      ,input  p-excel-line
      ,input  6
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  6            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("Ставка")
      ,input  p-excel-line
      ,input  7
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  7            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("Сумма")
      ,input  p-excel-line
      ,input  8
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  8            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("")
      ,input  p-excel-line
      ,input  9
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  9            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("Ставка")
      ,input  p-excel-line
      ,input  10
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  10           /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("Сумма")
      ,input  p-excel-line
      ,input  11
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  11           /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    assign
      p-excel-line = p-excel-line + 1
    .

    run macr_cell_format in this-procedure
      (input  8            /* p-size   */
      ,input  false        /* p-bold   */
      ,input  true         /* p-italic */
      ,input  ?            /* p-color  */
      ,input  p-excel-line /* p-row    */
      ,input  1            /* p-col    */
      ,input  p-excel-line /* p-row-2  */
      ,input  11           /* p-col-2  */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("1")
      ,input  p-excel-line
      ,input  1
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  1            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("2")
      ,input  p-excel-line
      ,input  2
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  2            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("3")
      ,input  p-excel-line
      ,input  3
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  3            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("4")
      ,input  p-excel-line
      ,input  4
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  4            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("5")
      ,input  p-excel-line
      ,input  5
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  5            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("7")
      ,input  p-excel-line
      ,input  6
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  6            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("8")
      ,input  p-excel-line
      ,input  7
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  7            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("9")
      ,input  p-excel-line
      ,input  8
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  8            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("12")
      ,input  p-excel-line
      ,input  9
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  9            /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("10")
      ,input  p-excel-line
      ,input  10
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  10           /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

    run macr_excel_char in this-procedure
      (input  format-excel-text("11")
      ,input  p-excel-line
      ,input  11
      ) .
    run macr_cell_merge in this-procedure
      (input  p-excel-line /* p-row   */
      ,input  11           /* p-col   */
      ,input  ?            /* p-row-2 */
      ,input  ?            /* p-col-2 */
      ) .

  end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE split-string F-Frame-Win
PROCEDURE split-string :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  define input  parameter p-split-string      as character no-undo .
  define input  parameter p-split-length      as integer   no-undo .
  define output parameter p-address-num-lines as integer   no-undo .
  define output parameter p-start-length-list as character no-undo .

  define variable v-ind as integer   no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-ind = 1
      p-address-num-lines = 0
    .

    do while true
    :
      if v-ind + p-split-length > length(p-split-string)
      then do:
        assign
          p-address-num-lines = p-address-num-lines + 1
          p-start-length-list = p-start-length-list
                              + (if p-start-length-list <> "" then ',':u else '':u)
                              + string(v-ind)
                              + {&comma-char}
                              + string(length(p-split-string) - v-ind + 1)
        .
        leave . /* --->>>--- */
      end.
      else do:
        define variable v-space-index as integer   no-undo .

        assign
          v-space-index = r-index(substring(p-split-string, v-ind, p-split-length), " ")
        .
        if v-space-index = 0
        then do:
          assign
            v-space-index = r-index(substring(p-split-string, v-ind, p-split-length), ",")
          .
        end.
        if v-space-index = 0
        then do:
          assign
            v-space-index = p-split-length
          .
        end.

        assign
          p-address-num-lines = p-address-num-lines + 1
          p-start-length-list = p-start-length-list
                              + (if p-start-length-list <> "" then ',':u else '':u)
                              + string(v-ind)
                              + {&comma-char}
                              + string(v-space-index)
        .
        assign
          v-ind = v-ind + v-space-index
        .
      end.
    end.
  end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE state-changed F-Frame-Win
PROCEDURE state-changed :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
  DEFINE INPUT PARAMETER p-issuer-hdl AS HANDLE NO-UNDO.
  DEFINE INPUT PARAMETER p-state AS CHARACTER NO-UNDO.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME