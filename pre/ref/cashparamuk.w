define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode as character no-undo.
define input parameter p-parent as character no-undo.
define input-output parameter p-rid as recid init ? no-undo.
define buffer b3-code for code .
define variable vss-revision    as character no-undo init "$Revision: $":U .
define variable vss-author      as character no-undo init "$Author: $":U .
define variable vss-date        as character no-undo init "$Date: $":U .
define variable vss-workfile    as character no-undo init "$Workfile: $":U .
define variable vss-archive     as character no-undo init "$Archive: $":U .
define variable vss-description as character no-undo init "редактирование параметров".
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
procedure sel-date :
  define input  parameter p-date-handle as handle    no-undo .
  define input  parameter p-description as character no-undo .
  do
  on error undo, return error return-value
  :
    if (can-query (p-date-handle, "sensitive")
      and
      p-date-handle :sensitive = true
      )
    or (can-query (p-date-handle, "read-only")
      and
      p-date-handle :read-only = false
      )
    then do:
      if p-date-handle :handle <> focus :handle
      then do:
        apply "entry":u to p-date-handle .
      end.
      define variable v-ok            as logical no-undo .
      define variable v-curr-sv-date as date no-undo .
      assign
        v-curr-sv-date = date(p-date-handle :screen-value) no-error
      .
      if v-curr-sv-date = ?
      then do:
        run gbl/getcurdt.p
          (output v-curr-sv-date
          ) .
      end.
      if v-curr-sv-date <> ?
      then do:
        run gbl/d-inpday.w
          (input ?
          ,input "Выбор даты"
          ,input p-description
          ,input ""
          ,input-output v-curr-sv-date
          ,output v-ok
          ).
        if v-ok = true
        then do:
          assign
            p-date-handle :screen-value = string(v-curr-sv-date) .
          .
        end.
      end.
    end.
  end.
end procedure.
define variable v-db-num like ub.db.db-num no-undo .
define variable v-name   as character no-undo .
define variable vDateIsoOld as character no-undo.
define variable mViewDop as logical no-undo.
mViewDop = num-entries (p-parent,chr(4)) eq 2.
define button B-Help
   label "Помо&щь"
   size 10 by 1
   bgcolor 8 .
define button b-quit auto-end-key
   label "&Отмена"
   size 10 by 1
   bgcolor 8 .
define button B-save auto-go
   label "&Ввод"
   size 10 by 1
   bgcolor 8 .
define variable mParentCode   as character       format "x(40)":U
   label "Функция"
   view-as combo-box
   list-item-pairs "1","1"
   size 42 by 1 no-undo.
define variable mCode   as character       format "x(20)":U
   label "Доп. Значение"
   view-as fill-in
   size 21 by 1 no-undo.
define variable mZNACH  as character    format "x(3)":U
   label "Степень защиты"
   view-as combo-box
   list-item-pairs "MGR","MGR",
   "REG","REG"
   size 20 by 1 no-undo.
define variable mDecript  as character    format "x(40)":U
   label "Наименование"
   view-as fill-in
   size 20 by 1 no-undo.
define variable fStatus as integer   init '0':U
   label "Статус"
   view-as combo-box inner-lines 2
   list-item-pairs "Обязательный",'0':U,
   "Необязательный",'1':U
   drop-down-list
   size 20 by 1 no-undo.
define frame Dialog-Frame
   B-save at row 1 col 1
   b-quit at row 1 col 11
   B-Help at row 1 col 36
   mParentCode at row 2.5 col 18 colon-aligned widget-id 8
   mCode at row 4 col 18 colon-aligned widget-id 10
   mZNACH at row 5.5 col 18 colon-aligned widget-id 12
   mDecript at row 7 col 18 colon-aligned widget-id 14
   fStatus at row 8.5 col 18 colon-aligned widget-id 16
   with view-as dialog-box keep-tab-order
   side-labels no-underline three-d  scrollable
   title "Редактирование параметра"
   default-button B-save cancel-button b-quit.
assign
   frame Dialog-Frame:SCROLLABLE = false
   frame Dialog-Frame:HIDDEN     = true.
on window-close of frame Dialog-Frame
   do:
      apply "END-ERROR":U to self.
   end.
on choose of B-save in frame Dialog-Frame
   do:
      run proc-save in this-procedure no-error.
      if error-status:error then return no-apply.
   end.
