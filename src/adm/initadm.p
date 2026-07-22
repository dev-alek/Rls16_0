block-level on error undo, throw.
define input  parameter inst     as logical   no-undo . /* YES - вопросы задавать */
define input  parameter p-create-adm as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: fe6ab15d03ae, 2740, rls $":U .
define variable vss-author      as character no-undo init "$Author: Ostroukhov $":U .
define variable vss-date        as character no-undo init "$Date: —б фев 20 15:59:20 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: initadm.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/initadm.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
find first sys-ctrl.
run adm\init-adm.p(inst,sys-ctrl.db-num,p-create-adm). 