/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Библиотека для выбора объекта или списка объекта

Автор: Белоусов Илья Александрович
Дата создания: 05/08/07
Author: Ilia Belousov
Creation date: 05/08/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 04/20/06

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&global-define include_userobjs ok

define temp-table userobjs_temp-user-obj no-undo
  field obj-type as character
  field obj-code as integer

  index xpk is primary unique obj-type obj-code
  .
&if     "{1}" <> "class"
&then
procedure userobjs_clear :
&else
method private void userobjs_clear ():
&endif

  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

  do
  on error undo, return error return-value
  :
    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      delete buf_userobjs_temp-user-obj .
    end.
  end.

end . /* userobjs_clear */

&if     "{1}" <> "class"
&then
procedure userobjs_object-count :
  define output parameter p-total-count as integer   no-undo .
&else
method private void userobjs_object-count (output p-total-count as integer ):
&endif
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

  do
  on error undo, return error return-value
  :
    assign
      p-total-count = 0
    .

    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      assign
        p-total-count = p-total-count + 1
      .
    end.
  end.

end. /* userobjs_object-count */

&if     "{1}" <> "class"
&then
procedure userobjs_append :
   define input  parameter p-obj-type as character no-undo .
   define input  parameter p-obj-code as integer   no-undo .
&else
method private void userobjs_append 
  (p-obj-type as character,
   p-obj-code as integer):
&endif
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      where buf_userobjs_temp-user-obj.obj-type = p-obj-type
        and buf_userobjs_temp-user-obj.obj-code = p-obj-code
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      create buf_userobjs_temp-user-obj .
      assign
        buf_userobjs_temp-user-obj.obj-type = p-obj-type
        buf_userobjs_temp-user-obj.obj-code = p-obj-code
      .
    end.
  end.

end. /* userobjs_append */

&if     "{1}" <> "class"
&then
procedure userobjs_object-exist :
  define output parameter p-object-exist as logical   no-undo .
&else
method private void userobjs_object-exist (output p-object-exist as logical):
&endif
  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

  do
  on error undo, return error return-value
  :
    find first buf_userobjs_temp-user-obj
      no-error .
    if not available buf_userobjs_temp-user-obj
    then do:
      assign
        p-object-exist = false
      .
    end.
    else do:
      assign
        p-object-exist = true
      .
    end.
  end.

end. /* userobjs_object-exist */

&if     "{1}" <> "class"
&then
procedure userobjs_transfer :

  define input  parameter p-callback-handle as handle no-undo .

  define variable vss-description as character no-undo init "userobjs_transfer: Передача списка объектов".

  define buffer buf_userobjs_temp-user-obj for userobjs_temp-user-obj .

  do
  on error undo, return error return-value
  :
    if valid-handle(p-callback-handle) <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Неизвестный указатель на процедуру" skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-callback-handle :get-signature("userobjs_append") = ""
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        substitute("В процедуре &1 не найдена внутренняя процедура userobjs_append"
                  ,p-callback-handle :file-name
                  ) skip
        view-as alert-box error .
      undo, return error return-value .
    end.

    for each buf_userobjs_temp-user-obj
    on error undo, return error return-value
    :
      run userobjs_append in p-callback-handle
        (input  buf_userobjs_temp-user-obj.obj-type
        ,input  buf_userobjs_temp-user-obj.obj-code
        ) .
    end.
  end.

end procedure. /* userobjs_iterate */


procedure userobjs_select-one :
   define input  parameter parparentproc     as widget-handle no-undo .
   define input  parameter p-db-num          as integer   no-undo .
   define input  parameter p-user-id         as character no-undo .
   define input  parameter p-host-code-obj   as integer   no-undo .
   define input  parameter p-obj-type        as character no-undo .
   define input  parameter p-obj-code        as integer   no-undo .
   define output parameter p-user-select     as logical   no-undo .
   define output parameter p-select-obj-type as character no-undo .
   define output parameter p-select-obj-code as character no-undo .

&else
method private void userobjs_select-one(
parparentproc     as widget-handle,
p-db-num          as integer   ,
p-user-id         as character ,
p-host-code-obj   as integer   ,
p-obj-type        as character ,
p-obj-code        as integer   ,
output p-user-select     as logical   ,
output p-select-obj-type as character ,
output p-select-obj-code as character 
):

