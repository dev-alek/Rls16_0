/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

История оснований (причин) создания документа по фирме

Автор: Чернова Светлана Александровна
Дата создания: 11/20/06
Author: Svetlana Chernova
Creation date: 11/20/06

create: Булгаков Андрей Николаевич
Дата создания: 11/01/05

*/

/* ***************************  Definitions  ************************** */
/* Parameters Definitions ---                                           */
define input        parameter parParentProc  as widget-handle no-undo.
define input        parameter p-bttns        as character     no-undo.
define input        parameter p-mode         as character     no-undo. /* может быть {&all}, frm, one */
define input        parameter p-host-code    as integer       no-undo.
define input        parameter p-ext-doc-type as character     no-undo.
define input        parameter p-hold-doc     as logical       no-undo.
define input-output parameter p-rid-list     as character     no-undo. /* статьи в выборке */

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision$":U.
define variable vss-author      as character no-undo initial "$Author$":U.
define variable vss-date        as character no-undo initial "$Date$":U.
define variable vss-workfile    as character no-undo initial "$Workfile$":U.
define variable vss-archive     as character no-undo initial "$Archive$":U.
define variable vss-description as character no-undo initial "История оснований (причин) создания документа по фирме":U.

{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/showinf.i         }
{ cmp/library.i         }
{ gbl/flt-def.i         }
{ gbl/waitfram.i        }
{ gbl/fltfield.i        }
{ ref/tmpchgs.i   " " " " "with-action"      }
{ gbl/fltopend.i defproc }
{ gbl/usrfulnf.i }

/* ********************  Preprocessor Definitions  ******************** */
/* Name of first Frame and/or Browse and/or first Query                 */
&scop f-l         Int2Char,Rec2Char
&scop sch-flt     + " для поиска. Поиск первой записи - <ВВОД>; поиск следующей - <CTRL-J>"
&scop description 'История оснований (причин) создания документа по объекту':U
{ gbl/std-func.i {&f-l} }



define buffer buf_changes  for temp-changes.
define buffer buf_c-trn-reason-host  for ub.c-trn-reason-host.
define            buffer sch_c-trn-reason-host for ub.c-trn-reason-host.

define variable filter-point     as character no-undo initial {&table_c-trn-reason-host}.
define variable filter-point0    as character no-undo initial {&table_c-trn-reason-host}.
define variable filter-label     as character no-undo initial {&description}.
define variable filter-label0    as character no-undo initial {&description}.

define variable sort-change-name as character no-undo.
define variable sort-column-name as character no-undo.
define variable sch-field        as character no-undo.
define variable FoundRec         as recid     no-undo.
define variable p-act-codes      as character no-undo initial {&hn-actions}.
define variable p-act-names      as character no-undo initial {&hn-actions-full}.
define variable v-doc-rec          as recid     no-undo.

/* ************************  Function Prototypes ********************** */
function mark-string returns character ( buffer loc-buf for ub.c-trn-reason-host ) :
  define variable v_mark-sign as character no-undo.

  run get-mark-string in this-procedure ( buffer loc-buf, output v_mark-sign ).
  return ( v_mark-sign ).
end function. /* mark-string */

function ShowAction returns character ( input i-act as integer ) :
  define variable v_act as character no-undo.

  run get-action-name in this-procedure ( input i-act, output v_act ).
  return ( v_act ).
end function. /* ShowAction */

function frm-name returns character ( buffer loc-buf for ub.c-trn-reason-host ) :
  define variable v_frm-name as character no-undo.

  run get-frm-name in this-procedure ( buffer loc-buf, output v_frm-name ).
  return ( v_frm-name ).
end function. /* frm-name */

function ext-name returns character ( input i-code as character ) :
  define variable v_ext-name as character no-undo.

  run get-ext-name in this-procedure ( input i-code, output v_ext-name ).
  return ( v_ext-name ).
end function. /* ext-name */

