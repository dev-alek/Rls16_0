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

Сканирование 2D кода. Автоматическое заполнение накладной.

Автор: Морозов Александр Сергеевич
Дата создания: 08/08/2021
Author: Alexandr Morozov
Creation date: 08/08/2021

*/
&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DECLARATIONS Procedure

using ibs.th.str.ptrl.autotrn.*.
using ibs.th.str.*.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Сканирование 2D кода. Автоматическое заполнение накладной.". 
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i  }
{ str/trdcalib.i }
{ gbl/getcntxt.i def }

          /* Parameters Definitions ---                                           */

define input  parameter parparentproc         as handle              no-undo .
define input  parameter p-doc-code            as character           no-undo .
define input  parameter p-mode                as character           no-undo .
define input  parameter p-handle              as handle              no-undo .

define variable iLang           as integer   no-undo.
define variable p-value-logical as logical no-undo.
define variable p-value-character  as character no-undo.
define variable p-value-date       as date no-undo.
define variable p-value-decimal    as decimal no-undo.
define variable p-value-integer    as integer no-undo.
define variable p-param-type       as character no-undo.
define variable v-tth as handle no-undo .



define variable par-type          as character no-undo .
define variable v-value-char      as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable qr-scan-time      as integer   no-undo .
define variable v-value-logical   as logical   no-undo .

define buffer t_doc        for ub.trn-doc .
define buffer bf_doc-line  for ub.doc-line.
define variable v-timedelay  as integer   no-undo.
define variable v-scan-str as character no-undo.

define stream str-err .
define stream in-stream.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS b-exit b-cancel v-mark  v-sts 
&Scoped-Define DISPLAYED-OBJECTS v-sts 

/* Custom List Definitions                                              */
/* List-1,List-2,List-3,List-4,List-5,List-6                            */

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME

{ cmp/str-glbl.i }
{ utl/crc32.i }

/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */

define button b-exit auto-go 
     label "&Отмена" 
     size 10 by 1
     bgcolor 8 .

define variable v-sts as character format "X(256)":U init "ожидание сканирования" 
     label "Статус" 
     view-as fill-in 
     size 76 by 1 no-undo.

DEFINE VARIABLE v-mark AS CHARACTER FORMAT "X(31000)":U 
  LABEL "Марка" 
  VIEW-AS FILL-IN 
  SIZE 76 BY 1 
  BGCOLOR 15 NO-UNDO.

/* ************************  Frame Definitions  *********************** */

define frame Dialog-Frame
     b-exit at row 1 col 1
     v-mark at row 2.3 col 5 no-label
     v-sts at row 3.5 col 7.5 colon-aligned
     space(2) skip(0.1)
    with view-as dialog-box keep-tab-order 
         side-labels no-underline three-d  scrollable 
         title "Сканирование 2D кода. Автоматическое заполнение накладной."
         default-button b-exit .


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
   FRAME-NAME                                                           */
assign 
       frame Dialog-Frame:SCROLLABLE       = false
       frame Dialog-Frame:HIDDEN           = true.

/* SETTINGS FOR FILL-IN f-msg IN FRAME Dialog-Frame
   NO-ENABLE ALIGN-L                                                    */
/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
on window-close of frame Dialog-Frame
do:
  APPLY "END-ERROR":U TO SELF.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*&Scoped-define SELF-NAME b-exit                              */
/*&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame*/
/*on choose of b-exit in frame Dialog-Frame /* Ввод */         */
/*do:                                                          */
/*                                                             */
/*end.                                                         */
/*                                                             */
/*/* _UIB-CODE-BLOCK-END */                                    */
/*&ANALYZE-RESUME                                              */

&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL b-exit Dialog-Frame
on return of b-exit in frame Dialog-Frame /* Ввод */
do:
  run save_update .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&Scoped-define SELF-NAME v-sts
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-sts Dialog-Frame
on entry of v-sts in frame Dialog-Frame
do:
  run LoadKeyboardLayoutA (input "00000419", input 0, output iLang).
      run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type /*p-obj-type*/
               ,input  v-cntxt-obj-code /*p-obj-code*/
               ,input  {&attr-marking}
               ,input  {&attr-marking_rus-key} /*p-param-code*/
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error . 
      IF p-value-logical = yes THEN  iLang = 68748313.

  run ActivateKeyboardLayout (input iLang, input 0).
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME b-exit
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL UUID_VSD Dialog-Frame
on any-printable of v-mark in frame Dialog-Frame
do:
  run proc-any-key.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-sts Dialog-Frame
