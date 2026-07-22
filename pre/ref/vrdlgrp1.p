block-level on error undo, throw.
define input-output parameter p-doc-rec as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-deliv-type-code like ub.var-deliv-gr-per-val.deliv-type-code no-undo .
define input parameter p-deliv-subj-code like ub.var-deliv-gr-per-val.deliv-subj-code no-undo .
define input parameter p-deliv-obj-type  like ub.var-deliv-gr-per-val.obj-type no-undo .
define input parameter p-deliv-obj-code  like ub.var-deliv-gr-per-val.obj-code no-undo .
define input parameter p-gr-per-val-code like ub.var-deliv-gr-per-val.gr-per-val-code no-undo .
define input parameter p-des like ub.delivery-type-subject.des no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: vrdlgrp1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/vrdlgrp1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке варианта доставки ПО ГРУППЕ СРОКА ГОДНОСТИ".
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
define variable v-db-num like ub.db.db-num no-undo .
define buffer buf_delivery-type  for ub.delivery-type.
define buffer buf_delivery-subject  for ub.delivery-subject.
define buffer buf_delivery-type-subject  for ub.delivery-type-subject.
define buffer buf_variant-delivery for ub.variant-delivery.
define buffer buf_group-period-validity for ub.group-period-validity.
define buffer buf_var-deliv-gr-per-val for ub.var-deliv-gr-per-val.
define buffer buf_clients for ub.clients.
define stream LogStream.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
if v-db-num <> 0 then do:
  run err-mess (substitute("Нельзя изменять запись ВАРИАНТ ДОСТАВКИ ПО ГРУППЕ СРОКОВ ГОДНОСТИ в УБД: Номер текущей БД &1"
                , v-db-num) ).
  undo, return error "":U.
end.
find first buf_delivery-type no-lock where
            buf_delivery-type.deliv-type-code = p-deliv-type-code  no-error .
if not available buf_delivery-type then do:
  run err-mess (substitute("Неправильная ссылка на ТИП ДОСТАВКИ, код типа доставки: &1"
                , p-deliv-type-code) ).
  undo, return error "deliv-type-code":U.
end.
find first buf_delivery-subject no-lock where
            buf_delivery-subject.deliv-subj-code = p-deliv-subj-code  no-error .
if not available buf_delivery-subject then do:
  run err-mess (substitute("Неправильная ссылка на СУБЪЕКТ ДОСТАВКИ, код субъекта доставки: &1"
                , p-deliv-subj-code) ).
  undo, return error "deliv-subj-code":U.
end.
find first buf_delivery-type-subject no-lock where
            buf_delivery-type-subject.deliv-type-code = p-deliv-type-code
        AND buf_delivery-type-subject.deliv-subj-code = p-deliv-subj-code
        no-error .
if not available buf_delivery-type-subject then do:
  run err-mess (substitute("Неправильная ссылка на ТИП ДОСТАВКИ ОТ СУБЪЕКТА, код типа доставки: &1, код субъекта: &2"
                , p-deliv-type-code
                , p-deliv-subj-code
                ) ).
  undo, return error "deliv-type-code":U.
end.
find first buf_clients no-lock where
          buf_clients.obj-type = p-deliv-obj-type
      AND buf_clients.obj-code = p-deliv-obj-code  no-error .
if not available buf_clients then do:
  run err-mess (substitute("Неправильная ссылка на ОБЪЕКТ ДОСТАВКИ: &1&2"
                , p-deliv-obj-type
                , p-deliv-obj-code
                ) ).
  undo, return error "obj-code":U.
end.
if buf_clients.obj-type <> 'маг':U
and buf_clients.obj-type <> 'скл':U then do:
  run err-mess (substitute("Неверный тип ОБЪЕКТА ДОСТАВКИ: &1, может быть только &2 или &3"
                , p-deliv-obj-type
                , 'маг':U
                , 'скл':U
                ) ).
  undo, return error "obj-type":U.
end.
find first buf_variant-delivery no-lock where
            buf_variant-delivery.deliv-type-code = p-deliv-type-code
        AND buf_variant-delivery.deliv-subj-code = p-deliv-subj-code
        AND buf_variant-delivery.obj-type = p-deliv-obj-type
        AND buf_variant-delivery.obj-code = p-deliv-obj-code
        no-error .
if not available buf_variant-delivery then do:
  run err-mess (substitute("Неправильная ссылка на ВАРИАНТ ДОСТАВКИ, код типа доставки: &1, код субъекта: &2, объект доставки &3&4"
                , p-deliv-type-code
                , p-deliv-subj-code
                , p-deliv-obj-type
                , p-deliv-obj-code
                ) ).
  undo, return error "deliv-type-code":U.
end.
find first buf_group-period-validity no-lock where
          buf_group-period-validity.gr-per-val-code = p-gr-per-val-code no-error .
