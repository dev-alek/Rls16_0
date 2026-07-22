/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Передача клиентов на кассу-запуск

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/12/05
Author: Bakhtadze Natalya
Creation date: 12/12/05

*/
block-level on error undo, throw.

define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-parameter      as character no-undo .

/*
p-parameter включает

define input parameter p-db-num   like ub.db.db-num no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter mode       as character no-undo .
*/
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Передача клиентов на кассу-запуск".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

define variable p-db-num   like ub.db.db-num no-undo .
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .
define variable mode       as character no-undo .




{ str/defc-cli.i "NEW SHARED" }
{ cmp/dc-list.i dc-list def "new shared" }
{ cmp/dcp-list.i dcp-list def "new shared" }
{ gbl/dct-algo.i }
{ gbl/clntattr.i }
{ gbl/cur-time.i }
{ str/cdsnddef.i }
{ str/cd-xml.i function }
{ rul/propreft.i }
{ str/cash-c-i.i " " def }
{ gbl/cd-attr.i }
{ gbl/getcntxt.i def }
{ str/cd-sumid.i }
{ ref/dc-prop.i }
{ ref/discprop.i }

define variable     cli-list            as char no-undo.
define variable     kk                  as integer no-undo.

/*настройка - на кассу товары всем списком имеющихся в наличии*/
define variable alllstcs as logical no-undo init no.
/*количество магазинов по данной фирме в данной БД > 1*/
define variable multiple-shops as logical no-undo.

DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE v-num as integer no-undo .
DEFINE VARIABLE v-type as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable choice as integer no-undo.
define variable conf-attr as character no-undo .
define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable v-curr-r-b as character no-undo .
DEFINE VARIABLE v-date as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-disp-msg as character no-undo .


define buffer for-cash-desk for cash-desk.
define buffer for-shop for shop.
define buffer for-clients for clients.

assign
p-db-num = integer(entry(1, p-parameter, {&delim-par}))
p-obj-type = entry(2, p-parameter, {&delim-par})
p-obj-code = integer(entry(3, p-parameter, {&delim-par}))
mode       = entry(4, p-parameter, {&delim-par})
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


for each cash-cli:
    delete cash-cli.
end.

{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }
{ str/cdpcknum.i p-obj-type p-obj-code }



run adm/shattri.p (
  input "get":U
  ,input p-obj-type
  ,input p-obj-code
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
IF error-status:error then do:
  delete object v-tth.
  v-disp-msg = substitute("Ошибка при получении настроек передачи данных на кассы НА ОБЪЕКТЕ &1&2:&3&4 &5"
            , p-obj-type
            , p-obj-code
            , {&new-line}
            , error-status:get-message(1)
            , return-value ) .
  message v-disp-msg view-as alert-box error .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input v-disp-msg).
  v-view-log = yes.
  undo, return error .
end.
delete object v-tth.
assign
alllstcs = v-value-logical.

define variable v-chk-act-host-code as integer   no-undo .
{ gbl/hostcode.i
  p-obj-type
  p-obj-code
  v-chk-act-host-code
}

if mode = "U"
then do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-clients_add-def':U
    {&cntxt-object}
    v-chk-act-host-code
    p-obj-type
    p-obj-code
    0
    0
    0
    true
    glog
  }
end.
else do:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_cashdesk-clients_deletion':U
    {&cntxt-object}
    v-chk-act-host-code
    p-obj-type
    p-obj-code
    0
    0
    0
    true
    glog
  }
end.


if NOT glog then  return .
glog = yes.
run gbl/d-askw.w (input "Выбор клиентов для пересылки",
                      input ( (if mode = "U" then "Переслать на кассу"
                                else "Удалить из кассы" ) + {&new-line} +
                                "информацию о клиентах с непустым номером дисконтной карты"
                                ),
                      input "|",
                      input "Все глобальные|Все по фирме|Выборочно|Отказ от пересылки",
                      input "|||",
                      input 1,
                      input 4,
                      output choice).

if choice = 4 then return.


{ gbl/curr-r-b.i
  v-curr-r-b
}



/*ищем есть ли еще магазины по данной фирме в данной БД*/
FOR EACH for-shop NO-LOCK where for-shop.host-code = v-host-code,
    FIRST for-clients No-LOCK WHERE
          for-clients.obj-type = p-obj-type AND
          for-clients.obj-code = p-obj-code AND
          for-clients.db-num = p-db-num:
    ii = ii + 1.
    if ii = 2 then do:
      multiple-shops = yes.
      leave.
    end.
