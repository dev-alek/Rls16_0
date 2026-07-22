define input        parameter p-mode   as character no-undo.
define input-output parameter p-rec-id as recid     no-undo.
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Просмотр карточки истории изменения количества по строке документа из складского места":U.
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
define buffer buf_clients  for ub.clients.
define buffer buf_object   for ub.clients.
define buffer buf_goods    for ub.goods.
define buffer buf_place    for ub.place.
define button   Btn_Exit  label "Вы&ход"  size-chars 10.00 by 1.00 default auto-end-key.
define button   Btn_OK    label "&Ввод "  size-chars 10.00 by 1.00 default auto-go.
define button b-help label "Помо&щь" size-chars 10.00 by 1.00 default.
define variable v-header as character no-undo initial " И Н Ф О Р М А Ц И Я   О   Т О В А Р Е ".
define variable v-label  as character no-undo initial " К О Л И Ч Е С Т В Е Н Н Ы Е   Х А Р А К Т Е Р И С Т И К И ".
define rectangle r-rect-0 edge-pixels 3 graphic-edge no-fill size-chars 98.25 by 1.50.
define rectangle r-rect-1 edge-pixels 2 graphic-edge no-fill size-chars 98.25 by 4.50.
define rectangle r-rect-2 edge-pixels 2 graphic-edge no-fill size-chars 98.25 by 2.25.
define frame fr-D-trn-attr-8
  ub.c-doc-pl-pump.obj-type    at row  1.25 col 16.50 colon-aligned view-as combo-box inner-lines 5 list-items "":U, 'орг':U, 'чел':U, 'скл':U, 'маг':U size-chars    6.00 by 1.00    label "Объект"
  ub.c-doc-pl-pump.obj-code    at row  1.25 col 25.00          view-as fill-in size-chars 10.50 by 1.00 no-label
  buf_object.obj-name  at row  1.25 col 36.00          view-as fill-in size-chars 63.50 by 1.00 no-label                   format "x(80)":U  fgcolor  4
  ub.c-doc-pl-pump.pl-code     at row  2.50 col 16.50 colon-aligned view-as fill-in size-chars 17.50 by 1.00    label "Складское место"
  buf_place.pl-name    at row  2.50 col 36.00          view-as fill-in size-chars 63.50 by 1.00 no-label                   format "x(80)":U  fgcolor  4
  ub.c-doc-pl-pump.pump-code   at row  3.75 col 16.50 colon-aligned view-as fill-in size-chars  3.50 by 1.00    label "ТРК"             format ">9":U
  ub.c-doc-pl-pump.out-code    at row  3.75 col 60.50 colon-aligned view-as fill-in size-chars 17.50 by 1.00    label "Документ"        format "x(16)":U  fgcolor  4
  r-rect-1             at row  5.50 col  1.50
  v-header             at row  5.00 col 29.00          view-as fill-in size-chars 40.25 by 1.00 no-label                   format "x(40)":U  fgcolor 15 bgcolor 3
  ub.c-doc-pl-pump.gds-code    at row  6.00 col 16.50 colon-aligned view-as fill-in size-chars 10.50 by 1.00    label "Код"
  buf_goods.artic      at row  7.25 col 16.50 colon-aligned view-as fill-in size-chars 17.50 by 1.00    label "Артикул"         format "x(16)":U
  buf_goods.gds-name   at row  7.25 col 36.00          view-as fill-in size-chars 63.50 by 1.00 no-label                   format "x(80)":U  fgcolor  4
  buf_goods.prod-type  at row  8.50 col 16.50 colon-aligned view-as combo-box inner-lines 5 list-items "":U, 'орг':U, 'чел':U, 'скл':U, 'маг':U size-chars    6.00 by 1.00    label "Производитель"
  buf_goods.prod-code  at row  8.50 col 25.00          view-as fill-in size-chars 10.50 by 1.00 no-label
  buf_clients.obj-name at row  8.50 col 36.00          view-as fill-in size-chars 63.50 by 1.00 no-label                   format "x(80)":U  fgcolor  4
  r-rect-2             at row 10.75 col  1.50
  v-label              at row 10.25 col 19.00          view-as fill-in size-chars 60.25 by 1.00 no-label                   format "x(60)":U  fgcolor 15 bgcolor 3
  buf_goods.unit-base  at row 11.50 col  2.50          view-as fill-in size-chars  4.00 by 1.00 no-label                   format "x(3)":U   fgcolor  4
  ub.c-doc-pl-pump.doc-qnty    at row 11.50 col 16.50 colon-aligned view-as fill-in size-chars 25.50 by 1.00    label "Заявлено"        format "->>>,>>>,>>>,>>>,>>9.999":U    fgcolor 12
  ub.c-doc-pl-pump.fact-qnty   at row 11.50 col 60.50 colon-aligned view-as fill-in size-chars 25.50 by 1.00    label "Фактически"      format "->>>,>>>,>>>,>>>,>>9.999":U    fgcolor 12
  r-rect-0             at row 13.25 col  1.50
    Btn_Exit           at row 13.50 col  2.50
    Btn_OK             at row 13.50 col 78.00
  b-help          at row 13.50 col 88.75
