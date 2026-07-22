/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Список документов переоценки

Автор: Чернова Светлана Александровна
Дата создания: 09/08/05
Author: Svetlana Chernova
Creation date: 09/08/05

Author1: Исаков Андрей Валерьевич
Created: 26.01.95
{&acc-office}       надо изменить
{&ext-acc-office}

*/

define input  parameter parParentProc as widget-handle no-undo.
define input  parameter bttns         as character no-undo .
define input  parameter list-mode     as character no-undo .
define input  parameter g#stat        as character no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define input  parameter p-doc-rec     as character no-undo . /* для жесткого фильтра */
define output parameter mark-list     as character no-undo .


define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Cписок документов переоценки ".
{ cmp/vssrevis.i }
{ gbl/lib-log.i }

define variable doc-rec as recid no-undo .


&Scop if-not-true ~
if g#log <> true then do: ~
  find p-doc where recid (p-doc) = doc-rec no-lock. ~
  return no-apply. ~
end.

&Scop net-proc ~
if not available p-doc then do: ~
  message "Неправильно выбран документ.". ~
  return no-apply. ~
end. ~
doc-rec = recid (p-doc). ~
do on stop undo, return no-apply : ~
  find p-doc where recid (p-doc) = doc-rec exclusive.  /* сетевая проверка */ ~
end.


&scop WINDOW-NAME    d-pr-docs
&scop FRAME-NAME     d-pr-docs

{ cmp/str-glbl.i }
{ cmp/trg-def.i }
{ cmp/showinf.i }
{ cmp/library.i }
{ str/getctxtp.i def }
{ gbl/getcntxt.i def }

{ gbl/getcntxt.i get }
{ str/getctxtp.i get }
{ gbl/fltopend.i defproc }

define variable next-prev    as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable v-host-code  as integer   no-undo .
define variable v-host-name  as character no-undo .
define variable v-obj-db-num as integer   no-undo .
define variable v-plt-db-num as integer   no-undo .
define variable v-plt-id     as integer   no-undo .
define variable v-pdf-db-num as integer   no-undo .
define variable v-pdf-id     as integer   no-undo .
define variable v-user-name  as character no-undo .
define variable v-user-name-corr as character no-undo .
define variable v-doc-rec    as recid     no-undo .
define variable v-log-handle as handle    no-undo .
define variable v-mess as character no-undo .
define variable v-vid-action        as integer no-undo .
define variable v-vid-param         as longchar no-undo .
define variable varoldstatus        as character no-undo .
define variable varshift-date as date      no-undo.
define variable varshift-num  as integer   no-undo.
define variable varshift-name as character no-undo.
{ str/initiator.i }

{ gbl/get-lgh.i  v-log-handle }

