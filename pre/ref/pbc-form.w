define input        parameter parparentproc as   widget-handle      no-undo .
define input        parameter p-mode        as character            no-undo .
define input        parameter bc            like ub.bar-code.b-code no-undo .
define input        parameter par-shbl      like ub.prod-bc.b-str   no-undo .
define input        parameter par-EAN       as   logical            no-undo .
define input        parameter p-cdrg-type   as character no-undo .
define input-output parameter rid           as   recid              no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Форма работы с дополнительным бар-кодом":U .
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
define variable dops        as character no-undo format "X(250)":U.
define variable dopst       as character no-undo format "X(1)":U.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable send-ref as logical no-undo.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'send-ref'
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output dops
  ,output dopst
  ) no-error .
  send-ref = (IF error-status:error or dops <> "yes" then no else yes).
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE t-EAN AS LOGICAL INITIAL no
     LABEL "Только EAN"
     VIEW-AS TOGGLE-BOX
     SIZE 13 BY .83 NO-UNDO.
DEFINE VARIABLE t-NEdeMark AS LOGICAL INITIAL no
     LABEL "Требуется  маркировка"
     VIEW-AS TOGGLE-BOX
     SIZE 24 BY .83 NO-UNDO.
DEFINE QUERY d-bc-form FOR
      ub.bar-code,
      ub.prod-bc,
      ub.units,
      ub.goods SCROLLING.
DEFINE FRAME d-bc-form
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-help AT ROW 1 COL 21
     t-EAN AT ROW 2.5 COL 17
     t-NEdeMark AT ROW 2.5 COL 31
     ub.prod-bc.b-str AT ROW 3.67 COL 15 COLON-ALIGNED FORMAT "X(40)"
          VIEW-AS FILL-IN
          SIZE 41.5 BY 1
          FGCOLOR 4
     ub.bar-code.unit-cli AT ROW 4.96 COL 15 COLON-ALIGNED
          LABEL "Ед.изм."
          VIEW-AS FILL-IN
          SIZE 5.5 BY 1
     ub.units.long-name AT ROW 5 COL 22 COLON-ALIGNED NO-LABEL
          VIEW-AS FILL-IN
          SIZE 34.63 BY 1
          FGCOLOR 4
     ub.goods.unit-base AT ROW 6.25 COL 15.13 COLON-ALIGNED
          LABEL "Осн. ед. изм."
          VIEW-AS FILL-IN
          SIZE 5.25 BY 1
     ub.bar-code.cli-base-rate AT ROW 6.33 COL 35.13 COLON-ALIGNED FORMAT ">,>>9.9999999999"
          VIEW-AS FILL-IN
          SIZE 21.63 BY 1
     SPACE(3.49) SKIP(0.58)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE ""
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME d-bc-form:SCROLLABLE       = FALSE
       FRAME d-bc-form:HIDDEN           = TRUE.
ON GO OF FRAME d-bc-form
DO:
  run create-bar-code in this-procedure no-error .
  if error-status :error
  then do:
    return no-apply .
  end.
END.
ON WINDOW-CLOSE OF FRAME d-bc-form
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON RETURN OF ub.prod-bc.b-str IN FRAME d-bc-form
DO:
  apply "entry" to ub.bar-code.unit-cli in frame d-bc-form.
  return no-apply.
END.
ON leave OF prod-bc.b-str IN FRAME d-bc-form
DO:
    define variable VTXT as char no-undo.
    define variable vGtin as int64 no-undo.
    if p-cdrg-type  eq 'GTIN':U
    then do:
        vTXt = prod-bc.b-str:screen-value.
      if    length(vtxt) > 14
      then do:
         if    (length(vtxt) eq 14 + 7 + 4 + 4
             or length(vtxt) eq 14 + 7 + 4 )
         then
            prod-bc.b-str:screen-value = substring(vtxt,1,14).
         else if vtxt begins "01"
         then
            prod-bc.b-str:screen-value = substring(vtxt,3,14).
         else do:
         end.
      end.
   end.
