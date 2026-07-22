define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование атрибутов заказов флористов".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
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
define temp-table tt-upd-attr no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
define temp-table tt-upd-attr-fuel no-undo
  field code           as character
  field type-attr      as character
  field format-attr    as character
  field fillin_width   as integer
  field fillin_height  as integer
  field label-attr     as character
  field user-can-edit  as logical
  field output-display as logical
  field hot-key        as character
  field can-select     as logical
  field other          as character
  field proc-attr      as character
  field proc-win       as character
  field proc-func      as character
  field full-screen-val as character
  field sort_       as integer
  index code is primary unique code
  index output-display output-display code
  index by-sort sort_
  .
define input parameter p-mode as character no-undo.
define input parameter p-doc-code like ub.trn-doc.doc-code no-undo.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1.
DEFINE BUTTON B-help DEFAULT
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1.
DEFINE VARIABLE v-kuda AS CHARACTER
     VIEW-AS EDITOR MAX-CHARS 220 SCROLLBAR-VERTICAL
     SIZE 62 BY 2 NO-UNDO.
DEFINE VARIABLE l-loc-hour AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время выполнения заказа"
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.
DEFINE VARIABLE l-loc-min AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY 1 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.
DEFINE VARIABLE v-date-chk AS DATE FORMAT "99/99/9999":U
     LABEL "Дата чека предоплаты"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-date-cr AS DATE FORMAT "99/99/9999":U
     LABEL "Дата выполнения заказа"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-deliv-date AS DATE FORMAT "99/99/9999":U
     LABEL "Дата доставки"
     VIEW-AS FILL-IN
     SIZE 14 BY 1 NO-UNDO.
DEFINE VARIABLE v-end-hour AS INTEGER FORMAT "99":U INITIAL 23
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE v-end-min AS INTEGER FORMAT "99":U INITIAL 59
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE v-face AS CHARACTER FORMAT "X(256)":U
     LABEL "Контактное лицо"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.
DEFINE VARIABLE v-komu AS CHARACTER FORMAT "X(256)":U
     LABEL "Кому"
     VIEW-AS FILL-IN
     SIZE 62 BY 1 NO-UNDO.
DEFINE VARIABLE v-nac AS DECIMAL FORMAT "->>,>>9.9<<<<":U INITIAL 0
     LABEL "Наценка за работу,%"
     VIEW-AS FILL-IN
     SIZE 14.6 BY 1 NO-UNDO.
DEFINE VARIABLE v-Nchk-bef AS CHARACTER FORMAT "X(256)":U
     LABEL "№ чека предоплаты"
     VIEW-AS FILL-IN
     SIZE 23 BY 1 NO-UNDO.
DEFINE VARIABLE v-start-hour AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время доставки"
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE v-start-min AS INTEGER FORMAT "99":U INITIAL 0
     LABEL ""
     VIEW-AS FILL-IN
     SIZE 4 BY 1 NO-UNDO.
DEFINE VARIABLE v-summa-bef AS DECIMAL FORMAT "->>>>,>>9.99":U INITIAL 0
     LABEL "Сумма предоплаты"
     VIEW-AS FILL-IN
     SIZE 14.6 BY 1 NO-UNDO.
DEFINE VARIABLE v-summa-dos AS DECIMAL FORMAT "->>,>>9.99":U INITIAL 0
     LABEL "Сумма доставки,(баз.вал.)"
     VIEW-AS FILL-IN
     SIZE 14.6 BY 1 NO-UNDO.
DEFINE VARIABLE v-tel AS CHARACTER FORMAT "X(256)":U
     LABEL "Контактный телефон"
     VIEW-AS FILL-IN
     SIZE 38 BY 1 NO-UNDO.
