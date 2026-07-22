block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rkepsyn3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rkepsyn3.p $":U .
define variable vss-description as character no-undo init "Синхронизация данных по персоналу в IBS TH с данными по персоналу кассе R-keeper".
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
define variable p-curr-obj-type like ub.clients.obj-type no-undo .
define variable p-curr-obj-code like ub.clients.obj-code no-undo .
define variable p-rid-list as character no-undo .
define variable p-options as character no-undo .
define variable log-file-name                as character      no-undo init "rkepsyn.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable ii as integer no-undo .
do
on error undo, return error return-value
:
  assign
  p-curr-obj-type      = entry(1, p-parameter, chr(4))
  p-curr-obj-code      = integer(entry(2, p-parameter, chr(4)))
  p-rid-list           = entry(3, p-parameter, chr(4))
  p-options            = entry(4, p-parameter, chr(4))
  no-error
  .
  if error-status:error then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute("Ошибка входных параметров &1:&2&3&4"
                          , p-parameter
                          , chr(10)
                          , error-status:get-message(1)
                          , return-value
                          )).
    assign
    v-view-log = yes.
    .
  end.
  do ii = 1 to num-entries(p-options):
    CASE entry(ii, p-options):
      when "name":U then do:
        run hide-counter in p-log-handle .
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("Синхронизация имен персонала на кассах R-KEEPER и в IBS TH....."
                              )).
        run str/rkepsync.p (
                           input parparentproc
                          ,input p-parent-handle
                          ,input p-log-handle
                          ,input p-rid-list
                          ,input p-curr-obj-type
                          ,input p-curr-obj-code
                       ) no-error .
      end.
    END CASE.
    if error-status:error then do:
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute("!!!! Ошибка выполнения!&1&2 &3"
                              , chr(10)
                              , error-status:get-message(1)
                              , return-value
                              )).
    end.
  end.
end.
