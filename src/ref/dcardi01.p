block-level on error undo, throw.
/*

$Revision: 560be6005277, 558, rls $
$Author: PGridchina $
$Date: Wed Mar 30 17:48:23 2016 +0400 $
$Workfile: dcardi01.p $
$Archive: ref/dcardi01.p $

Сохранение изменений в карточке дисконтной карты

Автор: Бахтадзе Наталья Викторовна
Дата создания: 11/16/05
Author: Bakhtadze Natalya
Creation date: 11/16/05

*/

/*
Мастеръ Гамбсъ этимъ полукресломъ
начинаетъ новую партiю мебели.
1865 г.
Санктъ-Петербургъ.

ОТДЕЛЕНИЕ БИЗНЕС-ЛОГИКИ ОТ ИНТЕРФЕЙСА!!!!!

*/

define input parameter parparentproc   as widget-handle no-undo .
define input parameter p-parent-handle as handle        no-undo .
define input parameter p-log-handle    as handle        no-undo .
define input parameter p-hn-handle     as handle        no-undo . /*handle для вызова процедур истории и маршрутизации - используется в saledc*/
define input parameter p-silent                       as logical no-undo . /*может быть yes  с выводом в файл no с руганью на экран и ? c return-value*/
define input-output parameter par-rid as recid no-undo .
define input parameter par-mode as character no-undo .
define input parameter par-mode2 as character no-undo .
define input parameter p-curr-obj-type  like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code  like ub.clients.obj-code no-undo .

define input parameter pard-card as character no-undo  case-sensitive.
define input parameter paremitent-host-code like ub.dis-card.emitent-host-code no-undo .
define input parameter parcli-type like ub.dis-card.cli-type no-undo .
define input parameter parcli-code like ub.dis-card.cli-code no-undo .
define input parameter par-status_ like ub.dis-card.status_ no-undo .
define input parameter par-type like ub.dis-card.type no-undo .
define input parameter pard-pcnt like ub.dis-card.d-pcnt no-undo .
define input parameter parcash-d-pcnt like ub.dis-card.cash-d-pcnt no-undo .
define input parameter parcategory like ub.dis-card.category no-undo .
define input parameter pard-pcnt-method like ub.dis-card.d-pcnt-method no-undo .
define input parameter parcredit-card like ub.dis-card.credit-card no-undo .
define input parameter parlim-kr like ub.dis-card.lim-kr no-undo .
define input parameter pardebet-card like  ub.dis-card.debet-card  no-undo .
define input parameter parstaff-card like  ub.dis-card.staff-card  no-undo .
define input parameter parissue-date like ub.dis-card.issue-date no-undo .
define input parameter parissue-code like ub.dis-card.issue-code no-undo .
define input parameter parvalid-from like ub.dis-card.valid-from no-undo .
define input parameter parvalid-date like ub.dis-card.valid-date no-undo .
define input parameter parsourced-card like ub.dis-card.sourced-card no-undo .
define input parameter parcli-message like ub.dis-card.cli-message no-undo case-sensitive.
define input parameter parmask-card   like ub.dis-card.mask-card no-undo .
define input parameter parmain-card   like ub.dis-card.main-card no-undo .
define input parameter paris-subsid   like ub.dis-card.is-subsid no-undo .
define input parameter p-update-prop  as logical no-undo .
define temp-table tt0-dis-card-property no-undo like ub.dis-card-property.
DEFINE INPUT PARAMETER TABLE FOR tt0-dis-card-property.




define variable vss-revision    as character no-undo init "$Revision: 560be6005277, 558, rls $":U .
define variable vss-author      as character no-undo init "$Author: PGridchina $":U .
define variable vss-date        as character no-undo init "$Date: Wed Mar 30 17:48:23 2016 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dcardi01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/dcardi01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке дисконтной карты".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ trg/discardh.i }
{ trg/discardh.i "rul" }
{ trg/maskfunc.i }
{ str/defc-cli.i "NEW SHARED" }
{ cmp/dc-list.i dc-list def "new shared" }
{ cmp/dcp-list.i dcp-list def "new SHARED" }
{ ref/discprop.i }

DEFINE VARIABLE loc#log as logical no-undo .
DEFINE VARIABLE dd as decimal no-undo .
DEFINE VARIABLE VAR-ENTRY as character no-undo .
DEFINE VARIABLE varcard-num like ub.dis-card.card-num no-undo .
define variable v-ok as logical no-undo .
define variable v-descr as character no-undo .
define variable v-dop-d-card as character no-undo .
define variable ii as integer no-undo .
define variable old-sourced-card like ub.dis-card.sourced-card no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-deleted as logical no-undo .
define variable v-type as character no-undo .
define variable v-can-issue as logical no-undo .
define variable v-can-edit as logical no-undo .
define variable v-err-mess as character no-undo .
define variable v-import as logical no-undo .
define variable v-rum as logical no-undo .
define variable v-old-title as character no-undo .
define variable v-has-right-to-restore as logical no-undo .
define variable v-first-card like ub.dis-card.first-card no-undo .
define variable v-first-main-card like ub.dis-card.first-main-card no-undo .
define variable v-overissue-num like ub.dis-card.overissue-num no-undo .

define buffer source_dis-card for ub.dis-card.
define buffer main_dis-card for ub.dis-card.
define buffer other_dis-card for ub.dis-card.
define buffer buf_clients for ub.clients.
define buffer buf_dis-host for ub.dis-host .
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dis-card-type for ub.dis-card-type.
define buffer buf_dis-card-property for ub.dis-card-property.

{ trg/new-bcod.i }

if g#db-num > 0 then do:
  message  vss-workfile vss-revision vss-description skip
          "Вызов процедуры в УБД запрещен"
  view-as alert-box ERROR.
  return error '':u.
end.


if par-mode <> {&add-def}
AND par-mode <> {&update}
AND par-mode <> {&add-import}
then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр par-mode - " par-mode
  view-as alert-box error .
  return error '':u.
end.
if par-mode  = {&add-import} then do:
  v-import = yes.
  par-mode = {&add-def}.
end.
if par-mode2 <> '':U then
assign
v-import = (par-mode2 = "import":U)
v-rum = (par-mode2 = "rum":U)
.

