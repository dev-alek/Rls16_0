/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Получение контекста сессии

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/16/03
Author: Bakhtadze Natalya
Creation date: 12/16/03

v-cntxt-current-context
v-cntxt-host-code-obj
v-cntxt-obj-type
v-cntxt-obj-code

Допустимые значения переменных

v-cntxt-db-num         код_текущей_БД
v-cntxt-userid         идентификатор_пользовател
v-cntxt-level          {&cntxt-global} {&cntxt-firm} {&cntxt-object}
v-cntxt-host-code-obj  0               код_фирмы     код_фирмы
v-cntxt-obj-type       '':u            '':u          тип_объекта
v-cntxt-obj-code       0               0             код_объекта
v-cntxt-db-num-obj     ?               ?             код_БД_объекта


Замена:
    g#side-active = ( v-cntxt-db-num-obj = v-cntxt-db-num )
    g#obj-remote  = ( v-cntxt-db-num-obj <> 0 )
*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" <> "def" and "{1}" <> "get" &then
  &message {&file-name} Неправильно указан первый параметр {1}. Должен быть def или get
&endif

&if "{1}" = "def" &then
  define variable v-cntxt-db-num        as integer   no-undo . /* текущая БД            */
  define variable v-cntxt-userid        as character no-undo . /* текущий пользователь  */
  define variable v-cntxt-level         as character no-undo . /* уровень контекста     */
  define variable v-cntxt-host-code-obj as integer   no-undo . /* текущая фирма         */
  define variable v-cntxt-obj-type      as character no-undo . /* тип текущего объекта  */
  define variable v-cntxt-obj-code      as integer   no-undo . /* код текущего объекта  */
  define variable v-cntxt-db-num-obj    as integer   no-undo . /* база текущего объекта */
  define variable v-cntxt-is-admin      as logical   no-undo . /* база текущего объекта */
&endif
&if "{3}" = " " &then
  &scoped-define main-menu-handle-variable parparentproc
&else
  &scoped-define main-menu-handle-variable {3}
&endif
&if "{1}" = "get" &then
  run mainmenu_getcntxt in {&main-menu-handle-variable}
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
&endif
/* $Workfile$ e n d */