with view-as dialog-box side-labels no-underline three-d scrollable
     title "":U default-button Btn_Exit cancel-button Btn_Exit.
assign frame fr-D-trn-attr-8 :scrollable = no.
on choose of Btn_OK in frame fr-D-trn-attr-8 do:
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
  apply "GO":U to frame fr-D-trn-attr-8.
end.
on choose of Btn_Exit in frame fr-D-trn-attr-8 do:
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
on F1 of frame fr-D-trn-attr-8 anywhere do:
  if b-help :sensitive then DO: apply "CHOOSE":U to b-help in frame fr-D-trn-attr-8. END.
  return no-apply.
end.
if valid-handle( active-window ) and frame fr-D-trn-attr-8 :parent = ? then frame fr-D-trn-attr-8 :parent = active-window.
if current-window :window-state = window-minimized then do: current-window :window-state = window-normal. end.
on window-close of frame fr-D-trn-attr-8 do: apply "END-ERROR":U to self. end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame fr-D-trn-attr-8
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
on choose of b-help in frame fr-D-trn-attr-8
do:
  apply "help":u to frame fr-D-trn-attr-8 .
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
                v-frame-width = frame fr-D-trn-attr-8:width - 0.3
                fh            = frame fr-D-trn-attr-8:first-child
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
  find ub.c-doc-pl-pump no-lock where recid( ub.c-doc-pl-pump ) = p-rec-id no-error.
  if not available ub.c-doc-pl-pump then do:
    message
      "Карточка истории изменения количества по строке документа по складскому месту и ТРК не найдена."
    view-as alert-box error.
    undo Main-Block, leave Main-Block.
  end.
  assign frame fr-D-trn-attr-8 :title =
     substitute( 'Карточка изменения количества (товар &1) по документу "&2" (складское место &3, ТРК &4) -- &5',
                 ub.c-doc-pl-pump.gds-code, ub.c-doc-pl-pump.out-code, ub.c-doc-pl-pump.pl-code, ub.c-doc-pl-pump.pump-code, p-mode ).
  display ub.c-doc-pl-pump.obj-type
          ub.c-doc-pl-pump.obj-code
          ub.c-doc-pl-pump.pl-code
          ub.c-doc-pl-pump.pump-code
          ub.c-doc-pl-pump.out-code
          ub.c-doc-pl-pump.gds-code
          ub.c-doc-pl-pump.doc-qnty
          ub.c-doc-pl-pump.fact-qnty
          v-label
          v-header
  with frame fr-D-trn-attr-8.
  find first buf_object no-lock where
             buf_object.obj-type = ub.c-doc-pl-pump.obj-type and
             buf_object.obj-code = ub.c-doc-pl-pump.obj-code no-error.
  if available buf_object then do: display buf_object.obj-name with frame fr-D-trn-attr-8. end.
  find first buf_goods no-lock where
             buf_goods.gds-code = ub.c-doc-pl-pump.gds-code no-error.
  if available buf_goods then do:
    display buf_goods.artic
            buf_goods.prod-type
            buf_goods.prod-code
            buf_goods.gds-name
            buf_goods.unit-base
    with frame fr-D-trn-attr-8.
    find first buf_clients no-lock where
               buf_clients.obj-type = buf_goods.prod-type and
               buf_clients.obj-code = buf_goods.prod-code no-error.
    if available buf_clients then do: display buf_clients.obj-name with frame fr-D-trn-attr-8. end.
  end.
  find first buf_place no-lock where
             buf_place.obj-type = ub.c-doc-pl-pump.obj-type and
             buf_place.obj-code = ub.c-doc-pl-pump.obj-code and
             buf_place.pl-code  = ub.c-doc-pl-pump.pl-code  no-error.
  if available buf_place then do: display buf_place.pl-name with frame fr-D-trn-attr-8. end.
  enable Btn_Exit b-help with frame fr-D-trn-attr-8.
  if p-mode = 'ПРОСМОТР':U then do: hide Btn_OK in frame fr-D-trn-attr-8. end.
  wait-for go of frame fr-D-trn-attr-8.
end.
hide frame fr-D-trn-attr-8 no-pause.
