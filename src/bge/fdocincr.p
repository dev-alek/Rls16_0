block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fdocincr.p $
$Archive: bge/fdocincr.p $

Экспорт платежей

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/09/04
Author: Bakhtadze Natalya
Creation date: 12/09/04

Параметры:
    sOutFile            - имя файла .xm1 для вывода (вызывающая программа создает и по завершении
                            экспорта переименовывает этот файл в .xml. Сделано для синхронизации с
                            блоком импорта во внешней бухгалтерии.
    sLogFile            - полное имя файла для записи событий.
    hEDT                - handle поля лога (EDITOR) окна вывода
    hCNT                - handle поля счётчика (FILL-IN) окна вывода
*/

define input parameter p-range           as integer                 no-undo.
define input parameter p-db-num          as integer                 no-undo.
define input parameter p-obj-list        as character               no-undo.
define input parameter p-host-code       as integer                 no-undo.
define input parameter p-cur-date        as date                    no-undo.
define input parameter p-start-date      as date                    no-undo.
define input parameter sOutFile          as character               no-undo.
define input parameter sLogFile          as character               no-undo.
define input parameter p-parent-proc     as handle                  no-undo.
define input parameter hEDT              as handle                  no-undo.
define input parameter hCNT              as handle                  no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fdocincr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/fdocincr.p $":U .
define variable vss-description as character no-undo init "Экспорт платежей".
{ cmp/vssrevis.i }

{ cmp/trg-def.i         }
{ bge/bge-xml.i         }
{ str/lib-trn.i         }
{ gbl/temphost.i
  &share-options="shared"
}

do
on error undo, return error
:
define variable v-base-code                 as integer       no-undo.
define variable v-base-abbr       like ub.currency.curr-abbr no-undo .
define variable v-base-name       like ub.currency.curr-name no-undo .

define buffer buf_currency for ub.currency.
define buffer buf_sysconf for ub.sysconf.
find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-code .

if not valid-handle( p-parent-proc )
then do:
    return.
end.
{ gbl/basecode.i p-host-code v-base-code }
find first buf_currency no-lock where
          buf_currency.curr-code = v-base-code no-error .
if available buf_currency then
assign
v-base-abbr = buf_currency.curr-abbr
v-base-name = buf_currency.curr-name
.



OUTPUT STREAM stmXMLOut TO VALUE( sOutFile + "xm1" ) CONVERT TARGET "1251" APPEND.

RUN wp-XMLWriteCNT( hCNT, "" ).

run export-documents in this-procedure .

output stream stmxmlout close.

end.

/*==========================================================================*/
procedure export-documents :
do
on error undo, return error
:
  define variable v-ext-fin-doc-type  as character    no-undo.
  define variable v-fin-doc-code      as integer      no-undo.
  define variable v-doc-date          as date         no-undo.
  define variable v-fact-date         as date         no-undo.
  define variable v-doc-PS            as character    no-undo.
  define variable v-bge-date          as date         no-undo.
  define variable v-bge-date-str      as character    no-undo.


  define buffer buf_fin-doc            for ub.fin-doc.
  define buffer buf_c-fin-doc          for ub.c-fin-doc.

  export-findocuments:
  for each buf_fin-doc no-lock
      where buf_fin-doc.host-code = p-host-code
        and buf_fin-doc.status_  = {&fin-fact}
        and buf_fin-doc.fact-date >= p-start-date
        and buf_fin-doc.bge-date = ?
  on error undo, return error
  :
    /*получим bge-date*/
    /*
    if  buf_fin-doc.bge-date <> ? then NEXT export-findocuments.
    */

    if buf_fin-doc.obj-type = "":U and buf_fin-doc.obj-code = 0
    then do:
      if buf_sysconf.firm-db-num <> p-db-num then next export-findocuments.
    end.
    if buf_fin-doc.obj-type = "":U and buf_fin-doc.obj-code = 0
    and not (p-range = 1 or p-range = 2) then next export-findocuments.
    if buf_fin-doc.obj-code <> 0
    and p-range = 3
    and not can-find(first temp-obj no-lock where
                           temp-obj.obj-type = buf_fin-doc.obj-type
                       and temp-obj.obj-code = buf_fin-doc.obj-code) then  next export-findocuments.
      assign
      v-ext-fin-doc-type = buf_fin-doc.fin-ext-doc-type
      v-fin-doc-code     = buf_fin-doc.fin-doc-code
      v-doc-date     = buf_fin-doc.doc-date
      v-fact-date    = buf_fin-doc.fact-date
      v-doc-ps       = buf_fin-doc.ps
      .
      run export-fin-doc (
            input v-ext-fin-doc-type
          , input p-host-code
          , input v-fin-doc-code
          , input v-doc-date
          , input v-fact-date
          , input v-doc-ps
        ) no-error.
      if error-status :error then do:
        run wp-XMLWriteLog in this-procedure (
              input sLogFile
            , input 1
            , input substitute( "Ошибка экспорта финансового документа. Номер документа: &1. &2. &3 &4 "
                                , v-fin-doc-code
                                , return-value
                                , trim(error-status :get-message(1))
                                , trim(error-status :get-message(2))
                              )
        ).
        undo export-findocuments, next export-findocuments.
      end.
      /* Пометить выгруженные - прописать поле bge-date fin-doc */
      run run-callback-write-doc-code in this-procedure (
            input p-parent-proc
          , input "fin-doc":U
          , input buf_fin-doc.host-code
          , input buf_fin-doc.fin-doc-code
          , input 0 /*corr-user-db-num*/
          , input 0 /*chip-num*/
          , input slogfile
      ).
    end.        /* for each buf_fin-doc */
    export-deleted-documents:
    for each buf_c-fin-doc no-lock
       where buf_c-fin-doc.host-code = p-host-code
         AND buf_c-fin-doc.is-del    = yes
    on error undo, return error
    :
      if buf_c-fin-doc.status_ <> {&fin-fact} then NEXT export-deleted-documents.
      if buf_c-fin-doc.bge-date  <> ? then  NEXT export-deleted-documents.

      assign
      v-fin-doc-code     = buf_c-fin-doc.fin-doc-code
      .
      run export-deleted-docs in this-procedure (
           input p-host-code
         , input v-fin-doc-code
         ,input buf_c-fin-doc.corr-user-db-num
         ,input buf_c-fin-doc.chip-num
      ) no-error.
      if error-status:error then do:
        run wp-XMLWriteLog in this-procedure (
              input sLogFile
            , input 1
            , input substitute( "Ошибка экспорта удаленного документа. Номер документа: &1. &2. &3 &4 "
                                , v-fin-doc-code
                                , return-value
                                , trim(error-status :get-message(1))
                                , trim(error-status :get-message(2))
                            )
        ).
        undo export-deleted-documents, next export-deleted-documents.
      end.
      /* Пометить выгруженные - прописать поле c-fin-doc.bge-date */
      run run-callback-write-doc-code in this-procedure (
            input p-parent-proc
          , input "c-fin-doc":U
          , input buf_c-fin-doc.host-code
          , input buf_c-fin-doc.fin-doc-code
          , input buf_c-fin-doc.corr-user-db-num
          , input buf_c-fin-doc.chip-num
          , input slogfile
      ).
  end.        /* for each buf_c-fin-doc */
end.
end procedure. /* export-documents */


/*==========================================================================*/
procedure export-fin-doc :
define input parameter p-ext-doc-type           as character    no-undo.
define input parameter p-host-code              as integer      no-undo .
define input parameter p-fin-doc-code           as integer      no-undo.
define input parameter p-doc-date               as date         no-undo.
define input parameter p-fact-date              as date         no-undo.
define input parameter p-doc-PS                 as character    no-undo.

{ str/xmlfdoc0.i def }

define variable v-exists-before     as logical      no-undo.
define variable v-exists-after      as logical      no-undo.
define variable v-doc-date          as date         no-undo.
define variable v-today             as date         no-undo.
define variable v-time              as integer      no-undo.

do
on error undo, return error
:

 find first buf_fin-doc no-lock where
           buf_fin-doc.host-code = p-host-code
       AND buf_fin-doc.fin-doc-code = p-fin-doc-code no-error .
  if not available buf_fin-doc then do:

  end.
  assign
  v-doc-date  = buf_fin-doc.doc-date
  .
  run wp-XMLWriteCnt( hcnt, "   " + string( p-fin-doc-code ) + " от " + string( p-fact-date ) ) .
  process events.
  run wp-xmltagopen( 2, "operation","" ).
  run wp-xmltagput( 3, "referenceNo",        string( p-fin-doc-code                       ), 0 ).
  run wp-xmltagput( 3, "codeOperation",      string( p-ext-doc-type                       ), 0 ).
  run wp-xmltagput( 3, "host",               string( p-host-code                          ), 0 ).
  run wp-xmltagput( 3, "dateDoc",            string( v-doc-date,"99.99.9999"              ), 0 ).
  run wp-xmltagput( 3, "dateFact",           string( p-fact-date,"99.99.9999"             ), 0 ).
  run wp-xmltagput( 3, "valutCode",          string( v-base-code                          ), 0 ).

  { str/xmlfdoc0.i run LIST bge-xml }

  run wp-xmltagput( 3, "comment",  p-doc-PS, 0 ).
  run wp-xmltagclose( 2, "operation" ).
end.
end procedure. /* export-fin-doc */


/*==========================================================================*/
procedure run-callback-write-doc-code :
do
on error undo, return error
:
define input parameter p-handle           as handle       no-undo.
define input parameter p-type             as character    no-undo.
define input parameter p-host-code        as integer      no-undo.
define input parameter p-fin-doc-code     as integer      no-undo.
define input parameter p-corr-user-db-num as integer      no-undo.
define input parameter p-chip-num         as integer      no-undo.
define input parameter p-log-file         as character    no-undo.

define variable v-procedure-name    as char no-undo.

case p-type
:
  when "fin-doc":U then do:
    assign
    v-procedure-name = "fill-temp-fin-doc-code":U
    .
  end.        /* when "fin-doc":U */
  when "c-fin-doc":U then do:
    assign
    v-procedure-name = "fill-temp-del-fin-doc-code":U
    .
  end.        /* when "c-fin-doc":U */
end case.       /* case p-type */

if lookup( v-procedure-name, p-handle :internal-entries ) > 0
then do:
    run value( v-procedure-name ) in p-handle (
                                                input p-host-code
                                               ,input p-fin-doc-code
                                               ,input p-corr-user-db-num
                                               ,input p-chip-num
                                                  ) no-error.
    if error-status :error
    then do:
        run wp-XMLWriteLog in this-procedure (
              input p-log-file
            , input 1
            , input substitute( "Ошибка при вызове callback - процедуры &1.", v-procedure-name )
        ).
    end.
end.
else do:                           /* нет такой процедуры */
    run wp-XMLWriteLog in this-procedure (
          input p-log-file
        , input 1
        , input substitute( "Не найдена callback - процедура &1.", v-procedure-name )
    ).
end.

end.
end procedure. /* run-callback-write-doc-code */


/*==========================================================================*/
procedure export-deleted-docs :
define input parameter p-host-code      as integer no-undo .
define input parameter p-fin-doc-code   as integer no-undo.
define input parameter p-corr-user-db-num as integer no-undo .
define input parameter p-chip-num         as integer no-undo .
define buffer buf_c-fin-doc     for ub.c-fin-doc.
do
for
buf_c-fin-doc
on error undo, return error
:
    find first buf_c-fin-doc no-lock
         where buf_c-fin-doc.fin-doc-code = p-fin-doc-code
          AND  buf_c-fin-doc.host-code = p-host-code
          AND buf_c-fin-doc.corr-user-db-num = p-corr-user-db-num
          AND buf_c-fin-doc.chip-num = p-chip-num
    .
    run wp-XMLWriteCnt( input hcnt, input substitute( "Удаленный: &1 от &2", p-fin-doc-code, buf_c-fin-doc.fact-date ) ).
    process events.
    run wp-xmltagopen( input 2, input "operation", input "" ).
    run wp-xmltagput( input 3, input "referenceNo"  , input buf_c-fin-doc.fin-doc-code                               , input 0 ).
    run wp-xmltagput( input 3, input "isDel"        , input "yes"                                                    , input 0 ).
    run wp-xmltagput( input 3, input "flagDel"      , input buf_c-fin-doc.is-del                                     , input 0 ).
    run wp-xmltagput( input 3, input "codeOperation", input string( buf_c-fin-doc.fin-ext-doc-type                  ), input 0 ).
    run wp-xmltagput( input 3, input "host"         , input string( buf_c-fin-doc.host-code                         ), input 0 ).
    run wp-xmltagput( input 3, input "dateDel"      , input string( buf_c-fin-doc.corr-date ,"99.99.9999"           ), input 0 ).
    run wp-xmltagput( input 3, input "dateDoc"      , input string( buf_c-fin-doc.doc-date  ,"99.99.9999"           ), input 0 ).
    run wp-xmltagput( input 3, input "dateFact"     , input string( buf_c-fin-doc.fact-date ,"99.99.9999"           ), input 0 ).
    run wp-xmltagput( input 3, input "comment"      , input buf_c-fin-doc.PS                                         , input 0).
    run wp-xmltagclose( input 2, input "operation" ).
end.
end procedure. /* export-deleted-docs */