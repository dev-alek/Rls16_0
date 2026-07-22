block-level on error undo, throw.
define input parameter p-obj-type  like ub.parts.obj-type  no-undo .
define input parameter p-obj-code  like ub.parts.obj-code  no-undo .
define input parameter p-artic     like ub.parts.artic     no-undo .
define input parameter p-prod-type like ub.parts.prod-type no-undo .
define input parameter p-prod-code like ub.parts.prod-code no-undo .
define input parameter p-in-code   like ub.parts.in-code   no-undo .
define input parameter p-out-code  like ub.parts.out-code  no-undo .
define input parameter p-part-code like ub.parts.part-code no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Объединение партий в свободной зоне".
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
define variable v-cmd-proc-handle as handle    no-undo .
define variable v-cmd-code1       as integer   no-undo .
define variable v-cur-db-num      as integer   no-undo .
define variable v-rec-ord         as integer   no-undo .
define variable v-spacial-doc     as logical   no-undo .
define temp-table temp-parts no-undo like ub.parts .
define buffer buf_goods      for ub.goods .
define buffer buf_trn-doc    for ub.trn-doc .
define buffer buf_bar-code   for ub.bar-code .
define buffer buf_temp-parts for temp-parts .
define buffer buf_parts-attr for ub.parts-attr .
do
on error undo, return error
:
  assign
    v-spacial-doc = false
  .
  if p-out-code <> 'free-zone':U
  then do:
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-out-code
      no-error .
    if available buf_trn-doc
      and ( buf_trn-doc.ext-doc-type = 'iv':U
            or buf_trn-doc.ext-doc-type = 'rv':U
          )
    then do:
      assign
        v-spacial-doc = true
      .
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Данная версия программы не может склеивать партии" skip
        "зарезервированные за документами" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Партия" p-in-code p-part-code skip
        "Документ" p-out-code skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
  find first ub.goods no-lock
    where ub.goods.artic     = p-artic
      and ub.goods.prod-type = p-prod-type
      and ub.goods.prod-code = p-prod-code
    no-error .
  if not available ub.goods
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден товар" skip
      "Объект" p-obj-type p-obj-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Партия" p-in-code p-part-code skip
      "Документ" p-out-code skip
      view-as alert-box error .
    undo, return error .
  end.
  define variable l-create-bar-code as logical no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'create-bar-code=request'
  ,output l-create-bar-code
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении атрибута товара" skip
      "Объект" p-obj-type p-obj-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "create-bar-code=request"
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  find first ub.parts exclusive-lock
    where ub.parts.obj-type  = p-obj-type
      and ub.parts.obj-code  = p-obj-code
      and ub.parts.artic     = p-artic
      and ub.parts.prod-type = p-prod-type
      and ub.parts.prod-code = p-prod-code
      and ub.parts.in-code   = p-in-code
      and ub.parts.out-code  = p-out-code
      and ub.parts.part-code = p-part-code
    no-error .
  if not available ub.parts
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найдена партия для разбиения" skip
      "Объект" p-obj-type p-obj-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Партия" p-in-code p-part-code skip
      "Документ" p-out-code skip
      view-as alert-box error .
    undo, return error .
  end.
  define buffer buf_gds-obj for ub.gds-obj .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  )  .
  find current buf_gds-obj exclusive-lock .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-cur-db-num
  )  .
  if v-cur-db-num <> 0
    and v-spacial-doc <> true
  then do:
    run nws/cmd-bush.p persistent set v-cmd-proc-handle
      no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute("Ошибка при запуске процедуры cmd-bush.p") skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      undo, return error return-value .
    end.
    run begin-create-command in v-cmd-proc-handle
      (input  'cmd-parts-split':U
      ,input "":U
      ,output v-cmd-code1
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при создании команды &1", 'cmd-transfer-goods':U ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      undo, return error return-value .
    end.
    run add-dump in v-cmd-proc-handle
      (input v-cmd-code1
      ,input 'gds-obj':U
      ,input '+update':U
      ,input (buffer buf_gds-obj :handle)
      ,input '':U
      ,output v-rec-ord
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при добавлении записи &1 в команду с кодом &2", 'gds-obj':U, v-cmd-code1 ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      undo, return error return-value .
    end.
  end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscheck in g#library
  (input p-obj-type
  ,input p-obj-code
  ,input p-artic
  ,input p-prod-type
  ,input p-prod-code
  ,input ?
  ,input ''
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка проверки целостности товара до операции разбиения" skip
      "Объект" p-obj-type p-obj-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Партия" p-in-code p-part-code skip
      "Документ" p-out-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
  define buffer buf_parts for ub.parts .
  define variable v-new-part-code like ub.parts.part-code no-undo .
  assign
    v-new-part-code = entry(1, ub.parts.part-code, '#':U)
  .
  find first buf_parts exclusive-lock
    where buf_parts.obj-type  = ub.parts.obj-type
      and buf_parts.obj-code  = ub.parts.obj-code
      and buf_parts.artic     = ub.parts.artic
      and buf_parts.prod-type = ub.parts.prod-type
      and buf_parts.prod-code = ub.parts.prod-code
      and buf_parts.in-code   = ub.parts.in-code
      and buf_parts.out-code  = ub.parts.out-code
      and buf_parts.part-code = v-new-part-code
    no-error.
  if not available buf_parts
  then do:
    create buf_parts .
    buffer-copy ub.parts to buf_parts
    assign
      buf_parts.part-code  = v-new-part-code
      buf_parts.out-code   = ub.parts.out-code
      buf_parts.status_    = ub.parts.status_
      buf_parts.doc-type   = ub.parts.doc-type
      buf_parts.rsrv-free  = ub.parts.rsrv-free
    .
    assign
      buf_parts.qnty      = 0
      buf_parts.fact-qnty = 0
      buf_parts.real-qnty = 0
      buf_parts.cli-qnty  = 0
    .
  end.
  assign
    buf_parts.qnty      = buf_parts.qnty      + ub.parts.qnty
    buf_parts.fact-qnty = buf_parts.fact-qnty + ub.parts.fact-qnty
    buf_parts.cli-qnty  = buf_parts.cli-qnty  + ub.parts.cli-qnty
  .
  validate buf_parts .
  define variable v-gds-code as integer   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
  find first buf_parts-attr exclusive-lock
       where buf_parts-attr.in-code   = buf_parts.in-code
         and buf_parts-attr.gds-code  = v-gds-code
         and buf_parts-attr.part-code = v-new-part-code
         no-error.
         if not available buf_parts-attr then do:
          find first ub.parts-attr no-lock
               where ub.parts-attr.in-code   = ub.parts.in-code
                 and ub.parts-attr.gds-code  = v-gds-code
                 and ub.parts-attr.part-code = ub.parts.part-code
                 no-error.
            if available ub.parts-attr then do:
              create buf_parts-attr.
              buffer-copy ub.parts-attr to buf_parts-attr
              assign
                buf_parts-attr.part-code = v-new-part-code
                .
            end.
         end.
  create buf_temp-parts .
  buffer-copy buf_parts to buf_temp-parts
  assign
    buf_temp-parts.qnty      = ub.parts.qnty
    buf_temp-parts.fact-qnty = ub.parts.fact-qnty
    buf_temp-parts.cli-qnty  = ub.parts.cli-qnty
  .
  if v-cur-db-num <> 0
    and v-spacial-doc <> true
  then do:
    run add-dump in v-cmd-proc-handle
      (input v-cmd-code1
      ,input 'parts':U
      ,input '+update':U
      ,input (buffer buf_temp-parts :handle)
      ,input '':U
      ,output v-rec-ord
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при добавлении записи &1 в команду с кодом &2", 'parts':U, v-cmd-code1 ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      undo, return error return-value .
    end.
  end.
  create buf_temp-parts .
  buffer-copy ub.parts to buf_temp-parts
  assign
    buf_temp-parts.qnty      = - ub.parts.qnty
    buf_temp-parts.fact-qnty = - ub.parts.fact-qnty
    buf_temp-parts.cli-qnty  = - ub.parts.cli-qnty
  .
  if v-cur-db-num <> 0
    and v-spacial-doc <> true
  then do:
    run add-dump in v-cmd-proc-handle
      (input v-cmd-code1
      ,input 'parts':U
      ,input '+update':U
      ,input (buffer buf_temp-parts :handle)
      ,input '':U
      ,output v-rec-ord
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при добавлении записи &1 в команду с кодом &2", 'parts':U, v-cmd-code1 ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      undo, return error return-value .
    end.
  end.
  delete ub.parts .
  if l-create-bar-code
  then do:
    define variable v-bar-code-is-new as logical no-undo .
    define variable v-root-node like ub.gds-prt.node-code no-undo .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-root-node
  )  .
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  buf_goods.gds-code
  ,input  v-root-node
  ,input  buf_parts.part-code
  ,input  buf_parts.in-code
  ,input  buf_goods.unit-base
  ,input  ?
  ,output v-bar-code-is-new
  ,buffer buf_bar-code
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании бар-кода партии" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
  if v-cur-db-num <> 0
    and v-spacial-doc <> true
  then do:
    run send-command in v-cmd-proc-handle
      ( input v-cmd-code1
      ,input "0"
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( "Ошибка при отправке в новости команды с кодом &1", v-cmd-code1 ) skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      delete procedure v-cmd-proc-handle .
      undo, return error return-value .
    end.
    delete procedure v-cmd-proc-handle .
  end.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscheck in g#library
  (input p-obj-type
  ,input p-obj-code
  ,input p-artic
  ,input p-prod-type
  ,input p-prod-code
  ,input ?
  ,input ''
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка проверки целостности товара после операции слияния партий" skip
      "Объект" p-obj-type p-obj-code skip
      "Артикул" p-artic p-prod-type p-prod-code skip
      "Партия" p-in-code p-part-code skip
      "Документ" p-out-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error .
  end.
end.
