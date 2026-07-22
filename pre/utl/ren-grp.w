define input  parameter p-node-code as integer   no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Создание симметричной шкалы признаков".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
define variable sc-name like ub.gds-prt.node-name format "x(40)" label "Название шкалы" no-undo.
def temp-table temp-level no-undo
    field num  as integer
    field ord  as integer
    field name like ub.gds-prt.node-name
    index num is primary unique num .
def temp-table temp-node no-undo
    field num  as integer
    field ord  as integer
    field name like ub.gds-prt.node-name
    index num  is primary unique num ord.
def query temp-level for temp-level .
def browse temp-level query temp-level
       disp temp-level.name
       with size 35 by 10 no-labels title "Уровни".
def query temp-node for temp-node .
def browse temp-node query temp-node
       display temp-node.name
       with size 35 by 10 no-labels title "Признаки".
def button b-exit auto-go default
     LABEL "&Выход"
     SIZE 10 BY 1.
def button b-help
    label "Помо&щь"
     SIZE 10 BY 1.
def button b-upd-nd
    label "&Изменить"
     SIZE 10 BY 1.
DEF FRAME td
  b-exit     AT ROW  1   COL  1
  b-help     AT ROW  1   COL 11
  sc-name    AT ROW  2.5 COL  5
  temp-level AT ROW  4   COL  1
  temp-node  AT ROW  4   COL 37
  b-upd-nd   AT ROW 14.5 COL 45
WITH VIEW-AS DIALOG-BOX SCROLLABLE SIDE-LABELS THREE-D DEFAULT-BUTTON b-exit TITLE "".
on go of frame td do:
end.
on choose of b-upd-nd
or return of temp-node
or default-action of temp-node
do:
  run upd-nd in this-procedure .
end.
ON WINDOW-CLOSE OF FRAME td APPLY "END-ERROR":U TO SELF.
on value-changed of temp-level in frame td do:
  run open-temp-node in this-procedure .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame td
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
on choose of b-help in frame td
do:
  apply "help":u to frame td .
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
                v-frame-width = frame td:width - 0.3
                fh            = frame td:first-child
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
do
on error undo, return error return-value
:
  assign
    frame td :title = "Шкала"
  .
  run open-all in this-procedure .
  temp-level :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
  temp-node :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
  enable
    temp-level temp-node b-exit b-upd-nd b-help
    with frame td.
  wait-for go of frame td.
end.
procedure prt-tree :
  def input param uc like ub.gds-prt.upper-code no-undo.
  def buffer buf_gds-prt   for ub.gds-prt.
  define variable nc         as int no-undo.
  define variable next-level as log no-undo.
  find first buf_gds-prt where buf_gds-prt.upper-code = uc.
  find temp-level where temp-level.num = buf_gds-prt.lvl-num.
  assign
    temp-level.ord = 0
    nc = buf_gds-prt.node-code
    .
  if can-find (first buf_gds-prt where buf_gds-prt.upper-code = nc)
  then do:
    next-level = yes.
  end.
  else do:
    next-level = no.
  end.
  for each buf_gds-prt
    where buf_gds-prt.upper-code = uc
  :
    if buf_gds-prt.prt-num > temp-level.ord
    then do:
      assign
        temp-level.ord = buf_gds-prt.prt-num
      .
    end.
    create temp-node.
    assign
      temp-node.num  = buf_gds-prt.lvl-num
      temp-node.ord  = buf_gds-prt.prt-num
      temp-node.name = buf_gds-prt.node-name
    .
  end.
  if next-level
  then do:
    run prt-tree (nc).
  end.
end procedure.
PROCEDURE upd-nd :
  define variable ri as recid no-undo .
  if not available temp-node
  then do:
    return .
  end.
  define variable v-node-name as character no-undo .
  assign
    v-node-name = temp-node.name
  .
  run gbl/d-prompt.w (
      'title=':u + "Имя признака" + '\':u
    + 'text1=':u + "Имя признака" + '\':u
    + 'format=x(16)\':u
    + 'type=char\':u
    ,input-output v-node-name
    ).
  if return-value = 'false':u then do:
    return .
  end.
  if v-node-name = ""
  then do:
    message
      "Не задано значение признака" skip
      view-as alert-box information .
    return .
  end.
  if can-find(first temp-node
    where temp-node.num = temp-level.num
      and temp-node.name = v-node-name
      and recid( temp-node ) <> ri )
  then do:
    message
      "Признак" v-node-name "уже есть" skip
      view-as alert-box information .
    return .
  end.
  run utl/rengdprt.p
    (input p-node-code
    ,input temp-level.num
    ,input temp-node.name
    ,input v-node-name
    ) .
  run open-all in this-procedure .
END PROCEDURE.
procedure open-temp-level :
  do
  on error undo, return error return-value
  :
    open query temp-level for each temp-level.
  end.
end procedure.
procedure open-temp-node :
  do
  on error undo, return error return-value
  :
    open query temp-node for each temp-node where temp-node.num = temp-level.num.
  end.
end procedure.
procedure open-all :
  do
  on error undo, return error return-value
  :
    find ub.gds-prt
      where ub.gds-prt.node-code = p-node-code
      .
    if ub.gds-prt.node-name = '_Пустая шкала':U
    then do:
      message
        "Изменение пустой шкалы невозможно."
        view-as alert-box error.
      undo, return error return-value .
    end.
    assign
      sc-name  = ub.gds-prt.node-name
    .
    for each temp-level
    :
      delete temp-level .
    end.
    for each temp-node
    :
      delete temp-node .
    end.
    for each ub.lvl-name
      where lvl-name.upper-code = ub.gds-prt.upper-code
    :
      create temp-level.
      assign
        temp-level.num = ub.lvl-name.level
        temp-level.name = ub.lvl-name.lvl-name
      .
    end.
    run prt-tree in this-procedure
      (input p-node-code
      ).
    disp sc-name with frame td.
    run open-temp-level in this-procedure .
    run open-temp-node in this-procedure .
  end.
end procedure.
