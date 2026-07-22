&if defined (tmprecid_i_def) eq 0
&then
&glob tmprecid_i_def yes
{cmp/str-glbl.i}
 define {1} temp-table tmprecid 
    field Frecid as recid init ?
    field fnum as character
    field fTable as character
 index num  fnum Frecid
 index itable is primary unique fTable Frecid  
 .
define variable fSelect as logical no-undo format "*/" column-label "".
{ def/funcmet.i isSelect logical }
    (iBuffer as handle  ):
    define buffer tmprecid for tmprecid.
    if iBuffer:available
    then
       find first tmprecid where tmprecid.fTable = iBuffer:TABLE
                             and tmprecid.Frecid = iBuffer:recid
       no-lock no-error.
    return available tmprecid.
 end.

{ def/funcmet.i  setSelect logical }
    (iBuffer as handle  ):
    define buffer tmprecid for tmprecid.
    if iBuffer:available
    then do:
       find first tmprecid where tmprecid.fTable = iBuffer:TABLE
                             and tmprecid.Frecid = iBuffer:recid
       no-lock no-error.
       if available tmprecid
       then
          delete tmprecid.
       else do:
          create tmprecid.
          assign
             tmprecid.fTable = iBuffer:TABLE
             tmprecid.Frecid = iBuffer:recid
          .
       end.
    end.
    return available tmprecid.
 end.
 {&CommentStartClass}
 procedure rid-keep :
     run gbl/rid-keep.p (input table tmprecid) no-error.
 end.

 procedure rid-rest :
      run gbl/rid-rest.p (output table tmprecid) no-error.
 end.
 {utl/comment.i} */
&endif