define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter  bttn        as character no-undo .
define input parameter c-point as character no-undo .
define input parameter tbl     as character no-undo .
define input parameter buf     as character no-undo .
define input parameter fld     as character no-undo .
define input parameter lab     as character no-undo .
define input parameter spr     as character no-undo .
define input parameter p-size  as character no-undo .
define input parameter p-size-min  as character no-undo .
define input parameter p-format as character no-undo .
define input parameter dim     as character no-undo .
define output parameter p-rec as recid no-undo .
define output parameter P-LENGTH as integer no-undo .
define output parameter P-NUM-CLMN as integer no-undo .
define output parameter P-file-name as character no-undo .
define output parameter P-encoding as character no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Выбор шаблона экспорта товаров на ТСД".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table t-f no-undo
field table-name as character
field field-name as character
field field-name-0 as character
field field-format as character
field field-type as character
field field-size as character
field field-size-min as character
field field-csize as character
field field-label as character
field field-clabel as character
field field-spr as character
field field-delim as character
field field-table-order as integer
field field-order as integer
index pi is unique primary
table-name
field-name
index iorder
field-order
index itorder
table-name
field-table-order
.
define shared temp-table temp-shop no-undo
like ub.shop.
DEFINE VARIABLE kl AS INTEGER INITIAL 0.
define variable MethodReturn AS LOGICAL.
define variable ID AS RECID.
define variable IDENT AS RECID.
define variable ii as integer no-undo.
define variable rec as recid no-undo.
define variable v-length as integer no-undo.
define variable v-num-clmn as integer no-undo.
define variable v-delim as character no-undo.
define variable v-choose as logical no-undo.
define variable v-file-directory as character no-undo.
define variable v-rec-num as integer no-undo.
DEFINE VARIABLE v-scl-format AS CHARACTER NO-UNDO.
define variable flt-rec as recid no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable v-doc-rec as recid no-undo .
DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 8.8 BY 1 TOOLTIP "Добавить новый шаблон".
DEFINE BUTTON b-Cancel AUTO-END-KEY DEFAULT
     LABEL "&Выход "
     SIZE 10 BY 1 TOOLTIP "Выход без изменений"
     BGCOLOR 8 .
DEFINE BUTTON b-codes
     LABEL "&Коды":L
     SIZE 9.5 BY 1 TOOLTIP "Выбор типов кодов для экспорта".
DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE 8.8 BY 1 TOOLTIP "Удалить ранее существующий шаблон".
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Отменить":L
     SIZE 10 BY 1 TOOLTIP "Отменить действие установок шаблона".
DEFINE BUTTON b-file
     LABEL "&Файл":L
     SIZE 10 BY 1 TOOLTIP "Выбор файла для экспорта".
DEFINE BUTTON b-help DEFAULT
     LABEL "Помо&щь":L
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-OK AUTO-GO DEFAULT
     LABEL "&Применить":L
     SIZE 10 BY 1 TOOLTIP "Применить установки выбранного шаблона"
     BGCOLOR 8 .
DEFINE BUTTON b-update
     LABEL "&Изменить":L
     SIZE 9 BY 1 TOOLTIP "Изменить установки выбранного шаблона".
DEFINE VARIABLE f-ascii AS INTEGER FORMAT ">>9":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 6.1 BY 1 NO-UNDO.
DEFINE VARIABLE f-delim AS CHARACTER FORMAT "X(1)":U
     VIEW-AS FILL-IN
     SIZE 2 BY 1 NO-UNDO.
DEFINE VARIABLE f-file-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 97.9 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE f-length AS CHARACTER FORMAT "X(5)":U
     VIEW-AS FILL-IN
     SIZE 9.1 BY 1 NO-UNDO.
DEFINE VARIABLE f-num-clmn AS CHARACTER FORMAT "X(3)":U
     VIEW-AS FILL-IN
     SIZE 6.1 BY 1 NO-UNDO.
DEFINE VARIABLE f-rec-num AS CHARACTER FORMAT "X(7)":U
     VIEW-AS FILL-IN
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE f-scl-format AS CHARACTER FORMAT "X(7)":U
     VIEW-AS FILL-IN
     SIZE 8 BY 1 NO-UNDO.
