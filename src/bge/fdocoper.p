block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fdocoper.p $
$Archive: bge/fdocoper.p $

Экспорт финансовых документов

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/22/04
Author: Bakhtadze Natalya
Creation date: 04/22/04

Параметры:
    p-host-code         - код фирмы
    p-ext-doc-type      - расширенный тип документа
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

define input parameter p-host-code              as integer                 no-undo.
define input parameter p-ext-doc-type           as character               no-undo.
define input parameter p-oper-name              as character               no-undo.
define input parameter p-fact-order-from        like ub.stk-tot.fact-order    no-undo.
define input parameter p-fact-order-to          like ub.stk-tot.fact-order    no-undo.
define input parameter p-doc-type-list          as character               no-undo.
define input parameter p-obj-list               as character               no-undo.
define input parameter p-db-num                 as integer                 no-undo.
define input parameter p-range                  as integer                 no-undo.
define input parameter p-mode                   as character               no-undo.
define input parameter p-parameter-list         as character               no-undo.
define input parameter p-xml-file-name          as character               no-undo.
define input parameter p-log-file-name          as character               no-undo.
define input parameter p-list-file-name         as character               no-undo.
define input parameter p-xml-file-number        as integer                 no-undo.
define input parameter hEDT                     as handle                  no-undo.
define input parameter hCNT                     as handle                  no-undo.
define output parameter p-last-xml-file-name    as character               no-undo.
define output parameter p-last-xml-file-number  as integer                 no-undo.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: fdocoper.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/fdocoper.p $":U .
def var vss-description as character no-undo init "Экспорт финансовых документов".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i  }
{ cmp/library.i }
{ bge/bgelib.i   }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ str/in-vatp.i def }
{ gbl/temphost.i }

