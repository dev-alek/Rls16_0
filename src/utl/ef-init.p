block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ef-init.p $
$Archive: utl/ef-init.p $

Инициализация мобильного блока EasyFuel

Автор: Бахтадзе Наталья Викторовна
Дата создания: 05/30/08
Author: Bakhtadze Natalya
Creation date: 05/30/08

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ef-init.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ef-init.p $":U .
define variable vss-description as character no-undo init "Инициализация мобильного блока EasyFuel".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/temp-dcp.i def }
{ ref/temp-dcp.i init-proc }
{ ref/temp-dcp.i lock-proc }
{ ref/dc-prop.i }
{ ref/discprop.i }
{ ref/extclass.i }
{ rul/propreft.i }
define stream stmxmlout .
{ str/cd-xml.i }
{ ref/dc-efdf.i }
{ ref/dc-efdf.i vid }
{ gbl/dec-hex.i }
{ gbl/cur-time.i }
{ cmp/ini-lib.i }
{ gbl/fileslsh.i }
{ utl/ef-dom.i }
{ ref/tmpchgs.i "NEW SHARED" temp-labels update }


define variable v-num as integer no-undo .
DEFINE VARIABLE v-rid-list as character no-undo .
define variable v-setted as logical no-undo .
define variable v-sum-id as character no-undo .
define variable v-dt-code as integer no-undo .
define variable v-nid as character no-undo .
define variable glog as logical no-undo .


define buffer buf_dis-card for ub.dis-card.
define buffer locked_dis-card-property for ub.dis-card-property.

define buffer buf_temp-ef for temp-ef.
define buffer buf_temp-ef1 for temp-ef1.
define buffer buf_temp-ef2 for temp-ef2.
define buffer buf2_temp-ef for vidtemp-ef.
define buffer buf2_temp-ef1 for vidtemp-ef1.
define buffer buf2_temp-ef2 for vidtemp-ef2.


/*выберем карту из списка*/

run ref/discards.w (
                  input parparentproc
                ,input "b-sel":U
                ,input {&all}
                ,input v-cntxt-host-code-obj
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input '':U
                ,input ?
                ,output v-rid-list ) no-error.

