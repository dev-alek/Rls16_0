block-level on error undo, throw.
define input parameter p-obj-type like ub.c-fbr-gds-grp-hist.obj-type no-undo .
define input parameter p-obj-code like ub.c-fbr-gds-grp-hist.obj-code no-undo .
define input parameter p-node-code  like ub.c-fbr-gds-grp-hist.node-code no-undo .
define input parameter p-corr-user-db-num  like ub.c-fbr-gds-grp-hist.corr-user-db-num no-undo .
define input parameter p-chip-num  like ub.c-fbr-gds-grp-hist.chip-num no-undo .
define input parameter p-subject like ub.c-fbr-gds-grp-hist.subject no-undo .
define input parameter p-action   like ub.c-fbr-gds-grp-hist.action no-undo .
define input parameter p-silent  as logical no-undo .
define output parameter p-description as character no-undo .
define output parameter p-full-name-old as character no-undo .
define output parameter p-full-name-new as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cfggrhiv.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/cfggrhiv.p $":U .
define variable vss-description as character no-undo init "Заполнение временной таблицы для показа изменений по таблицам истории групп блюд".
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
procedure fbr-grp-attr-name :
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
        undo, return error "Неизвестный атрибут группы блюд" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fbr-grp-attr-tooltip :
do
  on error undo, return error
  :
    define input  parameter p-code    as character no-undo .
    define output parameter p-tooltip as character no-undo .
    define output parameter p-label   as character no-undo .
    case p-code :
      otherwise do:
            undo, return error "Неизвестный атрибут группы блюд" + " " + p-code .
      end.
    end.
  end.
end procedure.
procedure fbr-grp-attr-value :
do
on error undo, return error
:
define input  parameter p-obj-type    as character  no-undo.
define input  parameter p-obj-code    as integer    no-undo.
define input  parameter p-node-code   as integer    no-undo.
define input  parameter p-code        as character  no-undo.
define output parameter p-value       as character  no-undo.
define output parameter p-type        as character  no-undo.
    define variable v-format         as character no-undo .
    define variable v-label          as character no-undo .
    define variable v-user-can-edit  as logical   no-undo .
    define variable v-output-display as logical   no-undo .
    define variable v-other          as character no-undo .
    define buffer buf_fbr-gds-grp-attr for ub.fbr-gds-grp-attr.
    run fbr-grp-attr-name in this-procedure (
          input  p-code
        , output p-type
        , output v-format
        , output v-label
        , output v-user-can-edit
        , output v-output-display
        , output v-other
    ) no-error .
    if error-status :error
    then do:
        undo, return error return-value .
    end.
    find first buf_fbr-gds-grp-attr no-lock
         where buf_fbr-gds-grp-attr.obj-type  = p-obj-type
           and buf_fbr-gds-grp-attr.obj-code  = p-obj-code
           and buf_fbr-gds-grp-attr.node-code = p-node-code
           and buf_fbr-gds-grp-attr.attr-code = p-code
    no-error .
    if available buf_fbr-gds-grp-attr
    then do:
        assign
            p-value = buf_fbr-gds-grp-attr.attr-value
        .
    end.
    else do:
        assign
        p-value = (if p-type = 'L':U then "no":U else "")
        .
    end.
