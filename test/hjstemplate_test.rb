require 'test_helper'

class HomeControllerTest < ActionController::TestCase

  test "page header should include link to asset" do
    get :index
    assert_response :success
    assert_select 'head script[type="text/javascript"][src="/assets/templates/test.js"]', true, @response.body
  end

end

class HjsTemplateTest < ActionController::IntegrationTest

  test "asset pipeline should serve template" do
    get "/assets/templates/test.js"
    assert_response :success
    assert @response.body =~ %r{^Ember\.TEMPLATES\["templates/test"\] = Handlebars\.template\(.+\);$}m, @response.body.inspect
  end

  test "should compile plain handlebars" do
    get "/assets/templates/plain.raw"
    assert_response :success
    assert @response.body == "Ember.TEMPLATES[\"templates/plain\"] = Handlebars.template(function (Handlebars,depth0,helpers,partials,data) {\n  helpers = helpers || Handlebars.helpers;\n  var buffer = \"\", stack1, self=this, functionType=\"function\", helperMissing=helpers.helperMissing, undef=void 0, escapeExpression=this.escapeExpression;\n\n\n  stack1 = helpers.ohai || depth0.ohai;\n  if(typeof stack1 === functionType) { stack1 = stack1.call(depth0, { hash: {} }); }\n  else if(stack1=== undef) { stack1 = helperMissing.call(depth0, \"ohai\", { hash: {} }); }\n  buffer += escapeExpression(stack1) + \"\\n\";\n  return buffer;});\n", @response.body.inspect
  end

  test "should unbind mustache templates" do
    get "/assets/templates/hairy.mustache"
    assert_response :success
    assert @response.body =~ %r{^Ember\.TEMPLATES\["templates/hairy"\] = Handlebars\.template\(.+\);$}m, @response.body.inspect
  end

  test "ensure new lines inside the anon function are persisted" do
    get "/assets/templates/new_lines.js"
    assert_response :success
    assert @response.body.include?("helpers['if'];\n"), @response.body.inspect
  end

  test "can specify a template root" do
    begin
      EmberRails.template_root = 'templates'
      get "/assets/templates/another_test.js"
      assert_response :success
      assert @response.body =~ %r{^Ember\.TEMPLATES\["another_test"\] = Handlebars\.template\(.+\);$}m, @response.body.inspect
    ensure
      EmberRails.template_root = nil
    end
  end

end
