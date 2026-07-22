&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12 GUI
&ANALYZE-RESUME
&Scoped-define WINDOW-NAME CURRENT-WINDOW
&Scoped-define FRAME-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Dialog-Frame 
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Настройки для ПЕЧАТНЫХ ФОРМ

Автор: Чернова Светлана Александровна
Дата создания: 07/04/07
Author: Svetlana Chernova
Creation date: 07/04/07

This .W file was created with the Progress AppBuilder.

*/

define input parameter parparentproc as widget-handle no-undo.
define input parameter p-mode        as character no-undo.
define input parameter p-obj-type    like ub.clients.obj-type no-undo.
define input parameter p-obj-code    like ub.shop.obj-code no-undo.
define input parameter p-type        as char no-undo.

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-Workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Настройки для ПЕЧАТНЫХ ФОРМ" .
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ gbl/thbjattr.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/onewin.i   }
{ gbl/twowin.i   }
{ str/lib-trn.i  }

define temp-table temp_twowin_itemsSelected_col no-undo
    field its-key   as integer
    field itm-key   as integer
    field itmExtKey as character

    index pi is primary unique
      its-key
    index im
      itm-key
.
define variable v-list-edt-full as character    no-undo.
define variable v-list-edt      as character    no-undo.


define buffer obj_thbj-attr for ub.thbj-attr.
define buffer glb_thbj-attr for ub.thbj-attr.
define buffer frm_thbj-attr for ub.thbj-attr.
define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
define variable v-ttho     as handle no-undo .
define variable v-tthg    as handle no-undo .
define variable v-tthf    as handle no-undo .
define variable v-to-create as logical no-undo.
define variable v-to-create-prt as logical no-undo.
define variable v-to-create-prt-g as logical no-undo.
define variable v-to-create-prt-f as logical no-undo.
define variable str-attr as character no-undo .
define temp-table thbjattr_thbj-attr-o no-undo like thbjattr_thbj-attr .
define temp-table thbjattr_thbj-attr-g no-undo like thbjattr_thbj-attr .
define temp-table thbjattr_thbj-attr-f no-undo like thbjattr_thbj-attr .
define variable v-obj-type  as character no-undo .
define variable v-obj-code as integer   no-undo .
define variable v-host-code as integer   no-undo .
define variable fl as character no-undo .
define variable v-twowin-point as character no-undo .

/* Поля для assign НЕЗАБЫТЬ ДОБАВИТЬ СУДА НОВЫЕ !!! */

/*&Scoped-define page-1p  fgdsnind  invprn0 ~                                  */
/*outprncd outdisc  outegrp outobj outappr outdate outnum  ~                   */
/*sort-prd outhold  outsubs  torg2-no outt12 ~                                 */
/*outprim outrubl outrecv  outares outsend outprops ~                          */
/*outasend rep-artic                                                           */
/*                                                                             */
/*&Scoped-define page-2p outssdoc factur01 incurrat tick-w in-docpr  outrecv  ~*/
/*sort-prd torg2-no outprops outR outB outogr outC rep-artic                   */

assign
v-ttho = buffer thbjattr_thbj-attr-o:table-handle .
v-tthg = buffer thbjattr_thbj-attr-g:table-handle .
v-tthf = buffer thbjattr_thbj-attr-f:table-handle .
 if g#db-num <> 0 and p-obj-type = "" and  p-obj-code = 0
    then p-mode = {&lookup} .

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Dialog-Box
&Scoped-define DB-AWARE no

/* Name of designated FRAME-NAME and/or first browse and/or first query */
&Scoped-define FRAME-NAME Dialog-Frame

/* Standard List Definitions                                            */
&Scoped-Define ENABLED-OBJECTS B-exit B-quit B-Help ~
I-fgdsnind I-in-docpr I-outdisc I-outegrp I-outappr I-outdate I-outhold ~
I-outnum I-outobj I-invprn0 I-outrecv I-outprncd I-sort-prd I-torg2-no ~
I-outprim I-outrubl I-outssdoc I-outsubs I-outt12 RECT-2 I-factur01 ~
I-incurrat I-tick-w I-outares I-outsend I-outprops I-outasend I-outR ~
I-outogr I-outb I-outc B-20 B-1 fgdsnind outssdoc invprn0 outprncd B-14 ~
factur01 B-15 incurrat B-16 tick-w B-2 in-docpr B-3 outdisc B-outdisc ~
outegrp B-outegrp B-outrecv outrecv B-4 B-9 outobj B-outobj B-5 outappr ~
B-outappr B-6 outdate B-outdate sort-prd B-8 outnum B-outnum torg2-no B-7 ~
outhold B-outhold outprops B-12 outsubs B-outsubs B-24 outR B-25 B-13 ~
outt12 B-outt12 outogr outprim B-outprim B-26 B-18 outb B-19 B-27 outrubl ~
B-outrubl outc outares B-outares B-21 B-22 outsend B-outsend B-23 outasend ~
B-outasend FILL-IN-4 v-fgdsnind v-outssdoc v-invprn0 ~
v-outprncd v-factur01 v-incurrat v-tick-w v-in-docpr FILL-IN-1 v-outdisc ~
v-outegrp v-outrecv v-outobj v-outappr v-outdate v-sort-prd v-outnum ~
v-torg2-no v-outhold v-outprops v-outsubs v-outR v-outogr v-outt12 ~
v-outprim v-outb v-outc v-outrubl v-outares v-outsend v-outasend ~
rep-artic I-rep-artic v-rep-artic
&Scoped-Define DISPLAYED-OBJECTS fgdsnind outssdoc invprn0 outprncd ~
factur01 incurrat tick-w in-docpr outdisc outegrp outrecv outobj outappr ~
outdate sort-prd outnum torg2-no outhold outprops outsubs outR outt12 ~
outogr outprim outb outrubl outc outares outsend outasend ~
FILL-IN-4 v-fgdsnind v-outssdoc v-invprn0 v-outprncd v-factur01 ~
v-incurrat v-tick-w v-in-docpr FILL-IN-1 v-outdisc v-outegrp v-outrecv ~
v-outobj v-outappr v-outdate v-sort-prd v-outnum v-torg2-no v-outhold ~
v-outprops v-outsubs v-outR v-outogr v-outt12 v-outprim v-outb v-outc ~
v-outrubl v-outares v-outsend v-outasend rep-artic v-rep-artic

/* Custom List Definitions                                              */
/* page-1,page-2,no-dis,List-4,List-5,List-6                            */
&Scoped-define I-fgdsnind I-outdisc I-outegrp I-outappr I-outdate ~
I-outhold I-outnum I-outobj I-invprn0 I-outprncd I-outprim I-outrubl ~
I-outsubs I-outt12 I-outares I-outsend I-outasend B-1 fgdsnind invprn0 ~
outprncd B-3 outdisc B-outdisc outegrp B-outegrp B-4 B-9 outobj B-outobj ~
B-5 outappr B-outappr B-6 outdate B-outdate B-8 outnum B-outnum B-7 outhold ~
B-outhold B-12 outsubs B-outsubs B-13 outt12 B-outt12 outprim B-outprim ~
B-18 B-19 outrubl B-outrubl outares B-outares B-21 B-22 outsend B-outsend ~
B-23 outasend B-outasend v-fgdsnind v-invprn0 v-outprncd FILL-IN-1 ~
v-outdisc v-outegrp v-outobj v-outappr v-outdate v-outnum v-outhold ~
v-outsubs v-outt12 v-outprim v-outrubl v-outares v-outsend v-outasend ~
I-in-docpr I-outrecv I-sort-prd I-torg2-no I-outssdoc ~
I-factur01 I-incurrat I-tick-w I-outprops I-outR I-outogr I-outb I-outc ~
B-20 outssdoc B-14 factur01 B-15 incurrat B-16 tick-w B-2 in-docpr ~
B-outrecv outrecv sort-prd torg2-no outprops B-24 B-25 B-26 B-27 v-outssdoc ~
v-factur01 v-incurrat v-tick-w v-in-docpr v-outrecv v-sort-prd v-torg2-no ~
v-outprops v-outR v-outogr v-outb v-outc rep-artic I-rep-artic v-rep-artic
&Scoped-define no-dis B-exit B-quit B-Help 

/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME



/* ***********************  Control Definitions  ********************** */

/* Define a dialog box                                                  */

/* Definitions of the field level widgets                               */
DEFINE BUTTON B-1 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-12 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-13 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-14 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-15 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-16 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-18 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-19 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-2 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-20 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-21 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-22 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-23 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-24 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-25 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-26 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-27 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-3 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-4 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-5 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-6 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-7 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-8 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-9 
     IMAGE-UP FILE "cmp/btn-ref.bmp":U
     LABEL "" 
     SIZE 3 BY .92.

DEFINE BUTTON B-exit AUTO-GO 
     LABEL "&Ввод" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-Help 
     LABEL "&Help" 
     SIZE 3 BY 1
     BGCOLOR 8 .

DEFINE BUTTON B-outappr 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-outares 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-outasend 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-outdate 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-outdisc 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-outegrp 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-outhold 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-outnum 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-outobj 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-outprim 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-outrecv 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "B-outrecv" 
     SIZE 3 BY 1 TOOLTIP "Список типов единиц измерений".

DEFINE BUTTON B-outrubl 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-outsend 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-outsubs 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-outt12 
     IMAGE-UP FILE "cmp/update.bmp":U
     LABEL "" 
     SIZE 3 BY 1.

DEFINE BUTTON B-quit AUTO-END-KEY 
     LABEL "&Отмена" 
     SIZE 10 BY 1
     BGCOLOR 8 .

DEFINE VARIABLE outappr AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE outares AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE outasend AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE outdate AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE outdisc AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE outegrp AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE outhold AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE outnum AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE outobj AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE outprim AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE outrecv AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 45.25 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE outrubl AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE outsend AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE outsubs AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE outt12 AS CHARACTER 
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 10 BY 1
     FONT 4 NO-UNDO.

DEFINE VARIABLE FILL-IN-1 AS CHARACTER FORMAT "X(256)":U INITIAL "Список печатных форм, для которых :" 
      VIEW-AS TEXT 
     SIZE 35.63 BY .67
     BGCOLOR 3 FGCOLOR 15  NO-UNDO.

DEFINE VARIABLE FILL-IN-4 AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 26 BY 1 NO-UNDO.

DEFINE VARIABLE in-docpr AS CHARACTER FORMAT "X(256)":U 
     VIEW-AS FILL-IN 
     SIZE 14 BY 1 NO-UNDO.

DEFINE VARIABLE v-factur01 AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 91.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-fgdsnind AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 70.63 BY .92 NO-UNDO.

