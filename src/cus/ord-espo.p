block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ord-espo.p $
$Archive: cus/ord-espo.p $

Создание внешней расходной накладной по заказу покупателЯ

Автор: Чернова Светлана Александровна
Дата создания: 08/23/06
Author: Svetlana Chernova
Creation date: 08/23/06

*/
define input  parameter ParParentProc as handle no-undo .
define input  parameter p-ord-recid   as recid no-undo .
define output parameter p-doc-code as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-espo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-espo.p $":U .
define variable vss-description as character no-undo init "Создание внешней расходной накладной по заказу покупателя".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/showinf.i }
{ gbl/waitfram.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ cus/ord-code.i def }
{ cmp/gds-list.i gds-list def "new shared"}

define buffer buf_ord-doc      for ub.ord-doc.
define buffer buf_trn-doc      for ub.trn-doc.
define buffer buf_ord-line     for ub.ord-line.
define buffer buf_ord-dtl      for ub.ord-dtl.
define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv.
define buffer buf_ord-line-rcv for ub.ord-line-rcv.
define variable v-ord-num as character no-undo .
define variable v-host-code as integer   no-undo .
define variable p-rcv-code as character no-undo .

find first  buf_ord-doc no-lock where recid ( buf_ord-doc ) = p-ord-recid no-error .
if error-status :error then return .
v-ord-num = buf_ord-doc.doc-code .
{ gbl/hostcode.i
  buf_ord-doc.obj-type
  buf_ord-doc.obj-code
  v-host-code
  }

/* 1. Создать поставку                     */
/* 2. Закрыть поставку до статуса поставка */
/* 3. Создать внешнюю РН в статусе ЗАПР-   */
/* 4. закрыть накладную до НАКЛ + или ЗАПР+ */
/* в своей БД до накл+ в чужой до запр+     */
/* 5. если количеств не хватает предложить создание заявок */

run waitfram-show in this-procedure ( "Формирование РН...." ) .
do transaction
on error undo, return error return-value
:

/* 1. Создать поставку  */
run create-rcv in this-procedure
    (output p-rcv-code ) no-error .

    if error-status :error then do:
          message  return-value
          error-status :get-message(1)
          view-as alert-box error .
          undo, return error .
    end.

/* 2. Закрыть поставку до статуса поставка */
find first buf_ord-doc-rcv exclusive-lock where
           buf_ord-doc-rcv.rcv-code =  p-rcv-code and
           buf_ord-doc-rcv.doc-code =  v-ord-num
           no-error .
    if error-status :error then do:
        message  return-value
        error-status :get-message(1)
        view-as alert-box error .
        undo, return error .
    end.
    buf_ord-doc-rcv.status_  = {&ord-rcv} .


/* 3. Создать внешнюю РН в статусе ЗАПР-   */
run cus/ord-trn.p
    ( input parparentproc ,
      input recid (buf_ord-doc-rcv) ,
      input no
      ) no-error .
    if error-status :error then do:
        message  return-value
        error-status :get-message(1)
        view-as alert-box error .
        undo, return error .
    end.
find first  buf_ord-doc exclusive-lock where recid ( buf_ord-doc ) = p-ord-recid no-error .
assign
   buf_ord-doc.status_  = {&ord-rcv}
   .


for each ub.ord-chain no-lock where
         ub.ord-chain.doc-code =  p-rcv-code and
         ub.ord-chain.doc-type = 'rcv'                  and
         ub.ord-chain.rel-doc-type = 'trn'
         :
    for each buf_trn-doc exclusive-lock where
             buf_trn-doc.doc-code  = ub.ord-chain.rel-doc-code
             :
             buf_trn-doc.flag_  = true .
    end.
end.
/*  Проверим текущую БД и БД объекта документа */
if v-host-code = v-cntxt-host-code-obj then do:
define variable v-make-z as logical   no-undo .
define variable p-rez as logical   no-undo .
define variable p-ord-doc as character no-undo .
define buffer buf_gds-obj for ub.gds-obj  .

v-make-z = false .

for each buf_ord-line no-lock where
         buf_ord-line.doc-code = buf_ord-doc.doc-code
         :
         find first buf_gds-obj no-lock where
                    buf_gds-obj.obj-type = buf_ord-doc.obj-type and
                    buf_gds-obj.obj-code = buf_ord-doc.obj-code and
                    buf_gds-obj.gds-code = buf_ord-line.gds-code no-error .
         if not available buf_gds-obj then do:
            v-make-z = true  .
            leave.
         end.
          if buf_ord-line.qnty > buf_gds-obj.free-qnty  then do:
            v-make-z = true  .
            leave.
          end.