if num-entries(par-status_, {&delim-par}) > 1 then
assign
v-has-right-to-restore = logical(entry(2, par-status_, {&delim-par}))
par-status_ = entry(1, par-status_, {&delim-par} )
.

if par-type = "" then do:
  assign
  v-err-mess = substitute("Тип дисконтной карты не может быть пустым").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "type":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.

if parcli-type <> {&prs}
and parcli-type <> {&cmp} then do:
  assign
  v-err-mess =  substitute("Неверный тип клиента &1"
                          , (if parcli-type= ? then {&question-mark} else parcli-type)
                              ).

  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "cli-type":U.
  return error (if p-silent = yes then v-err-mess else var-entry).

end.

find first buf_clients no-lock where
          buf_clients.obj-type = parcli-type
      AND buf_clients.obj-code = parcli-code no-error .
if not available buf_clients  then do:
  assign
  v-err-mess = substitute("Не найден клиент &1&2 для карты"
             , (if parcli-type= ? then {&question-mark} else parcli-type)
             , (if parcli-code= ? then {&question-mark} else string(parcli-code))).

  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "cli-code":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.



FIND FIRST buf_dis-card-type share-LOCK WHERE
           buf_dis-card-type.type = par-type AND
           buf_dis-card-type.emitent-host-code = paremitent-host-code AND
           buf_dis-card-type.host-code = 0 AND
           buf_dis-card-type.obj-type = "":U AND
           buf_dis-card-type.obj-code = 0 No-ERROR.
if not avail buf_dis-card-type then do:
  assign
  v-err-mess = substitute("Неверный тип дисконтной карты").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "type":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.

if paremitent-host-code <> 0 and not can-find( first ub.sysconf No-LOCK WHERE
                       ub.sysconf.host-code = paremitent-host-code) then do:
  assign
  v-err-mess = substitute("Нет фирмы-эмитента дисконтной карты").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "host-code":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.

if pard-pcnt < 0 or parcash-d-pcnt < 0 then do:
  if pard-pcnt < 0 then do:
    assign
    v-err-mess = substitute("Скидка по дисконтной карте &1 не может быть отрицательной", pard-pcnt).
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "d-pcnt":U.
  end.
  if parcash-d-pcnt < 0 then do:
    assign
    v-err-mess = substitute("Скидка по дисконтной карте &1 не может быть отрицательной", parcash-d-pcnt).
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "cash-d-pcnt":U.
  end.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.

if pard-pcnt > 100 or parcash-d-pcnt > 100 then do:
  if pard-pcnt > 100 then  do:
    assign
    v-err-mess = substitute("Скидка по дисконтной карте &1 не может быть больше 100%", pard-pcnt).
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "d-pcnt":U.
  end.
  if parcash-d-pcnt > 100 then do:
    assign
    v-err-mess = substitute("Скидка по дисконтной карте &1 не может быть больше 100%", parcash-d-pcnt).
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "cash-d-pcnt":U.
  end.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.

if pard-pcnt > 50 or parcash-d-pcnt > 50 then do:
  if not p-silent then do:
    message "Вы уверены что скидка по дисконтной карте выше 50%?"
    view-as alert-box QUESTION buttons YES-NO update loc#log.
    if NOT loc#log  then do:
      if pard-pcnt > 50 then do:
        var-entry = "d-pcnt":U.
      end.
      else do:
        var-entry = "cash-d-pcnt":U.
      end.
      return error (if p-silent = yes then v-err-mess else var-entry).
    end.
  end.
end.

if paremitent-host-code = 0 and parcredit-card then do:
  assign
  v-err-mess = substitute("Глобальная дисконтная карта не может быть кредитной").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "credit-card":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.

if parcredit-card and parlim-kr <= 0 then do:
  assign
  v-err-mess  = substitute("Неверный лимит кредита &1, если дисконтная карта кредитная, лимит кредита должен быть положительным"
                           ,parlim-kr).
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "lim-kr":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.

if parcredit-card and pardebet-card then do:
  assign
  v-err-mess = substitute("Карта не может быть одновременно и кредитной и дебетовой").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "credit-card":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.


if parissue-code = 0 and not parmask-card then do:
    assign
    v-err-mess = substitute("Не указан код магазина, выдавшего карту").
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "issue-code":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
end.

if not parmask-card then do:
  find first ub.shop no-lock where
            ub.shop.obj-code = parissue-code NO-ERROR.
  if not avail ub.shop or (paremitent-host-code <> 0 and ub.shop.host-code <> paremitent-host-code) then do:
    assign
    v-err-mess = substitute("Не найден магазин &1, выдавший карту, или он принадлежит другой фирме", parissue-code).
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "issue-code":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  define buffer shop_clients for ub.clients.
  find first shop_clients no-lock where
           shop_clients.obj-type = {&shop}
       and shop_clients.obj-code = parissue-code .
  if shop_clients.stts <> integer({&current-status-int}) then do:
    if p-silent then do:
&scop status-code string(shop_clients.stts)
      assign
      v-err-mess = substitute("Магазин &1, выдавший карту, имеет статус 2&3" +
                              "Нельзя выдать карту от имени этого магазина!"
                              , parissue-code
                              , {&status-int-name}
                              , {&new-line}
                              ).
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "issue-code":U.
      return error (if p-silent = ? then v-err-mess else var-entry).
    end.
    else do:
      assign
      v-err-mess = substitute("Магазин &1, выдавший карту, имеет статус &2&3" +
                              "Вы уверены, что хотите выдать карту от имени этого магазина?"
                              , parissue-code
                              , {&status-int-name}
                              , {&new-line}
                              ).
      define variable glog as logical no-undo .
      message
      v-err-mess view-as alert-box warning buttons yes-no update glog.
      if not glog then do:
        var-entry = "":U.
        return error var-entry.
      end.
    end.
  end.
end.



if parissue-date = ? then do:
  assign
  v-err-mess = substitute("Не указана дата выдачи карты").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "issue-date":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.

if parvalid-from = ? then do:
  assign
  v-err-mess = substitute("Не указана дата начала действия карты").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "valid-from":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.

