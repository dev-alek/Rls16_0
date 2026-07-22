DEFINE TEMP-TABLE tt-rvs-line-pump NO-UNDO LIKE ub.rvs-line-pump.
define input parameter parparentproc    as widget-handle no-undo.
define input parameter p-rec-line-pump as recid     no-undo.
define input parameter p-mode          as character no-undo.
define input parameter p-title         as character no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Ввод и корректировка Данных с ТРК":U.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
define variable g-log as logical no-undo.
define buffer bf_rvs-doc          for ub.rvs-doc.
define buffer prev_icnt-line      for ub.icnt-line.
define buffer prev_rvs-line-pump  for ub.rvs-line-pump.
define buffer bf_goods            for ub.goods.
DEFINE BUTTON b-cancel AUTO-END-KEY
     LABEL "&Отменить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "&Помощь"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-save AUTO-GO
     LABEL "&Сохранить"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE QUERY Dialog-Frame FOR
      tt-rvs-line-pump SCROLLING.
DEFINE FRAME Dialog-Frame
     b-save AT ROW 1.13 COL 1.5
     b-cancel AT ROW 1.13 COL 11.75
     b-help AT ROW 1.13 COL 22.13
     tt-rvs-line-pump.meas-el-cnt AT ROW 2.46 COL 25 COLON-ALIGNED
          LABEL "Измер. электр. счетчика"
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     tt-rvs-line-pump.state-el-cnt AT ROW 2.46 COL 73.75 COLON-ALIGNED
          LABEL "Показ. электр. счетчика"
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     tt-rvs-line-pump.meas-am-cnt AT ROW 3.67 COL 25 COLON-ALIGNED
          LABEL "Сумма по измер."
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     tt-rvs-line-pump.state-am-cnt AT ROW 3.67 COL 73.75 COLON-ALIGNED
          LABEL "Сумма по показ."
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     tt-rvs-line-pump.meas-cf-cnt AT ROW 4.88 COL 25 COLON-ALIGNED
          LABEL "Кол-во наливов по измер."
          VIEW-AS FILL-IN
          SIZE 19 BY 1
     tt-rvs-line-pump.state-cf-cnt AT ROW 4.88 COL 73.75 COLON-ALIGNED
          LABEL "Кол-во наливов по показ."
          VIEW-AS FILL-IN
          SIZE 19 BY 1
     tt-rvs-line-pump.meas-mh-cnt AT ROW 6.08 COL 25 COLON-ALIGNED
          LABEL "Измер. мех. счетчика"
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     tt-rvs-line-pump.state-mh-cnt AT ROW 6.08 COL 73.75 COLON-ALIGNED
          LABEL "Показ. мех. счетчика"
          VIEW-AS FILL-IN
          SIZE 23 BY 1
     tt-rvs-line-pump.meas-mh-qnty AT ROW 7.29 COL 25 COLON-ALIGNED
          LABEL "Измер. оборот"
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-rvs-line-pump.state-mh-qnty AT ROW 7.29 COL 73.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 17 BY 1
     tt-rvs-line-pump.meas-am-qnty AT ROW 8.5 COL 25 COLON-ALIGNED
          LABEL "Измер. сумма оборота"
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     tt-rvs-line-pump.state-am-qnty AT ROW 8.5 COL 73.75 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 16 BY 1
     tt-rvs-line-pump.meas-cf-qnty AT ROW 9.71 COL 25 COLON-ALIGNED
          LABEL "Измер. кол-во наливов"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     tt-rvs-line-pump.state-cf-qnty AT ROW 9.71 COL 73.75 COLON-ALIGNED
          LABEL "Факт кол-во наливов"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
     SPACE(12.74) SKIP(0.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Данные с ТРК"
         CANCEL-BUTTON b-cancel.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-save IN FRAME Dialog-Frame
DO:
  define buffer other-line-pump for ub.rvs-line-pump.
      if input frame Dialog-Frame tt-rvs-line-pump.state-el-cnt <> tt-rvs-line-pump.state-el-cnt      then run us-state-el-cnt.   if tt-rvs-line-pump.state-el-cnt < 0 then do:      message "Показания электронного счетчика отрицательные."              "Будем сохранять?"      view-as alert-box question buttons yes-no update g-log.      if not g-log then do:         apply "entry" to state-el-cnt in frame Dialog-Frame.          return no-apply.      end.   end.
      if input frame Dialog-Frame tt-rvs-line-pump.state-mh-cnt <> tt-rvs-line-pump.state-mh-cnt      then run us-state-mh-cnt.   if tt-rvs-line-pump.state-mh-cnt < 0 then do:      message "Показания механического счетчика отрицательные."              "Будем сохранять?"      view-as alert-box question buttons yes-no update g-log.      if not g-log then do:         apply "entry" to state-mh-cnt in frame Dialog-Frame.          return no-apply.      end.   end.
      if input frame Dialog-Frame tt-rvs-line-pump.state-mh-qnty <> tt-rvs-line-pump.state-mh-qnty      then run us-state-mh-qnty.   if tt-rvs-line-pump.state-mh-qnty < 0 then do:      message "Факт оборот отрицательный."              "Будем сохранять?"      view-as alert-box question buttons yes-no update g-log.      if not g-log then do:         apply "entry" to state-mh-qnty in frame Dialog-Frame.          return no-apply.      end.   end.
      if input frame Dialog-Frame tt-rvs-line-pump.state-cf-cnt <> tt-rvs-line-pump.state-cf-cnt      then run us-state-cf-cnt.   if tt-rvs-line-pump.state-cf-cnt < 0 then do:      message "Кол-во наливов по показаниям отрицательное."              "Будем сохранять?"      view-as alert-box question buttons yes-no update g-log.      if not g-log then do:         apply "entry" to state-cf-cnt in frame Dialog-Frame.          return no-apply.      end.   end.
      if input frame Dialog-Frame tt-rvs-line-pump.state-cf-qnty <> tt-rvs-line-pump.state-cf-qnty      then run us-state-cf-qnty.   if tt-rvs-line-pump.state-cf-qnty < 0 then do:      message "Факт кол-во наливов отрицательное."              "Будем сохранять?"      view-as alert-box question buttons yes-no update g-log.      if not g-log then do:         apply "entry" to state-cf-qnty in frame Dialog-Frame.          return no-apply.      end.   end.
      if input frame Dialog-Frame tt-rvs-line-pump.state-am-cnt <> tt-rvs-line-pump.state-am-cnt      then run us-state-am-cnt.   if tt-rvs-line-pump.state-am-cnt < 0 then do:      message "Сумма по показаниям отрицательная."              "Будем сохранять?"      view-as alert-box question buttons yes-no update g-log.      if not g-log then do:         apply "entry" to state-am-cnt in frame Dialog-Frame.          return no-apply.      end.   end.
      if input frame Dialog-Frame tt-rvs-line-pump.state-am-qnty <> tt-rvs-line-pump.state-am-qnty      then run us-state-am-qnty.   if tt-rvs-line-pump.state-am-qnty < 0 then do:      message "Факт сумма оборота за смену отрицательная."              "Будем сохранять?"      view-as alert-box question buttons yes-no update g-log.      if not g-log then do:         apply "entry" to state-am-qnty in frame Dialog-Frame.          return no-apply.      end.   end.
  find first ub.rvs-line-pump where recid( ub.rvs-line-pump ) =  p-rec-line-pump no-error.
  buffer-copy tt-rvs-line-pump to ub.rvs-line-pump.
  for each other-line-pump where
           other-line-pump.rvs-code    = ub.rvs-line-pump.rvs-code    and
           other-line-pump.obj-type    = ub.rvs-line-pump.obj-type    and
           other-line-pump.obj-code    = ub.rvs-line-pump.obj-code    and
           other-line-pump.gds-code    = ub.rvs-line-pump.gds-code    and
           other-line-pump.pump-code   = ub.rvs-line-pump.pump-code   and
           other-line-pump.nozzle-code = ub.rvs-line-pump.nozzle-code :
    if recid( other-line-pump ) = p-rec-line-pump then do: next. end.
    assign other-line-pump.state-am-cnt  = ub.rvs-line-pump.state-am-cnt
           other-line-pump.state-am-qnty = ub.rvs-line-pump.state-am-qnty
           other-line-pump.state-cf-cnt  = ub.rvs-line-pump.state-cf-cnt
           other-line-pump.state-cf-qnty = ub.rvs-line-pump.state-cf-qnty
           other-line-pump.state-el-cnt  = ub.rvs-line-pump.state-el-cnt
           other-line-pump.state-mh-cnt  = ub.rvs-line-pump.state-mh-cnt
           other-line-pump.state-mh-qnty = ub.rvs-line-pump.state-mh-qnty.
  end.
END.
ON LEAVE OF tt-rvs-line-pump.state-am-cnt IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame tt-rvs-line-pump.state-am-cnt <> tt-rvs-line-pump.state-am-cnt then do:
  run us-state-am-cnt no-error.
  if error-status:error then return no-apply.
end.
END.
ON return OF tt-rvs-line-pump.state-am-cnt IN FRAME Dialog-Frame
DO:
   apply "entry" to tt-rvs-line-pump.state-cf-cnt in frame Dialog-Frame.
 return no-apply.
END.
ON LEAVE OF tt-rvs-line-pump.state-am-qnty IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame tt-rvs-line-pump.state-am-qnty <> tt-rvs-line-pump.state-am-qnty then do:
  run us-state-am-qnty no-error.
  if error-status:error then return no-apply.
end.
END.
ON return OF tt-rvs-line-pump.state-am-qnty IN FRAME Dialog-Frame
DO:
   apply "entry" to tt-rvs-line-pump.state-cf-qnty in frame Dialog-Frame.
 return no-apply.
END.
ON LEAVE OF tt-rvs-line-pump.state-cf-cnt IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame tt-rvs-line-pump.state-cf-cnt <> tt-rvs-line-pump.state-cf-cnt then do:
  run us-state-cf-cnt no-error.
  if error-status:error then return no-apply.
end.
END.
ON return OF tt-rvs-line-pump.state-cf-cnt IN FRAME Dialog-Frame
DO:
   apply "entry" to tt-rvs-line-pump.state-mh-cnt in frame Dialog-Frame.
 return no-apply.
END.
ON LEAVE OF tt-rvs-line-pump.state-cf-qnty IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame tt-rvs-line-pump.state-cf-qnty <> tt-rvs-line-pump.state-cf-qnty then do:
  run us-state-cf-qnty no-error.
  if error-status:error then return no-apply.
end.
END.
ON return OF tt-rvs-line-pump.state-cf-qnty IN FRAME Dialog-Frame
DO:
   apply "entry" to b-save in frame Dialog-Frame.
 return no-apply.
END.
ON LEAVE OF tt-rvs-line-pump.state-el-cnt IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame tt-rvs-line-pump.state-el-cnt <> tt-rvs-line-pump.state-el-cnt then do:
  run us-state-el-cnt no-error.
  if error-status:error then return no-apply.
end.
END.
ON return OF tt-rvs-line-pump.state-el-cnt IN FRAME Dialog-Frame
DO:
 apply "entry" to tt-rvs-line-pump.state-am-cnt in frame Dialog-Frame.
 return no-apply.
END.
ON LEAVE OF tt-rvs-line-pump.state-mh-cnt IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame tt-rvs-line-pump.state-mh-cnt <> tt-rvs-line-pump.state-mh-cnt then do:
  run us-state-mh-cnt no-error.
  if error-status:error then return no-apply.
end.
END.
ON return OF tt-rvs-line-pump.state-mh-cnt IN FRAME Dialog-Frame
DO:
   apply "entry" to tt-rvs-line-pump.state-mh-qnty in frame Dialog-Frame.
 return no-apply.
END.
ON LEAVE OF tt-rvs-line-pump.state-mh-qnty IN FRAME Dialog-Frame
DO:
if input frame Dialog-Frame tt-rvs-line-pump.state-mh-qnty <> tt-rvs-line-pump.state-mh-qnty then do:
  run us-state-mh-qnty no-error.
  if error-status:error then return no-apply.
end.
END.
ON return OF tt-rvs-line-pump.state-mh-qnty IN FRAME Dialog-Frame
DO:
   apply "entry" to tt-rvs-line-pump.state-am-qnty in frame Dialog-Frame.
 return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if p-mode = 'ИЗМЕНЕНИЕ':U then
     find first ub.rvs-line-pump where recid(ub.rvs-line-pump) =  p-rec-line-pump no-error.
  else
     find first ub.rvs-line-pump where recid(ub.rvs-line-pump) =  p-rec-line-pump no-lock no-error.
  if not available ub.rvs-line-pump then do:
     message "Неверно переданы параметры."
             "Не найдена строка данных с ТРК с recid " p-rec-line-pump " ."
     view-as alert-box error.
     return error.
  end.
  create tt-rvs-line-pump.
  buffer-copy ub.rvs-line-pump to tt-rvs-line-pump.
  release ub.rvs-line-pump.
  if p-mode = 'ИЗМЕНЕНИЕ':U then
  find first bf_rvs-doc where bf_rvs-doc.rvs-code = tt-rvs-line-pump.rvs-code.
  else find first bf_rvs-doc where bf_rvs-doc.rvs-code = tt-rvs-line-pump.rvs-code no-lock.
  RUN enable_UI.
  if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
     disable tt-rvs-line-pump.state-el-cnt tt-rvs-line-pump.state-am-cnt tt-rvs-line-pump.state-cf-cnt tt-rvs-line-pump.state-mh-cnt tt-rvs-line-pump.state-mh-qnty tt-rvs-line-pump.state-am-qnty tt-rvs-line-pump.state-cf-qnty with frame Dialog-Frame.
  end.
  if p-mode <> 'ИЗМЕНЕНИЕ':U then
    disable b-save with frame Dialog-Frame.
   if tt-rvs-line-pump.icnt-code <> ? then do:
      find prev_icnt-line where prev_icnt-line.doc-code    = tt-rvs-line-pump.icnt-code   and
                                prev_icnt-line.obj-type    = tt-rvs-line-pump.obj-type    and
                                prev_icnt-line.obj-code    = tt-rvs-line-pump.obj-code    and
                                prev_icnt-line.pump-code   = tt-rvs-line-pump.pump-code   and
                                prev_icnt-line.nozzle-code = tt-rvs-line-pump.nozzle-code no-lock no-error.
      if not available prev_icnt-line then do:
         message "Фатальная ошибка. Нет инвентаризации счетчика № " tt-rvs-line-pump.icnt-code " !" skip
              "Объект: " tt-rvs-line-pump.obj-type " " tt-rvs-line-pump.obj-code skip
              "ТРК: " tt-rvs-line-pump.pump-code skip
              "Пистолет: " tt-rvs-line-pump.nozzle-code
         view-as alert-box error.
      end.
   end.
   if tt-rvs-line-pump.rvs-prev-code <> ? then do:
      find first prev_rvs-line-pump where prev_rvs-line-pump.rvs-code    = tt-rvs-line-pump.rvs-prev-code and
                                          prev_rvs-line-pump.obj-type    = tt-rvs-line-pump.obj-type      and
                                          prev_rvs-line-pump.obj-code    = tt-rvs-line-pump.obj-code      and
                                          prev_rvs-line-pump.pl-code     = tt-rvs-line-pump.pl-code       and
                                          prev_rvs-line-pump.gds-code    = tt-rvs-line-pump.gds-code      and
                                          prev_rvs-line-pump.pump-code   = tt-rvs-line-pump.pump-code     and
                                          prev_rvs-line-pump.nozzle-code = tt-rvs-line-pump.nozzle-code   no-lock no-error.
      if not available prev_rvs-line-pump then do:
         find first bf_goods where bf_goods.gds-code = tt-rvs-line-pump.gds-code no-lock.
         message "Фатальная ошибка. Нет сверки № " tt-rvs-line-pump.rvs-prev-code " !" skip
              "Объект: " tt-rvs-line-pump.obj-type " " tt-rvs-line-pump.obj-code skip
              "Складское место: " tt-rvs-line-pump.pl-code skip
              "Товар: " bf_goods.artic " " bf_goods.prod-type " " bf_goods.prod-code " " bf_goods.gds-name skip
              "ТРК: " tt-rvs-line-pump.pump-code skip
              "Пистолет: " tt-rvs-line-pump.nozzle-code
         view-as alert-box error.
      end.
   end.
  assign frame Dialog-Frame:title = frame Dialog-Frame:title + " - " + p-mode
  + " - " +  p-title.
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-rvs-line-pump SHARE-LOCK.
  GET FIRST Dialog-Frame.
  IF AVAILABLE tt-rvs-line-pump THEN
    DISPLAY tt-rvs-line-pump.meas-el-cnt tt-rvs-line-pump.state-el-cnt
          tt-rvs-line-pump.meas-am-cnt tt-rvs-line-pump.state-am-cnt
          tt-rvs-line-pump.meas-cf-cnt tt-rvs-line-pump.state-cf-cnt
          tt-rvs-line-pump.meas-mh-cnt tt-rvs-line-pump.state-mh-cnt
          tt-rvs-line-pump.meas-mh-qnty tt-rvs-line-pump.state-mh-qnty
          tt-rvs-line-pump.meas-am-qnty tt-rvs-line-pump.state-am-qnty
          tt-rvs-line-pump.meas-cf-qnty tt-rvs-line-pump.state-cf-qnty
      WITH FRAME Dialog-Frame.
  ENABLE b-save b-cancel b-help tt-rvs-line-pump.state-el-cnt
         tt-rvs-line-pump.state-am-cnt tt-rvs-line-pump.state-cf-cnt
         tt-rvs-line-pump.state-mh-cnt tt-rvs-line-pump.state-mh-qnty
         tt-rvs-line-pump.state-am-qnty tt-rvs-line-pump.state-cf-qnty
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE us-state-am-cnt :
assign frame Dialog-Frame tt-rvs-line-pump.state-am-cnt.
assign tt-rvs-line-pump.state-am-qnty = tt-rvs-line-pump.state-am-cnt -
                                        (if tt-rvs-line-pump.rvs-prev-code <> ? then
                                         prev_rvs-line-pump.state-am-cnt else ?).
display tt-rvs-line-pump.state-am-qnty with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE us-state-am-qnty :
assign frame Dialog-Frame tt-rvs-line-pump.state-am-qnty.
assign tt-rvs-line-pump.state-am-cnt = tt-rvs-line-pump.state-am-qnty +
                                        (if tt-rvs-line-pump.rvs-prev-code <> ? then
                                         prev_rvs-line-pump.state-am-cnt else ?).
display tt-rvs-line-pump.state-am-cnt with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE us-state-cf-cnt :
assign frame Dialog-Frame tt-rvs-line-pump.state-cf-cnt.
assign tt-rvs-line-pump.state-cf-qnty = tt-rvs-line-pump.state-cf-cnt -
                                        (if tt-rvs-line-pump.rvs-prev-code <> ? then
                                         prev_rvs-line-pump.state-cf-cnt else ?).
display tt-rvs-line-pump.state-cf-qnty with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE us-state-cf-qnty :
assign frame Dialog-Frame tt-rvs-line-pump.state-cf-qnty.
assign tt-rvs-line-pump.state-cf-cnt = tt-rvs-line-pump.state-cf-qnty +
                                        (if tt-rvs-line-pump.rvs-prev-code <> ? then
                                         prev_rvs-line-pump.state-cf-cnt else ?).
display tt-rvs-line-pump.state-cf-cnt with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE us-state-el-cnt :
assign frame Dialog-Frame tt-rvs-line-pump.state-el-cnt.
assign tt-rvs-line-pump.state-mh-cnt = tt-rvs-line-pump.state-el-cnt -
                                       (if tt-rvs-line-pump.icnt-code <> ? then (prev_icnt-line.state-el-cnt - prev_icnt-line.state-mh-cnt) else 0)
       tt-rvs-line-pump.state-mh-qnty = tt-rvs-line-pump.state-mh-cnt -
                                       (if tt-rvs-line-pump.rvs-prev-code <> ? then prev_rvs-line-pump.state-mh-cnt else ?).
display tt-rvs-line-pump.state-mh-cnt tt-rvs-line-pump.state-mh-qnty with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE us-state-mh-cnt :
assign frame Dialog-Frame tt-rvs-line-pump.state-mh-cnt.
assign tt-rvs-line-pump.state-el-cnt = tt-rvs-line-pump.state-mh-cnt +
                                       (if tt-rvs-line-pump.icnt-code <> ? then (prev_icnt-line.state-el-cnt - prev_icnt-line.state-mh-cnt) else 0)
       tt-rvs-line-pump.state-mh-qnty = tt-rvs-line-pump.state-mh-cnt -
                                        (if tt-rvs-line-pump.rvs-prev-code <> ? then prev_rvs-line-pump.state-mh-cnt else ?).
display tt-rvs-line-pump.state-el-cnt tt-rvs-line-pump.state-mh-qnty with frame Dialog-Frame.
END PROCEDURE.
PROCEDURE us-state-mh-qnty :
assign frame Dialog-Frame tt-rvs-line-pump.state-mh-qnty.
assign  tt-rvs-line-pump.state-mh-cnt = tt-rvs-line-pump.state-mh-qnty +
                                       (if available prev_rvs-line-pump then prev_rvs-line-pump.state-mh-cnt else ?).
        tt-rvs-line-pump.state-el-cnt = tt-rvs-line-pump.state-mh-cnt +
                                       (if tt-rvs-line-pump.icnt-code <> ? then (prev_icnt-line.state-el-cnt - prev_icnt-line.state-mh-cnt) else ?).
display tt-rvs-line-pump.state-el-cnt tt-rvs-line-pump.state-mh-cnt with frame Dialog-Frame.
END PROCEDURE.
