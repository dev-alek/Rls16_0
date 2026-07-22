block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: rsndxibm.p $
$Archive: str/rsndxibm.p $

Утилита досылки файлов на кассу IBm-XML

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/30/05
Author: Bakhtadze Natalya
Creation date: 10/30/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rsndxibm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rsndxibm.p $":U .
define variable vss-description as character no-undo init "Утилита досылки файлов на кассу IBm-XML".
{ cmp/vssrevis.i }
/*
p-parameter включает

define input parameter p-dir as character no-undo.
define input parameter p-resend as logical no-undo.
/*"путь к неразобранным файлам*/
*/

{ cmp/trg-def.i }
{ str/cdsnddef.i }
define variable p-dir as character no-undo .
define variable p-resend as logical no-undo .

define variable file_ as character no-undo .
define variable path as character no-undo .
define variable atr as character no-undo .
define variable v-entry as character no-undo .
define variable ii as integer no-undo .
define variable v-cd-num as character no-undo .
define variable v-shop-code as character no-undo .
define variable ss as character no-undo .
define variable p-encoding as character no-undo init "windows-1251":U.
{ gbl/xmlparse.i }
{ gbl/xmlvalid.i }
define stream stmXMLOut.
{ str/cd-xml.i }
{ cmp/bitoper.i }

DEFINE VARIABLE var-file-line-num          as   integer               no-undo .
DEFINE VARIABLE v-path                    as character                no-undo .
DEFINE VARIABLE v-full-path               as character                no-undo .
DEFINE VARIABLE v-file-name               as character                no-undo .
DEFINE VARIABLE v-file-name-no-ext        as character                no-undo .
DEFINE VARIABLE v-file-name-ext           as character                no-undo .
define stream chkstream.
define variable v-exit-processing as logical no-undo .
define variable v-first as logical no-undo init yes.
define variable p-view-log as logical   no-undo .
define variable p-spool-or-data as character no-undo .
define variable p-obj-code as integer   no-undo .
define variable v-adresat as character no-undo .
define variable p-pos-type as character no-undo init {&cd-type-IBm-XML}.
{ str/cd-xmlg.i ignoriruem spool }

define stream dirstream.
define stream PrnLibStream.
define buffer buf_cash-desk for ub.cash-desk.
assign
p-dir = entry(1, p-parameter, {&delim-par} )
p-resend = (if num-entries(p-parameter, {&delim-par} ) > 1
            then logical(entry(2, p-parameter, {&delim-par} ))
            else no).
input stream DirStream from os-dir(p-dir) .
_file:
REPEAT :
  import stream DirStream file_ path atr.
  if length(file_) > 3
  AND substring( file_, length(file_) - 2, 3 ) = "xml":u
  AND can-do( "f", atr )  then do:
    if v-first then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!В директории &1 обнаружены файлы, недошедшие до кассы:&2            посылаются заново......."
                              , p-dir
                              , {&new-line})
                                          ).
      v-first = no.
    end.

    process events.
    assign
    v-adresat = '':U
    v-shop-code = '':U
    v-cd-num = '':U
    v-exit-processing = no
    .
    RUN get-xml-ibm-c(input path ) no-error .
    if error-status :error
    then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "!!!Ошибка при обработке файла &1: &2"
                                , file_
                                , return-value
                              )
                                            ).
      assign
      v-view-log = yes
      .
      next _file .
    end.
    if v-adresat <> '':U  then do:
       assign
       v-entry = trim(substring(v-adresat, 4)
                   , {&single-quote}).
       v-shop-code = entry(1, v-entry, "_").
       v-cd-num    = entry(2, v-entry, "_").
      .
      find first buf_cash-desk where
                buf_cash-desk.pos-type = {&cd-type-ibm-xml}
            and buf_cash-desk.db-num = g#db-num
            and buf_cash-desk.obj-code = integer(trim(v-shop-code, {&shop}))
            and buf_cash-desk.cash-num = integer(trim(v-cd-num, 'касса'))           no-error .
      if available buf_cash-desk then do:
          run str/get-inis.p (
                          input {&shop}
                        , input buf_cash-desk.obj-code
                        , input buf_cash-desk.pos-type
                        , input buf_cash-desk.remote
                        , input "get":U /*некий параметр который говорит для чего нам настройки*/
                        , output out
                        , output out2
                        , output in_
                        , output spl
                        , output sav
                        , output v-remote
                        )  no-error .
          if error-status:error then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute(
                                  "!!!Не удалось получить настройки для  POS типа &1 для маг&2 из ini-файла:&3&4 &5"
                                  , buf_cash-desk.pos-type
                                  , buf_cash-desk.obj-code
                                  , {&new-line}
                                  , error-status:get-message(1)
                                  , return-value
                                  )).
            assign
            v-view-log = yes.
            next _file.
          end.
          run str/post-xml.p
            (
            input parparentproc
            ,input parparentproc
            ,input p-log-handle
            ,input (if p-resend then ? else g#news)
            ,input (if p-resend then ? else g#auto)
            ,input 'send'
            ,input log-file-name
            ,input (entry(1, buf_cash-desk.addr-path, {&delim-par}) + '://' + entry(2, buf_cash-desk.addr-path, {&delim-par}))
            ,input replace( path, "/", "\" )
            ,input (replace(in_  + spl  + "/" + file_, "/", "\" ))
            ,input 30
            ,input substitute("Маг&1 касса&2 &3", buf_cash-desk.obj-code, buf_cash-desk.cash-num, file_)
            ) no-error .
        end. /*if available buf_cash-desk then do:*/
        else do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute(
                                "!!!Неизвестная касса-адресат в файле &1: &2&3 касса &4"
                                , path
                                , {&shop}
                                , v-shop-code
                                , v-cd-num
                                )).
          assign
          v-view-log = yes.
          next _file.
        end.
    end. /* shop-code <> 0*/
  end. /*if length(file) > 3 */
end. /*repeat*/
input stream Dirstream close.


procedure cb-xmlparse-tag-start-Data :
define input parameter p-parameter as character no-undo .
/* обработка события "конец Data"*/

do
on error undo, return error
:
  assign
  v-adresat = cb-xmlparse-get-attr(
                          input this-procedure:handle
                          ,input "data":U
                          ,input p-parameter
                          ,input "to":U
                          ,input yes)

  .
  assign
  v-exit-processing = yes
  .
end.
END PROCEDURE.


     .