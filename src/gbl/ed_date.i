/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Создание триггеров на редактирование даты

Автор: Чернова Светлана Александровна
Дата создания: 07/09/07
Author: Svetlana Chernova
Creation date: 07/09/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 15/05/00

Должен быть включен в Main Block программы

Определяет следующие триггеры
  on ' '                - очистка экранного значения,
  on delete-character   - очистка экранного значения,
  on ctrl-d             - подставить текущую дату
  on ctrl-b             - подставить первую дату месяца для даты уже введенной в поле ввода
                          если дата не введена, то подставляется первый день текущего месяца
  on ctrl-e             - подставить последнюю дату месяца для даты уже введенной в поле ввода
                          если дата не введена, то подставляется последняя текущего месяца

Параметры
{1} - обязательный параметр - имя поля,
{2} - необязательный параметр - задает frame или browse, которому принадлежит
      принадлежит редактируемое поле.
      по умолчанию имеет значение
        in frame {&frame-name}
{3} - необязательный параметр. Если параметр задан, то не создается контекстное меню.
{4} - необязательный параметр. Если параметр задан, то он выводится в качестве описания даты.
{5} - необязательный параметр. Если параметр задан, то в него записывается handle menu

TODO - использовать sysconf.holidays для того, чтобы показывать выходные дни

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&if "{1}" Eq "" &then
  &message Wrong usage Of ed_date.i
&endif

&if "{2}" = "" &then
  &scop stdbtn-frame-name in frame {&frame-name}
&else
  &scop stdbtn-frame-name {2}
&endif

on ' ' of {1} {&stdbtn-frame-name}
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.

on delete-character of {1} {&stdbtn-frame-name}
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.

on ctrl-d of {1} {&stdbtn-frame-name}
do:
  define variable v-curr-sv-date as date no-undo .

  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.

    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.

on ctrl-b of {1} {&stdbtn-frame-name}
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.

    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .

    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .

      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.

  return no-apply .
end.


on ctrl-e of {1} {&stdbtn-frame-name}
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.

    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .

    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.

  return no-apply .
end.

on ctrl-f of {1} {&stdbtn-frame-name}
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.

    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .

&if "{4}" <> "" &then
    assign
      v-description = {4}
    .
&endif

    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?                     /* h-callback    */
        ,input "Выбор даты"          /* p-title       */
        ,input v-description         /* p-description */
        ,input ""                    /* p-mode        */
        ,input-output v-curr-sv-date /* p-date        */
        ,output v-ok                 /* p-ok          */
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.

  return no-apply .
end.


&if "{3}" = "" &then
  &scop seq {&sequence}

  define MENU m-ed-date{&seq}
    MENU-ITEM m-ed-date{&seq}-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date{&seq}-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date{&seq}-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date{&seq}-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  &if "{5}" <> "" &then
    {5} = MENU m-ed-date{&seq}:handle.
  &endif

  if {1} :POPUP-MENU {&stdbtn-frame-name} = ?
  then do:
    ASSIGN
      {1} :POPUP-MENU {&stdbtn-frame-name} = MENU m-ed-date{&seq} :HANDLE
      {1} :MENU-MOUSE {&stdbtn-frame-name} = 3
    .
  end.

  define variable v-label-handle{&seq} as handle no-undo .

  assign
    v-label-handle{&seq} = {1} :side-label-handle {&stdbtn-frame-name}
  .

  if valid-handle (v-label-handle{&seq})
  then do:
    if v-label-handle{&seq} :tooltip = ""
    or v-label-handle{&seq} :tooltip = ?
    then do:
      assign
        v-label-handle{&seq} :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.

  ON CHOOSE OF MENU-ITEM m-ed-date{&seq}-1 in menu m-ed-date{&seq} DO:
    apply "ctrl-b":U to {1} {&stdbtn-frame-name} .
  END.

  ON CHOOSE OF MENU-ITEM m-ed-date{&seq}-2 in menu m-ed-date{&seq} DO:
    apply "ctrl-d":U to {1} {&stdbtn-frame-name} .
  END.

  ON CHOOSE OF MENU-ITEM m-ed-date{&seq}-3 in menu m-ed-date{&seq} DO:
    apply "ctrl-e":U to {1} {&stdbtn-frame-name} .
  END.

  ON CHOOSE OF MENU-ITEM m-ed-date{&seq}-4 in menu m-ed-date{&seq} DO:
    apply "ctrl-f":U to {1} {&stdbtn-frame-name} .
  END.
&endif

/* $Workfile$ e n d */