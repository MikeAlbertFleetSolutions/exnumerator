defmodule ExnumeratorTest do
  use ExUnit.Case

  @values_strings ["sent", "read", "received", "delivered"]
  @values_atoms [:sent, :read, :received, :delivered]
  @values_keywords [sent: "S", read: "READ", received: "R", delivered: "D"]
  # in some scenerios the enumeration is backed by a "codes" table that resolved to an integer
  # (i.e. a ORDERS table with a column of ORDER_STATUS_ID that maps to the ORDER_STATUSES table)
  # it's very convenient to support building a enumeration against integer values in this case
  @int_valued_keywords [sent: 1, read: 2, received: 3, delivered: 4]

  defmodule MessageAsString do
    use Exnumerator, values: ["sent", "read", "received", "delivered"]
  end

  defmodule MessageAsAtom do
    use Exnumerator, values: [:sent, :read, :received, :delivered]
  end

  defmodule MessageAsKeywords do
    use Exnumerator, values: [sent: "S", read: "READ", received: "R", delivered: "D"]
  end

  defmodule IntValuedKeywords do
    use Exnumerator, values: [sent: 1, read: 2, received: 3, delivered: 4]
  end

  describe "MessageAsString" do
    test "should store given values" do
      assert MessageAsString.values() == @values_strings
    end

    test "should return a random value" do
      assert MessageAsString.sample() in @values_strings
    end

    test "should return the first value" do
      assert MessageAsString.first() == List.first(@values_strings)
    end
  end

  describe "MessageAsAtom" do
    test "should store given values" do
      assert MessageAsAtom.values() == @values_atoms
    end

    test "should return a random value" do
      assert MessageAsAtom.sample() in @values_atoms
    end

    test "should return the first value" do
      assert MessageAsAtom.first() == List.first(@values_atoms)
    end
  end

  describe "MessageAsKeywords" do
    test "should store given values" do
      assert MessageAsKeywords.values() == @values_keywords
    end

    test "should return a random value" do
      assert MessageAsKeywords.sample() in @values_keywords
    end

    test "should return the first value" do
      assert MessageAsKeywords.first() == List.first(@values_keywords)
    end
  end

  describe "IntValuedKeywords" do
    test "should store given values" do
      assert IntValuedKeywords.values() == @int_valued_keywords
    end

    test "should return a random value" do
      assert IntValuedKeywords.sample() in @int_valued_keywords
    end

    test "should return the first value" do
      assert IntValuedKeywords.first() == List.first(@int_valued_keywords)
    end
  end

  describe "values as  list of strings (MessageAsString)" do
    test "should argument given types" do
      assert MessageAsString.cast("sent") == {:ok, "sent"}
      assert MessageAsString.load("received") == {:ok, "received"}
      assert MessageAsString.dump("delivered") == {:ok, "delivered"}
    end

    test "should not accept argument except string" do
      assert MessageAsString.cast(:sent) == :error
      assert MessageAsString.load(:sent) == :error
      assert MessageAsString.dump(:sent) == :error
    end

    test "should load string and not convert to atom" do
      refute MessageAsString.load("received") == {:ok, :received}
      assert MessageAsString.load("received") == {:ok, "received"}
    end

    test "should not cast unknown argument" do
      assert MessageAsString.cast("invalid") == :error
      assert MessageAsString.load("invalid") == :error
      assert MessageAsString.dump("invalid") == :error
    end
  end

  describe "values as list of atoms (MessageAsAtom)" do
    test "should argument given types" do
      assert MessageAsAtom.cast(:sent) == {:ok, :sent}
      assert MessageAsAtom.dump(:delivered) == {:ok, "delivered"}
    end

    test "should load string and convert to atom" do
      refute MessageAsAtom.load("received") == {:ok, "received"}
      assert MessageAsAtom.load("received") == {:ok, :received}
    end

    test "should accept string for values in atom for cast and dump" do
      assert MessageAsAtom.cast("sent") == {:ok, :sent}
      assert MessageAsAtom.dump("delivered") == {:ok, "delivered"}
    end

    test "should not cast unknown argument" do
      assert MessageAsAtom.cast(:invalid) == :error
      assert MessageAsAtom.load(:invalid) == :error
      assert MessageAsAtom.dump(:invalid) == :error
    end
  end

  describe "values as keyword list (MessageAsKeywords)" do
    test "should store given values" do
      assert MessageAsKeywords.values() == @values_keywords
    end

    test "should return a random value" do
      assert MessageAsKeywords.sample() in @values_keywords
    end

    test "should cast atom, string, or raw value" do
      assert MessageAsKeywords.cast(:sent) == {:ok, :sent}
      assert MessageAsKeywords.cast("sent") == {:ok, :sent}
      assert MessageAsKeywords.cast("S") == {:ok, :sent}
    end

    test "should not cast non-whitelisted values" do
      assert MessageAsKeywords.cast(:invalid) == :error
      assert MessageAsKeywords.cast("invalid") == :error
    end

    test "should dump atom, string, or raw value" do
      assert MessageAsKeywords.dump(:sent) == {:ok, "S"}
      assert MessageAsKeywords.dump("sent") == {:ok, "S"}
      assert MessageAsKeywords.dump("S") == {:ok, "S"}
    end

    test "should not dump non-whitelisted values" do
      assert MessageAsKeywords.dump(:invalid) == :error
      assert MessageAsKeywords.dump("invalid") == :error
    end

    test "should load only the raw value" do
      assert MessageAsKeywords.load("S") == {:ok, :sent}
      assert MessageAsKeywords.load(:sent) == :error
      assert MessageAsKeywords.load("sent") == :error
    end
  end


  describe "int values in keyword list (MessageAsKeywords)" do
    test "should store given values" do
      assert IntValuedKeywords.values() == @int_valued_keywords
    end

    test "should return a random value" do
      assert IntValuedKeywords.sample() in @int_valued_keywords
    end

    test "should cast atom, string, or raw value" do
      assert IntValuedKeywords.cast(:sent) == {:ok, :sent}
      assert IntValuedKeywords.cast("sent") == {:ok, :sent}
      assert IntValuedKeywords.cast(1) == {:ok, :sent}
    end

    test "should not cast non-whitelisted values" do
      assert IntValuedKeywords.cast(:invalid) == :error
      assert IntValuedKeywords.cast("invalid") == :error
    end

    test "should dump atom, string, or raw value" do
      assert IntValuedKeywords.dump(:sent) == {:ok, 1}
      assert IntValuedKeywords.dump("sent") == {:ok, 1}
      assert IntValuedKeywords.dump(1) == {:ok, 1}
    end

    test "should not dump non-whitelisted values" do
      assert IntValuedKeywords.dump(:invalid) == :error
      assert IntValuedKeywords.dump("invalid") == :error
    end

    test "should load only the raw value" do
      assert IntValuedKeywords.load(1) == {:ok, :sent}
      assert IntValuedKeywords.load(:sent) == :error
      assert IntValuedKeywords.load("sent") == :error
    end
  end
end