DEFINE VARIABLE v-in-docpr AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 80.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-incurrat AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 91.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-invprn0 AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 93.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-outappr AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 59.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-outares AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 82.25 BY .79 NO-UNDO.

DEFINE VARIABLE v-outasend AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 80 BY .79 NO-UNDO.

DEFINE VARIABLE v-outb AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 34.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-outc AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 38.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-outdate AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 20.75 BY .79 NO-UNDO.

DEFINE VARIABLE v-outdisc AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 80.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-outegrp AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 31.75 BY .79 NO-UNDO.

DEFINE VARIABLE v-outhold AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 59 BY .79 NO-UNDO.

DEFINE VARIABLE v-outnum AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 30.75 BY .79 NO-UNDO.

DEFINE VARIABLE v-outobj AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 62 BY .79 NO-UNDO.

DEFINE VARIABLE v-outogr AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 34.63 BY .92 NO-UNDO.

DEFINE VARIABLE v-outprim AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 80 BY .79 NO-UNDO.

DEFINE VARIABLE v-outprncd AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 93.25 BY 1 NO-UNDO.

DEFINE VARIABLE v-outprops AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 80 BY .79 NO-UNDO.

DEFINE VARIABLE v-outR AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 34.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-outrecv AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 48.25 BY .79 NO-UNDO.

DEFINE VARIABLE v-outrubl AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 82.25 BY .79 NO-UNDO.

DEFINE VARIABLE v-outsend AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 80 BY .79 NO-UNDO.

DEFINE VARIABLE v-outssdoc AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 49 BY .92 NO-UNDO.

DEFINE VARIABLE v-outsubs AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 80 BY .79 NO-UNDO.

DEFINE VARIABLE v-outt12 AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 82.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-rep-artic AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 80 BY .79 NO-UNDO.

DEFINE VARIABLE v-sort-prd AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 80 BY .79 NO-UNDO.

DEFINE VARIABLE v-tick-w AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 91.63 BY .79 NO-UNDO.

DEFINE VARIABLE v-torg2-no AS CHARACTER FORMAT "X(256)":U 
      VIEW-AS TEXT 
     SIZE 80 BY .79 NO-UNDO.

DEFINE IMAGE I-factur01
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-fgdsnind
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-in-docpr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-incurrat
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-invprn0
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outappr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outares
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outasend
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outb
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outc
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outdate
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .92.

DEFINE IMAGE I-outdisc
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outegrp
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outhold
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outnum
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outobj
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outogr
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outprim
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outprncd
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outprops
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outR
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outrecv
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outrubl
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outsend
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outssdoc
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .92.

DEFINE IMAGE I-outsubs
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-outt12
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-rep-artic
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-sort-prd
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-tick-w
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE IMAGE I-torg2-no
     FILENAME "cmp/info.bmp":U
     SIZE 3 BY .79.

DEFINE VARIABLE outb AS CHARACTER INITIAL "no_print" 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "no_print",
"Item 2", "2",
"Item 3", "3"
     SIZE 54.25 BY .79
     FONT 4 NO-UNDO.

DEFINE VARIABLE outc AS CHARACTER INITIAL "clad_doc" 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "no_print",
"Item 2", "2",
"Item 3", "3"
     SIZE 54.25 BY .79
     FONT 4 NO-UNDO.

DEFINE VARIABLE outogr AS CHARACTER INITIAL "no_print" 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "no_print",
"Item 2", "2",
"Item 3", "3"
     SIZE 60 BY .79
     FONT 4 NO-UNDO.

DEFINE VARIABLE outR AS CHARACTER INITIAL "no_print" 
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS 
          "Item 1", "no_print",
"Item 2", "2",
"Item 3", "3"
     SIZE 54.25 BY .79
     FONT 4 NO-UNDO.

DEFINE VARIABLE outssdoc AS CHARACTER 
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS 
          "Накладная", "nacl",
"Фин.док-т", "findoc",
"Пусто", ""
     SIZE 20 BY 2
     FONT 4 NO-UNDO.

DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL  GROUP-BOX  
     SIZE 97 BY .75.

DEFINE VARIABLE factur01 AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2.5 BY .79 NO-UNDO.

DEFINE VARIABLE fgdsnind AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 3 BY .92 NO-UNDO.

DEFINE VARIABLE incurrat AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY .79 NO-UNDO.

DEFINE VARIABLE invprn0 AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 39 BY .79 NO-UNDO.

DEFINE VARIABLE outprncd AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 50 BY 1 NO-UNDO.

DEFINE VARIABLE outprops AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 32.63 BY .79 NO-UNDO.

DEFINE VARIABLE rep-artic AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 47.25 BY .79 NO-UNDO.

DEFINE VARIABLE sort-prd AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 47.25 BY .79 NO-UNDO.

DEFINE VARIABLE tick-w AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 2 BY .79 NO-UNDO.

DEFINE VARIABLE torg2-no AS LOGICAL INITIAL no 
     LABEL "" 
     VIEW-AS TOGGLE-BOX
     SIZE 32.63 BY .79 NO-UNDO.


/* ************************  Frame Definitions  *********************** */

DEFINE FRAME Dialog-Frame
/*общие*/
     B-exit AT ROW 1 COL 1
     B-quit AT ROW 1 COL 11
     B-Help AT ROW 1 COL 95
     RECT-2 AT ROW 2 COL 3.63 WIDGET-ID 346
     FILL-IN-4 AT ROW 2.25 COL 73 COLON-ALIGNED NO-LABEL WIDGET-ID 352
/*глобальные*/
     invprn0 AT ROW 3 COL 4.63 WIDGET-ID 134
     outprncd AT ROW 3.75 COL 5 WIDGET-ID 148
     I-invprn0 AT ROW 3 COL 1.63 WIDGET-ID 136
     I-outprncd AT ROW 3.79 COL 1.63 WIDGET-ID 146
     v-invprn0 AT ROW 3 COL 6.63 NO-LABEL WIDGET-ID 138
     v-outprncd AT ROW 3.75 COL 7.25 NO-LABEL WIDGET-ID 150    
     B-outrecv AT ROW 10.21 COL 48.75 WIDGET-ID 154
     outrecv AT ROW 10.25 COL 2.75 NO-LABEL WIDGET-ID 152
     v-outrecv AT ROW 10.21 COL 51.75 NO-LABEL WIDGET-ID 144
     I-outrecv AT ROW 10.29 COL 1 WIDGET-ID 142
     I-sort-prd AT ROW 13.25 COL 1 WIDGET-ID 162
     rep-artic AT ROW 12.25 COL 2.75 WIDGET-ID 480
     v-rep-artic AT ROW 12.25 COL 6 NO-LABEL WIDGET-ID 482
     I-rep-artic AT ROW 12.25 COL 1 WIDGET-ID 484
     outprops AT ROW 15.25 COL 2.75 WIDGET-ID 416
     v-outprops AT ROW 15.25 COL 5.25 NO-LABEL WIDGET-ID 418
     I-outprops AT ROW 15.25 COL 1 WIDGET-ID 414
     sort-prd AT ROW 13.25 COL 2.75 WIDGET-ID 164
     torg2-no AT ROW 14.25 COL 2.75 WIDGET-ID 286
     v-sort-prd AT ROW 13.25 COL 6 NO-LABEL WIDGET-ID 166
     v-torg2-no AT ROW 14.25 COL 6 NO-LABEL WIDGET-ID 216
     I-torg2-no AT ROW 14.25 COL 1 WIDGET-ID 212
                 
/*фирма*/
     B-14 AT ROW 3.58 COL 2.75 WIDGET-ID 354
     factur01 AT ROW 3.58 COL 6 WIDGET-ID 358
     B-15 AT ROW 4.46 COL 2.75 WIDGET-ID 362
     incurrat AT ROW 4.46 COL 6 WIDGET-ID 364
     B-16 AT ROW 5.33 COL 2.75 WIDGET-ID 370
     tick-w AT ROW 5.33 COL 6 WIDGET-ID 374
     FILL-IN-4 AT ROW 2.25 COL 73 COLON-ALIGNED NO-LABEL WIDGET-ID 352
     v-factur01 AT ROW 3.58 COL 9.63 NO-LABEL WIDGET-ID 360
     v-incurrat AT ROW 4.46 COL 7.63 COLON-ALIGNED NO-LABEL WIDGET-ID 368
     v-tick-w AT ROW 5.33 COL 9.63 NO-LABEL WIDGET-ID 376
     RECT-2 AT ROW 2 COL 3.63 WIDGET-ID 346
     I-factur01 AT ROW 3.58 COL 1 WIDGET-ID 356
     I-incurrat AT ROW 4.46 COL 1 WIDGET-ID 366
     I-tick-w AT ROW 5.33 COL 1 WIDGET-ID 372

