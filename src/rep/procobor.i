/*
$Revision$
$Author$
$Date$
$Workfile$
$Archive$

свалка процедур для обороток

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06

Дата создания: 10/02/01
*/

&if "{1}" = "find-last-prise-med" &then
/*---------------------------------------------------------------*/
procedure find-last-prise-med :
define input parameter p-artic     like ub.goods.artic no-undo .
define input parameter p-prod-type like ub.goods.prod-type no-undo .
define input parameter p-prod-code like ub.goods.prod-code no-undo .
define input parameter p-host-code like ub.gds-obj.host-code no-undo .
define output parameter  p-price   like ub.gds-obj.last-base no-undo .

define buffer p-gds-obj   for  ub.gds-obj .
define buffer buf_trn-doc for  ub.trn-doc .

define variable v-fact-order as decimal no-undo .

p-price = 0 .

  define variable v-in-date as date      no-undo .
  define variable fl as logical no-undo .
  fl = yes.
  v-fact-order = 0 .
  for each tt-obj-list no-lock break by tt-obj-list.obj-type by tt-obj-list.obj-code
  :
    find first p-gds-obj no-lock
      where p-gds-obj.artic     = p-artic         and
              p-gds-obj.prod-type = p-prod-type     and
              p-gds-obj.prod-code = p-prod-code     and
              p-gds-obj.obj-code  = tt-obj-list.obj-code and
              p-gds-obj.obj-type  = tt-obj-list.obj-type
      no-error .

    if available p-gds-obj then do:
    if p-gds-obj.in-date = ?  then next .

    if fl = yes then do:
      assign
        v-in-date = p-gds-obj.in-date
        p-price   =  if tPrintRubl then  p-gds-obj.last-rubl else  p-gds-obj.last-base
        fl = no
    .
     find first buf_trn-doc no-lock  where buf_trn-doc.doc-code = p-gds-obj.in-code no-error  .
     if available buf_trn-doc  then  v-fact-order = buf_trn-doc.fact-order .

    end.
      if p-gds-obj.in-date >= v-in-date   then do:

         if p-gds-obj.in-date = v-in-date then do:
            find first buf_trn-doc no-lock  where buf_trn-doc.doc-code = p-gds-obj.in-code no-error .
            if available buf_trn-doc  then
                if buf_trn-doc.fact-order >  v-fact-order   then do:
                  assign
                    v-fact-order = buf_trn-doc.fact-order
                    p-price   =  if tPrintRubl then  p-gds-obj.last-rubl else  p-gds-obj.last-base
                    v-in-date =   p-gds-obj.in-date
                  .
                end.
         end.
         else do:
          find first buf_trn-doc no-lock  where buf_trn-doc.doc-code = p-gds-obj.in-code no-error .
          if available buf_trn-doc  then
              assign
                p-price   =    if tPrintRubl then  p-gds-obj.last-rubl else  p-gds-obj.last-base
                v-in-date =    p-gds-obj.in-date
                v-fact-order = buf_trn-doc.fact-order .
              .
          end.
        if p-price = ? then   p-price  = 0 .
      end.
    end.
  End .
  if p-price = ? then   p-price  = 0 .
end procedure.

&endif
&if "{1}" = "pp" &then
/*---------------------------------------------------------------*/
procedure {1}{3} :
define input parameter ll as integer no-undo .
define input parameter uu as integer no-undo .
define input parameter ff as character no-undo .
&endif
&if "{2}" = "tree" &then
if ll > g-ll then return.
if ll < 1 then return.
  for each   ub.gds-grp no-lock where ub.gds-grp.lvl-num = ll
      and    ub.gds-grp.upper-code = uu
      :
       id = id + 1 .
            create tmp-gds.
            assign
              tmp-gds.id        = id
              tmp-gds.name      = (if ll = 1 then "" else fill("_",ll)) + ub.gds-grp.node-name + {&delim-grp}
              tmp-gds.f-name    = ff + ub.gds-grp.node-name + {&delim-grp}
              tmp-gds.node-code = ub.gds-grp.node-code
              tmp-gds.lvl = ub.gds-grp.lvl-num
              .
            run pp in this-procedure (ll + 1 , ub.gds-grp.node-code , tmp-gds.f-name ).
  End.
  &endif