&endif


  

  do
  on error undo, return error return-value
  :
    &if     "{1}" <> "class"
    &then
    run gbl/userobjs.w
    &else
    run gbl/userobjs_class.p
    &endif
      (input  parparentproc          /* parparentproc        */
      &if     "{1}" <> "class"
      &then
      ,input  this-procedure :handle /* p-callback-handle    */
      &else
      ,input "userobjs_select-one"
      ,input-output table  userobjs_temp-user-obj  by-reference
      &endif
      ,input  p-db-num               /* p-db-num             */
      ,input  p-user-id              /* p-user-id            */
      ,input  p-host-code-obj        /* p-curr-host-code-obj */
      ,input  p-obj-type             /* p-curr-obj-type      */
      ,input  p-obj-code             /* p-curr-obj-code      */
      &if     "{1}" <> "class"
      &then
      ,INPUT  "b-sel"                /* p-bttn               */
      &endif
      ,output p-user-select          /* p-user-select        */
      ,output p-select-obj-type      /* p-select-obj-type    */
      ,output p-select-obj-code      /* p-select-obj-code    */
      ) .
  end.

end. /* userobjs_select-one */

&if     "{1}" <> "class"
&then
procedure userobjs_select-many :

  define input  parameter parparentproc   as widget-handle no-undo .
  define input  parameter p-db-num        as integer   no-undo .
  define input  parameter p-user-id       as character no-undo .
  define input  parameter p-host-code-obj as integer   no-undo .
  define input  parameter p-obj-type      as character no-undo .
  define input  parameter p-obj-code      as integer   no-undo .
  define output parameter p-user-select   as logical   no-undo .
&else
method private void userobjs_select-many(
parparentproc     as widget-handle,
p-db-num          as integer   ,
p-user-id         as character ,
p-host-code-obj   as integer   ,
p-obj-type        as character ,
p-obj-code        as integer   ,
output p-user-select     as logical 
):
&endif
  define variable v-select-obj-type as character no-undo .
  define variable v-select-obj-code as integer   no-undo .

  do
  on error undo, return error return-value
  :
    &if     "{1}" <> "class"
    &then
    run gbl/userobjs.w
    &else
    run gbl/userobjs_class.p
    &endif
      (input  parparentproc          /* parparentproc        */
       &if     "{1}" <> "class"
      &then
      ,input  this-procedure :handle /* p-callback-handle    */
      &else
      ,input "userobjs_select-many"
      ,input-output table  userobjs_temp-user-obj by-reference
      &endif
      ,input  p-db-num               /* p-db-num             */
      ,input  p-user-id              /* p-user-id            */
      ,input  p-host-code-obj        /* p-curr-host-code-obj */
      ,input  p-obj-type             /* p-curr-obj-type      */
      ,input  p-obj-code             /* p-curr-obj-code      */
      &if     "{1}" <> "class"
      &then
      ,INPUT  "b-sel,b-mark"         /* p-bttn               */
      &endif
      ,output p-user-select          /* p-user-select        */
      ,output v-select-obj-type      /* p-select-obj-type    */
      ,output v-select-obj-code      /* p-select-obj-code    */
      ) .

  end.

end. /* userobjs_select-many */

&if     "{1}" <> "class"
&then
procedure thobjs :

   define input        parameter parparentproc     as widget-handle no-undo .
   define input        parameter i-bttns           as character     no-undo . /* список включенных кнопок */
   define input        parameter i-list-mode       as character     no-undo.
   /*{&all} {&db} {&company} "cli-type"*/
   define input        parameter i-obj-type        as character     no-undo.
   define input        parameter i-db-num          as integer       no-undo.
   define input        parameter i-host-code       as integer       no-undo.
   define input-output parameter p-rid-list        as character     no-undo .
&else
method private void thobjs(
   parparentproc     as widget-handle,
   i-bttns           as character,
   i-list-mode       as character,
/*{&all} {&db} {&company} "cli-type"*/
   i-obj-type        as character,
   i-db-num          as integer,
   i-host-code       as integer,
   input-output  p-rid-list as character 
):
&endif
&if     "{1}" <> "class"
&then
run ref/thobjs.p
&else
run ref/thobjs_class.p
&endif
        ( input parparentproc
        &if     "{1}" <> "class"
        &then
         ,input  this-procedure :handle /* p-callback-handle    */
        &else
         ,input-output table  userobjs_temp-user-obj by-reference
        &endif
        , input i-bttns
        , input i-list-mode 
        , input i-obj-type
        , input i-db-num /*p-db-num*/
        , input i-host-code  /*p-host-code*/
        , input-output p-rid-list ) no-error .
end.
/* $Workfile$ e n d */