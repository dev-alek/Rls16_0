block-level on error undo, throw.
define input  parameter h_current-procedure as handle    no-undo .
define variable v-start-level as integer no-undo .
define variable lok           as logical no-undo initial yes .
define variable level         as integer no-undo .
define variable vdebugalert   as logical no-undo .
define variable vss-revision    as character no-undo .
define variable vss-author      as character no-undo .
define variable vss-date        as character no-undo .
define variable vss-workfile    as character no-undo .
define variable vss-archive     as character no-undo .
define variable vss-description as character no-undo .
assign
  v-start-level = 2
  vdebugalert = session:debug-alert
  session:debug-alert = yes
.
if valid-handle( h_current-procedure )
and h_current-procedure :get-signature( 'vss-get-info':U ) <> ""
then do:
  run vss-get-info in h_current-procedure
    ( output vss-revision
    , output vss-author
    , output vss-date
    , output vss-workfile
    , output vss-archive
    , output vss-description
    ).
  message program-name( v-start-level ) skip( 1 )
          vss-revision                  skip( 0 )
          vss-author                    skip( 0 )
          vss-date                      skip( 0 )
          vss-workfile                  skip( 0 )
          vss-archive                   skip( 1 )
          vss-description               skip( 1 )
  view-as alert-box buttons ok-cancel title "Текущая программа" update lok  .
  if not lok then do:
    return no-apply .
  end.
end.
else do:
  message
    program-name( v-start-level ) skip
  view-as alert-box buttons ok-cancel title "Текущая программа" update lok  .
end.
assign
  level = v-start-level
.
repeat while program-name( level ) <> ? :
  message
    level program-name( level ) skip
    view-as alert-box buttons ok-cancel update lok .
  if not lok then do:
    return no-apply .
  end.
  assign
    level = level + 1
  .
end.
finally:
   session:debug-alert = vdebugalert.
end finally.
