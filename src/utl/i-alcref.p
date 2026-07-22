block-level on error undo, throw.
/*

$Revision: 9ebe6f343c82, 149, rls $
$Author: EShklyar $
$Date: Mon Feb 16 20:50:30 2015 +0400 $
$Workfile: i-alcref.p $
$Archive: utl/i-alcref.p $

Утилита закачки справочника видов алкогольной продукции

Автор: Хныкин Павел Андреевич
Дата создания: 09/20/06
Author: Pavel Khnykin
Creation date: 09/20/06

*/
define input parameter parparentproc as widget-handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: 9ebe6f343c82, 149, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Mon Feb 16 20:50:30 2015 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: i-alcref.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/i-alcref.p $":U .
define variable vss-description as character no-undo init "Утилита закачки видов алкоголя".
{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ rep/repfrm.i def  }
{ cmp/trg-def.i     }
{ cmp/showinf.i     }
{ gbl/getcntxt.i def }

/* scopes */
&scop import-file "cmp/alctype.ref":U
&scop log-file    "alctype-log.ref":U
&scop alc-type-delim ";":U

/* !!! temp-tables */
define temp-table tt-alc-type no-undo like ub.alc-type.

/* streams */
define stream in-stream.
DEFINE STREAM log-stream.

/* buffers */
define buffer buf_alc-type      for ub.alc-type.
define buffer buf_tt-alc-type   for tt-alc-type.
define buffer buf_alc-type-gds  for ub.alc-type-gds.

/* variables */
define variable v-log             as logical   no-undo .

define variable v-repfrm-str      as character no-undo .
define variable v-filename        as character no-undo .
define variable v-alc-type-code   as character no-undo .
define variable v-alc-type-name   as character no-undo .
define variable v-sea-sort        as character no-undo .
define variable v-str             as character no-undo .
define variable v-error           as character no-undo .

define variable v-alc-type-status as integer   no-undo .
define variable v-counter         as integer   no-undo .
define variable v-file-str-num    as integer   no-undo .
define variable v-i               as integer   no-undo .
define variable v-num             as integer   no-undo .

PROCEDURE write-log:
   define input parameter p-log-message as character no-undo.
   define input parameter p-error       as logical no-undo.
   define input parameter p-message     as logical no-undo.

   if p-message then do:
      MESSAGE p-log-message
      VIEW-AS ALERT-BOX INFORMATION .
   end.

   EXPORT STREAM log-stream DELIMITER "~t"
         TODAY
         TIME
         g#userid
         g#db-num
         p-log-message
   .

   if p-error then DO:
      OUTPUT STREAM log-stream CLOSE.
      return error p-log-message.
   end.
end procedure. /* write-log */


do
on error  undo, return error return-value
on endkey undo, return error return-value
on stop   undo, return error return-value
  :

