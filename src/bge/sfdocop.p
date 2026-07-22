block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sfdocop.p $
$Archive: bge/sfdocop.p $

Экспорт счетов-фактур

Автор: Хныкин Павел Андреевич
Дата создания: 10/09/07
Author: Pavel Khnykin
Creation date: 10/09/07

Параметры:
    p-host-code         - код фирмы
    p-oper-name         - номер операции (неверный номер - запись в лог)
    p-fact-order-from   - начальный fact-order
    p-fact-order-to     - конечный fact-order
    p-xml-file-name            - имя файла .tmp для вывода (вызывающая программа создает и по завершении
                            экспорта переименовывает этот файл в .xml. Сделано для синхронизации с
                            блоком импорта во внешней бухгалтерии.
    p-log-file-name            - полное имя файла для записи событий.
    hEDT                - handle поля лога (EDITOR) окна вывода
    hCNT                - handle поля счётчика (FILL-IN) окна вывода
*/

DEFINE INPUT  PARAMETER parparentproc        AS WIDGET-HANDLE        NO-UNDO.
define input parameter p-host-code              as integer                 no-undo.
define input parameter p-oper-name              as character               no-undo.
define input parameter p-fact-order-from        like ub.stk-tot.fact-order    no-undo.
define input parameter p-fact-order-to          like ub.stk-tot.fact-order    no-undo.
define input parameter p-obj-list               as character               no-undo.
define input parameter p-parameter-list         as character               no-undo.
define input parameter p-xml-file-name          as character               no-undo.
define input parameter p-log-file-name          as character               no-undo.
define input parameter p-list-file-name         as character               no-undo.
define input parameter p-xml-file-number        as integer                 no-undo.
define input parameter hEDT                     as handle                  no-undo.
define input parameter hCNT                     as handle                  no-undo.
define output parameter p-last-xml-file-name    as character               no-undo.
define output parameter p-last-xml-file-number  as integer                 no-undo.

define variable p-doc-type-list as character no-undo  init "" .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: sfdocop.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/sfdocop.p $":U .
def var vss-description as character no-undo init "Экспорт счетов-фактур".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ bge/bgelib.i   }

