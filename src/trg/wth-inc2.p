block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Проверка корректности данных в документе МЦ не инвент

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/21/05
Author: Bakhtadze Natalya
Creation date: 09/21/05

*/

define input parameter p-silent   as logical no-undo .

define input parameter pardoc-code like ub.wth-doc.doc-code no-undo .
define input parameter parhost-code like ub.wth-doc.host-code no-undo .
define input parameter parobj-type like ub.wth-doc.obj-type no-undo .
define input parameter parobj-code like ub.wth-doc.obj-code no-undo .
define input parameter parcli-type like ub.wth-doc.cli-type no-undo .
define input parameter parcli-code like ub.wth-doc.cli-code no-undo .
define input parameter par-operator like ub.wth-doc.operator no-undo .
define input parameter par-deliver like ub.wth-doc.deliver no-undo .
define input parameter par-receiver like ub.wth-doc.receiver no-undo .
define input parameter pardoc-type like ub.wth-doc.doc-type no-undo .
define input parameter parauto-fill like ub.wth-doc.auto-fill no-undo .
define input parameter par-exter_ like ub.wth-doc.exter_ no-undo .
define input parameter par-inter_ like ub.wth-doc.inter_ no-undo .
define input parameter parsource-ref like ub.wth-doc.source-ref no-undo .
define input parameter parsource-type like ub.wth-doc.source-type no-undo .
define input parameter par-borned like ub.wth-doc.borned no-undo .
define input parameter parlines-exist as logical no-undo .
define input parameter parext-type as character no-undo.
define output parameter parcli-name like ub.clients.obj-name no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Проверка корректности данных в документе МЦ не инвент".
{ cmp/vssrevis.i }


{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/clntattr.i }

{ gbl/thbjattr.i }

DEFINE VARIABLE var-entry as character no-undo .
define variable v-mes     as character no-undo .
define variable v-file    as logical no-undo .
define variable v-type as character no-undo .
define buffer buf_clients for ub.clients .
define buffer buf_wth-line for ub.wth-line .
define buffer current-place for ub.wth-place .
define buffer out-place for ub.wth-place .
define buffer buf_operator for ub.clients .
define buffer buf_deliver for ub.clients .
define buffer buf_receiver for ub.clients .
define buffer bind_wth-doc for ub.wth-doc .
define buffer bind_inkas for ub.inkas .
define variable v-chk-wth-prs  as logical   no-undo. /* для чтения параметра конфигурации */
define variable conf-par as character no-undo.
define variable par-type as character no-undo.
&scope type-psnattr-view "{&bef-WDEDT_Inc_Ext},{&bef-WDEDT_Exp_Ext},{&bef-WDEDT_Put_Cli},{&bef-WDEDT_exch}"


_main:
do
on error undo, return error
:

FIND FIRST ub.sysconf No-LOCK WHERE
           ub.sysconf.host-code = parhost-code No-ERROR.
IF NOT AVAIL ub.sysconf THEN DO:
  v-mes = substitute("Не найдена фирма &1", parhost-code).
  run err-mess(input-output v-mes).
  undo _main, return error v-mes.
END.

  /*проверка на соответствие типа и расш. типа*/
if lookup(parext-type,{&WDEDT_List-Return}) > 0 and pardoc-type <> {&return} or
   lookup(parext-type,{&WDEDT_List-Write-Off}) > 0 and pardoc-type <> {&write-off} or
   lookup(parext-type,{&WDEDT_List-expense}) > 0 and pardoc-type <> {&expense} or
   lookup(parext-type,{&WDEDT_List-Income}) > 0 and pardoc-type <> {&income} then do:
     v-mes = substitute("Расширенный тип документа &1 не соответствует типу документа &2",parext-type, pardoc-type).
     run err-mess(input-output v-mes).
     undo _main, return error (v-mes).
end.

if parauto-fill and parobj-type = {&stock} then do:
  v-mes = substitute("Для автоматического документа объект документа &1&2 должен быть магазином", parobj-type, parobj-code).
  run err-mess(input-output v-mes).
  var-entry = "obj-code":U.
  undo _main, return error (if p-silent then v-mes else var-entry).
end.

if parauto-fill and pardoc-type = {&write-off} then do:
  v-mes = substitute("Не бывает автоматических документов с типом", pardoc-type).
  run err-mess(input-output v-mes).
  undo _main, return error (v-mes).