do
on error undo, return error
:

  define variable v-exists-operation          as logical      no-undo.
  define variable v-doc-date        like ub.trn-doc.doc-date   no-undo.
  define variable v-fact-date       like ub.trn-doc.fact-date  no-undo.
  define variable v-doc-PS          like ub.trn-doc.PS         no-undo.
  define variable v-host-code                 as integer       no-undo.
  define variable v-base-code                 as integer       no-undo.
  define variable v-base-abbr       like ub.currency.curr-abbr no-undo .
  define variable v-base-name       like ub.currency.curr-name no-undo .
  define variable v-obj-counter     as integer                 no-undo .

  define variable v-last-file-position        as integer       no-undo.
  define buffer buf_currency for ub.currency.

    ASSIGN
    v-exists-operation = NO.
    .
    { gbl/basecode.i p-host-code v-base-code }

    find first buf_currency no-lock where
              buf_currency.curr-code = v-base-code no-error .
    if available buf_currency then
    assign
    v-base-abbr = buf_currency.curr-abbr
    v-base-name = buf_currency.curr-name
    .


    RUN bgelib-write-cnt( hCNT, "" ).
    assign
        p-last-xml-file-name = p-xml-file-name
    .
    if p-obj-list <> "":U and p-mode <> "":U then do:
      do v-obj-counter = 1 to num-entries ( p-obj-list ) / 2
      :
          create temp-obj.
          assign
          temp-obj.obj-code = integer( entry( v-obj-counter * 2, p-obj-list ) )
          temp-obj.obj-type = entry( v-obj-counter * 2 - 1, p-obj-list )
          no-error .
      end.
    end.
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
  define buffer buf_sysconf for ub.sysconf.

  { str/xmlfdoc0.i def }
  assign
      p-last-xml-file-name    = p-xml-file-name
      p-last-xml-file-number  = p-xml-file-number
  .
  output stream stmxmlout to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.

  export-documents:
  for each buf_fin-doc no-lock where
          buf_fin-doc.host-code = p-host-code
      AND buf_fin-doc.fact-order >= p-fact-order-from
      AND buf_fin-doc.fact-order <= p-fact-order-to
      AND buf_fin-doc.status_ = {&fact}
  on error undo, return error
  :
    if buf_fin-doc.obj-type = "":U and buf_fin-doc.obj-code = 0
    and p-mode = "shd":U
    then do:
      find first buf_sysconf no-lock where buf_fin-doc.host-code = buf_sysconf.host-code .
      if buf_sysconf.firm-db-num <> p-db-num then next export-documents.
    end.
    if buf_fin-doc.fin-ext-doc-type <> p-ext-doc-type then next export-documents.
    if buf_fin-doc.obj-type = "":U and buf_fin-doc.obj-code = 0 and not (p-range = 1 or p-range = 2) then next export-documents.
    if buf_fin-doc.obj-code <> 0
    and trim(p-obj-list) <> "":U
    and p-mode <> "":U
    and not can-find(first temp-obj no-lock where
                           temp-obj.obj-type = buf_fin-doc.obj-type
                       and temp-obj.obj-code = buf_fin-doc.obj-code) then  next export-documents.
    if v-need-new-file = yes
    then do:
        output stream stmxmlout close.
        assign
            v-prev-filename = p-xml-file-name
        .
        run bgelib-filename in this-procedure (
              input "findoc"
            , output p-xml-file-name
            , output v-void-string
            , output v-void-string
        ).
        run bgelib-write-footer in this-procedure (
              input no
            , input v-prev-filename
            , input p-list-file-name
            , input yes
            , input p-xml-file-name + "xml":U
        ).
        run bgelib-write-log in this-procedure (
            input p-log-file-name
            , input 1
            , input substitute( "Данные выгружены в файл &1"
                                    , replace( p-xml-file-name, "/", "\" ) + "xml"
                            )
        ).
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
        assign
            v-need-new-file = no
        .
    end.        /* if v-need-new-file = yes */
    assign
        v-doc-code = string(buf_fin-doc.fin-doc-code)
    .
    if not v-exists-operation
    then do:
        run bgelib-write-edt in this-procedure ( hEDT, 4, "Операция " + string( p-oper-name ) ).
        run bgelib-write-log in this-procedure ( p-log-file-name, 0, "&Line" ).
        run bgelib-write-log in this-procedure ( p-log-file-name, 1, "XML - Вывод операции " + string( p-oper-name ) + " (" + p-ext-doc-type + ")" ).
        assign
            v-exists-operation = yes
        .
    end.
    assign
    v-doc-code  = string(buf_fin-doc.fin-doc-code)
    v-doc-date  = buf_fin-doc.doc-date
    v-fact-date = buf_fin-doc.fact-date

    v-doc-PS    = buf_fin-doc.ps
    .
    run bgelib-write-cnt( hcnt, "   " + string( v-doc-code ) + " от " + string( v-fact-date ) ) .
    process events.

    { str/xmlfdoc0.i run LIST }


    if v-last-file-position = 0
    or seek( stmxmlout ) - v-last-file-position > {&bgelib-check-freespace-size}
    then do:
      run gbl/chkfree.p (
          input substring( p-xml-file-name, 1, 1 )
          , input {&bgelib_minimum-free-mbytes}
          , output v-need-disk-spc
      ) .
      if v-need-disk-spc = yes
      then do:
          run gbl/waitfrsp.w (
              input substring( p-xml-file-name, 1, 1 )
              , input {&bgelib_minimum-free-mbytes}
              , output v-cancel
          ) .
          if v-cancel = yes
          then do:
              undo, return error.
          end.
      end.
      assign
          v-last-file-position = seek( stmxmlout )
      .
    end.
    run bgelib-check-file-size in this-procedure (
          input p-xml-file-name + {&bgelib-temp-extension}
        , output v-need-new-file
    ).
  end.        /* for each buf_ot-tot-crsa-loop */
  output stream stmxmlout close.
end.
end procedure. /* export-documents */