DEFINE VARIABLE flt-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 97.9 BY 1
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.
DEFINE VARIABLE Rs-encoding AS CHARACTER INITIAL "IBM866"
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "DOS", "IBM866",
"WINDOWS", "WINDOWS-1251"
     SIZE 23.5 BY 1 NO-UNDO.
DEFINE QUERY br-filter FOR
      ubflt.filter SCROLLING.
DEFINE QUERY BR-sel-fields FOR
      t-f SCROLLING.
DEFINE BROWSE br-filter
  QUERY br-filter NO-LOCK DISPLAY
      ubflt.filter.Naim COLUMN-LABEL "Имя шаблона" FORMAT "X(255)":U
    WITH SEPARATORS SIZE 48.5 BY 12.77.
DEFINE BROWSE BR-sel-fields
  QUERY BR-sel-fields DISPLAY
      t-f.field-label format "X(30)" column-label "Название поля"
t-f.field-csize format "X(5)" column-label "Длина"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 38.9 BY 12.7.
DEFINE FRAME DIALOG-1
     b-Cancel AT ROW 1 COL 1
     b-OK AT ROW 1 COL 11
     b-exit AT ROW 1 COL 21
     b-file AT ROW 1 COL 31
     b-help AT ROW 1 COL 61
     flt-name AT ROW 2.53 COL 1 NO-LABEL
     Rs-encoding AT ROW 3.5 COL 21.5 NO-LABEL
     f-file-name AT ROW 4.53 COL 1 NO-LABEL
     b-codes AT ROW 5.7 COL 90
     f-length AT ROW 5.77 COL 27.1 COLON-ALIGNED NO-LABEL
     f-num-clmn AT ROW 5.77 COL 50.1 COLON-ALIGNED NO-LABEL
     f-delim AT ROW 5.77 COL 70.1 COLON-ALIGNED NO-LABEL
     f-ascii AT ROW 5.77 COL 81.3 COLON-ALIGNED NO-LABEL
     f-rec-num AT ROW 6.87 COL 39 COLON-ALIGNED NO-LABEL
     f-scl-format AT ROW 6.87 COL 89 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     b-add AT ROW 8 COL 50.1
     b-del AT ROW 9 COL 50.1
     br-filter AT ROW 9.07 COL 1
     BR-sel-fields AT ROW 9.07 COL 60.1
     b-update AT ROW 10 COL 50.1
     "Разделитель" VIEW-AS TEXT
          SIZE 12.5 BY .67 AT ROW 6 COL 59.1
          BGCOLOR 1 FGCOLOR 15
     "Количество выводимых записей" VIEW-AS TEXT
          SIZE 34.9 BY .67 AT ROW 7.13 COL 3.5
          BGCOLOR 1 FGCOLOR 15
     "Файл" VIEW-AS TEXT
          SIZE 14.5 BY .67 AT ROW 3.77 COL 2
          BGCOLOR 1 FGCOLOR 15
     "Список полей" VIEW-AS TEXT
          SIZE 39.3 BY .67 AT ROW 8.03 COL 59.8
          BGCOLOR 1 FGCOLOR 15
     "ASCII" VIEW-AS TEXT
          SIZE 6.1 BY .67 AT ROW 6 COL 75
          BGCOLOR 1 FGCOLOR 15
     "Список шаблонов" VIEW-AS TEXT
          SIZE 48.6 BY .67 AT ROW 8.03 COL 1
          BGCOLOR 1 FGCOLOR 15
     "Длина записи" VIEW-AS TEXT
          SIZE 14.5 BY .67 AT ROW 6 COL 14.1
          BGCOLOR 1 FGCOLOR 15
     "Кол-во полей" VIEW-AS TEXT
          SIZE 12.5 BY .67 AT ROW 6 COL 39.1
          BGCOLOR 1 FGCOLOR 15
     "Формат весового кода" VIEW-AS TEXT
          SIZE 34.9 BY .67 AT ROW 7.13 COL 55.5 WIDGET-ID 4
          BGCOLOR 1 FGCOLOR 15
     SPACE(9.34) SKIP(14.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Шаблоны выгрузки в файл для ТСД":L
         DEFAULT-BUTTON b-OK CANCEL-BUTTON b-Cancel.
ASSIGN
       FRAME DIALOG-1:SCROLLABLE       = FALSE.
ON CHOOSE OF b-add IN FRAME DIALOG-1
DO:
  Kl = 0.
  run gbl/upd-tsd.w (
                 input parparentproc
                ,input p-obj-type
                ,input p-obj-code
                ,input c-point
                ,input Tbl
                ,input Buf
                ,input Fld
                ,input Lab
                ,input Spr
                ,input p-size
                ,input p-size-min
                ,input p-format,Dim
                ,input Kl
                ,OUTPUT ID
                ,OUTPUT P-LENGTH
                ,OUTPUT P-NUM-CLMN).
  IF ID = ? THEN ID = IDENT.
  RUN enable_UI.
  run proc-buttons in this-procedure .
  REPOSITION br-filter TO RECID flt-rec no-error.
  APPLY "VALUE-CHANGED" TO br-filter.
  apply "entry" to br-filter.
END.
ON CHOOSE OF b-Cancel IN FRAME DIALOG-1
DO:
     flt-rec = ?.
     return  "undo":U.
END.
ON CHOOSE OF b-codes IN FRAME DIALOG-1
DO:
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
if not avail ubflt.filter then return no-apply.
run adm/to-cd.w ( 'ПРОСМОТР':U ,
INPUT v-host-code,
INPUT p-obj-type,
INPUT p-obj-code,
INPUT ("Типы кодов для вывода в файл ТСД" + chr(32) + p-obj-type +
string(p-obj-code)),
INPUT-OUTPUT temp-shop.all-prt,
INPUT-OUTPUT temp-shop.cd-bc-alt,
INPUT-OUTPUT temp-shop.cd-bc-base,
INPUT-OUTPUT temp-shop.cd-loc-alt,
INPUT-OUTPUT temp-shop.cd-loc-base,
INPUT-OUTPUT temp-shop.cd-parts-all,
INPUT-OUTPUT temp-shop.cd-parts-not-blank,
INPUT-OUTPUT temp-shop.cd-parts-ser,
INPUT-OUTPUT temp-shop.cd-pb-alt,
INPUT-OUTPUT temp-shop.cd-pb-base,
INPUT-OUTPUT temp-shop.cd-sc-base) .
END.
ON CHOOSE OF b-del IN FRAME DIALOG-1
do:
do on stop  undo, return:
  if available ubflt.filter then do:
    flt-name = "".
    get prev br-filter.
    if not available ubflt.filter then do:
      get first br-filter.
      get next br-filter.
    end.
    flt-rec = recid(ubflt.filter).
    FIND FIRST ubflt.filter WHERE ubflt.filter.Num-flt = Kl EXCLUSIVE-LOCK NO-ERROR.
    DELETE ubflt.filter.
    find ubflt.filter where recid(ubflt.filter) = flt-rec no-lock no-error.
    RUN enable_UI.
    run proc-buttons in this-procedure .
    REPOSITION br-filter TO RECID flt-rec no-error.
    APPLY "VALUE-CHANGED" TO br-filter.
    apply "entry" to br-filter.
   END.
  end.
END.
ON CHOOSE OF b-exit IN FRAME DIALOG-1
DO:
   flt-rec = ?.
   find ubflt.usr-flt where ubflt.usr-flt.user-name = v-cntxt-userid
                        and ubflt.usr-flt.call-point = ubflt.filter.call-point
                        no-error.
   if available ubflt.usr-flt then delete ubflt.usr-flt.
END.
ON CHOOSE OF b-file IN FRAME DIALOG-1
DO:
assign
p-file-name = if p-file-name = "":U then "tsd.txt":U else p-file-name
.
run gbl/d-file.p (
 input-output p-file-name
,input-output v-file-directory
,input        "Текстовые файлы"
,input        "*.txt":U
,input        ","
,input        "txt":U
,input        no
,input        yes
,input        yes
,input        "Введите имя файла для экспорта"
,output       v-choose
).
if not v-choose then do:
  return no-apply.
end.
display
p-file-name @ f-file-name
with frame DIALOG-1.
END.
ON CHOOSE OF b-OK IN FRAME DIALOG-1
DO:
ASSIGN
rs-encoding
p-encoding = rs-encoding.
if p-file-name = "":U or f-file-name:screen-value = "":U then do:
    message
    "Введите имя файла для экспорта"
    view-as alert-box.
    return no-apply.
end.
if available ubflt.filter  then do:
   p-rec = recid(ubflt.filter).
   find ubflt.usr-flt where ubflt.usr-flt.user-name = v-cntxt-userid
                        and ubflt.usr-flt.call-point = ubflt.filter.call-point
                        no-error.
   if not available ubflt.usr-flt then create ubflt.usr-flt.
   assign
   ubflt.usr-flt.user-name = v-cntxt-userid
   ubflt.usr-flt.call-point    = ubflt.filter.call-point
   ubflt.usr-flt.naim = ubflt.filter.naim.
   end.
else p-rec = ?.
END.
ON CHOOSE OF b-update IN FRAME DIALOG-1
DO:
  FIND FIRST ubflt.filter WHERE ubflt.filter.Num-flt = Kl EXCLUSIVE-LOCK NO-ERROR no-wait.
  IF AVAILABLE(ubflt.filter) THEN DO:
   Kl = ubflt.filter.Num-flt.
   run gbl/upd-tsd.w  (
                    input parparentproc
                   ,input p-obj-type
                   ,input p-obj-code
                   ,input c-point
                   ,input Tbl
                   ,input Buf
                   ,input Fld
                   ,input Lab
                   ,input Spr
                   ,input p-size
                   ,input p-size-min
                   ,input p-format
                   ,input Dim
                   ,input Kl
                   ,output ID
                   ,OUTPUT P-LENGTH
                   ,OUTPUT P-NUM-CLMN).
   IF ID = ? THEN ID = IDENT.
   RUN enable_UI.
   run proc-buttons in this-procedure .
   REPOSITION br-filter TO RECID flt-rec no-error.
   APPLY "VALUE-CHANGED" TO br-filter.
   apply "entry" to br-filter.
 END.
   else
     if locked ubflt.filter then
        message 'Шаблон в данный момент корректируется другим пользователем'.
END.
ON MOUSE-SELECT-DBLCLICK OF br-filter IN FRAME DIALOG-1
DO:
apply "choose" to  b-ok.
END.
ON RETURN OF br-filter IN FRAME DIALOG-1
DO:
apply "choose" to  b-ok.
END.
ON VALUE-CHANGED OF br-filter IN FRAME DIALOG-1
DO:
 IF AVAILABLE(ubflt.filter) THEN DO:
    flt-rec = recid(ubflt.filter).
    flt-name = ubflt.filter.naim.
    Kl = ubflt.filter.Num-flt.
    assign
        v-num-clmn = num-entries(ubflt.filter.fields-sort)
        v-length = 0
        .
    run fill-table in this-procedure.
    IDENT = RECID(ubflt.filter).
    DISPLAY
    flt-name
    string(v-length, ">>>>9") @ f-length
    string(v-num-clmn, ">>9") @ f-num-clmn
    v-delim @ f-delim
    f-ascii
    string(v-rec-num) @ f-rec-num
    v-scl-format @ f-scl-format
    with frame DIALOG-1.
  END.
  ELSE do:
    run fill-table in this-procedure.
    f-ascii = 0.
    display
    "":U @ f-length
    "":U @ f-num-clmn
    "":U @ f-delim
    f-ascii
    "":U @ f-rec-num
    "":U @ f-scl-format
    with frame DIALOG-1.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME DIALOG-1:PARENT eq ?
THEN FRAME DIALOG-1:PARENT = ACTIVE-WINDOW.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame DIALOG-1
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame DIALOG-1
do:
  apply "help":u to frame DIALOG-1 .
end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame DIALOG-1:width - 0.3
                fh            = frame DIALOG-1:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame DIALOG-1 :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame DIALOG-1 :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame DIALOG-1 :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame DIALOG-1 :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame DIALOG-1 :height = v-frame-height
          .
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame DIALOG-1 :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame DIALOG-1 :height
      v-frame-virtual-height = frame DIALOG-1 :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame DIALOG-1 :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame DIALOG-1
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-height = frame DIALOG-1 :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame DIALOG-1 :height = frame DIALOG-1 :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame DIALOG-1 :height = frame DIALOG-1 :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-height = frame DIALOG-1 :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame DIALOG-1 :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame DIALOG-1 :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame DIALOG-1 :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame DIALOG-1 :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame DIALOG-1 :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame DIALOG-1 :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame DIALOG-1 :width = v-frame-width
          .
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame DIALOG-1 :scrollable = true
          then do:
            assign
              frame DIALOG-1 :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame DIALOG-1 :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame DIALOG-1 :width
      v-frame-virtual-width = frame DIALOG-1 :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame DIALOG-1 :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame DIALOG-1
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-width = frame DIALOG-1 :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame DIALOG-1 :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame DIALOG-1 :width = frame DIALOG-1 :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame DIALOG-1 :scrollable = true
      then do:
        assign
          frame DIALOG-1 :virtual-width = frame DIALOG-1 :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame DIALOG-1 :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame DIALOG-1 :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame DIALOG-1
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame DIALOG-1 :height - v-diasize-resize-button :height
                  - 1
                  - (frame DIALOG-1 :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame DIALOG-1 :width - v-diasize-resize-button :width
                  - 1
                  - (frame DIALOG-1 :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame DIALOG-1
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame DIALOG-1 :height
      v-col-delta = v-new-col - frame DIALOG-1 :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame DIALOG-1 :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame DIALOG-1 :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame DIALOG-1 :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame DIALOG-1 :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame DIALOG-1 :width
      v-diasize-current-frame-height = frame DIALOG-1 :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame DIALOG-1
    :
      assign
        v-diasize-orig-frame-height = frame DIALOG-1 :height
        v-diasize-orig-frame-width  = frame DIALOG-1 :width
        v-diasize-browse-handle     = browse br-filter :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame DIALOG-1 :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
ON WINDOW-CLOSE OF FRAME DIALOG-1 APPLY "END-ERROR":U TO SELF.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-filter :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame DIALOG-1 anywhere
do:
   v-doc-rec = recid(ubflt.filter). OPEN QUERY br-filter FOR EACH ubflt.filter       WHERE ubflt.filter.call-point = c-point NO-LOCK. Reposition br-filter to recid v-doc-rec no-error .                APPLY 'ENTRY' to br-filter. APPLY 'value-changed' TO br-filter.
    apply "VALUE-CHANGED" to br-filter.
end.
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame DIALOG-1 anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame DIALOG-1. END.
  return no-apply.
end.
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame DIALOG-1 anywhere do:
  if b-update :sensitive then DO: apply "CHOOSE":U to b-update in frame DIALOG-1. END.
  return no-apply.
end.
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame DIALOG-1 anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame DIALOG-1. END.
  return no-apply.
end.
define variable vss-include-info11 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame DIALOG-1 anywhere do:
  if b-ok :sensitive then DO: apply "CHOOSE":U to b-ok in frame DIALOG-1. END.
  return no-apply.
end.
define variable vss-include-info12 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F2 of frame DIALOG-1 anywhere do:
  if b-cancel :sensitive then DO: apply "CHOOSE":U to b-cancel in frame DIALOG-1. END.
  return no-apply.
end.
on end-error, stop of frame DIALOG-1 do:
   return "undo":u.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
  assign frame DIALOG-1:title = "Ш А Б Л О Н Ы   В Ы Г Р У З К И   В   Ф А Й Л   Д Л Я   Т С Д   (" + ENTRY(1, c-point, chr(4)) + ")".
  RUN enable_UI.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
  run proc-buttons in this-procedure.
  reposition br-filter to recid flt-rec no-error.
  apply "value-changed" to br-filter in frame DIALOG-1.
  WAIT-FOR GO OF FRAME DIALOG-1 focus br-filter.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME DIALOG-1.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY flt-name Rs-encoding f-file-name f-length f-num-clmn f-delim f-ascii
          f-rec-num f-scl-format
      WITH FRAME DIALOG-1.
  ENABLE b-Cancel b-OK b-exit b-file b-help Rs-encoding b-codes b-add b-del
         br-filter BR-sel-fields b-update
      WITH FRAME DIALOG-1.
  OPEN QUERY br-filter FOR EACH ubflt.filter       WHERE ubflt.filter.call-point = c-point NO-LOCK.
END PROCEDURE.
PROCEDURE fill-table :
define variable ii as integer no-undo.
for each t-f :
    delete t-f.
end.
if available ubflt.filter then do:
  assign
  v-num-clmn = num-entries(ubflt.filter.fields-sort)
  v-length = 0
  f-ascii = int(entry(3, ubflt.filter.fields-sort-rus, chr(4)))
  v-delim = chr(int(entry(3, ubflt.filter.fields-sort-rus, chr(4))))
  v-rec-num = int(entry(4, ubflt.filter.fields-sort-rus, chr(4)))
  v-scl-format = (IF NUM-ENTRIES(ubflt.filter.fields-sort-rus, chr(4)) < 5
                  THEN ">>>>9"
                  ELSE entry(5, ubflt.filter.fields-sort-rus, chr(4)))
        .
    do ii = 1 to v-num-clmn:
        create t-f.
        assign
        t-f.field-table-order = ii
        t-f.field-name = entry(2, entry(ii,entry(1, ubflt.filter.fields-sort, chr(4))), ".":U)
        t-f.field-label = entry(ii,entry(1, ubflt.filter.fields-sort-rus, chr(4)))
        t-f.field-size = entry(ii,entry(1, ubflt.filter.where-ysl, chr(4)))
        t-f.field-size-min = entry(ii,entry(2, ubflt.filter.where-ysl, chr(4)))
        t-f.field-csize = entry(ii,entry(3, ubflt.filter.where-ysl, chr(4)))
        t-f.field-format = entry(ii,ubflt.filter.where-ysl-rus, chr(4))
        v-length = v-length + integer(t-f.field-csize)
        .
    end.
    find first temp-shop no-error .
    if not avail temp-shop then do:
      create temp-shop.
    end.
    assign
    temp-shop.all-prt              = (lookup("all-prt":U, entry(2, ubflt.filter.fields-sort-rus, chr(4))) > 0)
    temp-shop.cd-bc-alt            = (lookup("cd-bc-alt":U, entry(2, ubflt.filter.fields-sort-rus, chr(4)))  > 0)
    temp-shop.cd-bc-base           = (lookup("cd-bc-base":U, entry(2, ubflt.filter.fields-sort-rus, chr(4))) > 0)
    temp-shop.cd-loc-alt           = (lookup("cd-loc-alt":U, entry(2, ubflt.filter.fields-sort-rus, chr(4))) > 0)
    temp-shop.cd-loc-base          = (lookup("cd-loc-base":U, entry(2, ubflt.filter.fields-sort-rus, chr(4))) > 0)
    temp-shop.cd-parts-all         = (lookup("cd-parts-all":U, entry(2, ubflt.filter.fields-sort-rus, chr(4))) > 0)
    temp-shop.cd-parts-not-blank   = (lookup("cd-parts-not-blank":U, entry(2, ubflt.filter.fields-sort-rus, chr(4)))  > 0)
    temp-shop.cd-parts-ser         = (lookup("cd-part-ser":U, entry(2, ubflt.filter.fields-sort-rus, chr(4)))  > 0)
    temp-shop.cd-pb-alt            = (lookup("cd-pb-alt":U, entry(2, ubflt.filter.fields-sort-rus, chr(4)))  > 0)
    temp-shop.cd-pb-base           = (lookup("cd-pb-base":U, entry(2, ubflt.filter.fields-sort-rus, chr(4)))  > 0)
    temp-shop.cd-sc-base           = (lookup("cd-sc-base":U, entry(2, ubflt.filter.fields-sort-rus, chr(4)))  > 0)
    .
end.
OPEN QUERY br-sel-fields FOR EACH t-f no-lock by t-f.field-table-order.
APPLY "ENTRY" to br-filter in frame DIALOG-1.
END PROCEDURE.
PROCEDURE proc-buttons :
  if lookup("b-codes", bttn) = 0 then do:
    disable b-codes
    with frame DIALOG-1.
    hide
    b-codes
    in frame DIALOG-1 .
  end.
  if lookup(bttn, "b-exit":U) = 0 then do:
    hide
    b-exit
    in frame DIALOG-1.
   end.
END PROCEDURE.