run get-report-num in parParentProc ( output g#report-num ).
{ gbl/hostname.i
  p-obj-type
  p-obj-code
  v-host-code
  v-host-name
}

{ gbl/objdbnum.i
  p-obj-type
  p-obj-code
  v-obj-db-num
}

def new shared var br-handle as handle no-undo.

/* для жесткого фильтра по контр. */
def new shared buffer sch-cli for clients.
def new shared buffer p-doc         for ub.price-doc.
define buffer p-d-b                 for ub.price-doc.            /* для поиска по номеру, дате, факт */
define buffer sch_price-list-type   for ub.price-list-type    .  /* Для жесткого фильтра */
define buffer sch_price-doc-forming for ub.price-doc-forming  .  /* Для жесткого фильтра */

define variable sch-field as character no-undo.
define variable mark      as character no-undo.

define variable filter-point as character no-undo init "Список переоценок" .
define variable filter-point0 as character no-undo init "Список_переоценок" .
define variable sort-column-name as character no-undo .

{ gbl/flt-def.i  }
{ gbl/fltfield.i }
{ gbl/waitfram.i }
define variable old-list as character no-undo .
define variable old-stat as character no-undo .
define variable g#log    as logical   no-undo .

/* ***********************  Control Definitions  ********************** */

DEFINE BUTTON b-add
     LABEL "&Добавить":L
     SIZE 9 BY 1.

DEFINE BUTTON b-chg
     LABEL "&Изменить":L
     SIZE 12 BY 1.

DEFINE BUTTON b-del
     LABEL "&Удалить":L
     SIZE  12 BY 1.

DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE  12 BY 1.

DEFINE BUTTON b-lkp
     LABEL "&Просмотр":L
     SIZE  12 BY 1.

DEFINE BUTTON b-close
     LABEL "&Закрыть":L
     SIZE  12 BY 1.

DEFINE BUTTON b-history
     LABEL "&История":L
     SIZE  12 BY 1.

DEFINE BUTTON b-print
     LABEL "Печат&ь":L
     SIZE 12 BY 1.

DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1
     TOOLTIP "Отметить текущий документ"
     .

DEFINE BUTTON b-markAll
     LABEL "&+":L
     SIZE 3 BY 1
     TOOLTIP "Отметить все"
     .

DEFINE BUTTON b-demark
     LABEL "&-":L
     SIZE 3 BY 1
     TOOLTIP "Снять все отметки"
     .

DEFINE BUTTON b-quit AUTO-go
     LABEL "&Выход ":L
     SIZE 12 BY 1.

DEFINE BUTTON b-sch
     LABEL "&Фильтр":L
     SIZE  12 BY 1.

DEFINE BUTTON b-sel
     LABEL "Вы&бор ":L
     SIZE  12 BY 1.

DEFINE BUTTON b-copy
     LABEL "&Копии":L
     tooltip "Скопировать переоценку по выбранным объектам"
     SIZE  12 BY 1.


DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR
     SIZE 98 BY 2 NO-UNDO.

DEFINE new shared VARIABLE sch-code AS CHARACTER format "x(12)" VIEW-AS fill-in SIZE 12 BY 1 NO-UNDO.
DEFINE new shared VARIABLE sch-date AS date VIEW-AS fill-in SIZE 12 BY 1 NO-UNDO.
DEFINE new shared VARIABLE sch-fact AS date VIEW-AS fill-in SIZE 12 BY 1 NO-UNDO.
define new shared variable sch-num as integer view-as fill-in size 3 by 1 no-undo.
DEFINE new shared QUERY br-docs FOR p-doc SCROLLING.

FUNCTION mark-string RETURN CHAR (buffer loc-p-doc for p-doc , input mark-list as character ).
  if lookup ( string(recid (loc-p-doc)) , mark-list ) > 0 then RETURN "*".
  else RETURN "".
END FUNCTION.


DEFINE BROWSE br-docs QUERY br-docs NO-LOCK DISPLAY
      mark-string ( buffer p-doc , input mark-list) @ mark COLUMN-LABEL "*" FORMAT "x(1)"
      p-doc.status_    COLUMN-LABEL "Статус"
      p-doc.doc-num format "x(12)"
      p-doc.doc-date   column-label "Дата"
      p-doc.fact-date  COLUMN-LABEL "Факт"
      (trim (p-doc.obj-type) + string (p-doc.obj-code, ">>>>9")) COLUMN-LABEL "Объект" FORMAT "x(8)"
      p-doc.rest-qnty  column-label "Кол-во"
      p-doc.sale-base  COLUMN-LABEL "Сумма "  FORMAT "->>>>>,>>>,>>>.99"
      p-doc.rest-sale  COLUMN-LABEL "Было "
      p-doc.pdf-id     COLUMN-LABEL "№ ДНЦ"
      p-doc.pdf-db     COLUMN-LABEL "БД ДНЦ"
      p-doc.plt-id     COLUMN-LABEL "№ ТПЛ"
      p-doc.plt-db-num COLUMN-LABEL "БД ТПЛ"
      p-doc.acc-date   column-label "Проводка"
      p-doc.bge-date   column-label "Внеш.пров."
      p-doc.out-code   column-label "Накл."
      /* p-doc.fact-order column-label "fact-order" */
    WITH SIZE 98 BY 15 separators.
/* ************************  Frame Definitions  *********************** */

DEFINE FRAME {&frame-name}
     b-quit   AT ROW 1  COL 1
     b-sel    AT ROW 1  COL 13
     b-mark   AT ROW 1 COL  25
     b-markall   AT ROW 2 COL  25
     b-demark    AT ROW 2 COL  28
     b-lkp    AT ROW 1 COL  28
     b-chg    AT ROW 1 COL 40
     b-close  AT ROW 1 COL  52
     b-sch    AT ROW 1  COL 50
     b-history AT ROW 1  COL 74
     b-help   AT ROW 1  COL 86


     b-add    AT ROW 2 COL 5
     b-del    AT ROW 2 COL  26
     b-copy   AT ROW 2  COL 50


     b-print  AT ROW 2 COL 86

     br-docs AT ROW 3 COL 1
     v-user-name AT ROW 18 COL 1 label "Создал"      fgcolor 4 format "x(15)"
     v-user-name-corr AT ROW 19 COL 1 label "Правил" fgcolor 4 format "x(15)"
     ed-notes AT ROW 20 COL 1 no-label bgcolor 8 fgcolor 4

     sch-code at row 22 col 2 label "&Начало номера"
     sch-date at row 22 col 29 label "Д&ата"
     sch-fact at row 22 col 47 label "Фак&т"
     sch-num at row 22 col 65 label "Найдено" fgcolor 12

     SPACE(0) SKIP(0.5)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
         DEFAULT-BUTTON b-quit.

/* ***************  Runtime Attributes and UIB Settings  ************** */

ASSIGN
       FRAME {&frame-name}:SCROLLABLE       = FALSE.

ASSIGN
       br-docs:NUM-LOCKED-COLUMNS IN FRAME {&frame-name} = 3.

/* ************************  Control Triggers  ************************ */

/* для устранения подвисания при неправильных нажатиях */
on any-printable of br-docs in frame {&frame-name} do:
  apply "entry" to sch-code in frame {&frame-name}.
end.

ON CHOOSE OF b-add IN FRAME {&frame-name} /* Добав */
DO:
define variable old-type as character no-undo .
define variable v-dead-doc   as character initial no no-undo.
define variable v-type       as character initial ? no-undo.
{ gbl/conf-rd.i
  "'dead-doc'"
  "''"
  "''"
  0
  "''"
  "''"
  "''"
  no
  v-dead-doc
  v-type
  no-error
}
if  error-status :error  = false then do:
    if v-dead-doc = "yes"  then  do:
      message "В системе установлен запрет на ввод документов!"
      view-as alert-box error .
      return no-apply  .
    end.
end.

if list-mode = {&status} and g#stat <> {&g___new} then do:
  message "В этом списке нет новых переоценок, поэтому добавление здесь запрещено.".
  return no-apply.
end.
{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_overvalue_preparation':U
  {&cntxt-object}
  v-host-code
  p-obj-type
  p-obj-code
  0
  0
  0
  true
  g#log
}
if g#log <> yes then return no-apply.

doc-rec = ? .
run str/pr-doc.w
( input parParentProc   ,
  input-output doc-rec  ,
  input {&add-def}        ,
  input-output  next-prev ) .

if doc-rec = ? then return no-apply.
run OpenBr in this-procedure  (yes, no, '':U).
END.

ON CHOOSE OF b-chg IN FRAME {&frame-name} /* Измен */
DO:

  {&net-proc}

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_overvalue_preparation':U
    {&cntxt-object}
    v-host-code
    p-obj-type
    p-obj-code
    0
    0
    0
    true
    g#log
  }
  if not g#log then return no-apply.
  run str/pr-doc.w
  ( input parParentProc   ,
    input-output doc-rec  ,
    input {&update}        ,
    input-output  next-prev
  ) no-error.
  apply "entry" to br-docs in frame {&frame-name}.
  if error-status:error then do:
    find p-doc where recid (p-doc) = doc-rec no-lock.  /* буфер ломается при return error */
    return no-apply.
  end.
  run OpenBr in this-procedure (yes, no, '':U).