DEFINE VARIABLE T-dost AS LOGICAL INITIAL no
     LABEL "Доставка"
     VIEW-AS TOGGLE-BOX
     SIZE 11.2 BY .81 NO-UNDO.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-help AT ROW 1 COL 81
     v-date-cr AT ROW 3.1 COL 26.2 COLON-ALIGNED
     l-loc-hour AT ROW 4.19 COL 27.6 COLON-ALIGNED
     l-loc-min AT ROW 4.19 COL 32 COLON-ALIGNED NO-LABEL
     v-tel AT ROW 5.24 COL 26 COLON-ALIGNED
     v-face AT ROW 6.24 COL 26 COLON-ALIGNED
     v-deliv-date AT ROW 7.24 COL 26 COLON-ALIGNED WIDGET-ID 2
     v-start-hour AT ROW 8.24 COL 26 COLON-ALIGNED WIDGET-ID 4
     v-start-min AT ROW 8.24 COL 31.8 COLON-ALIGNED WIDGET-ID 6
     v-end-hour AT ROW 8.24 COL 38.6 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     v-end-min AT ROW 8.24 COL 44.4 COLON-ALIGNED WIDGET-ID 10
     v-summa-bef AT ROW 9.24 COL 26 COLON-ALIGNED
     v-Nchk-bef AT ROW 10.24 COL 26 COLON-ALIGNED
     v-date-chk AT ROW 11.24 COL 26 COLON-ALIGNED
     T-dost AT ROW 12.24 COL 28
     v-summa-dos AT ROW 13.24 COL 27.2 COLON-ALIGNED
     v-nac AT ROW 14.24 COL 26 COLON-ALIGNED
     v-kuda AT ROW 15.24 COL 28 NO-LABEL
     v-komu AT ROW 17.52 COL 26 COLON-ALIGNED
     "Адрес доставки:" VIEW-AS TEXT
          SIZE 16.6 BY .67 AT ROW 15.43 COL 10.8
     "-" VIEW-AS TEXT
          SIZE 1 BY .62 AT ROW 8.43 COL 38.8 WIDGET-ID 12
     ":" VIEW-AS TEXT
          SIZE 1.2 BY 1 AT ROW 4.19 COL 32.8
          FGCOLOR 1
     SPACE(57.37) SKIP(15.32)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Информация о заказе".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
 RUN save-proc no-error .
 if error-status :error then return no-apply .
END.
ON CURSOR-DOWN OF l-loc-hour IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour .
  l-loc-hour = l-loc-hour -  1.
  if l-loc-hour < 0 then return no-apply.
  display l-loc-hour with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-hour IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour .
  l-loc-hour = l-loc-hour +  1.
  if l-loc-hour > 24 then return no-apply.
  display l-loc-hour with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-hour IN FRAME Dialog-Frame
DO:
    assign frame Dialog-Frame l-loc-hour .
   if l-loc-hour > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if l-loc-hour < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.
   end.
END.
ON return OF l-loc-hour IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  l-loc-hour:handle ) .
  return no-apply .
END.
ON CURSOR-DOWN OF l-loc-min IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-min .
  l-loc-min = l-loc-min -  1.
  if l-loc-min < 0 then return no-apply.
  display l-loc-min with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign  frame Dialog-Frame l-loc-min .
  l-loc-min = l-loc-min +  1.
  if l-loc-min > 59 then return no-apply.
  display l-loc-min with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign frame Dialog-Frame l-loc-min .
   if l-loc-min > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
END.
ON return OF l-loc-min IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  l-loc-min:handle ) .
  return no-apply .
END.
ON return OF T-dost IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  T-dost:handle ) .
  return no-apply .
END.
ON return OF v-date-chk IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  v-date-chk:handle ) .
  return no-apply .
END.
ON return OF v-date-cr IN FRAME Dialog-Frame
DO:
  run next-focus in this-procedure  (input  v-date-cr:handle ) .
  return no-apply .
END.
ON LEAVE OF v-end-hour IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame
  v-start-hour
  v-start-min
  v-end-hour
  v-end-min
  .
  if v-start-min + (v-start-hour * 60) > v-end-min + (v-end-hour * 60) then do:
     message "Конечное время периода доставки не может быть меньше начального" view-as alert-box.
     v-end-min:screen-value = v-start-min:screen-value.
     v-end-min = v-start-min.
     v-end-hour:screen-value = v-start-hour:screen-value.
     v-end-hour = v-start-hour.
  end.
END.
ON VALUE-CHANGED OF v-end-hour IN FRAME Dialog-Frame
DO:
  assign v-end-hour.
  if v-end-hour > 23 then do:
    v-end-hour = 23.
    v-end-hour:screen-value = "23".
  end.
