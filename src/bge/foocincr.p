block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: foocincr.p $
$Archive: bge/foocincr.p $

Экспорт ФО

Автор: Хныкин Павел Андреевич
Дата создания: 03/03/06
Author: Pavel Khnykin
Creation date: 03/03/06

Дата создания: 12/14/04


Параметры:
    sOutFile            - имя файла .xm1 для вывода (вызывающая программа создает и по завершении
                            экспорта переименовывает этот файл в .xml. Сделано для синхронизации с
                            блоком импорта во внешней бухгалтерии.
    sLogFile            - полное имя файла для записи событий.
    hEDT                - handle поля лога (EDITOR) окна вывода
    hCNT                - handle поля счётчика (FILL-IN) окна вывода
*/

define input parameter p-host-code       as integer                 no-undo.
define input parameter p-cur-date        as date                    no-undo.
define input parameter p-start-date      as date                    no-undo.
define input parameter sOutFile          as character               no-undo.
define input parameter sLogFile          as character               no-undo.
define input parameter p-parent-proc     as handle                  no-undo.
define input parameter hEDT              as handle                  no-undo.
define input parameter hCNT              as handle                  no-undo.
/*message "bge/foocincr.p" skip
p-host-code
p-cur-date
p-start-date
sOutFile
sLogFile
.
 */

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: foocincr.p $":U .
def var vss-archive     as character no-undo init "$Archive: bge/foocincr.p $":U .
def var vss-description as character no-undo init "Экспорт ФО".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ bge/bge-xml.i  }
{ str/lib-trn.i  }
{ str/fo-attr.i  }

do
on error undo, return error
:
define variable v-base-code       as integer       no-undo.
define variable v-base-abbr       like ub.currency.curr-abbr no-undo .
define variable v-base-name       like ub.currency.curr-name no-undo .

define buffer buf_currency for ub.currency.

if not valid-handle ( p-parent-proc )
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



OUTPUT STREAM stmXMLOut TO VALUE ( sOutFile + "xm1" ) CONVERT TARGET "1251" APPEND.

RUN wp-XMLWriteCNT ( hCNT, "" ).

run export-documents in this-procedure .

output stream stmxmlout close.

end.

/*==========================================================================*/
procedure export-documents :
do
on error undo, return error
:
  define variable v-ext-fin-ob-type  as character    no-undo.
  define variable v-fin-doc-code      as character no-undo .
  define variable v-doc-date          as date         no-undo.
  define variable v-fact-date         as date         no-undo.
  define variable v-doc-PS            as character    no-undo.
  define variable v-bge-date          as date         no-undo.
  define variable v-bge-date-str      as character    no-undo.


  define buffer buf_fin-ob            for ub.fin-ob.
  define buffer buf_fin-ob-attr       for ub.fin-ob-attr.

  export-fin-obs:
  for each buf_fin-ob no-lock
      where buf_fin-ob.host-code = p-host-code
        and buf_fin-ob.status_  = {&fin-fact}
  on error undo, return error
  :
    /* and buf_fin-ob.fact-date >= p-start-date */
     find first buf_fin-ob-attr no-lock where
          buf_fin-ob-attr.host-code = p-host-code
      AND buf_fin-ob-attr.doc-code  = buf_fin-ob.doc-code
      AND buf_fin-ob-attr.attr-code = {&fo-bge-date} no-error .
      if available buf_fin-ob-attr then next export-fin-obs.

      assign
      v-fin-doc-code  = buf_fin-ob.doc-code
      v-doc-date      = buf_fin-ob.doc-date
      v-fact-date     = buf_fin-ob.fact-date
      v-doc-ps        = buf_fin-ob.ps
      .
      run export-fin-ob (
           input p-host-code
          , input v-fin-doc-code
          , input v-doc-date
          , input v-fact-date
          , input v-doc-ps
        ) no-error.
      if error-status :error then do:
        run wp-XMLWriteLog in this-procedure (
              input sLogFile
            , input 1
            , input substitute ( "Ошибка экспорта ФО. Номер документа: &1. &2. &3 &4 "
                                , v-fin-doc-code
                                , return-value
                                , trim (error-status :get-message (1))
                                , trim (error-status :get-message (2))
                              )
        ).
        undo export-fin-obs, next export-fin-obs.
      end.
      /* Пометить выгруженные - прописать поле attr-value fin-ob-attr */
      run run-callback-write-doc-code in this-procedure (
            input p-parent-proc
          , input "fin-ob":U
          , input buf_fin-ob.host-code
          , input buf_fin-ob.doc-code
          , input 0 /*corr-user-db-num*/
          , input 0 /*chip-num*/
          , input slogfile
      ).
    end.        /* for each buf_fin-ob */
 end.
end procedure. /* export-documents */


/*==========================================================================*/
procedure export-fin-ob :
define input parameter p-host-code              as integer      no-undo .
define input parameter p-fin-doc-code           as character no-undo .
define input parameter p-doc-date               as date         no-undo.
define input parameter p-fact-date              as date         no-undo.
define input parameter p-doc-PS                 as character    no-undo.

{ bge/xmlfo0.i def }

define variable v-exists-before     as logical      no-undo.
define variable v-exists-after      as logical      no-undo.
define variable v-doc-date          as date         no-undo.
define variable v-today             as date         no-undo.
define variable v-time              as integer      no-undo.

do
on error undo, return error
:

 find first buf_fin-ob no-lock where
           buf_fin-ob.host-code = p-host-code
       AND buf_fin-ob.doc-code = p-fin-doc-code no-error .
  if not available buf_fin-ob then do:

  end.
  assign
  v-doc-date  = buf_fin-ob.doc-date
  .
  run wp-XMLWriteCnt ( hcnt, "   " + string ( p-fin-doc-code ) + " от " + string ( p-fact-date ) ) .
  process events.
  run wp-xmltagopen ( 2, "operation","" ).
  run wp-xmltagput ( 3, "referenceNo",        string ( p-fin-doc-code                       ), 0 ).
  run wp-xmltagput ( 3, "host",               string ( p-host-code                          ), 0 ).
  run wp-xmltagput ( 3, "dateDoc",            string ( v-doc-date,"99.99.9999"              ), 0 ).
  run wp-xmltagput ( 3, "dateFact",           string ( p-fact-date,"99.99.9999"             ), 0 ).
  run wp-xmltagput ( 3, "valutCode",          string ( v-base-code                          ), 0 ).

  { bge/xmlfo0.i run LIST bge-xml }

  run wp-xmltagput ( 3, "comment",  p-doc-PS, 0 ).
  run wp-xmltagclose ( 2, "operation" ).
end.
end procedure. /* export-fin-ob */


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
  when "fin-ob":U then do:
    assign
    v-procedure-name = "fill-temp-fin-doc-code":U
    .
  end.        /* when "fin-ob":U */
end case.       /* case p-type */

if lookup ( v-procedure-name, p-handle :internal-entries ) > 0
then do:
    run value ( v-procedure-name ) in p-handle (
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
            , input substitute ( "Ошибка при вызове callback - процедуры &1.", v-procedure-name )
        ).
    end.
end.
else do:                           /* нет такой процедуры */
    run wp-XMLWriteLog in this-procedure (
          input p-log-file
        , input 1
        , input substitute ( "Не найдена callback - процедура &1.", v-procedure-name )
    ).
end.

end.
end procedure. /* run-callback-write-doc-code */