block-level on error undo, throw.
 /*

$Revision: 54e7b0cc03ed, 638, rls $
$Author: ASMorozov $
$Date: Wed Jun 01 18:13:33 2016 +0400 $
$Workfile: cleaning-utm.p $
$Archive: utl/cleaning-utm.p $

Процедура очистки УТМ по расписанию


Автор: Морозов Александр Сергеевич
Дата создания: 05/25/16
Author: Morozov Alexandr
Creation date: 05/25/16

*/


using ibs.th.bge.egais.*.

define input parameter parparentproc    as widget-handle no-undo.
define input parameter p-parent-handle  as widget-handle no-undo.
define input parameter p-log-handle     as handle        no-undo.
define input parameter p-cre-db-num     as integer       no-undo.
define input parameter p-task-type      as character     no-undo.
define input parameter p-task-num       as integer       no-undo.
define input parameter p-db-num         as integer       no-undo.

define variable vss-revision    as character no-undo init "$Revision: 54e7b0cc03ed, 638, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Wed Jun 01 18:13:33 2016 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cleaning-utm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/cleaning-utm.p $":U .
define variable vss-description as character no-undo init "Процедура очистки УТМ по расписанию".

define variable admUtmObj         as class     admutm no-undo.
define variable v-fs-rar          as character no-undo. 
define variable url_              as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable v-value-type      as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-ext-sys         as integer   no-undo .

{ cmp/str-glbl.i }
{ adm/auto-def.i }
{ gbl/thbjattr.i }

&scop display-message    run write-log-and-file in p-log-handle (  ~
        input 1                                                      ~
      , input log-file-name                                          ~
      , input 1                                                      ~
      , input ~{&my-message~})

do
on error undo, return error return-value
:

  log-file-name = "shd-free.log".

  for each ub.clients where ub.clients.db-num = p-db-num no-lock:

    empty temp-table thbjattr_thbj-attr .
    run adm/shattri.p (
         input "get":U
        ,input ub.clients.obj-type
        ,input ub.clients.obj-code
        ,input {&attr-egais-host}
        ,input {&attr-egais-host_egais-fsrar}
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-value-type
        ,input-output TABLE thbjattr_thbj-attr
        ) no-error .
    assign 
      v-fs-rar = v-value-character 
    .
    
    run adm/shattri.p (
         input "get":U
        ,input '':U
        ,input 0
        ,input {&attr-egais-host}
        ,input {&attr-egais-host_egais-exsys}
        ,output v-value-character
        ,output v-value-date
        ,output v-value-decimal
        ,output v-value-integer
        ,output v-value-logical
        ,output v-value-type
        ,input-output TABLE thbjattr_thbj-attr
        ) no-error .
    assign v-ext-sys = v-value-integer .
    
    admUtmObj = new admutm (ub.clients.obj-type, ub.clients.obj-code, v-fs-rar, v-ext-sys).
    if admUtmObj:ConPar = "" or v-fs-rar = "" or v-ext-sys = 0
    then do:
      delete object admUtmObj.
      next.
    end.

     &scop my-message  ("Начало очистки УТМ" + {&new-line} + "Адрес: " + admUtmObj:ConPar + {&new-line} + "FSRAR: " + v-fs-rar + {&new-line} + "ВС: " + string (v-ext-sys) +  {&new-line} + "Объект: " + ub.clients.obj-type + string (ub.clients.obj-code))
    
    {&display-message}.
    
    find first ub.ext-system-attr where ub.ext-system-attr.db-num = 0 
      and ub.ext-system-attr.esys-id = v-ext-sys and ub.ext-system-attr.esya-attr-code = {&attr-esys-save-oxml-pck} no-lock.
    
    admUtmObj = new admutm (ub.clients.obj-type, ub.clients.obj-code, v-fs-rar, v-ext-sys).
    admUtmObj:Cleaning(integer (ub.ext-system-attr.esya-attr-value), p-log-handle).
    delete object admUtmObj.    
      
    &scop my-message  "Окончание очистки УТМ"
    {&display-message}.
      
  end.


end.

