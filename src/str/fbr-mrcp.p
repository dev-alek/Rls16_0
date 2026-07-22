block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fbr-mrcp.p $
$Archive: str/fbr-mrcp.p $

Вычисление требуемого количества и производимого количеств по одному товару по всем рецептам.

Автор: Белоусов Илья Александрович
Дата создания: 09/08/05
Author: Ilia Belousov
Creation date: 09/08/05

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fbr-mrcp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/fbr-mrcp.p $":U .
define variable vss-description as character no-undo init "Вычисление требуемого количества и производимого количеств по одному товару по всем рецептам.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define input parameter p-gds-code           as integer                      no-undo. /* товар */
define input parameter p-fbr-doc-doc-code   as character                    no-undo. /* документ производства */
define output parameter p-required-qnty     like fbr-line.fact-qnty init 0  no-undo. /* требуемое количество */
define output parameter p-available-qnty    like fbr-line.fact-qnty init 0  no-undo. /* производимое количество */

    define buffer buf_fbr-line  for fbr-line.
    define buffer buf_goods     for goods.
do
for buf_fbr-line
  , buf_goods
on error undo, return error
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    for each buf_fbr-line
       where buf_fbr-line.doc-code  = p-fbr-doc-doc-code
         and buf_fbr-line.artic     = buf_goods.artic
         and buf_fbr-line.prod-type = buf_goods.prod-type
         and buf_fbr-line.prod-code = buf_goods.prod-code
    :
        if buf_fbr-line.trn-type = {&write-off}
        then do:
            assign
                p-required-qnty = p-required-qnty + buf_fbr-line.fact-qnty
            .
        end.
        else do:
            assign
                p-available-qnty = p-available-qnty + buf_fbr-line.fact-qnty
            .
        end.
    end.
end.