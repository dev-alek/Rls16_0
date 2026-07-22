/*
$Revision:$
$Author:$
$Date:$
$Workfile:$
$Archive:$

Автор: Рукавишников Вадим
Дата создания: 27.04.2021
Author: Rukavishnikov Vadim
Creation date: 27.04.2021

*/

block-level on error undo, throw.
{cmp/str-glbl.i }
{ ibs\th\ref\code\codefrmpar.i }

define variable vss-revision    as character no-undo init "$Revision:$":U .
define variable vss-author      as character no-undo init "$Author:$":U .
define variable vss-date        as character no-undo init "$Date:$":U .
define variable vss-workfile    as character no-undo init "$Workfile:$":U .
define variable vss-archive     as character no-undo init "$Archive:$":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
   define variable v-ok as logical no-undo.
   define buffer b-code for code.
&Scoped-define CODE_PARENT iCodeTrg:parent
def var ref-list as  char no-undo.
def var vi       as  int no-undo.
run ref/gds-ref.p ( input iParparentproc
                              , input "b-sel,b-mark":U
                              , input ?                     /*p-stat */
                              , input ?                     /*p-list  */
                              , input ?                     /*p-cond  */
                              , input ?                     /*p-rec   */
                              , input ?                    /*p-grp   */
                              , input ?                     /*p-cli-type */
                              , input ?                     /*p-cli-code  */
                              , input ?                     /*p-obj-type  */
                              , input ?                      /*p-obj-code  */
                              , input ?                     /*p-other     */
                              , OUTPUT ref-list ).
IF ref-list <> "":U 
THEN DO vi = 1 to num-entries(ref-list):
    find first goods where recid( goods) eq int64(entry(vi,ref-list))
    no-lock no-error.
    if avail goods
    then do:
       find first code where code.parent = "TiketPrint" 
                      and code.code = string(goods.gds-code)
       no-lock no-error.
       if not avail code
       then do:
          create code.
          assign 
             code.code     = string(goods.gds-code)
             code.CodeName = goods.gds-name
             code.parent   = "TiketPrint" 
             Code.CodeValue = "1"
          .
          osave = no.
      end.
      else decimal(Code.CodeValue) = decimal(Code.CodeValue) + 1 .
   end.
end.
          