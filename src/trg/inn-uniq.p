block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Запись И_Н_Н в БД

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/22/06
Author: Bakhtadze Natalya
Creation date: 03/22/06

*/

define input-output parameter p-inn as character no-undo .
define input parameter p-old-inn as character no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-silent as logical no-undo .
define input parameter p-recid as recid no-undo .
define input parameter p-buf-handle as handle no-undo .
define output parameter p-inn-uniq-error as logical no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Запись И_Н_Н в БД".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ gbl/key-rec.i }
{ ref/extclass.i }

define variable conf-par as character no-undo .
define variable par-type as character no-undo .
define variable inn-uniq as integer no-undo .
define variable glog as logical no-undo .
define variable v-err-mess as character no-undo .
define variable bpr_lprocessedok as logical no-undo .
define variable v-new-inn as character no-undo .
define variable v-obj-type as character no-undo .
define variable v-obj-code as integer no-undo .
define variable v-our-key-rec as character no-undo .
define variable v-firm-our-key-rec as character no-undo .
define variable v-person-our-key-rec as character no-undo .
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .

define buffer another_firm for ub.firm.
define buffer another_person for ub.person.
define buffer buf_ext-classif for ub.ext-classif.
define buffer buf2_ext-classif for ub.ext-classif.
define buffer buf_firm for ub.firm.
define buffer buf_person for ub.person.
define temp-table temp-clients  no-undo
like ub.clients.
define buffer buf_batchprocess for ub.batchprocess.
&scop btpr-table buf_batchprocess

{ gbl/waitfram.i }