end.
end procedure.
procedure fbr-grp-attr-write :
do
on error undo, return error
:
define input parameter p-obj-type   like ub.fbr-gds-grp-attr.obj-type            no-undo.
define input parameter p-obj-code   like ub.fbr-gds-grp-attr.obj-code            no-undo.
define input parameter p-node-code  like ub.fbr-gds-grp-attr.node-code      no-undo.
define input parameter p-code       like ub.fbr-gds-grp-attr.attr-code      no-undo.
define input parameter p-value      like ub.fbr-gds-grp-attr.attr-value     no-undo.
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    define buffer buf_fbr-gds-grp-attr for ub.fbr-gds-grp-attr .
    run fbr-grp-attr-name in this-procedure (
                      input  p-code
                    , output v-type
                    , output v-format
                    , output v-label
                    , output v-user-can-edit
                    , output v-output-display
                    , output v-other
    ) no-error.
    if error-status :error
    then do:
        undo, return error return-value.
    end.
    find first buf_fbr-gds-grp-attr exclusive-lock
         where buf_fbr-gds-grp-attr.obj-type   = p-obj-type
           and buf_fbr-gds-grp-attr.obj-code   = p-obj-code
           and buf_fbr-gds-grp-attr.node-code  = p-node-code
           and buf_fbr-gds-grp-attr.attr-code  = p-code
    no-error.
    if not available buf_fbr-gds-grp-attr
    then do:
        create buf_fbr-gds-grp-attr.
        assign
        buf_fbr-gds-grp-attr.node-code  = p-node-code
        buf_fbr-gds-grp-attr.attr-code  = p-code
        buf_fbr-gds-grp-attr.obj-type   = p-obj-type
        buf_fbr-gds-grp-attr.obj-code   = p-obj-code
        buf_fbr-gds-grp-attr.attr-value = p-value
        .
    end.
    else do:
        assign
            buf_fbr-gds-grp-attr.attr-value = p-value
        .
    end.
end.
end procedure.
procedure fbr-grp-attr-delete :
do
on error undo, return error
:
define input parameter p-obj-type   like ub.fbr-gds-grp-attr.obj-type        no-undo.
define input parameter p-obj-code   like ub.fbr-gds-grp-attr.obj-code        no-undo.
define input parameter p-node-code  like ub.fbr-gds-grp-attr.node-code  no-undo.
define input parameter p-code       like ub.fbr-gds-grp-attr.attr-code  no-undo.
define output parameter p-deleted   as logical                      no-undo.
    define buffer buf_fbr-gds-grp-attr for ub.fbr-gds-grp-attr .
    define variable v-type              as character                no-undo.
    define variable v-format            as character                no-undo.
    define variable v-label             as character                no-undo.
    define variable v-user-can-edit     as logical                  no-undo.
    define variable v-output-display    as logical                  no-undo.
    define variable v-other             as character                no-undo.
    run fbr-grp-attr-name in this-procedure
    ( input  p-code
    , output v-type
    , output v-format
    , output v-label
    , output v-user-can-edit
    , output v-output-display
    , output v-other
    ) no-error .
    if error-status :error then do:
        undo, return error return-value .
    end.
    find first buf_fbr-gds-grp-attr exclusive-lock
         where buf_fbr-gds-grp-attr.obj-type   = p-obj-type
           and buf_fbr-gds-grp-attr.obj-code   = p-obj-code
           and buf_fbr-gds-grp-attr.node-code  = p-node-code
           and buf_fbr-gds-grp-attr.attr-code  = p-code
    no-error.
    if not available buf_fbr-gds-grp-attr
    then do:
        assign
            p-deleted = no
        .
    end.
    else do:
       delete buf_fbr-gds-grp-attr.
       assign
            p-deleted = yes
        .
    end.
end.
end procedure.
procedure fbr-grp-attr-news :
do
on error undo, return error
:
    define input  parameter p-code           as character no-undo .
    define output parameter p-news           as logical   no-undo .
    case p-code :
      otherwise do:
        undo, return error "неизвестный атрибут группы блюд" + " " + p-code .
      end.
    end.
end.
end procedure.
define variable v-chg-fields as character no-undo.
define variable v-old-fields as character no-undo.
define variable v-new-fields as character no-undo.
define variable ii as integer no-undo.
define variable v-mess as character no-undo .
define buffer buf_c-fbr-gds-grp-hist for ub.c-fbr-gds-grp-hist.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
find first buf_c-fbr-gds-grp-hist no-lock where
         buf_c-fbr-gds-grp-hist.obj-type = p-obj-type
      AND buf_c-fbr-gds-grp-hist.obj-code = p-obj-code
      AND buf_c-fbr-gds-grp-hist.node-code = p-node-code
      AND buf_c-fbr-gds-grp-hist.chip-num = p-chip-num
      AND buf_c-fbr-gds-grp-hist.corr-user-db-num = p-corr-user-db-num
      AND buf_c-fbr-gds-grp-hist.subject  = p-subject no-error .
if not available buf_c-fbr-gds-grp-hist then do:
  return error .
