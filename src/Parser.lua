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
  class "WrongTokenTypeException" { Exception }

  __Sealed__()
  class "EOFException" { Exception }

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

    function IsEOF(self)
      return self.index > #self.Tokens
    end

    __Arguments__{}(IToken/nil)
    function Peek(self)
      if self:IsEOF() then
        return
      end
      return self.Tokens[self.index]
    end

    __Arguments__{String}(IToken/nil)
    function Maybe(self, type)
      local token = self:Peek()
      if token and token:GetType() == type then
        self.index = self.index + 1
        return token
      end
    end

    __Arguments__{String}(IToken/nil)
    function Expect(self, type)
       if self:IsEOF() then
         throw(EOFException("EOF"))
       end
       return self:Maybe(type) or throw(WrongTokenTypeException(type))
    end
  end)
end)
