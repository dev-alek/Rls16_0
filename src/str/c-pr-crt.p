block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: c-pr-crt.p $
$Archive: str/c-pr-crt.p $

Копирование переоценки

Автор: Чернова Светлана Александровна
Дата создания: 04/10/02
Author: Svetlana Chernova
Creation date: 04/10/02



*/

define input  parameter p-doc-num  like ub.price-doc.doc-num no-undo .
define output parameter p-chip-num like ub.c-price-doc.chip-num no-undo .
define variable p-corr-doc-code like ub.price-doc.doc-num no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: c-pr-crt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/c-pr-crt.p $":U .
define variable vss-description as character no-undo init "Копирование переоценки ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ trg/factord.i  }
{ trg/partslib.i }
define variable num_rec        as integer   no-undo .
define variable start-time     as integer   no-undo .
define variable current-time   as character no-undo .
define variable current-action as character no-undo .
define variable v-description-ord-type as character no-undo .
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.
define variable parobj-date   like c-price-doc.corr-date         no-undo .
define variable parshift-date like c-price-doc.corr-shift-date   no-undo .
define variable parshift-num  like c-price-doc.corr-shift-num    no-undo .
define variable parshift-name as character no-undo.


/* для показа процесса переоценки */

define frame a
  ub.price-doc.doc-num                       label "Переоценка" skip
  ub.price-doc.status_                       label "Статус" skip
  current-action         format "x(40)"      no-label skip
  num_rec                format ">>>>>>>9"   label "Обработано артикулов" skip
  ub.price-list.artic                        label "Текущий артикул" skip
  current-time           format "x(8)"       label "Время" skip
  with view-as dialog-box side-labels three-d
  title "Пересчет переоценки"
  .


main-block :
do transaction
on error undo main-block, return error
:

  find first ub.price-doc where ub.price-doc.doc-num = p-doc-num  no-lock no-error .
  if not available ub.price-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Номер переоценки " p-doc-num skip
      error-status :get-message(1)
      view-as alert-box error .
    undo, return error.
  end.

  view frame a.
    display
    ub.price-doc.doc-num
    ub.price-doc.status_
    with frame a.
/*----------------------------------------*/
  assign
    current-action = "Копирование  шапки."
  .
  run show-action in this-procedure (current-action) .



  { gbl/curobjdt.i ub.price-doc.obj-type ub.price-doc.obj-code parobj-date no-error }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении дат на объекте" skip
        "ПЕРЕОЦЕНКА" ub.price-doc.doc-num skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      { gbl/stopwork.i }
      undo main-block, return error .
    end.


  { gbl/curshift.i ub.price-doc.obj-type ub.price-doc.obj-code parshift-date parshift-num parshift-name no-error }
    if error-status :error then do:
        assign
          parshift-date = ?
          parshift-num = 0 .
        .
    end.


  create c-price-doc.
  BUFFER-COPY ub.price-doc to c-price-doc
    assign
    c-price-doc.chip-num        = next-value (s-corr-chip, {&db-name_schema})
    c-price-doc.corr-man        = g#userid
    c-price-doc.corr-date       = parobj-date
    c-price-doc.corr-time       = v-time
    c-price-doc.corr-user-db-num = g#db-num
    c-price-doc.corr-shift-date = parshift-date
    c-price-doc.corr-shift-num  = parshift-num
    c-price-doc.corr-shift-name = parshift-name
    c-price-doc.ps              = c-price-doc.PS + ": Копирование в архив"
    c-price-doc.is-corr         = true
    p-chip-num = c-price-doc.chip-num
    no-error .

    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при копировании шапки переоценки" skip
        "ПЕРЕОЦЕНКА" ub.price-doc.doc-num skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      { gbl/stopwork.i }
      undo main-block, return error .
    end.
/*----------------------------------------*/
  assign
    current-action = "Копирование строк."
  .
  run show-action (current-action) .


  for each  ub.price-list exclusive-lock
      where ub.price-list.doc-num    = ub.price-doc.doc-num and
            ub.price-list.main-price = true
  on error undo main-block, return error
  on end-key undo main-block, return error
  :
    run process-line in this-procedure no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при копировании строки переоценки" skip
        "ПЕРЕОЦЕНКА" ub.price-doc.doc-num skip
        "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      { gbl/stopwork.i }
      undo main-block, return error .
    end.
  end.  /* for each ub.price-list */
/*-----------------------*/
end. /*do*/



procedure show-action :
  do
  on error undo, return error
  :
    define input parameter p-action as character no-undo .

    define variable v-today as date      no-undo.
    define variable v-time  as integer   no-undo.

    run cur-time in this-procedure ( output v-today
                                   , output v-time
                                   ).
    assign
      current-time = string(v-time - start-time, "HH:MM:SS")
      current-action = p-action
    .
    display
      current-time current-action
      with frame a.

  end.
end procedure. /* show-action */


procedure process-line :
do
on error undo, return error
:
define variable v-today as date      no-undo.
define variable v-time  as integer   no-undo.

    assign
      num_rec   = num_rec + 1
    .

    if num_rec mod 10 = 0 then do:
      run cur-time in this-procedure ( output v-today
                                     , output v-time ).
      assign
        current-time = string(v-time - start-time, "HH:MM:SS")
      .
      create c-price-list.
      BUFFER-COPY ub.price-list to c-price-list
      assign
        c-price-list.chip-num           = c-price-doc.chip-num
        c-price-list.corr-user-name     = g#userid
        c-price-list.corr-date          = parobj-date
        c-price-list.corr-time          = v-time
        c-price-list.corr-user-db-num   = g#db-num

      no-error .
      if error-status :error then do:
        message
        vss-workfile vss-revision vss-description skip
        "Ошибка при копировании строки переоценки BC" skip
        "ПЕРЕОЦЕНКА" ub.price-doc.doc-num skip
        "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      { gbl/stopwork.i }
      undo, return error .

          end.
      display
        num_rec ub.price-list.artic  current-time current-action
        with frame a.
    end.
  end.
end procedure . /* process-line */
/* $Workfile: c-pr-crt.p $ e n d */