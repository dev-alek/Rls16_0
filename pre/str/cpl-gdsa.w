define input        parameter p-mode   as character no-undo.
define input-output parameter p-rec-id as recid     no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Просмотр карточки истории изменения хранения товара на складском месте":U.
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
define buffer bf_obj   for ub.clients.
define buffer bf_cli   for ub.clients.
define buffer bf_place for ub.place.
define buffer bf_goods for ub.goods.
define button   Btn_Exit  label "Вы&ход"  size-chars 10.00 by 1.00 default auto-end-key.
define button   Btn_OK    label "&Ввод "  size-chars 10.00 by 1.00 default auto-go.
define button b-help label "Помо&щь" size-chars 10.00 by 1.00 default.
define variable v-header as character no-undo initial " И Н Ф О Р М А Ц И Я   О   Т О В А Р Е ".
define variable v-label  as character no-undo initial " К О Л И Ч Е С Т В Е Н Н Ы Е   Х А Р А К Т Е Р И С Т И К И ".
define rectangle r-rect-0 edge-pixels 3 graphic-edge no-fill size-chars 98.25 by 1.50.
define rectangle r-rect-1 edge-pixels 2 graphic-edge no-fill size-chars 98.25 by 4.50.
define rectangle r-rect-2 edge-pixels 2 graphic-edge no-fill size-chars 98.25 by 3.75.
define frame fr-D-pump-8
  ub.c-pl-gds.pl-code     at row  1.25 col 18.00 colon-aligned view-as fill-in    size-chars 10.50 by 1.00    label "Складское место"
  bf_place.pl-name     at row  1.25 col 31.00          view-as fill-in    size-chars 68.50 by 1.00 no-label format "x(80)":U   fgcolor  4
  ub.c-pl-gds.obj-type    at row  2.50 col 18.00 colon-aligned view-as combo-box inner-lines 5 list-items "":U, 'орг':U, 'чел':U, 'скл':U, 'маг':U size-chars    6.00 by 1.00    label "Объект"
  ub.c-pl-gds.obj-code    at row  2.50 col 26.50          view-as fill-in    size-chars 10.50 by 1.00 no-label
    bf_obj.obj-name    at row  2.50 col 37.50          view-as fill-in    size-chars 62.00 by 1.00 no-label format "x(80)":U   fgcolor  4
  r-rect-1             at row  4.50 col  1.50
  v-header             at row  4.00 col 29.00          view-as fill-in    size-chars 40.25 by 1.00 no-label format "x(40)":U   fgcolor 15 bgcolor 3
  ub.c-pl-gds.gds-code    at row  5.00 col 18.00 colon-aligned view-as fill-in    size-chars 10.50 by 1.00    label "Код"              fgcolor  4
  bf_goods.artic       at row  5.00 col 38.50          view-as fill-in    size-chars 17.50 by 1.00    label "Артикул"
  bf_goods.prod-type   at row  6.25 col 18.00 colon-aligned view-as combo-box inner-lines 5 list-items "":U, 'орг':U, 'чел':U, 'скл':U, 'маг':U size-chars    6.00 by 1.00    label "Производитель"
  bf_goods.prod-code   at row  6.25 col 26.50          view-as fill-in    size-chars 10.50 by 1.00 no-label
    bf_cli.obj-name    at row  6.25 col 37.50          view-as fill-in    size-chars 62.00 by 1.00 no-label format "x(80)":U   fgcolor  4
  bf_goods.gds-name    at row  7.50 col 18.00 colon-aligned view-as fill-in    size-chars 61.50 by 1.00    label "Название"         fgcolor  4
  r-rect-2             at row  8.92 col  1.50
  v-label              at row  8.58 col 19.00          view-as fill-in    size-chars 60.25 by 1.00 no-label format "x(60)":U   fgcolor 15 bgcolor 3
  ub.c-pl-gds.fact-qnty   at row 10.00 col 18.00 colon-aligned view-as fill-in    size-chars 16.50 by 1.00    label "Факт"             fgcolor 12
  ub.c-pl-gds.free-qnty   at row 10.00 col 37.50          view-as fill-in    size-chars 16.50 by 1.00    label "Свободно"         fgcolor 12
  ub.c-pl-gds.tolerance   at row 10.00 col 58.00          view-as fill-in    size-chars 13.50 by 1.00                             fgcolor 12
  ub.c-pl-gds.cli-qnty    at row 11.25 col 18.00 colon-aligned view-as fill-in    size-chars 16.50 by 1.00                             fgcolor 12
  ub.c-pl-gds.max-qnty    at row 11.25 col 56.00          view-as fill-in    size-chars 16.50 by 1.00                             fgcolor 12
  "СВЕРКА:"            at row 13.25 col 11.50                                                               fgcolor 15 bgcolor 3
  ub.c-pl-gds.rvs-on      at row 13.25 col 20.50          view-as toggle-box size-chars  16.50 by 1.00    label "включена"
  ub.c-pl-gds.rvs-code    at row 13.25 col 40.50          view-as fill-in    size-chars 17.50 by 1.00    label "номер"
  ub.c-pl-gds.status_     at row 14.75 col 18.00 colon-aligned view-as fill-in    size-chars  9.50 by 1.00
  ub.c-pl-gds.PS          at row 16.25 col  1.50          view-as editor no-word-wrap scrollbar-horizontal scrollbar-vertical size-chars 98.25 by 3.50 format "x(512)":U                no-label                    bgcolor 15
    r-rect-0           at row 20.25 col  1.50
    Btn_Exit           at row 20.50 col  2.50
    Btn_OK             at row 20.50 col 78.00
  b-help          at row 20.50 col 88.75
