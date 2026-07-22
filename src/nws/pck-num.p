block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: pck-num.p $
$Archive: nws/pck-num.p $

√енераци€ номера пакета, имени файла пакета, имени каталога источника и каталога назначени

јвтор: ”ханов ƒмитрий ёрьевич
ƒата создани€: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

define input        parameter p-action     as   character    no-undo .
define input        parameter p-db-num     like ub.db.db-num no-undo .
define input-output parameter p-pack-num   as   integer      no-undo .
define output       parameter p-pack-name  as   character    no-undo .
define output       parameter p-source-dir as   character    no-undo .
define output       parameter p-target-dir as   character    no-undo .
define output       parameter p-temp-dir   as   character    no-undo .

def var vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
def var vss-author      as character no-undo init "$Author: expertek $":U .
def var vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
def var vss-workfile    as character no-undo init "$Workfile: pck-num.p $":U .
def var vss-archive     as character no-undo init "$Archive: nws/pck-num.p $":U .
def var vss-description as character no-undo init "√енераци€ номера пакета, имени файла пакета, имени каталога источника и каталога назначени".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ nws/nws-def.i  }

FUNCTION nws-db-format returns character ( input p-db-num as integer):
  define variable v-nws-db-format as character no-undo .
  assign
    v-nws-db-format = string( p-db-num,  (if p-db-num > 999 then "99999":U else "999":U ) )
  .
  return v-nws-db-format.
END FUNCTION.

do
on error undo, return error
:
  define buffer buf_pck-sent for ub.pck-sent .
  define buffer buf_pck-rcvd for ub.pck-rcvd .

  define variable v-work-dir as character no-undo .

  if p-pack-num = -1 then do:
    case p-action :
      when "get":U then do:
        find last buf_pck-rcvd
          where buf_pck-rcvd.db-num = p-db-num
          use-index pi
          no-error
        .
        if not available buf_pck-rcvd then do:  /* не было ни одного пакета */
          assign
            p-pack-num = 0
          .
        end.
        else do:
          assign
            p-pack-num = buf_pck-rcvd.pack-num + 1
          .
        end.
      end.
      when "put":U then do:
        find last buf_pck-sent
          where buf_pck-sent.db-num = p-db-num
          use-index pi
          no-error
        .
        if not available buf_pck-sent then do:  /* не было ни одного пакета */
          assign
            p-pack-num = 0
          .
        end.
        else do:
          assign
            p-pack-num = buf_pck-sent.pack-num + 1
          .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          "Ќе предусмотрена операци€" p-action "дл€" vss-workfile
          view-as alert-box error.
        return error.
      end.
    end case.
  end.

  case p-action :
    when "get":U then do:
      assign
        v-work-dir   = nws-db-format( p-db-num ) + "-":U + nws-db-format( g#db-num )
        p-temp-dir   = nws-exch-dir + {&back-slash-char} + v-work-dir + ".":U + nws-db-format( g#db-num )
        p-source-dir = nws-exch-dir + {&back-slash-char} + v-work-dir
        p-target-dir = nws-heap-dir + {&back-slash-char} + v-work-dir
      .
    end.
    when "put":U then do:
      assign
        v-work-dir   = nws-db-format( g#db-num ) + "-":U + nws-db-format( p-db-num )
        p-temp-dir   = nws-exch-dir + {&back-slash-char} + v-work-dir + ".":U + nws-db-format( g#db-num )
        p-source-dir = nws-heap-dir + {&back-slash-char} + v-work-dir
        p-target-dir = nws-exch-dir + {&back-slash-char} + v-work-dir
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Ќе предусмотрена операци€" p-action "дл€" vss-workfile
        view-as alert-box error.
      return error.
    end.
  end case.

  assign
    p-pack-name = "p":U + string( p-pack-num, "9999999":U ) + ".txt":U.
  .

  /* если каталога source-dir нет, то создадим его */
  assign
    file-info:file-name = p-source-dir
  .
  if file-info:file-type = ?
    or not ( file-info:file-type begins "D":U ) then do:
    os-create-dir value( p-source-dir ).
    if os-error <> 0 then do:
      return error string( vss-workfile + {&space-char}
                           + " аталог" + {&space-char} + p-source-dir
                           + {&space-char} + "отсутствует, а создать его не удалось." ).
    end.
  end.
  /* если каталога target-dir нет, то создадим его */
  assign
    file-info:file-name = p-target-dir
  .
  if file-info:file-type = ?
    or not ( file-info:file-type begins "D":U ) then do:
    os-create-dir value( p-target-dir ).
    if os-error <> 0 then do:
      return error string( vss-workfile + {&space-char}
                           + " аталог" + {&space-char} + p-target-dir
                           + {&space-char} + "отсутствует, а создать его не удалось." ).
    end.
  end.

end.

/* $Workfile: pck-num.p $ end */