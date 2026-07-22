block-level on error undo, throw.
&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*------------------------------------------------------------------------


$Revision: ecc773e5a8dc, 1421, test $
$Author: EShklyar $
$Date: Fri Jun 29 17:59:55 2018 +0300 $
$Workfile: egais-marks.p $
$Archive: bge/egais-marks.p $

Интерфейс для расшифровки акцизной марки

Автор: Шкляр Елена 
Дата создания: 01/16/07
Author: Elena Shklyar
Creation date: 01/16/07

          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

/*using ibs.th.bge.egais.*.*/
/* Parameters Definitions ---                                           */
define input parameter parparentproc  as widget-handle no-undo .

/*define variable v-proc-name-err    as character    no-undo.*/

/* Local Variable Definitions ---                                       */

define variable vss-revision    as character no-undo init "$Revision: ecc773e5a8dc, 1421, test $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Fri Jun 29 17:59:55 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: egais-marks.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/egais-marks.p $":U .
define variable vss-description as character no-undo init "Интерфейс для расшифровки акцизной марки".

{ibs/th/bge/egais/ab-egais.i 1 new shared}
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
 main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  run bge/egais-ab-marks.w (
  input parparentproc ,
  input ""  ,
  input 0   ,
  input ""  ,
  input 0   ,
  input {&update} ,
  input-output table tt-marks
  ) .

end.