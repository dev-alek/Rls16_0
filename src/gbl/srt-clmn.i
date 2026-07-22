/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Сортировка броузера по колонке при нажатии на заголовок

Автор: Чернова Светлана Александровна
Дата создания: 10/09/06
Author: Svetlana Chernova
Creation date: 10/09/06

Суслов Алексей Юрьевич

Дата создания: 6 Aug 1999

&table-name            имя таблицы
                        Например:
                        &table-name     = "{&first-table-in-query-{&browse-name}}"

&browser-name          имя броузера
                        Например:
                        &browse-name    = "{&browse-name}"

&frame-name            имя фрейма
                        Например:
                        &frame-name     = "{&frame-name}"

&open-query            описание запроса до by

                        Например:
                        &open-query="run UI-on ('open')."

&open-query-otherwise  описание запроса по умолчанию
                        &open-query-otherwise="run UI-on ('open')."

&sort-column-name      необязательный парметр
                        Если он задан, то в этой переменной будет хранитьс
                        или пустая строка, или имя колонки, по которой необходимо
                        сделать сортировку

                        Пример:
                        &sort-column-name = "sort-column-name"

&sort-clmn_NN          Имена колонок в браузе, по которым необходимо проводить сортировку
                        Пример:
                         &sort-clmn_1    = "parts.qnty"
                         &sort-clmn_2    = "parts.fact-qnty"

&label-clmn_NN         Соответстующие лейблы колонок в браузе
                        необходимо задавать для вычисляемых полей

Если вы хотите употребить функции употребляемые нижележащими препроцессорами
вы должны включить файл перемещения { gbl/mv-clmn.i ....}.
Задавать параметры можно всегда (просто без включения файла mv-clmn.i колонки не будут
перемещаться).

&re-move-clmn = "yes"   если вы хотите перемещать колонки после сортировки
                        на место первой колонки (после фиксированных)
&mv-brw-default = "yes" если вы хотите при отмене сортировки приводить browser
                        к первоночальному порядку колонок
*/
def var sort-label{&browse-name}   as character no-undo . /* метка столбца, по которому упорядочен browse */
def var sort-clmn{&browse-name}    as handle    no-undo . /* handle столбца, по которому упорядочен browse*/
def var cur-clmn{&browse-name}     as handle    no-undo . /* handle текущего столбца browse               */
def var cur-clmn-loc{&browse-name} as integer   no-undo . /* номер столбца, по которому упорядочен browse */
def var re-query{&browse-name}     as logical   initial no no-undo .

on start-search, ctrl-o of {&browse-name} in frame {&frame-name} do:
   run sort-br{&browse-name}
     (input (if available {&table-name}
             then recid({&table-name})
             else ?
            )
     ).
end.

PROCEDURE sort-br{&browse-name} :
  /* указатель на запись, на которую надо позиционироваться */
  define input parameter p-recid as recid no-undo .
  {&before-sort}
  if re-query{&browse-name} = no then do:
    assign
       cur-clmn{&browse-name} = {&browse-name}:current-column in frame {&frame-name}
    .
    if sort-clmn{&browse-name} <> ? then sort-clmn{&browse-name}:column-fgcolor = 0.
    if cur-clmn{&browse-name} = sort-clmn{&browse-name} then do:
       /* выключение сортировки по столбцу */
      assign
         sort-label{&browse-name} = ""
         sort-clmn{&browse-name} = ?
      .
     end.
     else do:
       /* включение или переключение сортировки на другой столбец */
       assign
         sort-label{&browse-name} = cur-clmn{&browse-name}:label
         sort-clmn{&browse-name}  = cur-clmn{&browse-name}
         sort-clmn{&browse-name}:column-fgcolor = 4
       .
     end.
   end.

&SCOP CLMN_BODY ~
~&IF "~{&sort-clmn_~{&clmn_num~}~}" ~ <> "" ~
~&THEN ~
when ~
~&if "~{&label-clmn_~{&clmn_num~}~}" <> "" ~&then ~
  ~{&label-clmn_~{&clmn_num~}~}  ~
~&else ~
  ~{&sort-clmn_~{&clmn_num~}~}:label in browse {&browse-name} ~
~&endif ~
then DO: ~
  ~&if "~{&sort-column-name~}" <> "" ~&THEN ~
  assign ~
    ~{&sort-column-name~} = "~{&sort-clmn_~{&clmn_num~}~}" ~
  . ~
  ~&endif ~
  ~{&OPEN-QUERY~} ~
  . ~