END.

ON CHOOSE OF b-del IN FRAME {&frame-name} /* Удал */ DO:
define variable del-rec as recid no-undo.

  {&net-proc}

  if p-doc.status_ = {&order} and  (v-obj-db-num <> 0) or
    p-doc.status_ = {&permitted} and p-obj-type = {&shop} or
    p-doc.status_ = {&act-overvalue} then do:
    find p-doc where recid (p-doc) = doc-rec no-lock.
    message "Закрытый документ не может быть удален.".
    return no-apply.
  end.
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_overvalue_preparation':U
    {&cntxt-object}
    v-host-code
    p-obj-type
    p-obj-code
    0
    0
    0
    true
    g#log
  }
  {&if-not-true}
  g#log = no.
  message "Удалить документ № " p-doc.doc-num
              " ?   Вы уверены ?" view-as alert-box question buttons OK-Cancel
                update g#log.
  {&if-not-true}
  run waitfram-show in this-procedure ("Удаление переоценки № " + p-doc.doc-num + ". Ждите...").
  br-handle = br-docs:handle.
  if valid-handle (br-handle) then do:
    g#log = br-handle:select-next-row().
    if not g#log then g#log = br-handle:select-prev-row().
    del-rec = recid (p-doc).
  end.
  find p-doc where recid (p-doc) = doc-rec.
  do on stop undo, return no-apply.
    delete p-doc.
  end.
  doc-rec = del-rec.
  run waitfram-hide in this-procedure .
  run OpenBr in this-procedure (yes, no, '':U).
END.


ON CHOOSE OF b-history IN FRAME {&frame-name} /* history */
DO:
 run str/pr-cdoc.w (parParentProc ,p-doc.host-code, p-doc.doc-num) .
end.


ON CHOOSE OF b-lkp IN FRAME {&frame-name} /* Просм */
DO:
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_overvalue_lookup':U
    {&cntxt-object}
    p-doc.host-code
    p-doc.obj-type
    p-doc.obj-code
    0
    0
    0
    true
    g#log
  }
  if g#log <> yes then return no-apply.
  next-prev = yes.
  br-handle = br-docs:handle.
  do while next-prev <> ?:
  {&net-proc}
    run str/pr-doc.w
  ( input parParentProc   ,
    input-output doc-rec ,
    input {&lookup}        ,
    input-output  next-prev ) .

  end.
  if br-handle = ? then reposition br-docs to recid doc-rec no-error.
  apply "entry" to br-docs in frame {&frame-name}.
  apply "iteration-changed" to br-docs in frame {&frame-name}.
END.

