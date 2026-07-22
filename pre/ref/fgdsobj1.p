block-level on error undo, throw.
define input-output parameter par-rid as recid no-undo .
define input parameter par-mode as character no-undo .
define input parameter p-silent as logical no-undo .
define input parameter p-gds-code like ub.fbr-gds-obj.gds-code no-undo .
define input parameter p-obj-type like ub.fbr-gds-obj.obj-type no-undo .
define input parameter p-obj-code like ub.fbr-gds-obj.obj-code no-undo .
define input parameter p-fbr-grp-code like ub.fbr-gds-obj.fbr-grp-code no-undo .
define input parameter p-fbr-obj-type like ub.fbr-gds-obj.fbr-obj-type no-undo .
define input parameter p-fbr-obj-code like ub.fbr-gds-obj.fbr-obj-code no-undo .
define input parameter p-is-cd like ub.fbr-gds-obj.is-cd no-undo .
define input parameter p-is-menu like ub.fbr-gds-obj.is-menu no-undo .
define input parameter p-is-modificator like ub.fbr-gds-obj.is-modificator no-undo .
define input parameter p-is-null-price like ub.fbr-gds-obj.is-null-price no-undo .
define input parameter p-is-season like ub.fbr-gds-obj.is-season no-undo .
define input parameter p-is-semi-finished like ub.fbr-gds-obj.is-semi-finished no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fgdsobj1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/fgdsobj1.p $":U .
define variable vss-description as character no-undo init "Атрибуты товара на объекте-РЕСТОРАН".
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
define variable var-entry as character no-undo .
define variable v-db-num like ub.db.db-num no-undo .
define variable v-rec as recid no-undo .
define variable v-old-is-menu like ub.fbr-gds-obj.is-menu no-undo .
define variable v-old-is-semi-finished like ub.fbr-gds-obj.is-semi-finished no-undo .
define variable v-b-code like ub.bar-code.b-code no-undo .
define variable v-price-sale like ub.price-list.price-sale no-undo .
define variable v-excise like ub.price-list.excise no-undo .
define variable v-road-tax like ub.price-list.road-tax no-undo .
define variable v-doc-num like ub.price-list.doc-num no-undo .
define variable v-chg-fbr as logical no-undo .
define variable v-mes as character no-undo .
define buffer buf_clients for ub.clients.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define buffer buf_fbr-gds-grp for ub.fbr-gds-grp.
define buffer buf_goods for ub.goods.
define buffer buf_shop for ub.shop.
if par-mode <> 'ДОБАВЛЕНИЕ':U AND par-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр par-mode - " par-mode
  view-as alert-box error .
  return error '':u.
end.
find first buf_goods no-lock where
           buf_goods.gds-code = p-gds-code no-error .
if p-gds-code = 0
or not available buf_goods
then do:
  assign
  var-entry = "gds-code":U
  v-mes = "Не указан товар"
  .
  run do-message in this-procedure (var-entry, input-output v-mes).
  undo, return error (if p-silent then var-entry else v-mes).
end.
find first buf_clients no-lock where
          buf_clients.obj-type = p-obj-type
     AND  buf_clients.obj-code = p-obj-code no-error .
if p-obj-type = "":u
or p-obj-code = 0
or not available buf_clients
then do:
  assign
  var-entry = "obj-code":U
  v-mes = substitute("Не найден объект &1&2", p-obj-type, p-obj-code)
  .
  run do-message in this-procedure (var-entry, input-output v-mes).
  undo, return error (if p-silent then var-entry else v-mes).
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
if buf_clients.db-num <> v-db-num then do:
  assign
  var-entry = "obj-code":U
  v-mes = substitute("Изменения атрибута товара РЕСТОРАН возможны только на БД объекта: БД объекта &1&2 &3, текущая БД &4"
                     ,p-obj-type
                     ,p-obj-code
                     ,buf_Clients.db-num
                     ,v-db-num)
  .
  run do-message in this-procedure (var-entry, input-output v-mes).
   undo, return error (if p-silent then var-entry else v-mes).
end.
if LOOKUP(p-obj-type, ('маг':U + chr(44) + 'скл':U)) = 0 then do:
  assign
  var-entry = "obj-type":U
  v-mes = substitute("Атрибут товара РЕСТОРАН может быть определен только для объекта типа &1 или &2"
                     , 'маг':U
                     , 'скл':U)
  .
  run do-message in this-procedure (var-entry, input-output v-mes).
  undo, return error (if p-silent then var-entry else v-mes).