with view-as dialog-box side-labels no-underline three-d scrollable
     title "":U default-button Btn_Exit cancel-button Btn_Exit.
assign frame fr-D-pump-8 :scrollable = no.
on choose of Btn_OK in frame fr-D-pump-8 do:
define variable vss-include-info0 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  apply "GO":U to frame fr-D-pump-8.
end.
on choose of Btn_Exit in frame fr-D-pump-8 do:
define variable vss-include-info1 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
end.
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F1 of frame fr-D-pump-8 anywhere do:
  if b-help :sensitive then DO: apply "CHOOSE":U to b-help in frame fr-D-pump-8. END.
  return no-apply.
end.
if valid-handle( active-window ) and frame fr-D-pump-8 :parent = ? then frame fr-D-pump-8 :parent = active-window.
if current-window :window-state = window-minimized then do: current-window :window-state = window-normal. end.
on window-close of frame fr-D-pump-8 do: apply "END-ERROR":U to self. end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame fr-D-pump-8
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
on choose of b-help in frame fr-D-pump-8
do:
  apply "help":u to frame fr-D-pump-8 .
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
                v-frame-width = frame fr-D-pump-8:width - 0.3
                fh            = frame fr-D-pump-8:first-child
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
Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :
  if p-mode <> 'ПРОСМОТР':U then do:
    message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
            "Неверное значение параметра вызова p-mode:" p-mode
    view-as alert-box error.
    undo Main-Block, return error.
  end.
  find ub.c-pl-gds no-lock where recid( ub.c-pl-gds ) = p-rec-id no-error.
  if not available ub.c-pl-gds then do:
    message "Карточка истории хранения товара на складском месте не найдена!" view-as alert-box error.
    undo Main-Block, leave Main-Block.
  end.
  find first bf_goods no-lock where bf_goods.gds-code = ub.c-pl-gds.gds-code no-error.
  find first bf_place no-lock where
             bf_place.obj-type = ub.c-pl-gds.obj-type and
             bf_place.obj-code = ub.c-pl-gds.obj-code and
             bf_place.pl-code  = ub.c-pl-gds.pl-code  no-error.
  find first bf_obj   no-lock where
             bf_obj.obj-type   = ub.c-pl-gds.obj-type and
             bf_obj.obj-code   = ub.c-pl-gds.obj-code no-error.
  find first bf_cli   no-lock where
             bf_cli.obj-type   = bf_goods.prod-type and
             bf_cli.obj-code   = bf_goods.prod-code no-error.
  assign frame fr-D-pump-8 :title = substitute(
    'Карточка изменения хранения товара &1 "&2" на складском месте &3 "&4" (объект &5 &6 "&7") -- &8',
    ub.c-pl-gds.gds-code,
    bf_goods.gds-name,
    ub.c-pl-gds.pl-code,
    bf_place.pl-name,
    ub.c-pl-gds.obj-type,
    ub.c-pl-gds.obj-code,
    bf_obj.obj-name,
    p-mode ).
  display ub.c-pl-gds.pl-code
          ub.c-pl-gds.gds-code
          ub.c-pl-gds.obj-type  when ub.c-pl-gds.obj-type <> ?
          ub.c-pl-gds.obj-code
          ub.c-pl-gds.status_
          ub.c-pl-gds.fact-qnty
          ub.c-pl-gds.free-qnty
          ub.c-pl-gds.tolerance
          ub.c-pl-gds.cli-qnty
          ub.c-pl-gds.max-qnty
          ub.c-pl-gds.rvs-on
          ub.c-pl-gds.rvs-code  when ub.c-pl-gds.rvs-on = yes and ub.c-pl-gds.rvs-code <> ?
          ub.c-pl-gds.PS
          v-header
          v-label
  with frame fr-D-pump-8.
  if ub.c-pl-gds.rvs-on <> yes then do: hide ub.c-pl-gds.rvs-code in frame fr-D-pump-8. end.
  if available bf_goods then do:
    display bf_goods.artic
            bf_goods.prod-type when bf_goods.prod-type <> ?
            bf_goods.prod-code
            bf_goods.gds-name
    with frame fr-D-pump-8.
  end.
  if available bf_cli   then do: display bf_cli.obj-name  with frame fr-D-pump-8. end.
  if available bf_obj   then do: display bf_obj.obj-name  with frame fr-D-pump-8. end.
  if available bf_place then do: display bf_place.pl-name with frame fr-D-pump-8. end.
  enable ub.c-pl-gds.PS Btn_Exit b-help with frame fr-D-pump-8.
  assign ub.c-pl-gds.PS :read-only in frame fr-D-pump-8 = yes.
  if p-mode = 'ПРОСМОТР':U then do: hide Btn_OK in frame fr-D-pump-8. end.
  wait-for go of frame fr-D-pump-8.
end.
hide frame fr-D-pump-8 no-pause.
