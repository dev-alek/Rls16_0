block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .

define variable mDraw-util as class ibs.th.utl.draw_utility no-undo.
mDraw-util = new ibs.th.utl.draw_utility().
mDraw-util:parparentproc = parparentproc.
wait-for  mDraw-util:ShowDialog() .
delete object mDraw-util.