end. /*for each for-shop*/
if multiple-shops then do:
/*проверим права - моэет ли пользователь отсылать на все кассы фирмы сразу*/
/*если может то сделаем вопросец - хочет ли отсылать на все магазины сразу*/
run gbl/d-askw.w (input string(if mode = "U":U
                            then "Передача клиентов на кассу"
                            else "Удаление клиентов с кассы"),
              input "Отослать на кассы",
              input "|",
              input ("Все магазины данной БД|Текущий магазин " + string(p-obj-code)),
              input "|",
              input 1,
              input 2,
              output v-num).
    if v-num eq 5 or v-num eq 6 or v-num eq 7
    then
        v-num = 1. 
    IF v-num = 2 then multiple-shops = no.
    if multiple-shops then do:
      FOR EACH for-shop NO-LOCK where for-shop.host-code = v-host-code,
          FIRST for-clients No-LOCK WHERE
                for-clients.obj-type = p-obj-type AND
                for-clients.obj-code = p-obj-code AND
                for-clients.db-num = p-db-num:
        run fill-temp-cd in this-procedure ( input g#db-num, input {&shop}, input for-shop.obj-code, input no).
      end. /*for each for-shop*/
    end.

  end.
  if choice eq 5 or choice eq 6
  then
      choice = choice - 4. 
CASE choice :
  when 4 then
      return .
  when 3 then do:
    run str/dc-list.w (
                 input parparentproc
                 ,input v-host-code
                 ,input p-obj-type
                 ,input p-obj-code
                 ).
    if can-find(first dc-list) then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Подготовка данных")
                                                ).
      kk = 0.
      _kk:
        for each dc-list no-lock,
            first dis-card no-lock where
                  dis-card.d-card = dc-list.d-card,
             FIRST ub.dis-card-type No-LOCK WHERE
                      ub.dis-card-type.type = ub.dis-card.type and
                      ub.dis-card-type.emitent-host-code = ub.dis-card.emitent-host-code AND
                      ub.dis-card-type.host-code = 0 AND
                      ub.dis-card-type.obj-type = "":U AND
                      ub.dis-card-type.obj-code = 0:
          if ( lookup(ub.dis-card.type, ub.dis-card-type.DCBYSHOP) > 0  and
              ub.dis-card.issue-code <> p-obj-code) then NEXT _kk.
            FIND clients WHERE
                dis-card.cli-type = clients.obj-type AND
                dis-card.cli-code = clients.obj-code
          NO-LOCK NO-ERROR.
          kk = kk + 1.
          { str/cash-c-i.i mask}

          /*нарежем на куски по cdpcknum штук*/
          if ( kk  modulo cdpcknum)  = 0  and not alllstcs then do:
            run get-stop-state in p-log-handle (output v-stop).
            if v-stop then do:
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute("!!!Процедура пересылки остановлена пользователем"
                                      )
                                        ).
              leave _kk.
            end.
            else do:
              /*пошлем те cash-cli, которые успели сделать*/
              if cr > 0 then
              run str/send-cli.p (
                            input parparentproc
                            ,input p-parent-handle
                            ,input p-log-handle
                            ,input (string(p-obj-code) + {&delim-par} + mode + {&delim-par} +
                                     string(multiple-shops, "yes/no":U) + {&delim-par} + "no":U)
                              ) no-error .
              /*вернемся к первому и начнем писать в таблицу с головы*/
              assign
              start-paket = yes
              cr = 0
              .
            end.
        end. /* (kk modulo cdpcknum)  = 0 */
      END . /*for eac dc-list*/
    end. /*if can-find first dc-list*/
    else /*cli-list = ""*/ do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Не определен список постоянных клиентов для пересылки")
                                          ).
      return .
    end.
  end. /*when 2*/
  when 1 then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Подготовка данных")
                                              ).
    _each:
    FOR EACH ub.dis-card NO-LOCK WHERE
              (NOT can-do(dis-card.status_ , {&deleted-status}) OR
                mode = "D") AND
              ub.dis-card.emitent-host-code = 0,
        EACH ub.clients WHERE
              ub.clients.obj-type = ub.dis-card.cli-type AND
              ub.clients.obj-code = ub.dis-card.cli-code NO-LOCK :
      FIND FIRST ub.dis-card-type No-LOCK WHERE
                  ub.dis-card-type.type = ub.dis-card.type and
                  ub.dis-card-type.emitent-host-code = ub.dis-card.emitent-host-code AND
                  ub.dis-card-type.host-code = 0 AND
                  ub.dis-card-type.obj-type = "":U AND
                  ub.dis-card-type.obj-code = 0 NO-ERROR.
      if not avail(ub.dis-card-type) then NEXT _each.
      if ( lookup(ub.dis-card.type, ub.dis-card-type.DCBYSHOP) > 0  and
          ub.dis-card.issue-code <> p-obj-code) then NEXT _each.
      { str/cash-c-i.i mask}
      /*нарежем на куски по cdpcknum штук*/
      ACCUMULATE dis-card.d-card (COUNT).
      if ( ( ACCUM COUNT dis-card.d-card)  modulo cdpcknum)  = 0  and not alllstcs then do:
          /*пошлем те cash-cli, которые успели сделать*/
        run get-stop-state in p-log-handle (output v-stop).
        if v-stop then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Процедура пересылки остановлена пользователем"
                                  )
                                    ).
          leave _each.
        end.
        else do:
          if cr > 0 then
          run str/send-cli.p (
                        input parparentproc
                        ,input p-parent-handle
                        ,input p-log-handle
                        ,input (string(p-obj-code) + {&delim-par} + mode + {&delim-par} +
                                string(multiple-shops, "yes/no":U) + {&delim-par} + "no":U )
                          ) no-error .
          /*вернемся к первому и начнем писать в таблицу с головы*/
          assign
          start-paket = yes
          cr = 0
          .
        end.
      end. /* (ACCUM COUNT dis-card.d-card)  = 0 */
    END .
  end. /*when 1*/
  when 2 then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("Подготовка данных")
                                                ).
      _each1:
      FOR EACH ub.dis-card NO-LOCK WHERE
                (NOT can-do(dis-card.status_ , {&deleted-status}) OR
                mode = "D") AND
                ub.dis-card.emitent-host-code = v-host-code,
          EACH ub.clients WHERE
                ub.clients.obj-type = ub.dis-card.cli-type AND
                ub.clients.obj-code = ub.dis-card.cli-code NO-LOCK :
        FIND FIRST ub.dis-card-type No-LOCK WHERE
                    ub.dis-card-type.type = ub.dis-card.type and
                    ub.dis-card-type.emitent-host-code = ub.dis-card.emitent-host-code  AND
                    ub.dis-card-type.host-code = 0 AND
                    ub.dis-card-type.obj-type = "":U AND
                    ub.dis-card-type.obj-code = 0 NO-ERROR.
        if not avail(ub.dis-card-type) then NEXT _each1.
        if ( lookup(ub.dis-card.type, ub.dis-card-type.DCBYSHOP) > 0  and
        ub.dis-card.issue-code <> p-obj-code) then NEXT _each1.
      { str/cash-c-i.i mask}
      /*нарежем на куски по cdpcknum штук*/
      ACCUMULATE dis-card.d-card (COUNT).
      if ( ( ACCUM COUNT dis-card.d-card)  modulo cdpcknum)  = 0  and not alllstcs then do:
          /*пошлем те cash-cli, которые успели сделать*/
        if v-stop then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Процедура пересылки остановлена пользователем"
                                  )
                                    ).
          leave _each1.
        end.
        else do:
          if cr > 0 then
          run str/send-cli.p (
                        input parparentproc
                        ,input p-parent-handle
                        ,input p-log-handle
                        ,input (string(p-obj-code) + {&delim-par} + mode + {&delim-par} +
                                string(multiple-shops, "yes/no":U) + {&delim-par} + "no":U)
                          ) no-error .
          /*вернемся к первому и начнем писать в таблицу с головы*/
          assign
          start-paket = yes
          cr = 0
          .
        end.
      end. /* (ACCUM COUNT dis-card.d-card)  = 0 */
    END .
  end. /*when 1*/
    when 7 then 
    do:
            //create di.
            create cash-cli.
            assign
               cash-cli.cli-code        = ?
               cash-cli.d-card          = ? 
               cash-cli.crf             = 1
               cr                       = 1
             .
        if cr > 0 then
            run str/send-cli.p (
                input parparentproc
                ,input p-parent-handle
                ,input p-log-handle
                ,input (string(p-obj-code) + {&delim-par} + mode + {&delim-par} +
                string(multiple-shops, "yes/no":U) + {&delim-par} + "no":U)
                ) no-error .
        
    end.
END CASE .
/*пошлем непосланное*/
if cr > 0 and not v-stop then
run str/send-cli.p (
              input parparentproc
              ,input p-parent-handle
              ,input p-log-handle
              ,input (string(p-obj-code) + {&delim-par} + mode + {&delim-par} +
                      string(multiple-shops, "yes/no":U) + {&delim-par} + "no":U )
                ) no-error .
if not error-status:error then
run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute("Отправлены данные по клиентским картам на кассы &1&2", {&shop}, p-obj-code)
                                          ).
                                          
  finally :
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
