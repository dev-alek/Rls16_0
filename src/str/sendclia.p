block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sendclia.p $
$Archive: str/sendclia.p $

Посылка информации по ДК на все магазины БД написан для того, чтобы  не закрывтаь окно diallog.w при  вызове send-cli.p по каждому объекту

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/16/04
Author: Bakhtadze Natalya
Creation date: 02/16/04

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter p-db-num like ub.db.db-num no-undo .
define input parameter p-batch as logical no-undo .
define input parameter p-action as character no-undo .
*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendclia.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/sendclia.p $":U .
define variable vss-description as character no-undo init "Посылка информации по ДК на все магазины БД из новостей".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }

{ cmp/dc-list.i dc-list def "SHARED" }
{ cmp/dcp-list.i dcp-list def "SHARED" }
{ gbl/clntattr.i }

define variable p-db-num like ub.db.db-num no-undo .
define variable p-optimize as character no-undo .
define variable p-batch as logical no-undo .
define variable p-action as character no-undo .


define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable v-view-log as logical no-undo .
define variable log-file-name as character no-undo init "send-cd.txt":U.
define variable v-stop as logical no-undo .
define variable var-type     as character no-undo .
define variable v-optimize-object like ub.clients.obj-code no-undo .


define buffer buf_clients for ub.clients.
define buffer buf_shop for ub.shop.
define buffer buf_cash-desk for ub.cash-desk.

assign
p-db-num = integer(entry(1, p-parameter, {&delim-par}))
p-optimize = entry(2, p-parameter, {&delim-par})
p-batch = (if entry(3, p-parameter, {&delim-par}) = "yes":U
                 then yes
                 else (if entry(3, p-parameter, {&delim-par}) = "no":U
                       then no
                       else ?)
                 )
p-action = entry(4, p-parameter, {&delim-par})
no-error
.
if error-status:error then return error substitute("Неверные параметры: &1", p-parameter).



if p-optimize = "":U then do:
  _each1:
  FOR EACH buf_clients no-lock where
          buf_clients.obj-type = {&shop}
      and buf_clients.db-num = p-db-num:
    run get-stop-state in p-log-handle (output v-stop).
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
    run str/send-cli.p (
                  input parparentproc
                  ,input p-parent-handle
                  ,input p-log-handle
                  ,input (string(buf_clients.obj-code) + {&delim-par} + p-action + {&delim-par} + "no":U +
                          {&delim-par} + "yes":U)
                    ) no-error .
    if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute("!!!Ошибки при пересылке на маг&1&2&3 &4"
                             , buf_clients.obj-code
                             , {&new-line}
                             , error-status:get-message(1)
                             , return-value
                              )
                                ).
      assign
      v-view-log = yes
      .
    end.
  END.
end.
else do:
  if p-optimize begins "shop=":U then do:
    assign
    v-optimize-object = integer(replace(p-optimize, "shop=", "":U))
    .
  end.
  _each2:
  FOR EACH buf_clients no-lock where
          buf_clients.obj-type = {&shop}
      and buf_clients.db-num = p-db-num
      and (v-optimize-object = 0 or buf_clients.obj-code = v-optimize-object)
      ,
      FIRST buf_cash-desk where
            buf_cash-desk.obj-code = buf_clients.obj-code:
    /*сначала допишем в gds-list те записи которые предназначены ТОЛЬКО данному магазину*/
    for each dcp-list no-lock where
          dcp-list.obj-type = {&shop}
        AND dcp-list.obj-code = buf_clients.obj-code:
      find first dc-list where
                  dc-list.d-card = dcp-list.d-card no-error .
      if avail dc-list
      and dc-list.order-num > dcp-list.order-num then NEXT.
      if not avail dc-list then do:
        find first ub.dis-card no-lock where
                    ub.dis-card.d-card = dcp-list.d-card no-error .
        { cmp/dc-list.i dc-list assign }
      end.
      if avail dc-list then
      assign
      dc-list.order-num = dcp-list.order-num
      /*сигнал для cash-cli.p чтобы стер эту запись*/
      dc-list.flog =  yes
      .
      run get-stop-state in p-log-handle (output v-stop).
      if v-stop then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!!!Процедура пересылки остановлена пользователем"
                                )
                                  ).
        leave _each2.
      end.
    end. /*for each dcp-list no-lock where*/
    if can-find (first dcp-list no-lock where dcp-list.obj-type = {&shop} and dcp-list.obj-code = buf_clients.obj-code)
    or can-find(first dc-list)
    then  do:
      run str/send-cli.p (
                    input parparentproc
                    ,input p-parent-handle
                    ,input p-log-handle
                    ,input (string(buf_clients.obj-code) + {&delim-par} + p-action + {&delim-par} + "no":U +
                            {&delim-par} + (if p-action = "E":U then "no" else "yes")
                              )
                      ) no-error  .
      if error-status:error then do:
        assign
        v-view-log = yes
        .
      end.
    end.
  END. /*FOR EACH buf_clients no-lock where*/
end. /*optimize*/

if p-batch then do:
  if v-view-log then
  run set-view-log in p-log-handle(yes).
end.
else do:
  { str/cdviewlg.i
  "'!!!При отсылке информации на кассы произошли ошибки!!!'"
  "'send-cd.txt'" }
end.