/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Процедуры для кассы MARIA

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/14/05
Author: Bakhtadze Natalya
Creation date: 02/14/05

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

/*добавление нового кода товара на кассу маркетер*/
PROCEDURE cd-mrkt_plu-marketer :
define input parameter p-silence as logical no-undo .
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-id as character no-undo .
define input parameter p-b-code like ub.bar-code.b-code no-undo .
define input parameter p-b-str like ub.prod-bc.b-str no-undo .
define input parameter p-loc-ean as logical no-undo .
define input parameter p-is-petrolium as logical no-undo .
define input parameter p-extra as character no-undo .
/*для petrol-МАРИИ - это бар-код резервуара*/


define variable v-tot-gds as integer no-undo .
define variable v-max-gds as integer no-undo .
define variable v-petrol-start as integer no-undo .
define variable v-petrol-range as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-plu-type as character no-undo .
define variable v-int as integer no-undo .

define buffer  buf_cd-plu for ub.cd-plu.
define buffer  loc_cd-plu for ub.cd-plu.

define variable  ii as integer no-undo.
define variable v-mes as character no-undo .
_main:
DO ON ERROR undo, leave on stop undo, leave:
  if buf_cash-desk.pos-type <> {&cd-type-maria}
  or buf_cash-desk.cash-num <> 0 then do:

    assign
    v-mes =
    substitute("Товары на кассах можно определять только для кассовых менеджеров (номер кассы = 0) для типов касс &1"
              , buf_cash-desk.pos-type).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    return error v-mes.
  end.
  v-tot-gds = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input {&cda-maria_operative}
                                  ,input (if buf_cash-desk.pos-type = {&cd-type-maria}
                                        and p-is-petrolium
                                        then {&cda-maria_operative_tot-petrol}
                                        else {&cda-maria_operative_tot-gds})
                                  , output v-mes).
  if v-tot-gds = ? then undo _main, return error v-mes.
  v-max-gds = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input {&cda-maria_general}
                                  ,input {&cda-maria_general_max-gds}
                                  ,output v-mes).
  if v-max-gds = ? then undo _main, return error v-mes.
  v-petrol-range = cd-attr_get-attr-int(buffer buf_cash-desk
                                       ,input {&cda-maria_general_petrolium-range}
                                       ,input {&cda-maria_general_petrolium-range}
                                       ,output v-mes).
  if v-petrol-range = ? then undo _main, return error v-mes.

  if buf_cash-desk.pos-type = {&cd-type-maria} then do:
    assign
    v-petrol-start = 1
    v-max-gds = (if p-is-petrolium
                 then v-petrol-range
                 else v-max-gds)
    v-plu-type = (if p-is-petrolium
               then {&petrolium}
               else '':U)
    .
    if p-is-petrolium then do:
      /*проверим есть ли привязка к place*/
      if p-id = '':U then do:
        v-mes = substitute( "Топливо с кодом &1 не привязано к складскому месту&2" +
                            "Невозможно привязать к кассе типа &3"
                            , p-b-str
                            , {&new-line}
                            , {&cd-type-maria}).
        if not p-silence then
        message
        v-mes
        view-as alert-box error .
        return error v-mes.
      end.
      assign
      v-int = integer(p-id)
      no-error
      .
      if error-status:error
      or v-int > v-petrol-range then do:
        v-mes = substitute( "№ резервуара &1 для топлива с кодом &1 не укладывается&3" +
                            "в диапазоны номеров резервуаров для кассы типа &4"
                            , p-id
                            , p-b-str
                            , {&new-line}
                            , {&cd-type-maria}).
        if not p-silence then
        message
        v-mes
        view-as alert-box error .
        return error v-mes.
      end.
    end. /*if p-is-petrolium then do:*/
  end. /*if buf_cash-desk.pos-type = {&cd-type-maria} then do:*/
  if buf_cash-desk.pos-type = {&cd-type-maria}
  and p-is-petrolium then do:
    find first loc_cd-plu where
             loc_cd-plu.obj-type = {&shop}
         and loc_cd-plu.obj-code = buf_cash-desk.obj-code
         and loc_cd-plu.pos-type = buf_cash-desk.pos-type
         and loc_cd-plu.plu-type = {&petrolium}
   no-error .
   if available loc_cd-plu then do:
     if loc_cd-plu.b-code = p-b-code
     and loc_cd-plu.b-str = p-b-str then do:
        v-mes = substitute( "№ резервуара &1 на кассе УЖЕ привязан к топливу с кодом &1,&3"
                            , p-id
                            , p-b-str
                            , {&new-line}
                            ).
        if not p-silence then
        message
        v-mes
        view-as alert-box WARNING .
        return v-mes.
     end.
     else do:
        v-mes = substitute( "№ резервуара &1 на кассе привязан к топливу с кодом &1,&3" +
                            "нельзя его привязать к топливу &2&3"
                            , p-id
                            , loc_cd-plu.b-str
                            , {&new-line}
                            , p-b-str).
        if not p-silence then
        message
        v-mes
        view-as alert-box error .
        return error v-mes.
     end.
   end.
   ii = v-int.
  end.
  else do:
    DO ii = (if p-is-petrolium
            then v-petrol-start
            else (if buf_cash-desk.pos-type = {&cd-type-maria}
                 then 1
                 else (if v-petrol-start = 1
                        then (v-petrol-range + 1)
                        else 1)
                )
            )
      to v-max-gds :
      if not can-find (loc_cd-plu where
                      loc_cd-plu.obj-type = {&shop}
                   and loc_cd-plu.obj-code =  buf_Cash-desk.obj-code
                   and loc_cd-plu.pos-type = buf_Cash-desk.pos-type
                   and loc_cd-plu.plu-type = v-plu-type
                   and loc_cd-plu.plu-code = ii
                    )
      then LEAVE .
    END .
  end.
  if ii > v-max-gds then do:
      if not p-silence then
      message
      substitute("Превышено максимально допустимое количество &5 &1" +
                "для касс &2 &3&4"
                , {&new-line}
                , v-max-gds
                , {&shop}
                , buf_cash-desk.obj-code
                , (if p-is-petrolium then "топлив" else "товаров")
                )
      view-as alert-box ERROR .
      undo, return error "max-gds":U.
  end. /* if ii > v-max-gds then do:*/

  DO ii = (if p-is-petrolium
           then v-petrol-start
           else (if v-petrol-start = 1
                 then (v-petrol-range + 1)
                 else 1)
           )
     to v-max-gds :
    if not can-find (loc_cd-plu where
                      loc_cd-plu.obj-type = {&shop}
                   and loc_cd-plu.obj-code =  buf_Cash-desk.obj-code
                   and loc_cd-plu.pos-type = buf_Cash-desk.pos-type
                   and loc_cd-plu.plu-type = v-plu-type
                   and loc_cd-plu.plu-code = ii
                   )
    then LEAVE .
  END . /*DO ii = (if p-is-petrolium*/
  if ii > v-max-gds then do:
      if not p-silence then
      message
      substitute("Превышено максимально допустимое количество &5 &1" +
                "для касс &2 &3&4"
                , {&new-line}
                , v-max-gds
                , {&shop}
                , buf_cash-desk.obj-code
                , (if p-is-petrolium then "топлив" else "товаров")
                )
      view-as alert-box ERROR .
      undo, return error "max-gds":U.
  end. /*if ii > v-max-gds then do:*/
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_cd-plu.
  assign
  buf_cd-plu.b-code = p-b-code
  buf_cd-plu.b-str = p-b-str
  buf_cd-plu.charkey_two = (if buf_cash-desk.pos-type = {&cd-type-maria}
                                      then buf_cash-desk.addr-path
                                      else "U":U)
  buf_cd-plu.to-send = yes
  buf_cd-plu.charkey_one = "":U    /* отметка, что запись нужна */
  buf_cd-plu.to-del = no
  buf_cd-plu.plu-code = ii
  buf_cd-plu.obj-type = {&shop}
  buf_cd-plu.obj-code = buf_cash-desk.obj-code
  buf_cd-plu.pos-type = buf_cash-desk.pos-type
  buf_cd-plu.plu-type = v-plu-type
  buf_cd-plu.logkey_one = p-loc-ean
  buf_cd-plu.key#_one = integer(p-extra)
  .
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  substitute("&1_operative", buf_cash-desk.pos-type)
                                        ,input (if buf_cash-desk.pos-type = {&cd-type-maria}
                                              and p-is-petrolium
                                              then {&cda-maria_operative_tot-petrol}
                                              else {&cda-maria_operative_tot-gds})
                                        ,input '' /*p-attr-character*/
                                        ,input ? /*p-attr-date*/
                                        ,input 0.0 /*p-attr-decimal*/
                                        ,input  (v-tot-gds + 1) /*p-attr-integer*/
                                        ,input no /*p-attr-logical*/

                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <текущее количество товаров на кассе> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , {&shop}
                       ,buf_cash-desk.obj-code
                       , {&new-line}
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end. /*if error-status:error then do:*/

  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  {&cda-maria_operative}
                                        ,input  {&cda-maria_operative_to-send}
                                        ,input '' /*p-attr-character*/
                                        ,input ? /*p-attr-date*/
                                        ,input 0.0 /*p-attr-decimal*/
                                        ,input 0 /*p-attr-integer*/
                                        ,input yes /*p-attr-logical*/
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <Есть коды товаров, не отправленные на кассу> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , {&shop}
                       ,buf_cash-desk.obj-code
                       , {&new-line}
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end. /*if error-status:error then do:*/
  return "":U.
