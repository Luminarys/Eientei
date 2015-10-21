defmodule Eientei.UploadsTest do
  use Eientei.ModelCase

  alias Eientei.Upload

  @valid_attrs %{archived_url: "some content", filename: "some content", hash: "some content", location: "some content", name: "some content", size: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Upload.changeset(%Upload{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Upload.changeset(%Upload{}, @invalid_attrs)
    refute changeset.valid?
  end
end
