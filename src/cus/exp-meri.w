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

Экспорт результатов продаж  по поставщику  Заказчика "Мария"

Автор: Румянцев Юрий Александрович
Дата создания: 04/12/06
Author: Yuri Rumyantsev
Creation date: 04/12/06

Формат экспорта:
21/05/2002;4650997494415;3;155.30;1;1093

Описание приведенных полей:
1  - Дата продажи
2  - БК, на которой пробит чек
3  - количество
4  - цена
5  - 1 - продажа , 0 - возврат
6 - код поставщика

*/

/* ***************************  Definitions  ************************** */

/* Parameters Definitions ---                                           */
define input parameter parparentproc as widget-handle no-undo .

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Экспорт результатов продаж".
{ cmp/vssrevis.i }




{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/getcntxt.i def }

define stream txt.

define variable prt-name as char no-undo.
define variable t1 as char no-undo.
define variable ref-list as char no-undo.

define buffer ret-doc for ub.trn-doc.
define variable parts_qnty as dec no-undo.
define variable p-t like ub.doc-line.prod-type no-undo.
define variable p-c like ub.doc-line.prod-code no-undo.
define variable p-a like ub.doc-line.artic no-undo.
define variable b-c like ub.chk-gds.src-code no-undo.
define variable chk-qnty like ub.doc-line.fact-qnty no-undo.
define variable chk-price like ub.doc-line.price-base no-undo.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE DIALOG-BOX
&Scoped-define DB-AWARE no

/* Name of first Frame and/or Browse and/or first Query                 */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS Btn_OK Btn_Cancel b-help date-beg date-End ~
cli-code B-file B-file-2 file-name
&Scoped-Define DISPLAYED-OBJECTS date-beg date-End cli-code cli-name ~
file-name

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-file
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.

DEFINE BUTTON B-file-2
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL ""
     SIZE 3 BY 1.25.

DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1.

DEFINE BUTTON Btn_Cancel AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON Btn_OK AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE cli-code AS INTEGER FORMAT ">>>>>>>>>9":U INITIAL 0
     LABEL "Поставщик"
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.

DEFINE VARIABLE cli-name AS CHARACTER FORMAT "X(25)":U
     VIEW-AS FILL-IN
     SIZE 24.5 BY 1 NO-UNDO.

DEFINE VARIABLE date-beg AS DATE FORMAT "99/99/9999":U
     LABEL "Даты С"
     VIEW-AS FILL-IN
     SIZE 12 BY 1 NO-UNDO.

DEFINE VARIABLE date-End AS DATE FORMAT "99/99/9999":U
     LABEL "По"
     VIEW-AS FILL-IN
     SIZE 11.5 BY 1 NO-UNDO.

DEFINE VARIABLE file-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Файл"
     VIEW-AS FILL-IN
     SIZE 40 BY 1 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
     Btn_OK AT ROW 1 COL 1
     Btn_Cancel AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     date-beg AT ROW 2.75 COL 10.5 COLON-ALIGNED
     date-End AT ROW 2.75 COL 30 COLON-ALIGNED
     cli-code AT ROW 4.25 COL 11.5 COLON-ALIGNED
     cli-name AT ROW 4.25 COL 22 COLON-ALIGNED NO-LABEL
     B-file AT ROW 4.25 COL 48.5
     B-file-2 AT ROW 5.5 COL 48.5
     file-name AT ROW 5.75 COL 2.5
     SPACE(4.62) SKIP(0.62)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Экспорт чеков по поставщику в файл"
         DEFAULT-BUTTON Btn_OK CANCEL-BUTTON Btn_Cancel.


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
                                                                        */
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR FILL-IN cli-name IN FRAME Dialog-Frame
   NO-ENABLE                                                            */
/* SETTINGS FOR FILL-IN file-name IN FRAME Dialog-Frame
   ALIGN-L                                                              */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME





/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame /* Экспорт чеков по поставщику в файл */
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file Dialog-Frame
ON CHOOSE OF B-file IN FRAME Dialog-Frame
DO:
  run ref/cli-all.w (input parparentproc, "b-sel,b-add", ?, ?, ?, ?, ?, ?, output ref-list).
  if ref-list = "" then
    return no-apply.
  /* выбран клиент */
  find ub.clients where recid (ub.clients) = integer (ref-list) no-lock.
  if avail ub.clients then do:
     assign
         cli-code = ub.clients.obj-code
         cli-name = ub.clients.obj-name.
         DISP cli-code cli-name WITH FRAME {&FRAME-NAME}.
  end.
  else     return no-apply.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-file-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-file-2 Dialog-Frame
ON CHOOSE OF B-file-2 IN FRAME Dialog-Frame
DO:

    DEF VAR ll_commit AS LOG    NO-UNDO INIT NO.

    SYSTEM-DIALOG GET-FILE file-name
        TITLE "Выберите файл для экспорта"
        FILTERS
          " Текстовые файлы (*.txt) " "*.txt",
          " Все файлы (*.*) "                      "*.*"
        ask-overwrite
        save-as
        use-filename
        update ll_commit
        default-extension "txt"
        .
    IF ll_commit <> YES THEN do:
       RETURN NO-APPLY.
    end.
    IF file-name = PROGRAM-NAME( 1 ) THEN DO:
        BELL.
        MESSAGE "Рекурсия!" VIEW-AS ALERT-BOX ERROR.
        RETURN NO-APPLY.
    END.
    ASSIGN file-name = ( IF SEARCH( file-name ) = ? THEN file-name ELSE SEARCH( file-name ) ).
    DISP file-name WITH FRAME {&FRAME-NAME}.

END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME Btn_OK
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Btn_OK Dialog-Frame
ON CHOOSE OF Btn_OK IN FRAME Dialog-Frame /* Ввод */
DO:
define buffer buf_inkas for ub.inkas.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_goods for ub.goods.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_parts for ub.parts.
define buffer buf_doc-line for ub.doc-line.
define variable v-gds-code as integer no-undo .
assign
date-beg
date-end
.

if date-beg > date-end then do:
  message
  "Дата начала периода должна быть меньше даты конца"
  view-as alert-box error .
  undo, return no-apply.
end.
if date-beg = ? then do:
  message
  "Не задана дата C"
  view-as alert-box error .
  undo, return no-apply.
end.
if date-end = ? then do:
  message
  "Не задана дата По"
  view-as alert-box error .
  undo, return no-apply.
end.
if trim(file-name) = "" then do:
  message
  "Не задан файл для экспорта"
  view-as alert-box error .
  undo, return no-apply.
end.
output stream txt to value (file-name) no-echo.