END.
IF VALID-HANDLE (ACTIVE-WINDOW) AND FRAME d-bc-form:PARENT eq ?
THEN FRAME d-bc-form:PARENT = ACTIVE-WINDOW.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-bc-form
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
on choose of b-help in frame d-bc-form
do:
  apply "help":u to frame d-bc-form .
end.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-bc-form:width - 0.3
                fh            = frame d-bc-form:first-child
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
   VIEW FRAME d-bc-form.
   define buffer buf_prod-bc-attr for ub.prod-bc-attr.
  find ub.bar-code no-lock
    where ub.bar-code.b-code = bc
    .
  if ub.bar-code.stts_ = integer('99':U)
  or ub.bar-code.stts_ = integer('79':U)
  then do:
    message
    substitute("Собственный бар-код &1 заблокирован для удаления или логически удален", ub.bar-code.b-code) skip
    "Редактирование/добавление невозможно"
    view-as alert-box error .
    undo main-block, return error .
  end.
  find ub.goods no-lock
    where ub.goods.gds-code = ub.bar-code.gds-code
    .
  find ub.units no-lock
    where ub.units.unit-name = ub.bar-code.unit-cli
    .
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
  find first ub.prod-bc no-lock
    where ub.prod-bc.b-code = bc and ub.prod-bc.b-str = par-shbl
    .
  end.
  assign
    t-EAN = p-cdrg-type ne 'GTIN':U
    t-NEDEMark = no
  .
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
     t-NEdeMark = no .
  end.
  else do:
     display ub.prod-bc.b-str with frame d-bc-form .
      find first buf_prod-bc-attr exclusive-lock where buf_prod-bc-attr.b-str = ub.prod-bc.b-str and
         buf_prod-bc-attr.b-code = ub.prod-bc.b-code and buf_prod-bc-attr.attr-code = 'mark':U no-error .
      if available (buf_prod-bc-attr) then t-NEdeMark = logical(buf_prod-bc-attr.attr-value).
      else t-NEdeMark = no .
  end.
  display
    ub.bar-code.unit-cli
    t-EAN when p-cdrg-type ne 'GTIN':U
    t-NEDEMark when p-cdrg-type ne 'GTIN':U
    ub.bar-code.cli-base-rate
    ub.units.long-name
    ub.goods.unit-base
    with frame d-bc-form.
   if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  enable
    ub.prod-bc.b-str
    t-EAN when p-cdrg-type ne 'GTIN':U
    t-NEDEMark when p-cdrg-type ne 'GTIN':U
    b-exit
    b-help
    b-quit
    with frame d-bc-form .
  end.
  else do:
  enable
    t-NEDEMark when p-cdrg-type ne 'GTIN':U
    b-exit
    b-help
    b-quit
    with frame d-bc-form .
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  if par-EAN = no
  then do:
    assign
      t-ean = no
    .
    display
      t-EAN when p-cdrg-type ne 'GTIN':U
      with frame d-bc-form .
  end.
  end.
  if p-cdrg-type eq 'GTIN':U
  then assign
     t-EAN:visible = no
     t-NEDEMark:visible = no.
  else do:
     if p-mode = 'ДОБАВЛЕНИЕ':U then
     do:
        define buffer buf_prod-bc  for prod-bc.
        define buffer buf_gtin_bar for bar-code.
        for each buf_gtin_bar where buf_gtin_bar.gds-code  = ub.goods.gds-code
           and can-find (first buf_prod-bc
           where buf_prod-bc.b-code =  buf_gtin_bar.b-code
           and buf_prod-bc.bc-on-type = 'GTIN':U )
           no-lock:
           t-NEdeMark = yes.
        end.
        t-NEdeMark:visible = yes.
        disp t-NEdeMark with frame d-bc-form .
     end.
  end.
  if par-shbl <> ""
  then do:
    display
      par-shbl @ ub.prod-bc.b-str
      with frame d-bc-form .
  end.
  assign
    rid = ?
  .
  assign frame d-bc-form :title = "ДОПОЛНИТЕЛЬНЫЙ " + (if p-cdrg-type eq 'GTIN':U then 'GTIN':U + "                " else "бар-код                ") + p-mode.
  wait-for go of frame d-bc-form  focus ub.prod-bc.b-str.
