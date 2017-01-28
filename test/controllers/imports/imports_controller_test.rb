require 'test_helper'

class Imports::ImportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @imports_import = imports_imports(:one)
  end

  test "should get index" do
    get imports_imports_url
    assert_response :success
  end

  test "should get new" do
    get new_imports_import_url
    assert_response :success
  end

  test "should create imports_import" do
    assert_difference('Imports::Import.count') do
      post imports_imports_url, params: { imports_import: {  } }
    end

    assert_redirected_to imports_import_url(Imports::Import.last)
  end

  test "should show imports_import" do
    get imports_import_url(@imports_import)
    assert_response :success
  end

  test "should get edit" do
    get edit_imports_import_url(@imports_import)
    assert_response :success
  end

  test "should update imports_import" do
    patch imports_import_url(@imports_import), params: { imports_import: {  } }
    assert_redirected_to imports_import_url(@imports_import)
  end

  test "should destroy imports_import" do
    assert_difference('Imports::Import.count', -1) do
      delete imports_import_url(@imports_import)
    end

    assert_redirected_to imports_imports_url
  end
end