FOR EACH buf_inkas no-LOCK where
buf_inkas.doc-date >= date-beg AND
buf_inkas.doc-date <= date-end AND
buf_inkas.obj-type = v-cntxt-obj-type AND
buf_inkas.obj-code = v-cntxt-obj-code AND
buf_inkas.status_ = {&fact}
by buf_inkas.doc-date :
  /*******       Расход     *****************/
  FIND FIRST buf_trn-doc No-LOCK WHERE buf_trn-doc.doc-code = buf_inkas.inkas-code   NO-ERROR.
  if avail buf_trn-doc
  /*and buf_trn-doc.office = no 'nj gjkt e;t yt buhftn*/
  then do:
    assign
    b-c = ""
    chk-price = 0
    chk-qnty = 0
    p-t = ""
    p-c = ?
    p-a = ""
    parts_qnty = 0
    v-gds-code = 0
    .

    FOR  each buf_doc-line NO-LOCk WHERE buf_doc-line.doc-code = buf_trn-doc.doc-code
    by buf_doc-line.prod-type
    by buf_doc-line.prod-code
    by buf_doc-line.artic
    :

  /*message  "*1* "  buf_doc-line.artic  buf_goods.artic. pause.                         */

      display
      buf_doc-line.doc-code
      buf_doc-line.artic
      with frame ff view-as dialog-box
      title ": Экспорт чеков в файл".
      pause 0.


      if p-c <> ? then do:
        if  p-t <> buf_doc-line.prod-type
        or  p-c <> buf_doc-line.prod-code
        or p-a <> buf_doc-line.artic   then do:
          if  parts_qnty <> 0 then do:
            for each buf_CHK-GDS no-lock where
            buf_CHK-GDS.out-code = buf_trn-doc.doc-code   and
            buf_CHK-GDS.doc-qnty <> 0          :
              find buf_bar-code where buf_bar-code.b-code = buf_CHK-GDS.b-code no-lock no-error.
              if not avail buf_bar-code then next.
              if  buf_bar-code.gds-code = v-gds-code then do:
                chk-qnty = chk-qnty + buf_CHK-GDS.doc-qnty.
                chk-price = chk-price + ((buf_CHK-GDS.price-base - buf_CHK-GDS.discnt) * buf_CHK-GDS.doc-qnty).
                b-c = entry(1, buf_CHK-GDS.src-code, {&delim-par}).
              end. /*if buf_bar-code.gds-code = buf_goods.gds-code then do:*/
            end.   /*  for each buf_CHK-GDS no-lock where  */
            if parts_qnty > 0 then do:
              put stream txt unformatted
              trim(string(buf_trn-doc.fact-date, "99/99/9999"))  ";"
              trim(string(b-c)) ";"
              trim(string(parts_qnty)) ";"
              trim(string(chk-price / chk-qnty, "->>>,>>>,>>9.99"))  ";1;"
              trim(string(cli-code)) /*" *1* " buf_goods.artic*/
              skip.
              assign
              b-c = ""
              chk-price = 0
              chk-qnty = 0
              parts_qnty = 0.
            end.  /*  if parts_qnty > 0 then do:  */
          end.    /*    if  parts_qnty <> 0 then do:   */
          assign
          p-t  = buf_doc-line.prod-type
          p-c  = buf_doc-line.prod-code
          p-a  = buf_doc-line.artic
          b-c = ""
          chk-price = 0
          chk-qnty = 0
          parts_qnty = 0.
        end.  /*  if  p-t <> buf_doc-line.prod-type or   */
      end. /*    if p-c <> ? then do:  */
      find buf_goods  where
          buf_goods.prod-type = buf_doc-line.prod-type and
          buf_goods.prod-code = buf_doc-line.prod-code and
          buf_goods.artic         = buf_doc-line.artic no-lock no-error.

      assign
      p-t  = buf_doc-line.prod-type
      p-c  = buf_doc-line.prod-code
      p-a  = buf_doc-line.artic
      b-c = ""
      v-gds-code = buf_goods.gds-code
      chk-price = 0
      chk-qnty = 0
      parts_qnty = 0.
      FOR EACH buf_parts NO-LOCK WHERE
              buf_parts.obj-type  = buf_doc-line.obj-type AND
              buf_parts.obj-code  = buf_doc-line.obj-code AND
              buf_parts.artic        = buf_doc-line.artic AND
              buf_parts.prod-type = buf_doc-line.prod-type AND
              buf_parts.prod-code = buf_doc-line.prod-code AND
              buf_parts.out-code   = buf_doc-line.doc-code
              :

        if buf_parts.supp-code <> cli-code  then next.
        parts_qnty = parts_qnty + buf_parts.fact-qnty.
      end. /* FOR EACH buf_parts NO-LOCK WHERE */
      /*message  "*2* " buf_goods.artic. pause.                         */

      if  parts_qnty <> 0 then do:
        for each buf_CHK-GDS no-lock where
        buf_CHK-GDS.out-code = buf_trn-doc.doc-code and
        buf_CHK-GDS.doc-qnty <> 0
      :
          find buf_bar-code where buf_bar-code.b-code = buf_CHK-GDS.b-code no-lock no-error.
          if not avail buf_bar-code then next.
          if buf_bar-code.gds-code = buf_goods.gds-code then do:
            chk-qnty = chk-qnty + buf_CHK-GDS.doc-qnty.
            chk-price = chk-price + ((buf_CHK-GDS.price-base - buf_CHK-GDS.discnt) * buf_CHK-GDS.doc-qnty).
            b-c = entry(1, buf_CHK-GDS.src-code, {&delim-par}).
          end.
        end.   /*  for each buf_CHK-GDS no-lock where  */
        if parts_qnty > 0 then do:
          put stream txt unformatted
          trim(string(buf_trn-doc.fact-date, "99/99/9999"))  ";"
          trim(string(b-c)) ";"
          trim(string(parts_qnty)) ";"
          trim(string(chk-price / chk-qnty, "->>>,>>>,>>9.99"))  ";1;"
          trim(string(cli-code))   /*" *2*  " buf_goods.artic*/
          skip.
          assign
          b-c = ""
          chk-price = 0
          chk-qnty = 0
          parts_qnty = 0.
        end.  /*  if parts_qnty > 0 then do:  */
      end.    /*    if  parts_qnty <> 0 then do:   */
    end. /* FOR  each buf_doc-line NO-LOCk WHERE buf_doc-line.doc-code = doc-num: */
  end. /*  if buf_trn-doc then do:  */