ON CHOOSE OF b-close IN FRAME {&frame-name} /* Закр */
DO:
  define variable v-v1         as logical   no-undo .
  define variable v-close-type as integer   no-undo .
  define variable v-varmode    as character no-undo .
  define variable vv as integer   no-undo .
  define variable i-v as integer   no-undo .

  {&net-proc}

  vv = num-entries(mark-list) .
  v-v1 = false .
    if vv >= 1 then do:
      message "Выбрано " num-entries(mark-list) "переоценок "
              "Закрыть их списком до АКТ ?"
              view-as alert-box question
              button yes-no
              title "Вопрос"
              update v-v1.
    end.
    else do:
      mark-list = string(recid ( p-doc )) .
      vv = num-entries(mark-list) .
    end.
  g#auto = false .
    if list-mode = {&work} and v-v1 = false  then do:
      if not ( p-doc.status_ = {&g___new} ) then do:
      message "В этом режиме можно закрывать только до статуса " caps( {&order}) view-as alert-box information .
      return  .
      end.
    end.

  repeat i-v = 1 to vv :
    find first p-doc no-lock  where recid(p-doc) = integer(entry(i-v,mark-list )) no-error .
    if error-status :error then next.
    
    if p-doc.doc-date > today
    then do :
      message ("Нельзя закрыть переоценку " + p-doc.doc-num + ". Дата переоценки больше текущей даты.") view-as alert-box information .
      vv = 0.
      mark-list = "" .
      return.
    end.

  if v-v1 = true then assign
    v-varmode = "close-act":U
  .
  else assign
    v-varmode = "close":U .
  .
  do transaction :
  define buffer buf_price-doc-forming for ub.price-doc-forming  .
  if  p-doc.status_ = {&order} or p-doc.status_ = {&permitted}  then do:

    find first buf_price-doc-forming exclusive-lock where
              buf_price-doc-forming.plt-db-num = p-doc.plt-db-num and
              buf_price-doc-forming.plt-id     = p-doc.plt-id     and
              buf_price-doc-forming.pdf-db     = p-doc.pdf-db     and
              buf_price-doc-forming.pdf-id     = p-doc.pdf-id     and
              buf_price-doc-forming.stts       = int({&pdf-fact}) no-error .
    if not available buf_price-doc-forming then do:
      message
      substitute("Нельзя закрыть переоценку &1 , так как ДНЦ &2 еще не в статусе ФАКТ !" , p-doc.doc-num, p-doc.pdf-id )
      view-as alert-box information .
      return .
    end.
  end.

      if  p-doc.status_ = {&order} and v-v1 = false  then do:
          run gbl/d-askw.w
          ( input "Вопрос" /* Заголовок окна */
            ,input "Закрытие переоценки" + chr(10) /* Общее сообщение */
              + substitute("№         &1", p-doc.doc-num) + chr(10)
              + substitute("Дата      &1", string(p-doc.doc-date, '99/99/9999':u)) + chr(10)
              + (if p-doc.fact-date <> ? then substitute("Факт дата &1", string(p-doc.fact-date, '99/99/9999':u)) else "") + chr(10)
              + substitute("Оператор  &1", p-doc.user-name)
            ,input "|^" /* Символы разделители для кодирования двух следующих параметров */
                        /* первый символ - разделитель списков названий кнопок и описаний кнопок */
                        /* второй символ - разделитель атрибутов в описании кнопок */
            ,input "Разрешен" + '|':u
                + "Акт" + '|':u
                + "Отмена" /* список названий кнопок  */
                            /* каждая кнопка может иметь необязательный */
                            /* список атрибутов, влияющих на поведение кнопки */
            ,input "поэтапное закрытие переоценки|" /* список описаний кнопок */
                + "установление новых цен на товары, пересылка цен на кассы и по новостям |"
                + "Отмена закрытия переоценки"
            ,input 1 /* значение возвращаемое при нажатии enter */
            ,input 3 /* значение возвращаемое при нажатии escape */
            ,output v-close-type /* выбор пользователя */
            ).

          case v-close-type :
            when 1
            then do:
              assign
                v-varmode = "close":U
              .
            end.
            when 2
            then do:
              assign
                v-varmode = "close-act":U
              .
            end.
            when 3
            then do:
              assign mark-list = "" .
              return no-apply.
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Способ закрытия переоценки" skip
                "Неизвестное значение" v-close-type skip
                view-as alert-box error .

              undo, return no-apply .
            end.
          end case .
      end.
  end.
  /* ПРОВЕРКА ПРАВ */
    v-mess = "".
    varoldstatus = p-doc.status_.
    { gbl/curshift.i
        p-doc.obj-type
        p-doc.obj-code
        varshift-date
        varshift-num
        varshift-name
        no-error
      }
    run str/pr-stat.p
      ( input parParentProc
      , input v-log-handle
      , input v-varmode      /* p-mode    */
      , input p-doc.doc-num  /* p-doc-num */
      , input p-doc.out-code /*  связь с накладной  */
      , input false
      , input false
      ) no-error .
    if error-status :error then do:
        v-mess = "Ошибка закрытия переоценки " + p-doc.doc-num + {&new-line} +
          return-value + {&new-line} +
          error-status :get-message(1).
        message v-mess
                "Продолжить процесс ?"
                view-as alert-box question
                buttons yes-no
                update v11 as logical
                .
                assign mark-list = "" .
                
                v-vid-action = 57 .
                v-vid-param = "Initiator=" + v-initiator + {&delim-par} +
                              "SHOP_NUM=" + string(p-doc.obj-code) + {&delim-par} +
                              "DocNum=" + string(p-doc.doc-num) + {&delim-par} +
                              "DocType=" + "Переоценка" + {&delim-par} +
                              "FactDate=" + (if string(p-doc.fact-date) = ? then '' else string(p-doc.fact-date)) + {&delim-par} +
                              "ShiftNum=" + (if string(p-doc.shift-num) = ? then '' else string(p-doc.shift-num)) + {&delim-par} +
                              "ShiftDate=" + (if string(p-doc.shift-date) = ? then '' else string(p-doc.shift-date)) + {&delim-par} +
                              "ShiftNumCurr=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + {&delim-par} +
                              "ShiftDateCurr=" + (if string(varshift-date) = ? then '' else string(varshift-date)) + {&delim-par} +
                              "StatusOld=" + varoldstatus + {&delim-par} +
                              "StatusNew=" + string(p-doc.status_) + {&delim-par} +
                              "RESULT=1" + {&delim-par} + 
                              "Description=" + v-mess.
                
                run trg/userlog.p (
                      input {&nwsdochs_action_update_err}
                    , input {&table_price-doc}
                    , input ( buffer p-doc :handle )
                    , input v-vid-action
                    , input v-vid-param
                ) no-error.

        if v11 = false  then  return no-apply .
    end.
    
    if v-mess = ""
    then do:
      v-vid-action = 57 .
      v-vid-param = "Initiator=" + v-initiator + {&delim-par} +
                    "SHOP_NUM=" + string(p-doc.obj-code) + {&delim-par} +
                    "DocNum=" + string(p-doc.doc-num) + {&delim-par} +
                    "DocType=" + "Переоценка" + {&delim-par} +
                    "FactDate=" + (if string(p-doc.fact-date) = ? then '' else string(p-doc.fact-date)) + {&delim-par} +
                    "SHIFT_NUM_DOC=" + (if string(p-doc.shift-num) = ? then '' else string(p-doc.shift-num)) + (if string(p-doc.shift-date) = ? then '' else string(p-doc.shift-date, "99999999")) + {&delim-par} +
                    "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + {&delim-par} +
                    "StatusOld=" + varoldstatus + {&delim-par} +
                    "StatusNew=" + string(p-doc.status_) + {&delim-par} +
                    "RESULT=" + {&delim-par} + 
                    "Description=" no-error.
      
      find last ub.c-price-doc no-lock where ub.c-price-doc.doc-num = p-doc.doc-num no-error.   
      if available (ub.c-price-doc)
      then do:      
        run trg/userlog.p (
              input {&nwsdochs_action_update}
            , input {&table_c-price-doc}
            , input ( buffer ub.c-price-doc :handle )
            , input v-vid-action
            , input v-vid-param
        ) no-error.
      end.

    end.
    
  end.
  assign mark-list = "" .
  run OpenBr in this-procedure (yes, no, '':U).
