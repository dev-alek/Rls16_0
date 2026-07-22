block-level on error undo, throw.
/*

$Revision: e2c00fbc6380, 2303, rls $
$Author: EShklyar $
$Date: Fri Feb 14 16:31:04 2020 +0300 $
$Workfile: r-shft3r.p $
$Archive: rep/r-shft3r.p $

печать сменного отчета (ЮКОС лист 3 сбор данных)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 04/12/06
Author: Dmitry Ukhanov
Creation date: 04/12/06

*/

define input parameter pobj-type             like ub.shift-obj.obj-type   no-undo .
define input parameter pobj-code             like ub.shift-obj.obj-code   no-undo .
define input parameter pshift-date           like ub.shift-obj.shift-date no-undo .
define input parameter pshift-num            like ub.shift-obj.shift-num  no-undo .
DEFINE INPUT PARAMETER pshift-date1          like ub.shift-obj.shift-date    no-undo.
DEFINE INPUT PARAMETER pshift-num1           like ub.shift-obj.shift-num     no-undo.
define input parameter pClassify             as   character               no-undo .
define input parameter pSortType             as   character               no-undo .
define input parameter ptog-lavel            as   logical                 no-undo .
define input parameter pvar-lavel            as   integer                 no-undo .
define input parameter p-previous-shift-date as   date                    no-undo .
define input parameter p-batch               as   integer                 no-undo .

define variable vss-revision    as character no-undo initial "$Revision: e2c00fbc6380, 2303, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Fri Feb 14 16:31:04 2020 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-shft3r.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-shft3r.p $":U .
define variable vss-description as character no-undo initial "печать сменного отчета (ЮКОС лист 3 сбор данных)":U .

{ cmp/str-glbl.i                }
{ cmp/library.i                 }
{ cmp/r-page1.i                 }
{ rep/real-3df.i shared treal-3 }
{ rep/icm-3df.i  shared         }
{ arc/stk-lnrv.i def            }
{ rep/real-3cr.i        treal-3 }
{ trg/factord.i                 }
{ ref/gds-attr.i }
{ gbl/ggoattr.i }

define variable curr-grp-code like ub.gds-grp.node-code no-undo .
define variable loc-ii        as   integer              no-undo initial 1 .
define variable for-supp-name as   character            no-undo .
define variable cnum-entries  as   integer              no-undo .
define variable v-curr-r-b    as   character            no-undo .
define variable v-value as character no-undo .
define variable v-type as character no-undo .
define variable v-upper-code  like ub.gds-grp.node-code no-undo .
define variable v-p-accsup    as   character            no-undo .
define variable v-grp-name    as    character           no-undo .

define buffer buf_gds-grp   for ub.gds-grp  .
define buffer from-stk-line for ub.stk-line .
define buffer to-stk-line   for ub.stk-line .
define buffer buf_t-3       for t-3 .

/* Учет расходных материалов */
{ gbl/conf-rd.i
  "'accsup'"
  "''"
  "''"
  0
  "''"
  "''"
  "''"
  no
  v-p-accsup
  v-type
  no-error
}

{ gbl/curr-r-b.i
  v-curr-r-b
}

/* находим fact-order */
{ rep/r-shftfo.i attr-arh-detail-date }
{ arc/stk-lnrv.i }
for each tincome-3
:
  delete tincome-3 .
end.

/* найдем перечень групп по архивам */
if pclassify = "totals":U
then do:
  find first t-3 where
             t-3.grp-code = 0 no-error .
end.

_gds-obj:
for each  ub.gds-obj no-lock where
          ub.gds-obj.obj-type = pobj-type and
          ub.gds-obj.obj-code = pobj-code
  , first ub.goods   no-lock where
          ub.goods.artic     = ub.gds-obj.artic     and
          ub.goods.prod-type = ub.gds-obj.prod-type and
          ub.goods.prod-code = ub.gds-obj.prod-code and
          ub.goods.gds-type  = {&gds-goods}
  , first ub.units   no-lock where
          ub.units.unit-name = ub.goods.unit-base