if parvalid-from < 01/01/2000
and buf_dis-card-type.card-media = integer({&dc-cm-ef})
 then do:
  assign
  v-err-mess = substitute("Дата начала действия карты типа EasyFuel не может быть ранее 01/01/2000").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "valid-from":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.


if parvalid-date = ?
and buf_dis-card-type.card-media = integer({&dc-cm-ef})
then do:
  assign
  v-err-mess = substitute("Не указана дата окончания действия карты").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "valid-date":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.

if (parvalid-date - parvalid-from) > 4095
and buf_dis-card-type.card-media = integer({&dc-cm-ef})
then do:
  assign
  v-err-mess = substitute("Карта типа EasyFuel не может действовать больше 4095 дней &1" +
                          "Еесли начало срока действия карты &2, то конец срока действия может быть не позже &3"
                          , {&new-line}
                          ,string(parvalid-from, "99/99/9999")
                          ,string(parvalid-from + 4095, "99/99/9999")
                            ).
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "valid-date":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.




if parvalid-date < parissue-date then do:
  assign
  v-err-mess = substitute("Неверная дата окончания действия карты &1", parvalid-date).
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "valid-date":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.

if parvalid-date < parvalid-from then do:
  assign
  v-err-mess = substitute("Неверная дата окончания действия карты &1", parvalid-date).
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "valid-date":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.


if  trim(pard-card) = "" then do:
  assign
  v-err-mess = substitute("Не указан номер карты").
  run err-mess in this-procedure ( input-output v-err-mess).
  var-entry = "d-card":U.
  return error (if p-silent = yes then v-err-mess else var-entry).
end.

if parmask-card then do:
  /* у нас карта-маска*/
  run check-mask-card in this-procedure (
                                          input pard-card
                                        , input no /*p-silence*/
                                        , output v-ok
                                        , output v-descr) no-error .
  if error-status:error then do:
    assign
    v-err-mess = substitute("Ошибка при проверке карты-маски: &1 &2", error-status:get-message(1), return-value ).
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "d-card":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  if not v-ok then do:
    var-entry = "d-card":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
end.
else do:
  if par-type = {&dct-client} then do:
&scop dct-client-obj-type parcli-type
&scop dct-client-obj-code parcli-code
    if pard-card <> {&dct-client-card-no} then do:
        assign
        v-err-mess = substitute("Для карты типа &1 возможно только уникальное значение номера карты клиента = &2"
                                 ,{&dct-client}
                                 ,{&dct-client-card-no} ).
        run err-mess in this-procedure ( input-output v-err-mess).
        var-entry = "d-card":U.
        return error (if p-silent = yes then v-err-mess else var-entry).

    end.
  end.
  else do:
    if trim(pard-card) <> pard-card then do:
      assign
      v-err-mess = substitute("В номере карты присутствуют недопустиые символы").
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "d-card":U.
      return error (if p-silent = ? then v-err-mess else var-entry).
    end.
    if buf_dis-card-type.card-media = integer({&dc-cm-ef}) then do:
      /*шестнадцатиричное*/
      if length(pard-card) <> 8
      or trim(pard-card, "1234567890ABCDEF") <> ""
      or CAPS(pard-card) <> pard-card
      or pard-card = "00000000"
      then do:
        assign
        v-err-mess = substitute("Идентификатор карты EASYFUEL должен представлять 16-чное число&1" +
                                "и быть длиной 8 символов," +
                                "разрешены только цифры и ПРОПИСНЫЕ латинские A, B, C, D, E, F,&1" +
                                "идентификатор 00000000 не разрешен"
                                ,{&new-line})
        .
        run err-mess in this-procedure ( input-output v-err-mess).
        var-entry = "d-card":U.
        return error (if p-silent = yes then v-err-mess else var-entry).
      end.
    end.
    else do:
    /*обычная реальная карта*/
      dd = decimal( pard-card ) no-error.
      if ( error-status:error ) OR
          index( pard-card , "." ) > 0 OR
          index( pard-card , {&comma-char} ) > 0 OR
          index( pard-card , "-" ) > 0 OR
          index( pard-card , "+" ) > 0 then
          do:
          assign
          v-err-mess = substitute("Возможно только цифровое значение номера дисконтной карты клиента").
          run err-mess in this-procedure ( input-output v-err-mess).
          var-entry = "d-card":U.
          return error (if p-silent = yes then v-err-mess else var-entry).
      end.
      run ref/dcardi04.p (
                      input pard-card
                      /*код проверяемой карты*/
                      ,input par-type
                      ,input paremitent-host-code
                      ,input parissue-code
                      /*объект выдачи*/
                      ,output v-can-issue              ) no-error .
                      /*пользователь может выпустить*/
      if error-status:error then do:
        assign
        v-err-mess = substitute("Ошибка при проверке корректности № карты:&1&2 &4"
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                    ).


          run err-mess in this-procedure ( input-output v-err-mess).
          var-entry = "d-card":U.
          return error (if p-silent = yes then v-err-mess else var-entry).
      end.
      if not v-can-issue then do:
        assign
        v-err-mess = substitute("Некорректный номер карты:&1"
                                  , return-value
                                    ).

        run err-mess in this-procedure ( input-output v-err-mess).
        var-entry = "d-card":U.
        return error (if p-silent = yes then v-err-mess else var-entry).
      end.
    end. /*обычная реальная карта*/
  end.
end.

_main:
do for buf_dis-card,
       source_dis-card,
       main_dis-card
on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
:

