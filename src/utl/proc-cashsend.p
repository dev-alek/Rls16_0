block-level on error undo, throw.
/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рубан Дмитрий Андреевич 
Дата создания: 9 марта 2020 г.
Author:  Ruban Dmitriy Andreevich
Creation date: 9 марта 2020 г.

*/
define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
define variable mError as logical no-undo.
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ utl/proc-async.i proc_def}
{ adm/auto-def.i}
{ cmp/trg-def.i }
{ str/auto2dia.i &highest-window-handle = this-procedure}
{ cmp/gds-list.i gds-list def "new shared" }

define variable mSocetLog as character no-undo.
define variable mobjsend as character no-undo.
define variable mshop as integer no-undo.
define variable mcashnum as character no-undo init "?".
define variable mMaxGoods as integer no-undo.
mSocetLog = GetParamAsunc(1).
mobjsend  =  GetParamAsunc(2).
mshop     = int(GetParamAsunc(3)) no-error.
if    error-status:error
   or mshop eq ? 
then do:    
   run PutMesAsunc( "error  Не получен номер магазина" ).
   { utl/proc-async.i proc_end}
   return.
end.
define variable mparam as character no-undo.
mparam = GetParamAsunc(4).
if     mparam ne ""
   and mparam ne ?
then
   mCashNum  = mparam.
mMaxGoods = int(GetParamAsunc(5)) no-error.
if mobjsend eq "goods"
then do:
   define variable mGoods as integer no-undo.
   block-Goods:
   for each goods no-lock:
      mGoods = mGoods + 1.
      if     mMaxGoods ne ?
         and mMaxGoods ne 0
         and mMaxGoods lt mGoods
      then
         leave block-Goods.      
      create gds-list.
      buffer-copy goods to gds-list.
   end.
   run str/diallog.w (
                         &if "{&imp2cd_parparentproc}" <> '' &then
                         input {&imp2cd_parparentproc}
                         &else
                         input ?
                         &endif
                        ,input ?
                        ,input 'str/send-gds-onecash.p':U
                        ,input substitute ("&2&1&3&1&4&1&5",
                                           {&delim-par},
                                           mshop,
                                           yes,
                                           ?,
                                           mcashnum)
                        ,input yes /*p-auto-go*/
                        ,input '':U
                        ,input 'Отправка информации на кассу') no-error .
end.
else if mobjsend eq "gismt" or mobjsend eq "posonline" then do:
    run str/diallog.w (
        &if "{&imp2cd_parparentproc}" <> '' &then
        input {&imp2cd_parparentproc}
        &else
        input ?
        &endif
      , input ?
      , input "str/sendgismt.p":U
      , input substitute ("&2&1&3&1&4&1&5&1&6&1cash-send=&7,&8,&9", 
                                   {&delim-par}, 
                                   {&shop}, 
                                   mshop,
                                   'U':U,
                                   "gismt",
                                   'Передача настроек для проверки КМ':U,
                                   mCashNum,
                                   "SocetLog=" + mSocetLog,
                                   "cash-all=all"
                                   )
      , input ? /*p-auto-go*/
      , input "":U
      , input substitute("Отсылка настроек для проверки КМ")
  ) no-error.
end.       
else
   run str/send-all.p(?, 
                      this-procedure,
                      this-procedure, 
                      substitute ("&2&1&3&1&4&1&5&1&6&1cash-send=&7,&8", 
                                   {&delim-par}, 
                                   {&shop}, 
                                   mshop,
                                   'U':U,
                                   mobjsend,
                                   'Получение параметров кассы':U,
                                   mCashNum,
                                   "SocetLog=" + mSocetLog
                                   )
                      )
   .
{ utl/proc-async.i proc_end}
