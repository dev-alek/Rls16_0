/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Суслов Алексей Юрьевич
Дата создания: 04/12/06
Author: Alexey Suslov
Creation date: 04/12/06

*/

&IF "{1}" = "def" &THEN
define variable varsum-vat-acc      like doc-line.price-rubl no-undo.
define variable varsum-vat-sale     like doc-line.price-rubl no-undo.
define variable varsum-acc-out-vat  like doc-line.price-rubl no-undo.
define variable varsum-sale-out-vat like doc-line.price-rubl no-undo.
define variable varsum-sale         like doc-line.price-rubl no-undo.
define variable varsum-income       like doc-line.price-rubl no-undo.
define variable varsum-road-tax     like doc-line.price-rubl no-undo.
define variable varsum-qnty         like doc-line.fact-qnty    no-undo.
define variable vargds-grp          like gds-grp.node-code     no-undo.
define variable varnum-line         as   integer               no-undo.
define variable varroot             like gds-grp.node-code     no-undo.
define temp-table tt-doc-line no-undo
field artic              like doc-line.artic
field prod-type          like doc-line.prod-type
field prod-code          like doc-line.prod-code
field gds-name           like goods.gds-name
field gds-type           like goods.gds-type
field gds-unit-base      like goods.unit-base
field grp-code           like goods.grp-code
field grp-name           like goods.grp-name
field vat-acc            like doc-line.vat-pc
field sum-road-tax       like doc-line.road-tax
field road-tax           like doc-line.road-tax
field qnty               like doc-line.fact-qnty
field sum-vat-acc        like gds-dtl.price-rubl
field price-acc          like gds-dtl.price-rubl
field price-acc-out-vat  like gds-dtl.price-rubl
field increase           like gds-dtl.price-rubl
field vat-sale           like doc-line.vat-pc
field sum-vat-sale       like gds-dtl.price-rubl
field price-sale         like gds-dtl.price-rubl
field price-sale-out-vat like gds-dtl.price-rubl
field sum-acc            like gds-dtl.price-rubl
field sum-acc-out-vat    like gds-dtl.price-rubl
field sum-sale           like gds-dtl.price-rubl
field sum-sale-out-vat   like gds-dtl.price-rubl
index pi is unique primary artic prod-type prod-code
index grp-code grp-code.
def var sym1  as char init ":" no-undo.
def var sym2  as char init ":" no-undo.
def var sym3  as char init ":" no-undo.
def var sym4  as char init ":" no-undo.
def var sym5  as char init ":" no-undo.
def var sym6  as char init ":" no-undo.
def var sym7  as char init ":" no-undo.
def var sym8  as char init ":" no-undo.
def var sym9  as char init ":" no-undo.
def var sym10 as char init ":" no-undo.
def var sym11 as char init ":" no-undo.
def var sym12 as char init ":" no-undo.
def var sym13 as char init ":" no-undo.
def var sym14 as char init ":" no-undo.
def var sym15 as char init ":" no-undo.
def var sym16 as char init ":" no-undo.
def var sym17 as char init ":" no-undo.
def var Line  as char          no-undo.

&ENDIF
&IF "{1}" = "calc" &THEN
PROCEDURE calc-sale :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/

DEFINE INPUT PARAMETER parobj-type   LIKE ub.clients.obj-type NO-UNDO.
DEFINE INPUT PARAMETER parobj-code   LIKE ub.clients.obj-code NO-UNDO.
DEFINE INPUT PARAMETER pardate-shift AS   INTEGER    NO-UNDO.
DEFINE INPUT PARAMETER parstart-date AS   DATE       NO-UNDO.
DEFINE INPUT PARAMETER parend-date   AS   DATE       NO-UNDO.
DEFINE INPUT PARAMETER parstart_shift_num AS INTEGER NO-UNDO.
DEFINE INPUT PARAMETER parend_shift_num   AS INTEGER NO-UNDO.
define variable varr-b as character no-undo.
{ gbl/curr-r-b.i varr-b }

run waitfram-show in this-procedure ("Сбор данных о продажах").
&scop prefix-query for each trn-doc where trn-doc.obj-type    = parobj-type   and ~
                                          trn-doc.obj-code    = parobj-code   and ~
                                          trn-doc.status_     = {&fact}       and
