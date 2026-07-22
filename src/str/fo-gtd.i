/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Определение партии накладной по партии ФО
Анализирует ЗАКАЗЫ, ПОСТАВКИ, НАКЛАДНЫЕ И УДАЛЕННЫЕ НАКЛАДНЫЕ

Автор: Чернова Светлана Александровна
Дата создания: 04/02/07
Author: Svetlana Chernova
Creation date: 04/02/07

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-by-fo_parts no-undo like ub.parts.

procedure fo-find-part :
define input  parameter p-host-code   as integer   no-undo .  /*  fin-ob.host-code        */
define input  parameter p-fin-ob-code as character no-undo .  /*  fin-ob.doc-code         */
define input  parameter p-obj-type    as character no-undo .  /*  fin-gds-part.obj-type   */
define input  parameter p-obj-code    as integer   no-undo .  /*  fin-gds-part.obj-code   */
define input  parameter p-gds-code    as integer   no-undo .  /*  fin-gds-part.gds-code   */
define input  parameter p-in-code     as character no-undo .  /*  fin-gds-part.in-code    */
define input  parameter p-part-code   as character no-undo .  /*  fin-gds-part.part-code  */
define input  parameter p-out-code    as character no-undo .  /*  fin-gds-part.out-code   */
define input  parameter p-doc-type    as character no-undo .  /*  fin-gds-part.doc-type   */
define output  PARAMETER TABLE FOR temp-by-fo_parts .

define buffer buf_fin-ob        for ub.fin-ob  .
define buffer buf_fin-gds-part  for ub.fin-gds-part .
define buffer buf_fin-ob-trn    for ub.fin-ob-trn .
define buffer buf_trn-doc       for ub.trn-doc  .
define buffer buf_c-trn-doc     for ub.c-trn-doc  .
define buffer buf_parts         for ub.parts .
define buffer buf_c-parts       for ub.c-parts .
define buffer buf_ord-doc       for ub.ord-doc  .
define buffer buf_ord-doc-rcv   for ub.ord-doc-rcv  .
define buffer buf_ord-line-rcv  for ub.ord-line-rcv  .
define buffer buf_goods         for ub.goods  .
  do
  on error undo, return error return-value
  :
  empty temp-table temp-by-fo_parts .
  find first buf_fin-ob no-lock where
             buf_fin-ob.host-code   =  p-host-code     and
             buf_fin-ob.doc-code    =  p-fin-ob-code   no-error .
              if error-status :error then do:
                message
                  vss-include-info{&vssseq} skip
                  error-status :get-message(1) skip
                  return-value skip
                  "Неверно заданы входные параметры для процедуры fo-find-part"
                  view-as alert-box error
                  .
                return error .
              end.

  find first buf_fin-gds-part no-lock where
              buf_fin-gds-part.host-code   =  p-host-code     and
              buf_fin-gds-part.fin-ob-code =  p-fin-ob-code   and
              buf_fin-gds-part.obj-type    =  p-obj-type      and
              buf_fin-gds-part.obj-code    =  p-obj-code      and
              buf_fin-gds-part.gds-code    =  p-gds-code      and
              buf_fin-gds-part.in-code     =  p-in-code       and
              buf_fin-gds-part.part-code   =  p-part-code     and
              buf_fin-gds-part.out-code    =  p-out-code      and
              buf_fin-gds-part.doc-type    =  p-doc-type      no-error .
              if error-status :error then do:
                message
                  vss-include-info{&vssseq} skip
                  error-status :get-message(1) skip
                  return-value skip
                  "Неверно заданы входные параметры для процедуры fo-find-part"
                  view-as alert-box error
                  .
                return error .
              end.
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
              if error-status :error then do:
                message
                  vss-include-info{&vssseq} skip
                  error-status :get-message(1) skip
                  return-value skip
                  "Неверно заданы входные параметры для процедуры fo-find-part"
                  view-as alert-box error
                  .
                return error .
              end.

  find first buf_fin-ob-trn no-lock where
             buf_fin-ob-trn.doc-code     = buf_fin-gds-part.fin-ob-code and
             buf_fin-ob-trn.trn-doc-code = buf_fin-gds-part.out-code
             no-error .
  if not available buf_fin-ob-trn then return .  /* партий нет */
   case buf_fin-ob-trn.doc-type :
        when "order" then do: /* ЗАКАЗЫ */
            find first buf_ord-doc no-lock where buf_ord-doc.doc-code = buf_fin-gds-part.out-code no-error .
            for each buf_ord-doc-rcv no-lock where
                     buf_ord-doc-rcv.doc-code = buf_ord-doc.doc-code :

                 for each buf_ord-line-rcv no-lock where
                          buf_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code and
                          buf_ord-line-rcv.rcv-code  = buf_ord-doc-rcv.rcv-code and
                          buf_ord-line-rcv.artic     = buf_goods.artic          and
                          buf_ord-line-rcv.prod-type = buf_goods.prod-type      and
                          buf_ord-line-rcv.prod-code = buf_goods.prod-code,
                   each ub.ord-chain no-lock where
                          ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                          ub.ord-chain.doc-type = 'rcv'                  and
                          ub.ord-chain.rel-doc-type = 'trn'
                          :

                          run cr-trn (
                             input  ub.ord-chain.rel-doc-code
                            ,input  buf_fin-ob.contract-code
                            ,input  buf_goods.artic
                            ,input  buf_goods.prod-type
                            ,input  buf_goods.prod-code
                            ) .
                 end.
            end.
        end.
        when "rcv" then do: /* ПОСТАВКИ */
            find first buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.rcv-code = buf_fin-gds-part.out-code no-error .
            if available buf_ord-doc-rcv then do:
            for  each ub.ord-chain no-lock where
                          ub.ord-chain.doc-code = buf_ord-doc-rcv.rcv-code and
                          ub.ord-chain.doc-type = 'rcv'                  and
                          ub.ord-chain.rel-doc-type = 'trn'
                          :
            run cr-trn (
              input   ub.ord-chain.rel-doc-code
              ,input  buf_fin-ob.contract-code
              ,input  buf_goods.artic
              ,input  buf_goods.prod-type
              ,input  buf_goods.prod-code
              ) .
            end.
            end.
        end.
        when "" then do: /* НАКЛАДНЫЕ */
            find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_fin-gds-part.out-code no-error .
              if available buf_trn-doc then do: /* по живым*/
                 for each buf_parts no-lock where
                          buf_parts.obj-type   = p-obj-type and
                          buf_parts.obj-code   = p-obj-code and
                          buf_parts.artic      = buf_goods.artic and
                          buf_parts.prod-type  = buf_goods.prod-type and
                          buf_parts.prod-code  = buf_goods.prod-code and
                          buf_parts.in-code    = p-in-code  and
                          buf_parts.part-code  = p-part-code and
                          buf_parts.out-code   = p-out-code
                          :
                     create temp-by-fo_parts .
                     buffer-copy buf_parts to temp-by-fo_parts.
                 end.
              end.
              else do: /* по удаленным */
                  find first buf_c-trn-doc no-lock where
                             buf_c-trn-doc.doc-code = buf_fin-gds-part.out-code  and
                             buf_c-trn-doc.is-del = true
                             no-error .
                    if available buf_c-trn-doc then do:
                      for each buf_c-parts no-lock where
                                buf_c-parts.chip-num =  buf_c-trn-doc.chip-num and
                                buf_c-parts.corr-user-db-num  = buf_c-trn-doc.corr-user-db-num and
                                buf_c-parts.obj-type   = p-obj-type  and
                                buf_c-parts.obj-code   = p-obj-code  and
                                buf_c-parts.artic      = buf_goods.artic and
                                buf_c-parts.prod-type  = buf_goods.prod-type and
                                buf_c-parts.prod-code  = buf_goods.prod-code and
                                buf_c-parts.in-code    = p-in-code   and
                                buf_c-parts.part-code  = p-part-code and
                                buf_c-parts.out-code   = p-out-code
                                :
                          create temp-by-fo_parts .
                          buffer-copy buf_c-parts to temp-by-fo_parts.
                      end.
              end.
              end.
        end.
   end case.