end.
CASE p-subject:
  when 'fbr-gds-grp':U then do:
    run fbr-gds-grp-proc in this-procedure(output p-description) no-error .
  end.
  when 'fbr-gds-grp-attr':U then do:
    run fbr-gds-grp-attr-proc in this-procedure(output p-description) no-error .
  end.
END CASE.
if error-status:error then do:
  return error .
end.
procedure fbr-gds-grp-proc :
define output parameter p-description as character no-undo .
define variable v-is-created as logical no-undo .
define variable v-is-deleted as logical no-undo .
define variable v-field-name as character no-undo .
define variable v-field-label as character no-undo .
define variable jj as integer no-undo.
define buffer current_fbr-gds-grp for ub.fbr-gds-grp  .
define buffer current_c-fbr-gds-grp for ub.c-fbr-gds-grp  .
define buffer new_c-fbr-gds-grp for ub.c-fbr-gds-grp  .
  do
  on error undo, return error
  :
    find first current_c-fbr-gds-grp no-lock where
               current_c-fbr-gds-grp.obj-type = p-obj-type
           AND current_c-fbr-gds-grp.obj-code = p-obj-code
           AND current_c-fbr-gds-grp.node-code = p-node-code
           AND current_c-fbr-gds-grp.chip-num = p-chip-num
           AND current_c-fbr-gds-grp.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-fbr-gds-grp then do:
       v-mess = "Неверная ссылка на c-fbr-gds-grp в таблице c-fbr-gds-grp-hist".
       run err-mess in this-procedure ( input-output v-mess).
       return error v-mess.
    end.
    if buf_c-fbr-gds-grp-hist.action = integer('1':U) then do:
      assign
      v-is-created = yes
      v-chg-fields = get-all-fields ("fbr-gds-grp")
      .
    end.
    if buf_c-fbr-gds-grp-hist.action = integer('99':U) then do:
      assign
      v-is-deleted = yes
      v-chg-fields = get-all-fields ("fbr-gds-grp")
      .
    end.
    find first new_c-fbr-gds-grp no-lock where
              new_c-fbr-gds-grp.obj-type = p-obj-type
           AND new_c-fbr-gds-grp.obj-code = p-obj-code
           AND new_c-fbr-gds-grp.node-code = p-node-code
           AND new_c-fbr-gds-grp.chip-num > p-chip-num
           AND new_c-fbr-gds-grp.corr-user-db-num = p-corr-user-db-num
            no-error .
    if not available new_c-fbr-gds-grp then do:
        find first current_fbr-gds-grp no-lock where
               current_fbr-gds-grp.node-code = p-node-code no-error .
        if not available current_fbr-gds-grp
        and not  v-is-deleted
        then do:
            return error.
        end.
        if available current_fbr-gds-grp then
        buffer-compare current_fbr-gds-grp to current_c-fbr-gds-grp
        case-sensitive
        save result in v-chg-fields.
    end.
    else do:
        buffer-compare new_c-fbr-gds-grp
        except chip-num corr-date corr-time corr-user-name corr-user-db-num
        to current_c-fbr-gds-grp
        case-sensitive
        save result in v-chg-fields.
    end.
    if lookup("node-code", v-chg-fields ) > 0
    or lookup("upper-code", v-chg-fields ) > 0 then do:
       if not v-is-created then
       run c-get-full-name  in this-procedure (
                                                  input  yes
                                                 ,input p-obj-type
                                                 ,input p-obj-code
                                                 ,input p-node-code
                                                 ,input p-chip-num
                                                 ,input p-corr-user-db-num
                                                 ,output p-full-name-old
                                                ) no-error .
       if not v-is-deleted then
       run c-get-full-name  in this-procedure (
                                                  input  (if available new_c-fbr-gds-grp
                                                          then yes
                                                          else no)
                                                 ,input p-obj-type
                                                 ,input p-obj-code
                                                 ,input p-node-code
                                                 ,input (if available new_c-fbr-gds-grp
                                                         then new_c-fbr-gds-grp.chip-num
                                                         else 0)
                                                 ,input p-corr-user-db-num
                                                 ,output p-full-name-new
                                                ) no-error .
    end.
  _ii:
  do ii = 1 to num-entries(v-chg-fields):
    assign
    v-field-name = entry(ii, v-chg-fields)
    jj = lookup(v-field-name, "global-code,host-code,is-modificator,is-term,lvl-num,node-code,node-name,obj-code,obj-type,out-code,upper-code").
    if jj = 0 then next _ii.
    assign
    v-field-label = entry(jj, "Код Рубрикатора,Код фирмы,Модификаторы блюд,Терминальная группа,Уровень,Код,Наименование,Код объекта,Тип объекта,Код на кассе,Вн № выш.группы")
    .
    create temp-changes.
    assign
    temp-changes.f_name = v-field-name
    temp-changes.l_name = v-field-label
    temp-changes.v_old =  (if v-is-created
                          then "":U
                          else string(buffer current_c-fbr-gds-grp:buffer-field(v-field-name):buffer-value))
    temp-changes.v_new = (if available new_c-fbr-gds-grp
                          then string(buffer new_c-fbr-gds-grp:buffer-field(v-field-name):buffer-value)
                          else  (if v-is-deleted
                                then '':U
                                else  string(buffer current_fbr-gds-grp:buffer-field(v-field-name):buffer-value))
                          )
    .
  end.
