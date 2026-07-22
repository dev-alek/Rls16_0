block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fctnumch.p $
$Archive: utl/fctnumch.p $

Изменить фактический номер закрытия накладной или переоценки

Автор: Чернова Светлана Александровна
Дата создания: 05/08/07
Author: Svetlana Chernova
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/05/06

Процедура используется для изменения фактических номеров закрытия документов
с тем, чтобы при расчете архивов не возникали ошибки

*/

define input parameter p-doc-code     as character no-undo .
define input parameter p-doc-type     as character no-undo .
define input parameter p-new-fact-num as integer   no-undo .
define input parameter p-log-change   as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fctnumch.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fctnumch.p $":U .
define variable vss-description as character no-undo init "Изменить фактический номер закрытия накладной или переоценки".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/factord.i  }
{ gbl/cur-time.i }

on write of ub.trn-doc   override do: end.
on write of ub.price-doc override do: end.

do
on error undo, return error
:

  case p-doc-type :
    when {&table_trn-doc} then do:
      run trn-doc-fact-num in this-procedure
        (input p-doc-code
        ,input p-new-fact-num
        ).
    end.
    when {&table_price-doc} then do:
      run price-doc-fact-num in this-procedure
        (input p-doc-code
        ,input p-new-fact-num
        ).
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        view-as alert-box error .
      undo, return error .
    end.
  end case. /* p-doc-type */
end.



procedure trn-doc-fact-num :

  define input parameter p-doc-code as character no-undo .
  define input parameter p-new-fact-num as integer no-undo .

  do
  on error undo, return error
  :
    define variable v-today as date      no-undo.
    define variable v-time  as integer   no-undo.

    find first ub.trn-doc exclusive-lock
      where ub.trn-doc.doc-code = p-doc-code
      .

    if p-log-change <> false then do:
      output to fctnumch.txt append .
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      export
        ub.trn-doc.obj-type
        ub.trn-doc.obj-code
        "trn-doc_old-fact-num_new-fact-num"
        string(v-today, '99/99/9999')
        string(v-time, 'HH:MM')
        ub.trn-doc.doc-code
        ub.trn-doc.fact-num
        p-new-fact-num
        .
      output close .
    end.

    assign
      ub.trn-doc.fact-num = p-new-fact-num
    .

    define variable l-shift-on as logical no-undo .
    { gbl/objat.i
      ub.trn-doc.obj-type
      ub.trn-doc.obj-code
      "'shift-on=request'"
      l-shift-on
    }

    define variable v-fact-order           as decimal no-undo .
    define variable v-shift-end-fact-order as decimal no-undo .
    define variable v-day-end-fact-order   as decimal no-undo .

    run factord in this-procedure
      (input  trn-doc.fact-date   /* p-fact-date            */
      ,input  trn-doc.fact-time   /* p-fact-time            */
      ,input  trn-doc.fact-num    /* p-fact-num             */
      ,input  trn-doc.shift-date  /* p-shift-date           */
      ,input  trn-doc.shift-num   /* p-shift-num            */
      ,input  l-shift-on              /* p-shift-on             */
      ,output v-fact-order            /* p-fact-order           */
      ,output v-shift-end-fact-order  /* p-shift-end-fact-order */
      ,output v-day-end-fact-order    /* p-day-end-fact-order   */
      ) .
    assign
      trn-doc.fact-order = v-fact-order
    .

    for each doc-line exclusive-lock
      where doc-line.doc-code = ub.trn-doc.doc-code
    on error undo, return error
    :
      assign
        doc-line.fact-order = ub.trn-doc.fact-order
      .
    end.
  end.

end procedure. /* trn-doc-fact-num */

procedure price-doc-fact-num :

  define input parameter p-doc-code as character no-undo .
  define input parameter p-new-fact-num as integer no-undo .

  do
  on error undo, return error
  :
    define variable v-today as date      no-undo.
    define variable v-time  as integer   no-undo.

    find first ub.price-doc exclusive-lock
      where ub.price-doc.doc-num = p-doc-code
      .

    if p-log-change <> false then do:
      output to fctnumch.txt append .
      run cur-time in this-procedure ( output v-today
                                     , output v-time
                                     ).
      export
        ub.price-doc.obj-type
        ub.price-doc.obj-code
        "price-doc_old-fact-num_new-fact-num"
        string(v-today, '99/99/9999')
        string(v-time, 'HH:MM')
        ub.price-doc.doc-num
        ub.price-doc.fact-num
        p-new-fact-num
        .
      output close .
    end.

    assign
      ub.price-doc.fact-num = p-new-fact-num
    .

    define variable l-shift-on as logical no-undo .
    { gbl/objat.i
      ub.price-doc.obj-type
      ub.price-doc.obj-code
      "'shift-on=request'"
      l-shift-on
    }

    define variable v-fact-order           as decimal no-undo .
    define variable v-shift-end-fact-order as decimal no-undo .
    define variable v-day-end-fact-order   as decimal no-undo .

    run factord in this-procedure
      (input  price-doc.fact-date   /* p-fact-date            */
      ,input  price-doc.fact-time   /* p-fact-time            */
      ,input  price-doc.fact-num    /* p-fact-num             */
      ,input  price-doc.shift-date  /* p-shift-date           */
      ,input  price-doc.shift-num   /* p-shift-num            */
      ,input  l-shift-on              /* p-shift-on             */
      ,output v-fact-order            /* p-fact-order           */
      ,output v-shift-end-fact-order  /* p-shift-end-fact-order */
      ,output v-day-end-fact-order    /* p-day-end-fact-order   */
      ) .
    assign
      price-doc.fact-order = v-fact-order
    .

    for each price-list exclusive-lock
      where price-list.doc-num = ub.price-doc.doc-num
    on error undo, return error
    :
      assign
        price-list.fact-order = ub.price-doc.fact-order
      .
    end.
  end.

end procedure. /* price-doc-fact-num */