if par-mode = {&add-def} then do:
  if can-find( FIRST ub.dis-card No-LOCK where
                    ub.dis-card.d-card = pard-card
                       ) then do:
    assign
    v-err-mess = substitute("Уже есть глобальная дисконтная карта&1 с номером &2"
                , (if paremitent-host-code = 0
                  then "":U
                  else substitute(" на фирме &1", paremitent-host-code))
                , pard-card
                ).

    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "d-card":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end. /*can-find*/
  define variable v-param-type as character no-undo .
  define variable v-value-character as character no-undo .
  define variable v-value-date as date no-undo .
  define variable v-value-decimal as decimal no-undo .
  define variable v-value-integer as INTEGER no-undo .
  define variable l-zeros AS LOGICAL no-undo .
  define variable v-tth as handle no-undo .

  run adm/shattri.p (
      input "get":U
      ,input  ''
      ,input  0
      ,input  {&attr-dc-ref}
      ,input  {&attr-dc-ref_l-zeros} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output l-zeros
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) {4} .

  delete object v-tth no-error.

  if not l-zeros then do:
  assign
  v-dop-d-card = left-trim(pard-card, "0") .
  DO II = 1  to (19 - length(v-dop-d-card)) + 1:
    if can-find(first ub.dis-card no-lock where
                      ub.dis-card.d-card = v-dop-d-card
                  and ub.dis-card.status_ <> {&deleted-status}
                      )  then do:
    assign
      v-err-mess = substitute("Уже есть НЕУДАЛЕННАЯ дисконтная карта&1 с номером &2 - совпадает с &3 с точностью до лидирующих нулей"
                , (if paremitent-host-code = 0
                  then "":U
                  else substitute(" на фирме &1", paremitent-host-code))
                  ,v-dop-d-card
                  ,pard-card
                  ).
    run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "d-card":U.
      return error (if p-silent = yes then v-err-mess else var-entry).
    end.
    assign
    v-dop-d-card = "0" + v-dop-d-card
    .
  end.
  end.
  assign
  v-first-card = pard-card
  v-first-main-card = pard-card
  .
  if parsourced-card <> "" then do:
    find first source_dis-card exclusive-LOCK WHERE
              source_dis-card.d-card = parsourced-card  No-ERROR.
    if not available source_dis-card
    and not locked(source_dis-card)
    then do:
      assign
      v-err-mess  = substitute("Не найдена карта, к которой перевыпускается текущая карта", parsourced-card).
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "sourced-card":U.
      return error (if p-silent = yes then v-err-mess else var-entry).
    end.
    if source_dis-card.status_ = {&nonused-status}
    or source_dis-card.status_ = {&chown-status} then do:
      v-err-mess = substitute("Карта к которой, перевыпускается текущая карта, - &1 имеет статус &2&3" +
                              "перевыпуск запрещен"
                  , parsourced-card
                  ,source_dis-card.status_
                  ,{&new-line}
                  ).
    end.
    if source_dis-card.emitent-host-code <> paremitent-host-code then do:
      assign
      v-err-mess = substitute("Карта к которой, перевыпускается текущая карта, - &1 имеет другого эмитента &2"
                  , parsourced-card
                  ,source_dis-card.emitent-host-code).

      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "sourced-card":U.
      return error (if p-silent = yes then v-err-mess else var-entry) .
    end.
    /* пока запретим перевыпускать дополнительные*/
    if source_dis-card.is-subsid then do:
      assign
      v-err-mess = substitute("Карта к которой, перевыпускается текущая карта, - &1 является дополнительной&2" +
                              "перевыпуск запрещен"
                  , parsourced-card
                  ,{&new-line}).
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "sourced-card":U.
      return error (if p-silent = yes then v-err-mess else var-entry) .
    end.
    if NOT (source_dis-card.cli-type = parcli-type AND
            source_dis-card.cli-code = parcli-code) then do:
      assign
      v-err-mess = substitute("Карта к которой, перевыпускается текущая карта, - &1 выдана другому клиенту &2&3"
                  , parsourced-card
                  , source_dis-card.cli-type
                  , source_dis-card.cli-code).

      run err-mess in this-procedure ( input-output v-err-mess).
      return error v-err-mess.
    end.
    varcard-num = source_dis-card.card-num.
    if varcard-num = 0 then do:
      assign
      v-err-mess = substitute("Неверный внутренний № (&1) у карты &2, к которой перевыпускается текущая карта"
                  , varcard-num
                  , parsourced-card
                   ).
      run err-mess in this-procedure ( input-output v-err-mess).
      return error v-err-mess.
    end.
    for each other_dis-card no-lock where
            other_dis-card.card-num = source_dis-card.card-num
       AND  other_dis-card.sourced-card = parsourced-card:
        LEAVE.
    end.
    if available other_dis-card
    and
    other_dis-card.d-card <> pard-card  then do:
      assign
      v-err-mess = substitute("К карте &1 уже перевыпущена другая карта - &2"
                   , parsourced-card
                   , other_dis-card.d-card).

      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "sourced-card":U.
      return error (if p-silent = yes then v-err-mess else var-entry).
    end.
    assign
    v-first-main-card = source_dis-card.first-main-card
    v-first-card = source_dis-card.first-card.
    v-overissue-num = source_dis-card.overissue-num + 1.
  end. /*if parsourced-card <> "" then do:*/
  if paris-subsid <> no then do:
    find first main_dis-card exclusive-LOCK WHERE
              main_dis-card.d-card = parmain-card  No-ERROR.
    if not available main_dis-card
    and not locked(main_dis-card)
    then do:
      assign
      v-err-mess  = substitute("Не найдена ОСНОВНАЯ карта, к которой выпускается текущая ДОПОЛНИТЕЛЬНАЯ карта", parsourced-card).
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "main-card":U.
      return error (if p-silent = yes then v-err-mess else var-entry).
    end.
    if main_dis-card.status_ = {&nonused-status}
    or main_dis-card.status_ = {&chown-status} then do:
      v-err-mess = substitute("Основная карта, к которой перевыпускается текущая Дополнительная карта, - &1 имеет статус &2&3" +
                              "выпуск запрещен"
                  , parmain-card
                  ,main_dis-card.status_
                  ,{&new-line}
                  ).
    end.
    if main_dis-card.is-subsid = yes
    or main_dis-card.status_ = {&chown-status} then do:
      v-err-mess = substitute("Основная карта к которой, перевыпускается текущая Дополнительная карта, - &1 сама является Дополнительной&2" +
                              "выпуск запрещен"
                  , parmain-card
                  ,{&new-line}
                  ).
    end.
    if main_dis-card.emitent-host-code <> paremitent-host-code then do:
      assign
      v-err-mess = substitute("ОСНОВНАЯ Карта к которой, выпускается текущая карта, - &1 имеет другого эмитента &2"
                  , parmain-card
                  ,main_dis-card.emitent-host-code).

      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "main-card":U.
      return error (if p-silent = yes then v-err-mess else var-entry) .
    end.
    /*
    разрешим выпускать дополнительную карту на дргого клиента
    if NOT (main_dis-card.cli-type = parcli-type AND
            main_dis-card.cli-code = parcli-code) then do:
      assign
      v-err-mess = substitute("Карта к которой, выпускается текущая карта, - &1 выдана другому клиенту &2&3"
                  , parsmain-card
                  , main_dis-card.cli-type
                  , main_dis-card.cli-code).

      run err-mess in this-procedure ( input-output v-err-mess).
      return error v-err-mess.
    end.
    varcard-num = maiin_dis-card.card-num.
    if varcard-num = 0 then do:
      assign
      v-err-mess = substitute("Неверный внутренний № (&1) у основной карты &2, к которой выпускается текущая дополнительная карта"
                  , varcard-num
                  , parmain-card
                   ).
      run err-mess in this-procedure ( input-output v-err-mess).
      return error v-err-mess.
    end.
    */
    /*проверим что карта к которой выпускается своя */
    assign
    v-first-main-card = main_dis-card.first-main-card
    v-first-card = main_dis-card.first-card
    v-overissue-num = main_dis-card.overissue-num.
  end. /*if paris-subsid <> no then do:*/
  if varcard-num = 0 then do:
    run gen-b-code in this-procedure ( input {&gbl-dc-code}, output varcard-num) no-error .
    if error-status:error then do:
      assign
      v-err-mess = substitute("Ошибка при генерации внутреннего № ДК").
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "card-num":U.
      return error (if p-silent = yes then v-err-mess else var-entry).
    end.
  end.
  CREATE buf_dis-card.
  assign
  buf_dis-card.d-card = pard-card
  buf_dis-card.card-num = varcard-num
  .
  if v-import
  and valid-handle(p-hn-handle) then do:
      run discardh_write-dis-card-rul in p-hn-handle ( buffer buf_dis-card
                                                ,input buf_dis-card.type
                                                ,input buf_dis-card.emitent-host-code
                                                ,input (if par-mode = {&add-def}
                                                        then integer({&hn-create})
                                                        else integer({&hn-update})
                                                       )
                                                ).

  end.
  assign
  buf_dis-card.emitent-host-code = paremitent-host-code
  buf_dis-card.status_ =  (if par-status_ = '':U or par-status_ = ?
                            then {&current-status}
                            else par-status_)
  buf_dis-card.cli-type = parcli-type
  buf_dis-card.cli-code = parcli-code
  buf_dis-card.sourced-card = parsourced-card
  buf_dis-card.type = par-type
  buf_dis-card.d-pcnt = pard-pcnt
  buf_dis-card.cash-d-pcnt = parcash-d-pcnt
  buf_dis-card.category = parcategory
  buf_dis-card.d-pcnt-method = pard-pcnt-method
  buf_dis-card.credit-card = parcredit-card
  buf_dis-card.lim-kr = parlim-kr
  buf_dis-card.issue-code = parissue-code
  buf_dis-card.issue-date = parissue-date
  buf_dis-card.valid-from = parvalid-from
  buf_dis-card.valid-date = parvalid-date
  buf_dis-card.debet-card = pardebet-card
  buf_dis-card.staff-card = parstaff-card
  buf_dis-card.cli-message = parcli-message
  buf_dis-card.mask-card  = parmask-card
  buf_dis-card.main-card  = parmain-card
  buf_dis-card.first-card = v-first-card
  buf_dis-card.first-main-card = v-first-main-card
  buf_dis-card.is-subsid  = paris-subsid
  buf_dis-card.overissue-num  = v-overissue-num
  par-rid = recid( buf_dis-card )
  .
  if v-rum
  and valid-handle(p-hn-handle) then do:
      run discardh_send-dis-card-rul in p-hn-handle ( buffer buf_dis-card
                                                ,input buf_dis-card.type
                                                ,input buf_dis-card.emitent-host-code
                                                ,input (if par-mode = {&add-def}
                                                        then integer({&hn-create})
                                                        else integer({&hn-update})
                                                       )
                                                ).
  end.
  buf_Dis-card.trg-param = (if v-rum
                            then ({&trg-param-no-callnews} + {&comma-char} + {&trg-param-no-hist})
                            else '':U).

  release buf_dis-card no-error .
  if error-status:error then do:
    v-err-mess = substitute("Ошибка при сохранении записи ДИСКОНТНАЯ КАРТА&1&2&3&4"
                            ,error-status:get-message(1)
                            , {&new-line}
                            ,return-value
                            , {&new-line}).

    run err-mess in this-procedure ( input-output v-err-mess).
    undo _main, return error (if p-silent = yes then v-err-mess else '':U).
  end.
  if not v-rum then do:
    run str/saledc.p
        (
          input parparentproc
        ,input this-procedure :handle
        ,input ? /*p-log-handle*/
        ,input {&dct-proc_one-card-add}
        ,input ?  /*p-emitent-host-code*/
        ,input '':U /*p-type*/
        ,input 0 /*p-profile-id*/
        ,input 0 /*p-codex-id*/
        ,input 0 /*p-ruleset-id*/
        ,input g#db-num
        ,input pard-card
        ,input ? /*doc-date - выставим внутри*/
        ,input ? /*fact-date - выставим внутри*/
        ,input ? /*cre-pay*/
        ,input 1 /*p-sign*/
        ,input 1 /* p-direction */
        ,input yes /*p-save*/
        ) no-error .
    if error-status:error then do:
      undo _main, return error return-value .
    end.
  end.