&if "{1}" = "pp" &then
End procedure.
&endif
&if "{1}" = "find-mediator" &then
/*---------------------------------------------------------------*/
procedure find-mediator :
define input  parameter c-host-code as integer no-undo .
define input  parameter p-Showmediatr as logical no-undo .
define output parameter p-host-code as integer no-undo .
define output parameter p-flag as logical no-undo .

define buffer b-sysconf  for ub.sysconf.

 p-host-code = 0 .
 p-flag  = true .
    if p-Showmediatr = true then do:
    find first ub.sysconf where ub.sysconf.avrg-price = true no-lock no-error .

          if avail ub.sysconf then DO :
            p-host-code = ub.sysconf.host-code.
            if tPrintRubl = false then do:
                  find first b-sysconf where b-sysconf.host-code = c-host-code no-lock no-error .
                        if  ub.sysconf.base-code <> b-sysconf.base-code then DO:
                              p-flag  = false  .
                              message "Базовая валюта посредника и базовая валюта текущей фирмы не совпадает . Нельзя получить отчет в валюте !"
                              view-as alert-box error.
                        end.
            end.
          end.
          for each ub.shop no-lock where ub.shop.host-code = p-host-code :
              create tt-obj-list no-error .
              assign tt-obj-list.obj-type = {&shop}
                     tt-obj-list.obj-code = ub.shop.obj-code no-error .
          end.
          for each ub.store no-lock where ub.store.host-code = p-host-code :
              create tt-obj-list no-error .
              assign tt-obj-list.obj-type = {&stock}
                     tt-obj-list.obj-code = ub.store.obj-code no-error .
          end.
    End.
 End procedure .
&endif
&if "{1}" = "case-tdedt" &then
oborot-{&bef-{2}}[4]   = Round(oborot-{&bef-{2}}[1]   *  p-price-med , 2) .
&endif
&if "{1}" = "def-tt" &then
  define temp-table tt-obj-list no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is primary unique obj-type obj-code
    index name obj-name
    .
&endif
&if "{1}" = "display-excel-str" &then
 v-Format-string = v-Format-string  +
        string({2}[1] ) + CHR(9)  +
        string({2}[2 ]) + CHR(9)  +
        string({2}[3 ]) + CHR(9)  +
        string({2}[5 ]) + CHR(9)  +
        string({2}[6 ]) + CHR(9)  +
        string({2}[8 ]) + CHR(9)  +
        string({2}[9 ]) + CHR(9)  +
        string({2}[10]) + CHR(9)  +
        string({2}[4 ]) + CHR(9)  .
&endif
&if "{1}" = "ob-line-stk" &then
PROCEDURE ob-line-stk  :
define input  parameter x-store-code     like ub.clients.obj-code      no-undo.
define input  parameter x-store-type     like ub.clients.obj-type      no-undo.
define INPUT  parameter x-artic          like ub.stk-line.artic        no-undo.
define INPUT  parameter x-prod-code      like ub.stk-line.prod-code    no-undo.
define INPUT  parameter x-prod-type      like ub.stk-line.prod-type    no-undo.
define INPUT  parameter x-Fact-order-1   like ub.stk-line.Fact-order   no-undo.
define INPUT  parameter x-Fact-order-2   like ub.stk-line.Fact-order   no-undo.
define input  parameter x-sum-type       like ub.stk-line.sum-type     no-undo.
define input  parameter x-cat-id         like ub.stk-line.cat-id       no-undo.
define input  parameter x-ext-doc-type   like ub.ot-line.ext-doc-type  no-undo.
define input  parameter xTog-obj         as log                     no-undo.
define input  parameter xi               as int                     no-undo.

define output  parameter Quntity         like ub.stk-line.fact-qnty   no-undo.
define output  parameter sum             like ub.stk-line.sum-base    no-undo.
define output  parameter vat             like ub.stk-line.sum-base    no-undo.
define output  parameter slt             like ub.stk-line.sum-base    no-undo.
define output  parameter disc            like ub.stk-line.sum-base    no-undo.

define variable  First-qnty   like ub.stk-line.fact-qnty   no-undo.
define variable  Second-qnty  like ub.stk-line.fact-qnty   no-undo.
define variable  First-sum   like ub.stk-line.sum-base   no-undo.
define variable  Second-sum  like ub.stk-line.sum-base   no-undo.
define variable  First-vat   like ub.stk-line.sum-base   no-undo.
define variable  Second-vat  like ub.stk-line.sum-base   no-undo.
define variable  First-slt   like ub.stk-line.sum-base   no-undo.
define variable  Second-slt  like ub.stk-line.sum-base   no-undo.
define variable  First-disc   like ub.stk-line.sum-base   no-undo.
define variable  Second-disc  like ub.stk-line.sum-base   no-undo.

