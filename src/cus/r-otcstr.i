/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обработка одного документа

Автор: Бахтадзе Наталья Викторовна
Дата создания: 03/24/06
Author: Bakhtadze Natalya
Creation date: 03/24/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" = "rest" &then
/*данные по остаткам на конец*/

_temp-parts:
for each temp-parts :
  if temp-parts.is-supp = no or temp-parts.cst-code = "" then next _temp-parts.
  if can-find(first tt-file-ignore where
                    tt-file-ignore.doc-code = temp-parts.in-code AND
                    tt-file-ignore.artic = temp-parts.artic AND
                    tt-file-ignore.prod-type = temp-parts.prod-type AND
                    tt-file-ignore.prod-code = temp-parts.prod-code) then NEXT _temp-parts.
  my-accum = my-accum + 1.

  IF my-accum MODULO 50  = 0 then do:
    run waitfram-show in this-procedure ({&wmess} + " Обработано " + string(my-accum) + " партий остатков ").
  end.

  find first tt-cst where
              tt-cst.cst-code = temp-parts.cst-code AND
              tt-cst.artic = temp-parts.artic AND
              tt-cst.prod-type = temp-parts.prod-type AND
              tt-cst.prod-code = temp-parts.prod-code NO-ERROR.
  if not avail tt-cst then do:
    FIND FIRST ub.goods NO-LOCK where
                ub.goods.artic = temp-parts.artic AND
                ub.goods.prod-type = temp-parts.prod-type AND
                ub.goods.prod-code = temp-parts.prod-code No-ERROR.
    if not avail ub.goods then do:
    end.
    FIND FIRST ub.doc-line NO-LOCK WHERE
                ub.doc-line.doc-code = temp-parts.in-code AND
                ub.doc-line.artic = temp-parts.artic AND
                ub.doc-line.prod-type = temp-parts.prod-type AND
                ub.doc-line.prod-code = temp-parts.prod-code NO-ERROR.
    if not avail ub.doc-line then do:
    end.
    create tt-cst.
    assign
    tt-cst.cst-code = temp-parts.cst-code
    tt-cst.artic = temp-parts.artic
    tt-cst.prod-type = temp-parts.prod-type
    tt-cst.prod-code = temp-parts.prod-code
    tt-cst.nationality = ub.goods.nationality
    tt-cst.name_artic_unit = string(ub.goods.gds-name,
                                    ("X(" + string({&nau-length} - 5 - length(ub.goods.artic)) + ")") )
                                          +  {&space-char} +
                              ub.goods.artic + {&space-char} +
                              string(ub.goods.unit-base, "X(3)")
    tt-cst.tnved = ub.goods.tnved
    .
  end.
  assign
  tt-cst.qnty-rest = tt-cst.qnty-rest + temp-parts.fact-qnty
  .
  end.

/*{1} = rest*/
&endif



&if "{1}" = "start" &then
/*данные по остаткам на начало*/

_temp-parts:
for each temp-parts :
  if temp-parts.is-supp = no or temp-parts.cst-code = "" then next _temp-parts.
  if can-find(first tt-file-ignore where
                    tt-file-ignore.doc-code = temp-parts.in-code AND
                    tt-file-ignore.artic = temp-parts.artic AND
                    tt-file-ignore.prod-type = temp-parts.prod-type AND
                    tt-file-ignore.prod-code = temp-parts.prod-code) then NEXT _temp-parts.
  my-accum = my-accum + 1.

  IF my-accum MODULO 50  = 0 then do:
    run waitfram-show in this-procedure ({&wmess} + " Обработано " + string(my-accum) + " партий остатков ").
  end.

  find first tt-cst where
              tt-cst.cst-code = temp-parts.cst-code AND
              tt-cst.artic = temp-parts.artic AND
              tt-cst.prod-type = temp-parts.prod-type AND
              tt-cst.prod-code = temp-parts.prod-code NO-ERROR.
  if not avail tt-cst then do:
    FIND FIRST ub.goods NO-LOCK where
                ub.goods.artic = temp-parts.artic AND
                ub.goods.prod-type = temp-parts.prod-type AND
                ub.goods.prod-code = temp-parts.prod-code No-ERROR.
    if not avail ub.goods then do:
    end.
    FIND FIRST ub.doc-line NO-LOCK WHERE
                ub.doc-line.doc-code = temp-parts.in-code AND
                ub.doc-line.artic = temp-parts.artic AND
                ub.doc-line.prod-type = temp-parts.prod-type AND
                ub.doc-line.prod-code = temp-parts.prod-code NO-ERROR.
    if not avail ub.doc-line then do:
    end.
    create tt-cst.
    assign
    tt-cst.cst-code = temp-parts.cst-code
    tt-cst.artic = temp-parts.artic
    tt-cst.prod-type = temp-parts.prod-type
    tt-cst.prod-code = temp-parts.prod-code
    tt-cst.nationality = ub.goods.nationality
    tt-cst.name_artic_unit = string(ub.goods.gds-name,
                                    ("X(" + string({&nau-length} - 5 - length(ub.goods.artic)) + ")") )
                                          +  {&space-char} +
                              ub.goods.artic + {&space-char} +
                              string(ub.goods.unit-base, "X(3)")
    tt-cst.tnved = ub.goods.tnved
    .
  end.
  assign
  tt-cst.qnty-start = tt-cst.qnty-start + temp-parts.fact-qnty
  .
  delete temp-parts.
