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
    local tokens = Array[FauxCombinator.IToken] {lparen}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Equal('lparen', p:Peek():GetType())
  end

  __Test__()
  function TestPeekEOF()
    local tokens = Array[FauxCombinator.IToken] {}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Nil(p:Peek())
  end

  __Test__()
  function TestMaybeOK()
    local tokens = Array[FauxCombinator.IToken] {lparen, rparen}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Equal('lparen', p:Maybe('lparen'):GetType())
    Assert.Equal('rparen', p:Maybe('rparen'):GetType())
  end

  __Test__()
  function TestMaybeKO()
    local tokens = Array[FauxCombinator.IToken] {lparen}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Nil(p:Maybe('rparen'))
  end

  __Test__()
  function TestMaybeEOF()
    local tokens = Array[FauxCombinator.IToken] {}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Nil(p:Maybe('rparen'))
  end
  
  __Test__()
  function TestExpectOK()
    local tokens = Array[FauxCombinator.IToken] {lparen, rparen}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Equal('lparen', p:Expect('lparen'):GetType())
    Assert.Equal('rparen', p:Expect('rparen'):GetType())
  end

  __Test__()
  function TestExpectKOType()
    local tokens = Array[FauxCombinator.IToken] {lparen}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Find("Expected rparen, got lparen", Assert.Error(function ()
      p:Expect('rparen')
    end))
  end

  __Test__()
  function TestTryOK()
    local tokens = Array[FauxCombinator.IToken] {lparen}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Equal('lparen', p:Try(function ()
      return p:Expect('lparen'):GetType()
    end))
    Assert.True(p:IsEOF())
  end

  __Test__()
  function TestTryKO()
    local tokens = Array[FauxCombinator.IToken] {lparen}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Nil(p:Try(function () return p:Expect('rparen') end))
    Assert.False(p:IsEOF())
    Assert.Equal('lparen', p:Peek():GetType())
  end

  __Test__()
  function TestTryWrapOK()
    local tokens = Array[FauxCombinator.IToken] {lparen}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Equal('lparen', p:Try('lparen'):GetType())
    Assert.True(p:IsEOF())
  end

  __Test__()
  function TestTryWrapKO()
    local tokens = Array[FauxCombinator.IToken] {lparen}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Nil(p:Try('rparen'))
    Assert.False(p:IsEOF())
    Assert.Equal(p:Expect('lparen'):GetType(), 'lparen')
  end

  __Test__()
  function TestEitherFirst()
    local tokens = Array[FauxCombinator.IToken] {lparen}
    local p = FauxCombinator.Parser{Tokens = tokens}
    local t = p:Either(p:Expect_('lparen'), p:Expect_('rparen'))
    Assert.Equal('lparen', t:GetType())
    Assert.True(p:IsEOF())
  end

  __Test__()
  function TestEitherLast()
    local tokens = Array[FauxCombinator.IToken] {rparen}
    local p = FauxCombinator.Parser{Tokens = tokens}
    local t = p:Either(p:Expect_('lparen'), p:Expect_('rparen'))
    Assert.Equal('rparen', t:GetType())
    Assert.True(p:IsEOF())
  end

  __Test__()
  function TestEitherKO()
    local tokens = Array[FauxCombinator.IToken] {id_a}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Match("Either matched no branches", Assert.Error(function ()
      p:Either(p:Expect_('lparen'), p:Expect_('rparen'))
      return 'Error'
    end))
  end

  __Test__()
  function TestEitherKOTry()
    local tokens = Array[FauxCombinator.IToken] {id_a}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Nil(p:Try(function ()
      p:Either(p:Expect_('lparen'), p:Expect_('rparen'))
      return 'Error'
    end))
    Assert.False(p:IsEOF())
    Assert.Equal('id', p:Peek():GetType())
  end

  __Test__()
  function TestEitherWrapFirst()
    local tokens = Array[FauxCombinator.IToken] {lparen}
    local p = FauxCombinator.Parser{Tokens = tokens}
    local t = p:Either('lparen', 'rparen')
    Assert.Equal('lparen', t:GetType())
    Assert.True(p:IsEOF())
  end

  __Test__()
  function TestEitherWrapLast()
    local tokens = Array[FauxCombinator.IToken] {rparen}
    local p = FauxCombinator.Parser{Tokens = tokens}
    local t = p:Either('lparen', 'rparen')
    Assert.Equal('rparen', t:GetType())
    Assert.True(p:IsEOF())
  end

  __Test__()
  function TestEitherWrapKO()
    local tokens = Array[FauxCombinator.IToken] {id_a}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Find("Either matched no branches", Assert.Error(function ()
      p:Either('lparen', 'rparen')
    end))
  end
end)

UnitTest("FauxCombinator.Parser"):Run()