end.
end procedure.
procedure fbr-gds-grp-attr-proc :
define output parameter p-description as character no-undo .
define variable v-tooltip as character no-undo .
define variable v-label as character no-undo .
define buffer current_c-fbr-gds-grp-attr for ub.c-fbr-gds-grp-attr  .
  do
  on error undo, return error
  :
    find first current_c-fbr-gds-grp-attr no-lock where
              current_c-fbr-gds-grp-attr.obj-type  = p-obj-type
           AND current_c-fbr-gds-grp-attr.obj-code = p-obj-code
           AND current_c-fbr-gds-grp-attr.node-code = p-node-code
           AND current_c-fbr-gds-grp-attr.chip-num = p-chip-num
           AND current_c-fbr-gds-grp-attr.corr-user-db-num = p-corr-user-db-num
           no-error .
    if not avail current_c-fbr-gds-grp-attr then do:
      v-mess = "Неверная ссылка на c-fbr-gds-grp-attr в таблице c-fbr-gds-grp-attr-hist".
      run err-mess in this-procedure ( input-output v-mess).
      return error v-mess.
    end.
    run fbr-grp-attr-tooltip in this-procedure (
                input  string(current_c-fbr-gds-grp-attr.attr-code)
                ,output v-tooltip
                ,output v-label
                ) no-error .
    assign
    p-description = "Атрибут" + chr(32) + v-label
    .
define variable v-label-param as character no-undo .
v-label-param =
  "attr-code" + chr(4) + "Атрибут" + chr(4) + "" + chr(8)
 + "attr-value" + chr(4) + "Значение" + chr(4) + "" + chr(8)
 + "node-code" + chr(4) + "Вн Код" + chr(4) + "" + chr(8)
 + "obj-code" + chr(4) + "Код объекта" + chr(4) + "" + chr(8)
 + "obj-type" + chr(4) + "Тип объекта" + chr(4) + ""  .
 run proc-full-temp-changes in this-procedure (
                                             input (buf_c-fbr-gds-grp-hist.action = integer('1':U))
                                            ,input (buf_c-fbr-gds-grp-hist.action = integer('99':U))
                                            ,input  buffer current_c-fbr-gds-grp-attr:handle
                                            ,input  'fbr-gds-grp-attr':U
                                            ,input  "attr-code,attr-value,node-code,obj-code,obj-type"
                                            ,input  v-label-param).