end. /*add-def*/
else do:
  FIND FIRST buf_dis-card where
             recid(buf_dis-card) = par-rid No-ERROR.
  if not available buf_dis-card then do:
    assign
    v-err-mess = substitute("Не найдена или недоступна карта").
    run err-mess in this-procedure ( input-output v-err-mess).
    return error '':u.
  end.
  if buf_dis-card-type.d-pcnt-byshop and
    ((buf_dis-card.d-pcnt <> pard-pcnt) OR
      (buf_dis-card.cash-d-pcnt <> parcash-d-pcnt)
     )
    then do:
    assign
    v-err-mess = substitute("Нельзя изменить скидку на карте с дифференциацией скидки по объектам - она задается типом карты").
    run err-mess in this-procedure ( input-output v-err-mess).
    if (buf_dis-card.d-pcnt <> pard-pcnt) then do:
      var-entry = "d-pcnt":U.
    end.
    else do:
      var-entry = "cash-d-pcnt":U.
    end.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  if buf_dis-card.main-card <> parmain-card then do:
    assign
    v-err-mess = substitute("Нельзя изменить основную карту, к которой была выпущена данная дополнительная карта").
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "sourced-card":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  if buf_dis-card.is-subsid <> paris-subsid then do:
    assign
    v-err-mess = substitute("Нельзя изменить характеристику карты <ОСНОВНАЯ-или-ДОПОЛНИТЕЛЬНАЯ>").
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "sourced-card":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  if buf_dis-card.sourced-card <> parsourced-card then do:
    assign
    v-err-mess = substitute("Нельзя изменить карту, к которой была перевыпущена карта").
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "sourced-card":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  if paremitent-host-code <> 0 AND buf_dis-card.emitent-host-code <> paremitent-host-code then do:
    assign
    v-err-mess = substitute("Нельзя изменить эмитента карты с одной фирмы на другую").
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "emitent-host-code":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.
  { gbl/curr-r-b.i v-curr-r-b }
  if paremitent-host-code = 0 AND buf_dis-card.emitent-host-code <> 0
  and (parcredit-card = yes
       or (if v-curr-r-b = {&r-b-base}
           then (buf_dis-card.saldo-base < ( - 0.001))
           else (buf_dis-card.saldo-rubl < ( - 0.001))
         )
       )
  then do:
    assign
    v-err-mess = substitute( "Нельзя кредитную карту или карту с отрицательным сальдо по фирме &1 сделать глобальной картой"
                 , buf_dis-card.emitent-host-code).

    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "emitent-host-code":U.
    return error (if p-silent = yes then v-err-mess else var-entry).
  end.

  if paremitent-host-code <> 0 AND buf_dis-card.emitent-host-code = 0 then do:
    /*
    find first buf_dis-host no-lock where
              buf_dis-host.d-card = pard-card
          and buf_dis-host.host-code <> paremitent-host-code no-error .

    if available buf_dis-host then do:
    */
      assign
      v-err-mess = substitute("Нельзя глобальную карту сделать картой по фирме &1", buf_dis-card.emitent-host-code).
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "emitent-host-code":U.
      return error (if p-silent = yes then v-err-mess else var-entry).
    /*end.*/
  end.
  if buf_dis-card.status_ = {&deleted-status}
  and not v-has-right-to-restore
  then do:
    if not  v-can-edit /*это означает что читаем спул*/  then do:
      assign
      v-err-mess = substitute("У Вас нет прав на измение статуса удаленной карты!").
      run err-mess in this-procedure ( input-output v-err-mess).
      var-entry = "status_":U.
      return error (if p-silent = yes then v-err-mess else var-entry).
    end.
  end.
  if buf_dis-card.status_ = {&deleted-status}
  and buf_dis-card.mask-card = yes
  and not program-name(2) begins 'ref/dc-mask2.'
  then do:
    assign
    v-err-mess = substitute("Нельзя восстановить удаленную карту-маску!").
    run err-mess in this-procedure ( input-output v-err-mess).
    var-entry = "status_":U.
    return error (if p-silent = ? then v-err-mess else var-entry).
  end.
  /*напишем в историю */
  /*тут двойная запись возникает - пока закоментарим*/
  /*
  if not par-mode = {&add-def}
  then do:
    if buf_dis-card.type <> par-type
    or
    buf_dis-card.emitent-host-code <> paremitent-host-code
    or
    buf_dis-card.d-pcnt <> pard-pcnt
    or
    buf_dis-card.cash-d-pcnt <> parcash-d-pcnt
    or
    buf_dis-card.d-pcnt-method <> pard-pcnt-method
    or
    buf_dis-card.credit-card <> parcredit-card
    or
    buf_dis-card.lim-kr <> parlim-kr
    or
    buf_dis-card.issue-code <> parissue-code
    or
    buf_dis-card.issue-date <> parissue-date
    or
    buf_dis-card.valid-date <> parvalid-date
    or
    buf_dis-card.debet-card <> pardebet-card
    or
    buf_dis-card.staff-card <> parstaff-card
    or
    buf_dis-card.cli-message <> parcli-message
    or
    buf_dis-card.status_ <> par-status_
    or
    (buf_dis-card.mask-card
    and
    (buf_dis-card.cli-type <>  Parcli-type
    or
    buf_dis-card.cli-code <>  Parcli-code))
    then do:
      run discardh_write-dis-card-proc in this-procedure  (
                                                    buffer buf_dis-card
                                                  ,input (if g#news then {&hn-source-db} else "":U)
                                                  ,input (if g#news then string(g#news-source-db) else "":U)
                                                  ) .
    end.
  end.
  */
  /*
  if pard-pcnt-method <> buf_dis-card.d-pcnt-method then do:
    message "Нельзя изменить метод использования скидки по карте"
    view-as alert-box ERROR .
    var-entry = "d-pcnt-method":U.
    return error (if p-silent = yes then v-err-mess else var-entry)
  end.
  */
  /*при добавлении сюда сохраняемых полей надо добавить проверку что они изменились перед вызовом процедуры
  discardh_write-dis-card-proc
  */
  if v-rum
  and valid-handle(p-hn-handle) then do:
      run discardh_write-dis-card-rul in p-hn-handle ( buffer buf_dis-card
                                                ,input buf_dis-card.type
                                                ,input buf_dis-card.emitent-host-code
                                                ,input (if par-mode = {&add-def}
                                                        then integer({&hn-create})
                                                        else integer({&hn-update})
                                                       )
                                                ).

  end.
  assign
  buf_dis-card.type = par-type
  buf_dis-card.emitent-host-code = paremitent-host-code
  buf_dis-card.d-pcnt = pard-pcnt
  buf_dis-card.cash-d-pcnt = parcash-d-pcnt
  buf_dis-card.category = parcategory
  buf_dis-card.d-pcnt-method = pard-pcnt-method
  buf_dis-card.credit-card = parcredit-card
  buf_dis-card.lim-kr = parlim-kr
  buf_dis-card.issue-code = parissue-code
  buf_dis-card.issue-date = parissue-date
  buf_dis-card.valid-from = parvalid-from
  buf_dis-card.valid-date = parvalid-date
  buf_dis-card.debet-card = pardebet-card
  buf_dis-card.staff-card = parstaff-card
  buf_dis-card.cli-message = parcli-message
  buf_dis-card.status_ =  (if buf_dis-card.status_ = {&nonused-status}
                          or buf_dis-card.status_ = {&chown-status}
                          then buf_dis-card.status_
                          else par-status_)
  old-sourced-card = buf_dis-card.sourced-card
  buf_dis-card.cli-type = (if buf_dis-card.mask-card then parcli-type else buf_dis-card.cli-type)
  buf_dis-card.cli-code = (if buf_dis-card.mask-card then parcli-code else buf_dis-card.cli-code)
  buf_Dis-card.trg-param = (if v-rum
                            then ({&trg-param-no-callnews} + {&comma-char} + {&trg-param-no-hist})
                            else '':U)
  .
  if v-rum
  and valid-handle(p-hn-handle) then do:
      run discardh_send-dis-card-rul in p-hn-handle ( buffer buf_dis-card
                                                ,input buf_dis-card.type
                                                ,input buf_dis-card.emitent-host-code
                                                ,input (if par-mode = {&add-def}
                                                        then integer({&hn-create})
                                                        else integer({&hn-update})
                                                       )
                                                ).
  end.
  release buf_dis-card no-error .
  if error-status:error then do:
    assign
    v-err-mess = substitute("Ошибка при сохранении записи ДИСКОНТНАЯ КАРТА&1&2&3&4"
                            ,error-status:get-message(1)
                            , {&new-line}
                            ,return-value
                            , {&new-line}).

    run err-mess in this-procedure ( input-output v-err-mess).
    undo _main, return error v-err-mess.
  end.
