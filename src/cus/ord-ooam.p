block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ord-ooam.p $
$Archive: cus/ord-ooam.p $

автоматическое распределение заказа по запросам


Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Creation date: 07/01/04 4:49

*/

define input parameter parParentProc  as widget-handle no-undo.
define input-output parameter p-ord-doc-recid as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-ooam.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-ooam.p $":U .
define variable vss-description as character no-undo init "Распределение ручное".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cus/df-zakaz.i new }
{ cmp/r-page1.i  new }
{ rep/gn-extp.i  }
{ ref/grplibfn.i }
{ gbl/waitfram.i }
{ ref/grpobj.i   }
{ cmp/showinf.i  }
{ gbl/getcntxt.i def }
{ cus/ord-code.i def  }
{ gbl/thbjattr.i }

define variable to-arm      as character no-undo .
define variable store-type   as character no-undo .
define variable store-code   as integer   no-undo .
define variable g#db-remote as logical   no-undo .

{ gbl/getcntxt.i get }
assign
  store-type    = v-cntxt-obj-type
  store-code    = v-cntxt-obj-code
  g#db-remote   = (v-cntxt-db-num <> 0)

.

define variable rid-list as character no-undo .

define buffer buf_ord-doc for ub.ord-doc.
DEFINE BUFFER buf_goods FOR ub.goods.
DEFINE BUFFER X_doc-line FOR ub.doc-line.
DEFINE BUFFER X_gds-obj FOR ub.gds-obj.
DEFINE BUFFER X_goods FOR ub.goods.
DEFINE BUFFER X_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER buf_ord-doc-rcv FOR ub.ord-doc-rcv.
DEFINE BUFFER buf_ord-line-rcv FOR ub.ord-line-rcv.
DEFINE BUFFER X_ord-line FOR ub.ord-line.
DEFINE BUFFER X_trn-doc FOR ub.trn-doc.
define buffer   buf2-ord-doc-rcv  for ub.ord-doc-rcv .
define buffer   buf2-doc-line     for ub.doc-line     .


define temp-table temp-rcv-line no-undo like ub.ord-line-rcv
field cli-type as character
field cli-code as integer
.



find first buf_ord-doc  exclusive-lock  where
           recid(buf_ord-doc) = p-ord-doc-recid
           no-error .
if error-status :error then do:
message vss-workfile vss-revision vss-description skip
    "Ошибка  " skip
      skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error
.
return error.
end.

define variable  v-cli-type as character no-undo .
define variable  v-cli-code as integer no-undo .
define variable  v-node-code as integer no-undo .
define variable v-recid as recid no-undo .

define variable  v-range-income-cli     as integer      no-undo.
define variable  v-exists-income-cli    as logical      no-undo.

define variable v-old-qnty                as decimal no-undo .
define variable v-delta                   as decimal no-undo .
define variable v-temp-rcv-line_qnty      as decimal no-undo .

