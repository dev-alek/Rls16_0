block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ord-mrz.p $
$Archive: cus/ord-mrz.p $

Cоздание расходного внутр запроса +

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 08/05/04 3:46

*/

define input parameter parParentProc  as widget-handle no-undo.
define input parameter par-recid      as recid no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-mrz.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-mrz.p $":U .
define variable vss-description as character no-undo init "Cоздание расходного внутр запроса +".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ cmp/library.i }
{ gbl/waitfram.i }
{ cmp/gds-list.i gds-list def "new shared"}
{ cmp/showinf.i }
{ gbl/getcntxt.i def }
{ cus/ord-code.i def }


define variable g#host-name  as character no-undo .
define variable g#host-code    as integer   no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#log      as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#db-remote as logical   no-undo .
define variable g#in-ov      as logical   no-undo .
define variable g#rsrv-time  as decimal   no-undo .
define variable g#load-time as decimal   no-undo .
define variable g#holidays  as character no-undo .

define variable vt-obj-type as character no-undo .
define variable vt-obj-code as integer   no-undo .
define variable vt-host-code as integer   no-undo .

define buffer buf_sysconf for ub.sysconf  .

if parParentProc = ? then
   parParentProc = this-procedure .
define buffer bf_trn-doc for ub.trn-doc  .
define buffer bf_clients for ub.clients  .


find bf_trn-doc no-lock where recid(bf_trn-doc) = par-recid no-error .
  if not available bf_trn-doc   then return.
     vt-obj-type = bf_trn-doc.cli-type .
     vt-obj-code = bf_trn-doc.cli-code .
find first bf_clients no-lock where
     bf_clients.obj-type = vt-obj-type and
     bf_clients.obj-code = vt-obj-code no-error .
  if error-status :error then return .
     vt-host-code = bf_clients.host-code .