/* Definitions for BROWSE br-rsn-hosts                                */
&scop label-clmn_1-trhst  '*'
&scop form-clmn_1-trhst   'x(1)':U
&scop sort-clmn_1-trhst   mark-string( buffer buf_c-trn-reason-host )
&scop label-clmn_2-trhst  'Фирма'
&scop form-clmn_2-trhst   ">>>>>>>>9":U
&scop sort-clmn_2-trhst   buf_c-trn-reason-host.host-code
&scop label-clmn_3-trhst  'ТД'
&scop form-clmn_3-trhst   "x(2)":U
&scop sort-clmn_3-trhst   buf_c-trn-reason-host.ext-doc-type
&scop label-clmn_4-trhst  'М'
&scop form-clmn_4-trhst   "+/ ":U
&scop sort-clmn_4-trhst   buf_c-trn-reason-host.hold-doc
&scop label-clmn_5-trhst  'Код основания'
&scop form-clmn_5-trhst   "->,>>>,>>>,>>9":U
&scop sort-clmn_5-trhst   buf_c-trn-reason-host.reason-code
&scop label-clmn_6-trhst  'Наименование фирмы'
&scop form-clmn_6-trhst   "x(66)":U
&scop sort-clmn_6-trhst   frm-name( buffer buf_c-trn-reason-host )
&scop label-clmn_7-trhst  'Расширенный тип документа'
&scop form-clmn_7-trhst   "x(39)":U
&scop sort-clmn_7-trhst   ext-name( buf_c-trn-reason-host.ext-doc-type )
&scop dyn_sort-clmn_7-trhst  substitute('dynamic-function(&1ext-name&1, buf_c-trn-reason-host.ext-doc-type)', ~{&double-quote~})
&scop label-clmn_8-trhst  'Изменил'
&scop form-clmn_8-trhst   "x(8)":U
&scop sort-clmn_8-trhst   usrfulnf(buf_c-trn-reason-host.corr-user-name)
&scop dyn_sort-clmn_8-trhst   substitute('dynamic-function(&1usrfulnf&1, buf_c-trn-reason-host.corr-user-name)', ~{&double-quote~})
&scop label-clmn_9-trhst  'Действие'
&scop form-clmn_9-trhst   "x(10)":U
&scop sort-clmn_9-trhst   ShowAction( buf_c-trn-reason-host.action )
&scop dyn_sort-clmn_9-trhst   substitute('dynamic-function(&1ShowAction&1, buf_c-trn-reason-host.action)', ~{&double-quote~})
&scop label-clmn_10-trhst 'Дата корр.'
&scop form-clmn_10-trhst  "99/99/9999":U
&scop sort-clmn_10-trhst  buf_c-trn-reason-host.corr-date
&scop label-clmn_11-trhst 'Время'
&scop form-clmn_11-trhst  "x(8)":U
&scop sort-clmn_11-trhst  STRING( buf_c-trn-reason-host.corr-time, 'HH:MM:SS':U )
&scop label-clmn_12-trhst 'Щепка'
&scop form-clmn_12-trhst  "->,>>>,>>>,>>9":U
&scop sort-clmn_12-trhst  buf_c-trn-reason-host.chip-num
&scop label-clmn_13-trhst 'БД'
&scop form-clmn_13-trhst  ">>>>9":U
&scop sort-clmn_13-trhst  buf_c-trn-reason-host.corr-user-db-num
&scop enabled-clmn-trhst  {&sort-clmn_3-trhst}

&scop label-clmn_1-br-chg 'Изменилось'
&scop form-clmn_1-br-chg  'x(15)':U
&scop sort-clmn_1-br-chg  buf_changes.l_name
&scop label-clmn_2-br-chg 'Было'
&scop form-clmn_2-br-chg  'x(48)':U
&scop sort-clmn_2-br-chg  buf_changes.v_old
&scop label-clmn_3-br-chg 'Стало'
&scop form-clmn_3-br-chg  'x(48)':U
&scop sort-clmn_3-br-chg  buf_changes.v_new
&scop enabled-clmn-br-chg {&sort-clmn_1-br-chg}

/* ***********************  Control Definitions  ********************** */
/* Definitions of the field level widgets                               */
define button b-help   label "Помо&щь"   size-chars 10.00 by 1.00 default.
define button b-mark   label "&*"        size-chars  4.00 by 1.00 default.
define button b-quit    label "Вы&ход"    size-chars 10.00 by 1.00 default auto-end-key.
define button b-lkp   label "&Просмотр" size-chars 10.00 by 1.00 default.
define button b-sch label "&Фильтр"   size-chars 10.00 by 1.00 default.
define button b-sel label "Вы&бор"    size-chars 10.00 by 1.00 default auto-go.

define variable mark-num as integer   no-undo view-as fill-in size-chars  8.00 by 1.00 format "->>>,>>>":U.
define variable sch-rsn  as integer   no-undo view-as fill-in size-chars 15.50 by 1.00 format "->,>>>,>>>,>>>":U.
define variable sch-frm  as integer   no-undo view-as fill-in size-chars 10.50 by 1.00 format ">>>>>>>>>":U.
define variable sch-ext  as character no-undo view-as fill-in size-chars  9.50 by 1.00 format "x(8)":U.
define variable sch-num  as integer   no-undo view-as fill-in size-chars  4.50 by 1.00 format ">>>":U.

/* Query definitions                                                    */
define query br-rsn-hosts for buf_c-trn-reason-host scrolling.

define query br-changes for buf_changes scrolling.

/* Browse definitions                                                   */
define browse br-rsn-hosts query br-rsn-hosts display
{&sort-clmn_1-trhst}  column-label {&label-clmn_1-trhst}  format {&form-clmn_1-trhst}
{&sort-clmn_2-trhst}  column-label {&label-clmn_2-trhst}  format {&form-clmn_2-trhst}
{&sort-clmn_3-trhst}  column-label {&label-clmn_3-trhst}  format {&form-clmn_3-trhst}
{&sort-clmn_4-trhst}  column-label {&label-clmn_4-trhst}  format {&form-clmn_4-trhst}
{&sort-clmn_5-trhst}  column-label {&label-clmn_5-trhst}  format {&form-clmn_5-trhst}
{&sort-clmn_6-trhst}  column-label {&label-clmn_6-trhst}  format {&form-clmn_6-trhst}
{&sort-clmn_7-trhst}  column-label {&label-clmn_7-trhst}  format {&form-clmn_7-trhst}
{&sort-clmn_8-trhst}  column-label {&label-clmn_8-trhst}  format {&form-clmn_8-trhst}
{&sort-clmn_9-trhst}  column-label {&label-clmn_9-trhst}  format {&form-clmn_9-trhst}
{&sort-clmn_10-trhst} column-label {&label-clmn_10-trhst} format {&form-clmn_10-trhst}
{&sort-clmn_11-trhst} column-label {&label-clmn_11-trhst} format {&form-clmn_11-trhst}
{&sort-clmn_12-trhst} column-label {&label-clmn_12-trhst} format {&form-clmn_12-trhst}
{&sort-clmn_13-trhst} column-label {&label-clmn_13-trhst} format {&form-clmn_13-trhst}
enable
{&enabled-clmn-trhst}
with no-row-markers separators size-chars 98.25 by 13.13.

