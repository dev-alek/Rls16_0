block-level on error undo, throw.
/*

$Revision: a47b2aad5f12, 1943, rls $
$Author: druban $
$Date: Wed Jul 17 14:42:22 2019 +0300 $
$Workfile: send-cli.p $
$Archive: str/send-cli.p $

Пересылка клиентов на кассу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/28/05
Author: Bakhtadze Natalya
Creation date: 12/28/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
/*
p-parameter включает
define input parameter i-obj-code like ub.clients.obj-code no-undo.
DEFINE INPUT PARAMETER action as character no-undo.
/*action может быть U D и S - специальный режим
для вызова из продажи делает то же что и при вызове из новостей*/
/*количество магазинов по данной фирме в данной БД > 1*/
define input parameter multiple-shops as logical no-undo.
define input parameter p-batch as logical no-undo .
define input parameter p-other as character no-undo .
*/

define variable vss-revision    as character no-undo init "$Revision: a47b2aad5f12, 1943, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Wed Jul 17 14:42:22 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: send-cli.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/send-cli.p $":U .
define variable vss-description as character no-undo init "Пересылка клиентов на кассу".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

define variable i-obj-code like ub.clients.obj-code no-undo.
define variable action as character no-undo.
/*action может быть U D и S - специальный режим
для вызова из продажи делает то же что и при вызове из новостей*/
/*количество магазинов по данной фирме в данной БД > 1*/
define variable multiple-shops as logical no-undo.
define variable p-batch as logical no-undo .
define variable p-other as character no-undo .

{ str/defc-cli.i SHARED }
{ cmp/dc-list.i dc-list def "shared" }
{ ref/dc-prop.i }
{ ref/discprop.i }
{ gbl/dct-algo.i }
{ bge/bgelib.i }
{ str/cd-xml.i }
{ str/cdsnddef.i }
{ gbl/windtfrm.i }
{ gbl/clntattr.i }
{ gbl/cur-time.i }
{ str/cash-c-i.i " " def }
{ gbl/cd-attr.i }
{ str/cd-mrkt.i }
{ str/cd-sumid.i }
{ ref/dc-prop.i }
{ rul/propreft.i }
{ ref/get-dpcn.i }
define buffer buf_dis-thbj-rule for ub.dis-thbj-rule.
{ gbl/disrules.i cash-desk }
&if "{1}" eq "news"
&then
define shared temp-table dc-dis-card-mask no-undo like ub.dis-card-mask.
define shared temp-table dc-dis-card-mask-attr no-undo like ub.dis-card-mask-attr.
&endif
define variable ii as integer no-undo.
/*вспомогат*/
define variable conf-attr as character no-undo.
define variable conf-par as character no-undo.
define variable par-type as character no-undo.
DEFINE VARIABLE ind as integer no-undo .
DEFINE VARIABLE v-type as character no-undo .
/*настройка - на кассу товары всем списком имеющихся в наличии*/
define variable alllstcs as logical no-undo init no.
define variable v-curr-r-b as character no-undo .
define variable v-date-format as character no-undo .
define variable v-del-mrkt-cli as logical        no-undo .
define variable v-record as character no-undo .
/*список соответствий по скидкам для кассы мария */
define variable dr-list as character no-undo .
/*список приоритетов шаблонов правл скидок для скидок по пост клиенту*/
define variable drdcrank as character no-undo .
define variable v-magia-kat-codes-rule as integer no-undo .


define buffer for-shop for ub.shop.
define buffer for-clients for ub.clients.
define buffer lock-batchprocess for ub.batchprocess .
define buffer buf_cash-desk for ub.cash-desk.

/*откуда запустили -из продажи?*/
define variable run-from as char no-undo.
/*выбор кнопки*/
define variable v-num as integer no-undo.
DEFINE VARIABLE var-report-num as integer no-undo .
DEFINE VARIABLE v-date as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .


assign
i-obj-code = integer(entry(1, p-parameter, {&delim-par}))
action = entry(2, p-parameter, {&delim-par})
multiple-shops = (if entry(3, p-parameter, {&delim-par}) = "yes":U
                 then yes
                 else (if entry(3, p-parameter, {&delim-par}) = "no":U
                       then no
                       else ?)
                 )
p-batch = (if entry(4, p-parameter, {&delim-par}) = "yes":U
                 then yes
                 else (if entry(4, p-parameter, {&delim-par}) = "no":U
                       then no
                       else ?)
                 )
