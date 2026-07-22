/*

$Revision: 64ee1a69159c, 2047, rls $
$Author: SSlivenko $
$Date: Fri Oct 18 11:00:57 2019 +0300 $
$Workfile: progressbar.cls $
$Archive: ibs/th/gbl/progressbar.cls $

Класс визуализация прогресс бара

Автор: Хныкин Павел Андреевич
Дата создания: 10/09/07
Author: Pavel Khnykin
Creation date: 10/09/07

Пример использовани

  using Ibs.Th.Gbl.ProgressBar.
block-level on error undo, throw.
  define variable v-i as integer no-undo .
  define variable v-prg as class ProgressBar no-undo .

  v-prg = new ProgressBar( 1 , 100000 ).
  v-prg:show-bar().

  do v-i = 1 to 100000:
      v-prg:increment().
  end.

  v-prg:hide-bar().
  delete object v-prg.
  assign
      v-prg = ?
  .

  refresh_()  для обновления из пользовательского объекта
  process events не работает из пользовательского объекта

*/



CLASS Ibs.Th.Gbl.ProgressBar
  IMPLEMENTS Ibs.Th.Gbl.IProgressBar
:
  &scop frame-name progressbar
  { cmp/str-glbl.i class }
  &scoped-define vssseq {&sequence}
  define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: progressbar.cls $ $Revision: 64ee1a69159c, 2047, rls $".

    define protected variable v-stepvalue         as int64      no-undo.
    define protected variable v-prc               as character  no-undo.
    define protected variable v-prc-int           as integer    no-undo.
    define protected variable v-visible           as logical    no-undo.
    define protected variable v-maxvalue          as int64      no-undo.
    define protected variable v-minvalue          as int64      no-undo.
    define protected variable v-curvalue          as int64      no-undo.
    define protected variable v-time1             as int64      no-undo.
    define protected variable v-time2             as int64      no-undo.
    define protected variable v-prediction        as character  no-undo.
    define protected variable v-elapsed           as character  no-undo.
    define protected variable v-text              as character  no-undo.
    define protected variable v-last-repaint-time as int64      no-undo.
    define protected variable v-is-canceled       as logical    no-undo.

    define rectangle r-complete
        size-chars 78 by 1
        bgcolor 8.

    define rectangle r-progress
        size-chars 1 by 1
        edge-pixels 1
        bgcolor 14.

    define button b-cancel
        label "Отмена"
        size 10 by 1.

    define frame {&frame-name}
        r-complete at col 1 row 2
        r-progress at col 1 row 2
        v-prc at col 24 row 1 NO-LABEL
        v-elapsed    at col 1  row 3 FORMAT "X(10)" LABEL "Прошло"
        v-prediction at col 1  row 4 FORMAT "X(10)" LABEL "Расчетное время"
        b-cancel     at col 21 row 5
        space( 0 ) skip( 0 )
    with view-as dialog-box keep-tab-order
         side-labels no-underline three-d
         cancel-button b-cancel
    .

    DEFINE PUBLIC PROPERTY process-event AS logical INITIAL true NO-UNDO /*process events не работает при вызове из пользовательского объекта*/
      get.
      set.

    DEFINE PUBLIC PROPERTY fg-color AS INTEGER NO-UNDO
        GET :
            RETURN r-progress:BGCOLOR IN FRAME {&FRAME-NAME}.
        END GET.
        SET ( INPUT p-color AS INTEGER ) :
            ASSIGN
                r-progress:BGCOLOR IN FRAME {&FRAME-NAME} = p-color
            .
        END SET.

    DEFINE PUBLIC PROPERTY bg-color AS INTEGER NO-UNDO
        GET :
            RETURN r-complete:BGCOLOR IN FRAME {&FRAME-NAME}.
        END GET.
        SET ( INPUT p-color AS INTEGER ) :
            ASSIGN
                r-complete:BGCOLOR IN FRAME {&FRAME-NAME} = p-color
            .
        END SET.

    DEFINE PUBLIC PROPERTY frame-title AS CHARACTER NO-UNDO
        GET:
            RETURN FRAME {&FRAME-NAME}:TITLE.
        END GET.
        SET ( INPUT p-str AS CHARACTER ) :
            ASSIGN
                FRAME {&FRAME-NAME}:TITLE = p-str
            .
        END SET.

    DEFINE PUBLIC PROPERTY tick AS INT64 INITIAL 10000 NO-UNDO
        GET.
        SET.

    DEFINE PUBLIC PROPERTY can-cancel AS LOGICAL INITIAL NO NO-UNDO
        GET.
        SET.

    DEFINE PUBLIC PROPERTY is-canceled AS LOGICAL INITIAL NO NO-UNDO
        GET:
          return v-is-canceled .
        END GET.

    DEFINE PUBLIC PROPERTY cb-handle AS HANDLE NO-UNDO
      get.
      set.

    DEFINE PUBLIC PROPERTY cb-proc-name AS CHARACTER INITIAL ? NO-UNDO
      get.
      set.

    DEFINE PUBLIC PROPERTY cb-params AS CHARACTER INITIAL ? NO-UNDO
      get.
      set.

    CONSTRUCTOR PUBLIC ProgressBar ( INPUT p-min AS INT64 , INPUT p-max AS INT64 ) :
        this-object( p-min, p-max , 0 ).
    END CONSTRUCTOR.

    CONSTRUCTOR PUBLIC ProgressBar ( INPUT p-min AS INT64 , INPUT p-max AS INT64 , INPUT p-cur AS INT64 ) :
        define variable v-complete as integer no-undo.

        do with frame {&frame-name}:
            assign
                v-minvalue                = p-min
                v-maxvalue                = if ( p-min > p-max ) then p-min else p-max
                v-curvalue                = p-cur
                v-stepvalue               = if ( v-maxvalue - v-minvalue ) < 100 then ( 100 / ( v-maxvalue - v-minvalue ) )
                                            else integer( ( v-maxvalue - v-minvalue ) / 100 )
                v-prc-int                 = integer( ( v-curvalue / v-maxvalue ) * 100 )
                v-prc                     = substitute("&1 %" , v-prc-int )
                v-complete                = integer( ( r-complete:width-chars / v-maxvalue ) * v-curvalue )
                r-progress:width-chars    = if v-complete = 0 then 0.01 else v-complete
                b-cancel:visible          = false
                frame {&frame-name}:title = "Обработка..."
            .
        end.

    END CONSTRUCTOR.

    DESTRUCTOR ProgressBar () :

    END DESTRUCTOR.

    ON CHOOSE OF b-cancel IN FRAME {&frame-name}
    DO:
      if valid-handle(cb-handle)
      then do:
        if cb-handle:get-signature(cb-proc-name) <> ""
        then do:
          if cb-params <> ? and cb-params <> ""
          then do:
            run value(cb-proc-name) in cb-handle ( input cb-params ) no-error .
          end.
          else do:
            run value(cb-proc-name) in cb-handle no-error .
          end.
          if error-status :error
          then do:
            return no-apply.
          end.
        end.
      end. /* if valid-handle(cb-handle) */
      assign
        v-is-canceled = yes
      .
      hide-bar().
    END.