on return of v-mark in frame Dialog-Frame /* Марка */
do:
  run save_update .
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME v-mark
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON ENTRY OF v-mark IN FRAME Dialog-Frame /* Марка */
DO:
  run LoadKeyboardLayoutA (input "00000419", input 0, output iLang).
      run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type /*p-obj-type*/
               ,input  v-cntxt-obj-code /*p-obj-code*/
               ,input  {&attr-marking}
               ,input  {&attr-marking_rus-key} /*p-param-code*/
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error . 
      IF p-value-logical = yes THEN  iLang = 68748313.

  run ActivateKeyboardLayout (input iLang, input 0).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL v-mark Dialog-Frame
ON LEAVE OF v-mark IN FRAME Dialog-Frame /* Марка */
DO:
  assign frame {&frame-name} v-mark .
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
if valid-handle(active-window) and frame {&FRAME-NAME}:PARENT eq ?
  then frame {&FRAME-NAME}:PARENT = active-window.


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
MAIN-BLOCK:
do on error undo MAIN-BLOCK, leave MAIN-BLOCK
  :
  run LoadKeyboardLayoutA (input "00000419", input 0, output iLang).
      run adm/shattri.p (
               input "get":U
               ,input  v-cntxt-obj-type /*p-obj-type*/
               ,input  v-cntxt-obj-code /*p-obj-code*/
               ,input  {&attr-marking}
               ,input  {&attr-marking_rus-key} /*p-param-code*/
               ,output p-value-character
               ,output p-value-date
               ,output p-value-decimal
               ,output p-value-integer
               ,output p-value-logical
               ,output p-param-type
               ,input-output table-handle v-tth
               ) no-error . 
      IF p-value-logical = yes THEN  iLang = 68748313.

  run ActivateKeyboardLayout (input iLang, input 0).
  run enable_UI.
  
  find first t_doc no-lock where t_doc.doc-code = p-doc-code no-error . 
  
  run adm/shattri.p (
             input "get":U
            ,input  t_doc.obj-type
            ,input  t_doc.obj-code
            ,input  {&attr-petrol}
            ,input  {&attr-petrol_qr-scan-time} /*p-param-code*/
            ,output v-value-char
            ,output v-value-date
            ,output v-value-decimal
            ,output qr-scan-time
            ,output v-value-logical
            ,output par-type
            ,input-output table-handle v-tth
            ) no-error .
  if error-status:error then do:
      if valid-handle(v-tth) then delete object v-tth.
      qr-scan-time = 5000 .
  end.
  
  apply "entry" to v-mark in frame {&FRAME-NAME}.
  v-mark:READ-ONLY IN FRAME {&frame-name}       = TRUE .
  
  disable v-sts with frame {&frame-name}.
  
  wait-for go of frame {&FRAME-NAME}.
end.
run disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE ActivateKeyboardLayout Dialog-Frame 
procedure ActivateKeyboardLayout external 'user32' :
  define input parameter P1 as long.
  define input parameter P2 as long.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