p-other = (if num-entries(p-parameter, {&delim-par}) >= 5
          then entry(5, p-parameter, {&delim-par})
          else '':U)
no-error
.

if error-status:error
or multiple-shops = ?
or p-batch = ?
then
return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1)).
assign
v-del-mrkt-cli = lookup("del-mrkt-cli":U, p-other) > 0
.

run fill-temp-cd in this-procedure ( input g#db-num, input {&shop}, input i-obj-code, input yes).
{ str/cdpcknum.i {&shop} i-obj-code }
define variable p-obj-type as character no-undo.
p-obj-type = {&shop}.
run adm/shattri.p (
    input "get":U
    ,input  {&shop}
    ,input  i-obj-code
    ,input  {&attr-cd-sending}
    ,input  {&attr-cd-sending_alllstcs} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
IF not error-status:error
then do:
  delete object v-tth.
  alllstcs = v-value-logical.
end.
else do:
  delete object v-tth.
  return error return-value .
end.
assign
var-report-num = dynamic-next-value( "next-report":U, "ubflt":U)
.

FIND ub.shop WHERE ub.shop.obj-code = i-obj-code NO-LOCK .
FIND ub.sysconf WHERE ub.sysconf.host-code = ub.shop.host-code NO-LOCK .

{ gbl/curr-r-b.i
  v-curr-r-b
}


/*заполним таблицу cash-cli  для КОли*/
if action = "S":U then /*продажа*/
assign
run-from = "S":U
action = "U":U.

if action = "O":U then /**/
assign
run-from = "O":U
action = "U":U.

if action = "E":U then  /*экспорт*/
assign
run-from = "E":U
action = "U":U.


/*блокируем файл*/
if can-find(first cash-desk No-LOCK WHERE
                  cash-desk.db-num = g#db-num and
                  cash-desk.obj-code = i-obj-code AND
                  cash-desk.cash-on = yes AND
                  cash-desk.pos-type = {&cd-type-ipc-servispl}) then do:

  _lock-cli:
  DO while ind < 100 :
  run gbl/lock-prc.p
      (input {&lock-prc-put-dis-card}
      ,input i-obj-code
      ,input 0
      ,input 0
      ,input {&shop}
      ,input ""
      ,input ""
      ,input (
              "Код объекта" + ",,," +
              "Тип объекта" +  ",,,Передача диск. карт"
            )
      ,input no
      ,buffer lock-batchprocess
      ) no-error .
    if not error-status:error then do:
      leave _lock-cli.
    end.
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Объект &1: Файл для выгрузки данных ЗАНЯТ - Ждите", i-obj-code
                        )
                                        ).
    pause 1.
  end.
end.

if can-find(first cash-desk No-LOCK WHERE
                  cash-desk.db-num = g#db-num and
                  cash-desk.obj-code = i-obj-code AND
                  cash-desk.cash-on = yes AND
                  cash-desk.pos-type = {&cd-type-MAGIA-XML}) then do:
  find first buf_dis-thbj-rule no-lock where
            buf_dis-thbj-rule.obj-type = ''
         and buf_dis-thbj-rule.obj-code = 0
         and buf_dis-thbj-rule.pos-type = {&cd-type-MAGIA-XML}
         and buf_dis-thbj-rule.discnt-role = {&dthbjr-kateg-codes} no-error .
  if available buf_dis-thbj-rule then do:
    v-magia-kat-codes-rule = buf_dis-thbj-rule.rule-num.
    run create-dis-rule in this-procedure ( input buf_dis-thbj-rule.rule-num, yes) no-error .
  end.
end.

if v-del-mrkt-cli then do:
  for each cash-cli:
    { str/cash-c-i.i  " " MARIA }
  end.
  find last cash-cli use-index pi no-error .
  if available cash-cli then do:
    cr = cash-cli.crf + 1.
  end.
end.