end.
end procedure. /* fo-find-part */

procedure cr-trn : /* дл заказов и поставок косвенная ссылка */
define input  parameter p-doc-code as character no-undo . /* N накладной */
define input  parameter p-contract-code as integer   no-undo . /* N договора */
define input  parameter p-artic as character no-undo .
define input  parameter p-prod-type as character no-undo .
define input  parameter p-prod-code as integer   no-undo .

define buffer buf_trn-doc       for ub.trn-doc  .
define buffer buf_c-trn-doc     for ub.c-trn-doc  .
define buffer buf_parts         for ub.parts .
define buffer buf_c-parts       for ub.c-parts .

  do
  on error undo, return error return-value
  :
            find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code no-error .
              if available buf_trn-doc then do: /* по живым*/
                 for each buf_parts no-lock where
                          buf_parts.contract-code = p-contract-code and
                          buf_parts.obj-type   = buf_trn-doc.obj-type and
                          buf_parts.obj-code   = buf_trn-doc.obj-code and
                          buf_parts.artic      = p-artic and
                          buf_parts.prod-type  = p-prod-type and
                          buf_parts.prod-code  = p-prod-code and
                          buf_parts.out-code   = buf_trn-doc.doc-code
                          :
                     create temp-by-fo_parts .
                     buffer-copy buf_parts to temp-by-fo_parts.
                 end.
              end.
              else do: /* по удаленным */
                  find first buf_c-trn-doc no-lock where
                             buf_c-trn-doc.doc-code = p-doc-code  and
                             buf_c-trn-doc.is-del = true
                             no-error .
                    if available buf_c-trn-doc then do:
                      for each buf_c-parts no-lock where
                                buf_c-parts.chip-num =  buf_c-trn-doc.chip-num and
                                buf_c-parts.corr-user-db-num  = buf_c-trn-doc.corr-user-db-num and
                                buf_c-parts.contract-code = p-contract-code and
                                buf_c-parts.obj-type   = buf_c-trn-doc.obj-type  and
                                buf_c-parts.obj-code   = buf_c-trn-doc.obj-code  and
                                buf_c-parts.artic      = p-artic and
                                buf_c-parts.prod-type  = p-prod-type and
                                buf_c-parts.prod-code  = p-prod-code and
                                buf_c-parts.out-code   = buf_c-trn-doc.doc-code
                                :
                          create temp-by-fo_parts .
                          buffer-copy buf_c-parts to temp-by-fo_parts.
                      end.
                    end.
              end.
  end.

end procedure. /* cr-trn */
/* $Workfile$ e n d */