END.

ON CHOOSE OF b-copy IN FRAME {&frame-name} /* Копии */
DO:

  {&net-proc}

  run str/pr-copy.p
    (input  parParentProc , input p-doc.doc-num ) no-error .
  if error-status :error then do:
    find p-doc no-lock
      where recid (p-doc) = doc-rec
      .
    return no-apply .
  end.

  run OpenBr in this-procedure (yes, no, '':U).
END.


ON CHOOSE OF b-print IN FRAME {&frame-name} /* {&print} */
DO:

{&net-proc}

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_overvalue_print':U
    {&cntxt-object}
    v-host-code
    p-obj-type
    p-obj-code
    0
    0
    0
    true
    g#log
  }
  if g#log <> yes then return no-apply.
  run rep/pr-dprn.w ( parParentProc , doc-rec ).
  apply "entry" to br-docs.
END.

ON CHOOSE OF b-quit IN FRAME {&frame-name} /* Выход */
DO:
  doc-rec = ?.
END.

ON entry OF ed-notes IN FRAME {&frame-name}
DO:

  {&net-proc}

  if p-doc.status_ <> {&act-overvalue} and substring (p-doc.PS, 1, 1) = "@" then
  message "Чтобы программа не могла заново переписать Ваше примечание, удалите знак @.".
END.

ON leave OF ed-notes IN FRAME {&frame-name}
DO:
  do on stop undo, return no-apply:
    find p-d-b where recid (p-d-b) = doc-rec exclusive.
    p-d-b.PS = input frame {&frame-name} ed-notes.
  end.
END.

ON RETURN, MOUSE-SELECT-DBLCLICK OF ed-notes IN FRAME {&frame-name} DO:
  apply "entry" to br-docs in frame {&frame-name}.
  return no-apply.
END.

ON RETURN, MOUSE-SELECT-DBLCLICK OF br-docs IN FRAME {&frame-name} DO:
  if list-mode = {&choose} and lookup("b-mark":U, bttns) = 0 then apply "choose" to b-sel in frame {&frame-name}.
  else apply "choose" to b-lkp in frame {&frame-name}.
END.

ON iteration-changed OF br-docs do:
  if available p-doc then do:
    ed-notes = p-doc.PS.
    { gbl/usrfulnm.i
      p-doc.creid
      v-user-name
    }
    { gbl/usrfulnm.i
      p-doc.user-name
      v-user-name-corr
    }
    display ed-notes v-user-name v-user-name-corr with frame {&frame-name}.
    /* doc-rec = recid (p-doc) - это сюда ставить нельзя, неправ. будет работать leave ed-notes */
    if doc-rec <> recid (p-doc) then do:
      sch-num = 0.
      hide sch-num in frame {&frame-name}.
    end.
  end.
end.

ON RETURN, MOUSE-SELECT-DBLCLICK OF sch-code IN FRAME d-pr-docs DO:
  if sch-code <> input frame d-pr-docs sch-code or sch-field <> "doc-num" then do:
    sch-num = 0.
    hide sch-num in frame d-pr-docs.
  end.
  sch-field = "doc-num" .
  assign sch-code = input frame d-pr-docs sch-code.
  run OpenBr in this-procedure (NO,NO, substitute(" and p-doc.doc-num begins '&1' ", sch-code)).
  apply "entry":u to sch-num in frame {&frame-name}.
END.

on ctrl-j of sch-code in frame {&frame-name} /* номеру */ do:
  if sch-code <> input frame d-pr-docs sch-code or sch-field <> "doc-num" then do:
    sch-num = 0.
    hide sch-num in frame d-pr-docs.
  end.
  sch-field = "doc-num" .
  assign sch-code = input frame d-pr-docs sch-code.
  run OpenBr in this-procedure ( no, yes, substitute (" and p-doc.doc-num begins '&1' ", sch-code) ).
  apply "entry":U to sch-num in frame {&frame-name}.
  apply "entry":U to sch-num in frame {&frame-name}.
end.

ON RETURN, MOUSE-SELECT-DBLCLICK OF sch-date IN FRAME d-pr-docs DO:
define variable v-date as character no-undo .
    if sch-date <> input frame d-pr-docs sch-date or sch-field <> "doc-date" then do:
      sch-num = 0.
      hide sch-num in frame d-pr-docs.
    end.
    sch-field = "doc-date".
    assign sch-date = input frame d-pr-docs sch-date.

    v-date = string ( month (sch-date)) + {&slash-char} +
             string ( day   (sch-date)) + {&slash-char} +
             string ( year  (sch-date))
            .
    run OpenBr ( no, yes, substitute (" and p-doc.doc-date = &1 ", v-date) ) .
    apply "entry":u to sch-date in frame {&frame-name}.

end.

