block-level on error undo, throw.
define variable FullFileName  as character no-undo.
define variable v-param       as character no-undo .
define variable ind           as integer   no-undo .
define variable v-num-entries as integer   no-undo .
define variable v-msg         as character no-undo .
define stream   s-imp.
if session:parameter <> "":U
  and session:parameter <> ?
then do:
  assign
    v-num-entries = num-entries( session:parameter, ",":U )
  .
  do ind = 1 to v-num-entries :
    assign
      v-param = entry( ind, session:parameter, ",":U )
    .
      if v-param begins 'FullFileName' then do:
        assign
          FullFileName = entry( 2, v-param, "?":U )
        .
      end.
  end.
end.
if FullFileName = ? or FullFileName = ""
  then quit.
input stream s-imp from value( FullFileName ) .
import stream s-imp unformatted v-msg no-error .
message v-msg view-as alert-box information title "Информация.".
quit.
