block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: fin-init.p $
$Archive: utl/fin-init.p $

Копирование финанс. настроек по фирме - шифры учета, банки и счета

Автор: Кочетков Михаил Юрьевич
Дата создания: 09/14/05
Author: Michael Kochetkov
Creation date: 09/14/05

*/

define input parameter p-host-sour     as integer   no-undo .   /*p-host-sour    - код фирма-источник                                  */
define input parameter p-host-dest     as integer   no-undo .   /*p-host-dest    - код фирма-копи                                      */
define input parameter p-is-cel-nazn   as logical   no-undo .   /*p-is-cel-nazn  - копирование записи fin-code-cel-nazn                */
define input parameter p-is-an-uchet   as logical   no-undo .   /*p-is-an-uchet  - копирование записи fin-code-an-uchet                */
define input parameter p-is-cor-acc    as logical   no-undo .   /*p-is-cor-acc   - копирование записи fin-code-cor-acc                 */
define input parameter p-is-bank       as logical   no-undo .   /*p-is-bank      - копирование записи fin-bank и связ с ней fin-schet  */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: fin-init.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/fin-init.p $":U .
define variable vss-description as character no-undo init "Копирование финанс. настроек по фирме".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

do
on error undo, return error
:

  define buffer buf_sysconf           for sysconf.
  find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-sour no-error .
  if not available buf_sysconf then do:
    message "не найдена фирма-источник " p-host-sour " ."   view-as alert-box error.
    return error.
  end.
  find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-dest no-error .
  if not available buf_sysconf then do:
    message "не найдена фирма-копия " p-host-dest " ."   view-as alert-box error.
    return error.
  end.

  define stream slog .
  define stream serr .

  define buffer buf_fin-code-cel-nazn for fin-code-cel-nazn.
  define buffer buf_fin-code-an-uchet for fin-code-an-uchet.
  define buffer buf_fin-code-cor-acc  for fin-code-cor-acc.
  define buffer buf_fin-bank          for fin-bank.
  define buffer buf_fin-schet         for fin-schet.

  output stream slog to value("fin-init.log") .
  output stream serr to value("fin-init.err") .

  export stream slog "код фирмы-источника " p-host-sour " код фирмы-копии " p-host-dest {&new-line} .

  if p-is-cel-nazn then do:
    export stream slog "копирование записи fin-code-cel-nazn" {&new-line} .
    for each fin-code-cel-nazn no-lock
      where fin-code-cel-nazn.host-code = p-host-sour
      :
      find first buf_fin-code-cel-nazn no-lock
        where buf_fin-code-cel-nazn.host-code = p-host-dest
          and buf_fin-code-cel-nazn.fin-code  = fin-code-cel-nazn.fin-code
        no-error .
      if not available buf_fin-code-cel-nazn then do:
        create buf_fin-code-cel-nazn .
        BUFFER-COPY fin-code-cel-nazn EXCEPT host-code TO buf_fin-code-cel-nazn .
        assign buf_fin-code-cel-nazn.host-code = p-host-dest .
        export stream slog "скопирован " fin-code-cel-nazn.code-value fin-code-cel-nazn.descr {&new-line}  .
      end.
      else do:
        export stream slog "не могу скопировать " fin-code-cel-nazn.code-value fin-code-cel-nazn.descr {&new-line}  .
        export stream serr "не могу скопировать " fin-code-cel-nazn.code-value fin-code-cel-nazn.descr {&new-line}  .
      end.
    end.
  end.

  if p-is-an-uchet then do:
    export stream slog "копирование записи fin-code-an-uchet" {&new-line} .
    for each fin-code-an-uchet no-lock
      where fin-code-an-uchet.host-code = p-host-sour
      :
      find first buf_fin-code-an-uchet no-lock
        where buf_fin-code-an-uchet.host-code = p-host-dest
          and buf_fin-code-an-uchet.fin-code  = fin-code-an-uchet.fin-code
        no-error .
      if not available buf_fin-code-an-uchet then do:
        create buf_fin-code-an-uchet .
        BUFFER-COPY fin-code-an-uchet EXCEPT host-code TO buf_fin-code-an-uchet .
        assign buf_fin-code-an-uchet.host-code = p-host-dest .
        export stream slog "скопирован " fin-code-an-uchet.code-value fin-code-an-uchet.descr {&new-line}  .
      end.
      else do:
        export stream slog "не могу скопировать " fin-code-an-uchet.code-value fin-code-an-uchet.descr {&new-line}  .
        export stream serr "не могу скопировать " fin-code-an-uchet.code-value fin-code-an-uchet.descr {&new-line}  .
      end.
    end.
  end.

  if p-is-cor-acc then do:
    export stream slog "копирование записи fin-code-cor-acc" {&new-line} .
    for each fin-code-cor-acc no-lock
      where fin-code-cor-acc.host-code = p-host-sour
      :
      find first buf_fin-code-cor-acc no-lock
        where buf_fin-code-cor-acc.host-code = p-host-dest
          and buf_fin-code-cor-acc.fin-code  = fin-code-cor-acc.fin-code
        no-error .
      if not available buf_fin-code-cor-acc then do:
        create buf_fin-code-cor-acc .
        BUFFER-COPY fin-code-cor-acc EXCEPT host-code TO buf_fin-code-cor-acc .
        assign buf_fin-code-cor-acc.host-code = p-host-dest .
        export stream slog "скопирован " fin-code-cor-acc.code-value fin-code-cor-acc.descr {&new-line}  .
      end.
      else do:
        export stream slog "не могу скопировать " fin-code-cor-acc.code-value fin-code-cor-acc.descr {&new-line}  .
        export stream serr "не могу скопировать " fin-code-cor-acc.code-value fin-code-cor-acc.descr {&new-line}  .
      end.
    end.
  end.

  if p-is-bank then do:
    export stream slog "копирование записи fin-bank и fin-schet" {&new-line} .
    for each fin-bank no-lock
      where fin-bank.host-code = p-host-sour
      :
      find first buf_fin-bank no-lock
        where buf_fin-bank.host-code = p-host-dest
          and buf_fin-bank.code-bank = fin-bank.code-bank
        no-error .
      if not available buf_fin-bank then do:
        find first buf_fin-bank no-lock
          where buf_fin-bank.host-code = p-host-dest
            and buf_fin-bank.bik = fin-bank.bik
          no-error .
        if not available buf_fin-bank then do:
          create buf_fin-bank .
          BUFFER-COPY fin-bank EXCEPT host-code TO buf_fin-bank .
          assign buf_fin-bank.host-code = p-host-dest .
          export stream slog "скопирован банк " fin-bank.bank-name " БИК " fin-bank.bik {&new-line} .

          for each fin-schet no-lock /* смотрим счета клиентов по этому банку */
            where fin-schet.host-code = p-host-sour
              and fin-schet.code-bank = fin-bank.code-bank
            :
            find first buf_fin-schet no-lock
              where buf_fin-schet.host-code  = p-host-dest
                and buf_fin-schet.code-schet = fin-schet.code-schet
            no-error .
            if not available buf_fin-schet then do:
              create buf_fin-schet .
              BUFFER-COPY fin-schet EXCEPT host-code TO buf_fin-schet .
              assign buf_fin-schet.host-code = p-host-dest .
              export stream slog "скопирован р.счет " fin-schet.r-schet " в банке " fin-bank.bank-name " БИК " fin-bank.bik {&new-line} .
            end.
            else do:
              export stream slog "не могу скопировать р.счет " fin-schet.r-schet " в банке " fin-bank.bank-name " БИК " fin-bank.bik {&new-line} .
              export stream serr "не могу скопировать р.счет " fin-schet.r-schet " в банке " fin-bank.bank-name " БИК " fin-bank.bik {&new-line}.
            end.
          end.
        end.
        else do:
          export stream slog "не могу скопировать банк " fin-bank.bank-name " - уже имеется БИК " fin-bank.bik {&new-line} .
          export stream serr "не могу скопировать банк " fin-bank.bank-name " - уже имеется БИК " fin-bank.bik {&new-line} .
        end.
      end.
      else do:
        export stream slog "не могу скопировать банк " fin-bank.bank-name " - уже имеется ID " {&new-line} .
        export stream serr "не могу скопировать банк " fin-bank.bank-name " - уже имеется ID " {&new-line} .
      end.
    end.
  end.

  output stream slog close .
  output stream serr close .

end.