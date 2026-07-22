block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fodocop.p $
$Archive: bge/fodocop.p $

Экспорт финансовых обязательств

Автор: Хныкин Павел Андреевич
Дата создания: 03/03/06
Author: Pavel Khnykin
Creation date: 03/03/06

Дата создания: 11/30/04

*/

/*
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
define input parameter p-fact-order-from        like ub.stk-tot.fact-order no-undo.
define input parameter p-fact-order-to          like ub.stk-tot.fact-order no-undo.
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

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: fodocop.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: bge/fodocop.p $":U .
define variable vss-description as character no-undo initial "Экспорт финансовых обязательств":U .

{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ bge/bgelib.i   }
{ str/lib-trn.i  }
{ str/trdcalib.i }
{ str/in-vatp.i def }

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
  define variable v-firm-only as logical   no-undo .

  define buffer buf_sysconf for ub.sysconf.

  find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-code no-error .
  if buf_sysconf.fin-calc = 0 then v-firm-only = true.
  else v-firm-only = false .

  define variable v-i as integer   no-undo .
  define variable v-obj-list as character no-undo .

  if v-firm-only = false  then do:
  repeat v-i = 1 to num-entries ( p-obj-list )  by 2 :
   v-obj-list = v-obj-list +  entry (v-i,p-obj-list ) + entry (v-i + 1 , p-obj-list ) + "," .
  end.

  end.


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

  { bge/xmlfo0.i def }
  assign
      p-last-xml-file-name    = p-xml-file-name
      p-last-xml-file-number  = p-xml-file-number
  .

  output stream stmxmlout to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.
  export-documents:
  for each buf_fin-ob no-lock where
          buf_fin-ob.host-code = p-host-code
      AND buf_fin-ob.fact-order >= p-fact-order-from
      AND buf_fin-ob.fact-order <= p-fact-order-to
      AND buf_fin-ob.status_ = {&fact}
  on error undo, return error
  :

    if not v-firm-only then do:
        if lookup (buf_fin-ob.obj-type + string(buf_fin-ob.obj-code) , v-obj-list) = 0 then next.
    end.

    if v-need-new-file = yes
    then do:
        output stream stmxmlout close.
        assign
            v-prev-filename = p-xml-file-name
        .
        run bgelib-filename in this-procedure (
              input "fin-ob"
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
        v-doc-code = buf_fin-ob.doc-code
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
    v-doc-code  = buf_fin-ob.doc-code
    v-doc-date  = buf_fin-ob.doc-date
    v-fact-date = buf_fin-ob.fact-date

    v-doc-PS    = buf_fin-ob.ps
    .
    run bgelib-write-cnt ( hcnt, "   " + string( v-doc-code ) + " от " + string( v-fact-date ) ) .
    process events.

    { bge/xmlfo0.i run LIST }


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