/*объетные*/     
     B-1 AT ROW 2.21 COL 3 WIDGET-ID 392
     fgdsnind AT ROW 2.21 COL 6 WIDGET-ID 236
     v-fgdsnind AT ROW 2.21 COL 21 NO-LABEL WIDGET-ID 6
     I-fgdsnind AT ROW 2.21 COL 1 WIDGET-ID 10
     
     B-20 AT ROW 3.25 COL 3 WIDGET-ID 80
     outssdoc AT ROW 3.25 COL 57.5 NO-LABEL WIDGET-ID 280
     v-outssdoc AT ROW 3.25 COL 6 NO-LABEL WIDGET-ID 234
     I-outssdoc AT ROW 3.29 COL 1 WIDGET-ID 230

     B-2 AT ROW 5.75 COL 3 WIDGET-ID 82
     in-docpr AT ROW 5.75 COL 6 NO-LABEL WIDGET-ID 238
     I-in-docpr AT ROW 5.79 COL 1 WIDGET-ID 34
     v-in-docpr AT ROW 5.75 COL 21 NO-LABEL WIDGET-ID 18

     B-24 AT ROW 7 COL 3 WIDGET-ID 430
     outR AT ROW 7 COL 48 NO-LABEL WIDGET-ID 438
     v-outR AT ROW 7 COL 6 NO-LABEL WIDGET-ID 436
     I-outR AT ROW 7.04 COL 1 WIDGET-ID 432

     B-26 AT ROW 9.88 COL 3 WIDGET-ID 388
     outb AT ROW 9.88 COL 48 NO-LABEL WIDGET-ID 456
     v-outb AT ROW 9.88 COL 6 NO-LABEL WIDGET-ID 460 DISABLE-AUTO-ZAP
     I-outb AT ROW 9.92 COL 1 WIDGET-ID 454
     
     B-25 AT ROW 7.92 COL 3 WIDGET-ID 326
     outogr AT ROW 7.92 COL 48 NO-LABEL WIDGET-ID 446
     v-outogr AT ROW 7.92 COL 6 NO-LABEL WIDGET-ID 450
     I-outogr AT ROW 7.96 COL 1 WIDGET-ID 444
     
     B-27 AT ROW 8.92 COL 3 WIDGET-ID 462
     outc AT ROW 8.92 COL 48 NO-LABEL WIDGET-ID 466
     v-outc AT ROW 8.92 COL 6 NO-LABEL WIDGET-ID 464 DISABLE-AUTO-ZAP 
     I-outc AT ROW 8.96 COL 1 WIDGET-ID 470

     B-3 AT ROW 11.96 COL 3 WIDGET-ID 84
     outdisc AT ROW 11.96 COL 6 NO-LABEL WIDGET-ID 240
     v-outdisc AT ROW 12.04 COL 19 NO-LABEL WIDGET-ID 54
     I-outdisc AT ROW 12 COL 1 WIDGET-ID 50
     B-outdisc AT ROW 11.96 COL 15.75 WIDGET-ID 250

     B-4 AT ROW 12.96 COL 3 WIDGET-ID 86
     outegrp AT ROW 12.96 COL 6 NO-LABEL WIDGET-ID 242
     B-outegrp AT ROW 12.96 COL 15.75 WIDGET-ID 248
     v-outegrp AT ROW 13.04 COL 19 NO-LABEL WIDGET-ID 60
     I-outegrp AT ROW 13.04 COL 1 WIDGET-ID 56

     B-9 AT ROW 13.96 COL 3 WIDGET-ID 108
     outobj AT ROW 13.96 COL 6 NO-LABEL WIDGET-ID 252
     B-outobj AT ROW 13.96 COL 15.75 WIDGET-ID 254
     v-outobj AT ROW 14.04 COL 19 NO-LABEL WIDGET-ID 114
     I-outobj AT ROW 14 COL 1 WIDGET-ID 110

     B-5 AT ROW 14.96 COL 3 WIDGET-ID 88
     outappr AT ROW 14.96 COL 6 NO-LABEL WIDGET-ID 256
     B-outappr AT ROW 14.96 COL 15.75 WIDGET-ID 258
     v-outappr AT ROW 15.04 COL 19 NO-LABEL WIDGET-ID 66
     I-outappr AT ROW 15 COL 1 WIDGET-ID 64
  
     B-6 AT ROW 15.96 COL 3 WIDGET-ID 90
     outdate AT ROW 15.96 COL 6 NO-LABEL WIDGET-ID 262
     B-outdate AT ROW 15.96 COL 15.75 WIDGET-ID 260
     v-outdate AT ROW 16.04 COL 19 NO-LABEL WIDGET-ID 78
     I-outdate AT ROW 16 COL 1 WIDGET-ID 72

     B-8 AT ROW 16.96 COL 3 WIDGET-ID 100
     outnum AT ROW 16.96 COL 6 NO-LABEL WIDGET-ID 266
     B-outnum AT ROW 16.96 COL 15.75 WIDGET-ID 264
     v-outnum AT ROW 17 COL 19 NO-LABEL WIDGET-ID 106
     I-outnum AT ROW 17 COL 1 WIDGET-ID 104

     B-7 AT ROW 17.96 COL 3 WIDGET-ID 92
     outhold AT ROW 17.96 COL 6 NO-LABEL WIDGET-ID 244
     B-outhold AT ROW 17.96 COL 15.75 WIDGET-ID 246
     v-outhold AT ROW 18.04 COL 19 NO-LABEL WIDGET-ID 98
     I-outhold AT ROW 18 COL 1 WIDGET-ID 94
     
     B-12 AT ROW 18.96 COL 3 WIDGET-ID 316
     outsubs AT ROW 18.96 COL 6 NO-LABEL WIDGET-ID 322
     B-outsubs AT ROW 18.96 COL 15.75 WIDGET-ID 318
     v-outsubs AT ROW 19.04 COL 19 NO-LABEL WIDGET-ID 324
     I-outsubs AT ROW 19 COL 1 WIDGET-ID 320
     
     B-13 AT ROW 19.96 COL 3 WIDGET-ID 442
     outt12 AT ROW 19.96 COL 6 NO-LABEL WIDGET-ID 332
     B-outt12 AT ROW 19.96 COL 15.75 WIDGET-ID 328
     I-outt12 AT ROW 20 COL 1 WIDGET-ID 330
     v-outt12 AT ROW 20.04 COL 19 NO-LABEL WIDGET-ID 334

     B-18 AT ROW 20.96 COL 3 WIDGET-ID 452
     outprim AT ROW 20.96 COL 6 NO-LABEL WIDGET-ID 296
     B-outprim AT ROW 20.96 COL 15.75 WIDGET-ID 294
     v-outprim AT ROW 21.04 COL 19 NO-LABEL WIDGET-ID 222
     I-outprim AT ROW 21 COL 1 WIDGET-ID 218

     B-19 AT ROW 21.96 COL 3 WIDGET-ID 390
     outrubl AT ROW 21.96 COL 6 NO-LABEL WIDGET-ID 292
     B-outrubl AT ROW 21.96 COL 15.75 WIDGET-ID 290
     I-outrubl AT ROW 22 COL 1 WIDGET-ID 224
     v-outrubl AT ROW 22.04 COL 19 NO-LABEL WIDGET-ID 228
     
     B-21 AT ROW 22.96 COL 3 WIDGET-ID 394
     outares AT ROW 22.96 COL 6 NO-LABEL WIDGET-ID 406
     B-outares AT ROW 22.96 COL 15.75 WIDGET-ID 398
     I-outares AT ROW 23 COL 1 WIDGET-ID 402
     v-outares AT ROW 23.04 COL 19 NO-LABEL WIDGET-ID 410
     
     B-22 AT ROW 23.96 COL 3 WIDGET-ID 396
     outsend AT ROW 23.96 COL 6 NO-LABEL WIDGET-ID 408
     B-outsend AT ROW 23.96 COL 15.75 WIDGET-ID 400
     I-outsend AT ROW 24 COL 1 WIDGET-ID 404
     v-outsend AT ROW 24.04 COL 19 NO-LABEL WIDGET-ID 412
     
     B-23 AT ROW 24.96 COL 3 WIDGET-ID 420
     outasend AT ROW 24.96 COL 6 NO-LABEL WIDGET-ID 426
     B-outasend AT ROW 24.96 COL 15.75 WIDGET-ID 422
     I-outasend AT ROW 25.04 COL 1 WIDGET-ID 424
     v-outasend AT ROW 25.04 COL 19 NO-LABEL WIDGET-ID 428    
     
     
     
     FILL-IN-1 AT ROW 11.25 COL 1.75 NO-LABEL WIDGET-ID 336

    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         DEFAULT-BUTTON B-exit CANCEL-BUTTON B-quit WIDGET-ID 100.



/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Dialog-Box
   Allow: Basic,Browse,DB-Fields,Query
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS



/* ***********  Runtime Attributes and AppBuilder Settings  *********** */

&ANALYZE-SUSPEND _RUN-TIME-ATTRIBUTES
/* SETTINGS FOR DIALOG-BOX Dialog-Frame
   FRAME-NAME                                                           */
ASSIGN 
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.

/* SETTINGS FOR BUTTON B-1 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-12 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-13 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-14 IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR BUTTON B-15 IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR BUTTON B-16 IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR BUTTON B-18 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-19 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-2 IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR BUTTON B-20 IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR BUTTON B-21 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-22 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-23 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-24 IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR BUTTON B-25 IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR BUTTON B-26 IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR BUTTON B-27 IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR BUTTON B-3 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-4 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-5 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-6 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-7 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-8 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-9 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-exit IN FRAME Dialog-Frame
   3                                                                    */
/* SETTINGS FOR BUTTON B-Help IN FRAME Dialog-Frame
   3                                                                    */
/* SETTINGS FOR BUTTON B-outappr IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-outares IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-outasend IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-outdate IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-outdisc IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-outegrp IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-outhold IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-outnum IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-outobj IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-outprim IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-outrecv IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR BUTTON B-outrubl IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-outsend IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-outsubs IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-outt12 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR BUTTON B-quit IN FRAME Dialog-Frame
   3                                                                    */
/* SETTINGS FOR BUTTON BUTTON-1 IN FRAME Dialog-Frame
   3                                                                    */
/* SETTINGS FOR BUTTON BUTTON-2 IN FRAME Dialog-Frame
   3                                                                    */
/* SETTINGS FOR FILL-IN F-button-1 IN FRAME Dialog-Frame
   3                                                                    */
/* SETTINGS FOR FILL-IN F-button-2 IN FRAME Dialog-Frame
   3                                                                    */
/* SETTINGS FOR TOGGLE-BOX factur01 IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR TOGGLE-BOX fgdsnind IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR FILL-IN FILL-IN-1 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
/* SETTINGS FOR IMAGE I-factur01 IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR IMAGE I-fgdsnind IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-in-docpr IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR IMAGE I-incurrat IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR IMAGE I-invprn0 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-outappr IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-outares IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-outasend IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-outb IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR IMAGE I-outc IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR IMAGE I-outdate IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-outdisc IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-outegrp IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-outhold IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-outnum IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-outobj IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-outogr IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR IMAGE I-outprim IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-outprncd IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-outprops IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR IMAGE I-outR IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR IMAGE I-outrecv IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR IMAGE I-outrubl IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-outsend IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-outssdoc IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR IMAGE I-outsubs IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-outt12 IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR IMAGE I-rep-artic IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR IMAGE I-sort-prd IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR IMAGE I-tick-w IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR IMAGE I-torg2-no IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN in-docpr IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
/* SETTINGS FOR TOGGLE-BOX incurrat IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR TOGGLE-BOX invprn0 IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       invprn0:HIDDEN IN FRAME Dialog-Frame           = TRUE.

/* SETTINGS FOR EDITOR outappr IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       outappr:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR outares IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       outares:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR outasend IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       outasend:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR outdate IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       outdate:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR outdisc IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       outdisc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR outegrp IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       outegrp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR outhold IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       outhold:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR outnum IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       outnum:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR outobj IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       outobj:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR outprim IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       outprim:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR TOGGLE-BOX outprncd IN FRAME Dialog-Frame
   1                                                                    */
/* SETTINGS FOR TOGGLE-BOX outprops IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR EDITOR outrecv IN FRAME Dialog-Frame
   2                                                                    */
ASSIGN 
       outrecv:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR outrubl IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       outrubl:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR outsend IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       outsend:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR RADIO-SET outssdoc IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR EDITOR outsubs IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       outsubs:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR EDITOR outt12 IN FRAME Dialog-Frame
   1                                                                    */
