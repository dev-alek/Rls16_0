block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: adelrt.p $
$Archive: bge/adelrt.p $

Процедура произвольных автозаданий удаления маршуртизации ВС, работающих без подтверждения, и старых BatchProcess

Автор: Морозов Александр Сергеевич
Дата создания: 02/27/13
Author: Morozov Alexandr
Creation date: 02/26/13

*/

define input parameter parparentproc    as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-db-num-char    as character    no-undo.
define input parameter p-task-type      as character    no-undo.
define input parameter p-task-num       as integer      no-undo.
define input parameter p-db-num         as integer      no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: adelrt.p $":u .
define variable vss-archive     as character no-undo init "$Archive: bge/adelrt.p $":u .
define variable vss-description as character no-undo init  "Процедура произвольных автозаданий удаления маршуртизации ВС, работающих без подтверждения" .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ ref/shd-attr.i }
{ adm/auto-def.i }
{gbl/waitfram.i  }

define buffer buf_BatchProcess for ub.BatchProcess.

define variable v-task-num        as integer      no-undo.
define variable v-param-list      as character    no-undo.
define variable v-param-type      as character    no-undo.
define variable v-rec-extsys-list as character    no-undo.
define variable ii as integer no-undo.
define variable kk as integer no-undo.
define variable j as integer no-undo.
define variable v-last-num-pck as integer no-undo.
define variable v-rec-ext-sys as recid no-undo.
define variable v-day-shift as integer no-undo.

&scop display-message    run write-log-and-file in p-log-handle (  ~
    input 1                                                      ~
    , input log-file-name                                          ~
    , input 1                                                      ~
    , input ~{&my-message~})

run schedule-attr-value in this-procedure (            /* процедура получания параметров расписания */
  input integer(p-db-num-char)
  , input p-task-type
  , input p-task-num
  , input {&attr-schedule-param-list-h}
  , output v-param-list
  , output v-param-type
  ) no-error.

for each buf_BatchProcess exclusive-lock
  where buf_BatchProcess.BP_Status         = {&btpr-normal}
    and buf_BatchProcess.BP_Type           = {&btpr-type-autooxml}
    and buf_BatchProcess.CharKey_Two       = "auto":U
    and ( buf_BatchProcess.BP_ExecSysDate <= today - 1 )
    and num-entries (buf_BatchProcess.CharKey_Three, {&delim-key}) > 3 
  :
                    
  delete buf_BatchProcess.

end.

&scop my-message SUBSTITUTE("Удаление маршрутизации ВС.")
{&display-message}.
if v-param-list <> "" then
do:
  assign
    v-rec-extsys-list = entry (1, v-param-list, "!")
    v-day-shift = integer(entry (2, v-param-list, "!"))
  .
  &scop my-message SUBSTITUTE("Установлено &1 дн. хранения пакетов.", v-day-shift)
  {&display-message}.
  do j = 1 to num-entries (v-rec-extsys-list, ',') .
    assign
      v-rec-ext-sys =  integer (entry (j, v-rec-extsys-list, ',')).
    find first ub.ext-system no-lock where recid(ub.ext-system) = v-rec-ext-sys no-error.
    if not available ub.ext-system then next .
    &scop my-message SUBSTITUTE("ВС " + ub.ext-system.esys-name + " № " + string (ub.ext-system.esys-id) + ". Удаление..." )
    {&display-message}.  
    find last ub.esys-pck-sent no-lock where ub.esys-pck-sent.esps-rcvd = no 
      and ub.esys-pck-sent.esys-id = ub.ext-system.esys-id 
      and ub.esys-pck-sent.esps-sendtxtdate <= today - v-day-shift use-index pi no-error.
    if available ub.esys-pck-sent then assign v-last-num-pck = ub.esys-pck-sent.esps-pack-num .
    release ub.esys-pck-sent.
    for each ub.esys-pck-sent share-lock where ub.esys-pck-sent.esps-rcvd = no 
      and ub.esys-pck-sent.esys-id = ub.ext-system.esys-id 
      and ub.esys-pck-sent.esps-sendtxtdate <= today - v-day-shift by esps-pack-num   
    :
      run waitfram-show in this-procedure (INPUT substitute ("Удаление маршрутизации: Пакет № &1 (посл. пакет № &2)",  string (esys-pck-sent.esps-pack-num), v-last-num-pck)).
      do transaction.
        for each ub.esys-route share-lock where
                      ub.esys-route.esys-id = ub.esys-pck-sent.esys-id
                  and ub.esys-route.db-num = ub.esys-pck-sent.db-num
                  and ub.esys-route.esr-cr-db-num = ub.esys-pck-sent.esps-cr-db-num
                  and ub.esys-route.esr-last-pack = ub.esys-pck-sent.esps-pack-num :
            
            delete ub.esys-route.                  
            ii = ii + 1 .
            if ii mod 10 = 0 then run waitfram-show in this-procedure (INPUT substitute ("Удаление маршрутизации: Пакет № &1 (посл. пакет № &2). Удалено записей в пакете &3",  string (ub.esys-pck-sent.esps-pack-num), v-last-num-pck, string (ii))).
        end.
        ub.esys-pck-sent.esps-rcvd = yes.
        ii = 0 .
      end /*trans*/.
      assign
        kk = kk + 1.                                                                                 
    end.
    &scop my-message SUBSTITUTE("Удалено &1 пакетов ВС № &2.", kk, ub.ext-system.esys-id)
    {&display-message}.
    assign
      kk = 0 . 
  end.
  &scop my-message SUBSTITUTE("Удаление завершено.")
  {&display-message}.  
end.
else do:
  &scop my-message SUBSTITUTE("Не заданны параметры удаления. Удаление завершено.")
  {&display-message}.  
end.