&scop suffix-query     trn-doc.internal    = no           and                                                                       ~
                       trn-doc.doc-type    = {&expense}   and                                                                       ~
                       trn-doc.discnt-type = {&cash-desk} no-lock ,                                                                 ~
        each doc-line where doc-line.doc-code = trn-doc.doc-code no-lock,                                                           ~
             first goods where goods.artic     = doc-line.artic     and                                                             ~
                               goods.prod-type = doc-line.prod-type and                                                             ~
                               goods.prod-code = doc-line.prod-code no-lock:                                                        ~
       run calc-in-out in this-procedure. ~
       run cr-tt-doc-line in this-procedure.                                                                                      ~
       if varr-b = "rubl":u then do: ~
         run as1-tt-doc-line in this-procedure. ~
       end. ~
       else do: ~
         run as2-tt-doc-line in this-procedure. ~
       end. ~
end.
CASE pardate-shift:
WHEN 1 THEN DO:
   {&prefix-query}
   trn-doc.fact-date  >= parstart-date   and
   trn-doc.fact-date  <= parend-date     and
   {&suffix-query}
END.
WHEN 2 THEN DO:
   {&prefix-query}
   trn-doc.shift-date >= parstart-date   and
   trn-doc.shift-date <= parend-date     and
   {&suffix-query}
END.
WHEN 3 THEN DO:
   {&prefix-query}
   (trn-doc.shift-date  > parstart-date       or
    trn-doc.shift-date  = parstart-date       and
    trn-doc.shift-num  >= parstart_shift_num) and
   (trn-doc.shift-date  < parend-date         or
    trn-doc.shift-date  = parend-date         and
    trn-doc.shift-num  <= parend_shift_num)   and
   {&suffix-query}
END.
WHEN 4 THEN DO:
   {&prefix-query}
   trn-doc.shift-date >= parstart-date      and
   trn-doc.shift-num   = parstart_shift_num and
   trn-doc.shift-date <= parend-date        and
   trn-doc.shift-num   = parend_shift_num   and
   {&suffix-query}
END.
END CASE.
run as3-tt-doc-line in this-procedure.
run waitfram-hide in this-procedure .
END PROCEDURE.
procedure calc-in-out :
  { str/in-vatp.i  calc doc-line. trn-doc. g }                                                                                    ~
  { str/out-vatp.i calc doc-line. trn-doc.   }                                                                                    ~
end procedure.
procedure cr-tt-doc-line:
find first tt-doc-line where tt-doc-line.artic     = doc-line.artic     and
                             tt-doc-line.prod-type = doc-line.prod-type and
                             tt-doc-line.prod-code = doc-line.prod-code no-error.
if not available tt-doc-line then do:
     create tt-doc-line.
     ASSIGN tt-doc-line.artic             =  doc-line.artic
            tt-doc-line.prod-type         =  doc-line.prod-type
            tt-doc-line.prod-code         =  doc-line.prod-code
            tt-doc-line.gds-type          =  goods.gds-type
            tt-doc-line.grp-code          =  goods.grp-code
            tt-doc-line.gds-name          =  goods.gds-name
            tt-doc-line.gds-unit-base     =  goods.unit-base.
end.
end procedure.
procedure as1-tt-doc-line:
ASSIGN    tt-doc-line.vat-acc            = tt-doc-line.vat-acc          + doc-line.fact-qnty * vat-pc-loc
          tt-doc-line.vat-sale           = tt-doc-line.vat-sale         + doc-line.fact-qnty * doc-line.vat-pc
          tt-doc-line.sum-road-tax       = tt-doc-line.sum-road-tax     + doc-line.fact-qnty * road-tax-rubl-sale
          tt-doc-line.qnty               = tt-doc-line.qnty             + doc-line.fact-qnty
          tt-doc-line.sum-vat-acc        = tt-doc-line.sum-vat-acc      + doc-line.fact-qnty * vat-rubl-loc
          tt-doc-line.sum-vat-sale       = tt-doc-line.sum-vat-sale     + doc-line.fact-qnty * vat-rubl-sale
          tt-doc-line.sum-acc            = tt-doc-line.sum-acc          + doc-line.fact-qnty * price-rubl-with-tax-loc
          tt-doc-line.sum-sale           = tt-doc-line.sum-sale         + doc-line.fact-qnty * price-rubl-with-tax-sale.