on ctrl-j of sch-date in frame {&frame-name} /* номеру */ do:
define variable v-date as character no-undo .
    if sch-date <> input frame d-pr-docs sch-date or sch-field <> "doc-date" then do:
      sch-num = 0.
      hide sch-num in frame d-pr-docs.
    end.
    sch-field = "doc-date".
    assign sch-date = input frame d-pr-docs sch-date.

    v-date =
    string (day (sch-date)  ) + {&slash-char} +
    string (month (sch-date)) + {&slash-char} +
                        string (year (sch-date) )
            .
    run OpenBr ( no, yes, substitute (" and p-doc.doc-date = &1 ", v-date) ) .
    apply "entry":u to sch-date in frame {&frame-name}.
end.

ON RETURN, MOUSE-SELECT-DBLCLICK OF sch-fact IN FRAME d-pr-docs DO:
define variable v-date as character no-undo .
    if sch-fact <> input frame d-pr-docs sch-fact or sch-field <> "fact-date" then do:
      sch-num = 0.
      hide sch-num in frame d-pr-docs.
    end.
    sch-field = "fact-date".
    assign sch-fact = input frame d-pr-docs sch-fact.
    v-date =
            string ( day (sch-fact)  ) + {&slash-char} +
            string ( month (sch-fact)) + {&slash-char} +
            string ( year (sch-fact) )
            .
    run OpenBr ( no, yes, substitute (" and p-doc.fact-date = &1 ", v-date) ) .
    apply "entry":u to sch-fact in frame {&frame-name}.
END.

on ctrl-j of sch-fact in frame {&frame-name}  /* номеру */ do:
define variable v-date as character no-undo .
    if sch-fact <> input frame d-pr-docs sch-fact or sch-field <> "fact-date" then do:
      sch-num = 0.
      hide sch-num in frame d-pr-docs.
    end.
    sch-field = "fact-date".
    assign sch-fact = input frame d-pr-docs sch-fact.

    v-date = string ( month (sch-fact)) + {&slash-char} +
            string ( day (sch-fact)  ) + {&slash-char} +
            string ( year (sch-fact) )
            .
    run OpenBr ( no, yes, substitute (" and p-doc.fact-date = &1 ", v-date) ) .
    apply "entry":u to sch-fact in frame {&frame-name}.
END.


{ gbl/hot-key.i b-print }
{ gbl/hot-key.i b-history }
{ gbl/hot-key.i b-lkp }
{ gbl/hot-key.i b-add }
{ gbl/hot-key.i b-chg }
{ gbl/hot-key.i b-close }
{ gbl/hot-key.i b-del }

ON CHOOSE OF b-sel IN FRAME {&frame-name} /* {&choose} */
DO:

  {&net-proc}

  if mark-list <> "" then do:
  end.
  else do:
    mark-list = string(recid(p-doc)).
  end.
  apply "go" to frame {&frame-name}.
END.

on choose of b-mark in frame {&frame-name} do:
  run local-mark in this-procedure .
  if available p-doc then do:
    g#log = br-docs:select-next-row ().
  end.
  apply "entry" to br-docs in frame {&frame-name}.
end.

on choose of b-demark in frame {&frame-name} do:
   assign mark-list = "" .
   run OpenBr in this-procedure  (yes, no, '':U).
end.

on choose of b-markall in frame {&frame-name} do:
  define variable loc#log as logical no-undo .
  assign mark-list = "".
  GET first br-docs.
  DO WHILE available p-doc  :
    if available p-doc then do:
      { gbl/markstrn.i p-doc mark-list }
    end.
  GET next br-docs.
  end.
  run OpenBR in this-procedure (yes, no, '':U).
  apply "entry" to br-docs in frame {&frame-name}.
end.


on choose of b-sch in frame {&frame-name} do:
  run init-flt in this-procedure no-error.
end.


/* ***************************  Main Block  *************************** */

IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME {&FRAME-NAME}:PARENT eq ?
THEN FRAME {&FRAME-NAME}:PARENT = ACTIVE-WINDOW.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

