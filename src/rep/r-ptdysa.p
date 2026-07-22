block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ptdysa.p $
$Archive: rep/r-ptdysa.p $

ДИНАМИКА ПРОДАЖ НА АЗС по текущей смене

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/09/09
Author: Bakhtadze Natalya
Creation date: 07/09/09

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-cont-handle  as handle no-undo .
define input parameter p-report-id as character no-undo .
define input parameter p-log-file-name as character no-undo .
define input parameter p-xsd-file as character no-undo .
define input parameter p-rebh as handle no-undo . /*handle буфера для ошибок*/
define output parameter p-dataseth as handle no-undo.
define output parameter p-xmlh as handle no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ptdysa.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ptdysa.p $":U .
define variable vss-description as character no-undo init "ДИНАМИКА ПРОДАЖ НА АЗС по текущей смене".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ ref/grplibfn.i }
{ str/lib-trn.i }
{ gbl/key-rec.i }
{ gbl/gate-clb.i }
{ rep/r-ptdysa.i t }
{ gbl/cur-time.i }
{ gbl/rep-clb.i }
{ rep/fmtcli.i     }

define temp-table temp-obj no-undo
field obj-type as character
field obj-code as integer
field obj-name as character
field db-num as integer
field shift-date as date
field shift-num as integer
field shift-name as character
field report-num as integer
field db-num-list as character
field int64-id-list as character
field part-num-list as character
field rule-id as character
field field-name_ as character
field dataset-size as int64
index pi is unique primary
obj-type
obj-code
.



define variable l-shift-on as logical no-undo .
define variable v-full-name as character no-undo .
define variable v-is-petrol  as logical no-undo .
define variable v-is-pieces as logical no-undo .
define variable v-start-chk-date as date no-undo .
define variable v-start-chk-time as integer no-undo .
define variable v-end-chk-date as date no-undo .
define variable v-end-chk-time as integer no-undo .
define variable v-shift-id as character no-undo .
define variable v-part-num-list as character no-undo .
define variable v-db-num-list as character no-undo .
define variable v-int64-id-list as character no-undo .
define variable v-ii as integer no-undo .
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
define variable v-longchar as longchar no-undo .
define variable v_obj-dataseth as handle no-undo .
define variable v-gate-rec as character no-undo .
define variable glog as logical no-undo .
define variable v-current-cash-num as integer   no-undo .
define variable v-task-num as integer no-undo .
define variable v-write-err as logical no-undo .
define variable v-fix-start-date as date no-undo .
define variable v-fix-start-time as integer no-undo.
define variable v-fix-end-date as date no-undo .
define variable v-fix-end-time as integer no-undo.
define variable v-report-num as integer no-undo .
define variable v-current-datetime as datetime no-undo .
define variable v-obj-address as character no-undo .
define variable v-obj-phone as character no-undo .
define buffer buf_temp-obj for temp-obj.
define buffer buf_shift-obj for ub.shift-obj.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_goods for ub.goods.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_clients for ub.clients.
define buffer buf_gds-dyn-salt for gds-dyn-salt.
define buffer buf_grp-dyn-salt for grp-dyn-salt.
define buffer buf_obj-dyn-salt for obj-dyn-salt.
define buffer buf_cd-dyn-salt for cd-dyn-salt.
define buffer buf_temp-xml-tables for temp-xml-tables.

&scop display-message ~
          run write-log-and-file in p-log-handle ( ~
                input 1                            ~
              , input p-log-file-name                ~
              , input 1                            ~
              , input ~{&my-message}~)

/*здесь мы должны восстановить dataset из CLOB*/

if lookup("cb_write-report-error", p-parent-handle:internal-entries) > 0 then do:
  v-write-err = yes.
end.
p-xmlh = buffer buf_temp-xml-tables:handle.
run get-gate-rec in this-procedure ( input p-xsd-file
                                    ,output v-gate-rec) no-error.
