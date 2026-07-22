/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

пересылка объектов на КМ - пускальник

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/09/05
Author: Bakhtadze Natalya
Creation date: 09/09/05

*/
block-level on error undo, throw.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter p-db-num like ub.db.db-num no-undo .
/*эти параметры не имеют смысла тут
МАГИЯ работает как кассовый сервер на БД
а подразеделния одинаковы для всей БД
но ПУСТЬ БУДУТ!!*/
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
DEFINE INPUT PARAMETER action as char no-undo.
*/

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Пересылка объектов системы КМ-ру IBM-пускальник".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ str/defc-obj.i "NEW SHARED" }
{ rep/fmtcli.i }
{ gbl/getcntxt.i def }

define variable  p-db-num like ub.db.db-num no-undo .
/*эти параметры не имеют смысла тут
МАГИЯ работает как кассовый сервер на БД
а подразеделния одинаковы для всей БД
но ПУСТЬ БУДУТ!!*/
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .
define variable action     as character no-undo .
define variable log-file-name as character no-undo init "send-cd.txt".
define variable v-view-log as logical no-undo .
define variable callpoint as character no-undo.
define variable glog as logical no-undo .

define buffer buf_shop for ub.shop.
define buffer buf_clients for ub.clients.
define buffer buf_cash-desk for ub.cash-desk.
define buffer bfcdm_cash-desk for ub.cash-desk.

assign
p-db-num = integer(entry(1, p-parameter, {&delim-par}))
p-obj-code = integer(entry(2, p-parameter, {&delim-par}))
action     = entry(3, p-parameter, {&delim-par})
no-error
.
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         )).
  v-view-log = yes.
  undo, return error .
end .

{ gbl/getcntxt.i get }


assign
callpoint = action.
action = if action = "R" then "U" else action.
for each cash-obj:
    delete cash-obj.
end.

FIND FIRST ub.cash-desk NO-LOCK WHERE
           ub.cash-desk.db-num = g#db-num
       AND ub.cash-desk.pos-type = {&cd-type-IBM-XML}
       AND ub.cash-desk.autonomy = integer({&cd-manager})  No-error.
IF not avail(ub.cash-desk) then do:
  if callpoint <> "R" then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!&1 объектов БД реализуется только для кассового менеджера IBM"
                              , (if action = "U" then "Передача" else "Удаление")
                            )
                                            ).
     return.
  end.
end.
if callpoint = "R"
then do:
  glog = yes.
end.
else do:
  define variable v-host-code as integer   no-undo .
  { gbl/hostcode.i
    p-obj-type
    p-obj-code
    v-host-code
  }
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-reference_update':U
    {&cntxt-object}
    v-host-code
    p-obj-type
    p-obj-code
    0
    0
    0
    true
    glog
  }
end.
if NOT glog then return .
glog = yes.
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("&1 магазина &2: пересылка всех имеющихся в БД объектов"
                      , (if action = "U" then "Пересылка на кассы" else "Удаление с касс" )
                      , p-obj-code)
    ).