if not v-rid-list  = "" then do:
  FIND FIRST buf_dis-card no-lock where
              recid(buf_dis-card) = integer(v-rid-list).
  if buf_dis-card.status_ = {&nonused-status}
  or buf_dis-card.status_ = {&chown-status}
  then do:
    message
    substitute("Нельзя инициализировать МБ &1&2" +
              "Карта имеет статус &3, &4"
            , buf_dis-card.d-card
            , {&new-line}
            , buf_dis-card.status_
            , (if buf_dis-card.status_ = {&nonused-status}
              then "карта должна быть ОКОНЧАТЕЛЬНО удалена"
              else "карта будет доступна по окончании процесса смены владельца")
                )
    view-as alert-box error .
    return .
  end.
  do
  on error undo, return error return-value
  on stop undo, return error return-value
  on end-key undo, return error return-value :

    run lock-dcp in this-procedure ( input buf_dis-card.d-card
                                    ,buffer locked_dis-card-property).
  end.
  define buffer buf_Dis-card-property for ub.dis-card-property.
  find first buf_Dis-card-property no-lock where
             buf_dis-card-property.dtm-code = {&dc-prop_easyfuel}
         and buf_dis-card-property.d-card = buf_Dis-card.d-card
         and buf_dis-card-property.host-code = 0
         and buf_dis-card-property.obj-type = ''
         and buf_dis-card-property.obj-code = 0 no-error.
  if not available buf_dis-card-property then do:
    message
    substitute("В системе IBS TH Нет идентификационных данных EasyFuel для данной карты-МБ &1", buf_Dis-card.d-card)
    view-as alert-box error .
    undo, return ''.
  end.
  assign
  v-sum-id = buf_dis-card-property.sum-id
  v-dt-code = buf_dis-card-property.dt-code
  .
  for each temp-dis-card-property:
    delete temp-dis-card-property.
  end.
  run init-temp-dcp in this-procedure ( input {&lookup} + {&comma-char} + "init"
                                      ,input buf_dis-card.d-card
                                      ,input {&dc-prop_easyfuel}
                                      ,input v-sum-id
                                      ,input v-dt-code).

  run init-temp-dcp in this-procedure ( input {&lookup} + {&comma-char} + "init"
                                      ,input buf_dis-card.d-card
                                      ,input {&dc-prop_easyfuel-limits}
                                      ,input ""
                                      ,input 0).
  run ref/dc-ef.w (
                    input parparentproc
                   ,input {&lookup} + {&comma-char} + "init"
                   ,input {&dc-prop_easyfuel}
                   ,input v-sum-id
                   ,input v-dt-code
                   ,input 0 /*p-node-code*/
                   ,input buf_dis-card.emitent-host-code
                   ,input buf_dis-card.type
                   ,input buf_Dis-card.d-card
                   ,input v-cntxt-host-code-obj
                   ,input v-cntxt-obj-type
                   ,input v-cntxt-obj-code
                   ,input-output table temp-dis-card-property
                   ,output v-setted) no-error.
  if v-setted then do:
    run write-log in p-log-handle ( input 0,  "Ждите...." ).
    for each buf_temp-ef:
      delete buf_temp-ef.
    end.
    for each buf_temp-ef1:
      delete buf_temp-ef1.
    end.
    for each buf_temp-ef2:
      delete buf_temp-ef2.
    end.
    run fill-main-table  in this-procedure ( input buf_Dis-card.d-card, buffer buf_Dis-card).
    define variable v-out-file as character no-undo .
    define variable v-in-file as character no-undo .
    define variable v-cmd-line as character no-undo .
    define variable v-time as integer no-undo init 30.
    define variable v-xml-file-base as character no-undo .
    define variable v-error-code as character no-undo.
    for each buf_temp-ef:
      create buf2_temp-ef.
      buffer-copy buf_temp-ef
      to buf2_temp-ef.
    end.
    for each buf_temp-ef1:
      create buf2_temp-ef1.
      buffer-copy buf_temp-ef1
      to buf2_temp-ef1.
    end.
    for each buf_temp-ef2:
      create buf2_temp-ef2.
      buffer-copy buf_temp-ef2
      to buf2_temp-ef2.
    end.
    define variable v-param-type as character no-undo .
    define variable v-value-date as date no-undo .
    define variable v-value-decimal as decimal no-undo .
    define variable v-value-integer as INTEGER no-undo .
    define variable v-value-logical AS LOGICAL no-undo .
    define variable v-tth as handle no-undo .
    run adm/shattri.p (
         input "get":U
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
        ,input  {&attr-easyfuel}
        ,input  {&attr-easyfuel_master-key} /*p-param-code*/
        ,output v-nid
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-param-type
        ,INPUT-OUTPUT table-handle v-tth
        ) no-error .

    delete object v-tth.
    v-time = 0 * {&sec-per-command} + 10.
    run prepare-file-names in this-procedure ( input-output v-out-file, input-output v-in-file).
    run set-cmd-file in this-procedure (
                                        input ""
                                       ,input v-nid
                                       ,input buf_Dis-card.d-card
                                       ,input v-out-file).



    run prepare-cmd-line in this-procedure ( input v-out-file, input v-in-file, output v-cmd-line) no-error.
    if error-status:error then do:
      run write-log in p-log-handle ( input 0,  "Ошибка!" ).
      run write-log in p-log-handle ( input 0,  return-value ).
      undo, return error "" .
    end.
    run write-log in p-log-handle ( input 0,  "Обращаюсь к программе связи с МБ...Проверка связи..." ).
    run gbl/syn4.p (
                     input v-cmd-line
                    ,input v-in-file
                    ,input ""
                    ,input v-time
                    ) no-error.
    if error-status:error then do:
      run write-log in p-log-handle ( input 0,  "Ошибка!" ).
      run write-log in p-log-handle ( input 0,  return-value ).
      undo, return error "".
    end.
    if not error-status:error then do:
      run get-cmd-file in this-procedure (
                                         input ''
                                        ,input v-in-file
                                        ,input buf_Dis-card.d-card
                                        ,input "no-error"
                                        ,output v-error-code)
      no-error.
     if error-status:error then do:
      run write-log in p-log-handle ( input 0,  "Ошибка!" ).
      run write-log in p-log-handle ( input 0,  substitute("&1&2&3"
                                    , {&new-line}
                                    , error-status:get-message(1)
                                    , return-value )).
      undo, return error "".
     end.
    end.


    v-time = 1 * {&sec-per-command} + 10.

    run prepare-file-names in this-procedure ( input-output v-out-file, input-output v-in-file).
    /*сначала все считаем*/
    run set-cmd-file in this-procedure (
                                        input "ReadID"
                                       ,input v-nid
                                       ,input buf_Dis-card.d-card
                                       ,input v-out-file).

    run prepare-cmd-line in this-procedure ( input v-out-file, input v-in-file, output v-cmd-line) no-error .
    if error-status:error then do:
      run write-log in p-log-handle ( input 0,  "Ошибка!" ).
      run write-log in p-log-handle ( input 0,  return-value ).
      undo, return error "error" .
    end.

    /*запуск команды*/
    run write-log in p-log-handle ( input 0,  "Считывание идентификационных данных..." ).
    run gbl/syn4.p (
                     input v-cmd-line
                    ,input v-in-file
                    ,input ""
                    ,input v-time
                    ) no-error.
    if not error-status:error then do:
      run get-cmd-file in this-procedure (
                                         input 'ReadId'
                                        ,input v-in-file
                                        ,input buf_Dis-card.d-card
                                        ,input ""
                                        ,output v-error-code
) no-error .
      if error-status:error then do:
        run write-log in p-log-handle ( input 0,  "Ошибка!" ).
        run write-log in p-log-handle ( input 0,   substitute("&1&2&3"
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value )).
        undo, return error "".
      end.
    end.

    find first buf_temp-ef where
              buf_temp-ef.d-card = buf_Dis-card.d-card.
    define variable v-loog as logical no-undo .
    find first buf2_temp-ef .
    buffer-compare buf_temp-ef
    to buf2_temp-ef
    save result in v-loog.
    if buf2_temp-ef.car-reg-number <> ""
    and buf2_temp-ef.car-reg-number <> ?
    or buf2_temp-ef.issue-date <> ? then do:
      run tempchgs-create-lable-record in this-procedure (
                                                          input "temp-ef"
                                                        , input "car-reg-number"
                                                        , input "Гос.регистрационный номер"
                                                        , input 0
                                                        , input '':U
                                                        , input yes
                                                        ).
      run tempchgs-create-lable-record in this-procedure (
                                                          input "temp-ef"
                                                        , input "car-brand"
                                                        , input "Марка транспортного средства"
                                                        , input 0
                                                        , input '':U
                                                        , input yes
                                                        ).

      run tempchgs-create-lable-record in this-procedure (
                                                          input "temp-ef"
                                                        , input "ef-format"
                                                        , input "Формат данных на МБ"
                                                        , input 0
                                                        , input '':U
                                                        , input yes
                                                        ).

      run tempchgs-create-lable-record in this-procedure (
                                                          input "temp-ef"
                                                        , input "init-date-time"
                                                        , input "Дата время инициализации"
                                                        , input 0
                                                        , input '':U
                                                        , input yes
                                                        ).

      run tempchgs-create-lable-record in this-procedure (
                                                          input "temp-ef"
                                                        , input "valid-date"
                                                        , input "Действительно до"
                                                        , input 0
                                                        , input '':U
                                                        , input yes
                                                        ).

      run tempchgs-create-lable-record in this-procedure (
                                                          input "temp-ef"
                                                        , input "valid-from"
                                                        , input "Действительно c"
                                                        , input 0
                                                        , input '':U
                                                        , input yes
                                                        ).
      run tempchgs-create-lable-record in this-procedure (
                                                          input "temp-ef"
                                                        , input "petrol-code-1"
                                                        , input "Топливо 1"
                                                        , input 0
                                                        , input '':U
                                                        , input yes
                                                        ).
      run tempchgs-create-lable-record in this-procedure (
                                                          input "temp-ef"
                                                        , input "petrol-code-2"
                                                        , input "Топливо 2"
                                                        , input 0
                                                        , input '':U
                                                        , input yes
                                                        ).
      run tempchgs-create-lable-record in this-procedure (
                                                          input "temp-ef"
                                                        , input "petrol-code-3"
                                                        , input "Топливо 3"
                                                        , input 0
                                                        , input '':U
                                                        , input yes
                                                        ).
      run tempchgs-create-lable-record in this-procedure (
                                                          input "temp-ef"
                                                        , input "petrol-code-4"
                                                        , input "Топливо 4"
                                                        , input 0
                                                        , input '':U
                                                        , input yes
                                                        ).
      run tempchgs-create-lable-record in this-procedure (
                                                          input "temp-ef"
                                                        , input "issue-code"
                                                        , input "Выдал магазин"
                                                        , input 0
                                                        , input '':U
                                                        , input yes
                                                        ).
      run tempchgs-create-lable-record in this-procedure (
                                                          input "temp-ef"
                                                        , input "issued-by"
                                                        , input "Выдал оператор"
                                                        , input 0
                                                        , input '':U
                                                        , input yes
                                                        ).

      define variable v-ok as logical no-undo .
      run ref/view-chg.w (
                           INPUT parparentproc
                          ,input ? /*p-call-handle*/
                          ,input  "temp-ef" /*p-tbl-name*/
                          ,input (buffer buf_temp-ef:handle)
                          ,input (buffer buf2_temp-ef:handle)
                          ,input {&lookup}
                          ,input 0 /*p-limit-access*/
                          ,input "Разница в идентификационных данных"
                          ,input "Данные в IBS TH" /*p-col-old-label*/
                          ,input "Данные на МБ" /*p-col-new-label*/
                          ,input "" /*p-col-aux-label*/
                          ,input ("Данный МБ УЖЕ СОДЕРЖИТ ИДЕНТИФИКАЦИОННУЮ ИНФОРМАЦИЮ" + {&new-line} +
                                 "Внимательно просмотрите отличающиеся поля (ЕСЛИ ОНИ ЕСТЬ), прежде чем принять решение об инициализации") /*p-descr*/
                          ,output v-ok) no-error.
      message
      "Продолжить инициализацию?"
      view-as alert-box question buttons yes-no update glog.
      if not glog then return.

    end.
    run write-log in p-log-handle ( input 0,  "Ждите..." ).

    v-time = 3 * {&sec-per-command} + 10.
    run prepare-file-names in this-procedure ( input-output v-out-file, input-output v-in-file).
    run set-cmd-file in this-procedure (
                                        input "WriteID,WriteBrand,WriteLimit,WriteCons,WriteHistory"
                                       ,input v-nid
                                       ,input buf_Dis-card.d-card
                                       ,input v-out-file).
    run prepare-cmd-line in this-procedure ( input v-out-file, input v-in-file, output v-cmd-line) no-error .
    if error-status:error then do:
      run write-log in p-log-handle ( input 0,  "Ошибка" ).
      run write-log in p-log-handle ( input 0,  return-value ).
      undo, return error "".
    end.

    run write-log in p-log-handle ( input 0,  "Обращаюсь к программе связи с МБ...Запись идентификационных данных..." ).
    run gbl/syn4.p (
                     input v-cmd-line
                    ,input v-in-file
                    ,input ""
                    ,input v-time
                    ) no-error.
    if not error-status:error then do:
      run get-cmd-file in this-procedure (
                                          input 'WriteID,WriteBrand,WriteLimit,WriteCons,WriteHistory'
                                         ,input v-in-file
                                         ,input buf_Dis-card.d-card
                                        ,input ""
                                        ,output v-error-code
) no-error.
      if error-status:error then do:
        run write-log in p-log-handle ( input 0,  "Ошибка" ).
        run write-log in p-log-handle ( input 0,  substitute("&1&2&3"
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value )).
        undo, return error "".
      end.
      if search("ef-debug.flg") = ? then do:
        os-delete value(v-out-file).
        os-delete value(v-in-file).
      end.
      /*сохраним дату прошивки*/
      DEFINE VARIABLE v-today as date no-undo .
      define variable v-chip-num as integer no-undo .
      define variable v-corr-date as date no-undo .
      define variable v-corr-time as integer no-undo .

      run cur-time in this-procedure ( output v-today, output v-time).
      assign
      v-chip-num = 0
      v-corr-date = ?
      v-corr-time = ?.

      run discprop-write  in this-procedure (
                                              input buf_dis-card.d-card
                                              ,input 0
                                              ,input ''
                                              ,input 0
                                              ,input {&dc-prop_easyfuel}
                                              ,input {&dc_prop_easyfuel_init-date-time}
                                              ,input v-dt-code
                                              ,input v-sum-id
                                              ,input Xml-CD-DateTimetoString( v-today, v-time)
                                              ,input ? /*p-value-date      */
                                              ,input 0 /*p-value-decimal   */
                                              ,input 0 /*p-value-integer   */
                                              ,input no /*p-value-logical   */
                                              ,input "" /*p-source-type     */
                                              ,input "" /*p-source-ref     */
                                              ,input-output v-chip-num
                                              ,input-output v-corr-date
                                              ,input-output v-corr-time).

      run discprop-write  in this-procedure (
                                              input buf_dis-card.d-card
                                              ,input 0
                                              ,input ''
                                              ,input 0
                                              ,input {&dc-prop_easyfuel}
                                              ,input {&dc_prop_easyfuel_init-operator}
                                              ,input v-dt-code
                                              ,input v-sum-id
                                              ,input g#userid
                                              ,input ? /*p-value-date      */
                                              ,input 0 /*p-value-decimal   */
                                              ,input 0 /*p-value-integer   */
                                              ,input no /*p-value-logical   */
                                              ,input "" /*p-source-type     */
                                              ,input "" /*p-source-ref     */
                                              ,input-output v-chip-num
                                              ,input-output v-corr-date
                                              ,input-output v-corr-time).
      message
      substitute("МБ с номером &1 инициализирован успешно", buf_Dis-card.d-card)
      view-as alert-box .
    end.
    else do:

    end.
  end.
end.