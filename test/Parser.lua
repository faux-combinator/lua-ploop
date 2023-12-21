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

  __Test__()
  function TestAnyZeroWrap()
    local tokens = Array[FauxCombinator.IToken] {}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Equal(0, #p:Any('id'))
  end

  __Test__()
  function TestAnyZero()
    local tokens = Array[FauxCombinator.IToken] {}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Equal(0, #p:Any(function () return p:Expect('id') end))
  end

  __Test__()
  function TestAnyOneWrap()
    local tokens = Array[FauxCombinator.IToken] {id_a}
    local p = FauxCombinator.Parser{Tokens = tokens}
    local l = p:Any('id')
    Assert.Equal(1, #l)
    Assert.Equal('id', l[1]:GetType())
    Assert.Equal('a', l[1].Id)
  end

  __Test__()
  function TestAnyOne()
    local tokens = Array[FauxCombinator.IToken] {id_a}
    local p = FauxCombinator.Parser{Tokens = tokens}
    local l = p:Any(function () return p:Expect('id') end)
    Assert.Equal(1, #l)
    Assert.Equal('id', l[1]:GetType())
    Assert.Equal('a', l[1].Id)
  end

  __Test__()
  function TestAnyManyWrap()
    local tokens = Array[FauxCombinator.IToken] {id_a, id_b, id_c}
    local p = FauxCombinator.Parser{Tokens = tokens}
    local l = p:Any('id')
    Assert.Equal(3, #l)
    Assert.Equal('id', l[1]:GetType())
    Assert.Equal('a', l[1].Id)
    Assert.Equal('id', l[2]:GetType())
    Assert.Equal('b', l[2].Id)
    Assert.Equal('id', l[3]:GetType())
    Assert.Equal('c', l[3].Id)
  end

  __Test__()
  function TestAnyMany()
    local tokens = Array[FauxCombinator.IToken] {id_a, id_b, id_c}
    local p = FauxCombinator.Parser{Tokens = tokens}
    local l = p:Any(function () return p:Expect('id') end)
    Assert.Equal(3, #l)
    Assert.Equal('id', l[1]:GetType())
    Assert.Equal('a', l[1].Id)
    Assert.Equal('id', l[2]:GetType())
    Assert.Equal('b', l[2].Id)
    Assert.Equal('id', l[3]:GetType())
    Assert.Equal('c', l[3].Id)
  end

  __Test__()
  function TestAnyTyped()
    local tokens = Array[FauxCombinator.IToken] {id_a, id_b, id_c}
    local p = FauxCombinator.Parser{Tokens = tokens}
    class "AnyTypedId" (function (_ENV)
      property "Id" { type = String }
    end)
    local l = p:Any(AnyTypedId, function ()
      return AnyTypedId{Id = p:Expect('id').Id}
    end)
    Assert.Equal(3, #l)
    Assert.Equal('a', l[1].Id)
    Assert.Equal('b', l[2].Id)
    Assert.Equal('c', l[3].Id)
  end

  __Test__()
  function TestManyZeroKOEOFWrap()
    local tokens = Array[FauxCombinator.IToken] {}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Find("EOF", Assert.Error(function ()
      p:Many('id')
    end))
  end

  __Test__()
  function TestManyZeroKOTypeWrap()
    local tokens = Array[FauxCombinator.IToken] {lparen}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Find("Expected id, got lparen", Assert.Error(function ()
      p:Many('id')
    end))
  end

  __Test__()
  function TestManyZeroKOEOF()
    local tokens = Array[FauxCombinator.IToken] {}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Find("EOF", Assert.Error(function ()
      p:Many(function () return p:Expect('id') end)
    end))
  end

  __Test__()
  function TestManyZeroKOType()
    local tokens = Array[FauxCombinator.IToken] {lparen}
    local p = FauxCombinator.Parser{Tokens = tokens}
    Assert.Find("Expected id, got lparen", Assert.Error(function ()
      p:Many(function () return p:Expect('id') end)
    end))
  end

  __Test__()
  function TestManyOneWrap()
    local tokens = Array[FauxCombinator.IToken] {id_a}
    local p = FauxCombinator.Parser{Tokens = tokens}
    local l = p:Many('id')
    Assert.Equal(1, #l)
    Assert.Equal('id', l[1]:GetType())
    Assert.Equal('a', l[1].Id)
  end

  __Test__()
  function TestManyOne()
    local tokens = Array[FauxCombinator.IToken] {id_a}
    local p = FauxCombinator.Parser{Tokens = tokens}
    local l = p:Many(function () return p:Expect('id') end)
    Assert.Equal(1, #l)
    Assert.Equal('id', l[1]:GetType())
    Assert.Equal('a', l[1].Id)
  end

  __Test__()
  function TestManyManyWrap()
    local tokens = Array[FauxCombinator.IToken] {id_a, id_b, id_c}
    local p = FauxCombinator.Parser{Tokens = tokens}
    local l = p:Many('id')
    Assert.Equal(3, #l)
    Assert.Equal('id', l[1]:GetType())
    Assert.Equal('a', l[1].Id)
    Assert.Equal('id', l[2]:GetType())
    Assert.Equal('b', l[2].Id)
    Assert.Equal('id', l[3]:GetType())
    Assert.Equal('c', l[3].Id)
  end

  __Test__()
  function TestManyMany()
    local tokens = Array[FauxCombinator.IToken] {id_a, id_b, id_c}
    local p = FauxCombinator.Parser{Tokens = tokens}
    local l = p:Many(function () return p:Expect('id') end)
    Assert.Equal(3, #l)
    Assert.Equal('id', l[1]:GetType())
    Assert.Equal('a', l[1].Id)
    Assert.Equal('id', l[2]:GetType())
    Assert.Equal('b', l[2].Id)
    Assert.Equal('id', l[3]:GetType())
    Assert.Equal('c', l[3].Id)
  end

  __Test__()
  function TestManyTyped()
    local tokens = Array[FauxCombinator.IToken] {id_a, id_b, id_c}
    local p = FauxCombinator.Parser{Tokens = tokens}
    class "ManyTypedId" (function (_ENV)
      property "Id" { type = String }
    end)
    local l = p:Many(ManyTypedId, function ()
      return ManyTypedId{Id = p:Expect('id').Id}
    end)
    Assert.Equal(3, #l)
    Assert.Equal('a', l[1].Id)
    Assert.Equal('b', l[2].Id)
    Assert.Equal('c', l[3].Id)
  end


  __Test__()
  function TestTree()
    local tokens = Array[FauxCombinator.IToken] {
      lparen,
        id_a,
        id_b,
        lparen,
          id_a,
          id_b,
          lparen,
            lparen,
              id_c,
            rparen,
          rparen,
        rparen,
      rparen
    }
    local p = FauxCombinator.Parser{Tokens = tokens}

    interface "Expr" (function (_ENV)
      __Abstract__()
      __Return__{String}
      function Format()
      end
    end)

    class "Id" (function (_ENV)
      extend "Expr"

      property "Name" { type = String }

      function Format(self)
        return self.Name
      end
    end)

    class "Call" (function (_ENV)
      extend "Expr"

      property "Callee" { type = Expr }
      property "Arguments" { type = Array[Expr] }

      function Format(self)
        local args = self.Arguments:Map("x=>x:Format()"):Join(", ")
        return self.Callee:Format() .. "(" .. args .. ")"
      end
    end)

    local id = function ()
      local t = p:Expect('id')
      return Id{Name = t.Id}
    end

    local call, expr
    call = function ()
      p:Expect('lparen')
      local callee = expr()
      local args = p:Any(Expr, expr)
      p:Expect('rparen')
      return Call{Callee = callee, Arguments = args}
    end

    expr = function ()
      return p:Either(id, call)
    end
    local top = expr()
    Assert.Equal('a(b, a(b, c()()))', top:Format())
  end
end)

UnitTest("FauxCombinator.Parser"):Run()