end.
if v-make-z = true  then do:
   run cus/ord-chtp.w
    ( input  parParentProc ,
      input  recid(buf_ord-doc) ,
      output p-rez ,
      output p-ord-doc )    .
      if p-rez = true and
         p-ord-doc <> "" then do:
           message "Создана заявка № " p-ord-doc .
         end.
end.
    /* закрыть накладную */
    for each ub.ord-chain no-lock where
            ub.ord-chain.doc-code =  p-rcv-code and
            ub.ord-chain.doc-type = 'rcv'                  and
            ub.ord-chain.rel-doc-type = 'trn'
            :
      run close-zapr (input ub.ord-chain.rel-doc-code ) no-error .
    end.
end.
end.
run waitfram-hide in this-procedure .



procedure create-rcv :
define output parameter v-rcv-num as character no-undo .
  do
  on error undo, return error return-value
  :

define variable v-i-doc as character no-undo .
{ cus/ord-code.i
    'main'
    v-cntxt-db-num
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-i-doc
    v-rcv-num
    }

create ub.ord-doc-rcv.
buffer-copy buf_ord-doc to ub.ord-doc-rcv
   assign
      ub.ord-doc-rcv.rcv-code  = v-rcv-num
      ub.ord-doc-rcv.doc-type  = "out":U
      ub.ord-doc-rcv.doc-date  = today
      ub.ord-doc-rcv.status_   = {&g___new}
   .

for each buf_ord-line no-lock where
         buf_ord-line.doc-code = buf_ord-doc.doc-code
         :
         create ub.ord-line-rcv.
         buffer-copy buf_ord-line to ub.ord-line-rcv
         assign
           ub.ord-line-rcv.rcv-code  = v-rcv-num
           .
end.

for each buf_ord-dtl no-lock where
         buf_ord-dtl.doc-code = buf_ord-doc.doc-code
         :
         create ub.ord-dtl-rcv.
         buffer-copy buf_ord-dtl to ub.ord-dtl-rcv
         assign
           ub.ord-dtl-rcv.rcv-code  = v-rcv-num
           .
end.
  end.

end procedure. /* create-rcv */

PROCEDURE close-zapr :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input parameter p-trn-code as character no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#db-remote as logical   no-undo .
define variable g#in-ov      as logical   no-undo .
define variable g#rsrv-time  as decimal   no-undo .
define variable g#load-time as decimal   no-undo .
define variable g#holidays  as character no-undo .
define buffer buf_sysconf for ub.sysconf  .


find first buf_sysconf no-lock where buf_sysconf.host-code = v-cntxt-host-code-obj .
g#in-ov       = buf_sysconf.in-ov        .
g#rsrv-time   = buf_sysconf.rsrv-time    .
g#load-time   = buf_sysconf.load-time    .
g#holidays    = buf_sysconf.holidays    .



define buffer buf_s-trn-doc for ub.trn-doc.
define variable varmode            as   character           no-undo.
define variable varstatus          like ub.trn-doc.status_  no-undo.
define variable varflag            like ub.trn-doc.flag     no-undo.
define variable varcopystatus      like ub.trn-doc.status_  no-undo.
define variable varcopyflag        like ub.trn-doc.flag     no-undo.
define variable varcheck-return as logical no-undo .
define variable varchg-inv as logical no-undo .
assign
  varmode        = {&close-doc}
  varstatus      = {&inquiry}
  varflag        = true
  varcopystatus  = {&wayb}
  varcopyflag    = false
  varcheck-return = true
  varchg-inv = true
  .

run str/trn-graf.p
               (input  p-trn-code,
                input  v-cntxt-db-num,
                input  varmode,
                output varstatus,
                output varflag,
                output varcopystatus,
                output varcopyflag
                ) no-error.
.
if error-status:error then do:
   if error-status :get-message(1) <> "" or
      return-value = ""                  then do:
     message "Ошибка при вызове trn-graf.p." skip
     error-status :get-message(1) skip
     return-value skip
     view-as alert-box error.
   end.
   else do:
     message return-value
     view-as alert-box error.
   end.
   return error.
end.

run str/trn-stat.p
  ( input  parParentProc ,
    input this-procedure ,
    input  varmode,
    input  p-trn-code,
    input  varcheck-return,
    input  v-cntxt-db-num,
    input  g#in-ov,
    input  g#rsrv-time,
    input  g#load-time,
    input  g#holidays,
    input  yes,
    output varchg-inv,
    output table gds-list
    ) no-error.
if error-status:error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка при принудительном закрытии документа " p-trn-code skip
     return-value skip
     trim(error-status :get-message(1))
     trim(error-status :get-message(2))
     trim(error-status :get-message(3))
     trim(error-status :get-message(4))
     trim(error-status :get-message(5)) skip
     view-as alert-box error.
   return error.
end.

  end.  /* do */
END PROCEDURE.