main-block:
do
on error undo, return error return-value
:
  if p-inn = '':U
  and p-old-inn = '':U then return .
  assign
  v-new-inn = p-inn.
  run adm/shattri.p (
        input "get":U
      ,input  '':U
      ,input  0
      ,input  {&attr-cli-all}
      ,input  {&attr-cli-all_inn-uniq} /*p-param-code*/
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output inn-uniq
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .

  delete object v-tth.
  /*проверка на уникальность*/
  if inn-uniq = 99 and v-new-inn <> '' then return "".
  if inn-uniq = 2
  or v-new-inn = ''
  then do:
    create temp-clients.
    assign
    temp-clients.obj-type = (if p-buf-handle:table = {&table_clients}
                             then p-buf-handle::obj-type
                             else (if p-buf-handle:table = {&table_firm}
                                   then {&cmp}
                                   else {&prs})
                            )
    temp-clients.obj-code =  (if p-buf-handle:table = {&table_clients}
                             then p-buf-handle::obj-code
                             else (if p-buf-handle:table = {&table_firm}
                                   then p-buf-handle::firm-code
                                   else p-buf-handle::psn-code)
                            )
    .
    if p-buf-handle:table = {&table_firm} then
    run gen-key-rec in this-procedure (
                                        input  ({&table_firm})
                                        ,input  p-buf-handle
                                        ,output v-firm-our-key-rec ).

    if p-buf-handle:table = {&table_person} then
    run gen-key-rec in this-procedure (
                                        input  ({&table_person})
                                        ,input  p-buf-handle
                                        ,output v-person-our-key-rec ).

    run gen-key-rec in this-procedure (
                                        input  ({&table_clients})
                                        ,input  (buffer temp-clients:handle)
                                        ,output v-our-key-rec ).

    if v-new-inn <> '':u then do:
      find first buf_ext-classif where
              buf_ext-classif.classif-subject = {&table_clients}
          and buf_ext-classif.classif-name = {&extclass_clients_inn}
          and buf_ext-classif.charkey_one  = v-new-inn
          and buf_ext-classif.db-num  = -1
          no-error.
      if available buf_ext-classif then do:
        if buf_ext-classif.uniq-key-rec = v-our-key-rec
        or (temp-clients.obj-type = {&cmp} and buf_ext-classif.uniq-key-rec = v-firm-our-key-rec)
        or (temp-clients.obj-type = {&prs} and buf_ext-classif.uniq-key-rec = v-person-our-key-rec)
        then do:
          return.
        end.
        else do:
          define variable v-field-list as character no-undo .
          define variable v-value-list as character no-undo .
          run gen-key-fv in this-procedure ( input buf_ext-classif.uniq-key-rec
                                            ,output v-field-list
                                            ,output v-value-list
                                            ).
          if entry(1, buf_ext-classif.uniq-key-rec, {&delim-key}) = {&table_clients} then do:
            assign
            v-obj-type = entry(2, buf_ext-classif.uniq-key-rec, {&delim-key})
            v-obj-code = integer(entry(3, buf_ext-classif.uniq-key-rec, {&delim-key}))
            .
          end.
          else do:
            assign
            v-obj-type = (if entry(1, buf_ext-classif.uniq-key-rec, {&delim-key}) = {&table_firm} then {&cmp} else {&prs})
            v-obj-code = integer(entry(lookup((if v-obj-type = {&prs}
                                                then "obj-code"
                                                else "firm-code")
                                              , v-field-list
                                              , {&delim-key})
                                        , v-value-list, {&delim-key})).
          end.
          if g#news then do:
            /*запишем в batch факт появления коллизии - новости не останавливаем - */
            /*если мы в УБД - новости пришли из ГБД - провалимся дальше и запишем И_Н_Н на клиента который в ГБД*/
            /*если мы в ГБД - И_Н_Н на клиента пришедшего из УБД записывать не будем*/
            /*в обоих случаях надо зарегистрировать коллизию*/
            if g#db-num = 0 then do:
              p-inn = v-new-inn + {&question-mark}.
              /*в главной БД приняли данные из УБД - неправильный И_Н_Н у клиента который пришел по новостям*/
              /*в rcs не пишем*/
              /*сделать пометку что в firm или person для p-obj-code inn неправильный*/
            end.
            if g#db-num <> 0 then do:
              /*в удаленной БД приняли данные из ГБД - неправильный И_Н_Н у клиента который лежит в записи ext-classif*/
              /*надо создать запись ext-classif для p-obj-type p-obj-code */
              /*и сделать пометку что в firm или person для ext-classif.obj-code inn неправильный*/
              if v-obj-type = {&cmp} then do:
                find first buf_firm no-lock where
                          buf_firm.firm-code = v-obj-code.
              end.
              else do:
                find first buf_person no-lock where
                          buf_person.psn-code = v-obj-code .
              end.
            end.
            run trg/nu_coll.p (
                             input buf_ext-classif.uniq-key-rec
                            ,input {&nws-coll_inn-uniq}
                            ,input v-new-inn
                            ,input g#news-source-db
                            ,input 1
                            ).
          end.
          else do:
            /*не новости*/
            assign
            v-err-mess = substitute("Уже есть контрагент с {&abbr_inn_allshift} &1: &2&3&4" +
                                    "Согласно настройкам в Вашей системе НЕ ДОЛЖНО БЫТЬ ДВУХ КОНТРАГЕНТОВ с одинаковым {&abbr_inn_allshift}"
                                  , v-new-inn
                                  , v-obj-type
                                  , v-obj-code
                                  , {&new-line}
                                  ).
            p-inn-uniq-error = yes.
            return v-err-mess.
          end.
        end.
      end.
      if not available buf_ext-classif
      then do:
        find first buf_ext-classif where
                  buf_ext-classif.classif-name = {&extclass_clients_inn}
             and  buf_ext-classif.uniq-key-rec = v-our-key-rec
             and  buf_ext-classif.db-num = -1
             no-error .
        if not available buf_ext-classif then do:
          create buf_ext-classif.
          assign
          buf_ext-classif.uniq-key-rec = v-our-key-rec
          buf_ext-classif.classif-subject = {&table_clients}
          buf_ext-classif.classif-name = {&extclass_clients_inn}
          buf_ext-classif.db-num = -1
          .
        end.
        assign
        buf_ext-classif.charkey_one = v-new-inn
        .
      end.
      else do:
        if g#news
        and g#db-num <> 0 then do:
          find first buf2_ext-classif exclusive-lock where
                    buf2_ext-classif.classif-name = {&extclass_clients_inn}
                 and buf2_ext-classif.charkey_one = p-old-inn
                 and buf2_ext-classif.db-num = -1   no-wait no-error.
          if locked buf2_ext-classif then do:
            undo, return error substitute("Ошибка при обновлении уникального {&abbr_inn_allshift}:&1&2&1&3"
                                          ,{&new-line}
                                          , error-status:get-message(1)
                                          , return-value ).
          end.
          if available buf2_ext-classif then do:
              if buf2_ext-classif.uniq-key-rec = v-our-key-rec  then do:
                delete buf2_ext-classif.
              end.
          end.
          for each buf2_ext-classif where
                  buf2_ext-classif.classif-subject = {&table_clients}
              and buf2_ext-classif.classif-name = {&extclass_clients_inn}
              and buf2_ext-classif.uniq-key-rec = v-our-key-rec
              and buf2_ext-classif.db-num = -1
          on error undo, return error substitute("&1&2&3Ошибка при удалении записи {&abbr_inn_allshift} для &4&5:&2&6"
                                               , vss-workfile
                                               , vss-revision
                                               , {&new-line}
                                               , p-obj-type
                                               , p-obj-code
                                               , error-status:get-message(1)
                                                 )
          on stop undo, return error substitute("&1&2Занята запись {&abbr_inn_allshift} для &3&4"
                                               , vss-workfile
                                               , {&new-line}
                                               , p-obj-type
                                               , p-obj-code):
            delete buf2_ext-classif.
          end.
          assign
          buf_ext-classif.classif-name = {&extclass_clients_inn}
          buf_ext-classif.uniq-key-rec = v-our-key-rec
          buf_ext-classif.db-num = -1
          .
        end.
      end.
    end.
    else do:
      for each buf_ext-classif where
          buf_ext-classif.classif-subject = {&table_clients}
      and buf_ext-classif.classif-name = {&extclass_clients_inn}
      and buf_ext-classif.charkey_one  = p-old-inn
      and buf_ext-classif.db-num  = -1
      and buf_ext-classif.uniq-key-rec = (if temp-clients.obj-type = {&cmp}
                                          then v-firm-our-key-rec
                                          else v-person-our-key-rec)
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        delete buf_ext-classif.
      end.
      for each buf_ext-classif where
          buf_ext-classif.classif-subject = {&table_clients}
      and buf_ext-classif.classif-name = {&extclass_clients_inn}
      and buf_ext-classif.charkey_one  = p-old-inn
      and buf_ext-classif.db-num  = -1
      and buf_ext-classif.uniq-key-rec =  v-our-key-rec
      on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
      on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
      on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
      :
        delete buf_ext-classif.
      end.
    end.
    for each buf_batchprocess exclusive-lock where
            buf_batchprocess.charkey_one = v-our-key-rec
        AND buf_batchprocess.bp_type = {&btpr-type-nws-coll}
        and buf_batchprocess.bp_status = {&btpr-normal}
    on error undo, return error return-value :
      if buf_batchprocess.charkey_three <> v-new-inn then do:
        assign
          {&btpr-table}.bp_status = {&btpr-deleted}
        .
      end.
    end.
  end.
  else do:
    if g#news then return.
    if p-inn =  '':U then return.
    if p-obj-type = {&cmp} then do:
      find first another_firm no-lock where
                another_firm.inn = v-new-inn
            and recid(another_firm)  <> p-recid  no-error.
    end.
    if p-obj-type = {&prs}
    and inn-uniq = 1
    then do:
      find first another_firm no-lock where
                another_firm.inn = v-new-inn no-error.
    end.
    if available another_firm then do:
      if p-silent then do:
        /*
        assign
        v-err-mess = substitute("Уже есть фирма с {&abbr_inn_allshift} &1: фирма &2&3" +
                                "Изменение/добавление фирмы должно быть подтверждено оператором&3" +
                                "Автоматическое изменение добавление/изменение контрагента с таким {&abbr_inn_allshift} НЕВОЗМОЖНО"
                              , v-new-inn
                              , another_firm.firm-code
                              , {&new-line}
                              ).
        p-inn-uniq-error = yes.
        return v-err-mess.
        */
      end.
      else do:
        message
        substitute("Уже есть фирма с {&abbr_inn_allshift} &1: фирма &2&3" +
                  "Вы уверены, что хотите добавить/изменить контрагента с таким же {&abbr_inn_allshift}?"
                  , v-new-inn
                  , another_firm.firm-code
                  , {&new-line}
                  )
        view-as alert-box question buttons YES-NO update glog.
        if not glog then do:
          p-inn-uniq-error = yes.
          return "inn-uniq-no-message".
        end.
      end.
    end. /*if available another_firm then do:*/
    if inn-uniq = 1 then do:
      /*должны включить проверку И_Н_Н и для физ лиц*/
      run waitfram-show in this-procedure ( input "Ждите... Идет поиск повторных {&abbr_inn_allshift}" ).
      for each another_person no-lock :
        if another_person.inn = v-new-inn then do:
          if p-obj-type = {&cmp}
          or (p-obj-type = {&prs}
              and
              p-obj-code <> another_person.psn-code) then do:
            run waitfram-hide in this-procedure .
            if p-silent then do:
              assign
              v-err-mess = substitute("Уже есть физ.лицо с {&abbr_inn_allshift} &1: чел &2&3" +
                                      "Изменение/добавление контрагента должно быть подтверждено оператором&3" +
                                      "Автоматическое изменение добавление/изменение контрагента с таким {&abbr_inn_allshift} НЕВОЗМОЖНО"
                                    , v-new-inn
                                    , another_person.psn-code
                                    , {&new-line}
                                    ).
              p-inn-uniq-error = yes.
              return v-err-mess.
            end.
            else do:
              message
              substitute("Уже есть физ лицо с {&abbr_inn_allshift} &1: чел &2&3" +
                        "Вы уверены, что хотите добавить/изменить контрагента с таким же {&abbr_inn_allshift}?"
                        , v-new-inn
                        , another_person.psn-code
                        , {&new-line}
                        )
              view-as alert-box question buttons YES-NO update glog.
              if not glog then do:
                p-inn-uniq-error = yes.
                return  "inn-uniq-no-message".
              end.
            end.
          end.
        end. /*if another_person.inn = v-new-inn then do:*/
      end. /*for each another_person no-lock :*/
      run waitfram-hide in this-procedure .
    end. /*if inn-uniq = 1 then do:*/
  end.
end. /*doe*/