END. ~
~&ENDIF


  /* определяем текущую позицию колонки в браузере */
  assign
    cur-clmn-loc{&browse-name} = 1
  .

  def var column-handle as handle no-undo .

  column-handle = {&browse-name}:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmn{&browse-name} then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-loc{&browse-name} = cur-clmn-loc{&browse-name} + 1
    .
  end.

  case sort-label{&browse-name}:

    &scop clmn_num 1
    {&CLMN_BODY}
    &scop clmn_num 2
    {&CLMN_BODY}
    &scop clmn_num 3
    {&CLMN_BODY}
    &scop clmn_num 4
    {&CLMN_BODY}
    &scop clmn_num 5
    {&CLMN_BODY}
    &scop clmn_num 6
    {&CLMN_BODY}
    &scop clmn_num 7
    {&CLMN_BODY}
    &scop clmn_num 8
    {&CLMN_BODY}
    &scop clmn_num 9
    {&CLMN_BODY}
    &scop clmn_num 10
    {&CLMN_BODY}
    &scop clmn_num 11
    {&CLMN_BODY}
    &scop clmn_num 12
    {&CLMN_BODY}
    &scop clmn_num 13
    {&CLMN_BODY}
    &scop clmn_num 14
    {&CLMN_BODY}
    &scop clmn_num 15
    {&CLMN_BODY}
    &scop clmn_num 16
    {&CLMN_BODY}
    &scop clmn_num 17
    {&CLMN_BODY}
    &scop clmn_num 18
    {&CLMN_BODY}
    &scop clmn_num 19
    {&CLMN_BODY}
    &scop clmn_num 20
    {&CLMN_BODY}
    &scop clmn_num 21
    {&CLMN_BODY}
    &scop clmn_num 22
    {&CLMN_BODY}
    &scop clmn_num 23
    {&CLMN_BODY}
    &scop clmn_num 24
    {&CLMN_BODY}
    &scop clmn_num 25
    {&CLMN_BODY}
    &scop clmn_num 26
    {&CLMN_BODY}
    &scop clmn_num 27
    {&CLMN_BODY}
    &scop clmn_num 28
    {&CLMN_BODY}
    &scop clmn_num 29
    {&CLMN_BODY}
    &scop clmn_num 30
    {&CLMN_BODY}
    &scop clmn_num 31
    {&CLMN_BODY}
    &scop clmn_num 32
    {&CLMN_BODY}
    &scop clmn_num 33
    {&CLMN_BODY}
    &scop clmn_num 34
    {&CLMN_BODY}
    &scop clmn_num 35
    {&CLMN_BODY}
    &scop clmn_num 36
    {&CLMN_BODY}
    &scop clmn_num 37
    {&CLMN_BODY}
    &scop clmn_num 38
    {&CLMN_BODY}
    &scop clmn_num 39
    {&CLMN_BODY}
    &scop clmn_num 40
    {&CLMN_BODY}
    &scop clmn_num 41
    {&CLMN_BODY}
    &scop clmn_num 42
    {&CLMN_BODY}
    &scop clmn_num 43
    {&CLMN_BODY}
    &scop clmn_num 44
    {&CLMN_BODY}
    &scop clmn_num 45
    {&CLMN_BODY}
    &scop clmn_num 46
    {&CLMN_BODY}
    &scop clmn_num 47
    {&CLMN_BODY}
    &scop clmn_num 48
    {&CLMN_BODY}
    &scop clmn_num 49
    {&CLMN_BODY}
    &scop clmn_num 50
    {&CLMN_BODY}
    otherwise do:
      /*сортируем по умолчанию*/
      &if "{&sort-column-name}" <> "" &THEN
      assign
        {&sort-column-name} = ""
      .
      &endif
      {&OPEN-QUERY-otherwise}
      &IF "{&mv-brw-default}" = "yes" &THEN
        if can-do( this-procedure:internal-entries, 'mv-brw-default{&browse-name}') then do:
          run mv-brw-default{&browse-name}.
        end.
      &ENDIF
      /* сбрасываем подсветку когда нет open для этого столбца */
      if sort-label{&browse-name} <> "" then do:
        assign
          cur-clmn{&browse-name}:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-loc{&browse-name} = ?
      .
    end.
  end case.

  &IF "{&re-move-clmn}" = "yes" &THEN
    if cur-clmn-loc{&browse-name} <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmn{&browse-name}') then do:
        run ch-clmn{&browse-name} in this-procedure (cur-clmn-loc{&browse-name}).
      end.
    end.
  &ENDIF

  if p-recid <> ? then do:
    reposition {&browse-name} to recid p-recid no-error.
    apply "value-changed" to {&browse-name} in frame {&frame-name}.
  end.

  apply "entry" to {&browse-name} in frame {&frame-name}.

END PROCEDURE.

procedure re-open-query-srt-clmn{&browse-name}:
if cur-clmn{&browse-name} = ? then do:
   {&open-query-otherwise}
end.
else do:
   assign re-query{&browse-name} = yes.
   run sort-br{&browse-name}
     (input (if available {&table-name}
             then recid({&table-name})
             else ?
            )
     ).
   assign re-query{&browse-name} = no.
end.
end.