end.
end procedure.
procedure c-get-full-name :
do
on error undo, return error
:
define input parameter p-c          as logical no-undo .
define input parameter p-obj-type  as character no-undo .
define input parameter p-obj-code  as integer no-undo .
define input parameter p-node-code  as integer      no-undo.
define input parameter p-chip-num  as integer no-undo .
define input parameter p-corr-user-db-num as integer no-undo .
define output parameter p-full-name as character    no-undo.
    define variable v-upper-code    as integer           no-undo.
    define variable v-c as logical no-undo .
    define buffer buf_fbr-gds-grp       for ub.fbr-gds-grp.
    define buffer buf_upper_gds-grp for ub.fbr-gds-grp.
    define buffer buf_c-fbr-gds-grp       for ub.c-fbr-gds-grp.
    define buffer buf_c-upper_gds-grp for ub.c-fbr-gds-grp.
    if p-c then do:
      find first buf_c-fbr-gds-grp no-lock
          where buf_c-fbr-gds-grp.obj-type = p-obj-type
            AND buf_c-fbr-gds-grp.obj-code = p-obj-code
            AND buf_c-fbr-gds-grp.node-code = p-node-code
            AND buf_c-fbr-gds-grp.chip-num  = p-chip-num
            AND buf_c-fbr-gds-grp.corr-user-db-num  = p-corr-user-db-num
      no-error.
      if not available buf_c-fbr-gds-grp
      then do:
          undo, return error substitute("Не найдена запись истории для группы блюд: объеккт &1&2, вн № &3, chip-num &4, БД-корректор &5"
                                        , p-obj-type
                                        , p-obj-code
                                        , p-node-code
                                        , p-chip-num
                                        , p-corr-user-db-num
                                        ).
      end.
    end.
    else do:
      find first buf_fbr-gds-grp no-lock
          where buf_fbr-gds-grp.obj-type = p-obj-type
             AND buf_fbr-gds-grp.obj-code = p-obj-code
             AND buf_fbr-gds-grp.node-code = p-node-code
      no-error.
      if not available buf_fbr-gds-grp
      then do:
          undo, return error substitute("Не найдена запись группы блюд: объект &1&2 вн № &1"
                                        , p-obj-type
                                        , p-obj-code
                                        , p-node-code
                                        ).
      end.
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
        v-c = p-c
    .
    do while
    ( v-c = no and buf_fbr-gds-grp.upper-code <> 0)
    or ( v-c = yes and  buf_c-fbr-gds-grp.upper-code <> 0)
    on error undo, return error "Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = (if v-c = yes
                            then buf_c-fbr-gds-grp.node-name
                            else buf_fbr-gds-grp.node-name)
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = (if v-c
                            then buf_c-fbr-gds-grp.upper-code
                            else buf_fbr-gds-grp.upper-code)
        .
        find first buf_c-fbr-gds-grp no-lock
             where buf_c-fbr-gds-grp.obj-type  = p-obj-type
               AND buf_c-fbr-gds-grp.obj-code = p-obj-code
               AND buf_c-fbr-gds-grp.node-code = v-upper-code
               AND buf_c-fbr-gds-grp.chip-num  > p-chip-num
               AND buf_c-fbr-gds-grp.corr-user-db-num  = p-corr-user-db-num no-error .
        if not available buf_c-fbr-gds-grp then do:
          assign
          v-c = no
          .
          find first buf_fbr-gds-grp no-lock
              where buf_fbr-gds-grp.obj-type = p-obj-type
              AND buf_fbr-gds-grp.obj-code = p-obj-code
              AND buf_fbr-gds-grp.node-code = v-upper-code
          no-error.
          if not available buf_fbr-gds-grp
          then do:
              undo, return error substitute("Не найдена группа блюд с кодом &1 на объекте &2&3" +
                                             ". Ошибка ссылки в дереве товаров для записи истории групп товаров:" +
                                             "вн № &4, chip-num &5, БД-корректор &6"
                                            ,  v-upper-code
                                            , p-obj-type
                                            , p-obj-code
                                            , p-node-code
                                            , p-chip-num
                                            , p-corr-user-db-num).
          end.
        end.
        else do:
          assign
          v-c = yes
          .
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end procedure.
PROCEDURE err-mess:
  DEFINE INPUT-output PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      p-mess =
      substitute("История группы блюд  с вн кодом &1 &2&3: щепка &4 БД:&5 Предмет изменений &6&7&8"
                  ,p-node-code, p-obj-type, p-obj-code, p-chip-num, p-corr-user-db-num, p-subject
                  ,chr(10)
                  ,p-mess
                  ).
    end.
    otherwise do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
