block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: prcs-lst.p $
$Archive: gbl/prcs-lst.p $

Преобразование строки вида 1-5,9 в список вида 1,2,3,4,5,9
РАБОТАЕТ ТОЛЬКО С ПОЛОЖИТЕЛЬНЫМИ ЧИСЛАМИ!!!

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/31/06
Author: Dmitry Ukhanov
Creation date: 03/31/06

*/

define input parameter p-string     as character no-undo .
define input parameter p-min-val    as integer   no-undo .
define input parameter p-max-val    as integer   no-undo .
define input parameter p-first-err  as logical   no-undo .
define input parameter p-handle-tbl as handle    no-undo .
define input parameter p-field-name as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: prcs-lst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/prcs-lst.p $":U .
define variable vss-description as character no-undo init "Преобразование строки вида 1-5,9 в список вида 1,2,3,4,5,9".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  define variable v-err-msg      as character no-undo .
  define variable v-num-entries  as integer   no-undo .
  define variable v-num-entries1 as integer   no-undo .
  define variable v-ind          as integer   no-undo .
  define variable v-ind1         as integer   no-undo .
  define variable v-val-str      as character no-undo .
  define variable v-val-tmp      as character no-undo .
  define variable v-val-int      as integer   no-undo .
  define variable v-val-beg      as integer   no-undo .
  define variable v-val-end      as integer   no-undo .

  define variable fh             as handle    no-undo .

  assign
    v-err-msg     = "":U
    v-num-entries = num-entries( p-string, ",":U )
  .
  block_list:
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    assign
      v-val-str = trim( entry( v-ind, p-string, ",":U ) )
    .
    if v-val-str = "":U then do:
      next block_list.
    end.

    if num-entries( v-val-str, "-":U ) > 1 then do:
      assign
        v-val-tmp = trim( entry( 1, v-val-str, "-":U ) )
      .
      if v-val-tmp = "":U then do:
        if p-first-err = true then do:
          assign
            v-err-msg = substitute( 'задание списка "&1" некорректно; первое число отрицательное', v-val-str )
          .
          leave block_list.
        end.
        else do:
          next block_list.
        end.
      end.
      assign
        v-val-beg = integer( v-val-tmp )
        no-error
      .
      if error-status :error then do:
        if p-first-err = true then do:
          assign
            v-err-msg = substitute( "значение &1 не числовое", v-val-tmp )
          .
          leave block_list.
        end.
        else do:
          next block_list.
        end.
      end.
      if v-val-beg < p-min-val then do:
        if p-first-err = true then do:
          assign
            v-err-msg = substitute( "значение &1 меньше минимально допустимого (&2)", v-val-tmp, p-min-val )
          .
          leave block_list.
        end.
        else do:
          next block_list.
        end.
      end.
      assign
        v-val-tmp = trim( entry( num-entries( v-val-str, "-":U ), v-val-str, "-":U ) )
      .
      if v-val-tmp = "":U then do:
        if p-first-err = true then do:
          assign
            v-err-msg = substitute( 'задание списка "&1" некорректно; должно быть вида "1-5"', v-val-str )
          .
          leave block_list.
        end.
        else do:
          next block_list.
        end.
      end.
      assign
        v-val-end = integer( v-val-tmp )
        no-error
      .
      if error-status :error then do:
        if p-first-err = true then do:
          assign
            v-err-msg = substitute( "значение &1 не числовое", v-val-tmp )
          .
          leave block_list.
        end.
        else do:
          next block_list.
        end.
      end.
      if v-val-end > p-max-val then do:
        if p-first-err = true then do:
          assign
            v-err-msg = substitute( "значение &1 больше максимально допустимого (&2)", v-val-tmp, p-max-val )
          .
          leave block_list.
        end.
        else do:
          next block_list.
        end.
      end.

      assign
        v-ind1 = v-val-beg
      .

      block_dash:
      do while true
      on error undo, return error return-value
      :
        if v-ind1 = p-max-val + 1 then do:
          assign
            v-ind1 = p-min-val
          .
        end.

        p-handle-tbl:find-first( substitute( "where &1 = &2", p-field-name, v-ind1 ), no-lock ) no-error .

        if not p-handle-tbl:available then do:
          p-handle-tbl:buffer-create.
          assign
            fh = p-handle-tbl:buffer-field( p-field-name ).
            fh:buffer-value() = v-ind1
          .
        end.

        if v-ind1 = v-val-end then do:
          leave block_dash.
        end.
        assign
          v-ind1 = v-ind1 + 1
        .
      end.
    end.
    else do:
      assign
        v-val-int = integer( v-val-str )
        no-error
      .
      if error-status :error then do:
        if p-first-err = true then do:
          assign
            v-err-msg = substitute( "значение &1 не числовое", v-val-str )
          .
          leave block_list.
        end.
        else do:
          next block_list.
        end.
      end.
      if v-val-int > p-max-val then do:
        if p-first-err = true then do:
          assign
            v-err-msg = substitute( "значение &1 больше максимально допустимого (&2)", v-val-str, p-max-val )
          .
          leave block_list.
        end.
        else do:
          next block_list.
        end.
      end.
      if v-val-int < p-min-val then do:
        if p-first-err = true then do:
          assign
            v-err-msg = substitute( "значение &1 меньше минимально допустимого (&2)", v-val-str, p-min-val )
          .
          leave block_list.
        end.
        else do:
          next block_list.
        end.
      end.

      p-handle-tbl:find-first( substitute( "where &1 = &2", p-field-name, v-val-int ), no-lock ) no-error .

      if not p-handle-tbl:available then do:
        p-handle-tbl:buffer-create.
        assign
          fh = p-handle-tbl:buffer-field( p-field-name ).
          fh:buffer-value() = v-val-int
        .
      end.

    end.
  end.

  if v-err-msg <> "":U then do:
    return error v-err-msg.
  end.
  else do:
    return.
  end.

end.

/* $Workfile: prcs-lst.p $ e n d */