end. /*not add-def*/
define variable v-chip-num as integer no-undo .
define variable v-corr-date as date no-undo .
define variable v-corr-time as integer no-undo .
define variable v-updated as logical no-undo .
define variable v-updated-chr as character no-undo .
  IF p-update-prop THEN DO:
    /*обновим dis-card-property */
    FOR EACH tt0-dis-card-property
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
      assign
      v-chip-num = 0
      v-corr-date = ?
      v-corr-time = ?
      .
      v-updated = no.
      v-updated-chr = "".
      find first buf_dis-card-property no-lock where
                buf_dis-card-property.d-card = pard-card
           and  buf_dis-card-property.host-code = tt0-dis-card-property.host-code
           and  buf_dis-card-property.obj-type = tt0-dis-card-property.obj-type
           and  buf_dis-card-property.obj-code = tt0-dis-card-property.obj-code
           and  buf_dis-card-property.dt-code = tt0-dis-card-property.dt-code
           and  buf_dis-card-property.node-code = tt0-dis-card-property.node-code no-error.
      if not available buf_Dis-card-property then do:
        v-updated = yes.
      end.
      else do:
        buffer-compare
        tt0-dis-card-property
        except card-num main-card first-main-card first-card
        to buf_dis-card-property
        save result in v-updated-chr.
        v-updated = (v-updated-chr <> "").
      end.
      if v-updated then do:
        run discprop-write in this-procedure (
                                              input PARd-card
                                            ,input tt0-dis-card-property.host-code
                                            ,input tt0-dis-card-property.obj-type
                                            ,input tt0-dis-card-property.obj-code
                                            ,input tt0-dis-card-property.dtm-code
                                            ,input tt0-dis-card-property.node-code
                                            ,input tt0-dis-card-property.dt-code
                                            ,input tt0-dis-card-property.sum-id
                                            ,input tt0-dis-card-property.property-value-character
                                            ,input tt0-dis-card-property.property-value-date
                                            ,input tt0-dis-card-property.property-value-decimal
                                            ,input tt0-dis-card-property.property-value-integer
                                            ,input tt0-dis-card-property.property-value-logical
                                            ,input '':U /*p-source-type*/
                                            ,input '':U /*p-source-ref*/
                                            ,input-output v-chip-num
                                            ,input-output v-corr-date
                                            ,input-output v-corr-time
                                            )  no-error.
        IF ERROR-STATUS:ERROR THEN DO:
          assign
          v-err-mess = substitute("Ошибка при сохранении свойства дисконтной карты &1 &2 &3 &4:&5:&6&7 &8"
                                  , pard-card
                                  , tt0-dis-card-property.host-code
                                  , (tt0-dis-card-property.obj-type + string(tt0-dis-card-property.obj-code))
                                  , tt0-dis-card-property.dtm-code
                                  , tt0-dis-card-property.node-code
                                  , {&new-line}
                                  ,error-status:get-message(1)
                                  ,return-value).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo _main, return error v-err-mess.
        END.
      end.
    END.
    FOR EACH buf_dis-card-property where buf_dis-card-property.d-card = pard-card
    on error  undo _main, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
    on stop   undo _main, return error substitute( "&1. stop", vss-workfile )
    on endkey undo _main, return error substitute( "&1. endkey", vss-workfile )
    :
      if buf_dis-card-property.dtm-code = 0 then next.
      FIND FIRST tt0-dis-card-property NO-LOCK WHERE
          tt0-dis-card-property.d-card = pard-card
      AND tt0-dis-card-property.host-code = buf_dis-card-property.host-code
      AND tt0-dis-card-property.obj-type = buf_dis-card-property.obj-type
      AND tt0-dis-card-property.obj-code = buf_dis-card-property.obj-code
      AND tt0-dis-card-property.dt-code = buf_dis-card-property.dt-code
      AND tt0-dis-card-property.node-code = buf_dis-card-property.node-code
      NO-ERROR.
      IF NOT AVAILABLE tt0-dis-card-property THEN DO:
          ASSIGN
          v-deleted = NO
          v-chip-num = 0
          v-corr-date = ?
          v-corr-time = ?
          .
          run discprop-delete in this-procedure(
                                                 input PARd-card
                                                ,input buf_dis-card-property.host-code
                                                ,input buf_dis-card-property.OBJ-TYPE
                                                ,input buf_dis-card-property.obj-code
                                                ,input buf_dis-card-property.dtm-code
                                                ,input buf_dis-card-property.node-code
                                                ,input buf_dis-card-property.dt-code
                                                ,input '':U /*p-source-type*/
                                                ,input '':U  /*p-source-ref*/
                                                ,output v-deleted
                                                ,input-output v-chip-num
                                                ,input-output v-corr-date
                                                ,input-output v-corr-time
                                                ) no-error   .

        IF NOT v-deleted
        or error-status:error
        THEN DO:
          assign
          v-err-mess = substitute("Ошибка при удалении свойства дисконтной карты &1 &2 &3 &4:&5:&6&7 &8"
                                  , pard-card
                                  , buf_dis-card-property.host-code
                                  , (buf_dis-card-property.obj-type + string(buf_dis-card-property.obj-code))
                                  , buf_dis-card-property.dt-code
                                  , buf_dis-card-property.node-code
                                  , {&new-line}
                                  ,error-status:get-message(1)
                                  ,return-value
                                  ).
          run err-mess in this-procedure ( input-output v-err-mess).
          undo _main, return error v-err-mess.

        END.
      END.
    END.