if error-status:error then do:
  undo, return error substitute("Не найдено описание xsd-схемы &1 в БД", p-xsd-file).
end.
/*create p_dataset внутри get-gate-by-rec*/
run get-gate-by-rec in this-procedure ( input v-gate-rec
                                      ,output p-dataseth
                                      ,input-output p-xmlh
                                      ,input-output v-longchar
                                      ) no-error.
if error-status:error then do:
  &scop my-message substitute("Ошибка при создании структуры маршрутизируемых данных согласно гейту:&1&2&3&2&4" ~
                            , v-gate-rec ~
                            , ~{&new-line~} ~
                            , error-status:get-message(1) ~
                            , return-value )
  {&display-message}.
  delete object p-dataseth no-error.
  undo, return error '':U.
end.

/*найлем список объектов*/
for each buf_clients no-lock where
        buf_clients.db-num = g#db-num
    and buf_clients.stts = integer({&current-status-int})
    and buf_clients.obj-type = {&shop}:
  find first buf_temp-obj no-lock where
          buf_temp-obj.obj-type = buf_clients.obj-type
      and buf_temp-obj.obj-code = buf_clients.obj-code no-error.
  if not available buf_temp-obj then do:
    create buf_temp-obj.
    assign
    buf_temp-obj.obj-type = buf_clients.obj-type
    buf_temp-obj.obj-code = buf_clients.obj-code
    buf_temp-obj.obj-name = buf_clients.obj-name
    buf_temp-obj.db-num = buf_clients.db-num
    .
    release buf_temp-obj.
  end.
end.