if not available buf_group-period-validity then do:
  run err-mess (substitute("Неправильная ссылка на ГРУППУ СРОКОВ ГОДНОСТИ, код группы сроков годности: &1"
                , p-gr-per-val-code
                ) ).
  undo, return error "gr-per-val-code":U.
end.
if buf_group-period-validity.gr-per-from <= buf_variant-delivery.term-delivery then do:
  run err-mess (substitute(("Слишком большой срок доставки для данной группы сроков годности, &1" +
                           "срок доставки: &2 срок годности: &3-&4 дня " +
                           "код типа доставки: &5, код субъекта: &6, объект доставки: &7&8 " +
                           "код группы сроков годности: &9")
                , chr(10)
                , buf_variant-delivery.term-delivery
                , buf_group-period-validity.gr-per-from
                , buf_group-period-validity.gr-per-to
                , p-deliv-type-code
                , p-deliv-subj-code
                , p-deliv-obj-type
                , p-deliv-obj-code
                , p-gr-per-val-code
                ) ).
  undo, return error "":U.
end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
  find first buf_var-deliv-gr-per-val no-lock where
            buf_var-deliv-gr-per-val.deliv-type-code = p-deliv-type-code
        AND buf_var-deliv-gr-per-val.deliv-subj-code = p-deliv-subj-code
        AND buf_var-deliv-gr-per-val.obj-type = p-deliv-obj-type
        AND buf_var-deliv-gr-per-val.obj-code = p-deliv-obj-code
        AND buf_var-deliv-gr-per-val.gr-per-val-code = p-gr-per-val-code
        no-error .
  if available buf_var-deliv-gr-per-val then do:
    run err-mess (substitute("Уже есть запись ВАРИАНТА ДОСТАВКИ ПО ГРУППЕ СРОКОВ ХРАНЕНИЯ &1, у которой код типа доставки: &2 и код субъекта доставки: &3 и объект &4&5 и код группы сроков хранения &6"
                  , chr(10)
                  , p-deliv-type-code
                  , p-deliv-subj-code
                  , p-deliv-obj-type
                  , p-deliv-obj-code
                  , p-gr-per-val-code
                  ) ).
    undo, return error "deliv-type-code":U.
  end.
end.
_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create ub.var-deliv-gr-per-val.
    assign
    ub.var-deliv-gr-per-val.deliv-type-code = p-deliv-type-code
    ub.var-deliv-gr-per-val.deliv-subj-code = p-deliv-subj-code
    ub.var-deliv-gr-per-val.obj-type        = p-deliv-obj-type
    ub.var-deliv-gr-per-val.obj-code        = p-deliv-obj-code
    ub.var-deliv-gr-per-val.gr-per-val-code = p-gr-per-val-code
    p-doc-rec = recid(ub.var-deliv-gr-per-val)
    .
  end.
  else do:
    FIND FIRST ub.var-deliv-gr-per-val where
              recid(ub.var-deliv-gr-per-val) = p-doc-rec No-ERROR.
    if not available ub.var-deliv-gr-per-val then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись ВАРИАНТ ДОСТАВКИ ПО ГРУППЕ СРОКОВ ХРАНЕНИЯ - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.var-deliv-gr-per-val.deliv-type-code <> p-deliv-type-code
    or ub.var-deliv-gr-per-val.deliv-subj-code <> p-deliv-subj-code
    or ub.var-deliv-gr-per-val.obj-type        <> p-deliv-obj-type
    or ub.var-deliv-gr-per-val.obj-code        <> p-deliv-obj-code
    or ub.var-deliv-gr-per-val.gr-per-val-code <> p-gr-per-val-code
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "внутренний код типа доставки и/или" skip
      "внутренний код субъекта доставки и/или" skip
      "объект доставки и/или" skip
      "внутр. код группы сроков годности"
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
  end.
  assign
  ub.var-deliv-gr-per-val.des                 = p-des
  ub.var-deliv-gr-per-val.sts                 =  (if p-mode = 'ДОБАВЛЕНИЕ':U
                             then 0
                             else ub.var-deliv-gr-per-val.sts)
  .
  release ub.var-deliv-gr-per-val no-error.
  if error-status:error then do:
     run err-mess(substitute("Ошибка при сохранении записи ВАРИАНТ ДОСТАВКИ ПО ГРУППЕ СРОКОВ ГОДНОСТИ: тип доставки &1, субъект доставки &2, объект доставки &3&4, код группы сроков годности &5: &6: &7"
                             , p-deliv-type-code
                             , p-deliv-subj-code
                             , p-deliv-obj-type
                             , p-deliv-obj-code
                             , p-gr-per-val-code
                             , ERROR-STATUS:GET-message(1)
                             , return-value
                             )).
    undo, return error "":U.
 end.
end.
PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
      message
      p-mess
      view-as alert-box error .
END PROCEDURE.