END.


if not parmask-card then do:
  if (parsourced-card <> "":U and par-mode = {&add-def})
  or (par-mode = {&update} and parsourced-card <> old-sourced-card)
  then do:
    define variable v-sourced-status_ like ub.dis-card.status_ no-undo .
    assign
    v-sourced-status_ = {&deleted-status}.
    run ref/dcardi02.p (  input parparentproc
                    ,input recid(source_dis-card)
                    ,input p-silent
                    ,input v-has-right-to-restore
                    ,input par-mode2
                    ,input {&hn-source-dis-card}
                    ,input pard-card
                    ,input p-curr-obj-type
                    ,input p-curr-obj-code
                    ,input-output v-sourced-status_) no-error .
    if error-status:error then do:
      assign
      v-err-mess = substitute("Ошибка при сохранении статуса дисконтной карты &1, к которой перевыпускается карта&2&3&4&5"
                              ,source_dis-card.d-card
                              ,error-status:get-message(1)
                              , {&new-line}
                              ,return-value
                              , {&new-line}).

      run err-mess in this-procedure ( input-output v-err-mess).
      undo _main, return error v-err-mess.
    end.
    FIND FIRST dc-list WHERE
                dc-list.d-card = source_dis-card.d-card No-ERROR.
    IF NOT avail dc-list then do:
      create dc-list.
      assign
      dc-list.d-card = source_dis-card.d-card
      .
    end.
    FIND FIRST dc-list WHERE
                dc-list.d-card = pard-card No-ERROR.
    IF NOT avail dc-list then do:
      create dc-list.
      assign
      dc-list.d-card = pard-card
      .
    end.
    else do:
      find first dcp-list where
                dcp-list.d-card = pard-card
            AND dcp-list.host-code = ub.shop.host-code
            AND dcp-list.obj-type  = {&shop}
            AND dcp-list.obj-code  = parissue-code no-error .
      if available dcp-list
      then delete dcp-list.
      /*отошлем только один раз на кассы - така все равно шлем*/

    end.
  end. /*перевыпуск*/