define browse br-changes query br-changes display
{&sort-clmn_1-br-chg}  column-label {&label-clmn_1-br-chg}  format {&form-clmn_1-br-chg}
{&sort-clmn_2-br-chg}  column-label {&label-clmn_2-br-chg}  format {&form-clmn_2-br-chg}
{&sort-clmn_3-br-chg}  column-label {&label-clmn_3-br-chg}  format {&form-clmn_3-br-chg}
enable
{&enabled-clmn-br-chg}
with no-row-markers separators size-chars 98.25 by 4.75.

/* ************************  Frame Definitions  *********************** */
&scop frame-name fr-reason-host
define frame fr-reason-host
  b-quit     at row 1 col  1
  b-mark    at row  1 col 24
  mark-num     at row  1 col 13 no-label                              fgcolor 4
  b-sel  at row  1 col 28
  b-lkp    at row  1 col 48
  b-sch  at row  1 col 78.00
  b-help    at row  1 col 88
  br-rsn-hosts at row  3.00 col  1
  "          ":U at row 16.50 col  1 view-as text size-chars 98.00 by 1.00
  "ПОИСК ПО:"    at row 16.50 col  2.00 view-as text size-chars  9.00 by 1.00 bgcolor 3 fgcolor 15
  sch-rsn        at row 16.50 col 11.50    label "&Коду"
  sch-frm        at row 16.50 col 36.00    label "&Фирме"
  sch-ext        at row 16.50 col 56.50    label "&Типу"
  sch-num        at row 16.50 col 94.75 no-label                              fgcolor 4
    br-changes   at row 18.00 col  1.50
with view-as dialog-box keep-tab-order side-labels no-underline three-d scrollable
     title {&description}
     default-button b-quit cancel-button b-quit.

/* ***************  Runtime Attributes and UIB Settings  ************** */
assign frame fr-reason-host :scrollable = no.
assign br-rsn-hosts         :num-locked-columns in frame  fr-reason-host  = 1
       {&enabled-clmn-trhst} :read-only          in browse br-rsn-hosts = yes
       {&enabled-clmn-br-chg} :read-only          in browse   br-changes   = yes.
assign b-mark    :tooltip in frame fr-reason-host = "Поставить/снять отметку записи"
         b-quit     :tooltip in frame fr-reason-host = "Вернуться в окно вызова"
       b-sch  :tooltip in frame fr-reason-host = "Установить/снять фильтр"
       b-help    :tooltip in frame fr-reason-host = "Интерактивная помощь в формате *.html"
       b-lkp    :tooltip in frame fr-reason-host = "Просмотреть текущую запись"
       b-sel  :tooltip in frame fr-reason-host = "Выбрать текущую(ие) запись(и)"
       br-rsn-hosts :tooltip in frame fr-reason-host = "Список действий над кодами оснований (причин)"
      br-changes   :tooltip in frame fr-reason-host = "Список изменений кода основания (причины)"
      sch-rsn      :tooltip in frame fr-reason-host = "Код основания (причины)" {&sch-flt}
      sch-frm      :tooltip in frame fr-reason-host = "Код фирмы" {&sch-flt}
      sch-ext      :tooltip in frame fr-reason-host = "Расширенный тип документа" {&sch-flt}
      sch-num      :tooltip in frame fr-reason-host = "Количество найденных записей"
      mark-num     :tooltip in frame fr-reason-host = "Отмеченные записи".

/* ************************  Control Triggers  ************************ */
on delete-character of br-rsn-hosts in frame fr-reason-host do:
  if b-mark :sensitive in frame fr-reason-host then do: apply "CHOOSE":U to b-mark in frame fr-reason-host. end.
end.

on insert-mode of br-rsn-hosts in frame fr-reason-host do:
  if           b-mark   :sensitive in frame fr-reason-host then do:
    apply "CHOOSE":U to b-mark     in frame fr-reason-host.
  end.
  else if b-sel :sensitive in frame fr-reason-host then do:
    apply "CHOOSE":U to b-sel   in frame fr-reason-host.
  end.
end.

on choose of b-mark in frame fr-reason-host do: /* * */
  if available buf_c-trn-reason-host then do:
    { gbl/markstrn.i buf_c-trn-reason-host p-rid-list }
    br-rsn-hosts :refresh( ) in frame fr-reason-host.
    if last-event :function <> "MOUSE-SELECT-DBLCLICK" then do:
      br-rsn-hosts :select-next-row( ) in frame fr-reason-host.
    end.
    apply "VALUE-CHANGED":U to br-rsn-hosts in frame fr-reason-host.
    if num-entries( p-rid-list ) = 0 then do:
       hide
       mark-num   in frame fr-reason-host.
     end.
    else do:
      display
      num-entries( p-rid-list ) @ mark-num
      with frame fr-reason-host. end.
  END.
  apply "ENTRY":U to br-rsn-hosts in frame fr-reason-host.