define buffer stk-line2 for ub.stk-line .

if x-Fact-order-2 < x-Fact-order-1 Then x-Fact-order-2 = x-Fact-order-1.
 Assign
   First-qnty  = 0
   Second-qnty = 0
   Quntity     = 0

   First-sum  = 0
   Second-sum = 0
   sum        = 0

   First-vat  = 0
   Second-vat = 0
   vat        = 0

   First-slt   = 0
   Second-slt  = 0
   slt         = 0
   First-disc  = 0
   Second-disc = 0
   disc        = 0
  .

  For each obj-list  no-lock :
   if  xTog-obj THEN
       if   NOT(    x-store-type     = obj-list.obj-type
            AND    x-store-code      = obj-list.obj-code ) Then NEXT.

   FOR each temp#sum-type where temp#sum-type.xi = xi no-lock :

      find last ub.stk-line no-lock
        where ub.stk-line.obj-type   = obj-list.obj-type
          and ub.stk-line.obj-code   = obj-list.obj-code
          and ub.stk-line.artic      = x-artic
          and ub.stk-line.prod-type  = x-prod-type
          and ub.stk-line.prod-code  = x-prod-code
          and ub.stk-line.sum-type   = temp#sum-type.sum-type
          and ub.stk-line.cat-id     = {&root-cat-id}
          and ub.stk-line.fact-order <= x-fact-order-1
        use-index category
        no-error .
      if available ub.stk-line then do:
        assign
          First-qnty = First-qnty + ub.stk-line.fact-qnty
          First-sum  = First-sum  + (if tprintrubl then ub.stk-line.sum-rubl   else ub.stk-line.sum-base  )
          First-vat  = First-vat  + (if tprintrubl then ub.stk-line.vat-rubl   else ub.stk-line.vat-base  )
          First-disc = First-disc + (if tprintrubl then ub.stk-line.other-rubl else ub.stk-line.other-base )
          First-slt  = First-slt  + (if tprintrubl then ub.stk-line.slt-rubl   else ub.stk-line.slt-base   )
        .
      end.

      find last stk-line2 no-lock
        where stk-line2.obj-code   = obj-list.obj-code
          and stk-line2.obj-type   = obj-list.obj-type
          and stk-line2.artic      = x-artic
          and stk-line2.prod-type  = x-prod-type
          and stk-line2.prod-code  = x-prod-code
          and stk-line2.sum-type   = temp#sum-type.sum-type
          and stk-line2.cat-id     = {&root-cat-id}
          and stk-line2.fact-order <= x-fact-order-2
        use-index category
        no-error .
      if available stk-line2 then do:
        assign
          Second-qnty = Second-qnty + Stk-line2.fact-qnty
          Second-sum  = Second-sum  + (if tprintrubl then stk-line2.sum-rubl else stk-line2.sum-base    )
          Second-vat  = Second-vat  + (if tprintrubl then stk-line2.vat-rubl else stk-line2.vat-base    )
          second-disc = second-disc + (if tprintrubl then stk-line2.other-rubl else stk-line2.other-base )
          second-slt  = second-slt  + (if tprintrubl then stk-line2.slt-rubl   else stk-line2.slt-base   )
        .
      end.
   end.
 end.
 Assign
   Quntity = Second-qnty - first-qnty
   sum     = Second-sum  - first-sum
   vat     = Second-vat  - first-vat
   slt     = Second-slt  - first-slt
   disc    = Second-disc  - first-disc
   .
END PROCEDURE.
&endif

&if "{1}" = "func-vat"  &then
function func-vat returns decimal (
    input p-gds-code as integer  ,
    input p-obj-type as character ,
    input p-obj-code as integer  ).
define variable i-vat-pc as decimal no-undo .
{ gbl/pftxvalg.i
    p-gds-code
    {&vat-tax-code}
    x-Date-End
    v-cntxt-host-code-obj
    p-obj-type
    p-obj-code
    i-vat-pc
    no-error }
if error-status :error then return 0 .
else return i-vat-pc.
end function .
&endif

 /* $Workfile$ e n d */