run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Подготовка данных")
                                      ).

  find first cash-obj where
           cash-obj.km-objtype = 0
       AND  cash-obj.km-objcode = g#db-num
       AND cash-obj.km-objname = "БД" + string(g#db-num)
         no-error .
  if not available cash-obj then do:
    create cash-obj.
    assign
    cash-obj.km-objcode = g#db-num
    cash-obj.km-objtype = 0
    cash-obj.km-objname = "БД" + string(g#db-num)
    cash-obj.on-addr    = "":U
    cash-obj.off-addr   = "":U
    cash-obj.shop-nums  = "":U
    cash-obj.obj-lock   = 0
    .
    /*согласно соглашению с БАРАНОВым для БД посылаем 0 */
    for each bfcdm_cash-desk no-lock where
            bfcdm_cash-desk.db-num = g#db-num
      AND  bfcdm_cash-desk.pos-type = {&cd-type-ibm-xml}
      AND  bfcdm_cash-desk.autonomy = integer({&cd-manager})
      /*AND  bfcdm_cash-desk.cash-on = yes*/
      :
        assign
        cash-obj.shop-nums = cash-obj.shop-nums
                            + (if cash-obj.shop-nums = "":u then "":U else {&comma-char})
                            + string(bfcdm_cash-desk.obj-code)
        .
    end.
  end.
  find first cash-obj where
           cash-obj.km-objtype = 2
       AND  cash-obj.km-objcode = 0
       AND cash-obj.km-objname = "КМ"
         no-error .
  if not available cash-obj then do:
    create cash-obj.
    assign
    cash-obj.km-objcode = 0
    cash-obj.km-objtype = 2
    cash-obj.km-objname = "КМ"
    cash-obj.on-addr    = "":U
    cash-obj.off-addr   = "":U
    cash-obj.shop-nums  = "":U
    cash-obj.obj-lock   = 0
    .
    /*согласно соглашению с БАРАНОВым для БД посылаем 0 */
   for each bfcdm_cash-desk no-lock where
            bfcdm_cash-desk.db-num = g#db-num
      AND  bfcdm_cash-desk.pos-type = {&cd-type-ibm-xml}
      AND  bfcdm_cash-desk.autonomy = integer({&cd-manager})
      /*AND  bfcdm_cash-desk.cash-on = yes*/
      :
        assign
        cash-obj.shop-nums = cash-obj.shop-nums
                            + (if cash-obj.shop-nums = "":u then "":U else {&comma-char})
                            + string(bfcdm_cash-desk.obj-code)
        .
   end.
 end.


_for:
for each buf_clients no-lock where
          buf_clients.db-num = g#db-num
      AND buf_clients.obj-type = {&shop}:
  find first buf_shop no-lock where
              buf_shop.obj-code = buf_clients.obj-code no-error .
  if not available buf_shop then next _for.
  FIND FIRST cash-desk NO-LOCK WHERE
           cash-desk.db-num = g#db-num
       AND cash-desk.pos-type = {&cd-type-IBM-XML}
       AND cash-desk.autonomy = integer({&cd-slave})
       AND cash-desk.is-del   = no
       AND cash-desk.obj-code  = buf_clients.obj-code
       No-error.
  if not available cash-desk then next _for.
  find first cash-obj where
           cash-obj.km-objtype = 1
       AND  cash-obj.km-objcode = buf_clients.obj-code no-error .
  if not available cash-obj then do:
    /*получим параметры для счета фактуры*/
    run fmtcli-get-client in this-procedure
                                  (
                                   input {&cmp}
                                  ,input buf_clients.host-code
                                  ).
    create cash-obj.
    assign
    cash-obj.km-objcode = buf_clients.obj-code
    cash-obj.km-objtype = 1
    cash-obj.km-objname = buf_clients.obj-type + string(buf_clients.obj-code)
    cash-obj.on-addr    = "":U
    cash-obj.off-addr   = "":U
    cash-obj.shop-nums  = string(buf_clients.obj-code)
    cash-obj.obj-lock   = buf_clients.stts
    cash-obj.firm-name  = v-fmtcli-name
    cash-obj.jur-address = v-fmtcli-addres
    cash-obj.post-address = v-fmtcli-post-addres
    cash-obj.INN         = v-fmtcli-INN
    cash-obj.KPP         = v-fmtcli-KPP
    .
  end.
  for each buf_cash-desk no-lock where
              buf_cash-desk.db-num = g#db-num
          AND buf_cash-desk.obj-code = buf_shop.obj-code
          AND buf_cash-desk.pos-type = {&cd-type-ibm-xml}:
    if buf_cash-desk.autonomy = integer({&cd-self}) then next.
    /*баранов просит не посылать*/
    if buf_cash-desk.autonomy = integer({&cd-manager}) then next.

    find first cash-obj where
            cash-obj.km-objtype = (if buf_cash-desk.autonomy = integer({&cd-manager}) then 2 else 3)
        AND  cash-obj.km-objcode = buf_cash-desk.cash-num no-error .
    if not available cash-obj then do:
      create cash-obj.
      assign
      cash-obj.km-objcode = buf_cash-desk.cash-num
      cash-obj.km-objtype = (if buf_cash-desk.autonomy = integer({&cd-manager}) then 2 else 3)
      cash-obj.km-objname = (if buf_cash-desk.autonomy = integer({&cd-manager})
                             then "КМ"
                             else ("маг" + string(buf_cash-desk.obj-code) + "_касса" + string(buf_cash-desk.cash-num))
                             )
      cash-obj.on-addr    = (if buf_cash-desk.autonomy = integer({&cd-manager})
                            then buf_cash-desk.addr-path
                            else (entry(1, buf_cash-desk.addr-path, {&delim-par})
                                  + "://":U
                                  + entry(2, buf_cash-desk.addr-path, {&delim-par})
                                 )
                            )
      cash-obj.off-addr   = (if buf_cash-desk.autonomy = integer({&cd-manager})
                            then buf_cash-desk.addr-path
                            else (entry(1, buf_cash-desk.addr-path, {&delim-par})
                                  + "://":U
                                  + entry(2, buf_cash-desk.addr-path, {&delim-par})
                                 )
                            )
      cash-obj.shop-nums  = if buf_cash-desk.autonomy = integer({&cd-slave})
                            then  string(buf_cash-desk.obj-code)
                            else "":U
      cash-obj.obj-lock   = if ((action = "U":U or callpoint = "R":U) and buf_cash-desk.cash-on )
                            then 0
                            else 1
      .
      if buf_cash-desk.autonomy = integer({&cd-manager}) then do:
        for each bfcdm_cash-desk no-lock where
                bfcdm_cash-desk.db-num = g#db-num
          AND  bfcdm_cash-desk.pos-type = {&cd-type-ibm-xml}
          AND  bfcdm_cash-desk.autonomy = integer({&cd-manager})
          AND  bfcdm_cash-desk.cash-on = yes
          :
           assign
           cash-obj.shop-nums = cash-obj.shop-nums
                                + (if cash-obj.shop-nums = "":u then "":U else {&comma-char})
                                + string(bfcdm_cash-desk.obj-code)
           .
        end.
      end.
    end.
  end.
end. /*for each buf_clients no-lock where*/

if can-find(first cash-obj ) then do:
  run str/send-obj.p (
                    input parparentproc
                  ,input this-procedure
                  ,input p-log-handle
                  ,input (string(g#db-num) + {&delim-par} +
                          string(p-obj-code) + {&delim-par} +
                          action)) no-error.
  if not error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("&1 маг&2 &3"
                            , (if action = "U"
                              then "Передача объектов БД на кассы"
                              else "Удаление объектов БД с касс")
                            , p-obj-code
                            , (if action = "U"
                              then "проведена"
                              else "проведено")
                            )
                                        ).
  end.
  else do:
    assign
    v-view-log = yes
    .
  end.
end.
else do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Не найдено информации по объектам БД для передачи на кассы маг&1")
                            , p-obj-code
                                        ).
end.

  finally :
{ str/cdviewlg.i
"'!!!При отсылке информации на кассы произошли ошибки!!!'"
log-file-name not-delete }

    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1", {&new-line})
    ).
    define variable v-save-file-name as character no-undo .
    v-save-file-name = substitute("&1send-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
    OS-APPEND value(log-file-name) value(v-save-file-name).
    OS-DELETE value(log-file-name).
  end finally .