end.
find first buf_clients no-lock where
          buf_clients.obj-type = p-fbr-obj-type
     AND  buf_clients.obj-code = p-fbr-obj-code no-error .
if (p-fbr-obj-type = "":u
or p-fbr-obj-code = 0
or not available buf_clients)
and (p-is-menu = yes or
     p-is-semi-finished = yes)
then do:
  assign
  var-entry = "fbr-obj-code":U
  v-mes = substitute("для блюда меню и для полуфабриката должен быть определен объект-КУХНЯ")
  .
  run do-message in this-procedure (var-entry, input-output v-mes).
  undo, return error (if p-silent then var-entry else v-mes).
end.
if p-fbr-obj-type <> "":U and
p-fbr-obj-type <> 'маг':U then do:
  assign
  var-entry = "fbr-obj-type":U
  v-mes = substitute("Для атрибута товара РЕСТОРАН кухней может быть только объект типа &1", 'маг':U)
  .
  run do-message in this-procedure (var-entry, input-output v-mes).
  undo, return error (if p-silent then var-entry else v-mes).
end.
if p-fbr-grp-code <> 0 then do:
  find first buf_fbr-gds-grp  no-lock
       where buf_fbr-gds-grp.obj-type   = p-obj-type
         and buf_fbr-gds-grp.obj-code   = p-obj-code
         and buf_fbr-gds-grp.node-code  = p-fbr-grp-code
  no-error .
  if not available buf_fbr-gds-grp then do:
    assign
    var-entry = "fbr-grp-code":U
    v-mes  = substitute("Не найдена группа меню с кодом &1 для &2&3", p-fbr-grp-code, p-obj-type, p-obj-code)
    .
    run do-message in this-procedure (var-entry, input-output v-mes).
    undo, return error (if p-silent then var-entry else v-mes).
  end.
end.
if p-fbr-grp-code <> 0
or p-is-cd
then do:
  find first buf_shop no-lock where
            buf_shop.obj-code = p-obj-code .
  if (buf_shop.is-kitchen or
  buf_shop.is-kitchen-store)
  and not buf_shop.is-catering then do:
    assign
    var-entry =  (if p-fbr-grp-code <> 0
                  then "fbr-grp-code":U
                  else "fbr-obj-code":U)
    v-mes = substitute("Нельзя определять признаки ГРУППА МЕНЮ и/или ОТПРАВЛЯТЬ НА КАССУ для магазина,&1" +
                       "который имеет признаки КУХНЯ и/или СКЛАД КУХНИ" +
                       "и не является РЕСТОРАНОМ"
                       , chr(10))
    .
    run do-message in this-procedure (var-entry, input-output v-mes).
    undo, return error (if p-silent then var-entry else v-mes).
  end.
end.
if p-is-menu and p-is-semi-finished then do:
  assign
  var-entry = "is-semi-finished"
  v-mes = "Товар не может одновременно является блюдом меню и полуфабрикатом"
  .
  run do-message in this-procedure (var-entry, input-output v-mes).
  undo, return error (if p-silent then var-entry else v-mes).
end.
if p-is-semi-finished and p-is-modificator then do:
  assign
  var-entry = "is-menu"
  v-mes = "Товар не может одновременно является полуфабрикатом и модификатором"
  .
  run do-message in this-procedure (var-entry, input-output v-mes).
  undo, return error (if p-silent then var-entry else v-mes).
end.
if p-is-null-price = yes then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  ?
  ,output v-b-code
  )  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  v-b-code
  ,input  v-b-code
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
 if v-price-sale <> 0 and v-price-sale <> ? then do:
    assign
    var-entry = "is-null-price":U.
    v-mes = "Товар имеет цену на объекте - нельзя установить для него свойство БЕЗ ЦЕНЫ"
    .
    run do-message in this-procedure (var-entry, input-output v-mes).
    undo, return error (if p-silent then var-entry else v-mes).
 end.
