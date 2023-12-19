local PLOOP_PATH = os.getenv("LUA_FAUX_COMBINATOR_PLOOP_PATH")
if PLOOP_PATH then
  package.path = package.path .. ";" .. PLOOP_PATH .. "?.lua;" .. PLOOP_PATH .. "?/init.lua"
end

require "PLoop"
require "PLoop.System.UnitTest"
require "src/Parser"

PLoop.System.Logger.Default:AddHandler(print)

UnitTest "FauxCombinator.Parser"(function (_ENV)
  local lparen = FauxCombinator.BasicToken{Type = "lparen"}
  local rparen = FauxCombinator.BasicToken{Type = "rparen"}

  class "IdToken"(function (_ENV)
    extend "FauxCombinator.IToken"

    property "Id" { type = String }

    function GetType()
      return "id"
    end
  end)

  local id_a = IdToken{Id = "a"}
  local id_b = IdToken{Id = "b"}
  local id_c = IdToken{Id = "c"}
  local id_d = IdToken{Id = "d"}

  __Test__()
  function TestPeekOK()
    local tokens = Array[FauxCombinator.IToken]({lparen})
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Equal(p:Peek().Type, 'lparen')
  end

  __Test__()
  function TestPeekEOF()
    local tokens = Array[FauxCombinator.IToken]({})
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Nil(p:Peek())
  end

  __Test__()
  function TestMaybeOK()
    local tokens = Array[FauxCombinator.IToken]({lparen, rparen})
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Equal(p:Maybe('lparen').Type, 'lparen')
    Assert.Equal(p:Maybe('rparen').Type, 'rparen')
  end

  __Test__()
  function TestMaybeKO()
    local tokens = Array[FauxCombinator.IToken]({lparen})
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Nil(p:Maybe('rparen'))
  end

  __Test__()
  function TestMaybeEOF()
    local tokens = Array[FauxCombinator.IToken]({})
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Nil(p:Maybe('rparen'))
  end
  
  __Test__()
  function TestExpectOK()
    local tokens = Array[FauxCombinator.IToken]({lparen, rparen})
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Equal(p:Expect('lparen').Type, 'lparen')
    Assert.Equal(p:Expect('rparen').Type, 'rparen')
  end

  __Test__()
  function TestExpectKOType()
    local tokens = Array[FauxCombinator.IToken]({lparen})
    local p = FauxCombinator.Parser{Tokens = tokens}
    --Assert.Match("Expected %s, got %s", Assert.Error(function ()
      p:Expect('rparen')
    --end))
  end
end)

UnitTest("FauxCombinator.Parser"):Run()