if g#news
or g#esys
OR run-from = "S":U
or run-from = "O":U
or run-from = "E":U
then do:
  FOR EACH dc-list NO-LOCK,
      FIRST dis-card no-lock where
            dis-card.d-card = dc-list.d-card,
      first clients no-lock where
            clients.obj-type = dis-card.cli-type
        AND  clients.obj-code = dis-card.cli-code,
      FIRST ub.dis-card-type No-LOCK WHERE
            ub.dis-card-type.type = dis-card.type AND
            ub.dis-card-type.emitent-host-code = dis-card.emitent-host-code AND
            ub.dis-card-type.host-code = 0 AND
            ub.dis-card-type.obj-type = "":U AND
            ub.dis-card-type.obj-code = 0 :
    if dis-card.emitent-host-code <> 0 and
      dis-card.emitent-host-code <> ub.shop.host-code then NEXT.
    ii = ii + 1.
    { str/cash-c-i.i mask}
    /*эти записи предназначались одному объекту!!!*/
    if dc-list.flog = yes then delete dc-list.

    if ( ii  > cdpcknum)   and NOT alllstcs  then do:
      /*пошлем те cash-cli, которые успели сделать*/
      if cr > 0 then do:
        if g#news
        or g#esys
        then do:
          FOR EACH for-shop NO-LOCK where
                  for-shop.host-code = ub.shop.host-code,
              FIRST for-clients No-LOCK WHERE
                    for-clients.obj-type = {&shop}
                AND for-clients.obj-code = for-shop.obj-code
                AND for-clients.db-num = g#db-num:
            FIND ub.sysconf WHERE
                ub.sysconf.host-code = ub.shop.host-code NO-LOCK.
            assign
            i-obj-code = for-shop.obj-code
            .
            RUN SENDING in this-procedure no-error.
            {&sending-error}.
          END.
        end.
        else
        RUN SENDING in this-procedure no-error.
        {&sending-error}.
      end.
      /*вернемся к первому и начнем писать в таблицу с головы*/
      assign
      start-paket = yes
      cr = 0
      ii = 0
      .
    end. /* ii  > cdpcknum)   */
  END.
end. /*if g#news*/
/*очень долго разбираются новостные пакеты если приехало много клиентов*/
/*попробуем формировать временную таблицу один раз для всех магазинов данной фирмы
в данной базе данных*/

if (cr > 0 AND (g#news
                or g#esys
                or run-from = "S":U
                or run-from = "O":U
                or run-from = "E":U
                )
   )
or
   (NOT (g#news
         or g#esys
         OR run-from = "S"
         or run-from = "O":U
         or run-from = "E":U)
         AND can-find(first cash-cli)
    ) then do:
  if (g#news or g#esys OR multiple-shops) then do:
    FOR EACH for-shop NO-LOCK where for-shop.host-code = ub.shop.host-code,
            FIRST for-clients No-LOCK WHERE
                  for-clients.obj-type = {&shop} AND
                  for-clients.obj-code = for-shop.obj-code AND
                  for-clients.db-num = g#db-num,
      first buf_cash-desk no-lock where
           buf_cash-desk.db-num = g#db-num
       AND buf_cash-desk.obj-code = for-clients.obj-code
       AND buf_cash-desk.cash-on = yes   :
      FIND ub.sysconf WHERE
          ub.sysconf.host-code = ub.shop.host-code NO-LOCK.
      assign
      i-obj-code = for-shop.obj-code
      .
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Пересылка на кассы &1&2 информации о дисконтных картах", {&shop}, i-obj-code)
                                                ).
      RUN SENDING in this-procedure no-error.
      {&sending-error}.
    END.
  end.
  else do:
    run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Пересылка на кассы &1&2 информации о дисконтных картах", {&shop}, i-obj-code)
                                                  ).
    RUN SENDING in this-procedure no-error.
    {&sending-error}.
  end.
end.
for each cash-cli:
    delete cash-cli.
end.

if p-batch then do:
  if v-view-log then
  run set-view-log in p-log-handle(yes).
end.
else do:
  { str/cdviewlg.i
  "'!!!При отсылке информации на кассы произошли ошибки!!!'"
  log-file-name }
end.


/*PROCEDURE putc-cli.*/
/*разнящийся вывод для разных типов касс*/
{ str/putc-2.i }


/*PROCEDURE putc-dis-card-mask.*/
/*разнящийся вывод для разных типов касс*/
&if "{1}" eq "news"
&then
{ str/putc-20.i dc-dis-card}
&else
PROCEDURE putc-dis-card-mask.
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-pos-type as character no-undo.
define input parameter p-version as character no-undo .
end.
&endif


/*PROCEDURE for-cash-cycle*/
/*пройдем цикл по всем кассам одного типа*/
{ str/cd-cycl2.i }

/*PROCEDURE SENDING.*/
{ str/cd-send2.i }