{ gbl/getcntxt.i get }

  OUTPUT STREAM log-stream TO VALUE( {&log-file} ) CONVERT SOURCE "1251" APPEND.
      run write-log in this-procedure
            ( input "Начат импорт справочника видов алкоголя"
            , input no
            , input no
            ) .
     .
  message
    "Импорт справочника видов алкогольной продукции." skip
    "Начать импорт?"
  view-as alert-box question
  buttons yes-no update v-log.

  IF v-log <> YES THEN DO:
     run write-log in this-procedure
            ( input "отказ от импорта справочника"
            , input yes
            , input yes
            ) .
  END.
  /* ИМПОРТ типов алкогольной продукции из файла */
  ASSIGN
    v-filename     = SEARCH ({&import-file})
    v-counter      = 0
    v-file-str-num = 0
    v-repfrm-str   = "Чтение файла...":U
  .
  if v-filename = ? then do :
     run write-log in this-procedure
            ( input substitute( "Не найден файл &1.", {&import-file} )
            , input yes
            , input yes
            ) .
  END.

  EMPTY TEMP-TABLE tt-alc-type.

  INPUT STREAM in-stream FROM VALUE( v-filename ) CONVERT SOURCE "1251".
      run write-log in this-procedure
            ( input substitute("открыт файл &1", v-filename)
            , input no
            , input no
            ) .

  { rep/repfrm.i on 1 }

  REPEAT /* TRANSACTION
  ON ERROR UNDO, NEXT */
  :

    ASSIGN
      v-str           = ""
      v-alc-type-code = ""
      v-alc-type-name = ""
      v-sea-sort      = ""
      v-alc-type-status      = 0
      v-num           = 0
    .
    IMPORT STREAM in-stream UNFORMATTED v-str NO-ERROR .
    IF ERROR-STATUS :ERROR THEN DO:
      INPUT  STREAM in-stream  CLOSE.
      run write-log in this-procedure
            ( input SUBSTITUTE( "Ошибка при импорте данных из файла &1."
                              , {&import-file} )
            , input yes
            , input yes
            ) .
    END.

    ASSIGN
      v-num          = NUM-ENTRIES( v-str , {&alc-type-delim} )
      v-file-str-num = v-file-str-num + 1
    .

    if v-num <> 4 then do:
      INPUT  STREAM in-stream  CLOSE.
      run write-log in this-procedure
            ( input SUBSTITUTE( "В файле &1 неверный формат строки &2."
                             , {&import-file}
                             , v-file-str-num
                             )
            , input yes
            , input yes
            ) .
    END.

    ASSIGN
       v-alc-type-code = ENTRY( 1 , v-str , {&alc-type-delim} )
       v-alc-type-name = ENTRY( 2 , v-str , {&alc-type-delim} )
       /* 3 пункт оставлен для совместимости с 14 версией по файлу данных */
       v-sea-sort      = STRING( INTEGER( ENTRY( 3 , v-str , {&alc-type-delim} ) ) , "9999" )
       v-alc-type-status      = INTEGER( entry( 4 , v-str , {&alc-type-delim} ) )
       NO-ERROR
    .
    IF ERROR-STATUS :ERROR THEN DO :
      INPUT  STREAM in-stream  CLOSE.
      run write-log in this-procedure
            ( input SUBSTITUTE( "Ошибка при импорте данных из файла &1 в строке &2.&3&4"
                             , {&import-file}
                             , v-file-str-num)
            , input yes
            , input yes
            ) .
    END.


    IF CAN-FIND( FIRST buf_tt-alc-type WHERE buf_tt-alc-type.alc-type-code = v-alc-type-code
                                       NO-LOCK)
    THEN DO:
      INPUT  STREAM in-stream  CLOSE.
      run write-log in this-procedure
            ( input SUBSTITUTE( "В файле &1 присутствует более одного вида алкогольной продукции с кодом: &2."
                              , {&import-file}
                              , v-alc-type-code
                              )
            , input yes
            , input yes
            ) .
    END.

    CREATE tt-alc-type.
    ASSIGN
      v-counter                   = v-counter + 1
      tt-alc-type.alc-type-code   = v-alc-type-code
      tt-alc-type.alc-type-name   = v-alc-type-name
      tt-alc-type.alc-type-status = v-alc-type-status
    .
      run write-log in this-procedure
            ( input substitute("Импортирован &1, &2", v-alc-type-code, v-alc-type-code)
            , input no
            , input no
            ) .
     .

    { rep/repfrm.i disp v-counter v-repfrm-str }
  END. /* repeat input */

  INPUT STREAM in-stream CLOSE.
  { rep/repfrm.i off }

   run write-log in this-procedure
         ( input "Достигнут конец файла"
         , input no
         , input no
         ) .

  /* меняем статус на типах, отсутствующих в закачке */
  FOR EACH buf_alc-type /* WHERE buf_alc-type.alc-type-status = 0 */
                        EXCLUSIVE-LOCK
                        :

      IF NOT CAN-FIND( FIRST tt-alc-type
                       WHERE tt-alc-type.alc-type-code = buf_alc-type.alc-type-code
                       NO-LOCK )
      THEN DO:
         if can-find ( first buf_alc-type-gds
                       where buf_alc-type-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
                       no-lock
                     ) then do:
            ASSIGN
               buf_alc-type.alc-type-status = 1
            .
            run write-log in this-procedure
               ( input SUBSTITUTE("В файле &1 отсутствовал вид алкогольной продукции с кодом: &2. Ему изменен статус с 0 на 1. Не забудьте открепить товары."
                     , {&import-file}
                     , buf_alc-type.alc-type-code
                     )
               , input no
               , input yes
               ) .
         end.
         else DO:
            delete buf_alc-type.
         end.
      END.
  END.


  ASSIGN
    v-counter     = 0
    v-repfrm-str  = "Загрузка видов алкогольной продукции...":U
  .

  /* начинаем раскручивать закачаные типы */
  FOR EACH tt-alc-type NO-LOCK :
      ASSIGN
        v-counter = v-counter + 1
      .
      FIND FIRST buf_alc-type WHERE buf_alc-type.alc-type-code = tt-alc-type.alc-type-code
                              NO-LOCK
                              NO-ERROR
                              .
      /* если тип уже есть в справочнике */
      IF AVAILABLE buf_alc-type THEN DO:
        FIND CURRENT buf_alc-type EXCLUSIVE-LOCK NO-WAIT.
        /* !!! */
        IF LOCKED buf_alc-type THEN DO :
         run write-log in this-procedure
            ( input SUBSTITUTE ( "Запись вида алкогольной продукции <&1. &2> редактируется.&3Изменение записи невозможно."
                       , tt-alc-type.alc-type-code
                       , tt-alc-type.alc-type-name
                       , {&new-line}
                       )
            , input yes
            , input yes
            ) .
        END. /* LOCKED */
        ELSE DO :
          /* если тип требуется удалить */
          /* !!! */
          IF tt-alc-type.alc-type-status <> 0 THEN DO:
             /* проверяем отсутствие привязок товара к типу */
             FIND FIRST buf_alc-type-gds WHERE buf_alc-type-gds.alc-type-inner-code = tt-alc-type.alc-type-inner-code
                                           AND buf_alc-type-gds.alc-type-inner-code = tt-alc-type.alc-type-inner-code
                                         NO-LOCK
                                         NO-ERROR
                                         .
             IF AVAILABLE buf_alc-type-gds THEN do:
               run write-log in this-procedure
                  ( input SUBSTITUTE( "К виду алкогольной продукции <&1. &2> есть привязаные товары.&3Удаление вида невозможно."
                                 , tt-alc-type.alc-type-code
                                 , tt-alc-type.alc-type-name
                                 , {&new-line}
                                 )
                  , input no
                  , input yes
                  ) .
             END.
             ELSE DO :
               DELETE buf_alc-type.
             END.
          END. /* если тип требуется удалить */
          /* редактируем тип */
          ELSE DO:
            ASSIGN
              buf_alc-type.alc-type-name = tt-alc-type.alc-type-name
            .
          END. /* редактируем тип */
        END. /* NOT LOCKED */
      END. /* если тип уже есть в справочнике */

      /* если новый тип */
      ELSE DO:
        IF tt-alc-type.alc-type-status = 0 THEN DO:
          v-num = next-value ( s-alc-type , {&db-name_schema}).
          CREATE buf_alc-type.
          ASSIGN
             buf_alc-type.alc-type-inner-code = v-num
             buf_alc-type.create-user-db-num  = v-cntxt-db-num

             buf_alc-type.alc-type-code       = tt-alc-type.alc-type-code
             buf_alc-type.alc-type-name       = tt-alc-type.alc-type-name

             buf_alc-type.alc-type-status     = tt-alc-type.alc-type-status
             buf_alc-type.create-user         = '' /* !!! */
             buf_alc-type.create-date         = TODAY
             buf_alc-type.create-time         = TIME
             buf_alc-type.corr-user-name      = '' /* !!! */
             buf_alc-type.corr-date           = TODAY
             buf_alc-type.corr-time           = TIME
          .
        END.
      END. /* если новый тип */
      { rep/repfrm.i disp v-counter v-repfrm-str }
  END. /* FOR EACH tt-alc-type */

  /* чистим за собой */
  { rep/repfrm.i off }
  EMPTY TEMP-TABLE tt-alc-type.

  run write-log in this-procedure
      ( input "Импорт справочника завершен!"
      , input NO
      , input yes
      ) .

  OUTPUT STREAM log-stream CLOSE.
END. /* DO ON ERROR */