:
  if lookup( {&petrolium},  ub.units.type ) > 0 and
     lookup( {&divisional}, ub.units.type ) > 0
  then do:
    v-value = ''.
    run gds-attr-value in this-procedure (
                                            input ub.gds-obj.gds-code
                                          ,input {&attr-ptrl-as-good}
                                          ,output v-value
                                          ,output v-type) no-error.
    if not Logical(v-value) then do:
    next .
  end.
  end.
  
  /* #2789 Если есть атрибут группы товара Не учитывать в автоматической отчетности, то пропускаем товар */  
  v-upper-code = ub.goods.grp-code.
  v-value = "".
  do while v-upper-code > 0 and v-p-accsup = "yes" and p-batch > 0:      
      find first ub.gds-grp where ub.gds-grp.node-code = v-upper-code.
      
      run ggoattr-value(
        input ub.gds-grp.node-code,
        input 0,
        input "",
        input 0,
        input {&ggoattr-no-inc-auto-rep},
        output v-value,
        output v-type
      ).
      
      if v-value = "yes" then
        leave.
      else
        v-upper-code = ub.gds-grp.upper-code.
  end.  
  if v-value = "yes" then next.
  /* --------- */
  
  Find Last from-stk-line no-lock where
            from-stk-line.obj-type    = pobj-type            and
            from-stk-line.obj-code    = pobj-code            and
            from-stk-line.artic       = ub.gds-obj.artic     and
            from-stk-line.prod-type   = ub.gds-obj.prod-type and
            from-stk-line.prod-code   = ub.gds-obj.prod-code and
            from-stk-line.cat-id      = {&root-cat-id}       and
            from-stk-line.sum-type    = {&arh-crsa}          and
            from-stk-line.fact-order <= prev-fo              use-index category no-error .
  find last to-stk-line no-lock where
            to-stk-line.obj-type    = pobj-type            and
            to-stk-line.obj-code    = pobj-code            and
            to-stk-line.artic       = ub.gds-obj.artic     and
            to-stk-line.prod-type   = ub.gds-obj.prod-type and
            to-stk-line.prod-code   = ub.gds-obj.prod-code and
            to-stk-line.cat-id      = {&root-cat-id}       and
            to-stk-line.sum-type    = {&arh-crsa}          and
            to-stk-line.fact-order <= fo                   use-index category no-error .

  /* определение группы по товару в curr-grp-code */
 
