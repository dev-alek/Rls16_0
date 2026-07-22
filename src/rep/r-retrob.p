block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-retrob.p $
$Archive: rep/r-retrob.p $

Расчет ретро-бонусов

Автор: Сливенко Сергей Андреевич
Дата создания: 09/14/11
Author: Sergey Slivenko
Creation date: 09/14/11

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-retrob.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-retrob.p $":U .
define variable vss-description as character no-undo init "Расчет ретро-бонусов".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ rep/ostatok.i }
{ rep/rep-bt.i   }
{ rep/repfrm.i def }


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-det-tov     as logical       no-undo .
define input parameter p-itog-prod   as logical       no-undo .

define variable CurrGrpName         as character  no-undo .
define variable v-method            as character  no-undo .
define variable v-start-fact-order  as decimal    no-undo .
define variable v-end-fact-order    as decimal    no-undo .
define variable v-temp-f-o          as decimal    no-undo .
define variable v-temp-vozv         as decimal    no-undo .
define variable v-temp-sum          as decimal    no-undo .

define variable i as integer no-undo.
define variable   Counter1            as   integer        no-undo.
assign  Counter1 = 0 .

define buffer buf_goods                 for ub.goods.
define buffer buf_gds-obj               for ub.gds-obj.
define buffer buf_clients               for ub.clients.
define buffer buf2_clients              for ub.clients.
define buffer buf_contract              for ub.contract.
define buffer buf_contract-specif       for ub.contract-specif.
define buffer buf_contract-specif-attr  for ub.contract-specif-attr.
define buffer buf_stk-supp-line         for ub.stk-supp-line.

define temp-table tt-supp no-undo
  field name      as character
  field type      as character
  field code      as integer
  field sum       as decimal
  field sum-vat   as decimal
  field sum-bonus as decimal
  index pi is primary unique
    type
    code
.

define temp-table tt-prod no-undo
  field name      as character
  field type      as character
  field code      as integer
  field sum       as decimal
  field sum-vat   as decimal
  field sum-bonus as decimal
  field supp-type as character
  field supp-code as integer
  index pi is primary unique
    type
    code
    supp-type
    supp-code
.

define temp-table tt-gds no-undo
  field name      as character
  field code      as integer
  field artic     as character
  field prod-type as character
  field prod-code as integer
  field supp-type as character
  field supp-code as integer
  field sum       as decimal
  field sum-vat   as decimal
  field pct-rate  as decimal
  field sum-rate  as decimal
  field method    as character
  field sum-bonus as decimal
  field vozvrat   as logical
  index pi is primary unique
    code
    prod-type
    prod-code
    supp-type
    supp-code
.

  empty temp-table tt-supp    .
  empty temp-table tt-prod    .
  empty temp-table tt-gds     .

case X-Radio-Task:
  when 1 then do :
    run ostatok (
        input 0  ,
        input ""  ,no,
        input x-date-start - 1 ,
        input date('')      ,  0, 24,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input false ,

        output  v-temp-f-o  ,
        output  v-temp-f-o   ,
        output  v-temp-f-o   ,
        output  v-temp-f-o     ,
        output  v-temp-f-o     ,
        output  v-start-fact-order ).
    run ostatok (
        input 0  ,
        input ""  ,no,
        input x-date-start  ,
        input x-date-end    ,  0, 24,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input false ,

        output  v-temp-f-o  ,
        output  v-temp-f-o   ,
        output  v-temp-f-o   ,
        output  v-temp-f-o     ,
        output  v-temp-f-o     ,
        output  v-end-fact-order ).
  end.
  when 2 then do :
    run ostatok (
        input 0  ,
        input ""  ,yes,
        input x-date-start - 1 ,
        input date('')      ,  0, 24,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input false ,

        output  v-temp-f-o  ,
        output  v-temp-f-o   ,
        output  v-temp-f-o   ,
        output  v-temp-f-o     ,
        output  v-temp-f-o     ,
        output  v-start-fact-order ).
    run ostatok (
        input 0  ,
        input ""  ,yes,
        input x-date-start  ,
        input x-date-end    ,  0, 24,
        input {&arh-crsa}   ,
        input {&root-cat-id},
        input false ,

        output  v-temp-f-o  ,
        output  v-temp-f-o   ,
        output  v-temp-f-o   ,
        output  v-temp-f-o     ,
        output  v-temp-f-o     ,
        output  v-end-fact-order ).
  end.
end case.


  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  for each obj-list :                /* встать на объект */
      case x-SelectGood :
      when {&g-all} then do: /* все товары */
          for each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
            :
            run fill-tt in this-procedure.          end.
      end.
        when {&g-prod} then do:    /* не все производители */
          for each G#cli , /* встать на производителя */
              each buf_gds-obj  no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.prod-type = G#cli.obj-type
              and buf_gds-obj.prod-code = G#cli.obj-code
             use-index pi  :
             run fill-tt in this-procedure.
          end.                /* do ... по производителям */
        end .
        when {&g-grp} then do:    /* не все группы товаров */
          for each tmp#grp :
            run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output CurrGrpName ) .
            for each buf_gds-obj no-lock
              where buf_gds-obj.obj-type  = obj-list.obj-type
                and buf_gds-obj.obj-code  = obj-list.obj-code
                and buf_gds-obj.grp-name begins CurrGrpName
              use-index obj-grp :
              run fill-tt in this-procedure.
            end .
          end.    /* do i = 1 to num-entries ( gdsgrp_recids ) : */
        end.

       otherwise do: /* список товаров */
          for each gds-list ,
              each buf_gds-obj no-lock
            where buf_gds-obj.obj-type  = obj-list.obj-type
              and buf_gds-obj.obj-code  = obj-list.obj-code
              and buf_gds-obj.artic     = gds-list.artic
              and buf_gds-obj.prod-type = gds-list.prod-type
              and buf_gds-obj.prod-code = gds-list.prod-code
            :
            run fill-tt in this-procedure.
          end.
        end.

      end case.
  end.                    /* for each ... по объектам */

