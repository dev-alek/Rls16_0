block-level on error undo, throw.
define input  parameter p-node-code      like ub.gds-prt.node-code no-undo .
define input  parameter p-sort-level     as integer   no-undo .
define input  parameter p-start-from-max as logical   no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: srtgdprt.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: utl/srtgdprt.p $":U .
define variable vss-description as character no-undo initial "Сортировка признаков заданного уровня шкалы".
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
    assign
      p-vss-parameters = substitute('&1|&2':u,p-node-code,p-sort-level)
    .
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
define temp-table temp-node no-undo   field level-num as integer   field name      as character   index xpk is primary unique level-num name   .
define temp-table temp-node-list no-undo   field node-code as integer   field upper-code as integer   field level-num as integer   field order     as integer   field sort-order as integer   field node-name  as character   index xpk is primary level-num upper-code node-name   index xie1 upper-code node-name   index xie2 node-code   index xie3 sort-order   .
do
on error undo, return error return-value
:
  run validate-parameter in this-procedure
    (input p-node-code
    ,input p-sort-level
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  define buffer lock_gds-prt for ub.gds-prt .
  do transaction
  on error undo, return error return-value
  :
    find first lock_gds-prt exclusive-lock
      where lock_gds-prt.node-code = p-node-code
      .
  end.
  run fill-root-level in this-procedure
    (input p-node-code
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке целостности шкалы" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  run fill-levels in this-procedure
    (input p-node-code
    ,input 1
    ,input p-sort-level
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке целостности шкалы" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  run renumber-level-sort in this-procedure
    (input p-sort-level
    ,input p-start-from-max
    ) .
  run store-level-sort in this-procedure
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при сохранении порядка сортировки" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
end.
procedure validate-parameter :
  define input  parameter p-node-code like ub.gds-prt.node-code no-undo .
  define input  parameter p-level     as integer   no-undo .
  define buffer buf_gds-prt for ub.gds-prt .
  define buffer buf_db for ub.db .
  do
  on error undo, return error return-value
  :
    find first buf_gds-prt share-lock
      where buf_gds-prt.node-code = p-node-code
      no-error .
    if not available buf_gds-prt then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найдена шкала" skip
        "Номер шкалы" p-node-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_gds-prt.root <> true then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Указан номер не корневого признака" skip
        "Номер шкалы" p-node-code skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-prt-level as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtlevel in g#library
  (input  p-node-code
  ,output v-prt-level
  )  .
    if p-level < 1
    or p-level >= v-prt-level
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неправильный номер уровня" skip
        "Номер шкалы" p-node-code skip
        "Размер шкалы" v-prt-level skip
        "Задана сортировка уровня" p-level skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-office as logical   no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run currdbat in g#library
  (input  'office=request':u
  ,output v-office
  )  .
    if v-office = false
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Процедура сортировки шкалы может запускаться только в ГБД"
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure fill-root-level :
  define input  parameter p-node-code like ub.gds-prt.node-code no-undo .
  define buffer buf_gds-prt for ub.gds-prt .
  define buffer buf_temp-node for temp-node .
  define buffer buf_temp-node-list for temp-node-list .
  do
  on error undo, return error return-value
  :
    find first buf_gds-prt share-lock
      where buf_gds-prt.node-code = p-node-code
      .
    create buf_temp-node .
    assign
      buf_temp-node.level-num = 0
      buf_temp-node.name      = buf_gds-prt.node-name
    .
    create buf_temp-node-list .
    assign
      buf_temp-node-list.node-code  = buf_gds-prt.node-code
      buf_temp-node-list.upper-code = buf_gds-prt.upper-code
      buf_temp-node-list.level-num  = 0
      buf_temp-node-list.order      = buf_gds-prt.prt-num
      buf_temp-node-list.node-name  = buf_gds-prt.node-name
    .
  end.
end procedure.
procedure fill-levels :
  define input  parameter p-node-code like ub.gds-prt.node-code no-undo .
  define input  parameter p-level     as integer   no-undo .
  define input  parameter p-prt-level as integer   no-undo .
  define buffer buf_gds-prt for ub.gds-prt .
  define buffer buf_temp-node for temp-node .
  define buffer buf_temp-node-list for temp-node-list .
  do
  on error undo, return error return-value
  :
    find first buf_temp-node
      where buf_temp-node.level-num = p-level
      no-error .
    if not available buf_temp-node
    then do:
      for each buf_gds-prt share-lock
        where buf_gds-prt.upper-code = p-node-code
      on error undo, return error return-value
      :
        create buf_temp-node .
        assign
          buf_temp-node.level-num = p-level
          buf_temp-node.name      = buf_gds-prt.node-name
        .
      end.
    end.
    for each buf_gds-prt share-lock
      where buf_gds-prt.upper-code = p-node-code
    on error undo, return error return-value
    :
      create buf_temp-node-list .
      assign
        buf_temp-node-list.node-code  = buf_gds-prt.node-code
        buf_temp-node-list.upper-code = buf_gds-prt.upper-code
        buf_temp-node-list.level-num  = p-level
        buf_temp-node-list.order      = buf_gds-prt.prt-num
        buf_temp-node-list.sort-order = 0
        buf_temp-node-list.node-name  = buf_gds-prt.node-name
      .
      if p-level < p-prt-level then do:
        run fill-levels in this-procedure
          (input buf_gds-prt.node-code
          ,input p-level + 1
          ,input p-prt-level
          ) .
      end.
    end.
  end.
end procedure.
procedure renumber-level-sort :
  define input  parameter p-level          as integer   no-undo .
  define input  parameter p-start-from-max as logical   no-undo .
  define variable v-parent-level as integer   no-undo .
  define buffer parent_temp-node-list for temp-node-list .
  define buffer buf_temp-node-list for temp-node-list .
  do
  on error undo, return error return-value
  :
    assign
      v-parent-level = p-level - 1
    .
    for each parent_temp-node-list
      where parent_temp-node-list.level = v-parent-level
    on error undo, return error return-value
    :
      define variable v-sort-ind as integer   no-undo .
      assign
        v-sort-ind = 1
      .
      if p-start-from-max = true
      then do:
        define variable v-node-num  as integer   no-undo .
        define variable v-need-sort as logical   no-undo .
        define variable v-last-num  as integer   no-undo .
        assign
          v-node-num  = 1
          v-need-sort = false
          v-last-num  = 0
        .
        for each buf_temp-node-list
          where buf_temp-node-list.upper-code = parent_temp-node-list.node-code
        by buf_temp-node-list.node-name
        on error undo, return error return-value
        :
          if v-sort-ind < buf_temp-node-list.order
          then do:
            assign
              v-sort-ind = buf_temp-node-list.order
            .
          end.
          assign
            v-node-num = v-node-num + 1
          .
          if buf_temp-node-list.order < v-last-num
          or buf_temp-node-list.order < 1
          then do:
            assign
              v-need-sort = true
            .
          end.
          assign
            v-last-num = buf_temp-node-list.order
          .
        end.
        assign
          v-sort-ind = v-sort-ind + 1
        .
        if v-sort-ind < v-node-num
        then do:
          assign
            v-sort-ind = v-node-num
          .
        end.
      end.
      else do:
        assign
          v-need-sort = true
        .
      end.
      if v-need-sort = true then do:
        for each buf_temp-node-list
          where buf_temp-node-list.upper-code = parent_temp-node-list.node-code
        by buf_temp-node-list.node-name
        on error undo, return error return-value
        :
          assign
            buf_temp-node-list.sort-order = v-sort-ind
          .
          assign
            v-sort-ind = v-sort-ind + 1
          .
        end.
      end.
    end.
  end.
end procedure.
procedure store-level-sort :
  define buffer buf_temp-node-list for temp-node-list .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    define variable v-ind          as integer   no-undo .
    define variable v-current-time as character no-undo .
    define variable v-start-time   as int64     no-undo .
    def frame a
      v-ind          format ">>>>>>>9"  label "Обработано признаков" skip
      v-current-time format "x(8)"      label "Время" skip
      with view-as dialog-box side-labels three-d
      title "Сохранение порядка сортировки"
      .
    assign
      v-start-time = etime
    .
    view frame a .
    for each buf_temp-node-list
      where buf_temp-node-list.sort-order > 0
    by buf_temp-node-list.upper-code
    on error undo, return error return-value
    :
      assign
        v-ind = v-ind + 1
      .
      if v-ind modulo 10 = 0
      then do:
        assign
          v-current-time = string( integer(truncate((etime - v-start-time) / 1000, 0)), 'HH:MM:SS':u)
        .
        display
          v-ind
          v-current-time
          with frame a .
      end.
      do transaction
      on error undo, return error
      :
        find first buf_gds-prt exclusive-lock
          where buf_gds-prt.node-code = buf_temp-node-list.node-code
          .
        assign
          buf_gds-prt.prt-num = buf_temp-node-list.sort-order
        .
      end.
    end.
    hide frame a.
    pause 0 .
  end.
end procedure.
