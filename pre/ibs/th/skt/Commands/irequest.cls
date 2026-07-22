using ibs.th.skt.ControlledClients.*.
using ibs.th.skt.HeadHttp from propath.
block-level on error undo, throw.
class ibs.th.skt.Commands.IRequest abstract:
  define public property ContentBuff as memptr no-undo
    get.
    set.
  define public property HeadHTTP as HeadHTTP no-undo
    get.
    set.
  define public property Content as longchar no-undo
    get:
       if Content eq ? or Content = ""
       then do:
          if not (              ContentBuff = ?
                     or get-size (ContentBuff) = ?
                     or get-size (ContentBuff) = 0)
               and not HeadHttp:contentType = 'raw'
          then
               copy-lob from ContentBuff to Content no-error.
       end.
       return Content.
    end.
    set.
  define public property HndlSocket as handle no-undo
    get.
    set.
  define public property queryAdr as character  no-undo
  get:
     return if valid-object (HeadHTTP) then HeadHTTP:queryAdr else "".
  end.
  define public property queryPar as character  no-undo
  get:
     return if valid-object (HeadHTTP) then HeadHTTP:queryPar else "".
  end.
  method public character getQueryParam(iParam as char):
     return if valid-object (HeadHTTP) then HeadHTTP:getQueryParam(iParam) else ?.
  end.
  method public character convertContentInCharset(encoding as char):
     if     not (   ContentBuff = ?
                 or get-size (ContentBuff) = ?
                 or get-size (ContentBuff) = 0)
        and not HeadHttp:contentType = 'raw'
     then do:
        if encoding eq ?
        then
           copy-lob from ContentBuff to Content no-error.
        else
           copy-lob from ContentBuff to Content convert source codepage encoding no-error.
        if error-status:error
        then return error "Ошибка при преобразовании кодировки " + error-status:get-message(1).
     end.
  end.
end class.
