block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: tl_tree.p $
$Archive: rep/tl_tree.p $

Строит дерево признаков для r-protcl.p

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

*/

define input  parameter Prt_Root   like doc-line.prt-root.
define input  parameter NodeCode   like gds-prt.node-code. /* node-code узла-хозяина*/
define input  parameter level      as   integer.           /* порядковый номер уровня в отстраиваемом дереве*/
define input  parameter NodeName   like gds-prt.node-name. /* node-name узла-хозяина*/
define input  parameter GdsName    like goods.gds-name.
define input  parameter GdsArtic   like goods.artic.
define output parameter Last_Level as   logical.

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: tl_tree.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/tl_tree.p $":U .
def var vss-description as character no-undo init "Строит дерево признаков для r-protcl.p".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ rep/tl-tree.i  }

def     var                         Last_Level_Work   as      logical.
def     var                         Item_Count             as      integer.
def     var                         rec_id                     as     RECID    NO-UNDO.



Item_Count = 0.
FOR EACH gds-prt WHERE gds-prt.upper-code = NodeCode NO-LOCK:
    Item_Count = Item_Count + 1.
    FIND LAST tl-tree NO-ERROR.
    create  tl-tree.
    assign
        tl-tree.upper-code = gds-prt.upper-code
        tl-tree.node-code = gds-prt.node-code
        tl-tree.node-name = gds-prt.node-name
        tl-tree.prt-num = gds-prt.prt-num
        tl-tree.uppernode-name = NodeName
        tl-tree.gds-amount = 0
        tl-tree.level-number = level
        tl-tree.gds-name = GdsName
        tl-tree.gds-artic = GdsArtic.

    rec_id = recid(tl-tree).
    if level < 2 then
        run rep/tl_tree.p (INPUT Prt_Root, INPUT gds-prt.node-code, INPUT  (level + 1),
                            INPUT gds-prt.node-name, INPUT  GdsName, INPUT  GdsArtic,
                            OUTPUT Last_Level_Work).
    else
        Last_Level_Work = yes.
    FIND FIRST tl-tree WHERE recid(tl-tree) = rec_id NO-ERROR.
    if available tl-tree then
        tl-tree.LastLevel = Last_Level_Work.
END.

/*Cущественно лишь при level = 1:*/
if Item_Count = 0 then
    Last_Level = yes.
else
    Last_Level = no.