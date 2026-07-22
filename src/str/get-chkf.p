/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Программа приема чеков с касс

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/28/05
Author: Bakhtadze Natalya
Creation date: 09/28/05

На объекте:
p-remote = 0
1 посылает запросы на все включенные не remote кассы объекта
2 читает поочередно полученные спул-файлы
3 все чеки, которых нет в БД, переписывает в БД
4 проверяет правильность каждого чека и отмечает ошибки


p-remote = 1
1 посылает запросы на все включенные remote кассы объекта

p-auto = -1 подбор неразобранных ранее файлов с касс IBM-XML не посылаем запрос

*/
block-level on error undo, throw.

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
/*
p-parameter включает
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .

define input parameter p-remote as integer no-undo .
которые далее определены как переменные с префиксом p-

*/
/*0 работа с*/

define variable vss-revision    as character no-undo init "$Revision$":u .
define variable vss-author      as character no-undo init "$Author$":u .
define variable vss-date        as character no-undo init "$Date$":u .
define variable vss-workfile    as character no-undo init "$Workfile$":u .
define variable vss-archive     as character no-undo init "$Archive$":u .
define variable vss-description as character no-undo init "Программа приема чеков с касс" .
{ cmp/vssrevis.i }

{ str/get-chk.i  NEW }
{ str/get-chkf.i }
{ bge/bgelib.i }
{ str/cd-xml.i  }
{ str/tekkatsk.i  " " Dirstream }
{ gbl/thbj-def.i }
{ gbl/key-rec.i }
{ bge/socet.i}
{ gbl/objsrv.i}
/*образыв бывших input parameter*/
define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .

define variable p-remote as integer no-undo .
define variable p-auto   as integer no-undo .
define variable p-shft-close  as integer no-undo .
define variable p-other  as character no-undo .
define variable v-input-error as logical no-undo .
define variable v-view-log as logical no-undo .
define variable v-date as date      no-undo.
define variable v-time  as integer   no-undo.
define variable v-today-date as date      no-undo.
define variable v-today-time  as integer   no-undo.
define variable v-shift-num as integer no-undo .
define variable v-shift-name as character no-undo.
define variable v-z-count as integer no-undo .
define variable v-chk-num as integer no-undo .
define variable v-mes as character no-undo .
define variable v-param-prfx as character no-undo .
define variable v-shift-date  as date no-undo .
define variable l-shift-on as logical no-undo .
define variable v-esm as character no-undo .
define variable v-shift-date-chr as character no-undo .
define variable v-versiond as decimal no-undo .
define variable v-podbor as logical no-undo .
define variable log-file-name as character no-undo .
define variable ii as integer no-undo .
define variable v-spec-command as character no-undo .
define variable v-entry as character no-undo .
define variable v-attr-value as character no-undo .
define variable v-attr-type as character no-undo .
define variable v-is-script as logical no-undo .
define variable imaria as integer no-undo .
define variable shift-maria as integer no-undo .
define variable v-p-spl as character no-undo .
define variable v-spl-doc as character no-undo .
define variable v-spl as character no-undo .
define variable v-no-get-chk as logical no-undo .
define variable dflt-cd as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable vi as integer no-undo.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .


&scop view-log   if p-auto = 0 then do: ~
                   ~{ str/cdviewlg.i   ~
                    "substitute('!!!При приеме информации с касс &1&2 произошли ошибки!!!'  ~
                                 ,p-obj-type                                                ~
                                 ,p-obj-code)"                                               ~
                    "'get-chkf.log'" ~}   ~
                    return "error":U. ~
                 end

if num-entries(p-parameter, {&delim-par}) < 3
then do:
  assign
  v-input-error = yes
  v-esm         = "Неверное количество ENTRY в составном параметре"
  .
end.
else do:
  assign
  p-obj-type = entry(1, p-parameter, {&delim-par})
  p-obj-code = integer(entry(2, p-parameter, {&delim-par}))
  p-remote = integer(entry(3, p-parameter, {&delim-par}))
  p-auto   = if num-entries(p-parameter, {&delim-par}) >= 4
             then integer(entry(4, p-parameter, {&delim-par}))
             else 0
  p-shft-close  = if num-entries(p-parameter, {&delim-par}) >= 5
             then integer(entry(5, p-parameter, {&delim-par}))
             else 0
  no-error .
  if error-status:error then do:
    assign
    v-esm = error-status:get-message(1)
    v-input-error = yes
    .
  end.
  if num-entries(p-parameter, {&delim-par}) > 7 then do:
    p-other = p-parameter.
    entry(1, p-other, {&delim-par}) = ''.
    p-other = substring(p-other, 2).
    entry(1, p-other, {&delim-par}) = ''.
    p-other = substring(p-other, 2).
    entry(1, p-other, {&delim-par}) = ''.
    p-other = substring(p-other, 2).
    entry(1, p-other, {&delim-par}) = ''.
    p-other = substring(p-other, 2).
    entry(1, p-other, {&delim-par}) = ''.
    p-other = substring(p-other, 2).
    entry(1, p-other, {&delim-par}) = ''.
    p-other = substring(p-other, 2).
    entry(1, p-other, {&delim-par}) = ''.
    p-other = substring(p-other, 2).
  end.
  assign
  v-podbor = (if p-auto = -1 then yes else no)
  p-auto   = (if v-podbor then 0 else p-auto)
  p-auto = (if g#auto then 1 else 0)
  .
end.


assign
log-file-name = (if p-auto = 0 then 'get-chkf.log' else 'extgetcd.log').


if v-input-error = yes then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , v-esm
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.

{ str/waitp.i }


DEFINE VARIABLE var-found-not-remote  as logical no-undo .
DEFINE VARIABLE var-spl-suffix as character no-undo .
DEFINE VARIABLE var-spl-suffix-tmp as character no-undo .
define variable v-host-code like ub.sysconf.host-code no-undo .
define variable glog as logical no-undo .

if TRANSACTION then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1 &2 &3 Обратитесь к администратору системы&4" +
                         "Необходимо проверить, не включены ли одновременно настройки:&4" +
                         "<Значение цены в продаже брать из прайс-листа> = yes и&4" +
                         "<Тип автопереоценки> = before-margin, - это недопустимо."
                         , vss-workfile
                         , vss-revision
                         , vss-description
                         , {&new-line}
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.

for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
run adm/shattri.p (
      input "get":U
    ,input  '':U
    ,input  0
    ,input  {&attr-gds-ref}
    ,input  "":U /*p-param-code*/
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
  define variable v-disp-msg as character no-undo.
  v-disp-msg = substitute("Ошибка при получении опций работы со справочником товаров:&1&2 &3"
            , {&new-line}
            , error-status:get-message(1)
            , return-value ) .
  message v-disp-msg view-as alert-box error .
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input v-disp-msg).
  assign
  v-view-log = yes.
  undo, return .
end.
for each thbjattr_thbj-attr  where
        thbjattr_thbj-attr.obj-type = '':U
    and thbjattr_thbj-attr.obj-code = 0
    and thbjattr_thbj-attr.upper-prop-code = {&attr-gds-ref}
:
  case thbjattr_thbj-attr.prop-code:
    when {&attr-gds-ref_unq-artc} then do :
      unq-artc = thbjattr_thbj-attr.property-value-logical.
    end.
  end case.
end.

define buffer get-chk-lock_batchprocess  for ub.batchprocess .

{ gbl/hostcode.i p-obj-type p-obj-code v-host-code }

{ str/lockgchk.i }

run writelog in p-log-handle (
      input log-file-name
    , input 0
    , input  "&Dline"
                                  ).
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  {&attr-get-chk}
    ,input  {&attr-get-chk_no-get-chk} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .
assign
v-no-get-chk = v-value-logical
no-error .
if v-no-get-chk then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Согласно настроечным параметрам НЕТ приема чеков в &1&2!!!&3"
                          , p-obj-type
                          , p-obj-code
                          , {&new-line}
                        )
                                    ).
   return.
end.



run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "&1 &2&3"
                        , (if p-remote = 1 then "Запрос на удаленные кассы" else "Прием данных с касс")
                        , p-obj-type
                        , p-obj-code

                      )
                                  ).


define variable v-cd-prfx as character no-undo .
define variable v-spl-obj-cash-name as character no-undo .

{ gbl/dflt-cd.i p-obj-type p-obj-code dflt-cd no-error }

_cash-desk:
FOR EACH ub.cash-desk NO-LOCK WHERE
         ub.cash-desk.db-num = g#db-num and
         ub.cash-desk.obj-code = p-obj-code AND
         ub.cash-desk.cash-on