{ gbl/app_help.i &browse-name="br-docs" }
{ gbl/brwrefre.i " assign v-doc-rec = ?. ~
if available p-doc then v-doc-rec = recid(p-doc). ~
run OpenBr in this-procedure (yes, no, '':U). ~
reposition br-docs to recid v-doc-rec no-error. ~
apply 'iteration-changed' to br-docs. " }


{ gbl/ed_date.i sch-date }
{ gbl/ed_date.i sch-fact }
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:

/* для жесткого фильтра по контр., м-ру, исп-лю, кл-ку */
find sch-cli where recid (sch-cli) = int(p-doc-rec) no-error.


find sch_price-list-type where recid (sch_price-list-type) = int(p-doc-rec) no-error.
if available  sch_price-list-type and list-mode = "typepricelist":U then
    assign
        v-plt-db-num = sch_price-list-type.plt-db-num
        v-plt-id     = sch_price-list-type.plt-id
    .

find sch_price-doc-forming where recid (sch_price-doc-forming) = int(p-doc-rec) no-error.
if available  sch_price-doc-forming and list-mode = "pricedocforming":U then
    assign
        v-plt-db-num = sch_price-doc-forming.plt-db-num
        v-plt-id     = sch_price-doc-forming.plt-id
        v-pdf-db-num = sch_price-doc-forming.pdf-db
        v-pdf-id     = sch_price-doc-forming.pdf-id
     .


ENABLE b-quit b-lkp b-history b-print b-sch b-help br-docs sch-code sch-date sch-fact ed-notes
b-mark when lookup("b-mark":U, bttns) > 0
b-demark when lookup("b-mark":U, bttns) > 0
b-markall when lookup("b-mark":U, bttns) > 0
b-sel when lookup("b-sel":U, bttns) > 0
WITH FRAME {&frame-name}.

define variable var-pr-r-b as character no-undo .
{ gbl/curr-r-b.i  var-pr-r-b }

if var-pr-r-b = "rubl" then
   assign
      p-doc.sale-base:LABEL = "Сумма " + "({&abbr_rub})"
      p-doc.rest-sale:LABEL = "Было "  + "({&abbr_rub})"
   .
  else  assign
        p-doc.sale-base:LABEL = "Сумма " + "(б.в)"
        p-doc.rest-sale:LABEL = "Было "  + "(б.в)"
    .

run OpenBr in this-procedure (yes, no, '':U).

hide b-add b-del /*b-chg*/  b-copy in frame {&frame-name} .
/*enable b-chg  with frame {&frame-name}.*/

WAIT-FOR GO OF FRAME {&FRAME-NAME} focus br-docs.
END.

run disable_ui in this-procedure .

/* **********************  Internal Procedures  *********************** */

PROCEDURE disable_UI :
  HIDE FRAME {&frame-name}.
END PROCEDURE.

PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .


define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.

/* {&SetCursorWait} */
define variable sort-column-phrase as character no-undo .

case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.


&scop flt-open-open-query OPEN QUERY br-docs FOR EACH p-doc NO-LOCK

&scop flt-open-dyn_open-query  FOR EACH p-doc

&scop flt-open-query-handle query br-docs:handle

&scop flt-open-find-buffer-name p-doc

&scop flt-open-open-query-tail

&scop flt-open-query-was-opened     l-query-was-opened

&scop flt-open-sort-column-phrase   sort-column-phrase

&scop flt-open-call-point           filter-point

&scop flt-open-set-filter-name      set-filter-name

&scop flt-open-indexed-reposition

&scop flt-open-query               p-open-query

&scop flt-open-table-name          p-doc

&scop flt-open-search-option       no-lock

&scop flt-open-find-next           p-find-next

&scop flt-open-find-recid          doc-rec

&scop flt-open-find-condition       p-find-condition

&scop flt-open-find-buffer-def      define buffer p-doc for ub.price-doc.

&scop flt-open-debug-file

&scop flt-open-waitfram             true

define variable l-open-query as logical   no-undo .
define buffer buf_clients for ub.clients  .
find first buf_clients no-lock where buf_clients.obj-code = v-host-code and buf_clients.obj-type = {&cmp} no-error .
if not available buf_clients then return .
filter-point = filter-point0 + list-mode.



/* ------------------------------------------------------------------------------------------------------------ */
if p-open-query = true  then do:
  frame {&frame-name}:title = "ВСЕ  ПЕРЕОЦЕНКИ".
  sch-num = 0.
  hide sch-num in frame {&frame-name}.
end.
else  do:
   doc-rec = ?.
end.

case list-mode :
  when "typepricelist":U then do:
      frame {&frame-name}:title = "ПЕРЕОЦЕНКИ  по ТПЛ " +  sch_price-list-type.name .
      c-point = {&act-overvalue} + list-mode.
      enable b-copy b-close with frame {&frame-name}.
      { gbl/fltopend.i
        &where-cond      = " p-doc.plt-db-num = v-plt-db-num and p-doc.plt-id = v-plt-id "
        &dyn_where-cond  = " substitute( 'p-doc.plt-db-num = &1  and p-doc.plt-id =  &2 ' , v-plt-db-num , v-plt-id) "
        &use-ind         = " use-index pdf "
        &by              = " " }
  end.

  when "pricedocforming":U then do:
      frame {&frame-name}:title = "ПЕРЕОЦЕНКИ  по ДНЦ " +  sch_price-doc-forming.name .
      c-point = {&act-overvalue} + list-mode.

      enable b-copy b-close with frame {&frame-name}.
      { gbl/fltopend.i
        &where-cond  = " p-doc.plt-db-num = v-plt-db-num and p-doc.plt-id = v-plt-id and p-doc.pdf-db = v-pdf-db-num and p-doc.pdf-id = v-pdf-id "
        &dyn_where-cond  = " substitute( ' ~
                     p-doc.plt-db-num = &1 and  ~
                     p-doc.plt-id =  &2 and    ~
                     p-doc.pdf-db =  &3 and    ~
                     p-doc.pdf-id =  &4 ' ,  ~
                     v-plt-db-num , ~
                     v-plt-id     , ~
                     v-pdf-db-num , ~
                     v-pdf-id   )  ~
                     "
        &use-ind     = " use-index pdf "
        &by          = " " }
  end.


  when {&work} then do:
      c-point = {&act-overvalue} + list-mode.
      enable b-copy b-close with frame {&frame-name}.
  { gbl/fltopend.i
    &where-cond  = " true  "
    &dyn_where-cond  = " 'true'  "
    &use-ind     = " use-index date-num "
    &by          = " " }
  end.


  when {&company} then do:
      frame {&frame-name}:title = "ПЕРЕОЦЕНКА   Фирма : " + v-host-name .
      c-point = "актРАБОТА".
  enable b-copy with frame {&frame-name}.

  { gbl/fltopend.i
    &where-cond     = " p-doc.host-code = v-host-code "
    &dyn_where-cond = " substitute ( 'p-doc.host-code = &1' , v-host-code ) "
    &use-ind        = " use-index  host-date "
    &by             = " " }
  end.
  when {&g___object} then do:
      frame {&frame-name}:title = "ПЕРЕОЦЕНКА   Объект : " + p-obj-type + " " + string (p-obj-code).
      enable b-add b-chg b-del b-close with frame {&frame-name}.
      if (v-cntxt-db-num <> 0) then enable b-copy with frame {&frame-name}.
      c-point = {&act-overvalue} + list-mode.

  { gbl/fltopend.i
    &where-cond     = " p-doc.obj-type = p-obj-type and p-doc.obj-code = p-obj-code "
    &dyn_where-cond = " substitute ( 'p-doc.obj-type = &1&2&1 and p-doc.obj-code = &3', ~{&double-quote~} , p-obj-type, p-obj-code ) "
    &use-ind        = " use-index  obj-date "
    &by             = " " }
  end.
  when {&status} then do:
      frame {&frame-name}:title = "Объект : " + p-obj-type + " " + string (p-obj-code) + "  Статус : " + g#stat.
      enable b-add b-chg b-del b-close with frame {&frame-name}.
      c-point = {&act-overvalue} + list-mode.
  { gbl/fltopend.i
    &where-cond     = " p-doc.obj-type = p-obj-type and p-doc.obj-code = p-obj-code and  p-doc.status_ = g#stat "
    &dyn_where-cond = " substitute ( 'p-doc.obj-type = &1&2&1 and p-doc.obj-code = &3 and p-doc.status_ = &1&4&1', ~{&double-quote~} , p-obj-type, p-obj-code , g#stat) "
    &use-ind    = " use-index  stat-date "
    &by         = " " }
  end.
  /* ---------------------------------------------------------------------------------------------------------------- */

  when {&ext-acc-office-all} then do:
      frame {&frame-name}:title = "Все ПЕРЕОЦЕНКИ  БЕЗ  выгрузки  по ФИРМЕ   (кроме нулевых сумм)".
      c-point = {&act-overvalue} + list-mode.
  { gbl/fltopend.i
    &where-cond = " p-doc.status_ = ~{&act-overvalue~} ~
      and p-doc.bge-date = ? ~
      and p-doc.host-code = v-host-code ~
      and p-doc.sale-base <> 0 "
    &dyn_where-cond = " substitute ( 'p-doc.status_ = &1&2&1 and p-doc.bge-date = date(?) and p-doc.sale-base <> 0 and p-doc.host-code = &3 ', ~{&double-quote~} ,  ~{&act-overvalue~}, v-host-code ) "
    &use-ind    = " use-index  bge-host "
    &by         = " " }
  end.

  when {&choose} then do:
      frame {&frame-name}:title = trim (frame {&frame-name}:title) + " :   ВЫБОР".
      c-point = {&act-overvalue} + {&work}.
  { gbl/fltopend.i
    &where-cond = " true "
    &dyn_where-cond = " 'true' "
    &use-ind    = " "
    &by         = " " }
  end.