end procedure.
procedure as2-tt-doc-line :
ASSIGN    tt-doc-line.vat-acc            = tt-doc-line.vat-acc          + doc-line.fact-qnty * vat-pc-loc
          tt-doc-line.vat-sale           = tt-doc-line.vat-sale         + doc-line.fact-qnty * doc-line.vat-pc
          tt-doc-line.sum-road-tax       = tt-doc-line.sum-road-tax     + doc-line.fact-qnty * road-tax-base-sale
          tt-doc-line.qnty               = tt-doc-line.qnty             + doc-line.fact-qnty
          tt-doc-line.sum-vat-acc        = tt-doc-line.sum-vat-acc      + doc-line.fact-qnty * vat-base-loc
          tt-doc-line.sum-vat-sale       = tt-doc-line.sum-vat-sale     + doc-line.fact-qnty * vat-base-sale
          tt-doc-line.sum-acc            = tt-doc-line.sum-acc          + doc-line.fact-qnty * price-base-with-tax-loc
          tt-doc-line.sum-sale           = tt-doc-line.sum-sale         + doc-line.fact-qnty * price-base-with-tax-sale.
end procedure.
procedure as3-tt-doc-line:
for each tt-doc-line:
   ASSIGN
   tt-doc-line.sum-acc-out-vat    = tt-doc-line.sum-acc            - tt-doc-line.sum-vat-acc
   tt-doc-line.sum-sale-out-vat   = tt-doc-line.sum-sale           - tt-doc-line.sum-vat-sale
   tt-doc-line.increase           = tt-doc-line.sum-sale-out-vat   - tt-doc-line.sum-road-tax
   tt-doc-line.vat-acc            = tt-doc-line.vat-acc            / tt-doc-line.qnty
   tt-doc-line.vat-sale           = tt-doc-line.vat-sale           / tt-doc-line.qnty
   tt-doc-line.road-tax           = tt-doc-line.sum-road-tax       / tt-doc-line.qnty
   tt-doc-line.price-acc          = tt-doc-line.sum-acc            / tt-doc-line.qnty
   tt-doc-line.price-acc-out-vat  = tt-doc-line.sum-acc-out-vat    / tt-doc-line.qnty
   tt-doc-line.price-sale         = tt-doc-line.sum-sale           / tt-doc-line.qnty
   tt-doc-line.price-sale-out-vat = tt-doc-line.sum-sale-out-vat   / tt-doc-line.qnty
   .
end.
end procedure.

&ENDIF