/*  */
    METHOD PUBLIC VOID show-bar() :
        display
          r-complete
          v-prc
        with frame {&frame-name}.
        if can-cancel = yes
        then do:
          assign
            b-cancel:visible  = true
          .
          enable
            b-cancel
          with frame {&frame-name}.
        end.
        view frame {&frame-name}.
        assign
            v-visible = yes
            v-time1   = etime
        .
    END METHOD.

    METHOD PUBLIC VOID hide-bar() :
        HIDE FRAME {&FRAME-NAME}.
        ASSIGN
            v-visible = NO
        .
    END METHOD.

    METHOD PUBLIC VOID increment() :
        DEFINE VARIABLE v-mod       AS INT64     NO-UNDO.
        DEFINE VARIABLE v-time-diff AS INT64     NO-UNDO.

        IF v-curvalue >= v-maxvalue THEN RETURN.

        ASSIGN
            v-curvalue = v-curvalue + 1
            v-time2 = ETIME
            v-time-diff = INTEGER( TRUNCATE ( ( v-time2 - v-time1 ) / 1000 , 0 ) )
            v-mod = ( v-curvalue MODULO v-stepvalue )
        .
        IF v-visible AND v-mod = 0 THEN DO:
            repaint().
        END.

        ELSE IF ( v-time2 - v-last-repaint-time ) >= tick  THEN DO:
            assign
                v-elapsed = STRING( v-time-diff , 'HH:MM:SS':U )
                v-prediction = IF v-time-diff = 0 THEN "" ELSE string( INT64( TRUNCATE( v-maxvalue * ( v-time2 - v-time1 ) / ( 1000 * v-curvalue ), 0) ) , 'HH:MM:SS':U)
                v-last-repaint-time = v-time2
            .
            display
                v-elapsed
                v-prediction
            with frame {&frame-name}.
        END.
        process-events().
    END METHOD.

    METHOD PUBLIC VOID increment(inMsg as char) :
        DEFINE VARIABLE v-mod       AS INT64     NO-UNDO.
        DEFINE VARIABLE v-time-diff AS INT64     NO-UNDO.
        
        FRAME {&FRAME-NAME}:TITLE = "Обработка..." + inMsg.
        
        increment().

    END METHOD.
    
    METHOD PUBLIC VOID step ( INPUT p-val AS INTEGER ) :
        if p-val <= 0 then return.
        ASSIGN
            v-curvalue = v-curvalue + p-val
        .
        if v-curvalue > v-maxvalue then do:
          assign
            v-curvalue = v-maxvalue
          .
        end.
        IF p-val > v-stepvalue OR (( v-curvalue MODULO v-stepvalue) <= ( ( v-curvalue - p-val ) MODULO v-stepvalue ))  THEN DO:
            repaint().
        END.
        process-events().
    END METHOD.

    METHOD PUBLIC VOID stepto ( INPUT p-val AS INTEGER ) :
        define variable v-sval as int64   no-undo .
        define variable v-lval as int64   no-undo .
        /*
           TODO
             02/12/08 12:46
          В будущем можно сделать чтобы он скакал не только вперед, но и назад
          Зачем не знаю :)
        */
        if p-val < v-curvalue then return.
        if p-val <= 0 then return.
        assign
          v-sval = ( p-val - v-curvalue )
          v-lval = v-curvalue
        .
        if p-val > v-maxvalue then do:
          assign
            v-curvalue = v-maxvalue
          .
        end.
        else do:
          assign
            v-curvalue = p-val
          .
        end.
        IF v-sval > v-stepvalue OR (( v-curvalue MODULO v-stepvalue) <= ( v-lval MODULO v-stepvalue ))  THEN DO:
            repaint().
        END.
        process-events().
    END METHOD.


    METHOD PUBLIC VOID tick () :
        DEFINE VARIABLE v-time-diff AS INT64     NO-UNDO.

        ASSIGN
            v-time2 = ETIME
            v-time-diff = v-time2 - v-time1
        .
        IF ( v-time2 - v-last-repaint-time ) >= tick  THEN DO:
            assign
                v-elapsed = STRING( int64( TRUNCATE ( v-time-diff / 1000 , 0 ) )  , 'HH:MM:SS':U )
                v-last-repaint-time = v-time2
            .
            display
                v-elapsed
            with frame {&frame-name}.
        END.
        process-events().
    END METHOD.

    METHOD PRIVATE VOID repaint () :
        DEFINE VARIABLE v-complete AS INTEGER NO-UNDO.
        DO WITH FRAME {&FRAME-NAME}:
            assign
                v-time2 = ETIME
                v-complete = integer( ( r-complete:width-chars / v-maxvalue ) * v-curvalue )
                r-progress:width-chars = IF v-complete = 0 THEN 0.01 ELSE v-complete
                v-prc-int = INTEGER( ( v-curvalue / v-maxvalue ) * 100 )
                v-prc     = SUBSTITUTE("&1 %" , v-prc-int )
                v-prediction = string( INT64( TRUNCATE( v-maxvalue * ( v-time2 - v-time1 ) / ( 1000 * v-curvalue ), 0) ) , 'HH:MM:SS':U)
                v-elapsed = STRING( INT64( TRUNCATE ( ( v-time2 - v-time1 ) /  1000 , 0 ) ) , 'HH:MM:SS':U )
                v-last-repaint-time = v-time2
            .
            display
                r-progress
                v-prc
                v-prediction
                v-elapsed
            with frame {&frame-name}.
        END.
    END METHOD.

    METHOD PRIVATE VOID process-events () :
      if can-cancel and process-event
      then do:
        process events.
      end.
    END METHOD.
    
    METHOD PUBLIC VOID refresh_() :
        HIDE FRAME {&FRAME-NAME}.
        display r-complete v-prc with frame {&frame-name}.
        VIEW FRAME {&FRAME-NAME}.
    END METHOD.

END CLASS.