END.
RUN disable_UI.
PROCEDURE create-bar-code :
   define variable v-b-str as character no-undo .
   define buffer buf_prod-bc for ub.prod-bc.
   define variable v-send as logical no-undo .
   v-b-str = input frame d-bc-form ub.prod-bc.b-str.
   ASSIGN frame d-bc-form t-NEdeMark.
   rid = ?.
   if p-mode = 'ДОБАВЛЕНИЕ':U then
   do:
      run trg/prod-bc2.p (
         input  parparentproc
         ,input no
         ,input no
         ,input no
         ,input send-ref
         ,input p-cdrg-type
         ,input (if logical(t-EAN:screen-value) then "EAN" else "")
         ,buffer goods
         ,input bar-code.b-code
         ,input logical(t-NEDEMark:screen-value)
         ,input-output v-b-str
         ,output rid
         ) no-error.
      if error-status :error
         or rid = ? then
      do:
         apply "entry" to ub.prod-bc.b-str in frame d-bc-form.
         undo, return error return-value .
      end.
      else
      do:
         find first buf_prod-bc no-lock
            where recid(buf_prod-bc) = rid.
         if  buf_prod-bc.bc-on
            and send-ref
            then
         do:
            run str/diallog.w
               (input parparentproc
               ,input this-procedure
               ,input 'str/s-prodbc.p':U
               ,input string(rid) + chr(4) + "U":U
               ,input yes
               ,input '':U
               ,input "Пересылка ДопБК на кассы"
               ) .
         end.
      end.
   end.
   else
   do:
      if t-NEdeMark
         then
      do:
         find first buf_prod-bc-attr exclusive-lock where buf_prod-bc-attr.b-str = ub.prod-bc.b-str and
            buf_prod-bc-attr.b-code = ub.prod-bc.b-code and buf_prod-bc-attr.attr-code = 'mark':U no-error .
         if available (buf_prod-bc-attr) then
         do:
            if logical (buf_prod-bc-attr.attr-value) <> t-NEdeMark then v-send = true .
            buf_prod-bc-attr.attr-value = "yes" .
         end.
         else
         do:
            create buf_prod-bc-attr.
            assign
               buf_prod-bc-attr.b-str      = ub.prod-bc.b-str
               buf_prod-bc-attr.b-code     = ub.prod-bc.b-code
               buf_prod-bc-attr.attr-code  = 'mark':U
               buf_prod-bc-attr.attr-value = "yes"
               .
            v-send = true .
         end.
      end.
      else
      do:
         find first buf_prod-bc-attr exclusive-lock where buf_prod-bc-attr.b-str = ub.prod-bc.b-str and
            buf_prod-bc-attr.b-code = ub.prod-bc.b-code and buf_prod-bc-attr.attr-code = 'mark':U no-error .
         if available (buf_prod-bc-attr) then
         do:
            delete buf_prod-bc-attr .
            v-send = true .
         end.
      end.
      if v-send then
      do:
         rid = recid(ub.prod-bc) .
         find first buf_prod-bc no-lock
            where recid(buf_prod-bc) = rid.
         if  buf_prod-bc.bc-on
            and send-ref
            then
         do:
            run str/diallog.w
               (input parparentproc
               ,input this-procedure
               ,input 'str/s-prodbc.p':U
               ,input string(rid) + chr(4) + "U":U
               ,input yes
               ,input '':U
               ,input "Пересылка ДопБК на кассы"
               ) .
         end.
      end.
   end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME d-bc-form.
END PROCEDURE.