v-grp-name = replace (ub.goods.grp-name," /","/") .
  if pclassify    = "totals":U and
     X-selectgood = {&g-grp}
  then do:
    find first buf_t-3 where
               v-grp-name begins buf_t-3.serv-name no-error .
    if not available buf_t-3
    then do:
      next .
    end.
  end.
  else do:
    find first t-3 where
               v-grp-name begins     t-3.serv-name no-error .
    if not available t-3
    then do:
      next .
    end.
  end.

  assign
    curr-grp-code    = t-3.grp-code-sheet
    t-3.qnty1-before = t-3.qnty1-before + ( if available from-stk-line then from-stk-line.fact-qnty else 0 )
    t-3.netto-before = t-3.netto-before + ( if available from-stk-line
                                            then ( if v-curr-r-b = {&r-b-rubl}
                                                   then from-stk-line.sum-rubl
                                                   else from-stk-line.sum-base )
                                            else 0 )
    t-3.qnty1-after  = t-3.qnty1-after  + ( if available to-stk-line
                                            then to-stk-line.fact-qnty
                                            else ( if available from-stk-line then from-stk-line.fact-qnty else 0 ) )
    t-3.netto-after  = t-3.netto-after  + ( if available to-stk-line
                                            then ( if v-curr-r-b = {&r-b-rubl}
                                                   then to-stk-line.sum-rubl
                                                   else to-stk-line.sum-base )
                                            else ( if available from-stk-line
                                                   then ( if v-curr-r-b = {&r-b-rubl}
                                                          then from-stk-line.sum-rubl
                                                          else from-stk-line.sum-base )
                                                   else 0 ) )
  .
  if moving <> yes
  then do:
    next _gds-obj .
  end.
  if (not available from-stk-line
      and
      not available to-stk-line)
  or (available from-stk-line
      and
      available to-stk-line
      and from-stk-line.fact-order = to-stk-line.fact-order) then do:
    /*если не было движения то дальше фиксируем только остатки*/
    next _gds-obj .
  end.


  /* заполнение данными по приходу */
  for each ub.ot-line no-lock where
           ub.ot-line.obj-type    = pobj-type            and
           ub.ot-line.obj-code    = pobj-code            and
           ub.ot-line.artic       = ub.gds-obj.artic     and
           ub.ot-line.prod-type   = ub.gds-obj.prod-type and
           ub.ot-line.prod-code   = ub.gds-obj.prod-code and
           ub.ot-line.fact-order >= prev-fo              and
           ub.ot-line.fact-order <= fo                   and
           ub.ot-line.cat-id      = {&root-cat-id}       and
           ub.ot-line.sum-type    = {&arh-cost}
  :
    if not ( ub.ot-line.ext-doc-type = {&TDEDT_Pri_Vnesh}     or
             ub.ot-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} or
             ub.ot-line.ext-doc-type = {&TDEDT_Pri_Perem}     or
             ub.ot-line.ext-doc-type = {&TDEDT_Vozvrat_Perem} or
             ub.ot-line.ext-doc-type = {&TDEDT_Pri_Prvo}    )
    then do:
      next .
    end.
    find first tincome-3 where
               tincome-3.grp-code-sheet = curr-grp-code       and
               tincome-3.doc-code       = ub.ot-line.doc-code no-error .
    if not available tincome-3
    then do:
      find first ub.trn-doc no-lock where
                 ub.trn-doc.doc-code = ub.ot-line.doc-code no-error .
      if available ub.trn-doc then do:
        find first ub.clients no-lock where
                   ub.clients.obj-type = ub.trn-doc.cli-type and
                   ub.clients.obj-code = ub.trn-doc.cli-code no-error .
      end.
      create tincome-3 .
      assign
        tincome-3.grp-code-sheet = curr-grp-code
        tincome-3.supp-name      = ( if available ub.clients then ub.clients.obj-name else "":U )
        tincome-3.supp-type      = ub.trn-doc.cli-type
        tincome-3.supp-code      = ub.trn-doc.cli-code
        tincome-3.doc-code       = ub.ot-line.doc-code
        tincome-3.ii             = t-3.lines + 1
        t-3.lines                = t-3.lines + 1
      .
    end.
    assign
      tincome-3.qnty1-in  = tincome-3.qnty1-in + ub.ot-line.fact-qnty
      tincome-3.netto-in  = tincome-3.netto-in + ub.ot-line.sum-base
      tincome-3.is-fact  = yes
    .
  end. /* for each ub.trn-doc no-lock where */
  /* заполнение данными по архивам - инвентаризация и т.д. */
  /* по архивам найдем реализацию и т.д. */
  for each tt-stk-line
  :
    delete tt-stk-line .
  end.

  run stk-lnrv in this-procedure
    (  input       pobj-type
    ,  input       pobj-code
    ,  input       ub.gds-obj.artic
    ,  input       ub.gds-obj.prod-type
    ,  input       ub.gds-obj.prod-code
    ,  input       prev-fo
    ,  input       fo
    ,  input       {&arh-sadt}
    ,  input       {&root-cat-id}
    ,  input       yes
    , output table tt-stk-line
    ) no-error .
  for each tt-stk-line /* tt-stk-line.artic = t-2gds and ... */
  :
    /* поскольку все цифры лягут в графу расход и должны быть там положительными все цифры идут с минусами!!! */
    case substring( tt-stk-line.sum-type, length( {&arh-sadt} ) + 1 ) :
      when {&TDEDT_Inv}      or
      when {&TDEDT_Peresort}
      then do:
        find first treal-3 where
                   treal-3.grp-code-sheet = curr-grp-code and
                   treal-3.cpay-code      = -4            and
                   treal-3.curr-code      = 0             no-error .
        if not available treal-3
        then do:
          run create-treal-3 in this-procedure
            ( input t-3.grp-code-sheet
            , input -4
            , input 0
            , input - tt-stk-line.fact-qnty
            , input - tt-stk-line.sum-base
            , input "Инвентаризации"
            , input no
            , input ?
            ) no-error .
        end.
        else do:
          assign
            treal-3.qnty1 = treal-3.qnty1 - tt-stk-line.fact-qnty
            treal-3.netto = treal-3.netto - tt-stk-line.sum-base
          .
        end.
      end.
      when {&TDEDT_Ras_Vnesh}
      then do:
        find first treal-3 where
                   treal-3.grp-code-sheet = curr-grp-code and
                   treal-3.cpay-code      = -3            and
                   treal-3.curr-code      = 0             no-error .
        if not available treal-3
        then do:
          run create-treal-3 in this-procedure
            ( input t-3.grp-code-sheet
            , input -3
            , input 0
            , input - tt-stk-line.fact-qnty
            , input - tt-stk-line.sum-base
            , input "Отпуск без ККМ"
            , input no
            , input ?
            ) no-error .
        end.
        else do:
          assign
            treal-3.qnty1 = treal-3.qnty1 - tt-stk-line.fact-qnty
            treal-3.netto = treal-3.netto - tt-stk-line.sum-base
          .
        end.
      end.
      when {&TDEDT_Pri_Vnesh}          or
      when {&TDEDT_Ras_Vnesh_Kass}     or
      when {&TDEDT_Vozvrat_Vnesh_Kass} or
      when {&TDEDT_Vozvrat_Vnesh}      or
      when {&TDEDT_Pri_Perem}          or
      when {&TDEDT_Vozvrat_Perem}      or
      when {&TDEDT_Pri_Prvo}
      then do:
        /* уже учли */
      end.
      otherwise do:
        find first treal-3 where
                   treal-3.grp-code-sheet = curr-grp-code and
                   treal-3.cpay-code      = -1            and
                   treal-3.curr-code      = 0             no-error .
        if not available treal-3
        then do:
          run create-treal-3 in this-procedure
            ( input t-3.grp-code-sheet
            , input -1
            , input 0
            , input - tt-stk-line.fact-qnty
            , input - tt-stk-line.sum-base
            , input "Прочий докум.расход"
            , input no
            , input ?
            ) no-error .
        end.
        else do:
          assign
            treal-3.qnty1 = treal-3.qnty1 - tt-stk-line.fact-qnty
            treal-3.netto = treal-3.netto - tt-stk-line.sum-base
          .
        end.
      end.
      /* todo как прочие расходы будем определять ???????????? */
    end.
    delete tt-stk-line .
  end.
end. /* for each ub.gds-obj */
