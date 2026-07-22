block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: eflimits.p $
$Archive: utl/eflimits.p $

Изменение данных по топливу для мобильного блока EasyFuel

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
define variable vss-workfile    as character no-undo init "$Workfile: eflimits.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/eflimits.p $":U .
define variable vss-description as character no-undo init "Изменение данных по топливу для мобильного блока EasyFuel".
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
    substitute("Нельзя изменять данные МБ &1&2" +
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
    substitute("В системе IBS TH нет идентификационных данных EasyFuel для данной карты-МБ &1", buf_Dis-card.d-card)
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
  v-setted = yes.
  if v-setted then do:
    run write-log in p-log-handle ( input 0,  "Ждите..." ).
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
      run write-log in p-log-handle ( input 0,  "Ошибка" ).
      run write-log in p-log-handle ( input 0,  return-value  ).
      undo, return error "".
    end.
    run write-log in p-log-handle ( input 0,  "Обращаюсь к программе связи с МБ...Проверка связи..." ).
    run gbl/syn4.p (
                     input v-cmd-line
                    ,input v-in-file
                    ,input ""
                    ,input v-time
                    ) no-error.
    if error-status:error then do:
      run write-log in p-log-handle ( input 0,  "Ошибка" ).
      run write-log in p-log-handle ( input 0,  return-value  ).
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
       run write-log in p-log-handle ( input 0,  "Ошибка" ).
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
                                        input "ReadID,ReadLimit"
                                       ,input v-nid
                                       ,input buf_Dis-card.d-card
                                       ,input v-out-file).

    run prepare-cmd-line in this-procedure ( input v-out-file, input v-in-file, output v-cmd-line) no-error .
    if error-status:error then do:
       run write-log in p-log-handle ( input 0,  "Ошибка" ).
       run write-log in p-log-handle ( input 0,  return-value ).

       undo, return error "" .
    end.


    /*запуск команды*/
    run write-log in p-log-handle ( input 0
                                   , substitute("Обращаюсь к программе связи с МБ...&1" +
                                                "Считывание идентификационных данных...&1" +
                                                "Считывание лимитов по топливам..." , {&new-line})).

    run gbl/syn4.p (
                     input v-cmd-line
                    ,input v-in-file
                    ,input ""
                    ,input v-time
                    ) no-error.
    if not error-status:error then do:
      run get-cmd-file in this-procedure (
                                         input 'ReadId,ReadLimit'
                                        ,input v-in-file
                                        ,input buf_Dis-card.d-card
                                        ,input ""
                                        ,output v-error-code
                                         ) no-error .
      if error-status:error then do:
        run write-log in p-log-handle ( input 0,  "Ошибка" ).
        run write-log in p-log-handle ( input 0,  substitute("&1&2&3"
                                      , {&new-line}
                                      , error-status:get-message(1)
                                      , return-value )).
        undo, return error "".
      end.
    end.
    find first buf_temp-ef where
              buf_temp-ef.d-card = buf_Dis-card.d-card.
    find first buf2_temp-ef where
              buf2_temp-ef.d-card = buf_Dis-card.d-card.

    /*
    output to dc-efdf.txt.
    export buf_temp-ef.
    export buf2_temp-ef.
    for each buf_temp-ef1:
    export buf_temp-ef1.
    end.
    for each buf2_temp-ef1:
    export buf2_temp-ef1.
    end.

    output close.
    message 111 view-as alert-box .
    */

    /*надо сравнить привязку топлив и лимиты*/
    define variable v-th as handle no-undo .
    define variable v-th2 as handle no-undo .
    define variable v-jj as integer no-undo .
        run create-table in this-procedure ( input "limits", buffer buf_temp-ef, output v-th) .
    run create-table in this-procedure ( input "limits2", buffer buf_temp-ef, output v-th2) .

    run copy-fields in this-procedure ( buffer buf_temp-ef
                                      ,buffer buf2_temp-ef
                                      ,input v-th
                                      ,input v-th2) .


    define variable v-bh1 as handle no-undo .
    define variable v-bh2 as handle no-undo .
    create buffer v-bh1 for table v-th.
    create buffer v-bh2 for table v-th2.
    /*создадим */

    do v-jj = 1 to v-th:default-buffer-handle:num-fields:
      if v-th:default-buffer-handle:buffer-field(v-jj):name = "record-num" then next.
      run tempchgs-create-lable-record in this-procedure (
                                                          input v-th:name
                                                        , input v-th:default-buffer-handle:buffer-field(v-jj):name
                                                        , input (if v-th:default-buffer-handle:buffer-field(v-jj):name begins "EF-"
                                                                and not (v-th:default-buffer-handle:buffer-field(v-jj):name begins "EF-f")
                                                                then substitute("&1-&2"
                                                                               ,substring(v-th:default-buffer-handle:buffer-field(v-jj):name, 1, 4)
                                                                               ,v-th:default-buffer-handle:buffer-field(v-jj):label
                                                                               )
                                                                else v-th:default-buffer-handle:buffer-field(v-jj):label)
                                                        , input no
                                                        , input ""
                                                        , input yes
                                                       ).
    end.
    define variable v-ok as logical no-undo .
    run ref/view-chg.w (
                         INPUT parparentproc
                        ,input ? /*p-call-handle*/
                        ,input "limits"
                        ,input v-bh1
                        ,input v-bh2
                        ,input {&lookup} + {&comma-char} + "view-identical" /*p-tbl-name*/
                        ,input 0 /*p-limit-access*/
                        ,input "Разница в данных по топливам"
                        ,input "Данные в IBS TH" /*p-col-old-label*/
                        ,input "Данные на МБ" /*p-col-new-label*/
                        ,input "" /*p-col-aux-label*/
                        ,input ("Внимательно просмотрите отличающиеся поля (ЕСЛИ ОНИ ЕСТЬ), прежде чем принять решение об изменении данных") /*p-descr*/
                        ,output v-ok) no-error.
    delete object v-bh1.
    delete object v-bh2.
    delete object v-th.
    delete object v-th2.
    message
    "Провести изменение?"
    view-as alert-box question buttons yes-no update glog.
    if not glog then return.
    run write-log in p-log-handle ( input 0,  "Ждите" ).
    v-time = 3 * {&sec-per-command} + 10.
    run prepare-file-names in this-procedure ( input-output v-out-file, input-output v-in-file).
    buffer-copy buf2_temp-ef
    except car-reg-num car-brand
    to buf_temp-ef.
    run set-cmd-file in this-procedure (
                                        input "WriteLimit"
                                       ,input v-nid
                                       ,input buf_Dis-card.d-card
                                       ,input v-out-file).
    run prepare-cmd-line in this-procedure ( input v-out-file, input v-in-file, output v-cmd-line) no-error .
    if error-status:error then do:
      run write-log in p-log-handle ( input 0,  "Ошибка" ).
      run write-log in p-log-handle ( input 0,  return-value  ).
      undo, return error "" .
    end.
    run write-log in p-log-handle ( input 0,  "Обращаюсь к программе связи с МБ...Запись данных по топливам..." ).
    run gbl/syn4.p (
                     input v-cmd-line
                    ,input v-in-file
                    ,input ""
                    ,input v-time
                    ) no-error.
    if not error-status:error then do:
      run get-cmd-file in this-procedure (
                                          input 'WriteLimit'
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
      substitute("МБ с номером &1 перепрошит успешно", buf_Dis-card.d-card)
      view-as alert-box .
    end.
    else do:

    end.
  end.
end.

procedure create-table :
define input parameter p-tbl-name as character no-undo .
define parameter buffer buf_temp-ef for temp-ef.
define output parameter v-th as handle no-undo .

define variable v-jj as integer no-undo .
define variable v-fname as character no-undo .
define variable v-fnamelist as character no-undo .
define buffer buf_temp-ef1 for temp-ef1.
define buffer buf2_temp-ef for vidtemp-ef1.


  do
  on error undo, return error
  :
    create temp-table v-th.
    v-th:add-new-field( "record-num", {&abl-datatype-integer}).
    v-th:add-like-field( "petrol-code-1", buffer buf_temp-ef:handle:buffer-field("petrol-code-1")).
    v-th:add-like-field( "petrol-code-2", buffer buf_temp-ef:handle:buffer-field("petrol-code-2")).
    v-th:add-like-field( "petrol-code-3", buffer buf_temp-ef:handle:buffer-field("petrol-code-3")).
    v-th:add-like-field( "petrol-code-4", buffer buf_temp-ef:handle:buffer-field("petrol-code-4")).

&scop create-field  ~
    do v-jj = 1 to num-entries(v-fnamelist): ~
      v-fname = entry(v-jj, v-fnamelist). ~
      v-th:add-like-field( substitute("EF-&1-&2", ~{&prefix~}, v-fname), ~{&srcfh~}).  ~
    end
    v-fnamelist = "ef-petrol-code,petrol-num,common-limit,month-limit,day-limit,standard-dose,petrol-code".
    &scop prefix buf_temp-ef1.ef-petrol-code
    &scop srcfh (buffer buf_temp-ef1:handle:buffer-field(v-fname))
    for each buf_temp-ef1 :
      {&create-field}.
    end.

    &scop prefix buf2_temp-ef1.ef-petrol-code
    &scop srcfh (buffer buf2_temp-ef1:handle:buffer-field(v-fname))

    for each buf2_temp-ef1 :
      find first buf_temp-ef1 where
                buf_temp-ef1.ef-petrol-code = buf_temp-ef1.ef-petrol-code no-error.
      if not available buf_temp-ef1 then do:
        {&create-field}.
      end.
    end.
    v-th:add-new-index("pi", yes, yes).
    v-th:add-index-field("pi", "record-num").
    v-th:temp-table-prepare(p-tbl-name).

  end.

end procedure. /* create-table */

procedure copy-fields :
define parameter buffer buf_temp-ef for temp-ef.
define parameter buffer buf2_temp-ef for vidtemp-ef.
define input parameter v-th as handle no-undo .
define input parameter v-th2 as handle no-undo .

define variable v-jj as integer no-undo .
define variable v-fname as character no-undo .
define variable v-fnamelist as character no-undo .
define buffer buf_temp-ef1 for temp-ef1.
define buffer buf2_temp-ef1 for vidtemp-ef1.


  do
  on error undo, return error
  :
&scop copy-field ~
    do v-jj = 1 to num-entries(v-fnamelist): ~
      v-fname = entry(v-jj, v-fnamelist). ~
      ~{&th~}:default-buffer-handle:buffer-field( substitute("&1&2", ~{&prefix~}, v-fname)):buffer-value = ~{&srcbh~}:buffer-field(v-fname):buffer-value. ~
    end

    v-th:default-buffer-handle:buffer-create.
    v-th:default-buffer-handle::record-num = 1.
    &scop srcbh buffer buf_temp-ef:handle
    v-fnamelist = "petrol-code-1,petrol-code-2,petrol-code-3,petrol-code-4".
    &scop prefix ""
    &scop th v-th
    {&copy-field}.

    &scop srcbh buffer buf_temp-ef1:handle
    v-fnamelist = "ef-petrol-code,petrol-num,common-limit,month-limit,day-limit,standard-dose,petrol-code".
    &scop prefix substitute("EF-&1-", buf_temp-ef1.ef-petrol-code)

    for each buf_temp-ef1 :
      {&copy-field}.
    end.
    v-th:default-buffer-handle:buffer-release().

    v-th2:default-buffer-handle:buffer-create.
    v-th2:default-buffer-handle::record-num = 1.
    &scop srcbh buffer buf2_temp-ef:handle
    v-fnamelist = "petrol-code-1,petrol-code-2,petrol-code-3,petrol-code-4".
    &scop prefix ""
    &scop th v-th2
    {&copy-field}.

    &scop srcbh buffer buf2_temp-ef1:handle
    v-fnamelist = "ef-petrol-code,petrol-num,common-limit,month-limit,day-limit,standard-dose,petrol-code".
    &scop prefix substitute("EF-&1-", buf2_temp-ef1.ef-petrol-code)

    for each buf2_temp-ef1 :
      {&copy-field}.
    end.
    v-th2:default-buffer-handle:buffer-release().


  end.

end procedure. /* copy-fields */