end.

if parauto-fill and parlines-exist then do:
  if (
      (parcli-type = ub.sysconf.sale-type AND
       parcli-code = ub.sysconf.sale-code) AND
       can-find(first ub.chk-doc No-LOCK WHERE
                      ub.chk-doc.obj-type = parobj-type
                  and ub.chk-doc.obj-code = parobj-code
                  and ub.chk-doc.out-code = pardoc-code)
     ) then do:
    v-mes = substitute("К автодокументу МЦ для контрагента &1&2 не могут быть привязаны чеки МЦ", parcli-type, parcli-code).
    run err-mess(input-output v-mes).
    undo _main, return error (v-mes).
  end.
  if ( not par-borned and
       NOT (parcli-type = ub.sysconf.sale-type AND
           parcli-code = ub.sysconf.sale-code) AND
       NOT can-find(first ub.chk-doc No-LOCK WHERE
                          ub.chk-doc.out-code = pardoc-code)
    ) then do:
    v-mes = substitute("К данному автодокументу должны быть привязаны чеки МЦ").
    run err-mess(input-output v-mes).
    undo _main, return error (v-mes).
  end.
end.


FIND FIRST buf_clients No-LOCK WHERE
          buf_clients.obj-type = parcli-type AND
          buf_clients.obj-code = parcli-code NO-ERROR.
IF NOT AVAIL buf_clients THEN DO:
  v-mes = substitute("Не найден клиент &1&2 в справочнике клиентов", parcli-type, parcli-code).
  run err-mess(input-output v-mes).
  var-entry = "cli-type":U.
  undo _main, return error (if p-silent then v-mes else var-entry).
END.

if buf_clients.stts <> 0 then do:
  v-mes = substitute( "Нельзя создавать документ для удаленного контрагента &1&2", parcli-type, parcli-code).
  run err-mess(input-output v-mes).
  var-entry = "cli-type":U.
  undo _main, return error (if p-silent then v-mes else var-entry).
end.
parcli-name = buf_clients.obj-name.

IF par-inter_ AND
 NOT ( parcli-type = parobj-type AND
       parcli-code = parobj-code) then do:
  v-mes = substitute( "Для документа внутриобъектного перемещения МЦ неверно определен клиент &1&2", parcli-type, parcli-code).
  run err-mess(input-output v-mes).
  var-entry = "cli-type":U.
  undo _main, return error (if p-silent then v-mes else var-entry).
end.

IF par-exter_ and not parext-type = {&WDEDT_Put_Sale} then do:
  IF
  (parcli-type = parobj-type AND
  parcli-code = parobj-code) OR
  parcli-type = {&shop} OR
  parcli-type = {&stock}
  then do:
    v-mes = substitute( "Для документа внешнего перемещения МЦ неверно определен клиент &1&2", parcli-type, parcli-code).
    run err-mess(input-output v-mes).
    var-entry = "cli-code":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
end.
else if  parext-type = {&WDEDT_Put_Sale} then do:
 IF NOT ( parcli-type = {&SHOP} OR
          parcli-type = {&stock}) then do:
    message "Для документа погашения МЦ неверно определен клиент"
    view-as alert-box error .
    var-entry =  "cli-type":U.
    RETURN ERROR var-entry.
  END.
end.
else do:
 IF NOT ( parcli-type = {&SHOP} OR
          parcli-type = {&stock}) then do:
    message "Для документа внутренного перемещения МЦ неверно определен клиент"
    view-as alert-box error .
    var-entry =  "cli-type":U.
    RETURN ERROR var-entry.
  END.
  CASE parcli-type:
    when {&shop} then do:
      FIND FIRST ub.shop no-LOCK WHERE
                 ub.shop.obj-code = parcli-code No-ERROR.
      if not avail ub.shop or ub.shop.host-code <> parhost-code then do:
        message "Для документа внутренного перемещения МЦ неверно определен клиент" SKIP
                "магазин принадлежит другой фирме"
        view-as alert-box .
        var-entry =  "cli-code":U.
      end.
    end.
    when {&stock} then do:
      FIND FIRST ub.store no-LOCK WHERE
                 ub.store.obj-code = parcli-code No-ERROR.
      if not avail ub.store or ub.store.host-code <> parhost-code then do:
        message "Для документа внутренного перемещения МЦ неверно определен клиент" SKIP
                "склад принадлежит другой фирме"
        view-as alert-box .
        var-entry =  "cli-code":U.
      end.
    end.
  END CASE.

