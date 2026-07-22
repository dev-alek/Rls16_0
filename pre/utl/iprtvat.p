block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: iprtvat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/iprtvat.p $":U .
define variable vss-description as character no-undo init "Инициализация процента НДС в партиях в сооветствии с текущим НДС".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table temp-host no-undo
  field host-code like ub.store.host-code
  index xpk host-code
.
define  temp-table temp-obj no-undo
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
  field host-code like ub.store.host-code
  field db-num    like ub.clients.db-num
  index xpk  obj-type obj-code
  index xie1 host-code
  index xie2 db-num host-code
.
procedure init-temphost:
  define buffer buf_store   for ub.store .
  define buffer buf_shop    for ub.shop .
  define buffer buf_clients for ub.clients .
  define buffer buf_db for ub.db .
  define buffer buf_temp-host for temp-host .
  define buffer buf_temp-obj for temp-obj .
  do
  on error undo, return error return-value
  :
    for each buf_store
    on error undo, return error
    :
      find first buf_temp-host
        where buf_temp-host.host-code = buf_store.host-code
        no-error .
      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_store.host-code
        .
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = 'скл':U
          and buf_clients.obj-code = buf_store.obj-code
        no-error .
      if not available buf_clients
      then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" 'скл':U buf_store.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = 'скл':U
        buf_temp-obj.obj-code  = buf_store.obj-code
        buf_temp-obj.host-code = buf_store.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.
    for each buf_shop
    on error undo, return error
    :
      find first buf_temp-host
        where buf_temp-host.host-code = buf_shop.host-code
        no-error .
      if not available buf_temp-host
      then do:
        create buf_temp-host .
        assign
          buf_temp-host.host-code = buf_shop.host-code
        .
      end.
      find first buf_clients no-lock
        where buf_clients.obj-type = 'маг':U
          and buf_clients.obj-code = buf_shop.obj-code
        no-error .
      if not available buf_clients then do:
        message
          "Ошибка при поиске клиента" skip
          "Клиент" 'маг':U buf_shop.obj-code skip
          view-as alert-box error .
        undo, return error .
      end.
      create buf_temp-obj .
      assign
        buf_temp-obj.obj-type  = 'маг':U
        buf_temp-obj.obj-code  = buf_shop.obj-code
        buf_temp-obj.host-code = buf_shop.host-code
        buf_temp-obj.db-num    = buf_clients.db-num
      .
    end.
  end.
end.
run init-temphost .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer
  index xpk is primary unique obj-type obj-code
  .
procedure userobjs_clear :
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.
end .
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.
end.
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.
end.
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.
end.
procedure userobjs_transfer :
  define input  parameter p-callback-handle as handle no-undo .
  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.
end procedure.
procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel"
      ,output p-user-select
      ,output p-select-obj-type
      ,output p-select-obj-code
      ) .
  end.
end.
procedure userobjs_select-many :
  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    run gbl/userobjs.w
      (input  parparentproc
      ,input  this-procedure :handle
      ,input  p-db-num
      ,input  p-user-id
      ,input  p-host-code-obj
      ,input  p-obj-type
      ,input  p-obj-code
      ,INPUT  "b-sel,b-mark"
      ,output p-user-select
      ,output v-select-obj-type
      ,output v-select-obj-code
      ) .
  end.
end.
procedure thobjs :
   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo .
   define input        parameter i-list-mode       as character     no-undo.
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
run ref/thobjs.p
        ( input parparentproc
         ,input  this-procedure :handle
        , input i-bttns
        , input i-list-mode
        , input i-obj-type
        , input i-db-num
        , input i-host-code
        , input-output p-rid-list ) no-error .
end.
run str/gds-list.w
  (input parparentproc
  ,input v-cntxt-host-code-obj
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
  ) .
define variable lok as logical no-undo init false .
message
  "Проинициализировать партии свобоной и расходной зон для выбранных товаров." skip
  "значениями НДС из справочника товаров"
  "Да - все объекты" skip
  "Нет - выбрать объекты" skip
  view-as alert-box question buttons yes-no-cancel update lok
  .
if lok = ? then do:
  return .
end.
if lok = true then do:
  for each temp-obj
  :
    run initialise-parts-vat-pc
      (input temp-obj.obj-type
      ,input temp-obj.obj-code
      ).
  end.
end.
if lok = false
then do:
  define variable v-user-select as logical   no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run userobjs_select-many in this-procedure
  (input  parparentproc
  ,input  v-cntxt-db-num
  ,input  v-cntxt-userid
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,output v-user-select
  )  .
  if v-user-select <> true
  then do:
    message
      "Объект не выбран"
      view-as alert-box information .
    return .
  end.
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .
  for each buf_userobjs_temp-user-obj
  on error undo, return error return-value
  :
    run initialise-parts-vat-pc
      (input buf_userobjs_temp-user-obj.obj-type
      ,input buf_userobjs_temp-user-obj.obj-code
      ).
  end.
end.
procedure initialise-parts-vat-pc :
  define input parameter p-obj-type like ub.gds-obj.obj-type no-undo .
  define input parameter p-obj-code like ub.gds-obj.obj-code no-undo .
  define variable v-vat-pc        like ub.doc-line.vat-pc    no-undo.
  define variable v-slt-pc        like ub.doc-line.slt-pc    no-undo.
  define variable v-host-code     like ub.sysconf.host-code  no-undo.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
  for each gds-list
  :
    find first ub.goods no-lock
      where ub.goods.artic     = gds-list.artic
        and ub.goods.prod-type = gds-list.prod-type
        and ub.goods.prod-code = gds-list.prod-code
      .
    find first ub.gds-obj exclusive-lock
      where ub.gds-obj.obj-type  = p-obj-type
        and ub.gds-obj.obj-code  = p-obj-code
        and ub.gds-obj.artic     = ub.goods.artic
        and ub.gds-obj.prod-type = ub.goods.prod-type
        and ub.gds-obj.prod-code = ub.goods.prod-code
      no-error .
    for each ub.parts
      where ub.parts.obj-type     = p-obj-type
        and ub.parts.obj-code     = p-obj-code
        and ub.parts.artic        = ub.goods.artic
        and ub.parts.prod-type    = ub.goods.prod-type
        and ub.parts.prod-code    = ub.goods.prod-code
        and ub.parts.status_      = no
        and (ub.parts.rsrv-free   = yes
             or ub.parts.rsrv-free = no
            )
    :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  p-obj-type
  ,input  p-obj-code
  ,output v-vat-pc
  ) no-error .
      assign
      ub.parts.VAT-pc = v-vat-pc
      .
    end.
  end.
end procedure.