{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
  g#db-remote   = (v-cntxt-db-num <> 0)

.
{ gbl/hostname.i store-type store-code  g#host-code g#host-name }
run get-report-num  in parParentProc ( output g#report-num ).

find first buf_sysconf no-lock where buf_sysconf.host-code = g#host-code .
g#in-ov       = buf_sysconf.in-ov        .
g#rsrv-time   = buf_sysconf.rsrv-time    .
g#load-time   = buf_sysconf.load-time    .
g#holidays    = buf_sysconf.holidays    .


define buffer buf-oo_trn-doc     for ub.trn-doc.
define buffer buf-oo_ord-doc-rcv for ub.ord-doc-rcv.

define variable r-rec as recid no-undo.
define buffer buf_ord-doc-rcv  for ub.ord-doc-rcv.
define buffer buf_ord-line-rcv for ub.ord-line-rcv.
define buffer buf_doc-line     for ub.doc-line.
define buffer buf_gds-dtl      for ub.gds-dtl.
define buffer buf_ord-dtl-rcv  for ub.ord-dtl-rcv.
define buffer bb_trn-doc       for ub.trn-doc.
define variable v-flag-rcv as logical no-undo init false .

define variable loc-rcv-num as  character no-undo .
define variable g-log as logical no-undo .

find buf-oo_trn-doc no-lock where recid(buf-oo_trn-doc) = par-recid no-error .
  if not available buf-oo_trn-doc   then return.
     vt-obj-type = buf-oo_trn-doc.cli-type .
     vt-obj-code = buf-oo_trn-doc.cli-code .

  if not (buf-oo_trn-doc.status_  = {&inquiry}   and
          buf-oo_trn-doc.flag_    = true         and
          buf-oo_trn-doc.doc-type = {&income}  ) then do:

    message "Создать расходный внутренний запрос можно только на ЗАПР+ !"
            view-as alert-box information .
    return .
  end.

  v-flag-rcv = true .
define variable v-rcv-code as character no-undo .

  for each ub.ord-chain no-lock where
           ub.ord-chain.rel-doc-code = buf-oo_trn-doc.doc-code and
           ub.ord-chain.doc-type = 'rcv'                  and
           ub.ord-chain.rel-doc-type = 'trn'
           :
      v-flag-rcv = false  .
      v-rcv-code = ub.ord-chain.doc-code.
  end.

   /* для отправки по новостям заказа */
  define buffer buf_ord-doc for ub.ord-doc  .
  find first buf-oo_ord-doc-rcv no-lock where buf-oo_ord-doc-rcv.rcv-code = v-rcv-code no-error .
  find first buf_ord-doc exclusive-lock where
             buf_ord-doc.doc-code = buf-oo_ord-doc-rcv.doc-code no-error .
  if available buf_ord-doc then do:
     assign
        buf_ord-doc.flag_ = true .
     .
  end.



define variable v-obj-is-active as logical no-undo .
define buffer buf_clients for ub.clients.


{ gbl/objat.i
  buf-oo_trn-doc.cli-type
  buf-oo_trn-doc.cli-code
  "'active=request'"
  v-obj-is-active
  no-error
}
    if v-obj-is-active = false then do:
    find first buf_clients no-lock where
             buf_clients.obj-type = buf-oo_trn-doc.cli-type and
             buf_clients.obj-code = buf-oo_trn-doc.cli-code    .
    if not g#news then
       message "Создать расходный внутренний запрос можно только на активной стороне " skip
              buf-oo_trn-doc.cli-type
              buf-oo_trn-doc.cli-code skip
              "На базе данных № " buf_clients.db-num skip
              view-as alert-box information .
    return .
  end.

define variable m-ord as character no-undo .
define variable v-ord as character no-undo .
define variable v-flag as logical no-undo init false .
define variable v-num as character no-undo .


/*  Проверить может уже есть на этот ПН РН */
   run main-ord in this-procedure ( input buf-oo_trn-doc.doc-code  ,  output  m-ord ) .
   for each   bb_trn-doc no-lock where
              bb_trn-doc.doc-type = {&expense} and
              bb_trn-doc.doc-code begins  entry( 1 , buf-oo_trn-doc.doc-code , "-" )
             :
              run main-ord in this-procedure ( input bb_trn-doc.doc-code ,  output  v-ord ) .

              if m-ord = v-ord then do:
                 v-flag = true .
                 v-num = bb_trn-doc.doc-code .
                 leave.
              end.
   end.

if v-flag = true  then do:
    if not g#news then
    message "Уже есть расходный внутренний запрос :" v-num skip
            "на этот  приходный внутренний запрос :" buf-oo_trn-doc.doc-code
            view-as alert-box information .
    return .
end.

g-log = true .

  if not g#news then do:
  message "Создать расходный внутренний запрос ?"
    view-as alert-box question
    buttons yes-no
    update g-log .
  end.

  if g-log = false then return .

 run waitfram-show in this-procedure ( "Ждите , создание внутреннего расходного запроса - " ) .
/*------------------------------------*/
 if v-flag-rcv = true then do:
    run str/prirasiq.p (parParentProc, buf-oo_trn-doc.doc-code) .
    run waitfram-hide in this-procedure .
    return  .
 end.
/*------------------------------------*/
define variable v-i-doc as character no-undo .
{ cus/ord-code.i
    'main'
    v-cntxt-db-num
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-i-doc
    loc-rcv-num
    }

    create buf_ord-doc-rcv.
    BUFFER-COPY buf-oo_ord-doc-rcv to buf_ord-doc-rcv
    assign
      buf_ord-doc-rcv.rcv-code  = loc-rcv-num
    .

    for each buf_doc-line no-lock where
             buf_doc-line.doc-code =  buf-oo_trn-doc.doc-code :
             create buf_ord-line-rcv.
             BUFFER-COPY buf_doc-line to buf_ord-line-rcv
             assign
               buf_ord-line-rcv.rcv-code  = loc-rcv-num
               buf_ord-line-rcv.doc-code  = buf-oo_ord-doc-rcv.doc-code
               buf_ord-line-rcv.qnty      = buf_doc-line.doc-qnty
             .
    end. /* for each */
    for each buf_gds-dtl no-lock where
             buf_gds-dtl.doc-code =  buf-oo_trn-doc.doc-code :
             create buf_ord-dtl-rcv.
             BUFFER-COPY buf_gds-dtl to buf_ord-dtl-rcv
             assign
               buf_ord-dtl-rcv.rcv-code  = loc-rcv-num
               buf_ord-dtl-rcv.doc-code  = buf-oo_ord-doc-rcv.doc-code
               buf_ord-dtl-rcv.node-code = buf_gds-dtl.prt-code
               buf_ord-dtl-rcv.qnty      = buf_gds-dtl.doc-qnty
             .
    end. /* for each */

    r-rec = recid(buf_ord-doc-rcv).

    run cus/ord-trnz.p
                   ( parParentProc ,
                    input  r-rec ,
                    input  {&expense},
                    input  buf-oo_trn-doc.doc-code ) no-error .

    if error-status :error then do:
      if not g#news then do:
      message vss-workfile vss-revision vss-description skip
             "Ошибка ord-trnz.p " skip
              skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error
      .
      end.
      delete buf_ord-doc-rcv .
      return .
    end.

    /*закроем на ЗАПР + */
    run waitfram-show in this-procedure ( "Ждите , закрытие на запр+ " ) .
    for each ub.ord-chain no-lock where
              ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
              ub.ord-chain.doc-type = 'rcv'                  and
              ub.ord-chain.rel-doc-type = 'trn'
        :
        run close-zapr in this-procedure (ub.ord-chain.rel-doc-code) .
    end.
    find current buf_ord-doc-rcv  exclusive-lock  .
                 buf_ord-doc-rcv.status_ = {&ord-rcv} .  /* чтоб ушло по новостям вместе с ЗАПР+ */

    run waitfram-hide in this-procedure .


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


define buffer buf_s-trn-doc for ub.trn-doc.
define variable varmode            as   character           no-undo.
define variable varstatus          like ub.trn-doc.status_  no-undo.
define variable varflag            like ub.trn-doc.flag     no-undo.
define variable varcopystatus      like ub.trn-doc.status_  no-undo.
define variable varcopyflag        like ub.trn-doc.flag     no-undo.
define variable varcheck-return as logical no-undo .
define variable varchg-inv as logical no-undo .
assign
  varmode        =  {&close-doc}
  varstatus      = {&inquiry}
  varflag        = false
  varcopystatus  = {&inquiry}
  varcopyflag    = true
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


PROCEDURE main-ord :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define input parameter   p-in-ord-num as character no-undo .
define output parameter  p-out-ord-num as character no-undo .

if num-entries(p-in-ord-num , "." ) = 1 then
   p-out-ord-num = p-in-ord-num .
   else do:
     p-out-ord-num = entry(1, entry( 1 , p-in-ord-num , "." ) , "-" )  + "-" + entry( 2 , p-in-ord-num , "."  ) .
   end.


  end.  /* do */
END PROCEDURE.

procedure mainmenu_getcntxt :
define output parameter p-cntxt-db-num                as integer   no-undo . /* текущая БД            */
define output parameter p-cntxt-userid                as character no-undo . /* текущий пользователь  */
define output parameter p-cntxt-level                 as character no-undo . /* уровень контекста     */
define output parameter p-cntxt-host-code-obj         as integer   no-undo . /* текущая фирма         */
define output parameter p-cntxt-obj-type              as character no-undo . /* тип текущего объекта  */
define output parameter p-cntxt-obj-code              as integer   no-undo . /* код текущего объекта  */
define output parameter p-cntxt-db-num-obj            as integer   no-undo . /* база текущего объекта */
define output parameter p-cntxt-is-admin              as logical   no-undo . /* база текущего объекта */

  do
  on error undo, return error return-value
  :
  { gbl/objdbnum.i
     vt-obj-type
     vt-obj-code
     p-cntxt-db-num-obj
     }

  assign
    p-cntxt-db-num          =  v-cntxt-db-num
    p-cntxt-userid          =  v-cntxt-userid
    p-cntxt-level           =  v-cntxt-level
    p-cntxt-host-code-obj   =  vt-host-code
    p-cntxt-obj-type        =  vt-obj-type
    p-cntxt-obj-code        =  vt-obj-code
    p-cntxt-is-admin        =  v-cntxt-is-admin
  .

  end.
 end procedure. /* mainmenu_getcntxt */


procedure get-report-num :
  define output parameter p-report-num as integer no-undo .
   do
   on error undo, return error return-value
   :
    assign
      p-report-num = 1
    .
   end.

 end procedure. /* get-report-num */