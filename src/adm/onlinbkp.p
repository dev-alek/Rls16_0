block-level on error undo, throw.
/*

$Revision: 1eba0946c2d7, 3078, rls $
$Author: DRuban $
$Date: Пт авг 05 19:16:25 2022 +0300 $
$Workfile: onlinbkp.p $
$Archive: adm/onlinbkp.p $

Online backup

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/22/04
Author: Dmitry Ukhanov
Creation date: 03/22/04

*/

define output parameter p-message as character no-undo .


def var vss-revision    as character no-undo init "$Revision: 1eba0946c2d7, 3078, rls $":U .
def var vss-author      as character no-undo init "$Author: DRuban $":U .
def var vss-date        as character no-undo init "$Date: Пт авг 05 19:16:25 2022 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: onlinbkp.p $":U .
def var vss-archive     as character no-undo init "$Archive: adm/onlinbkp.p $":U .
def var vss-description as character no-undo init "Online backup".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ adm/onlinbkp.i }

do
on error undo, return error return-value
:
  define variable v-need-bkp    as logical   no-undo .
  define variable v-bat-name    as character no-undo .
  define variable v-msg-name    as character no-undo .
  define variable v-path-dlc    as character no-undo .
  define variable v-path-src-db as character no-undo .
  define variable v-path-dst-db as character no-undo .

  define variable v-del-file    as character no-undo .
  define variable v-err-code    as integer   no-undo .
  define variable v-err-mess    as character no-undo .

  define variable v-ind         as integer   no-undo .

  define variable v-temp-char   as character no-undo .

  define buffer buf_batchprocess for ub.batchprocess .
  define buffer buf_db           for ub.db .

  define variable v-full-db-list   as character no-undo .
  define variable v-lock-db-list   as character no-undo .
  define variable v-unlock-db-list as character no-undo .

  define stream ImpStream .

  define frame inf
    "Подождите..." space(5)
    with view-as dialog-box side-labels 1 columns three-d title "Online backup".

  

  run check-need-onlinebkp in this-procedure
    ( output v-need-bkp
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении необходимости проведения onlinebkp" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  if v-need-bkp <> true then do:
    assign
      p-message = "":U
    .
    return .
  end.

  /* Имя bat файла запускающего online backup */
  get-key-value section "onlinebkp"
                    key "bat-name"
                  value v-bat-name.
  if v-bat-name = ? then do
  :
    assign
      p-message = substitute( "&1. Backup не произведен. Отсутствует настройка на файл запуска (ключ [bat-name] в секции [onlinebkp]). ", vss-workfile )
    .
  end.
  else do:
    view frame inf.
    if search( v-bat-name ) = ? then do
    :
      return error substitute( "&1. Не найден файл запуска online backup (&2).", vss-workfile, v-bat-name ) .
    end.

    assign
      v-bat-name = search( v-bat-name )
    .

    get-key-value section "onlinebkp"
                      key "msg-name"
                    value v-msg-name.
    if v-msg-name = ? then do:
      return error substitute( "&1. Ошибка .ini файла: отсутствует ключ [msg-name] в секции [onlinebkp].", vss-workfile ) .
    end.

    /* Путь на Progress */
    get-key-value section "onlinebkp"
                      key "path-dlc"
                    value v-path-dlc.
    if v-path-dlc = ? then do:
      return error substitute( "&1. Ошибка .ini файла: отсутствует ключ [path-dlc] в секции [onlinebkp].", vss-workfile ) .
    end.
    assign
      file-info:file-name = v-path-dlc
    .
    if file-info:file-type = ?
      or not ( file-info:file-type begins "D":U )
    then do:
      return error substitute( "&1. Каталог &2 отсутствует", vss-workfile, v-path-dlc ) .
    end.

    /* Путь где лежит БД */
    get-key-value section "onlinebkp"
                      key "path-src-db"
                    value v-path-src-db.
    if v-path-src-db = ? then do:
      return error substitute( "&1. Ошибка .ini файла: отсутствует ключ [pach-src-db] в секции [onlinebkp].", vss-workfile ) .
    end.

    /* Куда копировать */
    get-key-value section "onlinebkp"
                      key "path-dst-db"
                    value v-path-dst-db.
    if v-path-dst-db = ? then do:
      return error substitute( "&1. Ошибка .ini файла: отсутствует ключ [pach-dst-db] в секции [onlinebkp].", vss-workfile ) .
    end.

    do transaction
    on error undo, return error return-value
    :
      assign
        v-full-db-list   = "":U
        v-lock-db-list   = "":U
        v-unlock-db-list = "":U
      .
      for each buf_db
      on error undo, return error return-value
      :
        if v-full-db-list <> "":U then do:
          assign
            v-full-db-list = v-full-db-list + {&comma-char}
          .
        end.
        assign
          v-full-db-list = v-full-db-list + substitute( "&1", buf_db.db-num )
        .

        run nws/lock-nws.p ( input buf_db.db-num
                            ,buffer buf_db
                           ) no-error .
        if error-status:error then do:
          if v-unlock-db-list <> "":U then do:
            assign
              v-unlock-db-list = v-unlock-db-list + {&comma-char}
            .
          end.
          assign
            v-unlock-db-list = v-unlock-db-list + substitute( "&1", buf_db.db-num )
          .
        end.
        else do:
          if v-lock-db-list <> "":U then do:
            assign
              v-lock-db-list = v-lock-db-list + {&comma-char}
            .
          end.
          assign
            v-lock-db-list = v-lock-db-list + substitute( "&1", buf_db.db-num )
          .
        end.
      end.
      if v-lock-db-list <> v-full-db-list then do:
        assign
          p-message = substitute( "&1. Произвести Online backup невозможно, т.к. заблокированы БД &2", vss-workfile, v-unlock-db-list )
        .
        undo, return .
      end.

      do while search( v-msg-name ) <> ?
      on error undo, return error return-value
      :
        assign
          v-del-file = search( v-msg-name )
          v-err-code = 0
        .

        bl1:
        do v-ind = 1 to 60 :
          os-delete value( v-del-file ).
          assign
            v-err-code = os-error
            file-info:file-name = v-del-file
          .
          if v-err-code = 0
            or file-info:file-type = ?
          then do:
            assign
              v-err-code = 0
            .
            leave bl1 .
          end.
          pause 1 no-message .
        end.
        if v-err-code <> 0 then do:
          run adm/os-err.p ( output v-err-mess ).
          return error substitute( "&1. Невозможно удалить файл отчета о выполнении backup (&2) &3 &4"
                                  ,vss-workfile
                                  ,v-del-file
                                  ,{&new-line}
                                  ,v-err-mess
                                ).
        end.
      end.

      os-command SILENT value( substitute( '&1 "&2" "&3" "&4" "&5"', v-bat-name, v-path-dlc, v-path-src-db, v-path-dst-db, v-msg-name ) ).

      if search( v-msg-name ) = ? then do:
        return error substitute( "&1. Не найден файл отчета о выполнении backup (&2).", vss-workfile, v-msg-name ) .
      end.

      assign
        v-msg-name = search( v-msg-name )
      .

      input stream ImpStream from value( v-msg-name ) .
      assign
        p-message = "":U
      .
      repeat
      on error undo, return error substitute( "&1. Error repeat", vss-workfile )
      :
        import stream ImpStream unformatted v-temp-char no-error .
        if p-message = "":U then do:
          if trim( v-temp-char ) <> "":U then do:
            assign
              p-message = v-temp-char
            .
          end.
        end.
        else do:
          assign
            p-message = p-message + {&new-line} + v-temp-char
          .
        end.
      end.
      input stream ImpStream close .

      assign
        p-message = trim( p-message )
      .

      if CAPS( p-message ) begins "YES":U
        or CAPS( p-message ) begins "OK":U
      then do:
        assign
          p-message = substitute( "Backup успешно завершен." )
        .
      end.
      else do:
        return error substitute( "&1. Ошибка backup:&2&3", vss-workfile, {&new-line}, p-message ) .
      end.
    end.
  end.

  hide frame inf.
end.

/* $Workfile: onlinbkp.p $ end */