define variable  par-type    as character no-undo.    /* тип параметра конфигурации */
define variable par-ord-oobj as logical no-undo .
define variable varpurch-code as integer no-undo.
define buffer buf_clients for ub.clients.
define variable v-value-character  as character no-undo .
define variable v-value-date       as date      no-undo .
define variable v-value-decimal    as decimal   no-undo .
define variable v-value-integer    as integer   no-undo .
run adm/shattri.p (
  input "get":U
  ,input ""
  ,input 0
  ,input {&attr-ord-global}
  ,input {&attr-ord-global_ord-oobj}
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output par-ord-oobj
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
  if error-status :error then par-ord-oobj = false .


for each x_ord-line no-lock where
    x_ord-line.doc-code = buf_ord-doc.doc-code,
       each buf_goods no-lock where
            buf_goods.prod-type =  x_ord-line.prod-type and
            buf_goods.prod-code =  x_ord-line.prod-code and
            buf_goods.artic     =  x_ord-line.artic
            break by buf_goods.grp-code
            on error undo, return error :

            if first-of(buf_goods.grp-code) then do:
               run grp-obj-income-cli-value in this-procedure
                 (
                  input buf_goods.grp-code   ,
                  input buf_ord-doc.obj-type ,
                  input buf_ord-doc.obj-code ,
                  output v-cli-type          ,
                  output v-cli-code          ,
                  output v-range-income-cli  ,
                  output v-exists-income-cli   ) .
                 /*
                  message v-cli-type          skip
                          v-cli-code          skip
                          v-range-income-cli  skip
                          v-exists-income-cli skip
                          .
                   */
            end.

         if not v-exists-income-cli  then next.
         /* Поиск уже сделанных в ручную поставок товара по клиенту по этому заказу */
         find first buf_clients no-lock where
                    buf_clients.obj-type = v-cli-type and
                    buf_clients.obj-code = v-cli-code no-error .
                    if error-status :error then do:
                      message "На группу " buf_goods.grp-name " не верно задан внутренний поставщик " .
                      next.
                    end.

         v-old-qnty = 0 .
         for each buf_ord-doc-rcv no-lock where
             buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
             on error undo, return error :
             for each buf_ord-line-rcv no-lock where
                     buf_ord-line-rcv.rcv-code  = buf_ord-doc-rcv.rcv-code and
                     buf_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code and
                     buf_ord-line-rcv.prod-type = x_ord-line.prod-type and
                     buf_ord-line-rcv.prod-code = x_ord-line.prod-code and
                     buf_ord-line-rcv.artic     = x_ord-line.artic ,
                  first buf2-ord-doc-rcv no-lock where
                        buf2-ord-doc-rcv.rcv-code =  buf_ord-line-rcv.rcv-code and
                        buf2-ord-doc-rcv.doc-code =  buf_ord-line-rcv.doc-code    ,
                  each ub.ord-chain no-lock where
                        ub.ord-chain.doc-code = buf2-ord-doc-rcv.rcv-code and
                        ub.ord-chain.doc-type = 'rcv'                     and
                        ub.ord-chain.rel-doc-type = 'trn'              ,
                  first buf2-doc-line no-lock where
                        buf2-doc-line.doc-code     =  ub.ord-chain.rel-doc-code  and
                        buf2-doc-line.artic        =  buf_ord-line-rcv.artic    and
                        buf2-doc-line.prod-code    =  buf_ord-line-rcv.prod-code and
                        buf2-doc-line.prod-type    =  buf_ord-line-rcv.prod-type

                 on error undo, return error :
                 v-old-qnty = v-old-qnty + buf2-doc-line.fact-qnty .
             end. /* for each */
         end. /* for each */
         v-delta = x_ord-line.qnty - v-old-qnty .

        if v-delta <= 0 then next. /* все распределили */
        v-temp-rcv-line_qnty      = 0.
        /* если есть параметр то сравниваем что на объекте */
        if par-ord-oobj  = true then do :
              find first x_gds-obj no-lock where
                          x_gds-obj.obj-type  = v-cli-type and
                          x_gds-obj.obj-code  = v-cli-code and
                          x_gds-obj.prod-type = x_ord-line.prod-type and
                          x_gds-obj.prod-code = x_ord-line.prod-code and
                          x_gds-obj.artic     = x_ord-line.artic no-error .
                          .
              if available x_gds-obj and x_gds-obj.free-qnty  > 0 then do:

                  v-temp-rcv-line_qnty      = MINIMUM (x_gds-obj.free-qnty , v-delta).
                  /* message x_gds-obj.fact-qnty skip v-temp-rcv-line_qnty  111111. */

              end.
        end.
        else do:
          v-temp-rcv-line_qnty      = v-delta .
        end.

         if v-temp-rcv-line_qnty  <= 0 then next .

        create temp-rcv-line.
        BUFFER-COPY x_ord-line to temp-rcv-line
         assign
          temp-rcv-line.rcv-code = "temp"
          temp-rcv-line.cli-type = v-cli-type
          temp-rcv-line.cli-code = v-cli-code
          temp-rcv-line.qnty     = v-temp-rcv-line_qnty
         .

end. /* for each */

for each temp-rcv-line break by  temp-rcv-line.cli-type by temp-rcv-line.cli-code
    on error undo, return error :
    if first-of(temp-rcv-line.cli-code) then do:

        run make-rcv in this-procedure (
            input temp-rcv-line.cli-type ,
            input temp-rcv-line.cli-code ,
            output v-recid
            ) .
    end.
end. /* for each */
 run exit-proc in this-procedure .



PROCEDURE exit-proc :
/* -----------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
-------------------------------------------------------------*/
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

define variable glob-gen as logical init false  no-undo .
define variable v-kk as integer no-undo .
define buffer buf_ver_ord-doc-rcv  for ub.ord-doc-rcv.
define buffer buf_ver_doc-line for ub.doc-line.
define buffer buf_ver_trn-doc  for ub.trn-doc.
define variable t-log-4 as logical no-undo .
define variable varchip-code      as integer   no-undo.
t-log-4 = false .

for each buf_ver_ord-doc-rcv no-lock where
         buf_ver_ord-doc-rcv.doc-code = buf_ord-doc.doc-code
         on error undo, return error :
        v-kk = 0 .
        for each ub.ord-chain no-lock where
                  ub.ord-chain.doc-code = buf_ver_ord-doc-rcv.rcv-code and
                  ub.ord-chain.doc-type = 'rcv'                  and
                  ub.ord-chain.rel-doc-type = 'trn'
                  :
              for each buf_ver_doc-line no-lock where
                  buf_ver_doc-line.doc-code = ub.ord-chain.rel-doc-code
                  on error undo, return error :
                  v-kk = v-kk + 1 .
              end. /* for each строки */
        end.

        if v-kk = 0 then do:
        for each ub.ord-chain no-lock where
                  ub.ord-chain.doc-code = buf_ver_ord-doc-rcv.rcv-code and
                  ub.ord-chain.doc-type = 'rcv'                  and
                  ub.ord-chain.rel-doc-type = 'trn'
                  :

           find first buf_ver_trn-doc no-lock where
                      buf_ver_trn-doc.doc-code = ub.ord-chain.rel-doc-code no-error .
           if available buf_ver_trn-doc then
              run str/del-doc.p
                ( input  parParentProc,
                  input  buf_ver_trn-doc.doc-code,
                  input  v-cntxt-db-num,
                  input  "del-doc.err",
                  input  ?,
                  input  ?,
                  input  v-cntxt-userid,
                  input  buf_ver_trn-doc.doc-code,
                  input  ?,
                  output varchip-code ) .
          find x_ord-doc-rcv  exclusive-lock where recid(x_ord-doc-rcv) = recid(buf_ver_ord-doc-rcv) no-error .
          if available x_ord-doc-rcv then
             delete x_ord-doc-rcv.
        end.
        end.
end. /* for each */


if buf_ord-doc.status_ = {&ord-req} and buf_ord-doc.flag_ = false  then do:

    if can-find(first X_ord-doc-rcv no-lock where X_ord-doc-rcv.doc-code = buf_ord-doc.doc-code ) = true
      then glob-gen = true .

    if  glob-gen = true  then do:

            message "Закрываем заказ до статуса " + caps( {&ord-req} ) +  "+ ? " view-as alert-box question
            buttons yes-no title "" update t-log-4 .
            if t-log-4 = true then do:
              run cus/ordoocls.p (
                  input parParentProc ,
                  input recid(buf_ord-doc) ,
                  input true )
                   .
            end.

    end.
end.


  end.  /* do */
END PROCEDURE.

PROCEDURE make-rcv :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :

/* -----------------------------------------------------------
  Purpose: генерация поставок по заказу
-------------------------------------------------------------*/
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer no-undo .
define output parameter  r-rec as recid no-undo.

define variable l-recid as recid no-undo.
define variable v-root-node as integer no-undo .

define variable ks          as  integer no-undo .
define variable loc-rcv-num as  character no-undo .
define variable ii          as  integer no-undo .
define buffer   b-goods     for ub.goods .
define buffer   bfp-ord-doc for ub.ord-doc .
define buffer   buf2-ord-line-rcv for ub.ord-line-rcv.
define buffer   buf_gds-obj for ub.gds-obj.
define variable last-all-rcv as decimal no-undo .
define variable v-i-doc as character no-undo .

define buffer buf_ord-doc-rcv for  ub.ord-doc-rcv.
define buffer buf_ord-line for ub.ord-line.
define buffer buf_ord-line-rcv for ub.ord-line-rcv.
define buffer buf_ord-dtl-rcv  for ub.ord-dtl-rcv.

ks = 0.

{ cus/ord-code.i
    'main'
    v-cntxt-db-num
    v-cntxt-obj-type
    v-cntxt-obj-code
    v-i-doc
    loc-rcv-num
    }


  find first bfp-ord-doc where    recid(bfp-ord-doc) = p-ord-doc-recid
       no-lock no-error.
       if error-status :error  then return.

   loc-ord-num = bfp-ord-doc.doc-code.

   if not( bfp-ord-doc.status_  = {&ord-req} and
           bfp-ord-doc.flag_    = false  )
   then do:
        message "Нелязя делать ЗАПРОС по   Заказу в статусе " caps(bfp-ord-doc.status_) string(bfp-ord-doc.flag_,"+/-") " !"
                 view-as alert-box information .
        return.
   end.

/* Шапка поставки */

create buf_ord-doc-rcv.
buffer-copy bfp-ord-doc to buf_ord-doc-rcv
   assign
      buf_ord-doc-rcv.rcv-code  = loc-rcv-num
      buf_ord-doc-rcv.doc-type  = {&ord-req}
      buf_ord-doc-rcv.doc-date  = today
      buf_ord-doc-rcv.status_   = {&g___new}
      buf_ord-doc-rcv.cli-code = p-cli-code
      buf_ord-doc-rcv.cli-type = p-cli-type
   .
 if
 buf_ord-doc-rcv.cli-code = buf_ord-doc-rcv.obj-code and
 buf_ord-doc-rcv.cli-type = buf_ord-doc-rcv.obj-type then do:
        message "Неверно заданы контрагенты !"
                 view-as alert-box information .
        undo,return error.

 end.

   for each temp-rcv-line no-lock where
       temp-rcv-line.cli-type = p-cli-type and
       temp-rcv-line.cli-code = p-cli-code by temp-rcv-line.line-num :
        ks = ks + 1 .

         { gbl/rootnode.i
           temp-rcv-line.artic
           temp-rcv-line.prod-type
           temp-rcv-line.prod-code
           v-root-node
         }

         create buf_ord-line-rcv.
         buffer-copy temp-rcv-line to buf_ord-line-rcv
         assign
           buf_ord-line-rcv.rcv-code  = buf_ord-doc-rcv.rcv-code
           buf_ord-line-rcv.line-num  = ks
           buf_ord-line-rcv.cli-qnty  = buf_ord-line-rcv.qnty / buf_ord-line-rcv.cli-base-rate
         .

         create buf_ord-dtl-rcv.
         buffer-copy buf_ord-line-rcv to buf_ord-dtl-rcv
            assign
              buf_ord-dtl-rcv.node-code = v-root-node
            .

         l-recid = recid(buf_ord-line-rcv).
end.

if ks > 0 then do:
    r-rec = recid(buf_ord-doc-rcv).
     /* message "Сделана поставка № " loc-rcv-num .*/

    run cus/ord-trnz.p (parParentProc ,
                    input r-rec ,
                    input {&income},
                    input "" ) no-error .
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip
             "Ошибка ord-trnz.p " skip
              skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error
      .
      delete buf_ord-doc-rcv .
      return error .
    end.

   end.
 else do:

   find first buf_ord-doc-rcv where buf_ord-doc-rcv.rcv-code  = loc-ord-num  exclusive-lock  .
   delete buf_ord-doc-rcv .
   r-rec = ?.
end.

rid-list = "" .

end.  /* do */
END PROCEDURE.