end.

on choose of b-quit in frame fr-reason-host do: /* Выход */
  run gbl/markqwa.p ( input b-mark :sensitive, input p-rid-list ) no-error.
  if error-status :error then do:
    return no-apply.
  end.
end.

on choose of b-sch in frame fr-reason-host do: /* Фильтр */
  {&SetCursorWait}
  run proc-filter in this-procedure no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on choose of b-sel in frame fr-reason-host do: /* Выбор */
  if not available buf_c-trn-reason-host then do:
    return no-apply.
  end.
  if p-rid-list = "":U
  or b-mark :sensitive = no then do:
    assign p-rid-list = string( recid( buf_c-trn-reason-host ) ).
  end.
end.

on choose of b-lkp in frame fr-reason-host do: /* Просмотр */
  define buffer buf_doc for ub.c-trn-reason-host.

  { gbl/stdbtn.i }
  if not available buf_c-trn-reason-host then do:
    message
    "Неправильно выбрана строка."
    view-as alert-box error.
    return no-apply.
  end.
  assign v-doc-rec = recid( buf_c-trn-reason-host ).
  find first buf_doc no-lock where
             buf_doc.host-code     = buf_c-trn-reason-host.host-code    and
             buf_doc.ext-doc-type  = buf_c-trn-reason-host.ext-doc-type and
             buf_doc.hold-doc      = buf_c-trn-reason-host.hold-doc     and
             buf_doc.chip-num     <> buf_c-trn-reason-host.chip-num     and
             recid( buf_doc )     <> recid( buf_c-trn-reason-host )     no-error.
  if not available buf_doc then do:
    message 'Данная запись истории пуста, т.к. соответствует СОЗДАНИЮ записи.' skip
            'Просмотр невозможен!'
    view-as alert-box.
    return no-apply.
  end.

  run str/hstcrsna.w ( input parParentProc
                     , input {&lookup}
                     , input-output v-doc-rec ).
  reposition br-rsn-hosts to recid v-doc-rec no-error.
  if error-status :error then do:
    reposition br-rsn-hosts to row 1 no-error.
  end.
  apply "ENTRY":U         to br-rsn-hosts in frame fr-reason-host.
  apply "VALUE-CHANGED":U to br-rsn-hosts in frame fr-reason-host.
end.

on return                of br-rsn-hosts in frame fr-reason-host or
   mouse-select-dblclick of br-rsn-hosts in frame fr-reason-host do:
  if           b-mark   :sensitive in frame fr-reason-host then do:
      apply "CHOOSE":U to b-mark   in frame fr-reason-host.
  end.
  else IF b-sel :sensitive in frame fr-reason-host then do:
      apply "CHOOSE":U to b-sel in frame fr-reason-host.
  end.
end.

on value-changed of br-rsn-hosts in frame fr-reason-host do:
  run proc-view-changes in this-procedure no-error.
end.

on entry of sch-rsn in frame fr-reason-host do:
  assign sch-ext :screen-value in frame fr-reason-host = "":U
         sch-frm :screen-value in frame fr-reason-host = "":U.
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display
  sch-rsn
  with frame fr-reason-host.
end.

on entry of sch-frm in frame fr-reason-host do:
  assign sch-ext :screen-value in frame fr-reason-host = "":U
         sch-rsn :screen-value in frame fr-reason-host = "":U.
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display
  sch-frm
  with frame fr-reason-host.
end.

on entry of sch-ext in frame fr-reason-host do:
  assign sch-rsn :screen-value in frame fr-reason-host = "":U
         sch-frm :screen-value in frame fr-reason-host = "":U.
  if sch-field <> self :name then do:
    assign sch-num   = 0
           sch-field = self :name
           FoundRec  = ?.
  end.
  display
  sch-ext
  with frame fr-reason-host.
end.

on leave of sch-rsn in frame fr-reason-host do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num
  in frame fr-reason-host.
end.

on leave of sch-frm in frame fr-reason-host do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num
  in frame fr-reason-host.
end.

on leave of sch-ext in frame fr-reason-host do:
  if lookup( last-event :function, "MOUSE-SELECT-DBLCLICK,RETURN" ) = 0 and last-event :label <> "CTRL-J" then do:
    assign FoundRec = ?
           sch-num  = 0.
  end.
  hide sch-num in frame fr-reason-host.
end.