end.

/*{1} = start*/
&endif


&if "{1}" = "moving" &then
/*данные про движению за отчетный период*/
_for-line:
FOR  each for-line NO-LOCk WHERE for-line.doc-code = doc-num:
  my-accum = my-accum + 1.
  IF my-accum MODULO 50  = 0 then do:
    run waitfram-show in this-procedure ({&wmess} + " Обработано " + string(my-accum) + " строк документов ").
  end.
  _parts:
  FOR EACH ub.parts NO-LOCK WHERE
          ub.parts.artic = for-line.artic AND
          ub.parts.prod-type = for-line.prod-type AND
          ub.parts.prod-code = for-line.prod-code AND
          ub.parts.out-code = doc-num AND
          ub.parts.obj-type = for-line.obj-type AND
          ub.parts.obj-code = for-line.obj-code:
    if ub.parts.cst-code = "" then NEXT _parts.
    IF ub.parts.is-supp = no /*только партии внешнего прихода*/ then NEXT _parts.
    if can-find(first tt-file-ignore where
                      tt-file-ignore.doc-code = ub.parts.in-code AND
                      tt-file-ignore.artic = for-line.artic AND
                      tt-file-ignore.prod-type = for-line.prod-type AND
                      tt-file-ignore.prod-code = for-line.prod-code) then NEXT _for-line.

    FIND FIRST tt-cst WHERE
               tt-cst.cst-code = ub.parts.cst-code AND
               tt-cst.artic = for-line.artic AND
               tt-cst.prod-type = for-line.prod-type AND
               tt-cst.prod-code = for-line.prod-code No-ERROR.

    if not avail tt-cst then do:
    /*товар к концу отчетного периода вышел в нуль по всем объектам в отдельности!! поэтому его нет*/
      FIND FIRST ub.goods NO-LOCK where
                 ub.goods.artic = for-line.artic AND
                 ub.goods.prod-type = for-line.prod-type AND
                 ub.goods.prod-code = for-line.prod-code No-ERROR.
      if not avail ub.goods then do:
      end.
      create tt-cst.
      assign
      tt-cst.cst-code = parts.cst-code
      tt-cst.artic = for-line.artic
      tt-cst.prod-type = for-line.prod-type
      tt-cst.prod-code = for-line.prod-code
      tt-cst.nationality = ub.goods.nationality
      tt-cst.name_artic_unit = string(ub.goods.gds-name,
                                      ("X(" + string({&nau-length} - 5 - length(goods.artic)) + ")") )
                                           +  {&space-char} +
                               ub.goods.artic + {&space-char} +
                               string(ub.goods.unit-base, "X(3)")
      tt-cst.tnved = ub.goods.tnved
      .
    end.
    assign
    prt-qnty =  is-out * ub.parts.fact-qnty
    .
    assign
    tt-cst.qnty-sale = tt-cst.qnty-sale +  (if is-sale then prt-qnty else 0)
    tt-cst.qnty-ext_expence = tt-cst.qnty-ext_expence +  (if is-ext_expense then prt-qnty else 0)
    tt-cst.qnty-other_expence = tt-cst.qnty-other_expence + (if is-other_expense then prt-qnty else 0)
    .
    if is-ext_expense then do:
      create tt-cst-ext.
      assign
      tt-cst-ext.artic = for-line.artic
      tt-cst-ext.prod-type = for-line.prod-type
      tt-cst-ext.prod-code = for-line.prod-code
      tt-cst-ext.cst-code = ub.parts.cst-code
      tt-cst-ext.des = substr(for-doc.PS, 1 , r-index(for-doc.ps, "@":U) - 1)
      tt-cst-ext.qnty = ( - prt-qnty)
      .
    end.
  END. /*FOR EACH parts*/
END. /*FOR EACH for-line*/

/*{1} = moving*/

&endif

/* $Workfile$ e n d */