end case.

if p-open-query <> true  and available p-d-b then doc-rec = recid (p-d-b).

if doc-rec <> ? then do:
  if p-open-query <> true  then do:
    sch-num = sch-num + 1.
    disp sch-num with frame {&frame-name}.
  end.
  reposition br-docs to recid doc-rec no-error.
end.
else if p-open-query <> true  then do:
  message "Переоценка не найдена.".
  sch-num = 0.
end.
apply "entry" to br-docs in frame {&frame-name}.
apply "iteration-changed" to br-docs in frame {&frame-name}.
hide b-add b-del /*b-chg*/  b-copy in frame {&frame-name} .
END PROCEDURE.

PROCEDURE init-flt :
  assign
  tbl = 'price-doc'
  join-tbl = "p-doc"
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
  run fltfield-add in this-procedure('status_', 'Статус', 'pr-stat',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

  run fltfield-add in this-procedure('doc-num', '', '',
                                    input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

  run fltfield-add in this-procedure('doc-date', 'Дата', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

  run fltfield-add in this-procedure('fact-date', 'Факт', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

  run fltfield-add in this-procedure('obj-type{&delim-flt}obj-code', 'Объект', 'cli',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

  run fltfield-add in this-procedure('rest-qnty', 'Кол-во', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

  run fltfield-add in this-procedure('rest-sale', 'Сумма До пер-ки ', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

  run fltfield-add in this-procedure('sale-base', 'Сумма по док. ', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

  run fltfield-add in this-procedure('creid', 'Создал', 'usr',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('user-name', 'Правил', 'usr',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

  run fltfield-add in this-procedure('fact-num', 'Порядок закрытия', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('plt-id', '№ ТПЛ', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pdf-id', '№ ДНЦ', '',
                                     input-output fld, input-output lab, input-output spr, input-output dim)  no-error.

Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( INPUT parparentproc, INPUT filter-point, INPUT tbl, INPUT join-tbl, INPUT fld, INPUT lab, INPUT spr, INPUT dim ).
  run openbr in this-procedure (yes, no, '':u).
END. /* Filter-Block */


END PROCEDURE.

PROCEDURE local-mark:
  if not available p-doc then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  { gbl/markstrn.i p-doc mark-list }
   if lookup(string( recid(p-doc) ), mark-list ) = 0
      then display  "" @ mark with browse br-docs.
      else display "*" @ mark with browse br-docs.

END PROCEDURE.


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE set-filter-name Dialog-Frame
PROCEDURE set-filter-name :
define input parameter p-filter-name as character no-undo .

  do with frame {&frame-name}:
    if p-filter-name > "" then do:
      assign
        frame {&frame-name}:title
          = frame {&frame-name}:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :TOOLTIP = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :TOOLTIP = ""
      .
    end.

  end. /* do with frame */

END PROCEDURE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&UNDEFINE FRAME-NAME
&UNDEFINE WINDOW-NAME