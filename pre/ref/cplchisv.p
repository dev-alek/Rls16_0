block-level on error undo, throw.
define input parameter p-obj-type like ub.c-plc-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-plc-hist.obj-code no-undo .
define input parameter p-pl-code like ub.c-plc-hist.pl-code no-undo .
define input parameter p-chip-num like ub.c-plc-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-plc-hist.corr-user-db-num no-undo .
define input parameter p-subject like ub.c-plc-hist.subject no-undo .
define input parameter p-action   like ub.c-plc-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 63f60a8c7447, 2876, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:49:10 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cplchisv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cplchisv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории скл места".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure placattr-name :
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
      otherwise do:
        undo, return error "неизвестный атрибут складского места" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure placattr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
      otherwise do:
        undo, return error "Неизвестный атрибут складского места" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure placattr-value :
 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.place-attr.attr-code  no-undo .
    define input  parameter p-obj-type like ub.place-attr.obj-type   no-undo .
    define input  parameter p-obj-code like ub.place-attr.obj-code   no-undo .
    define input  parameter p-pl-code like ub.place-attr.pl-code   no-undo .
    define output parameter p-value    like ub.place-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_place-attr for ub.place-attr .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run placattr-name in this-procedure
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
    find first buf_place-attr no-lock where
               buf_place-attr.obj-type  = p-obj-type
           AND buf_place-attr.obj-code  = p-obj-code
           AND buf_place-attr.pl-code  = p-pl-code
           AND buf_place-attr.attr-code = p-code
      no-error .
    if avail buf_place-attr then do:
      assign
        p-value =  buf_place-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure placattr-write :
  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.place-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.place-attr.obj-code   no-undo .
    define input parameter p-pl-code  like ub.place-attr.pl-code   no-undo .
    define input parameter p-code     like ub.place-attr.attr-code  no-undo .
    define input parameter p-value    like ub.place-attr.attr-value no-undo .
    define buffer buf_place-attr for ub.place-attr .
    define buffer lock_place-attr for ub.place-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run placattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_place-attr exclusive-lock where
               buf_place-attr.obj-type  = p-obj-type
           AND buf_place-attr.obj-code  = p-obj-code
           AND buf_place-attr.pl-code  = p-pl-code
           AND buf_place-attr.attr-code = p-code no-error .
    if not available buf_place-attr then do:
      create buf_place-attr .
      assign
        buf_place-attr.pl-code  = p-pl-code
        buf_place-attr.obj-type  = p-obj-type
        buf_place-attr.obj-code  = p-obj-code
        buf_place-attr.attr-code = p-code
        buf_place-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    ASSIGN
    buf_place-attr.attr-value = p-value no-error.
  end.
end procedure.
procedure placattr-exist :
  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.place-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.place-attr.obj-code   no-undo .
    define input parameter p-pl-code like ub.place-attr.pl-code   no-undo .
    define input parameter p-code     like ub.place-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .
    define buffer buf_place-attr for ub.place-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run placattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_place-attr no-lock where
               buf_place-attr.obj-type  = p-obj-type
           AND buf_place-attr.obj-code  = p-obj-code
           AND buf_place-attr.pl-code  = p-pl-code
           AND buf_place-attr.attr-code = p-code no-error .
    if available buf_place-attr then do:
      P-EXIST = YES.
    end.
  end.
end procedure.
procedure placattr-delete :
  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.place-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.place-attr.obj-code   no-undo .
    define input parameter p-pl-code like ub.place-attr.pl-code   no-undo .
    define input parameter p-code     like ub.place-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo .
    define buffer buf_place-attr for ub.place-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run placattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_place-attr exclusive-lock where
               buf_place-attr.obj-type  = p-obj-type
          AND  buf_place-attr.obj-code  = p-obj-code
          AND  buf_place-attr.pl-code  = p-pl-code
          AND  buf_place-attr.attr-code = p-code no-error .
    if not available buf_place-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_place-attr.
       P-DELETED = YES.
    END.
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure plgdattr-name :
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
      otherwise do:
        undo, return error substitute("Неизвестный атрибут товара на складском месте &1",  p-code ).
      end.
    end.
  end.
end procedure.
procedure plgdattr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
      otherwise do:
        undo, return error substitute("Неизвестный атрибут товара складском месте &1" , p-code ).
      end.
    end.
  end.
end procedure.
procedure plgdattr-value :
 do
  on error undo, return error
  :
    define input  parameter p-code     like ub.pl-gds-attr.attr-code  no-undo .
    define input  parameter p-obj-type like ub.pl-gds-attr.obj-type   no-undo .
    define input  parameter p-obj-code like ub.pl-gds-attr.obj-code   no-undo .
    define input  parameter p-pl-code  like ub.pl-gds-attr.pl-code    no-undo .
    define input  parameter p-gds-code like ub.pl-gds-attr.gds-code   no-undo .
    define output parameter p-value    like ub.pl-gds-attr.attr-value no-undo .
    define output parameter p-type     as character no-undo .
    define buffer buf_pl-gds-attr for ub.pl-gds-attr .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run plgdattr-name in this-procedure
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
    find first buf_pl-gds-attr no-lock where
               buf_pl-gds-attr.obj-type  = p-obj-type
           AND buf_pl-gds-attr.obj-code  = p-obj-code
           AND buf_pl-gds-attr.pl-code  = p-pl-code
           AND buf_pl-gds-attr.gds-code  = p-gds-code
           AND buf_pl-gds-attr.attr-code = p-code
      no-error .
    if avail buf_pl-gds-attr then do:
      assign
        p-value =  buf_pl-gds-attr.attr-value
      .
    end.
    else do:
      assign
        p-value = if p-type = 'L':U then "no":U else ""
      .
    end.
  end.
end procedure.
procedure plgdattr-write :
  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.pl-gds-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.pl-gds-attr.obj-code   no-undo .
    define input parameter p-pl-code  like ub.pl-gds-attr.pl-code    no-undo .
    define input parameter p-gds-code like ub.pl-gds-attr.gds-code   no-undo .
    define input parameter p-code     like ub.pl-gds-attr.attr-code  no-undo .
    define input parameter p-value    like ub.pl-gds-attr.attr-value no-undo .
    define buffer buf_pl-gds-attr for ub.pl-gds-attr .
    define buffer lock_pl-gds-attr for ub.pl-gds-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run plgdattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_pl-gds-attr exclusive-lock where
               buf_pl-gds-attr.obj-type  = p-obj-type
           AND buf_pl-gds-attr.obj-code  = p-obj-code
           AND buf_pl-gds-attr.pl-code  = p-pl-code
           AND buf_pl-gds-attr.gds-code  = p-gds-code
           AND buf_pl-gds-attr.attr-code = p-code no-error .
    if not available buf_pl-gds-attr then do:
      create buf_pl-gds-attr .
      assign
      buf_pl-gds-attr.obj-type  = p-obj-type
      buf_pl-gds-attr.obj-code  = p-obj-code
      buf_pl-gds-attr.pl-code  = p-pl-code
      buf_pl-gds-attr.gds-code  = p-gds-code
      buf_pl-gds-attr.attr-code = p-code
      buf_pl-gds-attr.attr-value = p-value no-error
      .
    end.
    ELSE
    ASSIGN
    buf_pl-gds-attr.attr-value = p-value no-error.
  end.
end procedure.
procedure plgdattr-exist :
  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.pl-gds-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.pl-gds-attr.obj-code   no-undo .
    define input parameter p-pl-code  like ub.pl-gds-attr.pl-code    no-undo .
    define input parameter p-gds-code like ub.pl-gds-attr.gds-code   no-undo .
    define input parameter p-code     like ub.pl-gds-attr.attr-code  no-undo .
    define output parameter p-exist    as logical no-undo .
    define buffer buf_pl-gds-attr for ub.pl-gds-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run plgdattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_pl-gds-attr no-lock where
               buf_pl-gds-attr.obj-type  = p-obj-type
           AND buf_pl-gds-attr.obj-code  = p-obj-code
           AND buf_pl-gds-attr.pl-code  = p-pl-code
           AND buf_pl-gds-attr.gds-code  = p-gds-code
           AND buf_pl-gds-attr.attr-code = p-code no-error .
    if available buf_pl-gds-attr then do:
      P-EXIST = YES.
    end.
  end.
end procedure.
procedure plgdattr-delete :
  do
  on error undo, return error
  :
    define input parameter p-obj-type like ub.pl-gds-attr.obj-type   no-undo .
    define input parameter p-obj-code like ub.pl-gds-attr.obj-code   no-undo .
    define input parameter p-pl-code  like ub.pl-gds-attr.pl-code    no-undo .
    define input parameter p-gds-code like ub.pl-gds-attr.gds-code   no-undo .
    define input parameter p-code     like ub.pl-gds-attr.attr-code  no-undo .
    define output parameter p-deleted  as logical no-undo .
    define buffer buf_pl-gds-attr for ub.pl-gds-attr .
    def var v-type           as character no-undo .
    def var v-format         as character no-undo .
    def var v-label          as character no-undo .
    def var v-user-can-edit  as logical   no-undo .
    def var v-output-display as logical   no-undo .
    def var v-other          as character no-undo .
    run plgdattr-name in this-procedure
      (input  p-code
      ,output v-type
      ,output v-format
      ,output v-label
      ,output v-user-can-edit
      ,output v-output-display
      ,output v-other
      ) no-error .
    if error-status :error then do:
      undo, return error return-value .
    end.
    find first buf_pl-gds-attr exclusive-lock where
               buf_pl-gds-attr.obj-type  = p-obj-type
           AND buf_pl-gds-attr.obj-code  = p-obj-code
           AND buf_pl-gds-attr.gds-code  = p-gds-code
           AND buf_pl-gds-attr.pl-code  = p-pl-code
           AND buf_pl-gds-attr.attr-code = p-code no-error .
    if not available buf_pl-gds-attr then do:
      P-DELETED = NO.
    end.
    ELSE DO:
       delete buf_pl-gds-attr.
       P-DELETED = YES.
    END.
  end.
end procedure.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .
define buffer buf_c-plc-hist for ub.c-plc-hist.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table temp-changes no-undo
field f_name as character
field l_name as character
field v_old as character
field v_new as character
field t_name as character
field num_ as integer
field uniq-key-rec as character
field action as integer
field fNotChange as logical
index pi is unique primary
num_
t_name
f_name
index
Chan
fnotChange
t_name
f_name
index imain uniq-key-rec
.
FUNCTION get-all-fields returns character (p-file-name as character ):
define variable v-dop as character no-undo .
  find first _file no-lock where _file._file-name = p-file-name no-error .
  if not available _file then return "":U.
  for each _field no-lock where
           _field._file-recid = recid(_file) :
    assign
    v-dop = v-dop + _field._field-name + chr(44)
    .
  end.
  return trim(v-dop).
END FUNCTION.
PROCEDURE proc-full-temp-changes :
  define input  parameter p-act-create as logical   no-undo .
  define input  parameter p-act-delete as logical   no-undo .
  define input  parameter p-hst-handle as handle    no-undo .
  define input  parameter p-main-table as character no-undo .
  define input  parameter p-field-list as character no-undo .
  define input  parameter p-label-form as character no-undo .
  define variable h-new-buf         as handle    no-undo .
  define variable h-main-buf        as handle    no-undo .
  define variable h-for-comp        as handle    no-undo .
  define variable v-inform          as character no-undo .
  define variable v-ind             as integer   no-undo .
  define variable v-idx-field-qnty  as integer   no-undo .
  define variable v-num-entries     as integer   no-undo .
  define variable fh                as handle    no-undo .
  define variable fh-main           as handle    no-undo .
  define variable fh-old            as handle    no-undo .
  define variable fh-new            as handle    no-undo .
  define variable v-field-name      as character no-undo .
  define variable v-field-lvl       as character no-undo .
  define variable v-field-form      as character no-undo .
  define variable v-search-exp      as character no-undo .
  define variable v-srch-main       as character no-undo .
  define variable v-word-link       as character no-undo .
  define variable v-av-chip-num     as logical   no-undo .
  define variable v-main-pi-fld-lst as character no-undo .
  define variable v-main-fld-lst    as character no-undo .
  define variable v-delim-list      as character no-undo .
  define variable v-label           as character no-undo .
  define variable v-old-value       as character no-undo case-sensitive.
  define variable v-new-value       as character no-undo case-sensitive.
  define variable v-chg-fields as character no-undo.
  for each temp-changes:
    delete temp-changes.
  end.
  if not p-hst-handle:available then do:
    return .
  end.
  create buffer h-new-buf  for table p-hst-handle .
  create buffer h-main-buf for table p-main-table .
  assign
    v-inform = h-main-buf:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = h-main-buf:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, h-main-buf:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, h-main-buf:name ).
  end.
  assign
    v-srch-main   = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
    v-delim-list  = "":U
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name      = entry( 4 + v-ind, v-inform, ",":U )
      fh                = p-hst-handle:buffer-field( v-field-name )
      fh-main           = h-main-buf:buffer-field( v-field-name )
      v-srch-main       = substitute( "&1 &2 &3.&4 =", v-srch-main, v-word-link, fh-main:table, v-field-name )
      v-main-pi-fld-lst = v-main-pi-fld-lst + v-delim-list + v-field-name
    .
    if fh:data-type ="character":U then do:
      assign
        v-srch-main = substitute( '&1 "&2"', v-srch-main, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-srch-main = substitute( "&1 &2", v-srch-main, fh:buffer-value() )
      .
    end.
    if v-delim-list = "":U then do:
      assign
        v-delim-list = ",":U
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  assign
    v-delim-list  = "":U
  .
  do v-ind = 1 to h-main-buf:num-fields
  on error undo, return error
  :
    assign
      fh-main      = h-main-buf:buffer-field( v-ind )
      v-field-name = fh-main:name
    .
      assign
        v-main-fld-lst = v-main-fld-lst + v-delim-list + v-field-name
      .
      if v-delim-list = "":U then do:
        assign
          v-delim-list = ",":U
        .
      end.
  end.
  assign
    v-inform = p-hst-handle:index-information(1)
    v-ind    = 2
  .
  do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
  on error undo, return error
  :
    assign
      v-inform = p-hst-handle:index-information( v-ind )
      v-ind    = v-ind + 1
    .
  end.
  if v-inform = ?
    or LC( entry( 1, v-inform, ",":U ) ) = "default":U
    or entry( 3, v-inform, ",":U ) <> "1":U
  then do:
    return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-workfile, p-hst-handle:name ).
  end.
  assign
    v-idx-field-qnty = num-entries( v-inform ) - 4
  .
  if v-idx-field-qnty < 2 then do:
    return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-workfile, v-inform, p-hst-handle:name ).
  end.
  assign
    v-search-exp  = "where":U
    v-word-link   = "":U
    v-av-chip-num = false
  .
  do v-ind = 1 to v-idx-field-qnty by 2
  on error undo, return error
  :
    assign
      v-field-name = entry( 4 + v-ind, v-inform, ",":U )
      fh           = p-hst-handle:buffer-field( v-field-name )
      v-search-exp = substitute( "&1 &2 &3.&4", v-search-exp, v-word-link, fh:table, v-field-name )
    .
    if v-field-name = "chip-num":U then do:
      assign
        v-search-exp  = substitute( "&1 >", v-search-exp )
        v-av-chip-num = true
      .
    end.
    else do:
      assign
        v-search-exp = substitute( "&1 =", v-search-exp )
      .
    end.
    if fh:data-type ="character":U then do:
      assign
        v-search-exp = substitute( '&1 "&2"', v-search-exp, replace( replace( fh:buffer-value(), '"':U, '""':U ), '~~':U, '~~~~':U ) )
      .
    end.
    else do:
      assign
        v-search-exp = substitute( '&1 &2', v-search-exp, fh:buffer-value() )
      .
    end.
    if v-word-link = "":U then do:
      assign
        v-word-link = "and":U
      .
    end.
  end.
  if v-av-chip-num = false then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Таблица &2 не содержит поля chip-num.", vss-workfile, p-hst-handle:name ) skip
      "Использование данной процедуры невозможно!" skip
      view-as alert-box error .
    return error .
  end.
  h-new-buf:find-first( v-search-exp, no-lock ) no-error .
  if not h-new-buf:available then do:
    h-main-buf:find-first( v-srch-main, no-lock ) no-error .
    if not h-main-buf:available then do:
      assign
        h-for-comp = ?
      .
    end.
    else do:
      assign
        h-for-comp = h-main-buf
      .
    end.
  end.
  else do:
    assign
      h-for-comp = h-new-buf
    .
  end.
  assign
    v-num-entries = num-entries( v-main-fld-lst, ",":U )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    assign
      v-field-name = entry( v-ind, v-main-fld-lst )
      fh-old       = p-hst-handle:buffer-field( v-field-name )
      v-old-value  = fh-old:buffer-value()
      v-label      = trim( fh-old:label )
    .
    if ( trim( p-field-list ) <> "":U
         and lookup( v-field-name, p-field-list ) > 0
       )
       or trim( p-field-list ) = "":U
    then do:
      if h-for-comp <> ? then do:
        assign
          fh-new      = h-for-comp:buffer-field( v-field-name )
          v-new-value = fh-new:buffer-value()
        .
      end.
      else do:
        assign
          v-new-value = "":U
        .
      end.
        if p-act-create = true then do:
          assign
            v-old-value = "":U
          .
        end.
        if p-act-delete = true then do:
          assign
            v-new-value = "":U
          .
        end.
      if v-old-value <> v-new-value
        or lookup(v-field-name,v-main-pi-fld-lst) ne 0
      then do:
        create temp-changes.
        assign
          temp-changes.t_name = p-main-table
          temp-changes.f_name = v-field-name
          temp-changes.l_name = replace( v-label, "&":U, "":U )
          temp-changes.v_old  = trim( v-old-value )
          temp-changes.v_new  = trim( v-new-value )
          temp-changes.num_   = 0
          temp-changes.fNotChange = v-old-value eq v-new-value
        .
      end.
    end.
  end.
  assign
    v-num-entries = num-entries( p-label-form, chr(8) )
  .
  do v-ind = 1 to v-num-entries
  on error undo, return error return-value
  :
    if num-entries( entry( v-ind, p-label-form, chr(8) ), chr(4) ) = 3 then do:
      assign
        v-field-name = entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-lvl  = entry( 2, entry( v-ind, p-label-form, chr(8) ), chr(4) )
        v-field-form = entry( 3, entry( v-ind, p-label-form, chr(8) ), chr(4) )
      .
      find first temp-changes
        where temp-changes.f_name = v-field-name
        no-error .
      if available temp-changes then do:
        if trim( v-field-lvl ) <> "":U then do:
          assign
            temp-changes.l_name = v-field-lvl
          .
        end.
        if trim( v-field-form ) <> "":U then do:
          assign
            temp-changes.v_old = dynamic-function( v-field-form, temp-changes.v_old )
          .
          if h-for-comp <> ? then do:
            assign
              temp-changes.v_new = dynamic-function( v-field-form, temp-changes.v_new )
            .
          end.
        end.
      end.
    end.
    else do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка! Список должен содержать три поля с разделителем delim-par!" skip
        substitute( "список для поля '&1': '&2'"
                    ,entry( 1, entry( v-ind, p-label-form, chr(8) ), chr(4) )
                    ,entry( v-ind, p-label-form, chr(8) )
                  ) skip
        substitute( "полный список: &2", p-label-form ) skip
        view-as alert-box error .
    end.
  end.
  delete object h-new-buf .
  delete object h-main-buf .
END PROCEDURE.
find first buf_c-plc-hist no-lock where
          buf_c-plc-hist.obj-type = p-obj-type
      AND buf_c-plc-hist.obj-code = p-obj-code
      AND buf_c-plc-hist.pl-code = p-pl-code
      AND buf_c-plc-hist.chip-num = p-chip-num
      AND buf_c-plc-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-plc-hist.subject  = p-subject no-error .
if not available buf_c-plc-hist then do:
  return error .
end.
CASE p-subject:
  when 'place':U then do:
    run place-proc in this-procedure(output p-description) no-error  .
  end.
  when 'pl-gds':U then do:
    run pl-gds-proc in this-procedure(output p-description) no-error  .
  end.
  when 'pl-gds-pump':U then do:
    run pl-gds-pump-proc in this-procedure(output p-description) no-error  .
  end.
  when 'pl-pump':U then do:
    run pl-pump-proc in this-procedure(output p-description) no-error  .
  end.
  when 'pl-pump-nozzle':U then do:
    run pl-pump-nozzle-proc in this-procedure(output p-description) no-error  .
  end.
  when 'place-attr':U then do:
    run place-attr-proc in this-procedure(output p-description) no-error  .
  end.
  when 'pl-gds-attr':U then do:
    run pl-gds-attr-proc in this-procedure(output p-description) no-error  .
  end.
  when 'pl-level':U then do:
    run pl-level-proc in this-procedure(output p-description) no-error  .
  end.
END CASE.
if error-status:error then do:
  return error substitute("&1 &2", error-status:get-message(1), return-value ) .
end.
procedure place-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-place for ub.c-place  .
  do
  on error undo, return error
  :
    find first curr_c-place no-lock where
               curr_c-place.obj-type = p-obj-type
           AND curr_c-place.obj-code = p-obj-code
           AND curr_c-place.pl-code = buf_c-plc-hist.pl-code
           AND curr_c-place.chip-num = p-chip-num
           AND curr_c-place.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail curr_c-place then do:
      v-mess = "Неверная ссылка на c-place в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "add-qnty" + chr(4) + "Дополнительное количество" + chr(4) + "" + chr(8)
 + "is-meas" + chr(4) + "Измеряется приборами" + chr(4) + "" + chr(8)
 + "loc1" + chr(4) + "Коорд1" + chr(4) + "" + chr(8)
 + "loc2" + chr(4) + "Коорд2" + chr(4) + "" + chr(8)
 + "loc3" + chr(4) + "Коорд3" + chr(4) + "" + chr(8)
 + "loc4" + chr(4) + "Коорд4" + chr(4) + "" + chr(8)
 + "max-qnty" + chr(4) + "Максимальное количество" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объектаТип объекта" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "pl-code" + chr(4) + "Код складского места" + chr(4) + "" + chr(8)
 + "pl-name" + chr(4) + "Название" + chr(4) + "" + chr(8)
 + "PS" + chr(4) + "Описание" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer('1':U)
                                            ,input buf_c-plc-hist.action = integer('99':U)
                                            ,input  buffer curr_c-place:handle
                                            ,input  'place':U
                                            ,input  "add-qnty,is-meas,loc1,loc2,loc3,loc4,max-qnty,pl-name,PS,status_"
                                            ,input  v-label-param).
end.
end procedure.
procedure pl-gds-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-pl-gds for ub.c-pl-gds  .
  do
  on error undo, return error
  :
    find first curr_c-pl-gds no-lock where
               curr_c-pl-gds.gds-code = buf_c-plc-hist.gds-code
           AND curr_c-pl-gds.obj-type = p-obj-type
           AND curr_c-pl-gds.obj-code = p-obj-code
           AND curr_c-pl-gds.pl-code = buf_c-plc-hist.pl-code
           AND curr_c-pl-gds.chip-num = p-chip-num
           AND curr_c-pl-gds.corr-user-db-num = p-corr-user-db-num   no-error .
    if not avail curr_c-pl-gds then do:
      v-mess = "Неверная ссылка на c-pl-gds в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "tolerance" + chr(4) + "Допустимое отклонение" + chr(4) + "" + chr(8)
 + "max-qnty" + chr(4) + "Максимальное количество" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "pl-code" + chr(4) + "Код складского места" + chr(4) + "" + chr(8)
 + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer('1':U)
                                            ,input buf_c-plc-hist.action = integer('99':U)
                                            ,input  buffer curr_c-pl-gds:handle
                                            ,input  'pl-gds':U
                                            ,input  "tolerance,max-qnty,PS,status_"
                                            ,input  v-label-param).
end.
end procedure.
procedure pl-gds-pump-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-pl-gds-pump for ub.c-pl-gds-pump  .
  do
  on error undo, return error
  :
    find first curr_c-pl-gds-pump no-lock where
               curr_c-pl-gds-pump.gds-code = buf_c-plc-hist.gds-code
           AND curr_c-pl-gds-pump.obj-type = p-obj-type
           AND curr_c-pl-gds-pump.obj-code = p-obj-code
           AND curr_c-pl-gds-pump.pl-code = buf_c-plc-hist.pl-code
           AND curr_c-pl-gds-pump.pump-code = buf_c-plc-hist.pump-code
           AND curr_c-pl-gds-pump.chip-num = p-chip-num
           AND curr_c-pl-gds-pump.corr-user-db-num = p-corr-user-db-num   no-error .
    if not avail curr_c-pl-gds-pump then do:
      v-mess = "Неверная ссылка на c-pl-gds-pump в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "pump-code" + chr(4) + "№ ТРК" + chr(4) + "" + chr(8)
 + "gds-code" + chr(4) + "Код товара" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "pl-code" + chr(4) + "Код складского места" + chr(4) + "" + chr(8)
 + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer('1':U)
                                            ,input buf_c-plc-hist.action = integer('99':U)
                                            ,input  buffer curr_c-pl-gds-pump:handle
                                            ,input  'pl-gds-pump':U
                                            ,input  "pump-code,gds-code,PS,status_"
                                            ,input  v-label-param).
end.
end procedure.
procedure pl-pump-nozzle-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-pl-pump-nozzle for ub.c-pl-pump-nozzle  .
  do
  on error undo, return error
  :
    find first curr_c-pl-pump-nozzle no-lock where
               curr_c-pl-pump-nozzle.nozzle-code = buf_c-plc-hist.nozzle-code
           AND curr_c-pl-pump-nozzle.obj-type = p-obj-type
           AND curr_c-pl-pump-nozzle.obj-code = p-obj-code
           AND curr_c-pl-pump-nozzle.pl-code = buf_c-plc-hist.pl-code
           AND curr_c-pl-pump-nozzle.pump-code = buf_c-plc-hist.pump-code
           AND curr_c-pl-pump-nozzle.chip-num = p-chip-num
           AND curr_c-pl-pump-nozzle.corr-user-db-num = p-corr-user-db-num   no-error .
    if not avail curr_c-pl-pump-nozzle then do:
      v-mess = "Неверная ссылка на c-pl-pump-nozzle в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "nozzle-code" + chr(4) + "№ пистолета" + chr(4) + "" + chr(8)
 + "pump-code" + chr(4) + "№ ТРК" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "pl-code" + chr(4) + "Код складского места" + chr(4) + "" + chr(8)
 + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer('1':U)
                                            ,input buf_c-plc-hist.action = integer('99':U)
                                            ,input  buffer curr_c-pl-pump-nozzle:handle
                                            ,input  'pl-pump-nozzle':U
                                            ,input  "pump-code,gds-code,PS,status_"
                                            ,input  v-label-param).
end.
end procedure.
procedure pl-pump-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-pl-pump for ub.c-pl-pump  .
  do
  on error undo, return error
  :
    find first curr_c-pl-pump no-lock where
               curr_c-pl-pump.obj-type = p-obj-type
           AND curr_c-pl-pump.obj-code = p-obj-code
           AND curr_c-pl-pump.pl-code = buf_c-plc-hist.pl-code
           AND curr_c-pl-pump.pump-code = buf_c-plc-hist.pump-code
           AND curr_c-pl-pump.chip-num = p-chip-num
           AND curr_c-pl-pump.corr-user-db-num = p-corr-user-db-num  no-error .
    if not avail curr_c-pl-pump then do:
      v-mess = "Неверная ссылка на c-pl-pump в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
  "pump-code" + chr(4) + "№ ТРК" + chr(4) + "" + chr(8)
 + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer('1':U)
                                            ,input buf_c-plc-hist.action = integer('99':U)
                                            ,input  buffer curr_c-pl-pump:handle
                                            ,input  'pl-pump':U
                                            ,input  "pump-code,obj-code,obj-type,pl-code,PS,status_"
                                            ,input  v-label-param).
end.
end procedure.
function  getPlaceAttrCode returns character (istr as char ):
   define variable OStr as character no-undo.
   if istr eq "disable-level-alarm"
   then
      OStr = "Сообщения о переполнении".
   else if istr eq "disable-water-alarm"
   then
      OStr = "Сообщения по воде".
   else if istr eq "place-need-RVD-rvs"
   then
      OStr = "Необходимо сделать сверку с РВД".
   else if istr eq "place-SI-level"
   then
      OStr = "Доп. средство измерения уровня".
   else if istr eq "place-SI-dens"
   then
      OStr = "Доп. средство измерения плотности".
   else if istr eq "place-SI-temp"
   then
      OStr = "Доп. средство измерения температуры".
   else if istr eq "place-SI"
   then
      OStr = "Основное средство измерения".
   else
      OStr = istr.
   return OStr.
end.
function  getPlaceAttrValue returns character (istr as char ):
   define variable OStr as character no-undo.
   define variable vFlag as logical no-undo.
   if    entry(1,istr,chr(4)) eq "enable"
   then
      assign
         OStr = "Включено"
         vFlag = yes
      .
   else if    entry(1,istr,chr(4)) eq "disable"
   then
      assign
         OStr  = "Выключено"
         vFlag = yes
      .
   else
      OStr = istr.
   if     vFlag
      and num-entries (istr,chr(4)) > 2
   then
      OStr = OStr + " для смены № " + entry(3,istr,chr(4)) + " Дата " + entry(2,istr,chr(4)).
   return OStr.
end.
function getSIname returns character (si-code as char) :
  for first sr-izmerenia no-lock where sr-izmerenia.node-code = integer(si-code) :
    return sr-izmerenia.sr-model .
  end .
end .
procedure place-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-place-attr for ub.c-place-attr  .
  do
  on error undo, return error
  :
    find first current_c-place-attr no-lock where
               current_c-place-attr.chip-num = p-chip-num
           AND current_c-place-attr.corr-user-db-num = p-corr-user-db-num
           AND current_c-place-attr.obj-type = p-obj-type
           AND current_c-place-attr.obj-code = p-obj-code
           AND current_c-place-attr.pl-code = p-pl-code  no-error .
    if not avail current_c-place-attr then do:
      v-mess = "Неверная ссылка на c-place-attr в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    run placattr-tooltip in this-procedure (
                input  current_c-place-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + chr(32) + v-label
    .
define variable v-label-param as character no-undo .
if current_c-place-attr.attr-code = "place-SI"
or current_c-place-attr.attr-code = "place-SI-temp"
or current_c-place-attr.attr-code = "place-SI-dens"
or current_c-place-attr.attr-code = "place-SI-level"
then do :
  v-label-param =
    "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "getSIname" + chr(8)
   + "attr-code" + chr(4) + "Код атрибута" + chr(4) + "getPlaceAttrCode"   .
end .
else do :
  v-label-param =
    "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "getPlaceAttrValue" + chr(8)
   + "attr-code" + chr(4) + "Код атрибута" + chr(4) + "getPlaceAttrCode" + chr(8)
   + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
   + "status_" + chr(4) + "Статус" + chr(4) + ""  .
end .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer('1':U)
                                            ,input buf_c-plc-hist.action = integer('99':U)
                                            ,input  buffer current_c-place-attr:handle
                                            ,input  'place-attr':U
                                            ,input  "attr-code,attr-value,PS,status_"
                                            ,input  v-label-param).
end.
end procedure.
procedure pl-gds-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-pl-gds-attr for ub.c-pl-gds-attr  .
  do
  on error undo, return error
  :
    find first current_c-pl-gds-attr no-lock where
               current_c-pl-gds-attr.gds-code = buf_c-plc-hist.gds-code
           AND current_c-pl-gds-attr.chip-num = p-chip-num
           AND current_c-pl-gds-attr.corr-user-db-num = p-corr-user-db-num
           AND current_c-pl-gds-attr.obj-type = p-obj-type
           AND current_c-pl-gds-attr.obj-code = p-obj-code
           AND current_c-pl-gds-attr.pl-code = p-pl-code  no-error .
    if not avail current_c-pl-gds-attr then do:
      v-mess = "Неверная ссылка на c-pl-gds-attr в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    run plgdattr-tooltip in this-procedure (
                input  current_c-pl-gds-attr.attr-code
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + chr(32) + v-label
    .
define variable v-label-param as character no-undo .
v-label-param =
  "attr-value" + chr(4) + "Значение атрибута" + chr(4) + "" + chr(8)
  + "attr-code" + chr(4) + "Код атрибута" + chr(4) + "" + chr(8)
 + "gds-code" + chr(4) + "Код товара" + chr(4) + "" + chr(8)
 + "PS" + chr(4) + "Примечание" + chr(4) + "" + chr(8)
 + "status_" + chr(4) + "Статус" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer('1':U)
                                            ,input buf_c-plc-hist.action = integer('99':U)
                                            ,input  buffer current_c-pl-gds-attr:handle
                                            ,input  'pl-gds-attr':U
                                            ,input  "attr-code,attr-value,gds-code,PS,status_"
                                            ,input  v-label-param).
end.
end procedure.
procedure pl-level-proc :
define output parameter p-description as character no-undo .
define buffer curr_c-pl-level for ub.c-pl-level  .
  do
  on error undo, return error
  :
    find first curr_c-pl-level no-lock where
               curr_c-pl-level.obj-type = p-obj-type
           AND curr_c-pl-level.obj-code = p-obj-code
           AND curr_c-pl-level.pl-code = buf_c-plc-hist.pl-code
           AND curr_c-pl-level.chip-num = p-chip-num
           AND curr_c-pl-level.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail curr_c-pl-level then do:
      v-mess = "Неверная ссылка на c-pl-level в таблице c-plc-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
define variable v-label-param as character no-undo .
v-label-param =
   "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + "" + chr(8)
 + "pl-code" + chr(4) + "Код складского места" + chr(4) + "" + chr(8)
 + "pl-level" + chr(4) + "Уровень в см" + chr(4) + "" + chr(8)
 + "pl-qnty" + chr(4) + "Объем в л" + chr(4) + "".
 run proc-full-temp-changes in this-procedure (
                                             input buf_c-plc-hist.action = integer('1':U)
                                            ,input buf_c-plc-hist.action = integer('99':U)
                                            ,input  buffer curr_c-pl-level:handle
                                            ,input  'pl-level':U
                                            ,input  "pl-level,pl-qnty"
                                            ,input  v-label-param).
end.
end procedure.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =
      substitute("История складского места &1 на &2&3: щепка &4 БД:&5  Предмет изменений &6&7&8"
                  ,p-pl-code
                  , p-obj-type
                  , p-obj-code
                  , p-chip-num
                  , p-corr-user-db-num
                  , p-subject
                  , chr(10)
                  , p-mess
                  ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