procedure disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  hide frame Dialog-Frame.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE dispmessage Dialog-Frame 
procedure dispmessage :
define input parameter p-str as character no-undo.
  
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
procedure enable_UI :
/*------------------------------------------------------------------------------
  Purpose:     ENABLE the User Interface
  Parameters:  <none>
  Notes:       Here we display/view/enable the widgets in the
               user-interface.  In addition, OPEN all queries
               associated with each FRAME and BROWSE.
               These statements here are based on the "Other 
               Settings" section of the widget Property Sheets.
------------------------------------------------------------------------------*/
  display v-sts v-mark b-exit 
      with frame Dialog-Frame.
  enable b-exit v-mark
      with frame Dialog-Frame.
  view frame Dialog-Frame.
  {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE LoadKeyboardLayoutA Dialog-Frame 
procedure LoadKeyboardLayoutA external 'user32':
  define input  parameter P1 as char.
  define input  parameter P2 as long.
  define return parameter pret as long.
end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save_update Dialog-Frame 
procedure save_update :
  
  define variable v-xmlfile as char no-undo .
  define variable v-ok as logical no-undo .
  define variable xmlhndlerObj as class xmlhndler no-undo .
  define variable v-tmp-int as int no-undo .
  define variable v-tmp-char as character no-undo .
  define variable v-tmp-char2 as character no-undo .
  define variable v-tmp-date as date no-undo .
  define variable v-gdsrec-list as char no-undo .
  define variable v-gd-cd as integer no-undo .
  define variable v-cli-code as character no-undo .
  define variable v-bad-symb as character no-undo .
  define variable v-json-str as character no-undo.
  define variable v-ix as integer no-undo.
  define variable v-crc as char no-undo.
  define variable ii as integer no-undo .
  define variable byte1 as character no-undo .
  define variable byte2 as character no-undo .
  define variable v-asc-symb as int64 no-undo .
  define variable mData as memptr no-undo .
  define variable tmpstr as character no-undo .
  define variable v-length as integer no-undo .
  define variable byte-size as integer no-undo .
  define variable infoSecsObj as class InfoSectionsTotal no-undo.
  define variable v-bool as logical no-undo.
  define variable v-gds-attr as character no-undo .
  
  define buffer buf_goods for ub.goods .
  define buffer buf_pl-gds for ub.pl-gds .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_doc-line-attr for ub.doc-line-attr .
  define buffer buf_auto-tank for ub.auto-tank .
  
  v-bad-symb = '!' + {&delim-par} + '@' + {&delim-par} + '#' + {&delim-par} + '$' + {&delim-par} + '%' + {&delim-par} + '^' + {&delim-par} + '&' + {&delim-par}
             + '*' + {&delim-par} + '(' + {&delim-par} + ')' + {&delim-par} + '-' + {&delim-par} + '_' + {&delim-par} + '=' + {&delim-par} + '+' + {&delim-par} 
             + '.' + {&delim-par} + ',' + {&delim-par} + '/' + {&delim-par} + '|' + {&delim-par} + '\' + {&delim-par} + '?' + {&delim-par} + '"' + {&delim-par}
             + ';' + {&delim-par} + ':' + {&delim-par} + '[' + {&delim-par} + ']' + {&delim-par} + chr(123) + {&delim-par} + '}' + {&delim-par}
             + '`' + {&delim-par} + '№' + {&delim-par} + ' ' + {&delim-par} + "'" + {&delim-par} + "RUS" .
             
  
  if v-mark:screen-value in frame {&frame-name} = ""
  then do:
    v-length = LENGTH(v-scan-str, 'raw').
    if v-length = 0
    then return .
    set-size(mData) = 0. 
    set-size(mData) = v-length.
    PUT-STRING(mData, 1, v-length) = v-scan-str.
    byte-size = GET-SIZE(mData).
    
    DO ii = 1 TO byte-size:
      v-asc-symb = GET-BYTE(mData, ii).
      byte1 = intToHex(v-asc-symb) .
      if byte2 = "d0" and byte1 = "3f"
      then do : 
        tmpstr = substring(tmpstr, 1, length(tmpstr) - 1) no-error .
        tmpstr = tmpstr + CHR(38) + CHR(36) no-error .
      end .
      else do :
        tmpstr = tmpstr + CHR(v-asc-symb) no-error .
      end .
      byte2 = intToHex(v-asc-symb) .
    END.
    set-size(mData) = 0.
    tmpstr = codepage-convert(tmpstr, "1251", "UTF-8") .
    tmpstr = replace(tmpstr, "&$", "И") .
    v-mark:screen-value in frame {&frame-name} = tmpstr .
    v-scan-str = "".
  end.
  
  v-json-str = v-mark:screen-value .
  v-scan-str = "".
  
  if trim(v-json-str) = ""
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message "Ошибка сканирования! Попробуйте увеличить время на сканирование QR-кода в настройках по топливу." view-as alert-box .
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    return .
  end . 
  
  if v-json-str begins (CHR(123) + "@data@^")
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message "Ошибка сканирования!" skip "Убедитесь, что установлена русская раскладка клавиатуры." view-as alert-box .
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    return .
  end .
  
  v-ix = index (v-json-str, ',"CRC":"').
  v-crc = substring (v-json-str, v-ix + 8, 8).
  v-json-str = substring (v-json-str, 9, v-ix - 9).
  v-json-str = codepage-convert(v-json-str, "UTF-8", "1251") .

  run checkcrc (input v-json-str, input v-crc, output v-ok).
  if not v-ok
  then do:
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message "Контрольная сумма не соответствует содержанию штрих-кода. Повторно просканируйте код с ТТН. При возникновении проблемы обратитесь в тех. поддержку" view-as alert-box .
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    return .
  end.
        
  assign v-mark = v-mark:screen-value .
 
  if trim(v-mark) = "" then return .
  
  run checkJson (input v-mark, output v-ok) .
  if not v-ok
  then do:
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message "Некорректный формат штрих-кода. Повторно просканируйте код с ТТН. При возникновении проблемы обратитесь в тех. поддержку" view-as alert-box .
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    undo, return.
  end.
  
  run parse2DCodeToXML (input v-mark, output v-xmlfile) no-error.
  if error-status:error
  then do:
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    undo, return.
  end.
  infoSecsObj = new ibs.th.str.InfoSectionsTotal().
    
  xmlhndlerObj = new xmlhndler().
  
  xmlhndlerObj:FillDataset(input search (v-xmlfile)) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message xmlhndlerObj:ErrMsg view-as alert-box.
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    undo, return error .
  end .

  v-ok = xmlhndlerObj:GetFirst("doc") no-error.
  if not v-ok
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message xmlhndlerObj:ErrMsg view-as alert-box.
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    undo, return error .
  end .  

  v-cli-code =  (xmlhndlerObj:vbf:buffer-field("contr-cd"):buffer-value) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message error-status:get-message (1) view-as alert-box.
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    undo, return error .
  end .
  else do:
    v-tmp-int = integer(v-cli-code) no-error .
    for first ub.clients-attr no-lock where ub.clients-attr.obj-type = {&cmp}
                                        and ub.clients-attr.attr-code = {&attr-code-KSK}
                                        and (ub.clients-attr.attr-value = v-cli-code
                                        or ub.clients-attr.attr-value = string(v-tmp-int))
                                        :
      v-tmp-int = ub.clients-attr.obj-code .                                    
    end .
    if v-tmp-int = 0 
    or v-tmp-int = ?
    then do :
      v-mark:screen-value = "" .
      v-scan-str = "".
      v-mark = "".
      message "Ошибка установки поставщика. Не найден поставщик с кодом " v-cli-code ". Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса" skip return-value view-as alert-box.  
      v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
      undo, return error .
    end .
    find first ub.clients no-lock where ub.clients.obj-type = {&cmp}
                                    and ub.clients.obj-code = v-tmp-int
                                    no-error .
    if not available ub.clients
    then do :
      v-mark:screen-value = "" .
      v-scan-str = "".
      v-mark = "".
      message "Отсутствует поставщик с кодом " v-cli-code ". Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса" view-as alert-box.
      v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .  
      undo, return error .
    end .
    else do :
      if ub.clients.stts <> {&bef-current-status-int}
      then do :
        v-mark:screen-value = "" .
        v-scan-str = "".
        v-mark = "".
        message "Поставщик с кодом " v-cli-code " неактивный (Удалён). Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса"  view-as alert-box.
        v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .  
        undo, return error .
      end .
/*      find first ub.clients-attr no-lock where ub.clients-attr.obj-type = ub.clients.obj-type                                                */
/*                                           and ub.clients-attr.obj-code = ub.clients.obj-code                                                */
/*                                           and (ub.clients-attr.attr-code = {&attr-supp-np} or ub.clients-attr.attr-code = {&attr-supp-lgas})*/
/*                                           and logical(ub.clients-attr.attr-value) = yes                                                     */
/*                                           no-error .                                                                                        */
/*      if not available ub.clients-attr                                                                                                       */
/*      then do :                                                                                                                              */
/*        message "Поставщик с кодом " v-cli-code " не является поставщиком НП/СУГ"  view-as alert-box.                                        */
/*        undo, return error .                                                                                                                 */
/*      end .                                                                                                                                  */
      run set-cli-cust in p-handle (input {&cmp}, input v-tmp-int) no-error.
    end .
  end.
  
  v-tmp-char =  (xmlhndlerObj:vbf:buffer-field("doc-num"):buffer-value) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message error-status:get-message (1) view-as alert-box.
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    undo, return error .
  end .
  else do:
    { str/tdat-wrt.i
        t_doc.doc-code
        {&trdcattr-nids}
        v-tmp-char
        no-error
    }
  end.
  
  v-tmp-char =  (xmlhndlerObj:vbf:buffer-field("doc-date"):buffer-value) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message error-status:get-message (1) view-as alert-box.
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    undo, return error .
  end .
  else do:
    if trim(v-tmp-char) = ""
    then do :
      v-mark:screen-value = "" .
      v-scan-str = "".
      v-mark = "".
      message "В накладной не указана дата документа. Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса"  view-as alert-box.
      v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
      undo, return error .
    end .
    v-tmp-date = date( entry(3, v-tmp-char, "-") + "/" + entry(2, v-tmp-char, "-") + "/" + entry(1, v-tmp-char, "-") ) no-error .
    if v-tmp-date = ?
    then do :
      v-mark:screen-value = "" .
      v-scan-str = "".
      v-mark = "".
      message "В накладной неверно указана дата документа. Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса"  view-as alert-box.
      v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
      undo, return error .
    end .
    { str/tdat-wrt.i
        t_doc.doc-code
        {&trdcattr-dids}
        string(v-tmp-date)
        no-error
    }
  end.
  
  v-ok = xmlhndlerObj:GetFirst("transp") no-error.
  if not v-ok
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message xmlhndlerObj:ErrMsg view-as alert-box.
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    undo, return error .
  end .
    
  v-cli-code =  (xmlhndlerObj:vbf:buffer-field("nb-cd"):buffer-value) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message error-status:get-message (1) view-as alert-box.
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    undo, return error .
  end .
  else do:
    v-tmp-int = integer(v-cli-code) no-error .
    for first ub.clients-attr no-lock where ub.clients-attr.obj-type = {&cmp}
                                        and ub.clients-attr.attr-code = {&attr-code-AIS}
                                        and (ub.clients-attr.attr-value = v-cli-code
                                        or ub.clients-attr.attr-value = string(v-tmp-int))
                                        :
      v-tmp-int = ub.clients-attr.obj-code .                                    
    end .
    find first ub.clients no-lock where ub.clients.obj-type = {&cmp}
                                    and ub.clients.obj-code = v-tmp-int
                                    no-error .
    if not available ub.clients
    then do :
      v-mark:screen-value = "" .
      v-scan-str = "".
      v-mark = "".
      message "Отсутствует нефтебаза с кодом " v-cli-code ". Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса"  view-as alert-box.  
      v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
      undo, return error .
    end .
    else do :
      if ub.clients.stts <> {&bef-current-status-int}
      then do :
        v-mark:screen-value = "" .
        v-scan-str = "".
        v-mark = "".
        message "Нефтебаза с кодом " v-cli-code " неактивна (Удалена). Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса"  view-as alert-box.
        v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .  
        undo, return error .
      end .
      v-tmp-char = {&cmp} + ";" + string(v-tmp-int) .
      { str/tdat-wrt.i
          t_doc.doc-code
          {&trdcattr-ptbobj}
          v-tmp-char
          no-error
      }
    end .
  end.
  
  define variable v-auto-num as character no-undo .
  define variable v-found-trans as logical no-undo .
    
  v-tmp-char =  (xmlhndlerObj:vbf:buffer-field("transp-num"):buffer-value) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message error-status:get-message (1) view-as alert-box.
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    undo, return error .
  end .
  else do:
    do ii = 1 to num-entries(v-bad-symb, {&delim-par}) :
      v-tmp-char = replace(v-tmp-char, entry(ii, v-bad-symb, {&delim-par}), "") .
    end .
    v-found-trans = no .
    for each ub.auto-tank no-lock where ub.auto-tank.status_ = {&current-status} :
      v-auto-num = ub.auto-tank.auto-num . 
      do ii = 1 to num-entries(v-bad-symb, {&delim-par}) :
        v-auto-num = replace(v-auto-num, entry(ii, v-bad-symb, {&delim-par}), "") .
      end .
      if v-auto-num = v-tmp-char
      then do :
        v-found-trans = true .
        leave .
      end .
    end .                              
    if not v-found-trans
    then do :
      v-mark:screen-value = "" .
      v-scan-str = "".
      v-mark = "".
      message "Отсутствует автоцистерна с гос. номером " v-tmp-char ". Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса" view-as alert-box.  
      v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
      undo, return error .
    end .
    else do :
      infoSecsObj:CarNum = ub.auto-tank.auto-num .
      { str/tdat-wrt.i
          t_doc.doc-code
          {&trdcattr-car-num}
          ub.auto-tank.auto-num
          no-error
      }
      v-tmp-char2 = ub.auto-tank.firm-type + ";" + string(ub.auto-tank.firm-code) .
      { str/tdat-wrt.i
          t_doc.doc-code
          {&trdcattr-autoent}
          v-tmp-char2
          no-error
      }
    end .
  end.  
  
  v-tmp-char =  (xmlhndlerObj:vbf:buffer-field("driv"):buffer-value) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message error-status:get-message (1) view-as alert-box.
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    undo, return error .
  end .
  else do:
    { str/tdat-wrt.i
        t_doc.doc-code
        {&trdcattr-fio-driver}
        v-tmp-char
        no-error
    }
  end. 
  
  v-tmp-char =  (xmlhndlerObj:vbf:buffer-field("pl-num"):buffer-value) no-error.
  if error-status:error
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message error-status:get-message (1) view-as alert-box.
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    undo, return error .
  end .
  else do:
    { str/tdat-wrt.i
        t_doc.doc-code
        {&trdcattr-seals-condition}
        v-tmp-char
        no-error
    }
  end. 
  
  v-ok = xmlhndlerObj:GetFirst("scs") no-error.
  if not v-ok
  then do :
    v-mark:screen-value = "" .
    v-scan-str = "".
    v-mark = "".
    message xmlhndlerObj:ErrMsg view-as alert-box.
    v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
    undo, return error .
  end .    
   
  rep_:
  repeat:
    if available ub.auto-tank
    then do :
      find first ub.auto-section no-lock where ub.auto-section.auto-num = ub.auto-tank.auto-num
                                           and ub.auto-section.section-num = xmlhndlerObj:vbf:buffer-field("sc-num"):buffer-value
                                           no-error .
      if not available ub.auto-section
      then do :
        v-mark:screen-value = "" .
        v-scan-str = "".
        v-mark = "".
        message "Для автоцистерны с номером " ub.auto-tank.auto-num " не найдена секция " xmlhndlerObj:vbf:buffer-field("sc-num"):buffer-value ". Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса" view-as alert-box title "Ошибка".
        if not xmlhndlerObj:GetNext()
          then leave rep_.
        next rep_.
      end .                                     
    end .
    v-gd-cd = xmlhndlerObj:vbf:buffer-field("gd-cd"):buffer-value no-error.
    if error-status:error
    then do:
      v-mark:screen-value = "" .
      v-scan-str = "".
      v-mark = "".
      message error-status:get-message (1) view-as alert-box.
      v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
      if not xmlhndlerObj:GetNext()
        then leave rep_.
      next rep_.
    end.
    else do:
      v-tmp-int = v-gd-cd .
      v-tmp-char = "" .
      for each ub.goods-attr no-lock where ub.goods-attr.attr-code = {&attr-gds-code-AIS}
                                       and trim(ub.goods-attr.attr-value) > ""
                                       :
        v-gds-attr = replace(ub.goods-attr.attr-value, " ", "") .
        if lookup(string(v-gd-cd), v-gds-attr) > 0
        then do :
          v-tmp-char = v-tmp-char + string(ub.goods-attr.gds-code) + "," .                                
          v-tmp-int = ub.goods-attr.gds-code .   
        end .                                 
      end .
      v-tmp-char = trim(v-tmp-char, ",") .
      if num-entries(v-tmp-char) > 1
      then do :
        message "Коду топлива " string(v-gd-cd) " соответствуют несколько товаров TH." skip "Выберите  топливо по справочнику ТН,  соответствующее  топливу сливаемой секции АЦ по ТТН (секция №" xmlhndlerObj:vbf:buffer-field("sc-num"):buffer-value ")."
        view-as alert-box .
        run str\chs-gd-from-list.w (input v-tmp-char,
                                    output v-tmp-int) .
        if v-tmp-int = 0
        or v-tmp-int = ?
        then do :
          next rep_.
        end .                            
      end .
      find first ub.goods where ub.goods.gds-code = v-tmp-int no-lock no-error.
      if not available (ub.goods)
      then do:
        v-mark:screen-value = "" .
        v-scan-str = "".
        v-mark = "".
        message "Для секции ТТН № " xmlhndlerObj:vbf:buffer-field("sc-num"):buffer-value "отсутствует товар с кодом " v-gd-cd ". Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса" view-as alert-box title "Ошибка".
        if not xmlhndlerObj:GetNext()
          then leave rep_.
        next rep_.
      end.
      find first ub.pl-gds no-lock where ub.pl-gds.obj-type   = t_doc.obj-type
                                     and ub.pl-gds.obj-code   = t_doc.obj-code
                                     and ub.pl-gds.gds-code   = ub.goods.gds-code
                                     no-error .
      if not available (ub.pl-gds)
      then do:
        v-mark:screen-value = "" .
        v-scan-str = "".
        v-mark = "".
        message "Для товара с кодом " v-tmp-int " не удалось определить резервуар для приема НП" ". Для внесения в систему данных обратитесь к ответственному сотруднику регионального офиса" view-as alert-box title "Ошибка".
        if not xmlhndlerObj:GetNext()
          then leave rep_.
        next rep_.
      end.   
      if lookup (string (recid (ub.goods)), v-gdsrec-list) = 0
      then do:
        v-gdsrec-list = string (v-gdsrec-list) + "," + string (recid (ub.goods)).
        infoSecsObj:Initialization(t_doc.doc-code, ub.goods.gds-code).
        infoSecsObj:GetInfoSectionProp().
      end.
      else do :
        infoSecsObj:Initialization(t_doc.doc-code, ub.goods.gds-code).
        infoSecsObj:NewSection().
      end .
        
      infoSecsObj:InfoSectionCurr:SectionName = xmlhndlerObj:vbf:buffer-field("sc-num"):buffer-value no-error.
      infoSecsObj:InfoSectionCurr:SetCarVol(infoSecsObj:InfoSectionCurr:SectionName) .
      infoSecsObj:InfoSectionCurr:DocVolume = xmlhndlerObj:vbf:buffer-field("vol"):buffer-value no-error.
      infoSecsObj:InfoSectionCurr:CliQnty = xmlhndlerObj:vbf:buffer-field("mass"):buffer-value no-error.
      infoSecsObj:InfoSectionCurr:DocDensity = xmlhndlerObj:vbf:buffer-field("dens"):buffer-value / 1000 no-error.
      infoSecsObj:InfoSectionCurr:DocQnty = infoSecsObj:InfoSectionCurr:CliQnty / infoSecsObj:InfoSectionCurr:DocDensity .
      infoSecsObj:InfoSectionCurr:TTNTemp = xmlhndlerObj:vbf:buffer-field("temp"):buffer-value no-error.
      v-tmp-int = xmlhndlerObj:vbf:buffer-field("gd-gr"):buffer-value no-error.
      if not error-status:error
      then do :
        case v-tmp-int:
          when 1 then infoSecsObj:InfoSectionCurr:GroupNP = "I" .
          when 2 then infoSecsObj:InfoSectionCurr:GroupNP = "II" .
          when 3 then infoSecsObj:InfoSectionCurr:GroupNP = "III" .
          when 4 then infoSecsObj:InfoSectionCurr:GroupNP = "IV" .
          otherwise infoSecsObj:InfoSectionCurr:GroupNP = "" .
        end case .
      end .
      v-tmp-int = xmlhndlerObj:vbf:buffer-field("fill-type"):buffer-value no-error.
      if not error-status:error
      then do :
        case v-tmp-int:
          when 0 then infoSecsObj:InfoSectionCurr:Pour = "Верхний налив" .
          when 1 then infoSecsObj:InfoSectionCurr:Pour = "Нижний налив" .
          otherwise infoSecsObj:InfoSectionCurr:Pour = "Верхний налив" .
        end case .
      end .
      infoSecsObj:InfoSectionCurr:DocDensST = xmlhndlerObj:vbf:buffer-field("dens-st"):buffer-value / 1000 no-error.
      infoSecsObj:InfoSectionCurr:AccShip = xmlhndlerObj:vbf:buffer-field("contr-err"):buffer-value no-error.
      infoSecsObj:InfoSectionCurr:PaspDens = xmlhndlerObj:vbf:buffer-field("dens-pas"):buffer-value / 1000 no-error.
      infoSecsObj:InfoSectionCurr:NumPassport = xmlhndlerObj:vbf:buffer-field("pasp"):buffer-value no-error.
      infoSecsObj:SaveDBNoCheck().
      if not xmlhndlerObj:GetNext()
        then leave rep_.
    end.
  end.
  v-gdsrec-list = left-trim (v-gdsrec-list, ",").
  v-mark:screen-value = "" .
  v-scan-str = "".
  v-mark = "".
  v-sts:screen-value in frame {&frame-name} = "ожидание сканирования" .
  run cycle-add-cust in p-handle (input v-gdsrec-list) no-error.
  if error-status:error
    then message "Ошибка добавление товара." return-value view-as alert-box.
  v-sts:screen-value in frame {&frame-name}  = "считано".
  
  for each buf_doc-line-attr exclusive-lock where buf_doc-line-attr.doc-code = t_doc.doc-code,
  first buf_goods no-lock where buf_goods.gds-code = buf_doc-line-attr.gds-code
  :
    if not can-find (first buf_doc-line no-lock where buf_doc-line.doc-code = buf_doc-line-attr.doc-code
                                                  and buf_doc-line.artic = buf_goods.artic
                                                  and buf_doc-line.prod-code = buf_goods.prod-code
                                                  and buf_doc-line.prod-type = buf_goods.prod-type)
    then do :
      delete buf_doc-line-attr .
    end .
  end .
  
  delete object infoSecsObj no-error .
  
  apply "choose" to b-exit in frame {&frame-name}.
  

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE parse2DCodeToXML Dialog-Frame 
procedure parse2DCodeToXML :
  
  define input parameter p-2dcode as char no-undo.
  define output parameter p-xmlfile as char no-undo.
  
  define variable v-ok as logical no-undo .
  define variable v-json-str as character no-undo.
  define variable v-ix as integer no-undo.
  define variable v-crc as char no-undo.
  define variable cmd as char no-undo.
  
  v-json-str = p-2dcode.
  v-scan-str = "".
  v-ix = index (v-json-str, ',"CRC":"').
  v-crc = substring (v-json-str, v-ix + 8, 8).
  v-json-str = substring (v-json-str, 9, v-ix - 9).
  
  v-json-str = replace(v-json-str, '\', '\\') .
  v-json-str = replace(v-json-str, '/', '\/') .
  
  output to "qr2d.json" convert target 'UTF-8'.
  put unformatted v-json-str.
  output close.
  
  cmd = substitute ('&1 -file=&2 >&3',
                     search("exe/json2xml.exe"),
                     search("qr2d.json"),
                     "qr2d.xml"
                     ) .
  os-command silent value (cmd). 
  
  file-info:file-name = search("qr2d.xml") .
  if file-info:file-size = 0
  then do :
    v-ok = false .
    v-sts = "oшибка при конвертации json в XML. Файл " + search("qr2d.xml") + " пустой (размер 0 байт)." .
    return error.
  end .

  p-xmlfile = search("qr2d.xml"). 

end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME



&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE checkJson Dialog-Frame 
procedure checkJson :
  define input parameter p-str as character no-undo .
  define output parameter p-ok as logical no-undo .
  
  define variable v-num-sec as integer no-undo .
  define variable v-tmp-str as character no-undo .
  define variable ii as integer no-undo .
  define variable v-num-teg as integer no-undo .
  
  p-ok = yes .
  
  if index(p-str, '"data"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"CRC"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"doc"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"contr-cd"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"doc-date"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"doc-num"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"transp"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"nb-cd"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"transp-num"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"driv"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"scs"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"sc-num"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"gd-cd"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"gd-gr"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"fill-type"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"temp"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"dens"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"mass"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"vol"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"dens-st"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"contr-err"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"pasp"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  if index(p-str, '"dens-pas"') = 0
  then do :
    p-ok = no .
    return .
  end .
  
  
  v-tmp-str = p-str .
  
  v-tmp-str = substring(v-tmp-str, index(v-tmp-str, '"scs"') + 6) .
  v-tmp-str = replace(v-tmp-str, chr(123), "") .
  v-tmp-str = replace(v-tmp-str, chr(125), "") .
  v-tmp-str = replace(v-tmp-str, "[", "") .
  v-tmp-str = replace(v-tmp-str, "]", "") .
  
  
  v-num-sec = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"sc-num"' then v-num-sec = v-num-sec + 1 .
  end.
  
  
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"gd-cd"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"gd-gr"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"fill-type"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"temp"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"dens"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"mass"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"vol"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"dens-st"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"contr-err"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"pasp"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  
  v-num-teg = 0 .
  do ii = 1 to num-entries(v-tmp-str) :
    if entry(ii, v-tmp-str) begins '"dens-pas"' then v-num-teg = v-num-teg + 1 .
  end.
  if v-num-teg <> v-num-sec
  then do :
    p-ok = no .
    return .
  end .
  
end .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE checkcrc Dialog-Frame 
procedure checkcrc:
  
  define input parameter p-json-str as char no-undo.
  define input parameter p-crc32 as char no-undo.
  define output parameter p-ok as logical no-undo.
  
  define variable v-crc32   as character no-undo .
  define variable mpData    as memptr    no-undo .
  define variable inLength  as integer   no-undo .
  
  p-ok = false.
  
  inLength     = LENGTH(p-json-str, 'raw').
  set-size(mpData) = 0. 
  set-size(mpData) = inLength.
  PUT-STRING(mpData,1,inLength) = p-json-str.
  v-crc32 =  intToHex(CRC32(INPUT mpData)) .
  set-size(mpData) = 0. 
  
  if length(v-crc32) < 8
  then
    v-crc32 = fill("0", 8 - length(v-crc32)) + v-crc32 .
  
  if p-crc32 = v-crc32
  then do :
    p-ok = true.
  end .
  
end.
/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE proc-any-key Dialog-Frame 
procedure proc-any-key :
  if v-scan-str = ""
  then
    v-timedelay = etime.
  else
  if etime - v-timedelay > qr-scan-time
  then
    v-scan-str = "".
  v-scan-str = v-scan-str + last-event:label.
end.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME