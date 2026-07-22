block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: chk-cont.p $
$Archive: utl/chk-cont.p $

утилита  проверка привязки партий и складских документов к договору поставщика

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/
define input parameter parParentProc as handle           no-undo.


/* ***************************  Definitions  ************************** */
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: chk-cont.p $":u .
define variable vss-archive     as character no-undo init "$Archive: utl/chk-cont.p $":u .
define variable vss-description as character no-undo init "утилита проверка привязки партий и складских документов к договору поставщика " .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ str/libtfarh.i }

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get  }

define variable g#host-code as integer   no-undo .
define variable g#host-name as character no-undo .

  os-delete 'chk-cont.log' .
  { str/writelog.i def "'chk-cont.log'"  }

  define variable Counter1 as integer   no-undo .
  define variable doc-list as character no-undo .
  define variable s-list as character no-undo .
  define variable ii as integer   no-undo .

  define buffer buf_clients for clients .
  define buffer buf_trn-doc for trn-doc .
  define buffer buf_parts for parts.
  define buffer buf_parts-attr for parts-attr.

  run ref/cli-all.w ( parParentProc, "b-sel,b-mark", {&cmp}, {&all}, {&current}, ?, "yes,yes,yes,,,,ИЛИ,,":u, "without-obj":U, output doc-list ) .
  if doc-list <> "" then do:
    assign  Counter1 = 0 .
    { gbl/working.i }
    { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
    { rep/repfrm.i on 100 } /* Показать окно информации о текущем процессе */
    do ii = 1 to num-entries(doc-list):
      find first buf_clients no-lock where RECID(buf_clients) = integer(entry(ii, doc-list)) no-error.
      assign s-list = "Поставщик " + buf_clients.obj-name .
      run writelog ( "chk-cont.log", 0, s-list) .
      for each buf_trn-doc  no-lock
        where buf_trn-doc.host-code = g#host-code
          and buf_trn-doc.cli-type  = buf_clients.obj-type
          and buf_trn-doc.cli-code  = buf_clients.obj-code
          and buf_trn-doc.ext-doc-type  = {&TDEDT_Pri_Vnesh}
        :
        assign s-list = "Проверка накладной № " + buf_trn-doc.doc-code + " вн.н. договора " + string(buf_trn-doc.contract-code) .
        run writelog ( "chk-cont.log", 0, s-list) .

        for each buf_parts-attr no-lock where buf_parts-attr.in-code = buf_trn-doc.doc-code :
          assign Counter1 = Counter1 + 1.
          { rep/repfrm.i disp Counter1 }
          if buf_parts-attr.contract-code <> buf_trn-doc.contract-code then do:
            assign
              s-list = "Не совпал вн.н. договора в parts-attr (" + string(buf_parts-attr.contract-code) +
                ")   parts-attr.gds-code=" + string(buf_parts-attr.gds-code)
                + "  parts-attr.part-code=" + string(buf_parts-attr.part-code)
            .
            run writelog ( "chk-cont.log", 0, s-list) .
          end.
        end.
        for each buf_parts no-lock where buf_parts.out-code = buf_trn-doc.doc-code :
          assign Counter1 = Counter1 + 1.
          { rep/repfrm.i disp Counter1 }
          if buf_parts.contract-code <> buf_trn-doc.contract-code then do:
            assign
              s-list = "Не совпал вн.н. договора в parts (" + string(buf_parts.contract-code) +
                ")   parts.obj-type=" + buf_parts.obj-type
                + "  parts.obj-code=" + string(buf_parts.obj-code)
                + "  parts.artic=" + buf_parts.artic
                + "  parts.prod-type=" + buf_parts.prod-type
                + "  parts.prod-code=" + string(buf_parts.prod-code)
                + "  parts.in-code=" + buf_parts.in-code
                + "  parts.out-code=" + buf_parts.out-code
                + "  parts.part-code=" + buf_parts.part-code
            .
            run writelog ( "chk-cont.log", 0, s-list) .
          end.
          for each gds-obj no-lock
            where gds-obj.artic     =  buf_parts.artic
              and gds-obj.prod-type =  buf_parts.prod-type
              and gds-obj.prod-code =  buf_parts.prod-code
           , each parts no-lock
            where parts.obj-type  =  gds-obj.obj-type
              and parts.obj-code  =  gds-obj.obj-code
              and parts.artic     =  buf_parts.artic
              and parts.prod-type =  buf_parts.prod-type
              and parts.prod-code =  buf_parts.prod-code
              and parts.in-code   =  buf_parts.in-code
              and parts.part-code =  buf_parts.part-code
            :
            assign Counter1 = Counter1 + 1.
            { rep/repfrm.i disp Counter1 }
            if parts.contract-code <> buf_trn-doc.contract-code then do:
              assign
                s-list = "Не совпал вн.н. договора в parts (" + string(parts.contract-code) +
                  ")   parts.obj-type=" + parts.obj-type
                  + "  parts.obj-code=" + string(parts.obj-code)
                  + "  parts.artic=" + parts.artic
                  + "  parts.prod-type=" + parts.prod-type
                  + "  parts.prod-code=" + string(parts.prod-code)
                  + "  parts.in-code=" + parts.in-code
                  + "  parts.out-code=" + parts.out-code
                  + "  parts.part-code=" + parts.part-code
              .
              run writelog ( "chk-cont.log", 0, s-list) .
            end.
          end.
        end.
      end.

      { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
      { gbl/stopwork.i }
    end.
  end.

  define variable g#log as logical   no-undo .
  run gbl/prnfilen.w ( input  "Результат работы утилиты", input  0, input  'chk-cont.log', input 7, output s-list, output g#log ).