end. /*doe*/
END PROCEDURE.


procedure cd-mrkt_update-marketer :
define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
define input parameter p-is-petrolium as logical no-undo .

define variable v-to-send as logical no-undo .
define variable v-tot-gds as integer no-undo .
define variable v-max-plu as integer no-undo .
define buffer buf_cd-plu for ub.cd-plu.
define variable v-plu-type as character no-undo .

  do
  on error undo, return error
  :

    v-to-send = no.
    v-tot-gds = 0.
    assign
    v-plu-type = (if p-is-petrolium
                  then  {&petrolium}
                  else '':U
              )
    .
    FOR EACH buf_cd-plu WHERE
           buf_cd-plu.obj-type = {&shop}
      and  buf_cd-plu.obj-code = p-obj-code
      and  buf_cd-plu.pos-type = p-pos-type
      and  buf_cd-plu.plu-type = v-plu-type
          :
      if  buf_cd-plu.to-del
      or  buf_cd-plu.to-send then do:
        assign
        v-to-send = yes.
      end.
      assign
      v-tot-gds = v-tot-gds + 1.
    end.

    run cd-attr-write  in this-procedure (
                                            input   p-db-num
                                            ,input  p-obj-code
                                            ,input  p-pos-type
                                            ,input  p-cash-num
                                            ,input  {&cda-maria_operative}
                                            ,input  (if p-pos-type = {&cd-type-maria}
                                                     and p-is-petrolium
                                                     then  {&cda-maria_operative_tot-petrol}
                                                     else {&cda-maria_operative_tot-gds})
                                            ,input '' /*p-attr-character*/
                                            ,input ? /*p-attr-date*/
                                            ,input 0.0 /*p-attr-decimal*/
                                            ,input v-tot-gds /*p-attr-integer*/
                                            ,input no /*p-attr-logical*/
                                                                                        ) no-error .
    if error-status:error then do:
        UNDO, RETURN ERROR RETURN-VALUE.
    END.


    run cd-attr-write  in this-procedure (
                                            input   p-db-num
                                            ,input  p-obj-code
                                            ,input  p-pos-type
                                            ,input  p-cash-num
                                            ,input  {&cda-maria_operative}
                                            ,input  (if p-pos-type = {&cd-type-maria}
                                                     and p-is-petrolium
                                                     then  {&cda-maria_operative_petrol-to-send}
                                                     else {&cda-maria_operative_to-send})
                                            ,input '' /*p-attr-character*/
                                            ,input ? /*p-attr-date*/
                                            ,input 0.0 /*p-attr-decimal*/
                                            ,input 0 /*p-attr-integer*/
                                            ,input v-to-send /*p-attr-logical*/
                                            ) no-error .
    if error-status:error then do:
        UNDO, RETURN ERROR RETURN-VALUE.
    END.

    FIND LAST buf_cd-plu NO-LOCK  WHERE
             buf_cd-plu.obj-type = {&shop}
         and buf_cd-plu.obj-code = p-obj-code
         and buf_cd-plu.pos-type = p-pos-type
         and buf_cd-plu.plu-type = v-plu-type  use-index pi no-error .
    if available buf_cd-plu then do:
      if v-max-plu < buf_cd-plu.plu-code
      then
      v-max-plu = buf_cd-plu.plu-code .
    end.
    else do:
      v-max-plu = 0.
    end.
    run cd-attr-write  in this-procedure (
                                          input   p-db-num
                                          ,input  p-obj-code
                                          ,input  p-pos-type
                                          ,input  p-cash-num
                                          ,input  {&cda-maria_operative}
                                          ,input  (if p-pos-type = {&cd-type-maria}
                                                  and p-is-petrolium
                                                  then {&cda-maria_operative_max-petrol-plu}
                                                  else {&cda-maria_operative_max-plu})
                                            ,input '' /*p-attr-character*/
                                            ,input ? /*p-attr-date*/
                                            ,input 0.0 /*p-attr-decimal*/
                                            ,input v-max-plu /*p-attr-integer*/
                                            ,input no /*p-attr-logical*/
                                          ) no-error .
    if error-status:error then do:
        UNDO, RETURN ERROR RETURN-VALUE.
    END.
  end.