run rep/extitle.p (1).

for each tt-supp no-lock :
  if p-det-tov then do :
    {&PutExcel}
    tt-supp.name                      {&tabulation}
    tt-supp.type + " " tt-supp.code   {&tabulation}
                                      {&tabulation}
    round(tt-supp.sum,2)              {&tabulation}
    round(tt-supp.sum-vat,2)          {&tabulation}
                                      {&tabulation}
                                      {&tabulation}
                                      {&tabulation}
    round(tt-supp.sum-bonus,2)        {&tabulation}
    SKIP.
    if not p-itog-prod then do :
      for each tt-gds where tt-gds.supp-type = tt-supp.type  and
                            tt-gds.supp-code = tt-supp.code  no-lock :
        if      tt-gds.method = "vat-yes" then v-method = "Приход с НДС".
        else if tt-gds.method = "vat-no"  then v-method = "Приход без НДС".
        else v-method = " - ".
        {&PutExcel}
        "     " + tt-gds.name       {&tabulation}
        tt-gds.code       {&tabulation}
        tt-gds.artic      {&tabulation}
        round(tt-gds.sum,2)        {&tabulation}
        round(tt-gds.sum-vat,2)    {&tabulation}
        tt-gds.pct-rate   {&tabulation}
        tt-gds.sum-rate   {&tabulation}
        v-method          {&tabulation}
        round(tt-gds.sum-bonus,2)  {&tabulation}
        SKIP.
      end. /* for each tt-gds  */
    end.
  end.
  else do :
    {&PutExcel}
    tt-supp.name                      {&tabulation}
    tt-supp.type + " " tt-supp.code   {&tabulation}
    round(tt-supp.sum,2)              {&tabulation}
    round(tt-supp.sum-vat,2)          {&tabulation}
    round(tt-supp.sum-bonus,2)        {&tabulation}
    SKIP.
  end.
  if p-itog-prod then do :
    for each tt-prod where tt-prod.supp-type = tt-supp.type and
                           tt-prod.supp-code = tt-supp.code no-lock :
      if p-det-tov then do :
        {&PutExcel}
        "   " + tt-prod.name              {&tabulation}
        tt-prod.type + " " tt-prod.code   {&tabulation}
                                          {&tabulation}
        round(tt-prod.sum,2)              {&tabulation}
        round(tt-prod.sum-vat,2)          {&tabulation}
                                          {&tabulation}
                                          {&tabulation}
                                          {&tabulation}
        round(tt-prod.sum-bonus,2)        {&tabulation}
        SKIP.
        for each tt-gds where tt-gds.prod-type = tt-prod.type       and
                              tt-gds.prod-code = tt-prod.code       and
                              tt-gds.supp-type = tt-prod.supp-type  and
                              tt-gds.supp-code = tt-prod.supp-code  no-lock :
          if      tt-gds.method = "vat-yes" then v-method = "Приход с НДС".
          else if tt-gds.method = "vat-no"  then v-method = "Приход без НДС".
          else v-method = " - ".

          {&PutExcel}
          "     " + tt-gds.name       {&tabulation}
          tt-gds.code       {&tabulation}
          tt-gds.artic      {&tabulation}
          round(tt-gds.sum,2)        {&tabulation}
          round(tt-gds.sum-vat,2)    {&tabulation}
          tt-gds.pct-rate   {&tabulation}
          tt-gds.sum-rate   {&tabulation}
          v-method          {&tabulation}
          round(tt-gds.sum-bonus,2)  {&tabulation}
          SKIP.
        end.  /*  for each tt-gds  */
      end.
      else do :
        {&PutExcel}
        "   " + tt-prod.name              {&tabulation}
        tt-prod.type + " " tt-prod.code   {&tabulation}
        round(tt-prod.sum,2)              {&tabulation}
        round(tt-prod.sum-vat,2)          {&tabulation}
        round(tt-prod.sum-bonus,2)        {&tabulation}
        SKIP.
      end.
    end. /*    for each tt-prod    */
  end.   /*   if p-itog-prod  */
end. /* for each tt-supp */

{&CloseExcel}
{ rep/repfrm.i off } /* Показать окно информации о текущем процессе */
{ gbl/stopwork.i }

run rep/runexcel.p (string( session:temp-directory) + {&DF_Name} + string( g#report-num ) + ".txt").


procedure fill-tt :
  find first G#CUSTOMER no-error .
  if not available G#CUSTOMER then
  for each buf_clients no-lock :
    { rep/r-retroB.i buf_clients}
    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }
  end.
  Else for each G#CUSTOMER no-lock :
    { rep/r-retroB.i G#CUSTOMER}
    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }
  end.
end procedure.