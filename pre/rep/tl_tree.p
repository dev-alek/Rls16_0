block-level on error undo, throw.
define input  parameter Prt_Root   like doc-line.prt-root.
define input  parameter NodeCode   like gds-prt.node-code.
define input  parameter level      as   integer.
define input  parameter NodeName   like gds-prt.node-name.
define input  parameter GdsName    like goods.gds-name.
define input  parameter GdsArtic   like goods.artic.
define output parameter Last_Level as   logical.
def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: tl_tree.p $":U .
def var vss-archive     as character no-undo init "$Archive: rep/tl_tree.p $":U .
def var vss-description as character no-undo init "Строит дерево признаков для r-protcl.p".
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
define variable vss-include-info0 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
def    shared    work-table  tl-tree     no-undo
    field   upper-code              like    gds-prt.upper-code
    field   node-code               like    gds-prt.node-code
    field   node-name              like    gds-prt.node-name
    field   uppernode-name     like    gds-prt.node-name
    field   price-base               like    gds-dtl.price-base
    field   price-rubl                 like    gds-dtl.price-rubl
    field   discnt-base              like    gds-dtl.discnt-base
    field   discnt-rubl               like    gds-dtl.discnt-rubl
    field   b-code                     as       char
    field   gds-amount             as      integer
    field   level-number           as      integer
    field   prt-num                   like    gds-prt.prt-num
    field   gds-name                like    goods.gds-name
    field   gds-artic                  like    goods.artic
    field   LastLevel                as      logical     init    no
    .
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
if Item_Count = 0 then
    Last_Level = yes.
else
    Last_Level = no.