end procedure. /* cd-attr_update-marketer */

/*добавление нового кода клиента на кассу маркетер*/
PROCEDURE cd-mrkt_clu-marketer :
define input parameter p-silence as logical no-undo .
define parameter buffer buf_cash-desk for ub.cash-desk.
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .


define variable v-tot-cli as integer no-undo .
define variable v-max-cli as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .

define buffer  buf_cd-clu for ub.cd-clu.
define buffer  loc_cd-clu for ub.cd-clu.

define variable  ii as integer no-undo.
define variable v-mes as character no-undo .
_main:
DO ON ERROR undo, leave on stop undo, leave:
  if buf_cash-desk.pos-type <> {&cd-type-maria}
  or buf_cash-desk.cash-num <> 0 then do:

    assign
    v-mes =
    substitute("Клиенты на кассах можно определять только для кассовых менеджеров (номер кассы = 0) для типов касс &1"
              , buf_cash-desk.pos-type).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    return error v-mes.
  end.
  v-tot-cli = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input {&cda-maria_operative}
                                  ,input {&cda-maria_operative_tot-cli}
                                  ,output v-mes).
  if v-tot-cli = ? then undo _main, return error v-mes.
  v-max-cli = cd-attr_get-attr-int(buffer buf_cash-desk
                                  ,input {&cda-maria_general}
                                  ,input {&cda-maria_general_max-cli}
                                  , output v-mes).
  if v-max-cli = ? then undo _main, return error v-mes.

  DO ii = 1
     to v-max-cli :
    if not can-find (loc_cd-clu where
                    loc_cd-clu.obj-type = {&shop}
                and loc_cd-clu.obj-code = buf_cash-desk.obj-code
                and loc_cd-clu.pos-type = buf_cash-desk.pos-type
                and loc_cd-clu.clu-type = '':U
                and loc_cd-clu.clu-code = ii
                   )
    then LEAVE .
  END .
  if ii > v-max-cli then do:
      if not p-silence then
      message
      substitute("Превышено максимально допустимое количество клиентов &1" +
                "для касс &2 &3&4"
                , {&new-line}
                , v-max-cli
                , {&shop}
                , buf_cash-desk.obj-code
                )
      view-as alert-box ERROR .
      undo, return error "max-cli":U.
  end.
  run cur-time in this-procedure ( output v-today, output v-time).
  create buf_cd-clu.
  assign
  buf_cd-clu.cli-code = p-obj-code
  buf_cd-clu.cli-type = p-obj-type
  buf_cd-clu.obj-type = {&shop}
  buf_cd-clu.obj-code = buf_Cash-desk.obj-code
  buf_cd-clu.pos-type = buf_cash-desk.pos-type
  buf_cd-clu.clu-type = '':U
  buf_cd-clu.to-send = yes
  buf_cd-clu.charkey_two = (if buf_cash-desk.pos-type = {&cd-type-maria}
                            then buf_cash-desk.addr-path
                            else "U":U)
  buf_cd-clu.clu-code = ii
  .
  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  {&cda-maria_operative}
                                        ,input  {&cda-maria_operative_tot-cli}
                                        ,input '' /*p-attr-character*/
                                        ,input ? /*p-attr-date*/
                                        ,input 0.0 /*p-attr-decimal*/
                                        ,input  (v-tot-cli + 1) /*p-attr-integer*/
                                        ,input no /*p-attr-logical*/
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <текущее количество клиентов на кассе> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , {&shop}
                       ,buf_cash-desk.obj-code
                       , {&new-line}
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.

  run cd-attr-write  in this-procedure (
                                        input   buf_cash-desk.db-num
                                        ,input  buf_cash-desk.obj-code
                                        ,input  buf_cash-desk.pos-type
                                        ,input  buf_cash-desk.cash-num
                                        ,input  {&cda-maria_operative}
                                        ,input  {&cda-maria_operative_cli-to-send}
                                        ,input '' /*p-attr-character*/
                                        ,input ? /*p-attr-date*/
                                        ,input 0.0 /*p-attr-decimal*/
                                        ,input 0 /*p-attr-integer*/
                                        ,input yes /*p-attr-logical*/
                                       ) no-error .
  if error-status:error then do:
    v-mes = substitute("Ошибка при записи <Есть коды клиентов, не отправленные на кассу> для кассы &1 &2&3:&4&5 &6"
                       ,buf_cash-desk.cash-num
                       , {&shop}
                       ,buf_cash-desk.obj-code
                       , {&new-line}
                       , error-status:get-message(1)
                       , return-value
                       ).
    if not p-silence then
    message
    v-mes
    view-as alert-box error .
    undo _main, return error v-mes.
  end.
  return "":U.