/**************  Возврат   *****************************/

FIND FIRST ret-doc No-LOCK WHERE ret-doc.doc-code = buf_trn-doc.out-code No-ERROR.
if avail ret-doc
and ret-doc.office = no
then do:
  assign
  b-c = ""
  chk-price = 0
  chk-qnty = 0
  p-t = ""
  p-c = ?
  p-a = ""
  v-gds-code = 0
  .

  FOR  each buf_doc-line NO-LOCk WHERE buf_doc-line.doc-code = ret-doc.doc-code
  by buf_doc-line.prod-type
  by buf_doc-line.prod-code
  by buf_doc-line.artic
  :
    if p-c <> ? then do:
      if  p-t <> buf_doc-line.prod-type
      or  p-c <> buf_doc-line.prod-code
      or p-a <> buf_doc-line.artic   then do:
        if  parts_qnty <> 0 then do:
          for each buf_CHK-GDS no-lock where
              buf_CHK-GDS.out-code = buf_trn-doc.doc-code and
              buf_CHK-GDS.doc-qnty < 0
              :
            find buf_bar-code where buf_bar-code.b-code = buf_CHK-GDS.b-code no-lock no-error.
            if not avail buf_bar-code then next.
            if buf_bar-code.gds-code = buf_goods.gds-code then do:
              chk-qnty = chk-qnty + buf_CHK-GDS.doc-qnty.
              chk-price = chk-price + ((buf_CHK-GDS.price-base - buf_CHK-GDS.discnt) * buf_CHK-GDS.doc-qnty).
              b-c = entry(1, buf_CHK-GDS.src-code, {&delim-par}).
            end.
          end.   /*  for each buf_CHK-GDS no-lock where  */

          if parts_qnty > 0 then do:
            put stream txt unformatted
            trim(string(ret-doc.fact-date, "99/99/9999"))  ";"
            trim(string(b-c)) ";"
            trim(string(parts_qnty)) ";"
            trim(string(chk-price / chk-qnty, "->>>,>>>,>>9.99"))  ";0;"
            trim(string(cli-code))   /*" *3*  " buf_goods.artic*/
            skip.
            assign
            b-c = ""
            chk-price = 0
            chk-qnty = 0
            parts_qnty = 0.
          end.  /*  if parts_qnty > 0 then do:  */
        end.    /*    if  parts_qnty <> 0 then do:   */
        assign
        p-t  = buf_doc-line.prod-type
        p-c  = buf_doc-line.prod-code
        p-a  = buf_doc-line.artic
        parts_qnty = 0.
      end.  /*  if  p-t <> buf_doc-line.prod-type or   */
    end.   /*    if p-c <> ? then do:  */
/*                           else do:*/
    find buf_goods  where
        buf_goods.prod-type = buf_doc-line.prod-type and
        buf_goods.prod-code = buf_doc-line.prod-code and
        buf_goods.artic     = buf_doc-line.artic no-lock no-error.
    assign
    p-t  = buf_doc-line.prod-type
    p-c  = buf_doc-line.prod-code
    p-a  = buf_doc-line.artic
    parts_qnty = 0.
