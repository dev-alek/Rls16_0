block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fobdocop.p $
$Archive: bge/fobdocop.p $

Экспорт ПФО

Автор: Хныкин Павел Андреевич
Дата создания: 03/03/06
Author: Pavel Khnykin
Creation date: 03/03/06

Дата создания: 11/30/04


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
def var vss-workfile    as character no-undo init "$Workfile: fobdocop.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/fobdocop.p $":U .
def var vss-description as character no-undo init "Экспорт финансовых обязательств".
{ cmp/vssrevis.i }

{ cmp/trg-def.i  }
{ bge/bgelib.i   }
{ str/lib-trn.i  }
/* { str/trdcalib.i } */
/* { str/in-vatp.i def } */
{ trg/factord.i  }

do
on error undo, return error
:

  define variable v-exists-operation          as logical       no-undo.
  define variable v-doc-date        like ub.trn-doc.doc-date   no-undo.
  define variable v-fact-date       like ub.trn-doc.fact-date  no-undo.
  define variable v-doc-PS          like ub.trn-doc.PS         no-undo.
  define variable v-host-code                 as integer       no-undo.
  define variable v-base-code                 as integer       no-undo.
  define variable v-base-abbr       like ub.currency.curr-abbr no-undo.
  define variable v-base-name       like ub.currency.curr-name no-undo.

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

  { bge/xmlfo1.i def }
  assign
      p-last-xml-file-name    = p-xml-file-name
      p-last-xml-file-number  = p-xml-file-number
  .
  define variable v-date-1 as date   no-undo .
  define variable v-date-2 as date   no-undo .
  if p-fact-order-from = 0 then do:
    v-date-1 = 01/01/1990.
  end.
  else do:
  run factord-to-date ( input p-fact-order-from, output v-date-1) .
  end.
  if p-fact-order-to = 0 then do:
    v-date-2 = 01/01/1990.
  end.
  else do:
  run factord-to-date ( input p-fact-order-to, output v-date-2) .
  end.

  output stream stmxmlout to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.
  export-documents:
  for each buf_fin-ob-before no-lock where
          buf_fin-ob-before.host-code = p-host-code
      AND buf_fin-ob-before.doc-date  >= v-date-1
      AND buf_fin-ob-before.doc-date  <= v-date-2
  on error undo, return error
  :
    if v-need-new-file = yes
    then do:
        output stream stmxmlout close.
        assign
            v-prev-filename = p-xml-file-name
        .
        run bgelib-filename in this-procedure (
              input "fin-ob-before"
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
        v-doc-code = string(buf_fin-ob-before.before-code)
    .
    if not v-exists-operation
    then do:
        run bgelib-write-edt in this-procedure ( hEDT, 4, "Операция " + string( p-oper-name ) ).
        run bgelib-write-log in this-procedure ( p-log-file-name, 0, "&Line" ).
        run bgelib-write-log in this-procedure ( p-log-file-name, 1, "XML - Вывод операции " + string( p-oper-name )  ).
        assign
            v-exists-operation = yes
        .
    end.
    assign
    v-doc-code  = buf_fin-ob-before.before-code
    v-doc-date  = buf_fin-ob-before.doc-date
    v-fact-date = buf_fin-ob-before.fact-date

    v-doc-PS    = buf_fin-ob-before.ps
    .
    run bgelib-write-cnt ( hcnt, "   " + string( v-doc-code ) + " от " + string( v-doc-date ) ) .
    process events.

    { bge/xmlfo1.i run LIST }


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