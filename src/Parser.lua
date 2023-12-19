local PLOOP_PATH = os.getenv("LUA_FAUX_COMBINATOR_PLOOP_PATH")
if PLOOP_PATH then
  package.path = package.path .. ";" .. PLOOP_PATH .. "?.lua;" .. PLOOP_PATH .. "?/init.lua"
end

-- TODO factor this out?
PLOOP_PLATFORM_SETTINGS = {
  --ENV_ALLOW_GLOBAL_VAR_BE_NIL = false,
  OBJECT_NO_RAWSEST = true,
  OBJECT_NO_NIL_ACCESS = true
}

require "PLoop"(function (_ENV)
  namespace "FauxCombinator"

  __Sealed__()
  __Abstract__()
  class "ParserException" { Exception }

  __Sealed__()
  class "WrongTokenTypeException" { ParserException }

  __Sealed__()
  class "EOFException" { ParserException }

  __Sealed__()
  class "EitherNoMatchException" { ParserException }

  interface "IToken" (function (_ENV)
    __Abstract__()
    function GetType()
    end
  end)

  -- TODO AllowObject?
  -- https://github.com/kurapica/Scorpio/blob/c6e4fc39438bc7a8d429270a09a73e366c1de16e/Modules/Global.lua#L175-L183
  class "BasicToken" (function (_ENV)
    extend "IToken"
    property "Type" { type = String }

    function GetType(self)
      return self.Type
    end
  end)

  class "Parser" (function (_ENV)
    property "Tokens" { type = Array[IToken] }
    field { index = 1 }

    __Return__{Bool}
    function IsEOF(self)
      return self.index > #self.Tokens
    end

    __Arguments__{}
    __Return__{IToken/nil}
    function Peek(self)
      if self:IsEOF() then
        return
      end
      return self.Tokens[self.index]
    end

    __Arguments__{String}
    __Return__{IToken/nil}
    function Maybe(self, type)
      local token = self:Peek()
      if token and token:GetType() == type then
        self.index = self.index + 1
        return token
      end
    end

    __Arguments__{String}
    __Return__{IToken}
    function Expect(self, type)
      if self:IsEOF() then
        throw(EOFException("EOF"))
      end

      local token = self:Peek()
      if token and token:GetType() == type then
        self.index = self.index + 1
        return token
      else
        throw(WrongTokenTypeException('Expected '..type..', got '..token:GetType()))
      end
    end

    __Arguments__{String}
    __Return__{Function}
    function Expect_(self, type)
      return function ()
        return self:Expect(type)
      end
    end

    __Arguments__{Function}
    function Try(self, fn)
      local index = self.index
      local ok, res = pcall(fn)
      if ok then
        return res
      elseif Class.IsObjectType(res, ParserException) then
        self.index = index -- restore index
      else
        throw(res)
      end
    end

    __Arguments__{String}
    function Try(self, type)
      return self:Try(self:Expect_(type))
    end

    __Arguments__{(Function+String) * 0}
    __Return__{IToken}
    function Either(self, ...)
      for _, fn in pairs({...}) do
        local res = self:Try(fn)
        if res then return res end
      end
      throw(EitherNoMatchException("Either matched no branches"))
    end
  end)
end)
