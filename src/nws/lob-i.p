block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: lob-i.p $
$Archive: nws/lob-i.p $

Прием CLOB или BLOB

Автор: Бахтадзе Наталья Викторовна
Дата создания: 07/28/06
Author: Bakhtadze Natalya
Creation date: 07/28/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-imp-handle as handle    no-undo .
define input parameter p-counter  as integer   no-undo .
define input parameter p-table-name as character no-undo .
define input parameter p-db-num as integer   no-undo .
define input  parameter p-int64-id as int64 no-undo .
define output parameter p-ok as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: lob-i.p $":U .
define variable vss-archive     as character no-undo init "$Archive: nws/lob-i.p $":U .
define variable vss-description as character no-undo init "Прием CLOB или BLOB".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ cmp/library.i  }
{ nws/lobfile.i  }

define variable counter    as integer   no-undo .
define variable rec-full   as character no-undo .
define variable v-rec-name as character no-undo .
define variable log-file-name as character no-undo init "":U.
define variable v-md5-signature as character no-undo .
define variable v-lob-bh as handle no-undo .
define variable v-ii as integer   no-undo .
define variable v-jj as integer   no-undo .

define buffer buf_temp-nws-outline for temp-nws-outline .
define buffer buf_temp-ext-file-line for temp-ext-file-line .
define buffer buf_clob-data for ub.clob-data.
define buffer buf_blob-data for ub.blob-data.
define temp-table temp-clob-data no-undo like ub.clob-data.
define temp-table temp-blob-data no-undo like ub.blob-data.
define buffer buf_temp-clob-data for temp-clob-data.
define buffer buf_temp-blob-data for temp-blob-data.


main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run write-to-log in p-log-handle (
        input substitute("Получение &1: БД &2 id &3"
                        , p-table-name
                        , p-db-num
                        , p-int64-id
                          )).

  do counter = 1 to p-counter
  on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
  on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
  on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
  :

    if counter modulo 10 = 0
    then do:
      run write-to-screen in p-log-handle (substitute("Получено записей &1", counter)) no-error.
    end.
    run nws-imps in p-imp-handle
      ( input-output counter
       ,output       rec-full
      ) no-error.
    if error-status :error then do:
      undo main-block, return error return-value .
    end.
    assign
      v-rec-name = entry( 1, rec-full, {&delim-nws} )
    .
    CASE entry(1, v-rec-name, {&delim-par}) :
      when {&table_nws-outline} then do:
        create buf_temp-nws-outline.
        run nws-impl in p-imp-handle
          ( input {&table_nws-outline}
           ,input buffer buf_temp-nws-outline:handle
          ) no-error.
        if error-status :error then do:
          delete buf_temp-nws-outline.
          undo main-block, return error return-value .
        end.
        case p-table-name:
          when {&table_clob-data} then do:
            create buf_temp-clob-data.
            assign
            v-lob-bh = buffer buf_temp-clob-data:handle.
          end.
          when {&table_blob-data} then do:
            create buf_temp-blob-data.
            assign
            v-lob-bh = buffer buf_temp-blob-data:handle.
          end.
        end case.
        do v-ii = 1 to v-lob-bh:handle:num-fields:

          if not (v-lob-bh:buffer-field(v-ii):data-type = {&abl-datatype-clob}
                  or
                  v-lob-bh:buffer-field(v-ii):data-type = {&abl-datatype-blob}) then do:
              v-jj = v-jj + 1.
              case v-lob-bh:buffer-field(v-ii):data-type:
                when {&abl-datatype-character} then do:
                assign
                v-lob-bh:buffer-field(v-ii):buffer-value = entry(v-jj, buf_temp-nws-outline.charkey_one, {&delim-key})
                .
                end.
                when {&abl-datatype-int64} then do:
                assign
                v-lob-bh:buffer-field(v-ii):buffer-value = int64(entry(v-jj, buf_temp-nws-outline.charkey_one, {&delim-key}))
                .
                end.
                when {&abl-datatype-integer} then do:
                assign
                v-lob-bh:buffer-field(v-ii):buffer-value = integer(entry(v-jj, buf_temp-nws-outline.charkey_one, {&delim-key}))
                .
                end.
                when {&abl-datatype-date} then do:
                assign
                v-lob-bh:buffer-field(v-ii):buffer-value = date(entry(v-jj, buf_temp-nws-outline.charkey_one, {&delim-key}))
                .
                end.
                when {&abl-datatype-logical} then do:
                assign
                v-lob-bh:buffer-field(v-ii):buffer-value = logical(entry(v-jj, buf_temp-nws-outline.charkey_one, {&delim-key}))
                .
                end.
              end case.
          end.
        end.
        case p-table-name:
          when {&table_clob-data} then do:
            find first buf_clob-data where
                      buf_clob-data.db-num = buf_temp-clob-data.db-num
                  and buf_clob-data.int64-id = buf_temp-clob-data.int64-id  no-error.
            if not available buf_clob-data then do:
              create buf_clob-data.
            end.
            buffer-copy buf_temp-clob-data
            to buf_clob-data no-lobs.
            v-lob-bh = buffer buf_clob-data:handle.
          end.
          when {&table_blob-data} then do:
            find first buf_blob-data where
                      buf_blob-data.db-num = buf_temp-blob-data.db-num
                  and buf_blob-data.int64-id = buf_temp-blob-data.int64-id  no-error.
            if not available buf_blob-data then do:
              create buf_blob-data.
            end.
            buffer-copy buf_temp-blob-data
            to buf_blob-data no-lobs.
            v-lob-bh = buffer buf_blob-data:handle.
          end.
        end case.
      end. /*when {&table_nws-outline} then do:*/
      when {&table_ext-file-line} then do:
        create buf_temp-ext-file-line.
        run nws-impl in p-imp-handle
          ( input {&table_ext-file-line}
           ,input buffer buf_temp-ext-file-line:handle
          ) no-error.
        if error-status :error then do:
          undo main-block, return error return-value .
        end.
        release buf_temp-ext-file-line.
      end. /*when {&table_ext-file-line} then do:*/
    END CASE.
  end. /*do counter*/
  run lob_write in this-procedure ( input v-lob-bh) .
  /*проверим md5 но пока не проверяем*/
  case p-table-name:
    when {&table_clob-data} then do:
      if v-md5-signature <> buf_temp-clob-data.crc-field then do:
        run write-to-log in p-log-handle (
                                            substitute("!!!"
                                                  )).
      end.
    end.
    when {&table_blob-data} then do:
      if v-md5-signature <> buf_temp-blob-data.crc-field then do:
        run write-to-log in p-log-handle (
                                            substitute("!!!"
                                                  )).
      end.
    end.
  end case.
  p-ok = yes.
  return '':U.
end. /*doe*/


procedure write-to-log :
define input parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
     run write-to-log in p-parent-handle (input p-message) .
  end.

end procedure. /* write-to-log */