&IF "{1}" = "calc-grp" &THEN
PROCEDURE calc-gds-grp :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
  define input  parameter pardisp-all         as   integer               no-undo. /*1 - печатаем все товары и все узлы
                                                                                    2 - печатаем только товары и верхний узел
                                                                                    3 - печатаем только узлы
                                                                                    4 - печатаем товары, терминальные узлы и верхний узел
                                                                                    5 - печатаем терминальные узлы и верхний узел*/
  define input  parameter parnode-code        like gds-grp.node-code     no-undo.
  define input  parameter pargrp-name         like goods.grp-name        no-undo.
  define output parameter parsum-vat-acc      like doc-line.price-rubl no-undo.
  define output parameter parsum-vat-sale     like doc-line.price-rubl no-undo.
  define output parameter parsum-acc-out-vat  like doc-line.price-rubl no-undo.
  define output parameter parsum-sale-out-vat like doc-line.price-rubl no-undo.
  define output parameter parsum-sale         like doc-line.price-rubl no-undo.
  define output parameter parsum-road-tax     like doc-line.price-rubl no-undo.
  define output parameter parsum-qnty         like doc-line.fact-qnty    no-undo.
  define variable vargrp-name-loc like goods.grp-name no-undo.
  /*если это не последний уровень шкалы*/
  find first gds-grp where gds-grp.node-code = parnode-code no-lock.
  vargrp-name-loc = pargrp-name + "\" + gds-grp.node-name.
  if length(vargrp-name-loc) > 37 then vargrp-name-loc = "..." +
                                       SUBSTRING(vargrp-name-loc, length(vargrp-name-loc) - 36, 37).

  if can-find(first gds-grp where gds-grp.upper-code = parnode-code no-lock) then do:
     for each gds-grp where gds-grp.upper-code = parnode-code no-lock:
         RUN calc-gds-grp (input  pardisp-all,
                           input  gds-grp.node-code,
                           input  vargrp-name-loc,
                           output varsum-vat-acc,
                           output varsum-vat-sale,
                           output varsum-acc-out-vat,
                           output varsum-sale-out-vat,
                           output varsum-sale,
                           output varsum-road-tax,
                           output varsum-qnty).
         ACCUMULATE varsum-vat-acc      (total)
                    varsum-vat-sale     (total)
                    varsum-acc-out-vat  (total)
                    varsum-sale-out-vat (total)
                    varsum-sale         (total)
                    varsum-road-tax     (total)
                    varsum-qnty         (total).
     end.
     ASSIGN
       parsum-vat-acc      = (ACCUM TOTAL varsum-vat-acc     )
       parsum-vat-sale     = (ACCUM TOTAL varsum-vat-sale    )
       parsum-acc-out-vat  = (ACCUM TOTAL varsum-acc-out-vat )
       parsum-sale-out-vat = (ACCUM TOTAL varsum-sale-out-vat)
       parsum-sale         = (ACCUM TOTAL varsum-sale        )
       parsum-road-tax     = (ACCUM TOTAL varsum-road-tax    )
       parsum-qnty         = (ACCUM TOTAL varsum-qnty        ).
       if parsum-vat-acc       > 0 OR
          parsum-vat-sale      > 0 OR
          parsum-acc-out-vat   > 0 OR
          parsum-sale-out-vat  > 0 OR
          parsum-sale          > 0 OR
          parsum-road-tax      > 0 OR
          parsum-qnty          > 0 THEN DO:
          if (pardisp-all <> 2 OR parnode-code = varroot) AND
             (pardisp-all <> 4 OR parnode-code = varroot) AND
             (pardisp-all <> 5 OR parnode-code = varroot) THEN
          run disp-total(input vargrp-name-loc    ,
                         input parsum-vat-acc     ,
                         input parsum-vat-sale    ,
                         input parsum-acc-out-vat ,
                         input parsum-sale-out-vat,
                         input parsum-sale        ,
                         input parsum-road-tax    ,
                         input parsum-qnty).
       END.
  end.
  /*если это терминальный уровень*/
  else do:
       if can-find(first tt-doc-line where tt-doc-line.grp-code = gds-grp.node-code) and
          pardisp-all <> 2 and
          pardisp-all <> 3 and
          pardisp-all <> 5 then run disp-grp-name(input vargrp-name-loc).
       for each tt-doc-line where tt-doc-line.grp-code = gds-grp.node-code:
           if pardisp-all <> 3 and
              pardisp-all <> 5 then run disp-tt-doc-line.
           ACCUMULATE tt-doc-line.sum-vat-acc      (total)
                      tt-doc-line.sum-vat-sale     (total)
                      tt-doc-line.sum-acc-out-vat  (total)
                      tt-doc-line.sum-sale-out-vat (total)
                      tt-doc-line.sum-sale         (total)
                      tt-doc-line.sum-road-tax     (total)
                      tt-doc-line.qnty             (total).
       end.
       ASSIGN
       parsum-vat-acc      = (ACCUM TOTAL tt-doc-line.sum-vat-acc     )
       parsum-vat-sale     = (ACCUM TOTAL tt-doc-line.sum-vat-sale    )
       parsum-acc-out-vat  = (ACCUM TOTAL tt-doc-line.sum-acc-out-vat )
       parsum-sale-out-vat = (ACCUM TOTAL tt-doc-line.sum-sale-out-vat)
       parsum-sale         = (ACCUM TOTAL tt-doc-line.sum-sale        )
       parsum-road-tax     = (ACCUM TOTAL tt-doc-line.sum-road-tax    )
       parsum-qnty         = (ACCUM TOTAL tt-doc-line.qnty            ).
       find first tt-doc-line where tt-doc-line.grp-code = gds-grp.node-code no-error.
       if available tt-doc-line then do:
           if pardisp-all <> 2       OR
              parnode-code = varroot then
           run disp-total(input vargrp-name-loc    ,
                          input parsum-vat-acc     ,
                          input parsum-vat-sale    ,
                          input parsum-acc-out-vat ,
                          input parsum-sale-out-vat,
                          input parsum-sale        ,
                          input parsum-road-tax    ,
                          input parsum-qnty).
      end.
  end.
END PROCEDURE.
&ENDIF