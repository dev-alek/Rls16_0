block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: partini.p $
$Archive: utl/partini.p $

Инициализация партий на основании складских документов

Автор: Чернова Светлана Александровна
Дата создания: 02/26/07
Author: Svetlana Chernova
Creation date: 02/26/07

create: Перваков Михаил Сергеевич
Дата создания: 04/11/06

*/

define input parameter l-update-free-zone     as logical no-undo .
define input parameter l-update-out-zone      as logical no-undo .
define input parameter l-update-archive-parts as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: partini.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/partini.p $":U .
define variable vss-description as character no-undo init "Инициализация партий на основании складских документов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }


if l-update-free-zone then do:
  for each ub.parts
    where ub.parts.out-code = {&free-code}
  :
    run process-part.
    process events.
  end.
end.

if l-update-out-zone then do:
  for each ub.parts
    where ub.parts.out-code = {&output-code}
  :
    run process-part.
    process events.
  end.
end.

if l-update-archive-parts then do:
  for each ub.parts
    where ub.parts.out-code <> {&free-code}
      and ub.parts.out-code <> {&output-code}
  :
    run process-part.
    process events.
  end.
end.

procedure process-part :

  output to process.txt append .
  export ub.parts .
  output close .


  if ub.parts.doc-type = {&act-overvalue} then do:
    assign
      rsrv-free = ?
    .
    next .
  end.

  find ub.trn-doc no-lock
    where ub.trn-doc.doc-code = ub.parts.in-code
    no-error.
  if available trn-doc then do: /* Инициализация внешнего прихода */
    assign
      ub.parts.doc-type  = ub.trn-doc.doc-type
      ub.parts.host-code = ub.trn-doc.host-code
      ub.parts.exch-code = ub.trn-doc.exch-code
      ub.parts.pay-code  = ub.trn-doc.pay-code
      ub.parts.supp-code = ub.trn-doc.cli-code
      ub.parts.supp-type = ub.trn-doc.cli-type
      ub.parts.VAT-type  = ub.trn-doc.VAT-type
      ub.parts.SLT-type  = ub.trn-doc.SLT-type
      ub.parts.fact-num  = ub.trn-doc.fact-num
      ub.parts.fact-date = ub.trn-doc.fact-date
      ub.parts.is-supp   = (ub.trn-doc.doc-type = {&income}
                            and not ub.trn-doc.internal
                           )
    .

    find ub.doc-line no-lock
      where ub.doc-line.doc-code  = ub.parts.in-code
        and ub.doc-line.artic     = ub.parts.artic
        and ub.doc-line.prod-type = ub.parts.prod-type
        and ub.doc-line.prod-code = ub.parts.prod-code
      no-error.
    if available doc-line then do:
      assign
        ub.parts.VAT-pc        = ub.doc-line.VAT-pc
        ub.parts.SLT-pc        = ub.doc-line.SLT-pc
        ub.parts.cli-base-rate = ub.doc-line.cli-base-rate
        ub.parts.price-base    = ub.doc-line.price-base
        ub.parts.price-rubl    = ub.doc-line.price-rubl
        ub.parts.price-cli     = ub.doc-line.price-cli
      .
    end.
    else do:
      assign
        ub.parts.VAT-pc = 20
        ub.parts.SLT-pc = 0
        ub.parts.cli-base-rate = 1
      .
    end.
    if ub.parts.cli-base-rate <> 0 then do:
      assign
        ub.parts.cli-qnty  = ub.parts.qnty / ub.parts.cli-base-rate
      .
    end.
    if ub.trn-doc.exch-rate <> 0 then do:
      assign
        ub.parts.price-cli  = ub.parts.price-rubl
                            * ( ub.trn-doc.exch-scale / ub.trn-doc.exch-rate )
                            * ub.parts.cli-base-rate
      .
    end.
    else do:
      assign
        ub.parts.price-cli  = 0
      .
    end.
  end.
  else do:
    output to ini-part.txt append .
    export 'trn-doc: bad in-code ' parts.in-code recid(parts).
    output close .
  end.

  case parts.out-code:
    when {&free-code} or
    when {&output-code} then do:
      assign
        parts.status_   = no
        parts.rsrv-free = { trg/partsprm.i "rsrv-free" "ub.parts.out-code" }
      .
    end.
    otherwise do:
      find trn-doc no-lock
        where trn-doc.doc-code = parts.out-code
        no-error.
      if available trn-doc then do:
        assign
          parts.doc-type = trn-doc.doc-type
        .
        if trn-doc.status_ = {&fact} then do:
          assign
            parts.fact-num  = trn-doc.fact-num
            parts.fact-date = trn-doc.fact-date
            parts.rsrv-free = ?
            parts.status_   = yes
          .
        end.
        else do:
          if trn-doc.internal then do:
            /* ??? здесь у нас проблема */
            /* для внутренних расходов мы должны ставить rsrv-free = yes */
            /* но только в базе данных, где было произведено резервирование */
            /*
            assign
              parts.rsrv-free = ?
            .
            */
          end.
          else do:
            assign
              parts.rsrv-free = { trg/partsprm.i "part-rsrv-free" "ub.trn-doc." "ub.parts.fact-qnty" }
            .
          end.
        end.
      end.
      else do:
        output to ini-part.txt append .
        export 'trn-doc: bad out-code' parts.out-code recid(parts).
        output close .
        assign
          parts.rsrv-free = ?
          parts.status_   = yes
        .
      end.
    end.
  end case.

end procedure. /* process-part */