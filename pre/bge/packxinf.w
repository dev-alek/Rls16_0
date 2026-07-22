define input parameter p-esys-id           like ub.esys-pck-sent.esys-id    no-undo.
define input parameter p-db-num            like ub.esys-pck-sent.db-num    no-undo.
define input parameter p-esps-cr-db-num    like ub.esys-pck-sent.esps-cr-db-num    no-undo.
define input parameter p-esps-pack-num     like ub.esys-pck-sent.esps-pack-num no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Информация по пакету OPENXML".
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
DEFINE BUTTON b-exit AUTO-END-KEY DEFAULT
     LABEL "&Выход"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE f-custom-pack-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Имя пакета в ВС"
     VIEW-AS FILL-IN
     SIZE 39 BY 1.07 NO-UNDO.
DEFINE VARIABLE f_CreDate AS DATE FORMAT "99/99/9999"
     LABEL "Дата создания"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.
DEFINE VARIABLE f_CreNum AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     LABEL "Кол-во формирований"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.
DEFINE VARIABLE f_CreTime AS CHARACTER FORMAT "X(8)"
     LABEL "Время создания"
     VIEW-AS FILL-IN
     SIZE 9 BY 1.
DEFINE VARIABLE f_db-num AS INTEGER FORMAT ">>>>9" INITIAL ?
     LABEL "Номер БД"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.
DEFINE VARIABLE f_esps-cr-db-num AS INTEGER FORMAT ">>>>9" INITIAL ?
     LABEL "Номер БД создания"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.
DEFINE VARIABLE f_esys-id AS INTEGER FORMAT ">>>>9" INITIAL ?
     LABEL "Номер ВС"
     VIEW-AS FILL-IN
     SIZE 6 BY 1.
DEFINE VARIABLE f_pack-num AS INTEGER FORMAT ">>>>>>>>>9" INITIAL ?
     LABEL "Номер пакета"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.
DEFINE VARIABLE f_RcvdDate AS DATE FORMAT "99/99/9999"
     LABEL "Дата"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.
DEFINE VARIABLE f_RcvdTime AS CHARACTER FORMAT "X(8)"
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 9 BY 1.
DEFINE VARIABLE f_SendTxtDate AS DATE FORMAT "99/99/9999"
     LABEL "Дата последнего"
     VIEW-AS FILL-IN
     SIZE 11 BY 1.
DEFINE VARIABLE f_SendTxtTime AS CHARACTER FORMAT "X(8)"
     LABEL "Время последнего"
     VIEW-AS FILL-IN
     SIZE 9 BY 1.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 61.6 BY 6.13.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 61.6 BY 4.5.
DEFINE RECTANGLE RECT-3
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 61.6 BY 3.5.
DEFINE QUERY pack-inf FOR
      ub.esys-pck-sent SCROLLING.
DEFINE FRAME pack-inf
     b-exit AT ROW 1 COL 1
     b-help AT ROW 1 COL 40
     f_db-num AT ROW 2.67 COL 21.5 COLON-ALIGNED
     f_esys-id AT ROW 2.67 COL 21.5 COLON-ALIGNED WIDGET-ID 2
     f_esps-cr-db-num AT ROW 2.67 COL 22.5 COLON-ALIGNED WIDGET-ID 4
     f-custom-pack-name AT ROW 3.67 COL 21.5 COLON-ALIGNED WIDGET-ID 6
     f_pack-num AT ROW 4.67 COL 21.5 COLON-ALIGNED
     f_CreDate AT ROW 5.67 COL 21.5 COLON-ALIGNED
     f_CreTime AT ROW 6.67 COL 21.5 COLON-ALIGNED
     f_CreNum AT ROW 9.8 COL 21.5 COLON-ALIGNED
     f_SendTxtDate AT ROW 10.8 COL 21.5 COLON-ALIGNED
     f_SendTxtTime AT ROW 11.8 COL 21.5 COLON-ALIGNED
     f_RcvdDate AT ROW 14.3 COL 21.5 COLON-ALIGNED
     f_RcvdTime AT ROW 15.3 COL 21.5 COLON-ALIGNED
     "Получение подтверждения" VIEW-AS TEXT
          SIZE 25.1 BY .8 AT ROW 13.3 COL 3
     "Создание файла пакета" VIEW-AS TEXT
          SIZE 22.8 BY .7 AT ROW 8.8 COL 3
     RECT-1 AT ROW 2.37 COL 1.9
     RECT-2 AT ROW 8.5 COL 1.9
     RECT-3 AT ROW 13 COL 1.9
     SPACE(6.09) SKIP(0.16)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Дополнительная информация о пакете OpenXML"
         DEFAULT-BUTTON b-exit.
ASSIGN
       FRAME pack-inf:SCROLLABLE       = FALSE
       FRAME pack-inf:HIDDEN           = TRUE.
ASSIGN
       f_db-num:HIDDEN IN FRAME pack-inf           = TRUE.
ASSIGN
       f_esps-cr-db-num:HIDDEN IN FRAME pack-inf           = TRUE.
ON WINDOW-CLOSE OF FRAME pack-inf
DO:
  APPLY "END-ERROR":U TO SELF.
END.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame pack-inf
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
on choose of b-help in frame pack-inf
do:
  apply "help":u to frame pack-inf .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame pack-inf:width - 0.3
                fh            = frame pack-inf:first-child
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
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME pack-inf:PARENT eq ?
THEN FRAME pack-inf:PARENT = ACTIVE-WINDOW.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
    define buffer buf_esys-pck-sent for ub.esys-pck-sent .
    find first buf_esys-pck-sent no-lock
      where buf_esys-pck-sent.esys-id   = p-esys-id
        and buf_esys-pck-sent.db-num   = p-db-num
        and buf_esys-pck-sent.esps-cr-db-num   = p-esps-cr-db-num
        and buf_esys-pck-sent.esps-pack-num = p-esps-pack-num
      no-error
    .
    if not available buf_esys-pck-sent then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Пакет N &1 для ВС &2 не найден.", p-esps-pack-num, p-esys-id )
        view-as alert-box error
      .
      return error .
    end.
    assign
      f_esys-id     = p-esys-id
      f_db-num      = p-db-num
      f_pack-num    = p-esps-pack-num
      f_CreDate     = buf_esys-pck-sent.esps-CreDate
      f_CreTime     = buf_esys-pck-sent.esps-CreTime
      f_CreNum      = buf_esys-pck-sent.esps-CreNum
      f_SendTxtDate = buf_esys-pck-sent.esps-SendTxtDate
      f_SendTxtTime = buf_esys-pck-sent.esps-SendTxtTime
      f_RcvdDate    = buf_esys-pck-sent.esps-rcvdDate
      f_RcvdTime    = buf_esys-pck-sent.esps-RcvdTime
      f-custom-pack-name = (if buf_esys-pck-sent.custom-pack-name = ''
                            then substitute("o&1.xml", string(p-esps-pack-num, "999999999"))
                            else buf_esys-pck-sent.custom-pack-name)
    .
  RUN enable_UI.
  WAIT-FOR GO OF FRAME pack-inf.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME pack-inf.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY f_db-num f_esys-id f-custom-pack-name f_pack-num f_CreDate f_CreTime
          f_CreNum f_SendTxtDate f_SendTxtTime f_RcvdDate f_RcvdTime
      WITH FRAME pack-inf.
  ENABLE b-exit RECT-1 RECT-2 RECT-3 b-help
      WITH FRAME pack-inf.
  VIEW FRAME pack-inf.
END PROCEDURE.