ASSIGN 
       outt12:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR TOGGLE-BOX rep-artic IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR TOGGLE-BOX sort-prd IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR TOGGLE-BOX tick-w IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR TOGGLE-BOX torg2-no IN FRAME Dialog-Frame
   2                                                                    */
/* SETTINGS FOR FILL-IN v-factur01 IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
ASSIGN 
       v-factur01:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-fgdsnind IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-fgdsnind:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-in-docpr IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
ASSIGN 
       v-in-docpr:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-incurrat IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
ASSIGN 
       v-incurrat:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-invprn0 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-invprn0:HIDDEN IN FRAME Dialog-Frame           = TRUE
       v-invprn0:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outappr IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-outappr:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outares IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-outares:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outasend IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-outasend:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outb IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
ASSIGN 
       v-outb:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outc IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
ASSIGN 
       v-outc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outdate IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-outdate:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outdisc IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-outdisc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outegrp IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-outegrp:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outhold IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-outhold:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outnum IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-outnum:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outobj IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-outobj:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outogr IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
ASSIGN 
       v-outogr:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outprim IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-outprim:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outprncd IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-outprncd:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outprops IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
ASSIGN 
       v-outprops:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outR IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
ASSIGN 
       v-outR:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outrecv IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
ASSIGN 
       v-outrecv:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outrubl IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-outrubl:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outsend IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-outsend:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outssdoc IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
ASSIGN 
       v-outssdoc:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outsubs IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-outsubs:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-outt12 IN FRAME Dialog-Frame
   ALIGN-L 1                                                            */
ASSIGN 
       v-outt12:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-rep-artic IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
ASSIGN 
       v-rep-artic:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-sort-prd IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
ASSIGN 
       v-sort-prd:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-tick-w IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
ASSIGN 
       v-tick-w:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* SETTINGS FOR FILL-IN v-torg2-no IN FRAME Dialog-Frame
   ALIGN-L 2                                                            */
ASSIGN 
       v-torg2-no:READ-ONLY IN FRAME Dialog-Frame        = TRUE.

/* _RUN-TIME-ATTRIBUTES-END */
&ANALYZE-RESUME

 



/* ************************  Control Triggers  ************************ */