BREAK
By ub.cash-desk.pos-type
with frame a :
  IF FIRST-OF(ub.cash-desk.pos-type) then do:
    
    v-index = index(p-other, ub.cash-desk.pos-type + '=').
    if v-index > 0 then do:
      /*извлечем спец команду*/
      assign
      v-spec-command  = substring(p-other, v-index)
      v-index = index(v-spec-command , {&delim-par})
      v-spec-command  = if v-index > 0
                        then substring(v-spec-command , 1, v-index - 1)
                        else v-spec-command
      v-spec-command = replace(v-spec-command, cash-desk.pos-type + '=', '':U)
      .
    end.
    else do:
      v-spec-command = '':U.
    end.
    CASE cash-desk.pos-type:
      when {&cd-type-MAGIA-XML} then do:
        assign
        v-cd-prfx = 'magia':U
        .
      end.
      when {&cd-type-IBM-XML} then do:
        assign
        v-cd-prfx = 'IBM-XML':U
        v-param-prfx = 'ibm':U
        .
      end.
      when {&cd-type-IBM} then do:
        assign
        v-cd-prfx = 'IBM':U
        v-param-prfx = 'ibm':U
        .
      end.
      when {&cd-type-NKT-IBM} then do:
        assign
        v-cd-prfx = 'NKT-IBM':U
        v-param-prfx = 'ibm':U
        .
      end.
      when {&cd-type-ncr-gm} then do:
        assign
        v-cd-prfx = 'ncr-gm':U
        .
      end.
      when {&cd-type-ncr-as-r} then do:
        assign
        v-cd-prfx = 'ncr-as-r':U
        .
      end.
      when {&cd-type-r-keeper} then do:
        assign
        v-cd-prfx = 'r-keeper':U
        .
      end.
      when {&cd-type-maria} then do:
        assign
        v-cd-prfx = 'maria':U
        v-param-prfx = 'maria':U
        .
      end.
      when {&cd-type-autotank} then do:
        assign
        v-cd-prfx = 'autotank':U
        v-param-prfx = 'autotank':U
        .
      end.
    END CASE.
    CASE cash-desk.pos-type :
      when {&cd-type-IBM}
      or
      when {&cd-type-IBM-XML}
      or
      when {&cd-type-MAGIA-XML}
      or
      when {&cd-type-NKT-IBM}
      or
      when {&cd-type-autotank}
      then  do:
        run str/get-inis.p (
                         input p-obj-type
                       , input p-obj-code
                       , input cash-desk.pos-type
                       , input cash-desk.remote
                       , input "get":U /*некий параметр который говорит для чего нам настройки*/
                       , output out
                       , output out2
                       , output in_
                       , output spl
                       , output sav
                       , output v-remote
                       )  no-error .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute(
                                "!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                                , cash-desk.pos-type
                                , p-obj-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                )).
          assign
          v-view-log = yes.
          {&view-log}.
          else undo,  return "error".
        end.
        if cash-desk.pos-type = {&cd-type-magia-XML} then do:
          assign
          kassa-rub-code = 0
          ibmgroup = no
          ibmspool = "3"
          .
        end.
        else do:
          /* выбор секции, из которой читать настройки для кассы */
          define variable v-effective-pos-type as character no-undo .
          v-effective-pos-type =  (if (cash-desk.pos-type = {&cd-type-ibm}
                                      or
                                      cash-desk.pos-type = {&cd-type-nkt-ibm})
                                  then {&attr-cd-type-ibm}
                                  else {&attr-cd-type-ibm-xml}
                                  ).
          /*
          if ub.cash-desk.pos-type = {&cd-type-ibm} OR ub.cash-desk.pos-type = {&cd-type-nkt-ibm} 
              then v-effective-pos-type = {&attr-cd-type-ibm}.
              else if ub.cash-desk.pos-type = {&cd-type-IBM-XML} 
                      then v-effective-pos-type = {&attr-cd-type-ibm-xml}.
                      else 
                          if ub.cash-desk.pos-type = {&cd-type-Autotank} 
                              then v-effective-pos-type = {&attr-cd-type-Autotank}.
                              else v-effective-pos-type = {&attr-cd-type-marketer}.*/
          run adm/shattri.p (
              input "get":U
              ,input  p-obj-type
              ,input  p-obj-code
              ,input  v-effective-pos-type
              ,input  '':U /*p-param-code*/
              ,output v-value-character
              ,output v-value-date
              ,output v-value-decimal
              ,output v-value-integer
              ,output v-value-logical
              ,output v-param-type
              ,INPUT-OUTPUT table-handle v-tth
              ) no-error .
          IF error-status:error then do:
            assign
            v-mes =  substitute(
                                  "Не удалось получить настройки для  POS типа &1 для маг&2"
                                  , cash-desk.pos-type
                                  , p-obj-code).
            run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input v-mes).
            v-view-log = yes.
            undo, return error v-mes.
          end.
          for each thbjattr_thbj-attr where
                  thbjattr_thbj-attr.obj-type = p-obj-type
              and thbjattr_thbj-attr.obj-code = p-obj-code
              and thbjattr_thbj-attr.upper-prop-code =  v-effective-pos-type
          on error undo, return error :
            case thbjattr_thbj-attr.prop-code :
              when {&attr-cd-type-ibm_ibmgroup} then do:
                assign
                ibmgroup = thbjattr_thbj-attr.property-value-logical.
              end.
              when {&attr-cd-type-ibm_ibmrubc}
              or when {&attr-cd-type-ibm-xml_ibmrubc} then do:
                kassa-rub-code = thbjattr_thbj-attr.property-value-integer.
              end.
              when {&attr-cd-type-IBM-XML_specgrp}
              or when {&attr-cd-type-IBM_specgrp} then do:
                specgrp = thbjattr_thbj-attr.property-value-character.
              end.
              when {&attr-cd-type-ibm_ibmspool} then do:
                if cash-desk.pos-type = {&cd-type-ibm}
                or cash-desk.pos-type = {&cd-type-nkt-ibm}
                then do:
                  assign
                  ibmspool = string(thbjattr_thbj-attr.property-value-integer).
                end.
              end.
              when {&attr-cd-type-autotank_cash-pay-list} then do:

              end.
            end case.
          end.
          if cash-desk.pos-type = {&cd-type-ibm-xml}
          and entry(1, v-spec-command) = "version" then do:
            define variable v-field-list as character no-undo .
            define variable v-value-list as character no-undo .
            define variable v-pos-type as character no-undo .
            define variable v-cash-num as integer no-undo init ?.
            run gen-key-fv in this-procedure ( input replace(v-spec-command, "version" + {&comma-char}, '')
                                              ,output v-field-list
                                              ,output v-value-list
                                              ).
            assign
            v-pos-type = entry(lookup("pos-type"
                                      , v-field-list
                                      , {&delim-key})
                                , v-value-list, {&delim-key})
            v-cash-num = integer(entry(lookup("cash-num"
                                              , v-field-list
                                              , {&delim-key})
                                        , v-value-list, {&delim-key})).
          end.
        end. /*ibm* или ibm-xml */
        assign
        var-found-not-remote = no
        .
        
        /* Получение данных по топливным транзакциям с кассы */
        if entry(1, v-spec-command) ne "version"
        then do:
           run str/get-tran-fuel.p(parparentproc,
                                   p-parent-handle,
                                   p-log-handle,
                                   log-file-name,
                                   p-obj-type,
                                   p-obj-code,
                                   output v-value-logical) no-error.
           if error-status:error then do:
              run write-log-and-file in p-log-handle (
                           input 1
                         , input log-file-name
                         , input 1
                         , input return-value).
           
           end.
        end.
        
        /* Получение данных по слипам с кассы */
        run str/get-chk-slips.p(parparentproc,
                                p-parent-handle,
                                p-log-handle,
                                log-file-name,
                                p-obj-type,
                                p-obj-code,
                                output v-value-logical) no-error.
        if error-status:error then do:
           run write-log-and-file in p-log-handle (
                        input 1
                      , input log-file-name
                      , input 1
                      , input return-value).
        
        end.
        if p-shft-close = 1 then do:
                    /* Получение данных по отчетам с кассы */
                    run str/get-chk-report.p(parparentproc,
                        p-parent-handle,
                        p-log-handle,
                        log-file-name,
                        p-obj-type,
                        p-obj-code,
                        output v-value-logical) no-error.
                    if error-status:error then 
                    do:
                        run write-log-and-file in p-log-handle (
                            input 1
                            , input log-file-name
                            , input 1
                            , input return-value).
        
                    end.            
        end.

        _ibm-cash-desk:
        FOR EACH for-cash-desk NO-LOCK WHERE
                for-cash-desk.db-num = g#db-num and
                for-cash-desk.pos-type = cash-desk.pos-type AND
                for-cash-desk.obj-code = p-obj-code AND
                for-cash-desk.cash-on = yes :
          if for-cash-desk.autonomy = integer({&cd-manager})
          and for-cash-desk.pos-type <> {&cd-type-autotank}
          then next _ibm-cash-desk.
          if for-cash-desk.autonomy = integer({&cd-slave})
          and for-cash-desk.pos-type = {&cd-type-autotank}
          then next _ibm-cash-desk.
          if v-cash-num <> ? and
          not (for-cash-desk.cash-num = v-cash-num
               and for-cash-desk.pos-type = v-pos-type)
          then next.
          /*непосредственно блок запроса*/
          if for-cash-desk.remote = 1 then do:
            /*для удаленных касс в суффикс должна входить и соотв поддиректория out[номер магазина]-[номар кассы] */
            /*проверим наличие этой директории - если ее нет пробуем создать*/
            if p-remote = 0 then NEXT _ibm-cash-desk.
            /*запрос на remote кассу отправляется только в случае p-remote = 1*/
            assign
            v-spl-obj-cash-name = string(for-cash-desk.obj-code, "99999") + "-":U +
                             trim(string(for-cash-desk.cash-num, ">999"))
            v-dir-remote-tmp = v-remote + "tmp":U
            v-dir-remote =  v-remote + "out":U + v-spl-obj-cash-name
            .

            run gbl/dir-cre.p ( input v-dir-remote-tmp) no-error .
            if error-status:error then do:
              /*директории нет и не удалось создать*/
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute(
                                    "!!!Каталог &1 для отсылки запроса на удаленную кассу &2 маг&3 не найден&4" +
                                    "и/или попытка его создания не удалась:&4 &5 &6"
                                    , v-dir-remote-tmp
                                    , for-cash-desk.cash-num
                                    , p-obj-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                    )).
              assign
              v-view-log = yes.
              NEXT _ibm-cash-desk.
            end. /*if error-status:error при dire-cre then do:*/
            assign
            var-spl-suffix = v-dir-remote + {&slash-char} +
                            "spl":U + v-spl-obj-cash-name
            var-spl-suffix-tmp = v-dir-remote-tmp + {&slash-char} +
                            "spl":U + v-spl-obj-cash-name
            .
          end. /*remote*/
          else do:
            if p-remote = 1  then NEXT _ibm-cash-desk.
            assign
            v-spl-obj-cash-name = string(for-cash-desk.obj-code, "99999") + "-":U + trim(string(for-cash-desk.cash-num, ">999"))
            var-spl-suffix = "spl":U  + v-spl-obj-cash-name
            var-spl-suffix-tmp = "spl":U  + v-spl-obj-cash-name
            .
          end.
          if (p-remote = 0 and Not for-cash-desk.remote = 1) or
              (p-remote = 1 and for-cash-desk.remote = 1 )  then do:
            if cash-desk.pos-type = {&cd-type-ibm}
            or cash-desk.pos-type = {&cd-type-nkt-ibm}
            then do:
              if search( (if for-cash-desk.remote = 1 then "":U else out) + var-spl-suffix-tmp + '.dat':U ) = ? then  do:
                output to value( (if for-cash-desk.remote = 1 then "":U else out) + var-spl-suffix-tmp + '.dat':U ) convert target "ibm866".
                put unformatted '<' spl '>'.
                output close.
              end.
              else do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute(
                                      "!!!Не могу отправить запрос на кассу &1 маг&2 по адресу &3&4" +
                                      "Возможно, в каталоге &5&4" +
                                      "остались файлы spl*.adr и spl*.dat&4" +
                                      "предыдущего недошедшего до кассы запроса - УДАЛЯЮТСЯ..."
                                      , for-cash-desk.cash-num
                                      , p-obj-code
                                      , for-cash-desk.addr-path
                                      , {&new-line}
                                      , ( if for-cash-desk.remote = 1 then v-dir-remote-tmp else out)
                                      )).
                assign
                v-view-log = yes.
                OS-DELETE value( (if for-cash-desk.remote = 1 then "":U else out) + var-spl-suffix-tmp + '.adr':U ) .
                OS-DELETE value( (if for-cash-desk.remote = 1 then "":U else out) + var-spl-suffix-tmp + '.ad0':U ) .
                OS-DELETE value( (if for-cash-desk.remote = 1 then "":U else out) + var-spl-suffix-tmp + '.dat':U ) .
                output to value( (if for-cash-desk.remote = 1 then "":U else out) + var-spl-suffix-tmp + '.dat':U ) convert target "ibm866".
                put unformatted '<' spl '>'.
                output close.
              end.
              output to value( (if for-cash-desk.remote = 1 then "":U else out) + var-spl-suffix-tmp + '.ad0':U ) convert target "ibm866".
              put ' ' skip(1). /* две пустые строки */
              put unformatted '  ' for-cash-desk.addr-path ' spool' skip.
              output close.
              OS-RENAME
              VALUE((if for-cash-desk.remote = 1 then "":U else out) + var-spl-suffix-tmp + '.ad0':U)
              VALUE((if for-cash-desk.remote = 1 then "":U else out) + var-spl-suffix-tmp + '.adr':U).
              os-er = OS-ERROR.
              if os-er <> 0 then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute(
                                      "!!!Ошибки при записи файлов запроса на кассу &1 маг&2 по адресу &3&4" +
                                      "Ошибки в работе локальной сети или нарушение прав доступа!"
                                      , for-cash-desk.cash-num
                                      , p-obj-code
                                      , ((if for-cash-desk.remote = 1 then "":U else out) + var-spl-suffix-tmp + '.adr':U)
                                      , {&new-line}
                                      )).
                assign
                v-view-log = yes.
                return error.
              end.
              if for-cash-desk.remote = 1 then do:
                /*проверим директорию*/
                run gbl/dir-cre.p ( input v-dir-remote) no-error .
                if error-status:error then do:
                  /*директории нет и не удалось создать*/
                  run write-log-and-file in p-log-handle (
                        input 1
                      , input log-file-name
                      , input 1
                      , input substitute(
                                        "!!!Каталог &1 для отсылки запроса на удаленную кассу &2 маг&3 не найден&4" +
                                        "и/или попытка его создания не удалась:&4 &5 &6"
                                        , v-dir-remote
                                        , for-cash-desk.cash-num
                                        , p-obj-code
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        )).
                  assign
                  v-view-log = yes.
                  NEXT _ibm-cash-desk.
                end.
                /*переименуем из tmp*/
                OS-RENAME
                VALUE(var-spl-suffix-tmp + '.adr':U)
                VALUE(var-spl-suffix + '.adr':U).
                OS-RENAME
                VALUE(var-spl-suffix-tmp + '.dat':U)
                VALUE(var-spl-suffix + '.dat':U).
              end.
              else do:
                assign
                var-found-not-remote = yes
                .
                RUN waitp in this-procedure (
                    input p-auto
                    ,input (out + var-spl-suffix + '.dat':U)
                    ,input 'Запрос на чтение данных с кассы ' + for-cash-desk.addr-path
                    ,input ' Подождите 15 сек '
                    ,input 'Касса не ответила.'
                    ,input 'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!'
                    ,input 15) NO-ERROR .
                if error-status:error then do:
                  nEXT _IBM-CASH-DESK.
                end.
              end.
            end. /*cd-type-ibm  */
            else do: /*cd-type-ibm-xml*/
              run xml-cd-filename in this-procedure (
                                                        input out
                                                       ,output v-xml-file-name
                                                       ,output v-xml-file-name-path
                                                       ,output v-log-file-name
                                                       ,output v-locked
                                                       ).
                assign
                v-obj-list = {&shop} + string(for-cash-desk.obj-code)
                .
 
              run cur-time in this-procedure(output v-today-date, output v-today-time).
              if cash-desk.pos-type = {&cd-type-magia-XML} then do:
                 run xml-cd-write-header in this-procedure (
                      input v-xml-file-name
                    , input v-xml-file-name-path
                    , input "spool":U
                    , input {&version-string}
                    , input v-obj-list
                    , input (v-obj-list + "_":U + "касса" + string(for-cash-desk.cash-num))
                    , no
                ).

              output stream stmxmlout to value( v-xml-file-name-path + "xm1" ) convert target "1251" append.

             
                /*найдем последний чек по данной кассе*/
                run get-last-check-date-time in this-procedure (
                                                                          input g#db-num
                                                                          ,input for-cash-desk.obj-code
                                                                          ,input for-cash-desk.pos-type
                                                                          ,input for-cash-desk.cash-num
                                                                          ,output v-date
                                                                          ,output v-time) no-error.

                if error-status:error then do:
                  run write-log-and-file in p-log-handle (
                        input 1
                      , input log-file-name
                      , input 1
                      , input substitute(
                                        "!!!Ошибка при получении данных о последнм принятом чеке по кассе &1 &2&3:&4" +
                                        "&5 &6!"
                                        , for-cash-desk.cash-num
                                        , {&shop}
                                        , p-obj-code
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        )).
                  assign
                  v-view-log = yes.
                  assign
                  v-date = v-today-date - 10
                  v-time = v-today-time
                  .
                end.

                run bgelib-tag-open in this-procedure ( input 2, input "SpoolData", input "":U).
                run bgelib-tag-put in this-procedure ( input 3, input "SpoolStation":U, input string(for-cash-desk.cash-num), input 1 ).
                run bgelib-tag-put in this-procedure ( input 3, input "SpoolDateFrom":U,
                                                      input (Xml-CD-DatetoString (v-date) + {&space-char}  + string(v-time, "HH:MM:SS":U)), input 1 ).
                run bgelib-tag-put in this-procedure ( input 3, input "SpoolDateTo":U,
                                                      input (Xml-CD-DatetoString (v-today-date + 2) + {&space-char} + string(0, "HH:MM:SS":U)), input 1 ).
                run bgelib-tag-put in this-procedure ( input 3, input "SpoolCheckType":U,  string(0), input 1 ).
                run bgelib-tag-close in this-procedure ( input 2, input "SpoolData").
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute(
                                      "Запрашиваем чеки с &1 &2 по &3 &4"
                                      ,string(v-date, "99/99/9999")
                                      ,string(v-time, "HH:MM:SS")
                                      ,string(v-today-date + 2, "99/99/9999")
                                      ,string(0, "HH:MM:SS"))).
             output stream stmxmlout close.
              run xml-cd-write-footer in this-procedure ( input for-cash-desk.pos-type, input v-xml-file-name-path, input "spool":U ) no-error .
              if error-status:error then do:
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute(
                                      "!!!Ошибки при записи файлов запроса на кассу &1 маг&2 по адресу &3&4" +
                                      "Ошибки в работе локальной сети или нарушение прав доступа!"
                                      , for-cash-desk.cash-num
                                      , p-obj-code
                                      , v-xml-file-name-path
                                      , {&new-line}
                                      )).
                assign
                v-view-log = yes.
                {&view-log}.
                else undo,  return .
              end.

              end.
              else do:
                 define variable Mreq as longchar no-undo.
                 define variable hSAXWriter as handle no-undo.
                 define variable mReadBuffer as logical no-undo.
                  
                 mReadBuffer = not objSrv:SystemSetting:GetCashCurl.

                 create sax-writer hSAXWriter.
                 if mReadBuffer
                 then
                    hSAXWriter:set-output-destination("longchar", Mreq) no-error.
                 else
                    hSAXWriter:set-output-destination("file"    , v-xml-file-name-path + 'xml':U) no-error.
                 
                 hSAXWriter:formatted = true.
                 hSAXWriter:encoding = "windows-1251".
               
                 hSAXWriter:start-document() no-error.
                 define variable OS-time as character  no-undo.
                 OS-time =  string( ( today - date( "01/01/1996" ) ) * 24 * 3600 + time, ">>>>>>>>9" ).
                 hSAXWriter:start-element("spool") no-error.
                 hSAXWriter:insert-attribute("type",   "REQUEST")       no-error.
                 hSAXWriter:insert-attribute("id",     v-xml-file-name) no-error.
                 hSAXWriter:insert-attribute("from",   string(v-obj-list))      no-error.
                 hSAXWriter:insert-attribute("to",     (v-obj-list + "_":U + "касса" + string(for-cash-desk.cash-num))) no-error.
                 hSAXWriter:insert-attribute("tstamp", string(OS-time))     no-error.
                   
                 
                 if entry(1, v-spec-command) = "version" then do:
                  /*пустой запрос*/
                 end.
                 else do:
                  /*найдем последний чек в закрытой продаже по данной кассе*/
                    run get-last-check-params in this-procedure (
                                                                               input g#db-num
                                                                               ,input for-cash-desk.obj-code
                                                                               ,input for-cash-desk.pos-type
                                                                               ,input for-cash-desk.cash-num
                                                                               ,output v-date
                                                                               ,output v-time
                                                                               ,output v-shift-num
                                                                               ,output v-z-count
                                                                               ,output v-chk-num
                                                                               ) no-error.
                    hSAXWriter:START-ELEMENT("Check").
                    hSAXWriter:insert-attribute("ctrl",   "READ")      no-error.
                    hSAXWriter:insert-attribute("id",     '>') no-error.
                    hSAXWriter:WRITE-data-ELEMENT("CDateFrom" , Xml-CD-DatetoString (v-date) + {&space-char}  + string(v-time, "HH:MM:SS":U) ) no-error.
                  
                    if error-status:error then do:
                       run write-log-and-file in p-log-handle (
                          input 1
                        , input log-file-name
                        , input 1
                        , input substitute(
                                          "!!!Ошибка при получении данных о последнем принятом чеке по кассе &1 &2&3:&4" +
                                          "&5 &6!"
                                          , for-cash-desk.cash-num
                                          , {&shop}
                                          , p-obj-code
                                          , {&new-line}
                                          , error-status:get-message(1)
                                          , return-value
                                          )).
                       v-view-log = yes.
                       assign
                          v-date = v-today-date - 10
                          v-time = v-today-time
                       .
                  end.
                  hSAXWriter:END-ELEMENT("Check" ).
                end.
                hSAXWriter:end-element("spool") no-error.
               
                hSAXWriter:end-document() no-error.
                if hSAXWriter:write-status = 7 then do:
                   delete object hSAXWriter no-error.
                   return error.
                end.
                delete object hSAXWriter no-error.
                run write-log-and-file in p-log-handle (
                      input 1
                    , input log-file-name
                    , input 1
                    , input substitute(
                                      if entry(1, v-spec-command) = "version"
                                      then "Запрашиваем версию кассы"
                                      else "Запрашиваем чеки с &1 &2"
                                      ,string(v-date, "99/99/9999")
                                      ,string(v-time, "HH:MM:SS"))).
                 
              end. /*else if cash-desk.pos-type = {&cd-type-magia-XML} then do:*/
 
              if for-cash-desk.remote = 1 then do:
                /*проверим директорию*/
                run gbl/dir-cre.p ( input v-dir-remote) no-error .
                if error-status:error then do:
                  /*директории нет и не удалось создать*/
                  run write-log-and-file in p-log-handle (
                        input 1
                      , input log-file-name
                      , input 1
                      , input substitute(
                                        "!!!Каталог &1 для отсылки запроса на удаленную кассу &2 маг&3 не найден&4" +
                                        "и/или попытка его создания не удалась:&4 &5 &6"
                                        , v-dir-remote
                                        , for-cash-desk.cash-num
                                        , p-obj-code
                                        , {&new-line}
                                        , error-status:get-message(1)
                                        , return-value
                                        )).
                  assign
                  v-view-log = yes.
                  NEXT _ibm-cash-desk.
                end.
                /*переименуем из tmp*/
                OS-RENAME
                VALUE(v-xml-file-name-path + 'xml':U)
                VALUE(var-spl-suffix + '.xml':U).
              end.
              else do:
                assign
                var-found-not-remote = yes
                .
                if for-cash-desk.autonomy = integer({&cd-self})
                or (for-cash-desk.autonomy = integer({&cd-manager})
                    and
                    for-cash-desk.pos-type = {&cd-type-autotank})
                then do:
                  if not v-podbor then do:
                    if not mReadBuffer
                    then do:
                       run str/post-xml.p
                         (
                          input parparentproc
                         ,input p-parent-handle
                         ,input p-log-handle
                         ,input g#news
                         ,input g#auto
                         ,input 'get'
                         ,input log-file-name
                         ,input (entry(1, for-cash-desk.addr-path, {&delim-par}) + '://' + entry(2, for-cash-desk.addr-path, {&delim-par}))
                         ,input (v-xml-file-name-path + 'xml':U)
                         ,input (replace(in_ + spl + "/" + v-xml-file-name, "/", "\" ) + ".xml")
                         ,input 30
                         ,input substitute('Чтение данных с кассы &1://&2'
                                           ,entry(1, for-cash-desk.addr-path, {&delim-par})
                                           ,entry(2, for-cash-desk.addr-path, {&delim-par})
                                         )
                         ) no-error .
                       if error-status:error
                       or return-value = "error" then do:
                         run write-log-and-file in p-log-handle (
                               input 1
                             , input log-file-name
                             , input 1
                             , input substitute( "!!!Касса &1 маг&2 не ответила:&3&4 &5"
                                                   ,for-cash-desk.cash-num
                                                   ,for-cash-desk.obj-code
                                                   , {&new-line}
                                                   , error-status:get-message(1)
                                                   , return-value
                                               )
                                                               ).
                         assign
                         v-view-log = yes
                         .
                         nEXT _IBM-CASH-DESK.
                         /* продолжаем обработку других касс
                         if not g#auto then do:
                             /*в режиме автоприема чеков должны считать чего-нибудь чтое сть в директории*/
                           return "error":U.
                         end. */
                       end.
                    end.
                    else do:
                       run write-log-and-file in p-log-handle (
                               input 1
                             , input log-file-name
                             , input 1
                             , input substitute('Чтение данных с кассы &1://&2'
                                           ,entry(1, for-cash-desk.addr-path, {&delim-par})
                                           ,entry(2, for-cash-desk.addr-path, {&delim-par})
                                         )
                                                               ).
                       mWriteRespFile = replace(in_ + sav + "/" + v-xml-file-name, "/", "\" ) + ".xml_sckt".
                       run ConectSocet (entry(1,entry(2, for-cash-desk.addr-path, {&delim-par}),":"),
                                        entry(2,entry(2, for-cash-desk.addr-path, {&delim-par}),":"),
                                         "",
                                         Mreq,
                                         "xml",
                                         30,
                                         no,
                                         substitute ("Чтение данных с кассы &1. ",entry(2, for-cash-desk.addr-path, {&delim-par}))
                                         ).
                        if mWebResp eq "" 
                        then do:
                           run write-log-and-file in p-log-handle (
                               input 1
                             , input log-file-name
                             , input 1
                             , input substitute( "!!!Касса &1 маг&2 не ответила:&3&4 &5"
                                                   ,for-cash-desk.cash-num
                                                   ,for-cash-desk.obj-code
                                                   , {&new-line}
                                                   , OerrMsg
                                                   , return-value
                                               )
                                                               ).
                            assign
                            v-view-log = yes
                            .
                            nEXT _IBM-CASH-DESK.
                         end.
                         else do:
                            run write-log-and-file in p-log-handle (
                               input 1
                             , input log-file-name
                             , input 1
                             , input substitute('Время ожидания выполнения задания на кассе - &1 c',
                                           mSocetEndTime
                                         )
                                                               ).
                        end.
                        
                    end.
                  end. /*if not v-podbor then do:*/
                end. /*if for-cash-desk.autonomy = integer({&cd-self})*/
                else do:
                  RUN waitpxml in this-procedure (
                                input p-auto
                                ,input (v-xml-file-name-path + 'xml':U)
                                ,input (replace(in_ + spl + "/" + v-xml-file-name, "/", "\" ) + ".xml")
                                ,input 'Чтение данных с кассы ' + for-cash-desk.addr-path
                                ,input ' Подождите 15 сек '
                                ,input 'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!'
                                ,input 'Подождите: касса обрабатывает запрос'
                                ,input 15) NO-ERROR .
                  if error-status:error then do:
                    nEXT _IBM-CASH-DESK.
                  end.
                end.
              end.
            end. /*cd-type-ibm-xml*/
          end. /*конец блока запроса*/
        /*if p-remote = 1 - только запрос - чеки не читаем - конец работы*/
        if p-remote = 1 then do:
          return.
        end.
        if not var-found-not-remote
        then do:
        end.
        else do:
          if (cash-desk.pos-type = {&cd-type-ibm-xml}
          and cash-desk.autonomy = integer({&cd-self}))
          or (cash-desk.pos-type = {&cd-type-autotank}
             and cash-desk.autonomy = integer({&cd-manager}))
          then do:
          end.
          else do:
            run waitp in this-procedure (
                        input p-auto
                        ,input ({&delim-par} + (in_ + spl) + {&delim-par} + "fl*")
                        ,input "Прием данных с кассы"
                        ,input substitute("Подождите &1 сек",  15)
                        ,input substitute("Подождите &1 сек",  15)
                        ,input substitute("Подождите &1 сек",  15)
                        ,input 15) no-error .
          end.
        end.
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "Данные касс &1 &2&3: спул-файлы: &4, архив: &5"
                                , cash-desk.pos-type
                                , p-obj-type
                                , p-obj-code
                                , (in_ + spl)
                                , (in_ + sav))
                                          ).
        if cash-desk.pos-type = {&cd-type-ibm}
        or cash-desk.pos-type = {&cd-type-nkt-ibm}
        then do:
          /* до этого момента писали в лог-файл log-file-name, определённый как
              = (if p-auto = 0 then 'get-chkf.log' else 'extgetcd.log');
             внутри get-ibmf.p сообщения безусловно выводятся в get-chkf.log
          */
          run str/get-ibmf.p (
                         input parparentproc
                        ,input p-log-handle
                        ,input p-obj-type
                        ,input p-obj-code
                        ,input v-host-code
                        ,input cash-desk.pos-type
                        ,input in_
                        ,input spl
                        ,input (in_ + sav)
                        ,input v-spec-command
                        ,input-output v-view-log
                        ) no-error  .
          if return-value = "error":U then do:
            v-view-log = yes.
            undo, return .
          end.
          /*по жалобам МОРОЗКО подчищаем возможные необработанные файлы*/
          run str/get-ibmf.p (
                         input parparentproc
                        ,input p-log-handle
                        ,input p-obj-type
                        ,input p-obj-code
                        ,input v-host-code
                        ,input cash-desk.pos-type
                        ,input in_
                        ,input spl
                        ,input (in_ + sav)
                        ,input v-spec-command
                        ,input-output v-view-log
                        ) no-error .
          if return-value = "error":U then do:
            v-view-log = yes.
            {&view-log}.
          end.
        end.
        else do:
/* Удаляем ошибочные чеки */
          block-del:
          for each chk-doc where (chk-doc.obj-type eq p-obj-type
                             and chk-doc.obj-code eq p-obj-code
                             and chk-doc.pay-desk eq cash-desk.cash-num
                             and chk-doc.out-code  = ?)
                             or (chk-doc.obj-type eq p-obj-type
                             and chk-doc.obj-code eq p-obj-code
                             and chk-doc.pay-desk eq cash-desk.cash-num
                             and chk-doc.out-code  = ?):
             if     (chk-doc.chk-date eq v-date
                and chk-doc.chk-time  ge v-time)
                or   chk-doc.chk-date gt v-date
             then do:
                
                if chk-doc.office eq ?
                then do:
                   delete chk-doc.
                   next block-del.
                end.
                else do vi = 1 to num-entries(chk-doc.office):
                   if can-do({&chk-err-list},entry(vi,chk-doc.office))
                    
                   then do:
                      delete chk-doc.
                      next block-del.
                   end.
                end.
             end.                               
          end.                     
   
          run str/getxibmf.p (
                         input parparentproc
                        ,input p-log-handle
                        ,input p-obj-type
                        ,input p-obj-code
                        ,input v-host-code
                        ,input in_
                        ,input spl
                        ,input (in_ + sav)
                        ,input cash-desk.pos-type
                        ,input (if (cash-desk.pos-type = {&cd-type-ibm-xml}
                                and cash-desk.autonomy = integer({&cd-self}))
                                or (cash-desk.pos-type = {&cd-type-autotank}
                                and cash-desk.autonomy = integer({&cd-manager}))
                                then "utf-8":U
                                else "windows-1251")
                        ,input log-file-name
                        ,input (if mReadBuffer then "readbuffer_" else "") +  "spool":U + (if p-other <> '':U then {&delim-par} + v-spec-command else '':U)
                        ,input
                          if mReadBuffer then mWebResp else
                                (if entry(1, v-spec-command) = "version"
                                and cash-desk.pos-type = {&cd-type-ibm-xml}
                                then v-xml-file-name-path
                                else "":U) /*ждем любых файлов только при чтении версии своего единственного*/
                        ,input-output v-view-log
                        ) no-error .


          if return-value = "error":U then do:
            assign
            v-view-log = yes.
            {&view-log}.
          end.
        end.
        END . /* FOR EACH for-cash-desk NO-LOCK WHERE */
/*---------------------------------------------------------------------------------*/
        
        _ibm-cash-desk-remote:
        FOR EACH for-cash-desk NO-LOCK WHERE
                for-cash-desk.db-num = g#db-num and
                for-cash-desk.pos-type = cash-desk.pos-type AND
                for-cash-desk.obj-code = p-obj-code AND
                for-cash-desk.cash-on = yes :
          if for-cash-desk.remote = 1 then do:
            /*для удаленных касс в суффикс должна входить и соотв поддиректория in[номер магазина]-[номер кассы] */
            /*проверим наличие этой директории - если ее нет пробуем создать*/
            assign
            v-dir-remote =  v-remote + "in":U +
                            string(for-cash-desk.obj-code, "99999") + "-":U +
                          trim(string(for-cash-desk.cash-num, ">999"))
            .
            run gbl/dir-cre.p ( input v-dir-remote) no-error .
            if error-status:error then do:
              /*директории нет и не удалось создать*/
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute(
                                    "!!!Каталог &1 для отсылки запроса на удаленную кассу &2 маг&3 не найден&4" +
                                    "и/или попытка его создания не удалась:&4 &5 &6"
                                    , v-dir-remote
                                    , for-cash-desk.cash-num
                                    , p-obj-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                    )).
              assign
              v-view-log = yes.
              NEXT _ibm-cash-desk-remote.
            end.
            if cash-desk.pos-type = {&cd-type-ibm}
            or cash-desk.pos-type = {&cd-type-nkt-ibm}
            then do:
              run str/get-ibmf.p (
                            input parparentproc
                            ,input p-log-handle
                            ,input p-obj-type
                            ,input p-obj-code
                            ,input v-host-code
                            ,input cash-desk.pos-type
                            ,input v-dir-remote + {&slash-char}
                            ,input "":U
                            ,input (in_ + sav)
                            ,input v-spec-command
                            ,input-output v-view-log
                            ) no-error .
              if return-value = "error":U then do:
                v-view-log = yes.
                {&view-log}.
              end.
            end.
            else do:
              run str/getxibmf.p (
                             input parparentproc
                            ,input p-log-handle
                            ,input p-obj-type
                            ,input p-obj-code
                            ,input v-host-code
                            ,input v-dir-remote + {&slash-char}
                            ,input "":U
                            ,input (in_ + sav)
                            ,input cash-desk.pos-type
                            ,input (if (cash-desk.pos-type = {&cd-type-ibm-xml}
                                    and cash-desk.autonomy = integer({&cd-self}))
                                    or (cash-desk.pos-type = {&cd-type-autotank}
                                    and cash-desk.autonomy = integer({&cd-manager}))
                                    then "utf-8":U
                                    else "windows-1251")
                            ,input log-file-name
                            ,input "spool":U + (if p-other <> '':U then {&delim-par} + v-spec-command else '':U)
                            ,input (if entry(1, v-spec-command) = "version"
                                    and cash-desk.pos-type = {&cd-type-ibm-xml}
                                    then v-xml-file-name-path
                                    else "":U) /*ждем любых файлов только при чтении версии своего единственного*/
                            ,input-output v-view-log
                            ) no-error .
              if return-value = "error":U then do:
                v-view-log = yes.
                {&view-log}.
              end.
            end.
          end.
          else do:
            NEXT _ibm-cash-desk-remote.
          end.
        END . /* do i */
      end. /*when ibm*/
      when {&cd-type-omron} then do:
        run str/get-inis.p (
                         input p-obj-type
                       , input p-obj-code
                       , input {&cd-type-omron}
                       , input cash-desk.remote
                       , input "get":U /*некий параметр который говорит для чего нам настройки*/
                       , output out
                       , output out2
                       , output in_
                       , output spl
                       , output sav
                       , output v-remote
                       )  no-error .

        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute(
                                "!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                                , cash-desk.pos-type
                                , p-obj-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                )).
          v-view-log = yes.
          {&view-log}.
          else undo,  return .
        end.
        for each thbjattr_thbj-attr:
          delete thbjattr_thbj-attr.
        end.
        run adm/shattri.p (
            input "get":U
            ,input  p-obj-type
            ,input  p-obj-code
            ,input  {&attr-cd-type-omron}
            ,input  '':U /*p-param-code*/
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-value-logical
            ,output v-param-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error .
        IF error-status:error then do:
          assign
          v-mes =  substitute(
                                "Не удалось получить настройки для  POS типа &1 для маг&2"
                                , cash-desk.pos-type
                                , p-obj-code).
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-mes).
          v-view-log = yes.
          undo,  return error v-mes.
        end.
        for each thbjattr_thbj-attr where
                thbjattr_thbj-attr.obj-type = p-obj-type
            and thbjattr_thbj-attr.obj-code = p-obj-code
            and thbjattr_thbj-attr.upper-prop-code =  {&attr-cd-type-omron}
        on error undo, return error :
          case thbjattr_thbj-attr.prop-code :
            when {&attr-cd-type-omron_omrbase} then do:
              assign
              base-cass = thbjattr_thbj-attr.property-value-integer.
            end.
            when {&attr-cd-type-omron_omrcurl} then do:
              curr-list = thbjattr_thbj-attr.property-value-character.
            end.
            when {&attr-cd-type-omron_omrpayl} then do:
              pay-list = thbjattr_thbj-attr.property-value-character.
            end.
            when {&attr-cd-type-omron_omrnal} then do:
              nal = thbjattr_thbj-attr.property-value-integer.
            end.
            when {&attr-cd-type-omron_omrntnl} then do:
              not-nal = thbjattr_thbj-attr.property-value-integer.
            end.
          end case.
        end.
        assign
        right-curs = ( if  base-cass = 0 then yes else no ) .
        if search( out + 'spl.dat' ) = ? then do:
                  output to value( out + 'spl.dat' ) convert target "ibm866".
                  put unformatted '<' spl '>'.
                  output close.
          end.
          else do:
            v-mes = "Не могу отправить запрос на кассу" .
            run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-mes).
            v-view-log = yes.
              message v-mes.
              return error.
          end.
          FOR EACH for-cash-desk NO-LOCK WHERE
                  for-cash-desk.db-num = g#db-num and
                  for-cash-desk.pos-type = cash-desk.pos-type AND
                  for-cash-desk.obj-code = p-obj-code AND
                  for-cash-desk.cash-on  = yes:
            assign
            v-versiond = decimal(for-cash-desk.version)
            no-error .
            if error-status:error
            or v-versiond < 0 then do:
                assign
                v-mes = substitute("Неверное значение поля <ВЕРСИЯ> &1 для кассы № &2 типа &3 в справочнике касс&4" +
                            "Значение версии может быть только десятичным числом > 0"
                            ,for-cash-desk.version
                            ,for-cash-desk.cash-num
                            ,{&cd-type-omron-new}
                            ,{&new-line}
                            ).
              run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-mes).
              v-view-log = yes.
                undo,  return error v-mes.
            end.
            output to value( out + 'spl.adr' ) convert target "ibm866".
            put ' ' skip(1). /* две пустые строки */
            put unformatted '  ' for-cash-desk.addr-path ' spool' skip.
            kass-list =   kass-list + entry( 4, for-cash-desk.addr-path, '.' ) + ','.
            output close.
            RUN waitp in this-procedure (
                         input p-auto
                        ,input(out + 'spl.dat')
                        ,input ('Чтение данных с кассы ' + for-cash-desk.addr-path)
                        ,input ' Подождите 15 сек '
                        ,input 'Касса не ответила.'
                        ,input 'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!'
                        ,input 15
                        ) NO-ERROR .
           if error-stat:error then NEXT _CASH-DESK.
          END .
          run waitp in this-procedure (
                       input p-auto
                      ,input ({&delim-par} + (in_ + spl) + {&delim-par} + "fl*")
                      ,input "Прием данных с кассы"
                      ,input "Подождите 15 сек"
                      ,input "Подождите 15 сек"
                      ,input "Подождите 15 сек"
                      ,input 15
                      ) no-error .
          if error-stat:error then NEXT _CASH-DESK.
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "Данные касс &1 &2&3: спул-файлы: &4, архив: &5"
                                  , cash-desk.pos-type
                                  , p-obj-type
                                  , p-obj-code
                                  , (in_ + spl)
                                  , (in_ + spl))
                                            ).
           input stream DirStream from os-dir ( in_ + spl ) .
           REPEAT :
             import stream DirStream file path atr.
             if can-do( "f", atr ) AND substring( file, 1, 2 ) = "fl"
             AND
             can-do( kass-list, substring( file, 3, 1 ) ) then do:
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute( "Обработка спул-файла &1"
                                      , path
                                    )
                                                ).
              DO trans :
                  if right-curs then
                  run str/get-omrn.p (
                                  input parparentproc
                                , input p-log-handle
                                , input p-obj-type
                                , input p-obj-code
                                , input v-host-code
                                , input for-cash-desk.version
                                , input path
                                ,input-output v-view-log
                                ) no-error .
                  else
                  run str/get-omr.p (
                                input parparentproc
                                , input p-log-handle
                                , input p-obj-type
                                , input p-obj-code
                                , input v-host-code
                                , input path
                                , input-output v-view-log
                                ) no-error .
              END .
            end.
          END .
          input stream DirStream close.
        end. /* IF OMRON */
        when {&cd-type-omron-new} then  do:
          for each thbjattr_thbj-attr:
            delete thbjattr_thbj-attr.
          end.
          run adm/shattri.p (
              input "get":U
              ,input  p-obj-type
              ,input  p-obj-code
              ,input  {&attr-cd-type-omron-new}
              ,input  '':U /*p-param-code*/
              ,output v-value-character
              ,output v-value-date
              ,output v-value-decimal
              ,output v-value-integer
              ,output v-value-logical
              ,output v-param-type
              ,INPUT-OUTPUT table-handle v-tth
              ) no-error .
          IF error-status:error then do:
            assign
            v-mes =  substitute(
                                  "Не удалось получить настройки для  POS типа &1 для маг&2"
                                  , cash-desk.pos-type
                                  , p-obj-code).
              run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-mes).
              v-view-log = yes.
            undo,  return error v-mes.
          end.
          for each thbjattr_thbj-attr where
                  thbjattr_thbj-attr.obj-type = p-obj-type
              and thbjattr_thbj-attr.obj-code = p-obj-code
              and thbjattr_thbj-attr.upper-prop-code =  {&attr-cd-type-omron-new}
          on error undo, return error :
            case thbjattr_thbj-attr.prop-code :
              when {&attr-cd-type-omron-new_omrnbase} then do:
                assign
                base-cass = thbjattr_thbj-attr.property-value-integer.
              end.
              when {&attr-cd-type-omron-new_omrncurl} then do:
                curr-list = thbjattr_thbj-attr.property-value-character.
              end.
              when {&attr-cd-type-omron-new_omrnpayl} then do:
                pay-list = thbjattr_thbj-attr.property-value-character.
              end.
              when {&attr-cd-type-omron-new_omrnnal} then do:
                nal = thbjattr_thbj-attr.property-value-integer.
              end.
              when {&attr-cd-type-omron-new_omrnntnl} then do:
                not-nal = thbjattr_thbj-attr.property-value-integer.
              end.
            end case.
          end.
          _omron-cash-desk:
          FOR EACH for-cash-desk NO-LOCK WHERE
                    for-cash-desk.db-num = g#db-num and
                    for-cash-desk.pos-type = cash-desk.pos-type AND
                    for-cash-desk.obj-code = p-obj-code AND
                    for-cash-desk.cash-on = yes:
               out = for-cash-desk.addr-path + "out\".
               output to value( out  + 'spool.adr' ) convert target "ibm866".
               output close.
               RUN waitp in this-procedure (
                           input p-auto
                          ,input (out + 'spool.adr')
                          ,input ('Чтение данных с кассы ' + out)
                          ,input ' Подождите 15 сек '
                          ,input 'Касса не ответила.'
                          ,input 'Касса не ответила. Если Вы уверены, что с ней нет связи нажмите кнопку!'
                          ,input 15) NO-ERROR .
               if error-status:error then  NEXT _OMRON-CASH-DESK.
          END . /* for each for-cash-desk */
          run waitp in this-procedure (
                          input p-auto
                         ,input ({&delim-par} + in_ + {&delim-par} + "*")
                         ,input "Прием данных с кассы"
                         ,input "Подождите 15 сек"
                         ,input "Подождите 15 сек"
                         ,input "Подождите 15 сек"
                         ,input 15) no-error .
          if error-status:error then.
          FOR EACH for-cash-desk NO-LOCK WHERE
                  for-cash-desk.db-num = g#db-num and
                  for-cash-desk.pos-type = cash-desk.pos-type AND
                  for-cash-desk.obj-code = p-obj-code AND
                  for-cash-desk.cash-on = yes:
            in_ = for-cash-desk.addr-path + "in\".
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "Чеки касс &1 &2&3: спул-файлы: &4, архив: &5"
                                    , cash-desk.pos-type
                                    , p-obj-type
                                    , p-obj-code
                                    , in_
                                    , (in_ + "\sav\":U))
                                              ).
            input stream DirStream from os-dir (in_).
            REPEAT :
                import stream DirStream file path atr.
                if can-do( "f", atr ) then do:
                    run write-log-and-file in p-log-handle (
                          input 1
                        , input log-file-name
                        , input 1
                        , input substitute( "Обработка спул-файла &1"
                                            , path
                                          )
                                                      ).
                    DO trans:
                        run str/get-omrn.p (
                                        input parparentproc
                                      , input p-log-handle
                                      , input p-obj-type
                                      , input p-obj-code
                                      , input v-host-code
                                      , input for-cash-desk.version
                                      , input path
                                      ,input-output v-view-log
                                      ) no-error .
                    END .
                end.
             END .
             input stream DirStream close.
          END . /* FOR EACH for-cash-desk */
        end.        /* OMRON NEW  */
        when {&cd-type-ipc-servispl} then do:
          /*найдем код платежа наличными из параметров системы для кассы IPC*/
          for each thbjattr_thbj-attr:
            delete thbjattr_thbj-attr.
          end.
          run adm/shattri.p (
              input "get":U
              ,input  p-obj-type
              ,input  p-obj-code
              ,input  {&attr-cd-type-ipc-servispl}
              ,input  '':U /*p-param-code*/
              ,output v-value-character
              ,output v-value-date
              ,output v-value-decimal
              ,output v-value-integer
              ,output v-value-logical
              ,output v-param-type
              ,INPUT-OUTPUT table-handle v-tth
              ) no-error .
          IF error-status:error then do:
            assign
            v-mes =  substitute(
                                  "Не удалось получить настройки для  POS типа &1 для маг&2"
                                  , cash-desk.pos-type
                                  , p-obj-code).
              run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-mes).
              v-view-log = yes.
            undo,  return error v-mes.
          end.
          for each thbjattr_thbj-attr where
                  thbjattr_thbj-attr.obj-type = p-obj-type
              and thbjattr_thbj-attr.obj-code = p-obj-code
              and thbjattr_thbj-attr.upper-prop-code =  {&attr-cd-type-ipc-servispl}
          on error undo, return error :
            case thbjattr_thbj-attr.prop-code :
              when {&attr-cd-type-ipc-servispl_ipcspayn} then do:
                assign
                pay-nal = thbjattr_thbj-attr.property-value-integer.
              end.
              when {&attr-cd-type-ipc-servispl_ipcsbasc} then do:
                 base-cass = thbjattr_thbj-attr.property-value-integer.
              end.
              when {&attr-cd-type-ipc-servispl_ipcsccrd} then do:
                cass-card = thbjattr_thbj-attr.property-value-character.
              end.
              when {&attr-cd-type-ipc-servispl_ipcstcrd} then do:
                trade-card = thbjattr_thbj-attr.property-value-character.
              end.
              when {&attr-cd-type-ipc-servispl_ipcscurc} then do:
                curr-card = thbjattr_thbj-attr.property-value-character.
              end.
            end case.
          end.
          cycle = no.
          FOR EACH for-cash-desk NO-LOCK WHERE
                for-cash-desk.db-num = g#db-num and
                for-cash-desk.pos-type = cash-desk.pos-type AND
                for-cash-desk.obj-code = p-obj-code AND
                for-cash-desk.cash-on = yes:
            DO jj = 1 TO 2 :
              if jj = 1
              then in_ = for-cash-desk.addr-path + "out\tmp" .
              else do:
                  FOR EACH chk_doc :
                      delete chk_doc.
                  END .
                  in_ = for-cash-desk.addr-path + "out".
              end.
              run write-log-and-file in p-log-handle (
                    input 1
                  , input log-file-name
                  , input 1
                  , input substitute( "Чеки касс &1 &2&3: спул-файлы: &4, архив: &5"
                                      , cash-desk.pos-type
                                      , p-obj-type
                                      , p-obj-code
                                      , in_
                                      , in_
                                                )).
              input stream DirStream from os-dir (in_).
              REPEAT :
                import stream DirStream file path atr.
                if can-do( "f", atr ) then  do:
                  if num-entries(file, ".") < 2 THEN NEXT.
                  IF NOT can-do("del,dat,ret":U, entry(2, file, ".")) then NEXT.
                  if entry(1, file, ".") = "cashdcrd" or
                      entry(1, file, ".") = "cashcmnt" then NEXT.
                  if jj = 2 AND  entry(1, file, ".") <> "cashsail":U then  NEXT .
                  run write-log-and-file in p-log-handle (
                        input 1
                      , input log-file-name
                      , input 1
                      , input substitute( "Обработка спул-файла &1"
                                          , path
                                        )
                                                    ).
                  DO TRANS :
                    run str/get-ipcs.p (
                                input parparentproc
                              , input p-log-handle
                              , input p-obj-type
                              , input p-obj-code
                              , input v-host-code
                              , in_
                              , input path
                              , input file
                              , input-output v-view-log
                              ) no-error .

                  END .
                end.
              END .
              input stream DirStream close.
            END .   /* DO jj = 1 TO 2 : */
          END . /* FOR EACH for-cash-desk */
        end. /*when ipc-servis+*/
      when {&cd-type-ncr-gm}
      or when {&cd-type-ncr-As-R}
      then  do:
        run str/get-inis.p (
                         input p-obj-type
                       , input p-obj-code
                       , input cash-desk.pos-type
                       , input cash-desk.remote
                       , input "get":U /*некий параметр который говорит для чего нам настройки*/
                       , output out
                       , output out2
                       , output in_
                       , output spl
                       , output sav
                       , output yestr
                       )  no-error .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute(
                                "!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                                , cash-desk.pos-type
                                , p-obj-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                )).
            v-view-log = yes.
            undo, return.
        end.
        /*если директория есть и есть файл то считаем его */
        if yestr <> ? and search( yestr + 'hocidc.001' ) <> ? then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "Чеки касс &1 &2&3: спул-файлы: &4, архив: &5"
                                  , cash-desk.pos-type
                                  , p-obj-type
                                  , p-obj-code
                                  , yestr
                                  , (in_ + sav + "\"))
                                            ).
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "Обработка спул-файла &1"
                                  , (yestr + "HOCIDC.001":U)
                                )
                                            ).
          run str/get-ncr.p (
                        input parparentproc
                      , input p-log-handle
                      , input p-obj-type
                      , input p-obj-code
                      , input v-host-code
                      , input cash-desk.pos-type
                      , input cash-desk.version
                      , input (yestr + "HOCIDC.001":U)
                      , input-output v-view-log
                      ) no-error .

          os-append
          value( yestr + "HOCIDC.001":U )
          value( in_ + sav + "\" + string( day( today ), "99" ) + "_" +
          string( month( today ), "99" ) + "_" +
          string( year( today ) modulo 100, "99" ) + ".spl" ) .
          os-delete value( yestr + "HOCIDC.001":U ) .
          next _cash-desk.
        end.
        /*пошлем запрос на сервер*/
        if search( out + 'spl.dat' ) = ? then  do:
          output to value( out + 'spl.da0' ) convert target "ibm866".
          put unformatted '<' spl '>'.
          output close.
        end.
        else do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute(
                                "!!!Не могу отправить запрос на сервер NCR маг&1" +
                                "Возможно, в каталоге &2&3" +
                                "остался файл spl.dat&3" +
                                "предыдущего недошедшего до кассы запроса - УДАЛЯЕТСЯ..."
                                , p-obj-code
                                , out
                                , {&new-line}
                                )).
          assign
          v-view-log = yes.
          OS-DELETE value( out + 'spl.da0' ) .
          OS-DELETE value( out + 'spl.dat' ) .
          output to value( out + 'spl.da0' ) convert target "ibm866".
          put unformatted '<' spl '>'.
          output close.
        end.
        OS-RENAME VALUE(out + 'spl.da0') VALUE(out + 'spl.dat').
        os-er = OS-ERROR.
        if os-er <> 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute(
                                "!!!Ошибки при записи файлов запроса на маг&1 по адресу &2&3" +
                                "Ошибки в работе локальной сети или нарушение прав доступа!"
                                , p-obj-code
                                , (out + 'spl.dat')
                                , {&new-line}
                                )).
          v-view-log = yes.
          undo, return.
        end.
        RUN waitp in this-procedure (
             input p-auto
            ,input (out + 'spl.dat')
            ,input 'Чтение данных с сервера NCR'
            ,input ' Подождите 15 сек '
            ,input 'Сервер не ответил.'
            ,input 'Сервер не ответил. Если Вы уверены, что с сервером нет связи нажмите кнопку!'
            ,input 15)
            NO-ERROR .
        if error-status:error then do:
          next _cash-desk.
        end.
        run waitp in this-procedure (
                     input p-auto
                    ,input ({&delim-par} + IN_ + SPL + {&delim-par} + (if spl = "":U then "":U else "\":U) + "HOCIDC.001":U)
                    ,input "Прием данных с кассы"
                    ,input "Подождите 20 сек"
                    ,input "Подождите 20 сек"
                    ,input "Подождите 20 сек"
                    ,input 20
                    ) no-error .
        if error-status:error then  NEXT _cASH-DESK.
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "Чеки касс &1 &2&3: спул-файлы: &4, архив: &5"
                                , cash-desk.pos-type
                                , p-obj-type
                                , p-obj-code
                                , (IN_ + SPL + (if spl = "":U then "":U else "\":U))
                                , (in_ + sav + "\"))
                                          ).
        if search( IN_ + SPL + (if spl = "":U then "":U else "\":U) + "HOCIDC.001":U ) = ? then NEXT _cash-desk.
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "Обработка спул-файла &1"
                                  , (IN_ + SPL + (if spl = "":U then "":U else "\":U) + "HOCIDC.001":U)
                                )
                                            ).
        run str/get-ncr.p (
                       input parparentproc
                      , input p-log-handle
                      , input p-obj-type
                      , input p-obj-code
                      , input v-host-code
                      , input cash-desk.pos-type
                      , input cash-desk.version
                      , input (IN_ + SPL + (if spl = "":U then "":U else "\":U) + "HOCIDC.001":U)
                      , input-output v-view-log
                      ) no-error .
        os-append
        value( IN_ + SPL + (if spl = "":U then "":U else "\":U) + "HOCIDC.001":U )
        value( in_ + sav + (if sav = "":U then "":U else "\":U) + string( day( today ), "99" ) + "_" +
        string( month( today ), "99" ) + "_" +
        string( year( today ) modulo 100, "99" ) + ".spl" ) .
        os-delete value( IN_ + SPL + (if spl = "":U then "":U else "\":U) + "HOCIDC.001":U ) .
      end. /*when ncr-gm*/
      when {&cd-type-r-keeper}
      then  do:
        run str/get-inis.p (
                         input p-obj-type
                       , input p-obj-code
                       , input cash-desk.pos-type
                       , input cash-desk.remote
                       , input "get":U /*некий параметр который говорит для чего нам настройки*/
                       , output out
                       , output out2
                       , output in_
                       , output spl
                       , output sav
                       , output yestr
                       )  no-error .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute(
                                "!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                                , cash-desk.pos-type
                                , p-obj-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                )).
            v-view-log = yes.
            undo, return.
        end.
        run str/get-rkpf.p (
                        input parparentproc
                      ,input p-log-handle
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input v-host-code
                      ,input in_
                      ,input spl
                      ,input (in_ + sav)
                      ,input cash-desk.pos-type
                      ,input log-file-name
                      ,input-output v-view-log
                      ) no-error .
      end. /*when r-keeper*/
      when {&cd-type-maria} then do:
        /*
        { gbl/objat.i
          p-obj-type
          p-obj-code
          "'shift-on=request'"
          l-shift-on
        }
        if not l-shift-on then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute("!!!Внимание! Для работы с кассой типа &1 требуется использование смен, а настройка СМЕНЫ НА ОБЪЕКТЕ выключена - это недопустимо."
                                , cash-desk.pos-type
                                  )).
          assign
          v-view-log = yes
          .
          else undo, return "error":U.
        end. /*if not l-shift-on then do:*/
        { gbl/curshift.i p-obj-type p-obj-code v-shift-date v-shift-num no-error}
        if error-status:error then do:
          if p-shft-close <> - 1 /*тогда это открытие*/ then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute("!!!Ошибка при получении номера открытой смены на &1&2:&3&4 &5"
                                  , p-obj-type
                                  , p-obj-code
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                    )).
            assign
            v-view-log = yes
            .
            else undo, return "error":U.
          end. /*if p-shft-close <> - 1 /*тогда это открытие*/ then do:*/
          else do:
            assign
            v-shift-num = integer(entry(6, p-parameter, {&delim-par}))
            v-shift-date-chr = entry(7, p-parameter, {&delim-par})
            .
          end.
        end. /*do:*/
        */
        define variable loc-is-ptrl as logical no-undo .
        { gbl/conf-rd.i
        "'is-ptrl'"
        0
        "''":U
        0
        "''":U
        "''":U
        "''":U
        NO
        conf-par
        par-type
        NO-ERROR
        }
        assign
        loc-is-ptrl = logical(conf-par) no-error .

        run str/get-inis.p (
                          input p-obj-type
                        , input p-obj-code
                        , input cash-desk.pos-type
                        , input cash-desk.remote
                        , input "get":U /*некий параметр который говорит для чего нам настройки*/
                        , output out
                        , output out2
                        , output in_
                        , output spl
                        , output sav
                        , output v-remote
                        )  no-error .
        if error-status:error then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute(
                                "!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                                , cash-desk.pos-type
                                , p-obj-code
                                , {&new-line}
                                , error-status:get-message(1)
                                , return-value
                                )).
          v-view-log = yes.
          undo, return "error".
        end.
        /*чтобы получить файлы с МАРИИ надо записать файлы заданий в директорию out*/
        _maria-cash-desk:
        FOR EACH for-cash-desk NO-LOCK WHERE
                for-cash-desk.db-num = g#db-num and
                for-cash-desk.pos-type = cash-desk.pos-type AND
                for-cash-desk.obj-code = p-obj-code AND
                for-cash-desk.cash-on = yes :
          if for-cash-desk.autonomy = integer({&cd-manager}) then next _maria-cash-desk.

          file = substring( string( next-value( s-spool, {&db-name_schema} ), '99999999999999999999'), 13, 8 ).
          if v-spec-command <> '':U then do:
            do ii = 1 to num-entries(v-spec-command, ';'):
              v-entry = entry(ii, v-spec-command, ';') .
              if v-entry begins 'Report' then do:
                do jj = 1 to num-entries(left-trim(v-entry, 'report')):
                  run maria-get in this-procedure (
                                                  buffer for-cash-desk
                                                , input in_ + spl + {&slash-char}
                                                , input 'fl' + file
                                                , input no /*by-record*/
                                                , input integer(entry(jj, left-trim(v-entry, 'report')))
                                                , input 0
                                                , input 0 /*кол-во записей которые хотим получить 0 - max на самом деле 5000*/
                                                , input ? /*p-min-plu*/
                                                , input ? /*p-max-plu*/
                                                , input ? /*p-other*/
                                                , input jj
                                                      ).

                end.
              end. /**if v-entry begins 'Report' then do*/
            end. /*            do ii = 1 to num-entries(v-spec-command, ';'):*/
          end. /*if v-spec-command <> '':U then do:*/
          else do:
             define variable v-character as character no-undo.
             define variable v-attr-date as date      no-undo.
             define variable v-decimal   as decimal   no-undo.
             define variable v-integer   as integer   no-undo.
             define variable v-logical   as logical   no-undo.
             v-character = ''.
             run cd-attr-value in this-procedure (
                                                 input for-cash-desk.db-num
                                                ,input for-cash-desk.obj-code
                                                ,input {&cd-type-maria}
                                                ,input for-cash-desk.cash-num
                                                ,input {&cda-maria_operative}
                                                ,input {&cda-maria_operative_last-check-maria}
                                                ,output v-character
                                                ,output v-attr-date
                                                ,output v-decimal
                                                ,output v-integer
                                                ,output v-logical
                                                ,output v-attr-type     ) no-error.
            do shift-maria = (if entry(1, for-cash-desk.addr-path, {&delim-par}) = 'ftp' then 2 else 1) to 2:
              if shift-maria = 1 then do:
                 assign
                 v-p-spl = {&spool-petrol-prev}
                 v-spl-doc = {&spool-goods-doc-prev}
                 v-spl = {&spool-goods-prev}
                 .
              end.
              if shift-maria = 2 then do:
                 assign
                 v-p-spl = {&spool-petrol-current}
                 v-spl-doc = {&spool-goods-doc-current}
                 v-spl = {&spool-goods-current}
                 .
              end.
              if loc-is-ptrl then do:
                do ii = 1 to num-entries(v-p-spl):
                  imaria = imaria + 1.
                  run maria-get in this-procedure (
                                                  buffer for-cash-desk
                                                , input in_ + spl + {&slash-char}
                                                , input 'fl' + file
                                                , input yes /*by-record*/
                                                , input integer(entry(ii, v-p-spl))
                                                , input 17
                                                , input 0 /*кол-во записей которые хотим получить 0 - max 1на самом деле 489 в */
                                                , input ? /*p-min-plu*/
                                                , input ? /*p-max-plu*/
                                                , input v-character
                                                , input imaria
                                                      ).
                end.

              end. /*if loc-is-ptrl then do:*/
              do jj = 1 to num-entries(v-spl):
                imaria = imaria + 1.
                run maria-get in this-procedure (
                                                buffer for-cash-desk
                                              , input in_ + spl + {&slash-char}
                                              , input 'fl' + file
                                              , input yes /*by-record*/
                                              , input integer(entry(jj, v-spl-doc))
                                              , input 11
                                              , input 0 /*кол-во записей которые хотим получить 0 - max на самом деле 5000*/
                                              , input ? /*p-min-plu*/
                                              , input ? /*p-max-plu*/
                                              , input v-character
                                              , input imaria
                                                    ).
                imaria = imaria + 1.
                run maria-get in this-procedure (
                                                buffer for-cash-desk
                                              , input in_ + spl + {&slash-char}
                                              , input 'fl' + file
                                              , input yes /*by-record*/
                                              , input integer(entry(jj, v-spl))
                                              , input 7
                                              , input 0 /*кол-во записей которые хотим получить 0 - max на самом деле 5000*/
                                              , input ? /*p-min-plu*/
                                              , input ? /*p-max-plu*/
                                              , input v-character
                                              , input imaria
                                                    ).
              end. /*do jj = 1 to num-entries(v-spl):*/
            end. /*обычный прием*/
          end. /*do shift-maria*/
        end. /*for each for-cash-desk*/
        output stream DIrstream to VALUE(in_ + spl + {&slash-char} + file + '.tsk').
        /*output stream DIrstream to VALUE(out + {&slash-char} + file + '.tsk').*/
        v-is-script = no.
        for each temp-tekka-tsk
        by temp-tekka-tsk.order-num
        :
          if temp-tekka-tsk.task-num = 'fl' + file then do:
            export stream DIrStream temp-tekka-tsk.
            if temp-tekka-tsk.is-script = yes then do:
              v-is-script = yes.
            end.
          end.
          delete temp-tekka-tsk.
        end.
        output stream Dirstream close.
        run str/runtekka.p (
                            input parparentproc
                            ,input p-parent-handle
                            ,input p-log-handle
                            ,input out                         /*директория где лежат файлы bat*/
                            ,input (in_ + spl + {&slash-char}) /*директория где лежат файлы объектов*/
                            ,input file
                            ,input v-remote /*директория работы с Addin.exe*/
                            ,input v-is-script
                            ) no-error .
        if error-status:error
        or return-value = "error" then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Касса &1 маг&2 не ответила:&3&4 &5"
                                    , cash-desk.pos-type
                                    , cash-desk.obj-code
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value
                                )
                                                ).
          assign
          v-view-log = yes
          .
          return "error":U.
        end. /*error-status-error*/
        run str/get-ibmf.p (
                       input parparentproc
                      ,input p-log-handle
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input v-host-code
                      ,input cash-desk.pos-type
                      ,input in_
                      ,input spl
                      ,input (in_ + sav)
                      ,input v-spec-command
                      ,input-output v-view-log
                      ) no-error  .
        if return-value = "error":U then do:
          v-view-log = yes.
          undo, return .
        end.
      end. /*maria*/
    END CASE .
  END. /*First-of cash-desk.pos-type*/
END.


run str/get-ffd.p(parparentproc,
                        p-parent-handle,
                        p-log-handle,
                        log-file-name,
                        p-obj-type,
                        p-obj-code,
                        output v-value-logical) no-error.
if error-status:error then do:
   run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input return-value).

end.

{str/proc-exp-1s.i} 
run proc-exp-1s in this-procedure  no-error.

run write-log-and-file in p-log-handle (
      input 1
    , input log-file-name
    , input 1
    , input substitute( "Обработка спул-файлов завершена, всего с касс принято &1 чеков/записей"
                        , lll
                      )
                                  ).

define variable v-process-sale as logical no-undo .
run adm/shattri.p (
    input "get":U
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  {&attr-cd-sending}
    ,input  {&attr-cd-sending_process-sale} /*p-param-code*/
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-process-sale
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .

if v-process-sale then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "Согласно настроечным параметрам подкачиваем чеки в продажу и резервируем!!!"
                        )
                                    ).
  run str/afgetchk.p (
                        input parparentproc
                       ,input p-parent-handle
                       ,input p-log-handle
                       ,input (p-obj-type + {&delim-par}  + string(p-obj-code) + {&delim-par} + '')
                       ) no-error.
end.


catch exAppErrors as class Progress.Lang.AppError :
  v-disp-msg = exAppErrors:ReturnValue .
  if v-disp-msg > "" then . else do :
    v-disp-msg = exAppErrors:GetMessage(1) .
    if v-disp-msg > "" then . else v-disp-msg = "Ошибка A-chkf" .
  end .
  run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-disp-msg
  ).
  v-view-log = yes .
end catch .
catch exProErrors as class Progress.Lang.ProError :
  v-disp-msg = exAppErrors:GetMessage(1) .
  if v-disp-msg > "" then . else v-disp-msg = "Ошибка P-chkf" .
  run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-disp-msg
  ).
  v-view-log = yes .
end catch .
catch exAnyErrors as class Progress.Lang.Error:
  v-disp-msg = "Ошибка U-chkf" .
  run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input v-disp-msg
  ).
  v-view-log = yes .
end catch .
finally :
  /* 28/II-2018 не используется:
&scop view-log   if p-auto = 0 then do: ~
                   ~{ str/cdviewlg.i   ~
                    "substitute('!!!При приеме информации с касс &1&2 произошли ошибки!!!'  ~
                                 ,p-obj-type                                                ~
                                 ,p-obj-code)"                                               ~
                    "'get-chkf.log'" ~}   ~
                    return "error":U. ~
                 end
  */
  define variable v-save-file-name as character no-undo .
  
  v-save-file-name = substitute("&1get-cd.log", ibs.th.gbl.gbl-inipar:logDir) .
  
  if v-view-log and p-auto = 0 then do:
    message
  "!!!При получении данных с касс произвошли ошибки!!!" skip
  "По завершении сообщения об ошибках будут сохранены в файле" skip
    v-save-file-name  
    view-as alert-box error .
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  run gbl/prnfilen.w
    (input  "Ошибки, возникшие при получении данных с касс"
    ,input  0
    ,input  "./get-chkf.log":U
    ,input  7
    ,output v-user-action
    ,output v-printed
    ) .

  end.
  
    run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("&1", {&new-line})
    ).
  OS-APPEND value(log-file-name) value(v-save-file-name).
  OS-DELETE value(log-file-name).
  /* если log-file-name писал в extgetcd.log - то отдельно
     надо добавить get-chkf.log, в который писали вложенные процессы */
  if index (log-file-name, "get-chkf.log") > 0 then . else do:
    OS-APPEND value("get-chkf.log") value(v-save-file-name).
    OS-DELETE value("get-chkf.log").
  end.
end finally .
