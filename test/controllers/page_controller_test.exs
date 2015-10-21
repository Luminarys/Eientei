defmodule Eientei.PageControllerTest do
  use Eientei.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "Fuwa~"
  end
end
