/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Настройка отчета о движении материальных ценностей (закладка № 2)

Автор: Гридчина Полина Дмитриевна
Дата создания: 09/04/06
Author: Polina Gridchina
Creation date: 09/04/06

*/

create widget-pool .

/* ********************  Preprocessor Definitions  ******************** */
&scop PROCEDURE-TYPE      SmartObject
&scop ADM-SUPPORTED-LINKS Record-Source,Record-Target,TableIO-Target
&scop FRAME-NAME          F-Main
&scop WINDOW-NAME         CURRENT-WINDOW
&scop ENABLED-OBJECTS     Tog-Obj Tog-Total
&scop DISPLAYED-OBJECTS   Tog-Obj Tog-Total Tog-Excel

/* ***************************  Definitions  ************************** */
/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "Настройка отчета о движении материальных ценностей (закладка № 2)":U.

/* Global, Shared, Preprocessor Definitions ---                         */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/showinf.i }
{ cmp/r-page1.i  }

/* Local Variable Definitions ---                                       */
define variable State-Source as widget-handle no-undo .

/* ***********************  Control Definitions  ********************** */
define variable Tog-Total as logical   no-undo initial yes label "Только итоги"
  view-as toggle-box size-chars 38.25 by 1.00 .

define variable Tog-Obj   as logical   no-undo initial yes label "Раздельно по объектам"
  view-as toggle-box size-chars 38.25 by 1.00 .

define variable Tog-Excel as logical   no-undo initial  no label "Только в Excel"
  view-as toggle-box size-chars 19.00 by 1.00 fgcolor 4 .

/* ************************  Frame Definitions  *********************** */
define frame {&FRAME-NAME}
  Tog-Obj   at row  2.50 col  2.75
  Tog-Total at row  4.00 col  2.75
  Tog-Excel at row 17.50 col 51.38
with 1 down no-box keep-tab-order overlay side-labels no-underline three-d at col 1 row 1 scrollable .

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign
  frame {&FRAME-NAME} :scrollable = no
  frame {&FRAME-NAME} :hidden     = yes
.

/* ************************* Included-Libraries *********************** */
{ src/adm/method/viewer.i }

/* ************************  Control Triggers  ************************ */
/* ***************************  Main Block  *************************** */
{ gbl/personly.i }

/* If testing in the UIB, initialize the SmartObject. */
&if defined( UIB_IS_RUNNING ) <> 0 &then
  run dispatch in this-procedure
    ( input 'initialize':U
    ) .
&endif

/* **********************  Internal Procedures  *********************** */
procedure disable_UI :
  hide frame {&FRAME-NAME} no-pause .
  if this-procedure :persistent
  then do:
    delete procedure this-procedure .
  end.
end procedure. /* disable_UI */

procedure local-initialize :
  run dispatch in this-procedure
    ( input 'initialize':U
    ) .
  assign
    Tog-Obj   = yes
    Tog-Total = no
  .
  display
    Tog-Obj
    Tog-Total
  with frame {&FRAME-NAME} .
end procedure. /* local-initialize */

procedure my-report :
  run rep/r-wth-dc.p
    ( input my-handle
    , input Tog-Obj
    , input Tog-Total
    ) no-error .
  if error-status :error
  then do:
    message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
            "Ошибка выполнения отчета" skip( 0 )
            return-value skip( 0 )
            error-status :get-message( 1 ) skip( 1 )
    view-as alert-box error .
  end.
end procedure. /* my-report */

procedure my-var :
  define variable l_shift-on as logical no-undo .

  assign frame {&FRAME-NAME} Tog-Excel
                             Tog-Obj
                             Tog-Total
  .
  /* строки в которых содержатся выбранные объекты */
  assign
    STR-obj-type = "":U
    STR-obj-code = "":U
    STR-obj-name = "":U
    STR-obj      = "":U
  .
  for each obj-list
  :
    { gbl/objat.i
        obj-list.obj-type
        obj-list.obj-code
        "'shift-on=request'"
        l_shift-on
        no-error
    }
    if error-status :error or
       l_shift-on <> yes
    then do:
      delete obj-list .
      next .
    end.
    assign
      STR-obj-type = STR-obj-type + obj-list.obj-type + ","
      STR-obj-code = STR-obj-code + string( obj-list.obj-code ) + ","
      STR-obj-name = STR-obj-name + obj-list.obj-name + ","
      STR-obj      = STR-obj      + obj-list.obj-type + "#" + string( obj-list.obj-code ) + ","
    .
  end. /* for each obj-list */
  assign
    ReportName   = "Отчет о движении материальных ценностей"
    ReportHeader = "":U
  .
end procedure. /* my-var */

procedure state-changed :
  define input parameter p-issuer-hdl as handle    no-undo .
  define input parameter p-state      as character no-undo .

  case p-state : /* Object instance CASEs can go here to replace standard behavior or add new cases. */
    when "link-changed":U
    then do:
      run my-var in this-procedure .
    end.
  end case. /* p-state */
end procedure. /* state-changed */