END.
ON LEAVE OF v-end-min IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame
  v-start-hour
  v-start-min
  v-end-hour
  v-end-min
  .
  if v-start-min + (v-start-hour * 60) > v-end-min + (v-end-hour * 60) then do:
     message "Конечное время периода доставки не может быть меньше начального" view-as alert-box.
     v-end-min:screen-value = v-start-min:screen-value.
     v-end-min = v-start-min.
     v-end-hour:screen-value = v-start-hour:screen-value.
     v-end-hour = v-start-hour.
  end.
END.
ON VALUE-CHANGED OF v-end-min IN FRAME Dialog-Frame
DO:
  assign v-end-min.
  if v-end-min > 59 then do:
    v-end-min = 59.
    v-end-min:screen-value = "59".
  end.
END.
ON return OF v-face IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  v-face:handle ) .
  return no-apply .
END.
ON return OF v-komu IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  v-komu:handle ) .
  return no-apply .
END.
ON return OF v-kuda IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  v-kuda:handle ) .
  return no-apply .
END.
ON return OF v-nac IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  v-nac:handle ) .
  return no-apply .
END.
ON return OF v-Nchk-bef IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  v-Nchk-bef:handle ) .
  return no-apply .
END.
ON LEAVE OF v-start-hour IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame
  v-start-hour
  v-start-min
  v-end-hour
  v-end-min
  .
END.
ON VALUE-CHANGED OF v-start-hour IN FRAME Dialog-Frame
DO:
  assign v-start-hour.
  if v-start-hour > 23 then do:
    v-start-hour = 23.
    v-start-hour:screen-value = "23".
  end.
END.
ON LEAVE OF v-start-min IN FRAME Dialog-Frame
DO:
  assign frame Dialog-Frame
  v-start-hour
  v-start-min
  v-end-hour
  v-end-min
  .
END.
ON VALUE-CHANGED OF v-start-min IN FRAME Dialog-Frame
DO:
  assign v-start-min.
  if v-start-min > 59 then do:
    v-start-min = 59.
    v-start-min:screen-value = "59".
  end.
END.
ON return OF v-summa-bef IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  v-summa-bef:handle ) .
  return no-apply .
END.
ON return OF v-summa-dos IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  v-summa-dos:handle ) .
  return no-apply .
