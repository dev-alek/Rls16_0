block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: ini-pfdt.p $
$Archive: utl/ini-pfdt.p $

Определение parts.fact-date parts.fact-num для правильного расходования партий по FIFO/LIFO

Автор: Чернова Светлана Александровна
Дата создания: 02/27/07
Author: Svetlana Chernova
Creation date: 02/27/07

create: Перваков Михаил Сергеевич
Дата создания: 04/12/06

TODO - запрашивать какую дату надо проставлять в партии, для которых
  отсутствуют приходные накладные

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ini-pfdt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/ini-pfdt.p $":U .
define variable vss-description as character no-undo init "Определение parts.fact-date parts.fact-num для правильного расходования партий по FIFO/LIFO".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/waitfram.i }

define variable lok as logical no-undo init false .

message
  "Вы действительно хотите обновить дату создания партий " skip
  "свободных и расходных зон на основе даты закрытия документа?"
  view-as alert-box question
  button yes-no update lOK.

if not lOK then do:
  return .
end.

run check-fact-date-num (input true /* l-fix */ ).


procedure check-fact-date-num :

  define input parameter l-fix as logical no-undo .

  define variable icount as integer no-undo .

  run waitfram-show in this-procedure
    (INPUT 'Отбор партий свободной и расходной зон ...'
    ).

  for each parts no-lock
    where (parts.out-code = {&free-code}
           or parts.in-code = {&output-code}
          )
  :
    assign
      icount = icount + 1
    .
    run waitfram-show in this-procedure
      (INPUT 'Обработано партий ' + STRING(icount)
      ).
    process events .

    if parts.out-code = {&free-code}
    or parts.out-code = {&output-code} then do:
      find first trn-doc no-lock
        where trn-doc.doc-code = parts.in-code
        no-error .
      if not available trn-doc then do:
        output to ini-pfdt.err append .
        export "invalid trn-doc.in-code" parts.in-code recid(parts) .
        export parts .
        output close .
      end.
    end.
    else do:
      /* todo ??? - здесь неправильный алгоритм */
      /* всегда надо брать в качестве даты - дату закрытия приходного документа */
      find first trn-doc no-lock
        where trn-doc.doc-code = parts.out-code
        no-error .
      if not available trn-doc then do:
        output to ini-pfdt.err append .
        export "invalid parts.out-code" parts.out-code recid(parts) .
        export parts .
        output close .
      end.
    end.

    if available trn-doc
    and (parts.fact-date <> trn-doc.fact-date
        or parts.fact-num <> trn-doc.fact-num
        )
    then do:
      output to ini-pfdt.txt append .
      export "fix-parts,recid,olddate,oldfactnum,newdate,newfact-num"
        recid(parts) parts.fact-date parts.fact-num trn-doc.fact-date trn-doc.fact-num .
      export parts .
      output close .

      if l-fix then do:
        define buffer buf_parts for parts .

        find buf_parts exclusive-lock
          where recid(buf_parts) = recid(parts)
          .
        assign
          buf_parts.fact-date = trn-doc.fact-date
          buf_parts.fact-num  = trn-doc.fact-num
        .
      end.
    end.
  end.

  run waitfram-hide in this-procedure .

end procedure .