END.
define variable v-send-all as logical no-undo .
if not p-silent then do:
  for each dc-list NO-LOCK:
    if not can-find( first dcp-list where
                dcp-list.d-card = dc-list.d-card)  then do:
      assign
      v-send-all = yes.
      leave.
    end.
  end.
 if v-send-all
 then do:
   if valid-handle(p-log-handle) then do:
     run get-title in p-log-handle (
          output v-old-title
                                  ).
     run set-title in p-log-handle (
          input 'Отправка информации по клиентским карта на кассы'
                                 ).
     run str/sendclia.p (
                  input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input(string(g#db-num) + {&delim-par} +  {&delim-par} + "no":U + {&delim-par} + "O":U)
                  ) no-error .
     run set-title in p-log-handle (
          input v-old-title
                                 ).
   end.
   else do:
     run str/diallog.w (
                    input parparentproc
                  , input this-procedure
                  , input 'str/sendclia.p':U
                  , input(string(g#db-num) + {&delim-par} +  {&delim-par} + "no":U + {&delim-par} + "O":U)
                  , input yes /*p-auto-go*/
                  , input '':U
                  , input 'Отправка информации по клиентским картам на кассу') no-error .
   end.
  end.
end.
RETURN '':u.

end.


procedure create-dis-card :
define input parameter pard-card like ub.dis-card.d-card no-undo .
define input parameter parcard-num like ub.dis-card.card-num.
define input parameter paremitent-host-code like ub.dis-card.emitent-host-code no-undo .
define input parameter parcli-type like ub.dis-card.cli-type no-undo .
define input parameter parcli-code like ub.dis-card.cli-code no-undo .
define input parameter par-status_ like ub.dis-card.status_ no-undo .
define input parameter parsourced-card like ub.dis-card.sourced-card no-undo .
define output parameter par-rid as recid no-undo .
define buffer buf_dis-card for ub.dis-card.

  do
  on error undo, return error
  :
    CREATE buf_dis-card.
    assign
    buf_dis-card.d-card = pard-card
    buf_dis-card.card-num = varcard-num
    buf_dis-card.emitent-host-code = paremitent-host-code
    buf_dis-card.status_ = (if par-status_ = '':U or par-status_ = ?
                            then {&current-status}
                            else par-status_)
    buf_dis-card.cli-type = parcli-type
    buf_dis-card.cli-code = parcli-code
    buf_dis-card.sourced-card = parsourced-card
    buf_dis-card.main-card  = parmain-card
    buf_dis-card.is-subsid  = paris-subsid
    buf_dis-card.first-card = v-first-card
    buf_dis-card.first-main-card = v-first-main-card
    par-rid = recid( buf_dis-card )
    .
  end.

end procedure. /* create-dis-card */

PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Карта №&1: эмитент: &2 тип: &3: &4", pard-card, paremitent-host-code, par-type, p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.