END.
ON return OF v-tel IN FRAME Dialog-Frame
DO:
    run next-focus in this-procedure  (input  v-tel:handle ) .
  return no-apply .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
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
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK :
   define buffer buf_trn-doc for ub.trn-doc  .
   find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code no-error .
   if not available buf_trn-doc then do:
     return error return-value .
   end.
  RUN init_proc.
  if p-mode = 'ПРОСМОТР':U then do:
     RUN sel_UI.
     WAIT-FOR GO OF FRAME Dialog-Frame .
  end.
  else do:
      if buf_trn-doc.status_ = 'запрос':U and buf_trn-doc.flag_ = false  then do:
        RUN enable_UI.
        WAIT-FOR GO OF FRAME Dialog-Frame focus v-date-cr.
      end.
      else do:
          if buf_trn-doc.status_ = 'накл':U and buf_trn-doc.flag_ = false  then do:
            RUN nakl_UI.
            WAIT-FOR GO OF FRAME Dialog-Frame focus v-date-cr.
          end.
          else do:
            RUN sel_UI.
            WAIT-FOR GO OF FRAME Dialog-Frame .
          end.
      end.
  end.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-date-cr l-loc-hour l-loc-min v-tel v-face v-deliv-date v-start-hour
          v-start-min v-end-hour v-end-min v-summa-bef v-Nchk-bef v-date-chk
          T-dost v-summa-dos v-nac v-kuda v-komu
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-help v-date-cr l-loc-hour l-loc-min v-tel v-face
         v-deliv-date v-start-hour v-start-min v-end-hour v-end-min v-summa-bef
         v-Nchk-bef v-date-chk T-dost v-summa-dos v-nac v-kuda v-komu
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE init_proc :
define variable p-type   as character no-undo .
define variable p-value  as character no-undo .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input '0rsrv-date':U ,
                       output p-value ,
                       output p-type )  .
    v-date-cr = DATE( p-value ) .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input '1ord_time':U ,
                       output p-value ,
                       output p-type )  .
    if num-entries(p-value, ":") > 1 then l-loc-hour  = INT(ENTRY ( 1 , p-value , ":" )) no-error .
    if num-entries(p-value, ":") > 1 then  l-loc-min   = INT(ENTRY ( 2 , p-value , ":" )) no-error .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input '2befpay':U ,
                       output p-value ,
                       output p-type )  .
    v-summa-bef =  DECIMAL(p-value).
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input '3ord_Nchek':U ,
                       output p-value ,
                       output p-type )  .
    v-Nchk-bef  = p-value.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input '5deliv':U ,
                       output p-value ,
                       output p-type )  .
    v-summa-dos = DECIMAL(p-value) .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input '6sumwrk':U ,
                       output p-value ,
                       output p-type )  .
    v-nac       = DECIMAL(p-value) .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input '22ord_contact':U ,
                       output p-value ,
                       output p-type )  .
    v-face      =  p-value      .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input '21ord_phone':U ,
                       output p-value ,
                       output p-type )  .
    v-tel       =  p-value      .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input '4ord_dl':U ,
                       output p-value ,
                       output p-type )  .
    T-dost      =  if p-value = "yes" then true else false  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input '4dchek':U ,
                       output p-value ,
                       output p-type )  .
    v-date-chk  = DATE(p-value)  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input '8ord_adr':U ,
                       output p-value ,
                       output p-type )  .
    v-kuda      =     p-value   .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input '9ord_hwo':U ,
                       output p-value ,
                       output p-type )  .
    v-komu      =     p-value   .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'delivery-date':U ,
                       output p-value ,
                       output p-type )  .
    v-deliv-date      =     date(p-value)   .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input p-doc-code ,
                        input 'delivery-time':U ,
                       output p-value ,
                       output p-type )  .
 if num-entries(p-value, ":") > 1 then
    do:
        v-start-hour      =     int(replace(entry(1, entry(1, p-value, "-"), ":")," ",""))   .
        v-start-min       =     int(replace(entry(2, entry(1, p-value, "-"), ":")," ",""))   .
        v-end-hour        =     int(replace(entry(1, entry(2, p-value, "-"), ":")," ",""))  .
        v-end-min         =     int(replace(entry(2, entry(2, p-value, "-"), ":")," ",""))   .
    end.
END PROCEDURE.
PROCEDURE nakl_UI :
  DISPLAY v-date-cr l-loc-hour l-loc-min v-tel v-face v-summa-bef v-Nchk-bef
          v-date-chk T-dost v-summa-dos v-nac v-kuda v-komu
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit B-help v-date-cr l-loc-hour l-loc-min v-tel v-face
         v-nac v-kuda
         v-komu
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE next-focus :
  define input parameter p-widget-handle as handle no-undo .
  do with frame Dialog-Frame :
    if  v-date-cr   :handle = p-widget-handle then do:  if l-loc-hour    :sensitive then do: apply "entry":u to l-loc-hour . return . end. end.
    if  l-loc-hour  :handle = p-widget-handle then do:  if l-loc-min     :sensitive then do: apply "entry":u to l-loc-min  . return . end. end.
    if  l-loc-min   :handle = p-widget-handle then do:  if v-tel         :sensitive then do: apply "entry":u to v-tel      . return . end. end.
    if  v-tel       :handle = p-widget-handle then do:  if v-face        :sensitive then do: apply "entry":u to v-face     . return . end. end.
    if  v-face      :handle = p-widget-handle then do:  if v-deliv-date   :sensitive then do: apply "entry":u to v-deliv-date. return . end.
                                                                                    else do: apply "entry":u to v-nac      . return . end.
                                                                                    end.