end.
if pardoc-type = {&write-off} and
   (par-inter_ or
    (par-exter_ AND NOT (parcli-type = {&cmp} AND parcli-code = parhost-code))
   ) then do:
  v-mes = substitute( "Для документа внутреннего перемещения МЦ типа &1 неверно определен клиент &2&3&4склад принадлежит другой фирме"
                     , pardoc-type
                     , parcli-type
                     , parcli-code
                     , {&new-line}

                     ).
  run err-mess(input-output v-mes).
  var-entry = "cli-code":U.
  undo _main, return error (if p-silent then v-mes else var-entry).
end.

FIND FIRST buf_wth-line No-LOCK WHERE
           buf_wth-line.doc-code = pardoc-code No-ERROR.
IF AVAIL buf_wth-line then do:
  if parext-type <> {&WDEDT_Dst_Cli} then do:
    FIND FIRST current-place NO-LOCK WHERE
        current-place.host-code   = parhost-code AND
        current-place.obj-type    = parobj-type AND
        current-place.obj-code    = parobj-code AND
        current-place.w-p-code    = buf_wth-line.w-p-code  NO-ERROR.
    IF NOT AVAIL current-place and
        not (buf_wth-line.w-p-code = 0 or buf_wth-line.w-p-code = ?)
    THEN DO:
      v-mes = substitute( "Не найдено место хранения МЦ &1 в справочнике!"
                          ,buf_wth-line.w-p-code
                        ).
      run err-mess(input-output v-mes).
      var-entry = "current-w-p-code":U.
      undo _main, return error (if p-silent then v-mes else var-entry).
    END.
  end.
  if parauto-fill and current-place.cash-desk = 0 and not par-borned  then do:
    v-mes = substitute( "Для автоматического документа МХ МЦ &1 должно быть кассой"
                        ,buf_wth-line.w-p-code
                      ).
    run err-mess(input-output v-mes).
    var-entry = "current-w-p-code":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  if parobj-type = parcli-type AND
     parobj-code = parcli-code and
     par-inter_  = yes         and
    (buf_wth-line.out-code = 0 or buf_wth-line.out-code = ?) THEN DO:
    v-mes = substitute( "Для внутриобъектного перемещения не указано место хранения!"
                        ,buf_wth-line.out-code
                      ).
    run err-mess(input-output v-mes).
    var-entry = "out-w-p-code":U.
    undo _main, return error (if p-silent then v-mes else var-entry).

  end.

  FIND FIRST out-place NO-LOCK WHERE
            out-place.host-code   = parhost-code AND
            out-place.obj-type    = parcli-type AND
            out-place.obj-code    = parcli-code AND
            out-place.w-p-code    = buf_wth-line.out-code  NO-ERROR.

  IF NOT AVAIL out-place AND
     buf_wth-line.out-code <> 0 AND
     buf_wth-line.out-code <> ? AND
     pardoc-type <> {&return} and
     pardoc-type <> {&income} and
     par-exter_ = no  and
     par-inter_ = no THEN DO:
    v-mes = substitute( "Не найдено место хранения МЦ &1 в справочнике!"
                        ,buf_wth-line.out-code
                      ).
    run err-mess(input-output v-mes).
    var-entry = "out-w-p-code":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  END.
  if parauto-fill and par-borned and out-place.cash-desk = 0 then do:
    v-mes = substitute( "Для автоматического документа МХ МЦ &1 должно быть кассой"
                        ,buf_wth-line.out-code
                      ).
    run err-mess(input-output v-mes).
    var-entry = "out-w-p-code":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  IF parobj-type = parcli-type AND
     parobj-code = parcli-code and
     par-inter_ = yes THEN DO:
    IF current-place.w-p-code = out-place.w-p-code THEN DO:
      v-mes = substitute( "Нельзя перемещать МЦ в место их хранения!"
                          ,buf_wth-line.out-code
                        ).
      run err-mess(input-output v-mes).
      var-entry = "out-w-p-code":U.
      undo _main, return error (if p-silent then v-mes else var-entry).
    END.
    if pardoc-type = {&expense} then parcli-name = out-place.w-p-name.
    else if pardoc-type = {&income} then parcli-name = current-place.w-p-name.
  END.