v_obj-dataseth = dataset report-ptdysa-dst:handle.
/*v_obj-dataseth:create-like(p-dataseth, "obj").*/
/*найдем сменный ли объект*/
_temp-obj:
for each buf_temp-obj :
  l-shift-on = no.
  { gbl/objat.i
    buf_temp-obj.obj-type
    buf_temp-obj.obj-code
    "'shift-on=request'"
    l-shift-on
    no-error
  }
  if not l-shift-on then do:
    &scop my-message substitute("&1&2 не является сменным объектом - пропускаем ....", buf_temp-obj.obj-type, buf_temp-obj.obj-code)
    /*{&display-message}.*/
    delete buf_temp-obj.
    next _temp-obj.
  end.
  assign
  v-obj-address = ''
  v-obj-phone = ''
  .
  RUN fmtcli-get-client IN THIS-PROCEDURE ( INPUT  buf_temp-obj.obj-type
                                          , INPUT  buf_temp-obj.obj-code
                                          ) .
  assign
  v-obj-address = ( if v-fmtcli-index <> '':U then ( v-fmtcli-index ) else '':U )
                            + ( if v-fmtcli-full-addres <> '':U then ( v-fmtcli-full-addres ) else '':U )
  v-obj-phone   = ( if v-fmtcli-phone <> '':U then v-fmtcli-phone else '':U )
  .

  /*найдем последнюю смену закончившуюся или текущую*/
  { gbl/curshift.i
  buf_temp-obj.obj-type
  buf_temp-obj.obj-code
  buf_temp-obj.shift-date
  buf_temp-obj.shift-num
  buf_temp-obj.shift-name
  no-error }
  if error-status:error
  or
  buf_temp-obj.shift-date = ? then do:
    find last buf_shift-obj
      where buf_shift-obj.obj-type = buf_temp-obj.obj-type
        and buf_shift-obj.obj-code = buf_temp-obj.obj-code
        and buf_shift-obj.status_ = {&sht-closed}
      use-index stts
      no-error .
    if available buf_shift-obj then do:
      assign
      buf_shift-obj.shift-date = buf_shift-obj.shift-date
      buf_shift-obj.shift-num = buf_shift-obj.shift-num
      buf_shift-obj.shift-name = buf_shift-obj.shift-name
      .
    end.
  end.
  if buf_temp-obj.shift-date = ? then do:
    &scop my-message substitute("Для &1&2 не удалось определить текущую или последнюю закончившуюся смену - пропускаем ...." ~
                                  , buf_temp-obj.obj-type ~
                                  , buf_temp-obj.obj-code )
    {&display-message}.
    if v-write-err then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input {&severity-low}
                                                    ,input {&my-message}).
    end.
    delete buf_temp-obj.
    next _temp-obj.
  end.
  if not available buf_shift-obj then do:
    find first buf_shift-obj no-lock where
            buf_shift-obj.obj-type = buf_temp-obj.obj-type
        and buf_shift-obj.obj-code = buf_temp-obj.obj-code
        and buf_shift-obj.shift-date = buf_temp-obj.shift-date
        and buf_shift-obj.shift-num = buf_temp-obj.shift-num no-error.
    if not available buf_shift-obj then do:
      &scop my-message substitute("Для &1&2 не удалось определить текущую или последнюю закончившуюся смену &3 П. &4 - пропускаем ...." ~
                                    , buf_temp-obj.obj-type ~
                                    , buf_temp-obj.obj-code ~
                                    , string(buf_temp-obj.shift-date, "99/99/9999") ~
                                    , string(buf_temp-obj.shift-num))
      if v-write-err then do:
        run cb_write-report-error in p-parent-handle ( input p-rebh
                                                      ,input p-report-id
                                                      ,input ?
                                                      ,input {&severity-low}
                                                      ,input {&my-message}).
      end.
      {&display-message}.
      delete buf_temp-obj.
      next _temp-obj.
    end.
  end.
  v-shift-id = substitute("&1&2.&3.&4"
                         , buf_temp-obj.obj-type
                         , buf_temp-obj.obj-code
                         , buf_temp-obj.shift-date
                         , buf_temp-obj.shift-num).
  assign
  v-part-num-list = ''
  v-db-num-list = ''
  v-int64-id-list = ''
  .
  v_obj-dataseth:empty-dataset().
  /*заполняем  МАЛЕНЬКИЙ dataset данными из БД*/

  run rep-clb_fill-report-xml in this-procedure ( input p-report-id
                                                 ,input v-shift-id
                                                 ,input v_obj-dataseth
                                                 ,output v-db-num-list
                                                 ,output v-int64-id-list
                                                 ,output v-part-num-list
                                                 ) no-error.
  if error-status:error then do:
    &scop my-message substitute("Ошибка при получении данных предыдущего среза отчета:&1&2&1&3" ~
                               , ~{&new-line~} ~
                               , error-status:get-message(1)  ~
                               , return-value )
    {&display-message}.
    if v-write-err then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input {&severity-medium}
                                                    ,input {&my-message}).
    end.
    v_obj-dataseth:empty-dataset().
    /*обнулим еще раз пойдем собирать заново*/
  end.
  assign
  buf_temp-obj.db-num-list = v-db-num-list
  buf_temp-obj.int64-id-list = v-int64-id-list
  buf_temp-obj.part-num-list = v-part-num-list
  buf_temp-obj.rule-id  = p-report-id
  buf_temp-obj.field-name_ = v-shift-id
  .
  /*начинаем заполнять маленький датасет новыми данными*/
  v-current-cash-num = - 1.
  run cur-time in this-procedure ( output v-today, output v-time).
  v-current-datetime =  cur-time-datetime ().
  _chk-doc:
  for each buf_chk-doc no-lock where
         buf_chk-doc.obj-type = buf_temp-obj.obj-type
     and buf_chk-doc.obj-code = buf_temp-obj.obj-code
     and buf_chk-doc.chk-date >= buf_temp-obj.shift-date
  by buf_chk-doc.obj-type
  by buf_chk-doc.obj-code
  by buf_chk-doc.pay-desk:
    if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then NEXT _chk-doc.
    if buf_chk-doc.chk-date > v-today
    or (buf_chk-doc.chk-date = v-today
        and
        buf_chk-doc.chk-time = v-time) then next _chk-doc. /*читаем только чеки ДО ТЕКУЩЕГО МОМЕНТА, который зафиксировали на входе*/
    if (buf_chk-doc.shift-date = buf_temp-obj.shift-date
    and buf_chk-doc.shift-num = buf_temp-obj.shift-num)
    or (lookup({&shift-err}, buf_chk-doc.office) > 0
        and buf_chk-doc.chk-date >= buf_chk-doc.shift-date
    and  buf_chk-doc.shift-num = 0) then do:
      if v-current-cash-num <> buf_chk-doc.pay-desk then do:
        release buf_cd-dyn-salt no-error .
        if v-current-cash-num > -1 then do:
          find first buf_cd-dyn-salt where
                    buf_cd-dyn-salt.obj-type = buf_temp-obj.obj-type
                and buf_cd-dyn-salt.obj-code = buf_temp-obj.obj-code
                and buf_cd-dyn-salt.shift-date = buf_temp-obj.shift-date
                and buf_cd-dyn-salt.shift-num = buf_temp-obj.shift-num
                and buf_cd-dyn-salt.cash-num = v-current-cash-num no-error.
          assign
          buf_cd-dyn-salt.end-date = v-fix-end-date
          buf_cd-dyn-salt.end-time = v-fix-end-time
          buf_cd-dyn-salt.start-date = v-fix-start-date
          buf_cd-dyn-salt.start-time = v-fix-start-time
          .
        end.
        find first buf_cd-dyn-salt where
                  buf_cd-dyn-salt.obj-type = buf_temp-obj.obj-type
              and buf_cd-dyn-salt.obj-code = buf_temp-obj.obj-code
              and buf_cd-dyn-salt.shift-date = buf_temp-obj.shift-date
              and buf_cd-dyn-salt.shift-num = buf_temp-obj.shift-num
              and buf_cd-dyn-salt.cash-num = buf_chk-doc.pay-desk no-error.
        if not available buf_cd-dyn-salt then do:
          create buf_cd-dyn-salt.
          assign
          buf_cd-dyn-salt.obj-type = buf_temp-obj.obj-type
          buf_cd-dyn-salt.obj-code = buf_temp-obj.obj-code
          buf_cd-dyn-salt.shift-date = buf_temp-obj.shift-date
          buf_cd-dyn-salt.shift-num = buf_temp-obj.shift-num
          buf_cd-dyn-salt.cash-num = buf_chk-doc.pay-desk
          buf_cd-dyn-salt.start-date = buf_temp-obj.shift-date
          buf_cd-dyn-salt.start-time = 0
          buf_cd-dyn-salt.end-date = buf_temp-obj.shift-date
          buf_cd-dyn-salt.end-time = -1
          buf_cd-dyn-salt.report-num = 0
          .
        end.
        assign
        v-start-chk-date = buf_cd-dyn-salt.start-date
        v-start-chk-time = buf_cd-dyn-salt.start-time
        v-end-chk-date = buf_cd-dyn-salt.end-date
        v-end-chk-time = buf_cd-dyn-salt.end-time
        v-fix-start-date = buf_cd-dyn-salt.start-date
        v-fix-start-time = buf_cd-dyn-salt.start-time
        v-fix-end-date = buf_cd-dyn-salt.end-date
        v-fix-end-time = buf_cd-dyn-salt.end-time
        buf_cd-dyn-salt.report-num = buf_cd-dyn-salt.report-num + 1
        v-current-cash-num = buf_chk-doc.pay-desk
        v-report-num = buf_cd-dyn-salt.report-num
        .
      end. /*if v-current-cash-num <> buf_chk-doc.pay-desk then do:*/
      if ((buf_chk-doc.chk-date = v-end-chk-date
            and buf_chk-doc.chk-time > v-end-chk-time)
            or
            buf_chk-doc.chk-date > v-end-chk-date)
       then do:
         if buf_chk-doc.chk-date > v-fix-end-date
         or (buf_chk-doc.chk-date = v-fix-end-date
             and
             buf_chk-doc.chk-time > v-fix-end-time)  then do:
          assign
          v-fix-end-date = buf_chk-doc.chk-date
          v-fix-end-time = buf_chk-doc.chk-time
          .
         end.
         if buf_chk-doc.chk-date < v-fix-start-date
         or (buf_chk-doc.chk-date < v-fix-start-date
             and
             buf_chk-doc.chk-time < v-fix-start-time) then do:
          assign
          v-fix-start-date = buf_chk-doc.chk-date
          v-fix-start-time = buf_chk-doc.chk-time
          .
         end.
         _chk-gds:
         for each buf_chk-gds no-lock where
                  buf_chk-gds.doc-code = buf_chk-doc.doc-code,
             first buf_bar-code no-lock where
                  buf_bar-code.b-code = buf_chk-gds.b-code:

           find first buf_goods no-lock where
                    buf_goods.gds-code = buf_bar-code.gds-code no-error.
           if not available buf_goods then do:
             &scop my-message substitute("!!!Не найден товар с кодом &1", buf_bar-code.gds-code)
             {&display-message}.
             if v-write-err then do:
               run cb_write-report-error in p-parent-handle ( input p-rebh
                                                             ,input p-report-id
                                                             ,input ?
                                                             ,input {&severity-medium}
                                                             ,input {&my-message}).
             end.
             next _chk-gds.
           end.
           find first buf_gds-grp no-lock where
                    buf_gds-grp.node-code = buf_goods.grp-code no-error.
          if available buf_gds-grp then do:
            run grplib-get-full-name in this-procedure ( input buf_gds-grp.node-code
                                                        ,output v-full-name) no-error.
            if error-status:error then do:
              assign
              v-full-name = substitute("_Группа с вн № &1", buf_gds-grp.node-code).
            end.
          end. /*if available buf_gds-grp then do:*/
          else do:
            assign
            v-full-name = substitute("_НЕИЗВЕСТНАЯ Группа с вн № &1", buf_goods.grp-code).
             if v-write-err then do:
               run cb_write-report-error in p-parent-handle ( input p-rebh
                                                             ,input p-report-id
                                                             ,input ?
                                                             ,input {&severity-medium}
                                                             ,input substitute("Не найдена группа с ВН № &1 для товара с кодом &2"
                                                                              , buf_goods.grp-code
                                                                              , buf_goods.gds-code
                                                                              )).
             end.
          end.
          find first buf_gds-dyn-salt where
                    buf_gds-dyn-salt.obj-type = buf_temp-obj.obj-type
               and  buf_gds-dyn-salt.obj-code = buf_temp-obj.obj-code
               and  buf_gds-dyn-salt.shift-date = buf_temp-obj.shift-date
               and  buf_gds-dyn-salt.shift-num = buf_temp-obj.shift-num
               and  buf_gds-dyn-salt.gds-code = buf_goods.gds-code
               no-error.
          if not available buf_gds-dyn-salt then do:
            create buf_gds-dyn-salt.
            assign
            buf_gds-dyn-salt.obj-type = buf_temp-obj.obj-type
            buf_gds-dyn-salt.obj-code = buf_temp-obj.obj-code
            buf_gds-dyn-salt.shift-date = buf_temp-obj.shift-date
            buf_gds-dyn-salt.shift-num = buf_temp-obj.shift-num
            buf_gds-dyn-salt.gds-code = buf_goods.gds-code
            buf_gds-dyn-salt.node-code = buf_goods.grp-code
            buf_gds-dyn-salt.unit-base = buf_goods.unit-base
            buf_gds-dyn-salt.gds-name = buf_goods.gds-name
            .
            assign
            v-is-petrol = no
            v-is-pieces = no
            .
            { str/is-petrl.i
              buf_goods.artic
              buf_goods.prod-type
              buf_goods.prod-code
              v-is-petrol
              v-is-pieces
              no-error
            }
            assign
            buf_gds-dyn-salt.is-petrol = (v-is-petrol and not v-is-pieces)
            .
          end.
          assign
          buf_gds-dyn-salt.fact-qnty = buf_gds-dyn-salt.fact-qnty + buf_chk-gds.doc-qnty
          buf_gds-dyn-salt.fact-sum = buf_gds-dyn-salt.fact-sum +
                                     buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
          .
          release buf_gds-dyn-salt.
          find first buf_grp-dyn-salt where
                      buf_grp-dyn-salt.obj-type = buf_temp-obj.obj-type
                and  buf_grp-dyn-salt.obj-code = buf_temp-obj.obj-code
                and  buf_grp-dyn-salt.shift-date = buf_temp-obj.shift-date
                and  buf_grp-dyn-salt.shift-num = buf_temp-obj.shift-num
                and  buf_grp-dyn-salt.node-code = buf_goods.grp-code
                no-error.
          if not available buf_grp-dyn-salt then do:
            create buf_grp-dyn-salt.
            assign
            buf_grp-dyn-salt.obj-type = buf_temp-obj.obj-type
            buf_grp-dyn-salt.obj-code = buf_temp-obj.obj-code
            buf_grp-dyn-salt.shift-date = buf_temp-obj.shift-date
            buf_grp-dyn-salt.shift-num = buf_temp-obj.shift-num
            buf_grp-dyn-salt.node-code = buf_goods.grp-code
            buf_grp-dyn-salt.full-name = v-full-name
            .
          end.
          assign
          buf_grp-dyn-salt.fact-qnty = buf_grp-dyn-salt.fact-qnty + buf_chk-gds.doc-qnty
          buf_grp-dyn-salt.fact-sum = buf_grp-dyn-salt.fact-sum +
                                    buf_chk-gds.doc-qnty * (buf_chk-gds.price-base - buf_chk-gds.discnt)
          .
          release buf_grp-dyn-salt.
        end. /*for each buf_chk-gds no-lock where*/
      end.
    end. /*if (buf_chk-doc.shift-date = buf_temp-obj.shift-date*/
  end. /*for each buf_chk-doc*/
  if v-current-cash-num > -1 then do:
    find first buf_cd-dyn-salt where
              buf_cd-dyn-salt.obj-type = buf_temp-obj.obj-type
          and buf_cd-dyn-salt.obj-code = buf_temp-obj.obj-code
          and buf_cd-dyn-salt.shift-date = buf_temp-obj.shift-date
          and buf_cd-dyn-salt.shift-num = buf_temp-obj.shift-num
          and buf_cd-dyn-salt.cash-num = v-current-cash-num no-error.
    assign
    buf_cd-dyn-salt.end-date = v-fix-end-date
    buf_cd-dyn-salt.end-time = v-fix-end-time
    buf_cd-dyn-salt.start-date = v-fix-start-date
    buf_cd-dyn-salt.start-time = v-fix-start-time
    .
  end.
  find first buf_obj-dyn-salt where
            buf_obj-dyn-salt.obj-type = buf_temp-obj.obj-type
        and buf_obj-dyn-salt.obj-code = buf_temp-obj.obj-code
        and buf_obj-dyn-salt.shift-date = buf_temp-obj.shift-date
        and buf_obj-dyn-salt.shift-num = buf_temp-obj.shift-num no-error.
  if not available buf_obj-dyn-salt then do:
    create buf_obj-dyn-salt.
  end.
  buffer-copy buf_temp-obj
  to buf_obj-dyn-salt
  assign
  buf_obj-dyn-salt.report-num = buf_obj-dyn-salt.report-num + 1
  buf_obj-dyn-salt.current-datetime = v-current-datetime
  buf_obj-dyn-salt.obj-address = v-obj-address
  buf_obj-dyn-salt.obj-phone = v-obj-phone
  .
  release buf_obj-dyn-salt.

  /*запихнем обратно в clob-data*/
  run rep-clb_save-rep-xml in this-procedure (
                             input parparentproc
                            ,input p-parent-handle
                            ,input p-log-handle
                            ,input p-cont-handle
                            ,input p-report-id
                            ,input buf_temp-obj.field-name_
                            ,input buf_temp-obj.part-num-list
                            ,input buf_temp-obj.db-num-list
                            ,input buf_temp-obj.int64-id-list
                            ,input (?) /*locked-rec-handle*/
                            ,input substitute("ДИНАМИКА ПРОДАЖ НА АЗС &1&2, смена &3 №&4 П.&5"
                                          , buf_temp-obj.obj-type
                                          , buf_temp-obj.obj-code
                                          , string(buf_temp-obj.shift-date, "99/99/9999")
                                          , buf_temp-obj.shift-name
                                          , buf_temp-obj.shift-num) /*p-descr*/
                           ,input no
                           ,input "1251"
                           ,input v_obj-dataseth
                            ) no-error.
  if error-status:error then do:
    if v-write-err then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input {&severity-high}
                                                    ,input substitute("Ошибка при сохранении в БД среза по &1&2 смена от &3 П.&4&5&6&5&7"
                                                                      , buf_temp-obj.obj-type
                                                                      , buf_temp-obj.obj-code
                                                                      , string(buf_temp-obj.shift-date)
                                                                      , buf_temp-obj.shift-num
                                                                      , {&new-line}
                                                                      , error-status:get-message(1)
                                                                      , return-value
                                                                      )).
    end.
  end.
  glog = p-dataseth:copy-dataset (
                          v_obj-dataseth
                        , no /*append-mode*/
                        , yes /*replace-mode*/
                        , yes /*loose-mode*/
                        ) no-error.
  if error-status:error then do:
    if v-write-err then do:
      run cb_write-report-error in p-parent-handle ( input p-rebh
                                                    ,input p-report-id
                                                    ,input ?
                                                    ,input {&severity-high}
                                                    ,input substitute("Ошибка при сохранении в отчет среза по &1&2 смена от &3 П.&4&5&6&5&7&5"
                                                                     , buf_temp-obj.obj-type
                                                                     , buf_temp-obj.obj-code
                                                                     , string(buf_temp-obj.shift-date)
                                                                     , buf_temp-obj.shift-num
                                                                     , {&new-line}
                                                                     , error-status:get-message(1)
                                                                     , return-value
                                                                     )).
    end.
  end.
end.
for each buf_temp-xml-tables:
  case buf_temp-xml-tables.tbl-name:
    when "grp-dyn-sal" then do:
      glog = buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                     buffer grp-dyn-salt:handle
                                                    , no /*append-mode*/
                                                    , yes /*replace-mode*/
                                                    , yes /*loose-mode*/
                                                    ) no-error.

    end.
    when "gds-dyn-sal" then do:
      glog = buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                      buffer gds-dyn-salt:handle
                                                    , yes /*append-mode*/
                                                    , yes /*replace-mode*/
                                                    , yes /*loose-mode*/
                                                    ) no-error.
    end.
    when "cd-dyn-sal" then do:
      glog = buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                     buffer cd-dyn-salt:handle
                                                    , no /*append-mode*/
                                                    , yes /*replace-mode*/
                                                    , yes /*loose-mode*/
                                                    ) no-error.

    end.

    when "obj-dyn-sal" then do:
      glog = buf_temp-xml-tables.tbl-handle:copy-temp-table(
                                                     buffer obj-dyn-salt:handle
                                                    , no /*append-mode*/
                                                    , yes /*replace-mode*/
                                                    , yes /*loose-mode*/
                                                    ) no-error.

    end.

end case.
end.
delete object v_obj-dataseth