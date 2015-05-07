defmodule ExAws.Dynamo.EncoderTest do
  use ExUnit.Case, async: true
  alias ExAws.Dynamo.Encoder

  test "encoding works with derived structs" do
    assert %Test.User{email: "foo@bar.com", name: %{first: "bob", last: "bubba"}, age: 23, admin: false}
    |> Encoder.encode
  end

  test "Encoder converts numbers to binaries" do
    assert Encoder.encode(34) == %{"N" => "34"}
  end

  test "Encoder can handle map values" do
    result = %{foo: 1, bar: %{baz: 2, zounds: "asdf"}} |> Encoder.encode
    assert %{"M" => %{"bar" => %{"M" => %{"baz" => %{"N" => "2"}, "zounds" => %{"S" => "asdf"}}}, "foo" => %{"N" => "1"}}} == result
  end

  test "Encoder can handle floats" do
    assert Encoder.encode(0.4) == %{"N" => "4.00000000000000022204e-01"}
  end

  test "Encoder with structs works properly" do
    user = %Test.User{email: "foo@bar.com", name: "Bob", age: 23, admin: false}
    assert %{"admin" => %{"BOOL" => "false"}, "age" => %{"N" => "23"},
      "email" => %{"S" => "foo@bar.com"}, "name" => %{"S" => "Bob"}} = Encoder.encode(user)
  end

  test "encoder handles lists properly" do
    %{"NS" => ["3", ["2", ["1", []]]]}
  end

  test "encoder is idempotent" do
    value = %{foo: 1, bar: %{baz: 2, zounds: "asdf"}}
    assert value |> Encoder.encode ==  value |> Encoder.encode |> Encoder.encode
  end
end