end.
END PROCEDURE. /*cd-mrkt_сlu-marketer */



procedure cd-mrkt_update-marketer-cli :
define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .

define variable v-cli-to-send as logical no-undo .
define variable v-tot-cli as integer no-undo .
define variable v-max-clu as integer no-undo .
define buffer buf_cd-clu for ub.cd-clu.
do
on error undo, return error return-value
:
  v-cli-to-send = no.
  v-tot-cli = 0.
  FOR EACH buf_cd-clu WHERE
        buf_cd-clu.obj-type = {&shop}
    and buf_cd-clu.obj-code =  p-obj-code
    and buf_cd-clu.pos-type =  p-pos-type
    and buf_cd-clu.clu-type =  '':U
    :
    if buf_cd-clu.to-del = yes then do:
      assign
      v-cli-to-send = yes.
    end.
    assign
    v-tot-cli = v-tot-cli + 1.
  end.

  run cd-attr-write  in this-procedure (
                                          input   p-db-num
                                          ,input  p-obj-code
                                          ,input  p-pos-type
                                          ,input  p-cash-num
                                          ,input  {&cda-maria_operative}
                                          ,input  {&cda-maria_operative_tot-cli}
                                          ,input '' /*p-attr-character*/
                                          ,input ? /*p-attr-date*/
                                          ,input 0.0 /*p-attr-decimal*/
                                          ,input v-tot-cli /*p-attr-integer*/
                                          ,input no /*p-attr-logical*/
                                          ) no-error .
  if error-status:error then do:
      UNDO, RETURN ERROR RETURN-VALUE.
  END.

  run cd-attr-write  in this-procedure (
                                          input   p-db-num
                                          ,input  p-obj-code
                                          ,input  p-pos-type
                                          ,input  p-cash-num
                                          ,input  {&cda-maria_operative}
                                          ,input  {&cda-maria_operative_cli-to-send}
                                          ,input '' /*p-attr-character*/
                                          ,input ? /*p-attr-date*/
                                          ,input 0.0 /*p-attr-decimal*/
                                          ,input 0 /*p-attr-integer*/
                                          ,input v-cli-to-send /*p-attr-logical*/
                                          ) no-error .
  if error-status:error then do:
      UNDO, RETURN ERROR RETURN-VALUE.
  END.

  FIND LAST buf_cd-clu WHERE
          buf_cd-clu.obj-type = {&shop}
      and buf_cd-clu.obj-code = p-obj-code
      and buf_cd-clu.pos-type = p-pos-type
      and buf_cd-clu.clu-type = '':U
      NO-LOCK use-index pi no-error .
  if available buf_cd-clu then do:
    if v-max-clu < buf_cd-clu.clu-code
    then
    v-max-clu = buf_cd-clu.clu-code.
  end.
  else do:
    v-max-clu = 0.
  end.
  run cd-attr-write  in this-procedure (
                                        input   p-db-num
                                        ,input  p-obj-code
                                        ,input  p-pos-type
                                        ,input  p-cash-num
                                        ,input  {&cda-maria_operative}
                                        ,input  {&cda-maria_operative_max-clu}
                                        ,input '' /*p-attr-character*/
                                        ,input ? /*p-attr-date*/
                                        ,input 0.0 /*p-attr-decimal*/
                                        ,input v-max-clu /*p-attr-integer*/
                                        ,input no /*p-attr-logical*/
                                        ) no-error .
  if error-status:error then do:
      UNDO, RETURN ERROR RETURN-VALUE.
  END.

end. /*doe*/

end procedure. /* cd-attr_update-marketer-cli */


/* $Workfile$ e n d */