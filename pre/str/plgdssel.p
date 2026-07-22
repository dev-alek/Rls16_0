block-level on error undo, throw.
define  input parameter p-parent-proc as   widget-handle      no-undo .
define  input parameter p-obj-type    like ub.pl-gds.obj-type no-undo .
define  input parameter p-obj-code    like ub.pl-gds.obj-code no-undo .
define  input parameter p-gds-code    like ub.pl-gds.gds-code no-undo .
define output parameter p-pl-code     like ub.pl-gds.pl-code  no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: plgdssel.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/plgdssel.p $":U .
define variable vss-description as character no-undo initial "выбор складского места":U .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable v_rid-list as character no-undo .
define variable is-petrol  as logical   no-undo .
define variable is-pieces  as logical   no-undo .
define buffer bf_goods  for ub.goods .
define buffer bf_pl-gds for ub.pl-gds .
assign
  p-pl-code = 0
.
find first bf_goods no-lock where
           bf_goods.gds-code = p-gds-code no-error .
if not available bf_goods
then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
          "Не найден товар" skip( 0 )
          "Первичный бар-код" p-gds-code "." skip( 1 )
  view-as alert-box error .
  undo, return error .
end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_goods.artic
  ,  input bf_goods.prod-type
  ,  input bf_goods.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
if error-status :error
then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
          "Ошибка при вызове программы lib-trn_is-petrl" skip( 0 )
          error-status :get-message( 1 ) skip( 0 )
          return-value skip( 1 )
  view-as alert-box error .
  undo, return error .
end.
run ref/pl-gdss.w
  (  input p-parent-proc
  ,  input "b-sel"
  ,  input p-obj-type
  ,  input p-obj-code
  ,  input ( if is-petrol = yes and is-pieces = no then 'топ':U else 'ТОВАР':U )
  ,  input recid( bf_goods )
  ,  input ?
  , output v_rid-list
  ) no-error .
if error-status :error
then do:
  message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
          "Ошибка при вызове программы pl-gdss.w" skip( 0 )
          error-status :get-message( 1 ) skip( 0 )
          return-value skip( 1 )
  view-as alert-box error .
  undo, return error .
end.
if v_rid-list <> ?    and
   v_rid-list <> "":U
then do:
  find first bf_pl-gds no-lock where
      recid( bf_pl-gds ) = integer( entry( 1, v_rid-list ) ) no-error .
  if available bf_pl-gds
  then do:
    assign
      p-pl-code = bf_pl-gds.pl-code
    .
  end.
end.