end.
_main:
do
on error undo _main, return error
:
  CASE par-mode:
    when 'ДОБАВЛЕНИЕ':U then do:
      find first buf_fbr-gds-obj no-lock where
                 buf_fbr-gds-obj.gds-code = p-gds-code
             AND buf_fbr-gds-obj.obj-type = p-obj-type
             AND buf_fbr-gds-obj.obj-code = p-obj-code no-error .
      if available buf_fbr-gds-obj then do:
        assign
        var-entry = "gds-code"
        v-mes = "уже определены атрибуты товара на объекте-РЕСТОРАН"
        .
        run do-message in this-procedure (var-entry, input-output v-mes).
        undo, return error (if p-silent then var-entry else v-mes).
      end.
      create ub.fbr-gds-obj.
      assign
      v-chg-fbr = yes
      .
    end.
    when 'ИЗМЕНЕНИЕ':U then do:
      find first ub.fbr-gds-obj exclusive-lock where
                recid(ub.fbr-gds-obj) = par-rid no-error .
      if not available ub.fbr-gds-obj
      then do:
        assign
        var-entry = "gds-code":U
        v-mes = "Нечего редактировать: не определены атрибуты товара на объекте-РЕСТОРАН"
        .
        run do-message in this-procedure (var-entry, input-output v-mes).
        undo, return error (if p-silent then var-entry else v-mes).
      end.
      IF ub.fbr-gds-obj.obj-type <> p-obj-type
      OR ub.fbr-gds-obj.obj-code <> p-obj-code
      then do:
        assign
        var-entry = "obj-code":U
        v-mes = "Нельзя изменить объект, на котором определены атрибуты товара-РЕСТОРАН"
        .
        run do-message in this-procedure (var-entry, input-output v-mes).
        undo, return error (if p-silent then var-entry else v-mes).
      end.
      IF ub.fbr-gds-obj.gds-code <> p-gds-code
      then do:
        assign
        var-entry = "gds-code":U
        v-mes = "Нельзя изменить товар, для которого определены атрибуты товара РЕСТОРАН"
        .
        run do-message in this-procedure (var-entry, input-output v-mes).
        undo, return error (if p-silent then var-entry else v-mes).
      end.
      if ub.fbr-gds-obj.fbr-obj-type <> p-fbr-obj-type
      OR ub.fbr-gds-obj.fbr-obj-code <> p-fbr-obj-code
      then do:
        assign
        v-chg-fbr = yes
        .
      end.
    end.
  END CASE.
  assign
  v-old-is-menu = ub.fbr-gds-obj.is-menu
  v-old-is-semi-finished = ub.fbr-gds-obj.is-semi-finished
  ub.fbr-gds-obj.gds-code = p-gds-code
  ub.fbr-gds-obj.obj-type = p-obj-type
  ub.fbr-gds-obj.obj-code = p-obj-code
  ub.fbr-gds-obj.fbr-grp-code = p-fbr-grp-code
  ub.fbr-gds-obj.fbr-obj-type = p-fbr-obj-type
  ub.fbr-gds-obj.fbr-obj-code = p-fbr-obj-code
  ub.fbr-gds-obj.is-cd = p-is-cd
  ub.fbr-gds-obj.is-menu = p-is-menu
  ub.fbr-gds-obj.is-modificator= p-is-modificator
  ub.fbr-gds-obj.is-null-price = p-is-null-price
    ub.fbr-gds-obj.is-season = p-is-season
  ub.fbr-gds-obj.is-semi-finished = p-is-semi-finished
  par-rid = recid(ub.fbr-gds-obj)
  .
  if v-chg-fbr then do:
    for each buf_fbr-gds-obj exclusive-lock where
            buf_fbr-gds-obj.gds-code = ub.fbr-gds-obj.gds-code,
        first buf_clients no-lock where
             buf_clients.obj-type = buf_fbr-gds-obj.obj-type
         AND buf_clients.obj-code = buf_fbr-gds-obj.obj-code
         AND buf_clients.db-num = v-db-num
    on error undo _main, return error "fbr-obj-code":U
    on stop undo _main, return error "fbr-obj-code":U
         :
      assign
      buf_fbr-gds-obj.fbr-obj-type = ub.fbr-gds-obj.fbr-obj-type
      buf_fbr-gds-obj.fbr-obj-code = ub.fbr-gds-obj.fbr-obj-code
      .
    end.
  end.
  release ub.fbr-gds-obj no-error .
  if error-status:error then do:
    assign
    var-entry = "":U
    v-mes = substitute("Ошибка при сохранении записи Атрибуты товара РЕСТОРАН:&1&2 &3"
                       , chr(10)
                       , error-status:get-message(1)
                       , return-value )
    .
    run do-message in this-procedure (var-entry, input-output v-mes).
    undo, return error (if p-silent then var-entry else v-mes).
  end.
end.
procedure do-message :
define input parameter p-entry as character no-undo .
define input-output parameter p-mes as character no-undo .
  do
  on error undo, return error
  :
   assign
   p-mes = substitute("Атрибут товара РЕСТОРАН: товар с кодом &1 &2&3: &4"
                      , p-gds-code
                      , p-obj-type
                      , p-obj-code
                      , p-mes).
   if p-silent = no then do:
     message
     p-mes view-as alert-box error.
   end.
  end.
end procedure.