end.
else do:
/*нет строк!!*/
  if parlines-exist then do:
    v-mes = substitute( "Нет строк в документе!" ).
    run err-mess(input-output v-mes).
    var-entry = "b-add":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
end.
/* проверка на обязательность заполнения физ. лиц по настроечному параметру */
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-stfactpref as character no-undo .
define variable v-numsfact   as integer no-undo .

define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
run adm/shattri.p (
    input "get":U
    ,input  parobj-type
    ,input  parobj-code
    ,input  {&attr-wthdoc_obj}
    ,input  'prsdoc':U /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error  then do:
    v-chk-wth-prs =  v-value-logical.
end.

if par-operator  <> ? or v-chk-wth-prs then do:
  FIND FIRST buf_operator NO-LOCK WHERE
    buf_operator.obj-type = {&prs}         AND
    buf_operator.obj-code = par-operator NO-ERROR.
  IF NOT AVAIL buf_operator THEN DO:
    v-mes = substitute( "Не найдено физ.лицо &1 в справочнике клиентов!", par-operator ).
    run err-mess(input-output v-mes).
    var-entry = "operator":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  END.
end.
if par-deliver  <> ? or v-chk-wth-prs then do:
  FIND FIRST buf_deliver NO-LOCK WHERE
    buf_deliver.obj-type = {&prs}         AND
    buf_deliver.obj-code = par-deliver NO-ERROR.
  IF NOT AVAIL buf_deliver THEN DO:
    v-mes = substitute( "Не найдено физ.лицо &1 в справочнике клиентов!", par-deliver ).
    run err-mess(input-output v-mes).
    var-entry = "deliver":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  END.
end.
if par-receiver <> ? or
   (v-chk-wth-prs and
    lookup(parext-type, {&type-psnattr-view}) = 0)
then do:
  FIND FIRST buf_receiver NO-LOCK WHERE
    buf_receiver.obj-type = {&prs}         AND
    buf_receiver.obj-code = par-receiver NO-ERROR.
  IF NOT AVAIL buf_receiver THEN DO:
    v-mes = substitute( "Не найдено физ.лицо &1 в справочнике клиентов!", par-receiver ).
    run err-mess(input-output v-mes).
    var-entry = "receiver":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  END.
end.

if parsource-ref <> '':U and parsource-ref <> ? then do:
  if parsource-ref = pardoc-code and parsource-type = {&wthd-wth-doc} then do:
    v-mes = substitute( "Нельзя связать документ с самим собой!" ).
    run err-mess(input-output v-mes).
    var-entry = "source-ref":U.
    undo _main, return error (if p-silent then v-mes else var-entry).
  end.
  CASE parsource-type:
    when {&wthd-wth-doc} then do:
      IF par-inter_ then do:   /* проверяем только для внутриобъектных документов. Для внутренних связанного может и не быть в этой БД */
        find first bind_wth-doc No-LOCK WHERE
                  bind_wth-doc.doc-code = parsource-ref No-ERROR.
        if not avail bind_wth-doc then do:
          v-mes = substitute("Не найден документ &1 для связи!", parsource-ref ).
          run err-mess(input-output v-mes).
          var-entry = "source-ref":U.
          undo _main, return error (if p-silent then v-mes else var-entry).
        end.
      end.
    end.
    when {&wthd-cash-desk} then do:
      find first bind_inkas No-LOCK WHERE
                bind_inkas.inkas-code = parsource-ref No-ERROR.
      if not avail bind_inkas then do:
        v-mes = substitute("Не найден документ &1 для связи!", parsource-ref ).
        run err-mess(input-output v-mes).
        var-entry = "source-ref":U.
        undo _main, return error (if p-silent then v-mes else var-entry).
      end.
    end.
    OTHERWISE do:
        v-mes = substitute("Неверный тип документа &1 для связи", parsource-type ).
        run err-mess(input-output v-mes).
        var-entry = "source-type":U.
        undo _main, return error (if p-silent then v-mes else var-entry).
    end.
  END CASE.
end.
end. /*doe*/


PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mes as character No-UNDO.
  p-mes = substitute("Документ МЦ №&1: &2&3&4&5", pardoc-code, parobj-type, parobj-code, {&new-line}, p-mes).
  if not p-silent then
  message
  p-mes
  view-as alert-box error .
END PROCEDURE.