/*                           end.  /*   else do:  */ */
    FOR EACH buf_parts NO-LOCK WHERE
          buf_parts.obj-type  = buf_doc-line.obj-type AND
          buf_parts.obj-code  = buf_doc-line.obj-code AND
          buf_parts.artic     = buf_doc-line.artic AND
          buf_parts.prod-type = buf_doc-line.prod-type AND
          buf_parts.prod-code = buf_doc-line.prod-code AND
          buf_parts.out-code   = buf_doc-line.doc-code
        :

      if buf_parts.supp-code <> cli-code then next.
      parts_qnty = parts_qnty + buf_parts.fact-qnty.
    end. /* FOR EACH parts NO-LOCK WHERE */
  end. /* FOR  each buf_doc-line NO-LOCk WHERE buf_doc-line.doc-code = doc-num: */
  if  parts_qnty <> 0 then do:
    for each buf_CHK-GDS no-lock where
            buf_CHK-GDS.out-code = buf_trn-doc.doc-code and
            buf_CHK-GDS.doc-qnty < 0
        :
      find buf_bar-code where buf_bar-code.b-code = buf_CHK-GDS.b-code no-lock no-error.
      if not avail buf_bar-code then next.
      if buf_bar-code.gds-code = buf_goods.gds-code then do:
        chk-qnty = chk-qnty + buf_CHK-GDS.doc-qnty.
        chk-price = chk-price + ((buf_CHK-GDS.price-base - buf_CHK-GDS.discnt) * buf_CHK-GDS.doc-qnty).
        b-c = entry(1, buf_CHK-GDS.src-code, {&delim-par}).
      end.
    end.   /*  for each buf_CHK-GDS no-lock where  */

    if parts_qnty > 0 then do:
      put stream txt unformatted
      trim(string(buf_trn-doc.fact-date, "99/99/9999"))  ";"
      trim(string(b-c)) ";"
      trim(string(parts_qnty)) ";"
      trim(string(chk-price / chk-qnty, "->>>,>>>,>>9.99"))  ";0;"
      trim(string(cli-code))    /*" *4*  " buf_goods.artic*/
      skip.
      assign
      b-c = ""
      chk-price = 0
      chk-qnty = 0
      parts_qnty = 0.
    end.  /*  if parts_qnty > 0 then do:  */
  end.    /*    if  parts_qnty <> 0 then do:   */
end.  /*  if ret-doc then do:  */

end. /*  FOR EACH buf_inkas no-LOCK where  */

output stream txt close.
message
" Экспорт в файл закончен. "
view-as alert-box information .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME cli-code
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL cli-code Dialog-Frame
ON LEAVE OF cli-code IN FRAME Dialog-Frame /* Поставщик */
DO:
  assign
      cli-code.

  if cli-code <> 0 then do:
       find ub.clients where ub.clients.obj-type = "орг" and
             ub.clients.obj-code = cli-code
       no-lock no-error.
       if avail ub.clients then do:
          assign
              cli-code = ub.clients.obj-code
              cli-name = ub.clients.obj-name.
              DISP cli-code cli-name WITH FRAME {&FRAME-NAME}.
       end.
       else  do:
             message "Такой поставщик не существует !!!!!!!!!!!!!!!!!!!!!!!!!!"
             view-as alert-box ERROR.
             assign
                 cli-code = 0
                 cli-name = "".
             return no-apply.
       end.
  end. /* if cli-code <> 0 or cli-code <> ? then do: */
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME file-name
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL file-name Dialog-Frame
ON LEAVE OF file-name IN FRAME Dialog-Frame /* Файл */
DO:
    ASSIGN file-name.
    IF SEARCH( file-name ) <> ? AND SEARCH( file-name ) <> "":U THEN DO:
        ASSIGN FILE-INFO:FILE-NAME = file-name.
        IF FILE-INFO:FULL-PATHNAME <> ? THEN ASSIGN file-name = FILE-INFO:FULL-PATHNAME.

        DISP file-name WITH FRAME {&FRAME-NAME}.
    END.
    APPLY "TAB":U TO file-name IN FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }

/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 { gbl/getcntxt.i get }
  if v-cntxt-obj-type <> {&shop} then do:
    message "Текущий объект не МАГАЗИН!"
    view-as alert-box ERROR.
    BELL.
    undo, return error.
  end.
  date-beg = today.
  date-end = today.
  assign
  date-beg
  date-end.
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
  DISPLAY date-beg date-End cli-code cli-name file-name
      WITH FRAME Dialog-Frame.
  ENABLE Btn_OK Btn_Cancel b-help date-beg date-End cli-code B-file B-file-2
         file-name
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME