block-level on error undo, throw.
define input parameter p-user-id like ub.c-usr-hist.user-id no-undo .
define input parameter p-chip-num like ub.c-usr-hist.chip-num no-undo .
define input parameter p-corr-user-db-num like ub.c-usr-hist.corr-user-db-num no-undo .
define input parameter p-subject like ub.c-usr-hist.subject no-undo .
define input parameter p-action   like ub.c-usr-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: 4886e87b5a2b, 3169, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:23 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cuserhistv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/cuserhistv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории пользователя".
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
define variable v-chg-fields    as character no-undo.
define variable v-old-fields    as character no-undo.
define variable v-new-fields    as character no-undo.
define variable ii              as integer   no-undo.
define variable v-mess          as character no-undo .
define buffer buf_c-usr-hist for ub.c-usr-hist.
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
find first buf_c-usr-hist no-lock where
  buf_c-usr-hist.user-id = p-user-id
  AND buf_c-usr-hist.chip-num = p-chip-num
  AND buf_c-usr-hist.corr-user-db-num = p-corr-user-db-num
  AND buf_c-usr-hist.subject  = p-subject no-error .
if not available buf_c-usr-hist then
do:
  return error .
end.
if p-subject begins 'user-account-attr':U + "."
then
   run user-obj-proc in this-procedure(output p-description) no-error  .
else CASE p-subject:
  when 'user-login':U then
    do:
      run user-login-proc in this-procedure(output p-description) no-error  .
    end.
  when 'user-account':U then
    do:
      run user-account-proc in this-procedure(output p-description) no-error  .
    end.
  when 'user-obj':U then
    do:
      run user-obj-proc in this-procedure(output p-description) no-error  .
    end.
  when 'user-host':U then
    do:
      run user-obj-proc in this-procedure(output p-description) no-error  .
    end.
  when 'user-login-action-role':U then
    do:
      run user-obj-proc in this-procedure(output p-description) no-error  .
    end.
END CASE.
if error-status:error then
do:
  return error substitute("&1 &2", error-status:get-message(1), return-value ) .
end.
procedure user-login-proc :
  define output parameter p-description as character no-undo .
  define buffer curr_c-user-login for ub.c-user-login  .
  do
    on error undo, return error
    :
    find first curr_c-user-login no-lock where
      curr_c-user-login.user-id = p-user-id
      AND curr_c-user-login.chip-num = p-chip-num
      AND curr_c-user-login.corr-user-db-num = p-corr-user-db-num
      no-error .
    if not avail curr_c-user-login then
    do:
      v-mess = "Неверная ссылка на c-user-login в таблице c-usr-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    define variable v-label-param as character no-undo .
    v-label-param =
      "user-login" + chr(4) + "Логин" + chr(4) + "" + chr(8)
      + "user-password-encoded" + chr(4) + "Пароль" + chr(4) + "" + chr(8)
      + "user-administrator" + chr(4) + "Администратор" + chr(4) + "" + chr(8)
      + "max-discnt" + chr(4) + "Максимальная скидка" + chr(4) + "" + chr(8)
      + "last-login-mjd" + chr(4) + "Дата и время последнего входа в систему" + chr(4) + "" + chr(8)
      + "status_" + chr(4) + "Статус" + chr(4) + "" + chr(8)
      + "user-password-set-mjd" + chr(4) + "Дата и время задания пароля" + chr(4) + "" + chr(8)
      + "cntxt-menu-code" + chr(4) + "Код меню" + chr(4) + "" + chr(8)
      + "cntxt-menu-group-id" + chr(4) + "Идентификатор группы пунктов меню" + chr(4) + "" + chr(8)
      + "last-login-computer-name" + chr(4) + "Компьютер" + chr(4) + "" + chr(8)
      + "last-login-computer-userid" + chr(4) + "Имя пользователя в компьютере" + chr(4) + "" + chr(8)
      + "last-login-process-id" + chr(4) + "Идентификатор процесса" + chr(4) + "" + chr(8)
      + "login-error-count" + chr(4) + "Попыток доступа" + chr(4) + "" + chr(8)
      + "show-goods-fields" + chr(4) + "Список полей" + chr(4) + "" + chr(8)
      + "action-check-parent" + chr(4) + "Проверять права в соответствии с родительским ид" + chr(4) + "" + chr(8)
      + "db-num" + chr(4) + "БД" + chr(4) + "" + chr(8)
      + "quest-print" + chr(4) + "Задавать вопрос: куда выводить документ?" + chr(4) + "".
    run proc-full-temp-changes in this-procedure (
      input buf_c-usr-hist.action = integer('1':U)
      ,input buf_c-usr-hist.action = integer('99':U)
      ,input  buffer curr_c-user-login:handle
      ,input  'user-login':U
      ,input  "db-num,user-login,user-password-encoded,user-administrator,max-discnt,last-login-mjd,status_,user-password-set-mjd,cntxt-menu-code,cntxt-menu-group-id,last-login-computer-name,last-login-computer-userid,last-login-process-id,login-error-count,show-goods-fields,action-check-parent,quest-print"
      ,input  v-label-param).
  end.
end procedure.
procedure user-account-proc :
  define output parameter p-description as character no-undo .
  define buffer curr_c-user-account for ub.c-user-account  .
  do
    on error undo, return error
    :
    find first curr_c-user-account no-lock where
      curr_c-user-account.user-id = buf_c-usr-hist.user-id
      AND curr_c-user-account.chip-num = p-chip-num
      AND curr_c-user-account.corr-user-db-num = p-corr-user-db-num   no-error .
    if not avail curr_c-user-account then
    do:
      v-mess = "Неверная ссылка на c-user-account в таблице c-usr-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    define variable v-label-param as character no-undo .
    v-label-param =
      "nik" + chr(4) + "Псевдоним" + chr(4) + "" + chr(8)
      + "status_" + chr(4) + "Статус" + chr(4) + "" + chr(8)
      + "last-name" + chr(4) + "Фамилия" + chr(4) + "" + chr(8)
      + "first-name" + chr(4) + "Имя" + chr(4) + "" + chr(8)
      + "second-name" + chr(4) + "Отчество" + chr(4) + "" + chr(8)
      + "phone-number" + chr(4) + "Городской телефон" + chr(4) + "" + chr(8)
      + "internal-phone-number" + chr(4) + "Внутренний телефон" + chr(4) + "" + chr(8)
      + "mobile-phone-number" + chr(4) + "Мобильный телефон" + chr(4) + "" + chr(8)
      + "e-mail" + chr(4) + "Эл.почта" + chr(4) + "" + chr(8)
      + "company" + chr(4) + "Компания" + chr(4) + "" + chr(8)
      + "department" + chr(4) + "Отдел" + chr(4) + "" + chr(8)
      + "position" + chr(4) + "Должность" + chr(4) + "" + chr(8)
      + "room" + chr(4) + "Комната" + chr(4) + "" + chr(8)
      + "PS" + chr(4) + "Примечание" + chr(4) + ""  .
    run proc-full-temp-changes in this-procedure (
      input buf_c-usr-hist.action = integer('1':U)
      ,input buf_c-usr-hist.action = integer('99':U)
      ,input  buffer curr_c-user-account:handle
      ,input  'user-account':U
      ,input  "nik,status_,last-name,first-name,second-name,phone-number,internal-phone-number,mobile-phone-number,e-mail,company,department,position,room,PS"
      ,input  v-label-param).
  end.
end procedure.
procedure user-obj-proc :
  define output parameter p-description as character no-undo .
  define buffer curr_c-usr-hist for ub.c-usr-hist  .
  do
    on error undo, return error
    :
    find first curr_c-usr-hist no-lock where
      curr_c-usr-hist.user-id = buf_c-usr-hist.user-id
      AND curr_c-usr-hist.chip-num = p-chip-num
      AND curr_c-usr-hist.corr-user-db-num = p-corr-user-db-num   no-error .
    if not avail curr_c-usr-hist then
    do:
      v-mess = "Неверная ссылка на c-usr-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    define variable vobj as character no-undo.
    define variable vDB as character no-undo.
    assign
       vobj = entry(1,curr_c-usr-hist.source-ref,chr(4))
       vDB  = entry(2,curr_c-usr-hist.source-ref,chr(4))
    no-error.
    create  temp-changes.
    assign
      temp-changes.l_name       = curr_c-usr-hist.subject
      temp-changes.uniq-key-rec = STRING (curr_c-usr-hist.chip-num)
      .
    if curr_c-usr-hist.action = integer('1':U) then temp-changes.v_new = vobj .
    else temp-changes.v_old = vobj .
    if vDB ne ""
    then do:
       create  temp-changes.
       assign
         temp-changes.f_name       = "db-num"
         temp-changes.l_name       = "БД"
         temp-changes.uniq-key-rec = STRING (curr_c-usr-hist.chip-num)
         .
       if curr_c-usr-hist.action = integer('1':U) then temp-changes.v_new = vDB .
       else temp-changes.v_old = vDB .
    end.
  end.
end procedure.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then
      do:
        p-mess =
          substitute("История пользователя &1: щепка &2 БД:&3  Предмет изменений &4&5&6"
          ,p-user-id
          , p-chip-num
          , p-corr-user-db-num
          , p-subject
          , chr(10)
          , p-mess
          ).
      end.
    otherwise
    do:
      message
        p-mess
        view-as alert-box error .
    end.
  end.
END PROCEDURE.