if  v-deliv-date :handle = p-widget-handle then do:  if v-start-hour        :sensitive then do: apply "entry":u to v-start-hour     . return . end. end.
if  v-start-hour :handle = p-widget-handle then do:  if v-start-min        :sensitive then do: apply "entry":u to v-start-min     . return . end. end.
if  v-start-min :handle = p-widget-handle then do:  if v-end-hour        :sensitive then do: apply "entry":u to v-end-hour     . return . end. end.
if  v-end-hour :handle = p-widget-handle then do:  if v-end-min        :sensitive then do: apply "entry":u to v-end-min     . return . end. end.
if  v-end-min :handle = p-widget-handle then do:  if v-summa-bef        :sensitive then do: apply "entry":u to v-summa-bef     . return . end. end.
    if  v-summa-bef :handle = p-widget-handle then do:  if v-Nchk-bef    :sensitive then do: apply "entry":u to v-Nchk-bef . return . end. end.
    if  v-Nchk-bef  :handle = p-widget-handle then do:  if v-date-chk    :sensitive then do: apply "entry":u to v-date-chk . return . end. end.
    if  v-date-chk  :handle = p-widget-handle then do:  if T-dost        :sensitive then do: apply "entry":u to T-dost     . return . end. end.
    if  T-dost      :handle = p-widget-handle then do:  if v-summa-dos   :sensitive then do: apply "entry":u to v-summa-dos. return . end. end.
    if  v-summa-dos :handle = p-widget-handle then do:  if v-nac         :sensitive then do: apply "entry":u to v-nac      . return . end. end.
    if  v-nac       :handle = p-widget-handle then do:  if v-kuda        :sensitive then do: apply "entry":u to v-kuda     . return . end. end.
    if  v-kuda      :handle = p-widget-handle then do:  if v-komu        :sensitive then do: apply "entry":u to v-komu     . return . end. end.
    if  v-komu      :handle = p-widget-handle then do:  if b-exit        :sensitive then do: apply "entry":u to b-exit     . return . end. end.
  end.
END PROCEDURE.
PROCEDURE save-proc :
define variable p-value  as character no-undo .
assign frame Dialog-Frame
  v-date-cr
  l-loc-hour
  l-loc-min
  v-tel
  v-face
  v-summa-bef
  v-Nchk-bef
  v-date-chk
  T-dost
  v-summa-dos
  v-nac
  v-kuda
  v-komu
  v-deliv-date
  v-start-hour
  v-start-min
  v-end-hour
  v-end-min
.
    p-value = string( v-date-cr, "99/99/9999" ) .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input '0rsrv-date':U ,
                       input p-value )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-oth in g#trdcalib ( input p-doc-code ,
                       input '0rsrv-date':U ,
                       input p-value )  .
    p-value = string(l-loc-hour, "99") + ":" + string(l-loc-min ,"99") .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input '1ord_time':U ,
                       input p-value )  .
    p-value = string(v-summa-bef) .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input '2befpay':U ,
                       input p-value )  .
    p-value = v-Nchk-bef.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input '3ord_Nchek':U ,
                       input p-value )  .
    p-value = string(v-summa-dos) .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input '5deliv':U ,
                       input p-value )  .
    p-value = string(v-nac) .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input '6sumwrk':U ,
                       input p-value )  .
    p-value  = v-face    .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input '22ord_contact':U ,
                       input p-value )  .
    p-value = v-tel     .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input '21ord_phone':U ,
                       input p-value )  .
    p-value = string(T-dost,"yes/no") .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input '4ord_dl':U ,
                       input p-value )  .
    p-value  = string(v-date-chk , "99/99/9999" )  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input '4dchek':U ,
                       input p-value )  .
    p-value  = v-kuda  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input '8ord_adr':U ,
                       input p-value )  .
    p-value  = v-komu  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input '9ord_hwo':U ,
                       input p-value )  .
    p-value  = string(v-deliv-date)  .
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input 'delivery-date':U ,
                       input p-value )  .
    p-value  = string(v-start-hour, "99") + ":" + string(v-start-min, "99") + "-" + string(v-end-hour, "99") + ":" + string(v-end-min, "99").
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input p-doc-code ,
                       input 'delivery-time':U ,
                       input p-value )  .
END PROCEDURE.
PROCEDURE sel_UI :
  DISPLAY v-date-cr l-loc-hour l-loc-min v-tel v-face v-summa-bef v-Nchk-bef
          v-date-chk T-dost v-summa-dos v-nac v-kuda v-komu v-deliv-date v-start-hour v-start-min v-end-hour v-end-min
      WITH FRAME Dialog-Frame.
      b-exit:label = "Вы&ход" .
  ENABLE b-exit B-help
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