if valid-handle(active-window) and frame Dialog-Frame:PARENT eq ?
   then frame Dialog-Frame:PARENT = active-window.
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
do on error   undo MAIN-BLOCK, leave MAIN-BLOCK
   on end-key undo MAIN-BLOCK, leave MAIN-BLOCK:
   if p-mode <> 'ДОБАВЛЕНИЕ':U and
      p-mode <> 'ИЗМЕНЕНИЕ':U
      then
   do:
      message
         vss-workfile vss-revision vss-description skip
         "Неверное значение параметров вызова p-mode"  p-mode
         view-as alert-box error.
      undo, return error.
   end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
   define variable vparentpar as character no-undo.
   define variable vcodepar   as character no-undo.
   assign
      vparentpar = p-parent
      vcodepar   = entry(num-entries (vparentpar,chr(4)),vparentpar,chr(4))
      entry(num-entries (vparentpar,chr(4)),vparentpar,chr(4)) = ""
      vparentpar = trim(vparentpar,chr(4))
   no-error.
   if not error-status:error
   then do:
      find first b3-code where
         b3-code.parent  = vparentpar
         and b3-code.code    = vcodepar no-lock no-error.
      if available b3-code
         then
      do:
         frame Dialog-Frame:TITLE = "Редактирование параметра " + b3-code.codename.
         v-name = b3-code.CodeName .
      end.
   end.
   mParentCode = entry(num-entries (p-parent,chr(4)),p-parent,chr(4)).
   define variable v-list-items as character no-undo.
   define buffer code-func for ub.code.
   for each code-func where code-func.parent eq "CashFunKey" no-lock by code-func.CodeName:
      v-list-items = v-list-items + chr(44) + code-func.codename + " (" + code-func.Code + ")" + chr(44) + code-func.code .
   end.
   mParentCode:LIST-ITEM-PAIRS  in frame Dialog-Frame = trim(v-list-items,chr(44)) .
   if p-mode = 'ИЗМЕНЕНИЕ':U then
   do:
      find first b3-code where
         recid(b3-code) = p-rid exclusive-lock no-wait no-error.
      if not available b3-code then
      do:
         message
            vss-workfile vss-revision vss-description skip
            "Не найдена запись параметра"
            view-as alert-box error .
         undo, return error.
      end.
      assign
         mCode    = b3-code.code
         mZNACH   = b3-code.CodeValue
         mDecript     = b3-code.CodeName
         Fstatus  = b3-code.status_
         .
   end.
   run enable_UI in this-procedure .
   if p-mode = 'ДОБАВЛЕНИЕ':U then
   do:
      enable mCode with frame Dialog-Frame.
      apply "entry" to mCode in frame Dialog-Frame.
   end.
   wait-for go of frame Dialog-Frame.
end.
session:data-entry-return = no .
run disable_UI.
procedure disable_UI :
   hide frame Dialog-Frame.
end procedure.
procedure enable_UI :
   display mCode mZNACH fStatus mDecript mParentCode
      with frame Dialog-Frame.
   enable B-save b-quit B-Help mCode mZNACH fStatus mDecript
      with frame Dialog-Frame.
   view frame Dialog-Frame.
   if mParentCode eq  ""
   then enable mParentCode
      with frame Dialog-Frame.
end procedure.
procedure proc-save :
   define buffer b3-code for code.
   define buffer b2-code for code.
   assign frame Dialog-Frame
      mParentCode
      mCode
      mZNACH
      mDecript
      fStatus
      .
   if mZNACH eq ""
      or mZNACH eq ""
   then do:
      message "Введите степень защиты ! " view-as  alert-box  error.
      apply "entry"  to mZNACH .
      return ERROR.
   end.
   do on error undo, return error
      on stop undo, return error:
      entry(num-entries (p-parent,chr(4)),p-parent,chr(4)) = mParentCode.
      if    mParentCode eq ?
         or mParentCode eq ""
      then do:
         message "Заполните функцию"
         view-as alert-box.
         apply "entry"  to mParentCode .
         return error.
      end.
      if mCode eq ?
      then do:
         message "Код не может быть пустой"
         view-as alert-box.
         return error.
      end.
      find first b3-code where
         b3-code.parent = p-parent
         and b3-code.code   = mcode
         and if p-rid eq ? then yes else recid(b3-code) ne p-rid
         no-lock no-error.
      if avail b3-code then
      do:
         message
            "Уже есть такаой параметр :" mCode
            view-as alert-box error .
         return error.
      end.
      find first b3-code where
         recid(b3-code) eq p-rid
         exclusive-lock no-error.
      if not avail b3-code then
      do:
         create b3-code.
      end.
      assign
         b3-code.parent    = p-parent
         b3-code.code      = mcode
         b3-code.codevalue = mZNACH
         b3-code.CodeName  = mDecript
         b3-code.status_   = fStatus
         b3-code.nwsgbd    = yes
         .
      p-rid = recid(b3-code).
   end.
end procedure.