do
on error undo, return error
:

  define variable g#db-num as integer   no-undo .
  run get-db-num  in parParentProc ( output g#db-num ).

  define variable v-exists-operation          as logical      no-undo.
  define variable p-doc-code        like ub.trn-doc.doc-code   no-undo.
  define variable v-doc-date        like ub.trn-doc.doc-date   no-undo.
  define variable v-fact-date       like ub.trn-doc.fact-date  no-undo.

  define variable v-last-file-position        as integer       no-undo.
  define variable v-i as integer   no-undo .
  define variable v-obj-list as character no-undo .

    ASSIGN  v-exists-operation = NO.

    RUN bgelib-write-cnt( hCNT, "" ).
    assign p-last-xml-file-name = p-xml-file-name  .
    run export-documents in this-procedure (
          input p-obj-list
        , input p-doc-type-list
        , input p-parameter-list
        , input p-xml-file-name
        , input p-log-file-name
        , input p-list-file-name
        , input p-xml-file-number
        , output p-last-xml-file-name
        , output p-last-xml-file-number
    ).
end.

/*==========================================================================*/
procedure export-documents :
do
on error undo, return error
:
  define input parameter p-obj-list               as character    no-undo.
  define input parameter p-doc-type-list          as character    no-undo.
  define input parameter p-parameter-list         as character    no-undo.
  define input parameter p-xml-file-name          as character    no-undo.
  define input parameter p-log-file-name          as character    no-undo.
  define input parameter p-list-file-name         as character    no-undo.
  define input parameter p-xml-file-number        as integer      no-undo.
  define output parameter p-last-xml-file-name    as character    no-undo.
  define output parameter p-last-xml-file-number  as integer      no-undo.

  define variable v-exists-before as logical      no-undo.
  define variable v-exists-after  as logical      no-undo.

  define variable v-need-new-file  as logical     no-undo.
  define variable v-need-disk-spc  as logical     no-undo.
  define variable v-cancel         as logical     no-undo.
  define variable v-prev-filename  as character   no-undo.
  define variable v-void-string    as character   no-undo.

  { str/xml-s-f0.i def }
  assign
    p-last-xml-file-name    = p-xml-file-name
    p-last-xml-file-number  = p-xml-file-number
  .

  output stream stmxmlout to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.
export-documents:
  for each buf_schet-fact-doc no-lock
    where buf_schet-fact-doc.host-code = p-host-code
      AND buf_schet-fact-doc.fact-order >= p-fact-order-from
      AND buf_schet-fact-doc.fact-order <= p-fact-order-to
      AND buf_schet-fact-doc.status_ = {&fact}
  on error undo, return error
  :
    if v-need-new-file = yes then do:
      output stream stmxmlout close.
      assign v-prev-filename = p-xml-file-name .
      run bgelib-filename in this-procedure ( input "s-f", output p-xml-file-name, output v-void-string, output v-void-string ).
      run bgelib-write-footer in this-procedure ( input no, input v-prev-filename, input p-list-file-name, input yes, input p-xml-file-name + "xml":U ).
      run bgelib-write-log in this-procedure ( input p-log-file-name, input 1
            , input substitute( "Данные выгружены в файл &1", replace( p-xml-file-name, "/", "\" ) + "xml" ) ).
      assign
        p-last-xml-file-number   = p-xml-file-number + 1
        p-last-xml-file-name     = p-xml-file-name
      .
      run bgelib-write-header in this-procedure (
              input no
            , input p-last-xml-file-name
            , input p-list-file-name
            , input p-last-xml-file-number
            , input yes
            , input v-prev-filename + "xml":U
            , input p-obj-list
            , input p-doc-type-list
            , input p-parameter-list
        ).
      output stream stmxmlout to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.
      assign v-need-new-file = no .
    end.        /* if v-need-new-file = yes */

    assign p-doc-code = buf_schet-fact-doc.doc-code .
    if not v-exists-operation then do:
      run bgelib-write-edt in this-procedure ( hEDT, 4, "Операция " + string( p-oper-name ) ).
      run bgelib-write-log in this-procedure ( p-log-file-name, 0, "&Line" ).
      run bgelib-write-log in this-procedure ( p-log-file-name, 1, "XML - Вывод операции " + string( p-oper-name )  ).
      assign v-exists-operation = yes .
    end.
    assign
      p-doc-code  = buf_schet-fact-doc.doc-code
      v-doc-date  = buf_schet-fact-doc.doc-date
      v-fact-date = buf_schet-fact-doc.fact-date
    .
    run bgelib-write-cnt( hcnt, "   " + string( p-doc-code ) + " от " + string( v-fact-date ) ) .
    process events.

    { str/xml-s-f0.i run LIST }

    if v-last-file-position = 0 or seek( stmxmlout ) - v-last-file-position > {&bgelib-check-freespace-size} then do:
      run gbl/chkfree.p ( input substring( p-xml-file-name, 1, 1 ), input {&bgelib_minimum-free-mbytes}, output v-need-disk-spc ) .
      if v-need-disk-spc = yes then do:
        run gbl/waitfrsp.w ( input substring( p-xml-file-name, 1, 1 ), input {&bgelib_minimum-free-mbytes}, output v-cancel ) .
        if v-cancel = yes then undo, return error.
      end.
      assign v-last-file-position = seek( stmxmlout ) .
    end.
    run bgelib-check-file-size in this-procedure ( input p-xml-file-name + {&bgelib-temp-extension}, output v-need-new-file ).
  end.        /* for each buf_ot-tot-crsa-loop */
  output stream stmxmlout close.
end.
end procedure. /* export-documents */