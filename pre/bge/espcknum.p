block-level on error undo, throw.
define input        parameter p-action         as   character    no-undo .
define input        parameter p-esys-id        like ub.ext-system.esys-id no-undo .
define input        parameter p-db-num         like ub.ext-system.db-num no-undo .
define input        parameter p-delivery-method as integer   no-undo .
define input        parameter oxml-exch-dir    as character no-undo .
define input        parameter oxml-heap-dir    as character no-undo .
define input        parameter p-sign-fileext   as character no-undo .
define input-output parameter p-pack-num       as   integer      no-undo .
define input-output parameter p-custom-pack-name as character no-undo .
define output       parameter p-pack-name      as   character    no-undo .
define output       parameter p-source-dir     as   character    no-undo .
define output       parameter p-target-dir     as   character    no-undo .
define output       parameter p-temp-dir       as   character    no-undo .
define output       parameter p-log-file-name  as character no-undo .
define output       parameter p-list-file-name as character no-undo .
define output       parameter p-custom-pack-flag as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: 0704feb42aff, 2004, rls $":U .
define variable vss-author      as character no-undo init "$Author: ostroukhov $":U .
define variable vss-date        as character no-undo init "$Date: Wed Sep 18 21:02:01 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: espcknum.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/espcknum.p $":U .
define variable vss-description as character no-undo init "Генерация для ВС номера пакета, имени файла пакета, имени каталога источника и каталога назначени".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function get-short-pack-name returns character ( input p-action as character
                                                ,input p-pack-num as integer
                                                ,input p-delivery-method as integer
                                                ,input p-custom-pack-name as character
                                                ,output p-custom-flag as logical
                                                ):
define variable v-short-pack-name as character no-undo .
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.
define buffer buf_clients for ub.clients.
define variable v-int-point as character no-undo .
define variable v-type as character no-undo .
case p-delivery-method:
 when integer('3':U) then do:
   find first buf_clients no-lock where
            buf_clients.db-num = g#db-num
         and buf_clients.obj-type = 'маг':U no-error .
   if not available buf_clients then do:
    find first buf_clients no-lock where
              buf_clients.db-num = g#db-num
          and buf_clients.obj-type = 'скл':U no-error .
   end.
   case p-action:
     when "put"
     or when "fput" then do:
        v-short-pack-name = (if available buf_clients
                           then  string(buf_clients.obj-code, (if buf_clients.obj-code > 999 then "9999" else "999"))
                           else "___") + "-" + "000" + "_"
                           + string( p-pack-num, "999999999":U ) + ".DAT":U.
     end.
     when "get"
     or when "fget" then do:
       v-short-pack-name = "000" + "-" +
                           (if available buf_clients
                           then  string(buf_clients.obj-code, (if buf_clients.obj-code > 999 then "9999" else "999"))
                           else "___") + "_"
                           + string( p-pack-num, "999999999":U ) + ".DAT":U.
     end.
   end case.
   p-custom-flag = yes.
 end.
 when integer('5':U) then do:
   if p-action = "get" then do:
     find first buf_esys-pck-rcvd  where
                buf_esys-pck-rcvd.espr-pack-num = p-pack-num - 1
            and buf_esys-pck-rcvd.esys-id = p-esys-id
            and buf_esys-pck-rcvd.db-num = p-db-num
            and buf_esys-pck-rcvd.espr-cr-db-num = g#db-num no-error.
     if available buf_esys-pck-rcvd
     and (p-custom-pack-name = ""
          or
          num-entries(p-custom-pack-name, "_") < 2
          or  (num-entries(buf_esys-pck-rcvd.custom-pack-name, "_") >= 2
               and entry(2, buf_esys-pck-rcvd.custom-pack-name, "_") >= entry(2, p-custom-pack-name, "_")
               )
          ) then do:
       p-custom-flag = yes.
       return ''.
     end.
   end.
   p-custom-flag = yes.
   v-short-pack-name = p-custom-pack-name.
 end.
 when integer('9':U) then do:
   p-custom-flag = yes.
   v-short-pack-name = p-custom-pack-name.
 end.
 when integer('11':U) then do:
   case p-action:
     when "put"
     or when "fput" then do:
       run db-attr-value in this-procedure
           (input g#db-num
           ,input 'int-point':U
           ,output v-int-point
           ,output v-type
           ) no-error .
       p-custom-flag = yes.
       v-short-pack-name = v-int-point + "_00000_" + string(p-pack-num) + "_"
                         + string(day(now), "99") + string(month(now), "99") + string(year(now), "9999")
                         + substring(string(TIME, "HH:MM:SS"), 1, 2)
                         + substring(string(TIME, "HH:MM:SS"), 4, 2)
                         + substring(string(TIME, "HH:MM:SS"), 7, 2)
                         + ".xml" .
     end.
     when "get"
     or when "fget" then do:
       p-custom-flag = yes.
       v-short-pack-name = p-custom-pack-name.
     end.
   end case.
 end.
 otherwise do:
   v-short-pack-name = "o":U + string( p-pack-num, "999999999":U ) + ".":U.
 end.
end case.
return v-short-pack-name.
end function.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure esallatr-name :
do
  on error undo, return error
  :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
    case p-code :
            when 'custom-pack-name':U then do:     assign     p-label = "Имя файла в ВС"     p-type = 'C':U      p-format = "X(255)"     p-label = "Имя файла в ВС"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
            when 'route-custom-pack-name':U then do:     assign     p-label = "Иям файла в ВС"     p-type = 'C':U      p-format = "X(255)"     p-label = "Иям файла в ВС"     p-user-can-edit  = false     p-output-display = false     p-other = ""      .   end.
      otherwise do:
        undo, return error substitute("неизвестный атрибут ВС &1", p-code) .
      end.
    end.
  end.
end procedure.
procedure esallatr-value :
do
  on error undo, return error
  :
  define input  parameter p-table-name as character no-undo .
  define input  parameter p-key1     as int64 no-undo .
  define input  parameter p-key2     as int64 no-undo .
  define input  parameter p-key3     as character no-undo .
  define input  parameter p-key4     as character no-undo .
  define input  parameter p-key5     as int64 no-undo .
  define input  parameter p-key6     as int64 no-undo .
  define input  parameter p-key7     as character no-undo .
  define input  parameter p-key8     as character no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  define buffer buf_esys-all-attr for ub.esys-all-attr.
  define variable v-format         as character no-undo .
  define variable v-label          as character no-undo .
  define variable v-user-can-edit  as logical   no-undo .
  define variable v-output-display as logical   no-undo .
  define variable v-other          as character no-undo .
    run esallatr-name in this-procedure
      (input  p-code
      ,output p-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    Find first  buf_esys-all-attr no-lock where
                buf_esys-all-attr.attr-code = p-code
           and  buf_esys-all-attr.table-name  = p-table-name
           and  buf_esys-all-attr.key1  = p-key1
           and  buf_esys-all-attr.key2  = p-key2
           and  buf_esys-all-attr.key3  = p-key3
           and  buf_esys-all-attr.key4  = p-key4
           and  buf_esys-all-attr.key5  = p-key5
           and  buf_esys-all-attr.key6  = p-key6
           and  buf_esys-all-attr.key7  = p-key7
           and  buf_esys-all-attr.key8  = p-key8  no-error .
   if avail buf_esys-all-attr then do:
    assign
    p-value = buf_esys-all-attr.attr-value.
   end.
   else do:
    assign
    p-value = if p-type = 'L':U then "no":U else "".
   end.
end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure ext-system-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-value :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-value in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-write :
  define input parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define input parameter p-value     like ub.ext-system-attr.esya-attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-write in g#attr-lib
      (input p-esys-id
      ,input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-exist :
  define input  parameter p-esys-id   like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num    like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code      like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-exist in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-delete :
  define input  parameter p-esys-id  like ub.ext-system-attr.esys-id    no-undo .
  define input  parameter p-db-num   like ub.ext-system-attr.db-num     no-undo .
  define input  parameter p-code     like ub.ext-system-attr.esya-attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-delete in g#attr-lib
      (input  p-esys-id
      ,input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ext-system-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ext-system-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info3 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define variable v-filelist-total-file-num           as integer      no-undo .
define variable v-filelist-total-dir-num            as integer      no-undo .
define variable v-filelist-main-procedure-handle    as handle       no-undo .
define variable v-filelist-main-procedure-name      as character    no-undo .
define temp-table temp-dirlist no-undo
    field dir-full-name     as character
    field dir-short-name    as character
    field need-process      as logical
    index xpk is primary unique dir-full-name
.
define temp-table temp-filelist no-undo
  field file-name        as character
  field file-name-no-ext as character
  field file-extension   as character
  field directory-name   as character
  field full-name        as character
  field dir-short-name   as character
  field need-process     as logical
  index xpk is unique primary full-name
  index xie1 directory-name file-name
  index xie2 directory-name file-name-no-ext
  index xie3 file-name
  index xie4 file-name-no-ext
  index xie5 need-process file-name
  .
define stream dir-list .
procedure filelist-get-file-num :
  define output parameter p-file-num as integer   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-file-num = v-filelist-total-file-num
    .
  end.
end procedure.
procedure filelist-clear :
  do
  on error undo, return error return-value
  :
    define buffer buf_filelist for temp-filelist .
    assign
      v-filelist-total-file-num = 0
    .
    for each buf_filelist
    on error undo, return error
    :
      delete buf_filelist .
    end.
  end.
end procedure.
procedure filelist-init :
  do
  on error undo, return error
  :
    define input parameter p-dir-name       as character no-undo .
    define input parameter p-filter-ext     as logical   no-undo .
    define input parameter p-ext-list       as character no-undo .
    define input parameter p-dir-short-name as character no-undo .
    define buffer buf_temp-filelist for temp-filelist .
    if p-filter-ext = true
       and p-ext-list = ?
    or (p-filter-ext = false
       and p-ext-list <> ?
       and p-ext-list <> "":U
       )
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "p-filter-ext" p-filter-ext skip
        "p-ext-list"   p-ext-list   skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_temp-filelist
      where buf_temp-filelist.directory-name = p-dir-name
    on error undo, return error return-value
    :
      delete buf_temp-filelist .
    end.
    input stream dir-list from os-dir( p-dir-name ).
    define variable v-file                  as character no-undo .
    define variable v-path                  as character no-undo .
    define variable v-mask                  as character no-undo .
    define variable v-extension             as character no-undo .
    define variable v-file-name-without-ext as character no-undo .
    repeat
    on error undo, return error
    :
      import stream dir-list v-file v-path v-mask .
      if  v-mask <> ?
      and v-mask begins 'F':u
      then do:
      end.
      else do:
        next .
      end.
      if num-entries(v-file, '.':u) > 1
      then do:
        assign
          v-extension = entry(num-entries(v-file, '.':u), v-file,  '.':u )
          v-file-name-without-ext = entry(num-entries(v-file, '.':u) - 1, v-file, '.':u )
        .
      end.
      else do:
        assign
          v-extension = ''
          v-file-name-without-ext = v-file
        .
      end.
      if p-filter-ext = true
      then do:
        if lookup(v-extension, p-ext-list) = 0
        then do:
          next .
        end.
      end.
      create buf_temp-filelist .
      assign
        buf_temp-filelist.file-name        = v-file
        buf_temp-filelist.directory-name   = p-dir-name
        buf_temp-filelist.file-name-no-ext = v-file-name-without-ext
        buf_temp-filelist.file-extension   = v-extension
        buf_temp-filelist.full-name        = p-dir-name + '/':u + v-file
        buf_temp-filelist.dir-short-name   = p-dir-short-name
      .
      assign
        v-filelist-total-file-num = v-filelist-total-file-num + 1
      .
      if v-filelist-main-procedure-handle <> ?
      then do:
        run value( v-filelist-main-procedure-name ) in v-filelist-main-procedure-handle
          (input "file":U
          , input v-filelist-total-file-num
          , input buf_temp-filelist.full-name
          , input buf_temp-filelist.file-name
          ) no-error.
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-subdir-init" skip(1)
            skip "Ошибка при вызове процедуры вывода"
            skip "результатов сканирования каталогов."
            skip return-value
            skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
          undo, return error .
        end.
      end.
    end.
    input stream dir-list close .
    return.
  end.
end procedure.
procedure filelist-dirlist-init-by-list :
  do
  on error undo, return error
  :
    define input parameter p-root-dir   as character no-undo .
    define input parameter p-dir-list   as character no-undo .
    define input parameter p-filter-ext as logical   no-undo .
    define input parameter p-ext-list   as character no-undo .
    define variable v-num-appdir as integer   no-undo .
    do v-num-appdir = 1 to num-entries(p-dir-list)
    :
      define variable v-curr-dir  as character no-undo .
      assign
        v-curr-dir = entry(v-num-appdir, p-dir-list)
      .
      run filelist-init in this-procedure
        (input p-root-dir + '/':u + v-curr-dir
        ,input p-filter-ext
        ,input p-ext-list
        ,input v-curr-dir
        ) .
    end.
  end.
end procedure.
procedure filelist-dirlist-clear :
  do
  on error undo, return error
  :
    define buffer buf_temp-dirlist for temp-dirlist .
    assign
        v-filelist-total-dir-num = 0
    .
    for each buf_temp-dirlist
    on error undo, return error
    :
      delete buf_temp-dirlist .
    end.
  end.
end procedure.
procedure filelist-dirlist-subdir-init :
define input parameter p-dir-name   as character no-undo .
    define buffer buf_temp-dirlist for temp-dirlist .
do
for buf_temp-dirlist
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :full-pathname = ?
    or index( file-info :file-type, "D" ) = 0
    then do:
        message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-init: Заданного каталога не существует."
            skip (1)
            skip "Задан каталог:"
            skip substitute( "'&1'", p-dir-name )
        view-as alert-box error .
        undo, return error .
    end.
    input stream dir-list from os-dir( p-dir-name ).
    define variable v-file                  as character no-undo .
    define variable v-path                  as character no-undo .
    define variable v-mask                  as character no-undo .
    file-in-directory:
    repeat
    on error undo, return error
    :
        import stream dir-list
            v-file
            v-path
            v-mask
        .
        if  v-mask = ?
        or index( v-mask, 'D':u ) = 0
        or v-file = ".":U
        or v-file = "..":U
        then do:
            next file-in-directory.
        end.
        else do:
            find first buf_temp-dirlist
                 where buf_temp-dirlist.dir-full-name    = v-path
            no-error.
            if not available buf_temp-dirlist
            then do:
                create buf_temp-dirlist .
                assign
                    buf_temp-dirlist.dir-full-name    = v-path
                    buf_temp-dirlist.dir-short-name   = v-file
                    buf_temp-dirlist.need-process     = yes
                .
            end.
            assign
                v-filelist-total-dir-num = v-filelist-total-dir-num + 1
            .
            if v-filelist-main-procedure-handle <> ?
            then do:
                run value( v-filelist-main-procedure-name ) in v-filelist-main-procedure-handle (
                      input "dir":U
                    , input v-filelist-total-dir-num
                    , input buf_temp-dirlist.dir-full-name
                    , input buf_temp-dirlist.dir-short-name
                ) no-error.
                if error-status :error
                then do:
                    message
                        vss-workfile vss-revision vss-description skip
                        "filelist-dirlist-subdir-init"
                        skip(1)
                        skip "Ошибка при вызове процедуры вывода"
                        skip "результатов сканирования каталогов."
                        skip return-value
                        skip trim(error-status :get-message(1))
                             trim(error-status :get-message(2))
                             trim(error-status :get-message(3))
                    view-as alert-box error.
                    undo, return error .
                end.
            end.
        end.
    end.
    input stream dir-list close .
end.
end procedure.
procedure filelist-dirlist-init :
define input parameter p-dir-name   as character no-undo .
    define variable v-file  as character no-undo.
    define variable v-path  as character no-undo.
    define variable v-mask  as character no-undo.
    define buffer buf_temp-dirlist for temp-dirlist .
do
for buf_temp-dirlist
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :full-pathname = ?
    or index( file-info :file-type, "D" ) = 0
    then do:
        message
            vss-workfile vss-revision vss-description skip
            "filelist-dirlist-init: Заданного каталога не существует."
            skip (1)
            skip "Задан каталог:"
            skip substitute( "'&1'", p-dir-name )
        view-as alert-box error .
        undo, return error .
    end.
    for each buf_temp-dirlist
       where buf_temp-dirlist.dir-full-name begins file-info :full-pathname
    on error undo, return error return-value
    :
        delete buf_temp-dirlist .
    end.
    create buf_temp-dirlist .
    assign
        buf_temp-dirlist.dir-full-name    = file-info :full-pathname
        buf_temp-dirlist.dir-short-name   = file-info :file-name
        buf_temp-dirlist.need-process     = yes
    .
    do
    while available buf_temp-dirlist
    on error undo, return error
    :
        run filelist-dirlist-subdir-init in this-procedure (
            input buf_temp-dirlist.dir-full-name
        ).
        assign
            buf_temp-dirlist.need-process = no
        .
        find first buf_temp-dirlist
             where buf_temp-dirlist.need-process = yes
        no-error.
    end.
end.
end procedure.
procedure filelist-set-procedure-handle :
define input parameter p-proc-handle    as handle           no-undo.
define input parameter p-proc-name      as character        no-undo.
    define variable v-signature    as character    no-undo.
do
on error undo, return error
:
    if p-proc-handle = ?
    or not valid-handle( p-proc-handle )
    or p-proc-handle :get-signature( p-proc-name ) = ""
    then do:
        assign
            v-filelist-main-procedure-handle = ?
            v-filelist-main-procedure-name   = ""
        .
        undo, return error "filelist-set-procedure-handle: Ошибка передачи handle основной процедуры или имени процедуры обработки результатов сканирования каталогов.".
    end.
    else do:
        assign
            v-signature = p-proc-handle :get-signature( p-proc-name )
        .
        if entry(   1, v-signature )    = "PROCEDURE":U
        and entry( 1, entry(  3, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  3, v-signature ), " ":U ) = "CHARACTER":U
        and entry( 1, entry(  4, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  4, v-signature ), " ":U ) = "INTEGER":U
        and entry( 1, entry(  5, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  5, v-signature ), " ":U ) = "CHARACTER":U
        and entry( 1, entry(  6, v-signature ), " ":U ) = "INPUT":U
        and entry( 3, entry(  6, v-signature ), " ":U ) = "CHARACTER":U
        then do:
            assign
                v-filelist-main-procedure-handle = p-proc-handle
                v-filelist-main-procedure-name   = p-proc-name
            .
        end.
        else do:
            assign
                v-filelist-main-procedure-handle = ?
                v-filelist-main-procedure-name   = ""
            .
            undo, return error "filelist-set-procedure-handle: Ошибка задания параметров процедуры обработки результатов сканирования каталогов.".
        end.
    end.
end.
end procedure.
procedure filelist-clear-procedure-handle :
do
on error undo, return error
:
    assign
        v-filelist-main-procedure-handle = ?
        v-filelist-main-procedure-name   = ?
    .
end.
end procedure.
procedure filelist-build-by-dirlist :
    define buffer buf_temp-dirlist      for temp-dirlist.
do
for buf_temp-dirlist
on error undo, return error
:
    for each buf_temp-dirlist
    on error undo, return error
    :
        run filelist-init in this-procedure (
              input buf_temp-dirlist.dir-full-name
            , input no
            , input "":U
            , input buf_temp-dirlist.dir-short-name
        ).
    end.
end.
end procedure.
procedure filelist-check-dir-exists :
define input parameter p-dir-name   as character        no-undo.
define output parameter p-exists    as logical          no-undo.
do
on error undo, return error
:
    assign
        file-info :file-name = p-dir-name
    .
    if file-info :file-type <> ?
    and substring( file-info :file-type, 1, 1 ) = "D":U
    then do:
        assign
            p-exists = yes
        .
    end.
    else do:
        assign
            p-exists = no
        .
    end.
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure db-attr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-value :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-value     like ub.db-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-write :
  define input parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input parameter p-code      like ub.db-attr.attr-code  no-undo .
  define input parameter p-value     like ub.db-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-write in g#attr-lib
      (input p-db-num
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-exist :
  define input  parameter p-db-num    like ub.db-attr.db-num     no-undo .
  define input  parameter p-code      like ub.db-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-delete :
  define input  parameter p-db-num   like ub.db-attr.db-num     no-undo .
  define input  parameter p-code     like ub.db-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure db-attr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run db-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
  define buffer buf_esys-pck-sent for ub.esys-pck-sent .
//  define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd .
  define buffer buf_esys-pck-keys for ub.esys-pck-keys .
  define buffer buf_esys-all-attr for ub.esys-all-attr.
  define buffer buf_temp-filelist for temp-filelist.
  define variable v-work-dir as character no-undo .
  define variable v-mess as character no-undo .
  define variable v-new-pack as logical no-undo .
  define variable v-to-return as logical no-undo .
  define variable v-ftp-path-in as character no-undo .
  define variable v-type as character no-undo .
  define variable v-num-entries as integer no-undo .
do
on error undo, return error
:
  run bge/esdirnam.p ( input p-action
                      ,input p-esys-id
                      ,input p-db-num
                      ,input p-delivery-method
                      ,input oxml-exch-dir
                      ,input oxml-heap-dir
                      ,output p-source-dir
                      ,output p-target-dir
                      ,output p-temp-dir
                      ,output p-log-file-name
                     ) .
  file-info:file-name = p-source-dir .
  if file-info:file-type begins "D":U then . else do :
    os-create-dir value( p-source-dir ).
    if os-error <> 0 then do:
      run gbl/os-errnm.p ( input os-error, output v-mess ).
      return error substitute("&1 Каталог &2 отсутствует, а создать его не удалось.&3&4"
                             ,vss-workfile
                             ,p-source-dir
                             ,chr(10)
                             ,v-mess
                           ).
    end.
  end.
  file-info:file-name = p-target-dir .
  if file-info:file-type begins "D":U then . else do :
    os-create-dir value( p-target-dir ).
    if os-error <> 0 then do:
      run gbl/os-errnm.p ( input os-error, output v-mess ) .
      return error substitute("&1 Каталог &2 отсутствует, а создать его не удалось.&3&4"
                             ,vss-workfile
                             ,p-target-dir
                             ,chr(10)
                             ,v-mess
                           ).
    end.
  end.
  if p-pack-num = -1 then do:
    run findPackNum in this-procedure (p-action, p-esys-id, p-db-num, p-delivery-method,
                                       output p-pack-num) no-error .
    if error-status:error then return error return-value .
    v-new-pack = yes.
  end.
  if p-pack-num < 0 then do:
    v-new-pack = yes.
    p-pack-num = abs(p-pack-num).
  end.
  p-list-file-name =  oxml-heap-dir + chr(92) + "lst":U + string( p-pack-num, "999999999") + ".":U .
  if (p-action = "put" or p-action = "fput") and p-custom-pack-name > '' then do:
    assign
    p-pack-name = p-custom-pack-name
    p-custom-pack-flag = yes
    .
  end.
  else do:
    if p-action = "put" then do:
      if p-custom-pack-name = ? then do:
        find first buf_esys-pck-sent no-lock where
                buf_esys-pck-sent.esps-pack-num = p-pack-num
            and buf_esys-pck-sent.esys-id = p-esys-id
            and buf_esys-pck-sent.db-num = p-db-num
            and buf_esys-pck-sent.esps-cr-db-num = g#db-num no-error.
        if available buf_esys-pck-sent
        and buf_esys-pck-sent.custom-pack-name <> ''
        then do:
          assign
          p-pack-name = buf_esys-pck-sent.custom-pack-name
          p-custom-pack-name = buf_esys-pck-sent.custom-pack-name
          p-custom-pack-flag = yes
          .
        end.
        else do:
          assign
          p-pack-name = get-short-pack-name( input p-action
                                           , input p-pack-num
                                           , input p-delivery-method
                                           , input buf_esys-pck-sent.custom-pack-name
                                           , output p-custom-pack-flag)
          p-custom-pack-name = p-pack-name
          .
        end.
      end.
      else do:
        assign
        p-pack-name = get-short-pack-name( input p-action
                                        , input p-pack-num
                                        , input p-delivery-method
                                        , input p-custom-pack-name
                                        , output p-custom-pack-flag)
        p-custom-pack-name = p-pack-name
        .
      end.
    end.
    if p-action = "get" then do:
      if p-delivery-method = integer('11':U) then do:
          empty temp-table temp-filelist .
          run filelist-init in this-procedure
          (input p-source-dir
          ,input true
          ,input "xml,zip" // ,p7s,p7c"

          ,input ""
          ) no-error.
          
          for each buf_temp-filelist exclusive-lock :
              /* 23/VIII-2018 заглушка: исключаем файлы с электронной подисью,
                              чтобы они читались строго позже файлов с данными */
              if (p-sign-fileext > "") and (buf_temp-filelist.file-extension = p-sign-fileext) then do :
                  delete buf_temp-filelist .
                  next .
              end . 
              /* 05/IX-2018 ещё заглушка: если в настройках в bge/oxmlspci.w указали неправильное расширение,
                                          а файлы с электронной подписью всё же пришли */
              if can-do("p7s,p7c", buf_temp-filelist.file-extension) then do :
                  delete buf_temp-filelist .
                  next .
              end . 
            v-num-entries = num-entries(buf_temp-filelist.file-name, "_") .
              if v-num-entries = 4
              or (v-num-entries = 5 and buf_temp-filelist.file-name begins "ack")
              then .
              else do :
                  delete buf_temp-filelist .
                  next .
              end.
          end.
          find first buf_temp-filelist no-error.
          if available buf_temp-filelist
          then do :
              p-custom-pack-name = buf_temp-filelist.file-name .
          end.
      end.
      
      find first buf_esys-all-attr share-lock where
              buf_esys-all-attr.attr-code = 'custom-pack-name':U
          and buf_esys-all-attr.table-name = 'esys-pck-rcvd':U
          and buf_esys-all-attr.key1 = p-pack-num
          and buf_esys-all-attr.key2 = p-esys-id
          and buf_esys-all-attr.key5 = p-db-num
          and buf_esys-all-attr.key6 = ibs.th.gbl.gbl-var:g#db-num no-error.
      assign
      p-pack-name = get-short-pack-name( input p-action
                                      , input p-pack-num
                                      , input p-delivery-method
                                      , input p-custom-pack-name
                                      , output p-custom-pack-flag)
      p-custom-pack-name = (if p-custom-pack-flag
                            then p-pack-name
                            else p-custom-pack-name)
      .
      if p-pack-name = '' then do:
        v-to-return = yes.
        /*не можем сделать просто return - надо еще директорию создать*/
      end.
      if not v-to-return then do:
        if v-new-pack = yes
        and p-custom-pack-flag
        then do:
        if not available buf_esys-all-attr then do:
          create buf_esys-all-attr.
          assign
          buf_esys-all-attr.attr-code = 'custom-pack-name':U
          buf_esys-all-attr.table-name = 'esys-pck-rcvd':U
          buf_esys-all-attr.key1 = p-pack-num
          buf_esys-all-attr.key2 = p-esys-id
          buf_esys-all-attr.key5 = p-db-num
          buf_esys-all-attr.key6 = ibs.th.gbl.gbl-var:g#db-num
          .
        end.
        buf_esys-all-attr.attr-value = p-custom-pack-name .
        end. /*if v-new-pack = yes*/
      end. /*if not v-to-return then do:*/
    end. /*if p-action = "get" then do:*/
  end. /*else if (p-action = "put" or p-action = "fput")*/


end.

procedure findPackNum private :
define input  parameter p-action   as character no-undo .
define input  parameter p-esys-id  as integer no-undo .
define input  parameter p-db-num   as integer no-undo .
define input  parameter p-delivery-method as integer no-undo .
define output parameter p-pack-num as integer no-undo .
define variable v-cr-db-num as integer no-undo .
define variable v-s-method  as character no-undo .
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd .
define buffer buf_esys-pck-sent for ub.esys-pck-sent .

  assign
    v-cr-db-num = ibs.th.gbl.gbl-var:g#db-num
    v-s-method  = string(p-delivery-method)
  no-error.
  case p-action :
    
    when "get":U then do:
      find last buf_esys-pck-rcvd no-lock
          where buf_esys-pck-rcvd.esys-id = p-esys-id
            and buf_esys-pck-rcvd.db-num  = p-db-num
            and buf_esys-pck-rcvd.espr-cr-db-num = v-cr-db-num
          use-index pi no-error .
      if available buf_esys-pck-rcvd then
        p-pack-num = buf_esys-pck-rcvd.espr-pack-num + 1 .
      else /* "первый", он же - "нулевой" пакет */
        p-pack-num = (if v-s-method = '2':U
                      or v-s-method = '1':U
                      or v-s-method = '3':U then 1 else 0) .
    end. /* end_of "get":U */
    when "fget":U then do:
      p-pack-num = 0.
    end.

    when "put":U then do:
      find last buf_esys-pck-sent no-lock
          where buf_esys-pck-sent.esys-id = p-esys-id
            and buf_esys-pck-sent.db-num  = p-db-num
            and buf_esys-pck-sent.esps-cr-db-num = v-cr-db-num
          use-index pi no-error .
      if available buf_esys-pck-sent then
        p-pack-num = buf_esys-pck-sent.esps-pack-num + 1 .
      else /* "первый", он же - "нулевой" пакет */
        p-pack-num = (if v-s-method = '11':U then 1 else 0) .
    end. /* end_of "put":U */
    when "fput" then do:
        /*экспорт файла*/
        p-pack-num = (if v-s-method = '11':U then 1 else 0) .
    end.

    otherwise do:
      return error substitute("&1 &2 &3&4Не предусмотрена операция &5 для &1&4"
                             ,vss-workfile, vss-revision, vss-description 
                             ,chr(10)
                             ,p-action
                           ).
    end.
  end case . /* end_of case_p_action */
  
end procedure . /* end_of findPackNum */

/* $Workfile: espcknum.p $ end */
