block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00198000.p $
$Archive: cut/00198000.p $

Файл пирога обрезания. Относится к категории 198.

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/05/09
Author: Dmitry Ukhanov
Creation date: 08/05/09

Обработка таблиц:
nws-doc-hist
nws-doc-hist-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00198000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00198000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 198.".
{ cmp/str-glbl.i }

define buffer old-nws-doc-hist for src.nws-doc-hist.
define buffer new-nws-doc-hist for dst.nws-doc-hist.
define buffer old-nws-doc-hist-attr for src.nws-doc-hist-attr.
define buffer new-nws-doc-hist-attr for dst.nws-doc-hist-attr.


define buffer new-trn-doc     for dst.trn-doc.
define buffer new-rvs-doc     for dst.rvs-doc.
define buffer new-price-doc   for dst.price-doc.
define buffer new-fbr-doc     for dst.fbr-doc.
define buffer new-wth-doc     for dst.wth-doc.
define buffer new-icnt-doc    for dst.icnt-doc.
define buffer new-inkas       for dst.inkas.
define buffer new-ord-cons    for dst.ord-cons.
define buffer new-ord-doc     for dst.ord-doc.
define buffer new-ord-doc-rcv for dst.ord-doc-rcv.

do
on error undo, return error
:
  { utl/00000001.i }
  on write of dst.nws-doc-hist override do: end.
  on write of dst.nws-doc-hist-attr override do: end.

  define variable v-need-copy as logical   no-undo .


  for each old-nws-doc-hist no-lock
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    assign
      v-need-copy = false
    .
    case old-nws-doc-hist.doc-type
    :
      when 'trn-doc':u
      then do:
        find first new-trn-doc no-lock
          where new-trn-doc.doc-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-trn-doc
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'rvs-doc':u
      then do:
        find first new-rvs-doc no-lock
          where new-rvs-doc.rvs-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-rvs-doc
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'price-doc':u
      then do:
        find first new-price-doc no-lock
          where new-price-doc.doc-num = old-nws-doc-hist.doc-code
          no-error .
        if available new-price-doc
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'fbr-doc':u
      then do:
        find first new-fbr-doc no-lock
          where new-fbr-doc.doc-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-fbr-doc
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'wth-doc':u
      then do:
        find first new-wth-doc no-lock
          where new-wth-doc.doc-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-wth-doc
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'icnt-doc':u
      then do:
        find first new-icnt-doc no-lock
          where new-icnt-doc.doc-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-icnt-doc
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'inkas':u
      then do:
        find first new-inkas no-lock
          where new-inkas.inkas-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-inkas
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'ord-cons':u
      then do:
        find first new-ord-cons no-lock
          where new-ord-cons.cons-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-ord-cons
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'ord-doc':u
      then do:
        find first new-ord-doc no-lock
          where new-ord-doc.doc-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-ord-doc
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
      when 'ord-doc-rcv':u
      then do:
        find first new-ord-doc-rcv no-lock
          where new-ord-doc-rcv.rcv-code = old-nws-doc-hist.doc-code
          no-error .
        if available new-ord-doc-rcv
        then do:
          assign
            v-need-copy = true
          .
        end.
      end.
    end.

    if v-need-copy = true
    then do:
      create new-nws-doc-hist.
      buffer-copy old-nws-doc-hist to new-nws-doc-hist.
    end.
  end.
  for each old-nws-doc-hist-attr no-lock
  on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
  :
    find first new-nws-doc-hist no-lock where
              new-nws-doc-hist.db-num = old-nws-doc-hist-attr.db-num
           and new-nws-doc-hist.ord-num = old-nws-doc-hist-attr.ord-num no-error.
    if available new-nws-doc-hist then do:
      create new-nws-doc-hist-attr.
      buffer-copy old-nws-doc-hist-attr to new-nws-doc-hist-attr.
    end.
  end.
  output stream str-gen close.
  return "Произведен экспорт таблиц: nws-doc-hist nws-doc-hist-attr .".
end.