&Scoped-define SELF-NAME Dialog-Frame
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON GO OF FRAME Dialog-Frame
DO:
  run save-proc in this-procedure no-error.
  if error-status :error then return no-apply.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL Dialog-Frame Dialog-Frame
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-1
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-1 Dialog-Frame
ON CHOOSE OF B-1 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "fgdsnind"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-12
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-12 Dialog-Frame
ON CHOOSE OF B-12 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outsubs"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-13
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-13 Dialog-Frame
ON CHOOSE OF B-13 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outt12"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-14
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-14 Dialog-Frame
ON CHOOSE OF B-14 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-firm},
       "factur01"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-15
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-15 Dialog-Frame
ON CHOOSE OF B-15 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-firm},
       "incurrat"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-16
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-16 Dialog-Frame
ON CHOOSE OF B-16 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-firm},
       "tick-w"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-18
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-18 Dialog-Frame
ON CHOOSE OF B-18 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outprim"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-19
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-19 Dialog-Frame
ON CHOOSE OF B-19 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outrubl"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-2
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-2 Dialog-Frame
ON CHOOSE OF B-2 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "in-docpr"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-20
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-20 Dialog-Frame
ON CHOOSE OF B-20 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outssdoc"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-21
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-21 Dialog-Frame
ON CHOOSE OF B-21 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outares"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-22
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-22 Dialog-Frame
ON CHOOSE OF B-22 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outsend"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-23
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-23 Dialog-Frame
ON CHOOSE OF B-23 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outasend"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-24
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-24 Dialog-Frame
ON CHOOSE OF B-24 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outR"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-25
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-25 Dialog-Frame
ON CHOOSE OF B-25 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outogr"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-26
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-26 Dialog-Frame
ON CHOOSE OF B-26 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outb"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-27
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-27 Dialog-Frame
ON CHOOSE OF B-27 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outc"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-3
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-3 Dialog-Frame
ON CHOOSE OF B-3 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outdisc"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-4
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-4 Dialog-Frame
ON CHOOSE OF B-4 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outegrp"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-5
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-5 Dialog-Frame
ON CHOOSE OF B-5 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outappr"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-6
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-6 Dialog-Frame
ON CHOOSE OF B-6 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outdate"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-7
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-7 Dialog-Frame
ON CHOOSE OF B-7 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outhold"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-8
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-8 Dialog-Frame
ON CHOOSE OF B-8 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outnum"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-9
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-9 Dialog-Frame
ON CHOOSE OF B-9 IN FRAME Dialog-Frame
DO:
  run gbl/v-taobj.w
      ({&attr-prt-obj},
       "outobj"
       ).
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-outappr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-outappr Dialog-Frame
ON CHOOSE OF B-outappr IN FRAME Dialog-Frame
DO:
 if p-mode = {&lookup} then return .
    run twowin_clear in this-procedure.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',  input  "ТОРГ12", input "Печатная форма ТОРГ-12",            input (if lookup ('torg12' , outappr ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg13',  input  "ТОРГ13", input "Печатная форма ТОРГ-13",            input (if lookup ('torg13' , outappr ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg16',  input  "ТОРГ16", input "Печатная форма ТОРГ-16",            input (if lookup ('torg16' , outappr ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'factur',  input  "Счет-фактура", input "Печатная форма Счет-фактура", input (if lookup ('factur' , outappr ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'schet',   input  "Счет",         input "Печатная форма Счет",         input (if lookup ('schet'  , outappr ) > 0 then  true  else false )  ).
    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outappr = ''.
    for each temp_twowin_itemsSelected_col
    :
      outappr = outappr + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outappr = trim(outappr,"," ).
 end.
 DISPLAY outappr with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-outares
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-outares Dialog-Frame
ON CHOOSE OF B-outares IN FRAME Dialog-Frame
DO:
 if p-mode = {&lookup} then return .
    run twowin_clear in this-procedure.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input (if lookup ('torg12'   , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input (if lookup ('torg12n'  , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input (if lookup ('torg12z'  , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input (if lookup ('torg13'   , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input (if lookup ('torg16'   , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input (if lookup ('factur'   , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'facturn',   input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением", input (if lookup ('facturn'  , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input (if lookup ('schet'    , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input (if lookup ('oldinp'   , outares ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input (if lookup ('oldexp'   , outares ) > 0 then  true  else false )).
    run twowin_add-item in this-procedure ( input 'torg1',   input  "Торг1", input "Акт приемки товара",                                       input (if lookup ('torg1'    , outares ) > 0 then  true  else false )).

    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outares = ''.
    for each temp_twowin_itemsSelected_col
    :
      outares = outares + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outares = trim(outares,"," ).
 end.
 DISPLAY outares with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-outasend
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-outasend Dialog-Frame
ON CHOOSE OF B-outasend IN FRAME Dialog-Frame
DO:
 if p-mode = {&lookup} then return .
    run twowin_clear in this-procedure.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",         input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input (if lookup ('torg12'     , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input (if lookup ('torg12n'    , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input (if lookup ('torg12z'    , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input (if lookup ('torg13'     , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input (if lookup ('torg16'     , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input (if lookup ('factur'     , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'facturn',  input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением",  input (if lookup ('facturn'    , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input (if lookup ('schet'      , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input (if lookup ('oldinp'     , outasend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input (if lookup ('oldexp'     , outasend ) > 0 then  true  else false ) ).

    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outasend = ''.
    for each temp_twowin_itemsSelected_col
    :
      outasend = outasend + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outasend = trim(outasend,"," ).
 end.
 DISPLAY outasend with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-outdate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-outdate Dialog-Frame
ON CHOOSE OF B-outdate IN FRAME Dialog-Frame
DO:
 if p-mode = {&lookup} then return .
    run twowin_clear in this-procedure.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input (if lookup ('torg12'     , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input (if lookup ('torg12n'    , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input (if lookup ('torg12z'    , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input (if lookup ('torg13'     , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input (if lookup ('torg16'     , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input (if lookup ('factur'     , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'facturn',   input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением", input (if lookup ('facturn'    , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input (if lookup ('schet'      , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input (if lookup ('oldinp'     , outdate ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input (if lookup ('oldexp'     , outdate ) > 0 then  true  else false )  ).

    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outdate = ''.
    for each temp_twowin_itemsSelected_col
    :
      outdate = outdate + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outdate = trim(outdate,"," ).
 end.
 DISPLAY outdate with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-outdisc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-outdisc Dialog-Frame
ON CHOOSE OF B-outdisc IN FRAME Dialog-Frame
DO:
 if p-mode = {&lookup} then return .
    run twowin_clear in this-procedure.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input (if lookup ('torg12'     , outdisc ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input (if lookup ('torg12n'     , outdisc ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input (if lookup ('torg12z'     , outdisc ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input (if lookup ('torg13'     , outdisc ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input (if lookup ('torg16'     , outdisc ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input (if lookup ('factur'     , outdisc ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'facturn',   input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением", input (if lookup ('facturn'     , outdisc ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input (if lookup ('schet'     , outdisc ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input (if lookup ('oldinp'     , outdisc ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input (if lookup ('oldexp'     , outdisc ) > 0 then  true  else false )  ).


    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outdisc = ''.
    for each temp_twowin_itemsSelected_col
    :
      outdisc = outdisc + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outdisc = trim(outdisc,"," ).
 end.
 DISPLAY outdisc with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-outegrp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-outegrp Dialog-Frame
ON CHOOSE OF B-outegrp IN FRAME Dialog-Frame
DO:
 if p-mode = {&lookup} then return .
    run twowin_clear in this-procedure.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input ( if lookup ('torg12'     , outegrp ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input ( if lookup ('torg12n'     , outegrp ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input ( if lookup ('torg12z'     , outegrp ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input ( if lookup ('torg13'     , outegrp ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input ( if lookup ('torg16'     , outegrp ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input ( if lookup ('factur'     , outegrp ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'facturn',   input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением", input ( if lookup ('facturn'     , outegrp ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input ( if lookup ('schet'     , outegrp ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input ( if lookup ('oldinp'     , outegrp ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input ( if lookup ('oldexp'     , outegrp ) > 0 then  true  else false ) ).


    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outegrp = ''.
    for each temp_twowin_itemsSelected_col
    :
      outegrp = outegrp + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outegrp = trim(outegrp,"," ).
 end.
 DISPLAY outegrp with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-outhold
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-outhold Dialog-Frame
ON CHOOSE OF B-outhold IN FRAME Dialog-Frame
DO:
 if p-mode = {&lookup} then return .
    run twowin_clear in this-procedure.
    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",         input   "ПУСТО" , input "" ,                                input  no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",            input ( if lookup ('torg12' , outhold ) > 0 then  true  else false )).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура", input ( if lookup ('factur' , outhold ) > 0 then  true  else false )).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",         input ( if lookup ('schet'  , outhold ) > 0 then  true  else false )).

    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outhold = ''.
    for each temp_twowin_itemsSelected_col
    :
      outhold = outhold + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outhold = trim(outhold,"," ).
 end.
 DISPLAY outhold with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-outnum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-outnum Dialog-Frame
ON CHOOSE OF B-outnum IN FRAME Dialog-Frame
DO:
 if p-mode = {&lookup} then return .
    run twowin_clear in this-procedure.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input ( if lookup ('torg12'  ,  outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input ( if lookup ('torg12n'  , outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input ( if lookup ('torg12z'  , outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input ( if lookup ('torg13'  ,  outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input ( if lookup ('torg16'  ,  outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input ( if lookup ('factur'  ,  outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'facturn',  input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением", input ( if lookup ('facturn'  , outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input ( if lookup ('schet'  ,   outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input ( if lookup ('oldinp'  ,  outnum ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input ( if lookup ('oldexp'  ,  outnum ) > 0 then  true  else false ) ).

    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outnum = ''.
    for each temp_twowin_itemsSelected_col
    :
      outnum = outnum + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outnum = trim(outnum,"," ).
 end.
 DISPLAY outnum with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-outobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-outobj Dialog-Frame
ON CHOOSE OF B-outobj IN FRAME Dialog-Frame
DO:
 if p-mode = {&lookup} then return .
    run twowin_clear in this-procedure.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура", input ( if lookup ('factur'  ,  outobj ) > 0 then  true  else false ) ).

    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
         ).

    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outobj = ''.
    for each temp_twowin_itemsSelected_col
    :
      outobj = outobj + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outobj = trim(outobj,"," ).
 end.
 DISPLAY outobj with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-outprim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-outprim Dialog-Frame
ON CHOOSE OF B-outprim IN FRAME Dialog-Frame
DO:
 if p-mode = {&lookup} then return .
    run twowin_clear in this-procedure.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                  input ( if lookup ('torg12'   ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",              input ( if lookup ('torg12n'  ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ",  input ( if lookup ('torg12z'  ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                  input ( if lookup ('torg13'   ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                  input ( if lookup ('torg16'   ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                       input ( if lookup ('factur'   ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'facturn',   input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением",  input ( if lookup ('facturn'  ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                               input ( if lookup ('schet'    ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                       input ( if lookup ('oldinp'   ,  outprim ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                       input ( if lookup ('oldexp'   ,  outprim ) > 0 then  true  else false )  ).

    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outprim = ''.
    for each temp_twowin_itemsSelected_col
    :
      outprim = outprim + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outprim = trim(outprim,"," ).
 end.
 DISPLAY outprim with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-outrecv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-outrecv Dialog-Frame
ON CHOOSE OF B-outrecv IN FRAME Dialog-Frame /* B-outrecv */
DO:
 if p-mode = {&lookup} then return .
    run twowin_clear in this-procedure.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input "",  input  string("","x(10)") + "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input ( if lookup ('torg12'   ,  outrecv ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input ( if lookup ('torg12n'  ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input ( if lookup ('torg12z'  ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input ( if lookup ('torg13'   ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input ( if lookup ('torg16'   ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input ( if lookup ('factur'   ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'facturn',   input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением", input ( if lookup ('facturn'  ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",                input "Печатная форма Счет",                       input ( if lookup ('schet'    ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                     input  ( if lookup ('oldinp'   ,  outrecv ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                     input  ( if lookup ('oldexp'   ,  outrecv ) > 0 then  true  else false ) ).

    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outrecv = ''.
    for each temp_twowin_itemsSelected_col
    :
      outrecv = outrecv + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outrecv = trim(outrecv,"," ).
 end.
 DISPLAY outrecv with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-outrubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-outrubl Dialog-Frame
ON CHOOSE OF B-outrubl IN FRAME Dialog-Frame
DO:
 if p-mode = {&lookup} then return .
    run twowin_clear in this-procedure.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",          input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура", input ( if lookup ('factur'   ,  outrubl ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet' ,    input  "Счет",         input "Печатная форма Счет",        input ( if lookup ('schet'    ,  outrubl ) > 0 then  true  else false ) ).

    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outrubl = ''.
    for each temp_twowin_itemsSelected_col
    :
      outrubl = outrubl + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outrubl = trim(outrubl,"," ).
 end.
 DISPLAY outrubl with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-outsend
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-outsend Dialog-Frame
ON CHOOSE OF B-outsend IN FRAME Dialog-Frame
DO:
 if p-mode = {&lookup} then return .
    run twowin_clear in this-procedure.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",         input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input ( if lookup ('torg12' ,  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input ( if lookup ('torg12n' ,  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input ( if lookup ('torg12z' ,  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input ( if lookup ('torg13' ,  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input ( if lookup ('torg16' ,  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input ( if lookup ('factur' ,  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'facturn',  input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением",  input ( if lookup ('facturn' ,  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input ( if lookup ('schet',   outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input ( if lookup ('oldinp',  outsend ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input ( if lookup ('oldexp',  outsend ) > 0 then  true  else false ) ).

    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outsend = ''.
    for each temp_twowin_itemsSelected_col
    :
      outsend = outsend + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outsend = trim(outsend,"," ).
 end.
 DISPLAY outsend with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-outsubs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-outsubs Dialog-Frame
ON CHOOSE OF B-outsubs IN FRAME Dialog-Frame
DO:
 if p-mode = {&lookup} then return .
    run twowin_clear in this-procedure.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",  input   "ПУСТО" , input "" , input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input ( if lookup ('torg12',  outsubs ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input ( if lookup ('torg12n',  outsubs ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input ( if lookup ('torg12z',  outsubs ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg13',   input  "ТОРГ13", input "Печатная форма ТОРГ-13",                                 input ( if lookup ('torg13',  outsubs ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg16',   input  "ТОРГ16", input "Печатная форма ТОРГ-16",                                 input ( if lookup ('torg16',  outsubs ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'factur',   input  "Счет-фактура", input "Печатная форма Счет-фактура",                      input ( if lookup ('factur',  outsubs ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'facturn',   input  "Счет-фактура с окр", input "Печатная форма Счет-фактура с округлением", input ( if lookup ('facturn',  outsubs ) > 0 then  true  else false ) ).
    run twowin_add-item in this-procedure ( input 'schet',    input  "Счет",         input "Печатная форма Счет",                              input ( if lookup ('schet',   outsubs ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldinp',   input  "Приходная Накладная", input "Печатная форма по ПН",                      input ( if lookup ('oldinp',  outsubs ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'oldexp',   input  "Накладная Расходная", input "Печатная форма по РН",                      input ( if lookup ('oldexp',  outsubs ) > 0 then  true  else false )  ).

    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outsubs = ''.
    for each temp_twowin_itemsSelected_col
    :
      outsubs = outsubs + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outsubs = trim(outsubs,"," ).
 end.
 DISPLAY outsubs with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME B-outt12
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL B-outt12 Dialog-Frame
ON CHOOSE OF B-outt12 IN FRAME Dialog-Frame
DO:
 if p-mode = {&lookup} then return .
    run twowin_clear in this-procedure.

    define variable v-accepted      as logical      no-undo.
    define variable v-cur-ext-key   as character    no-undo.
    run twowin_add-item in this-procedure ( input "",         input   "ПУСТО" , input "" ,                     input no ).
    run twowin_add-item in this-procedure ( input 'torg12',   input  "ТОРГ12", input "Печатная форма ТОРГ-12",                                 input (if lookup ('torg12' , outt12 ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12n',  input  "ТОРГ12 с окр", input "Печатная форма ТОРГ-12 с округлением",             input (if lookup ('torg12n' , outt12 ) > 0 then  true  else false )  ).
    run twowin_add-item in this-procedure ( input 'torg12z',  input  "ТОРГ12 для ювел.изд.", input "Печатная форма ТОРГ-12 для ювел.изделий ", input (if lookup ('torg12z' , outt12 ) > 0 then  true  else false )  ).

    run gbl/twowin.w (
          input ?
        , input 1
        , input "Выбор из списка форм"
        , input ""
        , input ""
        , input table temp_twowin_items
        , output table temp_twowin_itemsSelected_col
        , output v-cur-ext-key
        , output v-accepted
    ).
    if v-accepted and can-find (first temp_twowin_itemsSelected_col) then do:
    outt12 = ''.
    for each temp_twowin_itemsSelected_col
    :
      outt12 = outt12 + temp_twowin_itemsSelected_col.itmExtKey + "," .
    end.
    outt12 = trim(outt12,"," ).
 end.
 DISPLAY outt12 with FRAME {&FRAME-NAME}.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-factur01
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-factur01 Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-factur01 IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-fgdsnind
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-fgdsnind Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-fgdsnind IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-in-docpr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-in-docpr Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-in-docpr IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-incurrat
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-incurrat Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-incurrat IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-invprn0
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-invprn0 Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-invprn0 IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outappr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outappr Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outappr IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outares
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outares Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outares IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outasend
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outasend Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outasend IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outb
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outb Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outb IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outc Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outc IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outdate
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outdate Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outdate IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outdisc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outdisc Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outdisc IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outegrp
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outegrp Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outegrp IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outhold
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outhold Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outhold IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outnum
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outnum Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outnum IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outobj
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outobj Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outobj IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outogr
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outogr Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outogr IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outprim
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outprim Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outprim IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outprncd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outprncd Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outprncd IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outprops
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outprops Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outprops IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outR
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outR Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outR IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outrecv
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outrecv Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outrecv IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outrubl
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outrubl Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outrubl IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outsend
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outsend Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outsend IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outssdoc
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outssdoc Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outssdoc IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outsubs
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outsubs Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outsubs IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-outt12
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-outt12 Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-outt12 IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-rep-artic
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-rep-artic Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-rep-artic IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-sort-prd
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-sort-prd Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-sort-prd IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-tick-w
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-tick-w Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-tick-w IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&Scoped-define SELF-NAME I-torg2-no
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CONTROL I-torg2-no Dialog-Frame
ON MOUSE-SELECT-CLICK OF I-torg2-no IN FRAME Dialog-Frame
DO:
  MESSAGE {&SELF-NAME}:private-data  VIEW-AS ALERT-BOX INFORMATION.
END.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE SELF-NAME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Dialog-Frame 


/* ***************************  Main Block  *************************** */

/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent.   */
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

{ gbl/app_help.i }
/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
   outR:Radio-BUTTONS in frame {&frame-name}   = "Не печатать,no_print,Руководитель фирмы,ruk_firm,Директор объекта,dir_obj" .
   outB:Radio-BUTTONS in frame {&frame-name}   = "Не печатать,no_print,Гл. бух. фирмы,glbuh_firm,Бухгалтер объекта,buh_obj"  .
   outogr:Radio-BUTTONS in frame {&frame-name}  = "Не печатать,no_print,Руководитель фирмы,ruk_firm,Директор объекта,dir_obj,Менеджер документа,manag_doc".
   outC:Radio-BUTTONS in frame {&frame-name}   = "Не печатать,no_print,Кладовщик документа,clad_doc,Кладовщик объекта,clad_obj"  .

MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

if p-obj-type <> "" then
   frame {&frame-name}:title = frame {&frame-name}:title + (if p-obj-type = {&cmp} then " фирма" else " маг") + string(p-obj-code) .

define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_nakl-par_lookup':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
  }
   if loc#log <> yes then do: return error. end.
    run init-tt.
    run enable_UI.
    run init-proc.
    fl = 'new' .  /* флаг для закладок */
/*    apply  "CHOOSE":U   to  button-1 in frame {&frame-name} .*/

  WAIT-FOR GO OF FRAME {&FRAME-NAME}.
END.
run disable_UI.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE disable_UI Dialog-Frame  _DEFAULT-DISABLE
PROCEDURE disable_UI :
/*------------------------------------------------------------------------------
  Purpose:     DISABLE the User Interface
  Parameters:  <none>
  Notes:       Here we clean-up the user-interface by deleting
               dynamic widgets we have created and/or hide 
               frames.  This procedure is usually called when
               we are ready to "clean-up" after running.
------------------------------------------------------------------------------*/
  /* Hide all frames. */
  HIDE FRAME Dialog-Frame.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE enable_UI Dialog-Frame  _DEFAULT-ENABLE
PROCEDURE enable_UI :
  /*------------------------------------------------------------------------------
    Purpose:     ENABLE the User Interface
    Parameters:  <none>
    Notes:       Here we display/view/enable the widgets in the
                 user-interface.  In addition, OPEN all queries
                 associated with each FRAME and BROWSE.
                 These statements here are based on the "Other
                 Settings" section of the widget Property Sheets.
  ------------------------------------------------------------------------------*/
  if p-type = "glob" then 
  do:
    DISPLAY FILL-IN-4
      invprn0  I-invprn0  v-invprn0
      outprncd I-outprncd v-outprncd
      outrecv   I-outrecv B-outrecv v-outrecv
      rep-artic I-rep-artic   v-rep-artic
      outprops  I-outprops  v-outprops
      sort-prd  I-sort-prd    v-sort-prd
      torg2-no   I-torg2-no v-torg2-no
      WITH FRAME Dialog-Frame.
    ENABLE B-exit  B-quit  B-Help FILL-IN-4 RECT-2
      invprn0  I-invprn0  v-invprn0
      outprncd I-outprncd v-outprncd
      outrecv   I-outrecv B-outrecv v-outrecv
      rep-artic I-rep-artic   v-rep-artic
      outprops  I-outprops  v-outprops
      sort-prd  I-sort-prd    v-sort-prd
      torg2-no   I-torg2-no v-torg2-no
      WITH FRAME Dialog-Frame.
    HIDE  
      I-factur01 factur01  v-factur01  B-14
      I-incurrat  incurrat  v-incurrat  B-15
      I-tick-w  tick-w    v-tick-w  B-16
      fgdsnind  B-20  I-fgdsnind  v-fgdsnind
      outssdoc  B-1 I-outssdoc  v-outssdoc
      in-docpr  B-2 I-in-docpr  v-in-docpr
      outR    B-24  I-outR    v-outR
      outB    B-18  I-outb    v-outb
      outogr    B-13  I-outogr  v-outogr
      outC    B-27  I-outc    v-outc
      FILL-IN-1
      outdisc   B-3 I-outdisc   B-outdisc v-outdisc
      outegrp   B-4 I-outegrp B-outegrp v-outegrp
      outobj    B-9   I-outobj  B-outobj  v-outobj
      outappr   B-5 I-outappr B-outappr   v-outappr
      outdate   B-6 I-outdate   B-outdate v-outdate
      outnum    B-8 I-outnum  B-outnum  v-outnum
      outhold   B-7 I-outhold B-outhold v-outhold
      outsubs   B-12  I-outsubs B-outsubs v-outsubs
      outt12    B-25  I-outt12  B-outt12  v-outt12
      outprim   B-26  I-outprim B-outprim v-outprim
      outrubl   B-19  I-outrubl B-outrubl v-outrubl
      outares   B-21  I-outares B-outares v-outares
      outsend   B-22  I-outsend B-outsend v-outsend
      outasend  B-23  I-outasend  B-outasend  v-outasend
      invprn0  I-invprn0  v-invprn0
      outprncd I-outprncd v-outprncd
      outrecv   I-outrecv B-outrecv v-outrecv
      rep-artic I-rep-artic   v-rep-artic
      outprops  I-outprops  v-outprops
      sort-prd  I-sort-prd    v-sort-prd
      torg2-no   I-torg2-no v-torg2-no
     IN FRAME Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  end.
  if p-type = "firm" then 
  do:
    DISPLAY FILL-IN-4
      I-factur01 factur01  v-factur01  B-14
      I-incurrat  incurrat  v-incurrat  B-15
      I-tick-w  tick-w    v-tick-w  B-16
      WITH FRAME Dialog-Frame.
    ENABLE B-exit  B-quit  B-Help FILL-IN-4 RECT-2
      I-factur01 factur01  v-factur01  B-14
      I-incurrat  incurrat  v-incurrat  B-15
      I-tick-w  tick-w    v-tick-w  B-16
      WITH FRAME Dialog-Frame.
    HIDE  
     invprn0  I-invprn0  v-invprn0
      outprncd I-outprncd v-outprncd
      outrecv   I-outrecv B-outrecv v-outrecv
      rep-artic I-rep-artic   v-rep-artic
      outprops  I-outprops  v-outprops
      sort-prd  I-sort-prd    v-sort-prd
      torg2-no   I-torg2-no v-torg2-no
      fgdsnind  B-20  I-fgdsnind  v-fgdsnind
      outssdoc  B-1 I-outssdoc  v-outssdoc
      in-docpr  B-2 I-in-docpr  v-in-docpr
      outR    B-24  I-outR    v-outR
      outB    B-18  I-outb    v-outb
      outogr    B-13  I-outogr  v-outogr
      outC    B-27  I-outc    v-outc
      FILL-IN-1
      outdisc   B-3 I-outdisc   B-outdisc v-outdisc
      outegrp   B-4 I-outegrp B-outegrp v-outegrp
      outobj    B-9   I-outobj  B-outobj  v-outobj
      outappr   B-5 I-outappr B-outappr   v-outappr
      outdate   B-6 I-outdate   B-outdate v-outdate
      outnum    B-8 I-outnum  B-outnum  v-outnum
      outhold   B-7 I-outhold B-outhold v-outhold
      outsubs   B-12  I-outsubs B-outsubs v-outsubs
      outt12    B-25  I-outt12  B-outt12  v-outt12
      outprim   B-26  I-outprim B-outprim v-outprim
      outrubl   B-19  I-outrubl B-outrubl v-outrubl
      outares   B-21  I-outares B-outares v-outares
      outsend   B-22  I-outsend B-outsend v-outsend
      outasend  B-23  I-outasend  B-outasend  v-outasend
     IN FRAME Dialog-Frame.  
    VIEW FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  end.
  if p-type = "obj" then 
  do:
    DISPLAY FILL-IN-4
      fgdsnind  B-20  I-fgdsnind  v-fgdsnind
      outssdoc  B-1 I-outssdoc  v-outssdoc
      in-docpr  B-2 I-in-docpr  v-in-docpr
      outR    B-24  I-outR    v-outR
      outB    B-18  I-outb    v-outb
      outogr    B-13  I-outogr  v-outogr
      outC    B-27  I-outc    v-outc
      FILL-IN-1
      outdisc   B-3 I-outdisc   B-outdisc v-outdisc
      outegrp   B-4 I-outegrp B-outegrp v-outegrp
      outobj    B-9   I-outobj  B-outobj  v-outobj
      outappr   B-5 I-outappr B-outappr   v-outappr
      outdate   B-6 I-outdate   B-outdate v-outdate
      outnum    B-8 I-outnum  B-outnum  v-outnum
      outhold   B-7 I-outhold B-outhold v-outhold
      outsubs   B-12  I-outsubs B-outsubs v-outsubs
      outt12    B-25  I-outt12  B-outt12  v-outt12
      outprim   B-26  I-outprim B-outprim v-outprim
      outrubl   B-19  I-outrubl B-outrubl v-outrubl
      outares   B-21  I-outares B-outares v-outares
      outsend   B-22  I-outsend B-outsend v-outsend
      outasend  B-23  I-outasend  B-outasend  v-outasend
      WITH FRAME Dialog-Frame.
    ENABLE B-exit  B-quit  B-Help FILL-IN-4 RECT-2
      fgdsnind  B-20  I-fgdsnind  v-fgdsnind
      outssdoc  B-1 I-outssdoc  v-outssdoc
      in-docpr  B-2 I-in-docpr  v-in-docpr
      outR    B-24  I-outR    v-outR
      outB    B-18  I-outb    v-outb
      outogr    B-13  I-outogr  v-outogr
      outC    B-27  I-outc    v-outc
      FILL-IN-1
      outdisc   B-3 I-outdisc   B-outdisc v-outdisc
      outegrp   B-4 I-outegrp B-outegrp v-outegrp
      outobj    B-9   I-outobj  B-outobj  v-outobj
      outappr   B-5 I-outappr B-outappr   v-outappr
      outdate   B-6 I-outdate   B-outdate v-outdate
      outnum    B-8 I-outnum  B-outnum  v-outnum
      outhold   B-7 I-outhold B-outhold v-outhold
      outsubs   B-12  I-outsubs B-outsubs v-outsubs
      outt12    B-25  I-outt12  B-outt12  v-outt12
      outprim   B-26  I-outprim B-outprim v-outprim
      outrubl   B-19  I-outrubl B-outrubl v-outrubl
      outares   B-21  I-outares B-outares v-outares
      outsend   B-22  I-outsend B-outsend v-outsend
      outasend  B-23  I-outasend  B-outasend  v-outasend
      WITH FRAME Dialog-Frame.
      hide
      I-factur01 factur01  v-factur01  B-14
      I-incurrat  incurrat  v-incurrat  B-15
      I-tick-w  tick-w    v-tick-w  B-16
      invprn0  I-invprn0  v-invprn0
      outprncd I-outprncd v-outprncd
      outrecv   I-outrecv B-outrecv v-outrecv
      rep-artic I-rep-artic   v-rep-artic
      outprops  I-outprops  v-outprops
      sort-prd  I-sort-prd    v-sort-prd
      torg2-no   I-torg2-no v-torg2-no
      in frame Dialog-Frame.
    VIEW FRAME Dialog-Frame.
    {&OPEN-BROWSERS-IN-QUERY-Dialog-Frame}
  end.    

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-widgets Dialog-Frame 
PROCEDURE fill-widgets :
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-param-type as character no-undo .
define variable v-param-value as character no-undo .

for each thbjattr_thbj-attr:
  delete thbjattr_thbj-attr.
end.
for each thbjattr_thbj-attr-o:
  delete thbjattr_thbj-attr-o.
end.

for each thbjattr_thbj-attr-g:
  delete thbjattr_thbj-attr-g.
end.
for each thbjattr_thbj-attr-f:
  delete thbjattr_thbj-attr-f.
end.
for each temp-thbj-attr:
  delete temp-thbj-attr.
end.

if p-type = 'glob' then do:
run adm/shattri.p (
    input "init":U
  , input ""
  , input 0
  , input {&attr-prt-glob}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tthg
  ) no-error .

if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек GLOB" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo, return error .
end.
end.
if p-type = 'firm' then do:
run adm/shattri.p (
    input "init":U
  , input v-obj-type
  , input v-obj-code
  , input {&attr-prt-firm}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-tthf
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек firm" skip
  error-status:get-message(1) return-value
  view-as alert-box error .
  undo, return error .
end.
end.
if p-type = 'obj' then do:
run adm/shattri.p (
    input "init":U
  , input p-obj-type
  , input p-obj-code
  , input {&attr-prt-obj}
  , input "":U
  , output v-value-character
  , output v-value-date
  , output v-value-decimal
  , output v-value-integer
  , output v-value-logical
  , output v-param-type
  , input-output TABLE-HANDLE v-ttho
  ) no-error .
if error-status:error then do:
  message
  "Не удалось получить начальные значения настроек OBJ" skip
  error-status:get-message(1) skip
  return-value skip
  view-as alert-box error .
  undo, return error .
end.
end.
&scop telo1  IF thbjattr_thbj-attr-o.prop-code = ~{&attr-prt-obj_~{&pole~}~} THEN DO: ~
    ~{&pole~} = thbjattr_thbj-attr-o.property-value-~{&type~}. ~
    ~{&pole~}:private-data in frame {&frame-name} = "recid2=" + string(recid(thbjattr_thbj-attr-o)). ~
    display ~{&pole~} with frame {&frame-name} . ~
END.

&scop telo1g  IF thbjattr_thbj-attr-g.prop-code = ~{&attr-prt-glob_~{&pole~}~} THEN DO: ~
    ~{&pole~} = thbjattr_thbj-attr-g.property-value-~{&type~}. ~
    ~{&pole~}:private-data in frame {&frame-name} = "recid3=" + string(recid(thbjattr_thbj-attr-g)). ~
    display ~{&pole~} with frame {&frame-name} . ~
END.


&scop telo1f  IF thbjattr_thbj-attr-f.prop-code = ~{&attr-prt-firm_~{&pole~}~} THEN DO: ~
    ~{&pole~} = thbjattr_thbj-attr-f.property-value-~{&type~}. ~
    ~{&pole~}:private-data in frame {&frame-name} = "recid4=" + string(recid(thbjattr_thbj-attr-f)). ~
    display ~{&pole~} with frame {&frame-name} . ~
END.

if p-type = "glob" then do:
FOR EACH thbjattr_thbj-attr-g
:

&scop pole invprn0
&scop type logical
{&telo1g}

&scop pole outprncd
&scop type logical
{&telo1g}

&scop pole outrecv
&scop type character
{&telo1g}

&scop pole sort-prd
&scop type logical
{&telo1g}

&scop pole torg2-no
&scop type logical
{&telo1g}

&scop pole outprops
&scop type logical
{&telo1g}

&scop pole rep-artic
&scop type logical
{&telo1g}

  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-g to temp-thbj-attr.

end.
end.
if p-type = "obj" then do:
FOR EACH thbjattr_thbj-attr-o
:
&scop pole outprim
&scop type character
{&telo1}

&scop pole outrubl
&scop type character
{&telo1}

&scop pole outares
&scop type character
{&telo1}

&scop pole outsend
&scop type character
{&telo1}

&scop pole outssdoc
&scop type character
{&telo1}

&scop pole fgdsnind
&scop type logical
{&telo1}

&scop pole in-docpr
&scop type character
{&telo1}

&scop pole outdisc
&scop type character
{&telo1}

&scop pole outegrp
&scop type character
{&telo1}

&scop pole outappr
&scop type character
{&telo1}

&scop pole outdate
&scop type character
{&telo1}

&scop pole outhold
&scop type character
{&telo1}

&scop pole outnum
&scop type character
{&telo1}

&scop pole outobj
&scop type character
{&telo1}

&scop pole outsubs
&scop type character
{&telo1}

&scop pole outt12
&scop type character
{&telo1}

&scop pole outasend
&scop type character
{&telo1}

&scop pole outogr
&scop type character
{&telo1}

&scop pole outR
&scop type character
{&telo1}

&scop pole outB
&scop type character
{&telo1}

&scop pole outC
&scop type character
{&telo1}
  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-o to temp-thbj-attr.

END.
end.
if p-type = "firm" then do:
FOR EACH thbjattr_thbj-attr-f
:
&scop pole factur01
&scop type logical
{&telo1f}

&scop pole incurrat
&scop type logical
{&telo1f}

&scop pole tick-w
&scop type logical
{&telo1f}

  create temp-thbj-attr.
  buffer-copy thbjattr_thbj-attr-f to temp-thbj-attr.

end.
end.

define variable v-tooltip as character no-undo .
define variable v-label   as character no-undo .
define variable v-tooltip-code as character no-undo .
if p-type = "obj":U then do:
&scop telo2 run thbjattr_tooltip in this-procedure ( ~
   input   {&attr-prt-obj} ~
  ,input  "~{&pole~}" ~
  ,output v-tooltip ~
  ,output v-label ~
  ,output v-tooltip-code ~
  ) no-error . ~
v-~{&pole~}:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  ~
v-~{&pole~} = v-~{&pole~}:screen-value .  ~
I-~{&pole~}:private-data = REPLACE ( v-tooltip-code , "`" , "," ) . 

&scop pole fgdsnind
{&telo2}

&scop pole in-docpr
{&telo2}

&scop pole outappr
{&telo2}

&scop pole outdate
{&telo2}

&scop pole outdisc
{&telo2}

&scop pole outegrp
{&telo2}

&scop pole outhold
{&telo2}

&scop pole outnum
{&telo2}

&scop pole outobj
{&telo2}

&scop pole outprim
{&telo2}

&scop pole outrubl
{&telo2}

&scop pole outares
{&telo2}

&scop pole outsend
{&telo2}

&scop pole outasend
{&telo2}

&scop pole outssdoc
{&telo2}

&scop pole outsubs
{&telo2}

&scop pole outt12
{&telo2}

&scop pole outR
{&telo2}

&scop pole outB
{&telo2}

&scop pole outogr
{&telo2}

&scop pole outC
{&telo2}

end.
if p-type = "glob":U then do:
&scop telo2g run thbjattr_tooltip in this-procedure ( ~
   input   {&attr-prt-glob} ~
  ,input  "~{&pole~}" ~
  ,output v-tooltip ~
  ,output v-label ~
  ,output v-tooltip-code ~
  ) no-error . ~
v-~{&pole~}:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  ~
v-~{&pole~} = v-~{&pole~}:screen-value .  ~
I-~{&pole~}:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .

&scop pole invprn0
{&telo2g}

&scop pole outprncd
{&telo2g}

&scop pole outrecv
{&telo2g}

&scop pole sort-prd
{&telo2g}

&scop pole torg2-no
{&telo2g}

&scop pole outprops
{&telo2g}

&scop pole rep-artic
{&telo2g}

end.
if p-type = "firm":U then do:
&scop telo2f run thbjattr_tooltip in this-procedure ( ~
   input   {&attr-prt-firm} ~
  ,input  "~{&pole~}" ~
  ,output v-tooltip ~
  ,output v-label ~
  ,output v-tooltip-code ~
  ) no-error . ~
v-~{&pole~}:screen-value = REPLACE ( entry(2,v-label,":") , "`" , "," ) .  ~
v-~{&pole~} = v-~{&pole~}:screen-value .  ~
I-~{&pole~}:private-data = REPLACE ( v-tooltip-code , "`" , "," ) .

&scop pole factur01
{&telo2f}

&scop pole incurrat
{&telo2f}

&scop pole tick-w
{&telo2f}

end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-proc Dialog-Frame 
PROCEDURE init-proc :
define variable v-i as integer   no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-type as character no-undo .
define variable v-value as character no-undo .
define variable v-found as decimal   no-undo .
  if p-mode = {&update} then do:
  if p-type = "obj":U then do:
    find first obj_thbj-attr exclusive-lock where
              obj_thbj-attr.obj-type = p-obj-type
        and   obj_thbj-attr.obj-code = p-obj-code
        and   obj_thbj-attr.upper-prop-code = {&attr-prt-obj}
        and   obj_thbj-attr.prop-code = '':u no-wait no-error.
     if locked obj_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-prt-obj} skip
        "Запись ПАРАМЕТРОВ по объектам занята"
        view-as alert-box error .
        undo, return error.
      end.

   end.
   if p-type = "firm":U then do: 
    find first frm_thbj-attr exclusive-lock where
              frm_thbj-attr.obj-type = v-obj-type
        and   frm_thbj-attr.obj-code = v-obj-code
        and   frm_thbj-attr.upper-prop-code = {&attr-prt-firm}
        and   frm_thbj-attr.prop-code = '':u no-wait no-error.
     if locked frm_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-prt-obj} skip
        "Запись ПАРАМЕТРОВ по фирмам занята"
        view-as alert-box error .
        undo, return error.
      end.
    end.
    if p-type = "glob":U then do:
    find first glb_thbj-attr exclusive-lock where
              glb_thbj-attr.obj-type = ""
        and   glb_thbj-attr.obj-code = 0
        and   glb_thbj-attr.upper-prop-code = {&attr-prt-glob}
        and   glb_thbj-attr.prop-code = '':u no-wait no-error.
     if locked glb_thbj-attr then do:
        message
        vss-workfile vss-revision vss-description skip
        {&attr-prt-glob} skip
        "Запись Глобальных ПАРАМЕТРОВ  занята"
        view-as alert-box error .
        undo, return error.
      end.
     end. 
  end.
  else do:
    if p-type = "obj":U then do:
    find first obj_thbj-attr no-lock where
          obj_thbj-attr.obj-type = p-obj-type
    and   obj_thbj-attr.obj-code = p-obj-code
    and   obj_thbj-attr.upper-prop-code = {&attr-prt-obj}
    and   obj_thbj-attr.prop-code = '':u no-error.
    end.
    if p-type = "glob":U then do:
    find first glb_thbj-attr no-lock where
          glb_thbj-attr.obj-type = ""
    and   glb_thbj-attr.obj-code = 0
    and   glb_thbj-attr.upper-prop-code = {&attr-prt-glob}
    and   glb_thbj-attr.prop-code = '':u no-error.
    end.
    if p-type = "firm":U then do:
    find first frm_thbj-attr no-lock where
          frm_thbj-attr.obj-type = v-obj-type
    and   frm_thbj-attr.obj-code = v-obj-code
    and   frm_thbj-attr.upper-prop-code = {&attr-prt-firm}
    and   frm_thbj-attr.prop-code = '':u no-error.
    end.
  end.
if p-type = "obj":U then do:
  if not available obj_thbj-attr then do:
    assign
      v-to-create-prt  = true
      .
    message
    substitute ("Внимание!!!&1Параметра obj НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
                 view-as alert-box warning.

  end.
end.
if p-type = "glob":U then do:
  if not available glb_thbj-attr then do:
    assign
      v-to-create-prt-g  = true
      .
    message
    substitute ("Внимание!!!&1Гл.Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
                 view-as alert-box warning.

  end.
end.
if p-type = "firm":U then do:  
  if not available frm_thbj-attr then do:
    assign
      v-to-create-prt-f  = true
      .
    message
    substitute ("Внимание!!!&1 firm Параметра НЕТ в БД!&1Будут показаны ЗНАЧЕНИЯ ПО УМОЛЧАНИЮ",
                {&new-line})
                 view-as alert-box warning.

  end.
end.

  run fill-widgets in this-procedure no-error.
  if error-status:error then undo, return error.
  if p-mode <> {&update} then do:
     disable
     {&page-1p}
     {&page-2p}
     with frame {&frame-name}.
     B-exit:label = "Вы&ход"  .
     hide B-quit in frame {&frame-name} .
  END.
  /*  глобальные настроки.   */
  if p-type = "glob":U then do:
    disable all EXCEPT {&no-dis} with frame {&frame-name}.
    enable
     invprn0  I-invprn0  v-invprn0
      outprncd I-outprncd v-outprncd
      outrecv   I-outrecv B-outrecv v-outrecv
      rep-artic I-rep-artic   v-rep-artic
      outprops  I-outprops  v-outprops
      sort-prd  I-sort-prd    v-sort-prd
      torg2-no   I-torg2-no v-torg2-no
     with frame {&frame-name}.
  end.
  if p-type = "firm":U then do:         /* фирменные*/
    disable all EXCEPT {&no-dis} with frame {&frame-name}.
    enable
      I-factur01  factur01  v-factur01  B-14
      I-incurrat  incurrat  v-incurrat  B-15
      I-tick-w  tick-w    v-tick-w  B-16
     with frame {&frame-name}.
  end.
  if p-type = "obj":U then do:         /* фирменные*/
    disable all EXCEPT {&no-dis} with frame {&frame-name}.
    enable
      fgdsnind  B-20  I-fgdsnind  v-fgdsnind
      outssdoc  B-1 I-outssdoc  v-outssdoc
      in-docpr  B-2 I-in-docpr  v-in-docpr
      outR    B-24  I-outR    v-outR
      outB    B-18  I-outb    v-outb
      outogr    B-13  I-outogr  v-outogr
      outC    B-27  I-outc    v-outc
      FILL-IN-1
      outdisc   B-3 I-outdisc   B-outdisc v-outdisc
      outegrp   B-4 I-outegrp B-outegrp v-outegrp
      outobj    B-9   I-outobj  B-outobj  v-outobj
      outappr   B-5 I-outappr B-outappr   v-outappr
      outdate   B-6 I-outdate   B-outdate v-outdate
      outnum    B-8 I-outnum  B-outnum  v-outnum
      outhold   B-7 I-outhold B-outhold v-outhold
      outsubs   B-12  I-outsubs B-outsubs v-outsubs
      outt12    B-25  I-outt12  B-outt12  v-outt12
      outprim   B-26  I-outprim B-outprim v-outprim
      outrubl   B-19  I-outrubl B-outrubl v-outrubl
      outares   B-21  I-outares B-outares v-outares
      outsend   B-22  I-outsend B-outsend v-outsend
      outasend  B-23  I-outasend  B-outasend  v-outasend
     with frame {&frame-name}.
  end.
  /* не по фирме */

  /*это редактор и он read-only*/

end procedure.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE init-tt Dialog-Frame 
PROCEDURE init-tt :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
    v-obj-type = p-obj-type .
    v-obj-code = p-obj-code .
    if p-obj-type <> {&cmp}  and p-obj-type <> "" then  do:

       { gbl/hostcode.i
         p-obj-type
         p-obj-code
         v-host-code
         }
        v-obj-type = {&cmp}      .
        v-obj-code = v-host-code .
    end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE save-proc Dialog-Frame 
PROCEDURE save-proc :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-sale-add as character no-undo .
define variable v-trf-type like ub.clients.obj-type no-undo .
define variable v-trf-code like ub.clients.obj-code no-undo .
define variable v-param-type as character no-undo .
define variable wh as widget-handle no-undo .
define variable fh as widget-handle no-undo .
define variable v-same as logical no-undo .
define variable v-sameg as logical no-undo .
define variable v-samef as logical no-undo .
IF p-mode = {&LOOKUP} THEN RETURN .
define variable loc#log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    g#db-num
    g#userid
    {&action-head-code-main}
    'actn_nakl-par_update':U
    {&cntxt-object}
    v-cntxt-host-code-obj
    v-cntxt-obj-type
    v-cntxt-obj-code
    0
    0
    0
    true
    loc#log
  }
  if loc#log <> yes then do: return error. end.
if p-type = "glob" then do:
  ASSIGN
invprn0 FRAME {&FRAME-NAME}
outprncd
outrecv
rep-artic
outprops
sort-prd
torg2-no
 .
end.
if p-type = "obj" then do:
  ASSIGN
    fgdsnind FRAME {&FRAME-NAME}
    in-docpr
    outappr
    outdate
    outdisc
    outegrp
    outhold
    outnum
    outobj
    invprn0
    outprncd
    outrecv
    sort-prd
    torg2-no
    outprops
    outprim
    outrubl
    outssdoc
    outsubs
    outt12
    outares
    outsend
    outasend
    outR
    outB
    outogr
    outC
    rep-artic
 .
end.
if p-type = "firm" then do:
  ASSIGN
factur01
incurrat
tick-w
 .
end.
  

assign
  fh = frame {&frame-name}:first-child
  wh = fh:first-child
  .
do while valid-handle(wh):
  if wh:private-data begins "recid2=" then do:

    find first thbjattr_thbj-attr-o where
               recid(thbjattr_thbj-attr-o) = integer(entry(2, wh:private-data, '='))
               no-error .
    if available thbjattr_thbj-attr-o then do:
    assign
    buffer thbjattr_thbj-attr-o:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
    end.
  end.
  if wh:private-data begins "recid3=" then do:
    find first thbjattr_thbj-attr-g where
               recid(thbjattr_thbj-attr-g) = integer(entry(2, wh:private-data, '='))
               no-error .
    if available thbjattr_thbj-attr-g then do:
        assign
           buffer thbjattr_thbj-attr-g:buffer-field ("property-value-" + wh:data-type):buffer-value = wh:input-value.
    end.
  end.

  if wh:private-data begins "recid4=" then do:

    find first thbjattr_thbj-attr-f where
               recid(thbjattr_thbj-attr-f) = integer(entry(2, wh:private-data, '='))
               no-error .
    if available thbjattr_thbj-attr-f then do:
    assign
    buffer thbjattr_thbj-attr-f:buffer-field("property-value-" + wh:data-type):buffer-value = wh:input-value.
    end.
  end.

  wh = wh:next-sibling.
end.

do transaction
on error undo, return error return-value
:

  run thbjattr_set-section in this-procedure (
        input p-obj-type
      , input p-obj-code
      , input {&attr-prt-obj}
      , input table thbjattr_thbj-attr-o
  ) no-error.
  if error-status:error then do:
    message error-status:get-message(1)  skip
    return-value
    view-as alert-box.
    undo, return error.
  end.

  if ( p-obj-type = "" and p-obj-code = 0 ) or p-obj-type = {&cmp} then do:
      run thbjattr_set-section in this-procedure (
            input p-obj-type
          , input p-obj-code
          , input {&attr-prt-firm}
          , input table thbjattr_thbj-attr-f
      ) no-error.
      if error-status:error then do:
        message error-status:get-message(1)  skip
        return-value
        view-as alert-box.
        undo, return error.
      end.
  end.

  if p-obj-type = "" and p-obj-code = 0  then do:
      run thbjattr_set-section in this-procedure (
            input p-obj-type
          , input p-obj-code
          , input {&attr-prt-glob}
          , input table thbjattr_thbj-attr-g
      ) no-error.
      if error-status:error then do:
        message error-status:get-message(1)  skip
        return-value
        view-as alert-box.
        undo, return error.
      end.
  end.

end.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE twowin_custom-add-item Dialog-Frame 
PROCEDURE twowin_custom-add-item :
/* не менять название это callback!!!
------------------------------------------------------------------------------*/
DEFINE INPUT PARAMETER p-twowin-handle AS HANDLE NO-UNDO.
DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.
define variable v-ii as integer no-undo .
define variable v-is-petrolium as logical no-undo .
define variable v-is-pieces as logical no-undo .
define variable v-b-code as integer no-undo .
define variable v-exists as logical no-undo .
DEFINE BUFFER buf_cash-pay FOR ub.cash-pay.
define buffer buf_goods for ub.goods.
define buffer buf_temp_twowin_items for temp_twowin_items.
case v-twowin-point :
end case.

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE twowin_get-bttns Dialog-Frame 
PROCEDURE twowin_get-bttns :
/*------------------------------------------------------------------------------
не менять название! это callback
  ----------------------------------------------------------------------------*/
DEFINE OUTPUT PARAMETER p-bttns as character no-undo .
if p-mode = {&lookup} then do:
  p-bttns = "".
end.
else do:
  p-bttns = "b-add,b-del,b-up,b-down,b-exit".
end.
END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