on CTRL-J of sch-rsn in frame fr-reason-host do: /* код основания */
  {&SetCursorWait}
  if input frame fr-reason-host sch-rsn <> sch-rsn then do:
    assign sch-rsn.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame fr-reason-host.
  end.
  run proc-find-rsn in this-procedure ( input yes, input sch-rsn ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on return of sch-rsn in frame fr-reason-host do: /* код основания */
  {&SetCursorWait}
  assign sch-rsn.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame fr-reason-host.
  run proc-find-rsn in this-procedure ( input no,  input sch-rsn ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on mouse-select-dblclick of sch-rsn in frame fr-reason-host do: /* код основания */
  {&SetCursorWait}
  if input frame fr-reason-host sch-rsn <> sch-rsn then do:
    assign sch-rsn.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame fr-reason-host.
  end.
  run proc-find-rsn in this-procedure ( input yes, input sch-rsn ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on CTRL-J of sch-frm in frame fr-reason-host do: /* код фирмы */
  {&SetCursorWait}
  if input frame fr-reason-host sch-frm <> sch-frm then do:
    assign sch-frm.
    assign FoundRec = ?
           sch-num  = 0.
    hide
    sch-num  in frame fr-reason-host.
  end.
  run proc-find-frm in this-procedure ( input yes, input sch-frm ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on return of sch-frm in frame fr-reason-host do: /* код фирмы */
  {&SetCursorWait}
  assign sch-frm.
  assign FoundRec = ?
         sch-num  = 0.
  hide
  sch-num  in frame fr-reason-host.
  run proc-find-frm in this-procedure ( input no,  input sch-frm ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
   end.
end.

on mouse-select-dblclick of sch-frm in frame fr-reason-host do: /* код фирмы */
  {&SetCursorWait}
  if input frame fr-reason-host sch-frm <> sch-frm then do:
    assign sch-frm.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame fr-reason-host.
  end.
  run proc-find-frm in this-procedure ( input yes, input sch-frm ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on CTRL-J of sch-ext in frame fr-reason-host do: /* название */
  {&SetCursorWait}
  if input frame fr-reason-host sch-ext <> sch-ext then do:
    assign sch-ext.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame fr-reason-host.
  end.
  run proc-find-ext in this-procedure ( input yes, input sch-ext ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on return of sch-ext in frame fr-reason-host do: /* название */
  {&SetCursorWait}
  assign sch-ext.
  assign FoundRec = ?
         sch-num  = 0.
  hide   sch-num  in frame fr-reason-host.
  run proc-find-ext in this-procedure ( input no,  input sch-ext ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

on mouse-select-dblclick of sch-ext in frame fr-reason-host do: /* название */
  {&SetCursorWait}
  if input frame fr-reason-host sch-ext <> sch-ext then do:
    assign sch-ext.
    assign FoundRec = ?
           sch-num  = 0.
    hide   sch-num  in frame fr-reason-host.
  end.
  run proc-find-ext in this-procedure ( input yes, input sch-ext ) no-error.
  {&SetCursorNo}
  if error-status :error then do:
    return no-apply.
  end.
end.

{ gbl/hot-key.i b-help   }
{ gbl/hot-key.i b-mark   }
{ gbl/hot-key.i b-lkp   }
{ gbl/hot-key.i b-sel }

/* ***************************  Main Block  *************************** */
/* Parent the dialog-box to the ACTIVE-WINDOW, if there is no parent. */
if valid-handle( active-window ) and frame fr-reason-host :parent = ? then frame fr-reason-host :parent = active-window.

/* Restore the current-window if it is an icon. Otherwise the dialog box will be hidden */
if current-window :window-state = window-minimized then do: current-window :window-state = window-normal. end.

/* Add Trigger to equate WINDOW-CLOSE to END-ERROR */
on window-close of frame fr-reason-host do: apply "END-ERROR":U to self. end.

{ gbl/app_help.i }

{ gbl/mv-clmn.i
    &ext-col      = 13
    &frame-name   = fr-reason-host
    &browse-name  = br-rsn-hosts
    &table-name   = "buf_c-trn-reason-host"
    &start-column = 2              }

{ gbl/srt-clmd.i
    &ext-col              = 13
    &frame-name           = fr-reason-host
    &browse-name          = br-rsn-hosts
    &table-name           = "buf_c-trn-reason-host"
    &start-column         = 2
    &label-clmn_2         = "{&label-clmn_2-trhst}"
    &sort-clmn_2          = "{&sort-clmn_2-trhst}"
    &label-clmn_3         = "{&label-clmn_3-trhst}"
    &sort-clmn_3          = "{&sort-clmn_3-trhst}"
    &label-clmn_4         = "{&label-clmn_4-trhst}"
    &sort-clmn_4          = "{&sort-clmn_4-trhst}"
    &label-clmn_5         = "{&label-clmn_5-trhst}"
    &sort-clmn_5          = "{&sort-clmn_5-trhst}"
    &label-clmn_7         = "{&label-clmn_7-trhst}"
    &sort-clmn_7          = "{&sort-clmn_7-trhst}"
    &dyn_sort-clmn_7      = "{&dyn_sort-clmn_7-trhst}"
    &label-clmn_8         = "{&label-clmn_8-trhst}"
    &sort-clmn_8          = "{&sort-clmn_8-trhst}"
    &dyn_sort-clmn_8      = "{&dyn_sort-clmn_8-trhst}"
    &label-clmn_9         = "{&label-clmn_9-trhst}"
    &sort-clmn_9          = "{&sort-clmn_9-trhst}"
    &dyn_sort-clmn_9      = "{&dyn_sort-clmn_9-trhst}"
    &label-clmn_10        = "{&label-clmn_10-trhst}"
    &sort-clmn_10         = "{&sort-clmn_10-trhst}"
    &label-clmn_11        = "{&label-clmn_11-trhst}"
    &sort-clmn_11         = "{&sort-clmn_11-trhst}"
    &label-clmn_12        = "{&label-clmn_12-trhst}"
    &sort-clmn_12         = "{&sort-clmn_12-trhst}"
    &label-clmn_13        = "{&label-clmn_13-trhst}"
    &sort-clmn_13         = "{&sort-clmn_13-trhst}"
    &open-query           = "run OpenBr in this-procedure ( input yes, input no, input '':U )."
    &open-query-otherwise = "run OpenBr in this-procedure ( input yes, input no, input '':U )."
    &sort-column-name     = "sort-column-name"
    &re-move-clmn         = "no"
    &mv-brw-default       = "yes"                                                               }

{ gbl/mv-clmn.i
    &ext-col      = 3
    &frame-name   = fr-reason-host
    &browse-name  = br-changes
    &table-name   = "buf_changes"
    &start-column = 1              }


/* Now enable the interface and wait for the exit condition.            */
/* (NOTE: handle ERROR and END-KEY so cleanup code will always fire.    */
Main-Block:
do on error   undo Main-Block, leave Main-Block
   on end-key undo Main-Block, leave Main-Block :
  if lookup( p-mode, '{&bef-all},frm,one':U ) = 0 then do:
    message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
            "Неверное значение параметра вызова p-mode:" p-mode
    view-as alert-box error.
    return.
  end. /* p-mode */
  if p-mode = 'frm':U and
     p-mode = 'one':U then do:
    find first sch_c-trn-reason-host no-lock where
               sch_c-trn-reason-host.host-code = p-host-code no-error.
    if not available sch_c-trn-reason-host then do:
      message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
              'Неверное значение параметра вызова p-host-code:' p-host-code '.'
      view-as alert-box error.
      return.
    end.
  end. /* p-mode = 'frm':U */
  if p-mode = 'one':U then do:
    find first sch_c-trn-reason-host no-lock where
               sch_c-trn-reason-host.host-code    = p-host-code    and
               sch_c-trn-reason-host.ext-doc-type = p-ext-doc-type and
               sch_c-trn-reason-host.hold-doc     = p-hold-doc     no-error.
    if not available sch_c-trn-reason-host then do:
      message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
              'Неверное значение параметров вызова p-ext-doc-type и p-hold-doc:' p-ext-doc-type p-hold-doc '.'
      view-as alert-box error.
      return.
    end.
  end. /* p-mode = 'one':U */
  if p-rid-list <> "":U then do:
    find first sch_c-trn-reason-host no-lock where
        recid( sch_c-trn-reason-host ) = integer( entry( 1, p-rid-list ) ) no-error.
    if not available sch_c-trn-reason-host then do:
      message vss-workfile skip vss-revision skip vss-date skip( 1 ) vss-description skip( 1 )
              'Неверное значение параметра вызова p-rid-list: "' + p-rid-list + '".'
      view-as alert-box error.
      return error.
    end.
    else do:
      assign v-doc-rec = recid( sch_c-trn-reason-host ).
    end.
  end.

  enable  b-mark   when lookup( "b-mark":U,   p-bttns ) > 0 or p-bttns = "*"
          b-sel when lookup( "b-sel":U, p-bttns ) > 0 or p-bttns = "*"
          b-sch b-help b-quit b-lkp br-rsn-hosts br-changes sch-rsn sch-frm sch-ext
  with frame fr-reason-host.
  {&SetCursorWait}
  run OpenBr in this-procedure ( input yes, input no, input '':U ).
  hide mark-num in frame fr-reason-host.
  hide  sch-num in frame fr-reason-host.
  if p-rid-list <> "":U then do:
    reposition br-rsn-hosts to recid v-doc-rec no-error.
  end.
  br-rsn-hosts :set-repositioned-row( 5, "CONDITIONAL":U ).
  {&SetCursorNo}

  wait-for go of frame fr-reason-host.
end.
hide frame fr-reason-host no-pause.

/* **********************  Internal Procedures  *********************** */
procedure OpenBr :
define input parameter p-open-query     as logical   no-undo.
define input parameter p-find-next      as logical   no-undo.
define input parameter p-find-condition as character no-undo.

define variable l-query-was-opened as logical   no-undo.
define variable title0             as character no-undo.
define variable sort-column-phrase as character no-undo.
define variable l-open-query       as logical   no-undo.

case sort-column-name :
  when "":U then do:
    assign sort-column-phrase = "":U.
  end.
  otherwise      do:
    assign sort-column-phrase = "by " + sort-column-name.
 end.
end case. /* sort-column-name */

&scop flt-open-open-query         open query br-rsn-hosts for each buf_c-trn-reason-host
&scop flt-open-dyn_open-query     for each buf_c-trn-reason-host
&scop flt-open-query-handle       query br-rsn-hosts:handle
&scop flt-open-open-query-tail
&scop flt-open-dyn_open-query-tail ''
&scop flt-open-query-was-opened   l-query-was-opened
&scop flt-open-sort-column-phrase sort-column-phrase
&scop flt-open-call-point         filter-point
&scop flt-open-set-filter-name    set-filter-name
&scop flt-open-indexed-reposition
&scop flt-open-query              p-open-query
&scop flt-open-table-name         buf_c-trn-reason-host
&scop flt-open-search-option      no-lock
&scop flt-open-find-next          p-find-next
&scop flt-open-find-recid         v-doc-rec
&scop flt-open-find-condition     p-find-condition
&scop flt-open-find-buffer-name   buf_c-trn-reason-host
&scop flt-open-debug-file
&scop flt-open-waitfram           yes

assign
filter-point = substitute('&1 - &2', filter-point0, p-mode)
filter-label = substitute('&1 - &2', filter-label0, p-mode)
.

case p-mode :
  when {&all}  then do:
    assign
    frame fr-reason-host :title = "История оснований (причин) создания документов по объектам".
    { gbl/fltopend.i
        &where-cond = " yes "
        &use-ind    = "  "
        &by         = "  "  }
  end. /* {&all} */
  when 'frm':U then do:
    assign
    frame fr-reason-host :title =  substitute( 'История основания (причины) создания документов по фирме &1', p-host-code ).
    { gbl/fltopend.i
        &where-cond = " buf_c-trn-reason-host.host-code = p-host-code "
        &dyn_where-cond = " substitute('buf_c-trn-reason-host.host-code = &1', p-host-code )"
        &use-ind    = "  "
        &by         = "  "                                    }
  end. /* 'frm':U */
  when 'one':U then do:
    assign
        frame fr-reason-host :title =  substitute( 'История основания (причины) создания документа "&1" &2по фирме &3',
                  entry( lookup( p-ext-doc-type, {&TDEDT_List} ), {&TDEDT_List-full} ),
                  ( if p-hold-doc = yes then "(межфирменные перемещения) " else "":U ),
                  p-host-code ).
    { gbl/fltopend.i
        &where-cond = " buf_c-trn-reason-host.host-code    = p-host-code    and ~
                        buf_c-trn-reason-host.ext-doc-type = p-ext-doc-type and ~
                        buf_c-trn-reason-host.hold-doc     = p-hold-doc  "
        &dyn_where-cond = " substitute('buf_c-trn-reason-host.host-code    = &1    and ~
                        buf_c-trn-reason-host.ext-doc-type = &2&3&2 and ~
                        buf_c-trn-reason-host.hold-doc     = &4 ', p-host-code, ~{&double-quote~}, p-ext-doc-type, p-hold-doc )"

        &use-ind    = "  "
        &by         = "  "                                            }
  end. /* 'one':U */
end case. /* p-mode */
if p-open-query <> yes and v-doc-rec <> ? then
reposition br-rsn-hosts to recid v-doc-rec no-error.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query br-rsn-hosts:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
run WaitFram-Hide in this-procedure.
apply "VALUE-CHANGED":U to br-rsn-hosts in frame fr-reason-host.
apply "ENTRY":U         to br-rsn-hosts in frame fr-reason-host.
end procedure. /* OpenBr */

procedure proc-filter :
  &scop common input '':U, input-output fld, input-output lab, input-output spr, input-output dim
  assign tbl      = 'c-trn-reason'
         join-tbl = 'buf_c-trn-reason-host'
         fld      = '':U
         lab      = '':U
         spr      = '':U
         dim      = '0'.

  {&SetCursorWait}
  run fltfield-add in this-procedure ( input 'host-code',    input 'Код фирмы',      {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'ext-doc-type', input 'Расширенн. тип', {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'hold-doc',     input 'Межфирменный',   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'reason-code',  input 'Код причины',    {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'chip-num',     input 'Щепка',          {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-user-db-num',  input 'Номер БД',       {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-user-name',    input 'Имя',            {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-date',    input 'Дата коррекции', {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'corr-time',    input 'Время в сек.',   {&common} ) no-error.
  run fltfield-add in this-procedure ( input 'action',       input 'Действие',       {&common} ) no-error.

  Filter-Block:
  do on error   undo Filter-Block, leave Filter-Block
     on end-key undo Filter-Block, leave Filter-Block :
    run gbl/filter.w ( input parParentProc
                    ,input filter-point + {&delim-par} + filter-label
                    ,input tbl
                    ,input join-tbl
                    ,input fld
                    ,input lab
                    ,input spr
                    ,input dim            ).
    if return-value = {&flt-undo-value} then do:
      apply "ENTRY":U to browse br-rsn-hosts.
      return no-apply.
    end.
    assign mark-num = 0
           sch-num  = 0.
    hide   mark-num in frame fr-reason-host.
    hide   sch-num  in frame fr-reason-host.
    {&SetCursorWait}
    run OpenBr in this-procedure ( input yes, input no, input '':U ).
    assign b-sch :tooltip in frame fr-reason-host = "Установить/снять фильтр".
    {&SetCursorNo}
  end. /* Filter-Block */
end procedure. /* proc-filter */

procedure proc-view-changes :
for each temp-changes :
  delete temp-changes.
end.
if not available buf_c-trn-reason-host then do:
  run OpenChanges in this-procedure .
  return.
end.

&scop fields-name-list "host-code,ext-doc-type,hold-doc,reason-code"

define variable v-label-param as character no-undo .

v-label-param =
  "host-code" + {&delim-par} + "Код фирмы" + {&delim-par} + "" + {&delim-flf}
 + "ext-doc-type" + {&delim-par} + "Расш.тип док-та" + {&delim-par} + "" + {&delim-flf}
 + "hold-doc" + {&delim-par} + "Межфирменный." + {&delim-par} + "" + {&delim-flf}
 + "reason-code" + {&delim-par} + "Код основания" + {&delim-par}.
 run proc-full-temp-changes in this-procedure (
                                             input  (buf_c-trn-reason-host.action = integer({&hn-create}))
                                            ,input  (buf_c-trn-reason-host.action = integer({&hn-delete}))
                                            ,input  buffer  buf_c-trn-reason-host:handle
                                            ,input  {&table_c-trn-reason-host}
                                            ,input  {&fields-name-list}
                                            ,input  v-label-param).



run OpenChanges in this-procedure .
end procedure. /* proc-view-changes */

procedure OpenChanges :
 open query br-changes for each buf_changes.
end procedure. /* OpenChanges */

{ gbl/setfltnm.i }

procedure get-mark-string :
  define        parameter buffer loc-buf for ub.c-trn-reason-host.
  define output parameter        p-sign  as  character no-undo.

  assign p-sign = ( if lookup( Rec2Char( recid( loc-buf ) ), p-rid-list ) > 0 then chr( 42 ) else chr( 32 ) ).
end procedure. /* get-mark-string */

procedure get-action-name :
  define  input parameter p-code as integer   no-undo.
  define output parameter p-name as character no-undo.

  define variable v_code  as character no-undo.
  define variable j_entry as integer   no-undo.

  if p-code = ? or p-code = 0 then do: assign p-name = "":U. end.
  assign v_code  = Int2Char( p-code ).
  assign j_entry = lookup(   v_code, p-act-codes ).
  assign p-name  = ( if j_entry = 0 then "":U else entry( j_entry, p-act-names ) ).
end procedure. /* get-action-name */

procedure get-frm-name :
  define        parameter buffer loc-buf for ub.c-trn-reason-host.
  define output parameter        p-name  as  character no-undo.

  define buffer buf_cli for ub.clients.

  find first buf_cli no-lock where
             buf_cli.obj-type = {&cmp}            and
             buf_cli.obj-code = loc-buf.host-code no-error.
  assign p-name = ( if available buf_cli then buf_cli.obj-name else ( {&cmp} + " ":U + Int2Char( loc-buf.host-code ) ) ).
end procedure. /* get-frm-name */

procedure get-ext-name :
  define  input parameter p-code as character no-undo.
  define output parameter p-name as character no-undo.

  define variable v_code  as character no-undo.
  define variable j_entry as integer   no-undo.

  assign j_entry = lookup( p-code, {&TDEDT_List} ).
  assign p-name  = ( if j_entry > 0 then entry( j_entry, {&TDEDT_List-full} ) else "":U ).
end procedure. /* get-ext-name */

procedure proc-find-rsn :
  define input parameter p-next as logical no-undo.
  define input parameter p-code as integer no-undo.

  {&SetCursorWait}
  run OpenBr in this-procedure ( input no,
                                 input p-next,
                                 input substitute( " and buf_c-trn-reason-host.reason-code = &1 ", p-code ) ).
  if v-doc-rec <> ? then do:
    if FoundRec = ? then do: assign FoundRec = v-doc-rec. end.
    if FoundRec = v-doc-rec then do: assign sch-num = 0. end.
    assign  sch-num = sch-num + 1.
    display sch-num with frame fr-reason-host.
  end.
  else do:
    assign  sch-num = 0.
    hide    sch-num in frame fr-reason-host.
  end.
  apply "ENTRY":U to sch-rsn in frame fr-reason-host.
  {&SetCursorNo}
end procedure. /* proc-find-rsn */

procedure proc-find-frm :
  define input parameter p-next as logical no-undo.
  define input parameter p-code as integer no-undo.

  {&SetCursorWait}
  run OpenBr in this-procedure ( input no,
                                 input p-next,
                                 input substitute( " and buf_c-trn-reason-host.host-code = &1 ", p-code ) ).
  if v-doc-rec <> ? then do:
    if FoundRec = ? then do: assign FoundRec = v-doc-rec. end.
    if FoundRec = v-doc-rec then do: assign sch-num = 0. end.
    assign  sch-num = sch-num + 1.
    display sch-num with frame fr-reason-host.
  end.
  else do:
    assign  sch-num = 0.
    hide    sch-num in frame fr-reason-host.
  end.
  apply "ENTRY":U to sch-frm in frame fr-reason-host.
  {&SetCursorNo}
end procedure. /* proc-find-frm */

procedure proc-find-ext :
  define input parameter p-next as logical   no-undo.
  define input parameter p-name as character no-undo.

  {&SetCursorWait}
  assign p-name = replace( p-name, {&double-quote}, {&double-quote} + {&double-quote} )
         p-name = replace( p-name, {&single-quote}, {&single-quote} + {&single-quote} )
         p-name = {&double-quote} + p-name + {&double-quote}.
  run OpenBr in this-procedure ( input no,
                                 input p-next,
                                 input substitute( " and buf_c-trn-reason-host.ext-doc-type = &1 ", p-name ) ).
  if v-doc-rec <> ? then do:
    if FoundRec = ? then do: assign FoundRec = v-doc-rec. end.
    if FoundRec = v-doc-rec then do: assign sch-num = 0. end.
    assign  sch-num = sch-num + 1.
    display sch-num with frame fr-reason-host.
  end.
  else do:
    assign  sch-num = 0.
    hide    sch-num in frame fr-reason-host.
  end.
  apply "ENTRY":U to sch-ext in frame fr-reason-host.
  {&SetCursorNo}
end procedure. /* proc-find-ext */