&ANALYZE-SUSPEND _VERSION-NUMBER UIB_v9r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame
/*------------------------------------------------------------------------

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Комплексный импорт остатков из Trade

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

------------------------------------------------------------------------*/

define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Импрот приходных накладных из Trade".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/showinf.i }
{ gbl/filelist.i }
{ str/doc-code.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/gds-list.i gds-list def }
{ gbl/getcntxt.i def }
{ str/getctxtp.i def }
{ gbl/waitfram.i }


/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */

/* Local Variable Definitions ---                                       */
DEFINE STREAM str-err.
DEFINE TEMP-TABLE tt-trn-doc NO-UNDO LIKE ub.trn-doc.
{ str/lib-def.i }
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-base-code like ub.sysconf.base-code no-undo .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-calc b-help vardir
&Scoped-Define DISPLAYED-OBJECTS vardir

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON b-calc
     LABEL "&Расчет"
     SIZE 10 BY 1.

DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE vardir AS CHARACTER FORMAT "X(256)":U
     LABEL "Директория"
     VIEW-AS FILL-IN
     SIZE 50 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-calc AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     vardir AT ROW 2.5 COL 12 COLON-ALIGNED
     SPACE(1.12) SKIP(0.37)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Импорт внешних приходов Trade -> Trade House"
         DEFAULT-BUTTON b-exit.


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Импорт внешних приходов Trade -> Trade House */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-calc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-calc Dialog-Frame
ON CHOOSE OF b-calc IN FRAME Dialog-Frame /* Расчет */
DO:
  define buffer bf_temp-filelist     for temp-filelist .
  Define Buffer Bf-obj_Clients       For Ub.Clients.
  Define Buffer Bf_Clients           For Ub.Clients.
  Define Buffer Bf_Trn-doc           For Ub.Trn-doc.
  define buffer bf-imp_trn-doc       for ub.trn-doc.
  define buffer bf-imp_doc-line      for ub.doc-line.
  define buffer bf-imp_doc-line-attr for ub.doc-line-attr.
  define buffer bf-imp_gds-dtl       for ub.gds-dtl.
  define buffer bf-imp_parts         for ub.parts.
  DEFINE BUFFER bf_curr-accnt     FOR ub.curr-accnt.
  DEFINE VARIABLE varcli-code LIKE ub.clients.obj-code.
  DEFINE VARIABLE vardoc-code LIKE ub.trn-doc.doc-code.
  DEFINE VARIABLE vartoday    AS   DATE.
  FIND FIRST bf-obj_clients WHERE bf-obj_clients.obj-type = v-cntxt-obj-type AND
                                  bf-obj_clients.obj-code = v-cntxt-obj-code NO-LOCK NO-ERROR.
  IF NOT AVAILABLE bf-obj_clients THEN DO:
    MESSAGE "Не найден объект " v-cntxt-obj-type v-cntxt-obj-code "." SKIP
            "Утилита должна запускаться из окна администратора, с предустановленым текущим объектом в Trade House."
    VIEW-AS ALERT-BOX ERROR.
    RETURN NO-APPLY.
  END.
  ASSIGN FRAME {&FRAME-NAME} vardir.
  OUTPUT STREAM str-err TO VALUE(vardir + "/err.txt").
  RUN filelist-init IN THIS-PROCEDURE
     (vardir,
      YES,
      "adb",
      ?).
  FOR EACH bf_temp-filelist ON ERROR UNDO, RETURN NO-APPLY :
    IF SUBSTRING(bf_temp-filelist.file-name, 1, 1) <> "p" THEN DO:
      PUT STREAM str-err UNFORMATTED "Пропускаем файл " bf_temp-filelist.FILE-NAME " из-за некорректного имени." SKIP.
      NEXT.
    END.
    ASSIGN
      varcli-code = INTEGER(SUBSTRING(bf_temp-filelist.file-name-no-ext, 2)) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN DO:
      PUT STREAM str-err UNFORMATTED "Пропускаем файл " bf_temp-filelist.FILE-NAME " из-за некорректного имени." SKIP.
      NEXT.
    END.
    FIND FIRST bf_clients WHERE bf_clients.obj-type = {&cmp} AND
                                bf_clients.obj-code = varcli-code NO-LOCK NO-ERROR.
    IF NOT AVAILABLE bf_clients THEN DO:
      PUT STREAM str-err UNFORMATTED "Пропускаем файл " bf_temp-filelist.FILE-NAME " . Клиент " VARcli-code " не найден в системе." SKIP.
      NEXT.
    END.
    DO TRANSACTION ON ERROR UNDO, RETURN NO-APPLY :
      RUN doc-code IN THIS-PROCEDURE (
          "main":u,
          bf-obj_clients.obj-type,
          bf-obj_clients.obj-code,
          ?,
          output vardoc-code ).
      { gbl/curobjdt.i
        bf-obj_clients.obj-type
        bf-obj_clients.obj-code
        vartoday
      }
      find last bf_curr-accnt no-lock
        where bf_curr-accnt.curr-code = v-base-code
          and bf_curr-accnt.exch-date <= vartoday
      use-index pi no-error.
      { str/crtrndoc.i
        ?
        ?
        bf_curr-accnt.exch-rate
        bf_curr-accnt.exch-scale
        bf_clients.obj-code
        {&cmp}
        bf_clients.obj-name
        v-cntxt-db-num
        v-cntxt-userid
        "' '"
        vardoc-code
        vartoday
        {&income}
        no
        bf-obj_clients.host-code
        no
        bf-obj_clients.obj-code
        bf-obj_clients.obj-type
        no
        v-cntxp-in-pay
        "'@ Импортировано из TRADE'"
        no
        "{&without-SLT}"
        {&wayb}
        "{&inc-VAT}"
        {&TDEDT_Pri_Vnesh}
        {&bef-repayment-code}
        no-error
      }
      if error-status:error then do:
        PUT STREAM str-err UNFORMATTED "Ошибка при создании документа по файлу " bf_temp-filelist.FILE-NAME " : " return-value "." SKIP.
        NEXT.
      end.
      find first bf_trn-doc where bf_trn-doc.doc-code = vardoc-code .
      assign
          bf_trn-doc.exch-date    = bf_trn-doc.doc-date
          bf_trn-doc.exch-code    = 0
          bf_trn-doc.exch-rate    = 1
          bf_trn-doc.exch-scale   = 1
          bf_trn-doc.print-rubl   = yes
          bf_trn-doc.ret-supp     = no.
      assign
        vartemp-doc-code = "import-" + bf_trn-doc.doc-code.
      run utl/imp-all.p (parparentproc, 2, bf_temp-filelist.full-name, "1251", bf_trn-doc.exch-code, vartemp-doc-code, bf_trn-doc.cli-type, bf_trn-doc.cli-code, bf_trn-doc.host-code) no-error.
      if error-status:error then do:
        PUT STREAM str-err UNFORMATTED "Ошибка при копировании в документ по файлу " bf_temp-filelist.FILE-NAME " : " return-value "." SKIP.
        NEXT.
      end.
      find first bf-imp_trn-doc where bf-imp_trn-doc.doc-code = vartemp-doc-code.
      for each lib-trn_ret-doc       : delete lib-trn_ret-doc       . end.
      for each lib-trn_ret-line      : delete lib-trn_ret-line      . end.
      for each lib-trn_ret-line-attr : delete lib-trn_ret-line-attr . end.
      for each lib-trn_ret-dtl       : delete lib-trn_ret-dtl       . end.
      for each lib-trn_ret-parts     : delete lib-trn_ret-parts     . end.

      create lib-trn_ret-doc.
      buffer-copy bf-imp_trn-doc to lib-trn_ret-doc.
      for each bf-imp_doc-line where bf-imp_doc-line.doc-code = bf-imp_trn-doc.doc-code on error undo, return no-apply :
        create lib-trn_ret-line.
        buffer-copy bf-imp_doc-line to lib-trn_ret-line.
      end.
      for each bf-imp_doc-line-attr where bf-imp_doc-line-attr.doc-code = bf-imp_trn-doc.doc-code on error undo, return no-apply :
        create lib-trn_ret-line-attr.
        buffer-copy bf-imp_doc-line-attr to lib-trn_ret-line-attr.
      end.
      for each bf-imp_gds-dtl where bf-imp_gds-dtl.doc-code = bf-imp_trn-doc.doc-code on error undo, return no-apply :
        create lib-trn_ret-dtl.
        buffer-copy bf-imp_gds-dtl to lib-trn_ret-dtl.
      end.
      for each bf-imp_parts where bf-imp_parts.out-code = bf-imp_trn-doc.doc-code on error undo, return no-apply :
        create lib-trn_ret-parts.
        buffer-copy bf-imp_parts to lib-trn_ret-parts.
      end.
      delete bf-imp_trn-doc.
      { str/copy-in.i
        parparentproc
        recid(bf_trn-doc)
        lib-trn_ret-doc
        lib-trn_ret-line
        lib-trn_ret-line-attr
        lib-trn_ret-dtl
        lib-trn_ret-parts
        no
        no
        no
        yes
        this-procedure
        no-error
      }
      if error-status:error then do:
        message error-status:error return-value error-status:get-message(1) error-status:get-message(2) view-as alert-box.
        PUT STREAM str-err UNFORMATTED "Ошибка при копировании в документ " bf_trn-doc.doc-code " : " return-value "." SKIP.
        NEXT.
      end.
      create tt-trn-doc.
      buffer-copy bf_trn-doc to tt-trn-doc.
    END.
  END.
  define variable varlog as logical no-undo initial yes.
  message "Вы хотите закрыть документы на факт?" view-as alert-box question buttons yes-no update varlog.
  if varlog = yes then do:
    for each tt-trn-doc on error undo, return no-apply :
      find first bf_trn-doc where bf_trn-doc.doc-code = tt-trn-doc.doc-code .
      assign
        bf_trn-doc.tot-cli = bf_trn-doc.tot-calc.
      define variable varwas-moving as logical no-undo.
      run str/trn-stat.p (
            input parparentproc
          ,  input this-procedure
          , input {&close-fact}
          , input bf_trn-doc.doc-code
          , input no
          , input v-cntxt-db-num
          , input v-cntxp-in-ov
          , input v-cntxp-rsrv-time
          , input v-cntxp-load-time
          , input v-cntxp-holidays
          , input yes
          , output varwas-moving
          , output table gds-list
      ) no-error.
      if error-status:error then do:
        put stream str-err unformatted "Ошибка при закрытии документа " bf_trn-doc.doc-code " по файлу " bf_temp-filelist.file-name " : " return-value "." skip.
        next.
      end.
    end.
  end.

  OUTPUT STREAM str-err CLOSE.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-help
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-help Dialog-Frame
ON CHOOSE OF b-help IN FRAME Dialog-Frame /* Помощь */
OR HELP OF FRAME {&FRAME-NAME}
DO: /* Call Help Function (or a simple message). */
  MESSAGE "Help for File: {&FILE-NAME}" VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
{ gbl/app_help.i }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  { gbl/getcntxt.i get }
  { str/getctxtp.i get }
  { gbl/basecode.i v-cntxt-host-code-obj v-base-code }
  RUN enable_UI.
  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
RUN disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

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
  DISPLAY vardir
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-calc b-help vardir
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME