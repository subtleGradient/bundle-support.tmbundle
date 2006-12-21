#!/usr/bin/env ruby
# 
# CodeCompletion TESTS
# 
require "#{ENV['TM_SUPPORT_PATH']}/lib/codecompletion"
require 'test/unit'

class TestTextmateCodeCompletion < Test::Unit::TestCase
  def test_blank
    set_tm_vars({"TM_SELECTED_TEXT" => nil, "TM_CURRENT_LINE" => "", "TM_COLUMN_NUMBER" => "1", "TM_BUNDLE_PATH" => "/Users/taylott/Library/Application Support/TextMate/Bundles/Ruby.tmbundle", "TM_INPUT_START_COLUMN" => "1", "TM_SUPPORT_PATH" => "/Library/Application Support/TextMate/Support"})
    assert_equal "${101:test}$100$0", TextmateCodeCompletion.new(['test'], %{}).to_s
  end
  def test_basic
    set_tm_vars({"TM_SELECTED_TEXT" => nil, "TM_CURRENT_LINE" => "basic", "TM_COLUMN_NUMBER" => "6", "TM_BUNDLE_PATH" => "/Users/taylott/Library/Application Support/TextMate/Bundles/Ruby.tmbundle", "TM_INPUT_START_COLUMN" => "1", "TM_SUPPORT_PATH" => "/Library/Application Support/TextMate/Support"})
    assert_equal "${101:basic}$100$0", TextmateCodeCompletion.new(['basic'], %{basic}).to_s
  end
  def test_a
    set_tm_vars({"TM_SELECTED_TEXT" => nil, "TM_CURRENT_LINE" => "a", "TM_COLUMN_NUMBER" => "2", "TM_BUNDLE_PATH" => "/Users/taylott/Library/Application Support/TextMate/Bundles/Ruby.tmbundle", "TM_INPUT_START_COLUMN" => "1", "TM_SUPPORT_PATH" => "/Library/Application Support/TextMate/Support"})
    assert_equal "${101:aaa}$100$0", TextmateCodeCompletion.new(['aaa'], %{a}).to_s
  end
  
  def test_in_snippet
    set_tm_vars({"TM_SELECTED_TEXT" => nil, "TM_CURRENT_LINE" => %{${1:snippet}}, "TM_COLUMN_NUMBER" => "12", "TM_BUNDLE_PATH" => "/Users/taylott/Library/Application Support/TextMate/Bundles/Ruby.tmbundle", "TM_INPUT_START_COLUMN" => "1", "TM_SUPPORT_PATH" => "/Library/Application Support/TextMate/Support"})
    assert_equal '\${1:snippet${0:}}', TextmateCodeCompletion.new(['nomatch'], %{${1:snippet}}).to_s
  end
  def test_in_snippet_match
    set_tm_vars({"TM_SELECTED_TEXT" => nil, "TM_CURRENT_LINE" => %{${1:snippet}}, "TM_COLUMN_NUMBER" => "12", "TM_BUNDLE_PATH" => "/Users/taylott/Library/Application Support/TextMate/Bundles/Ruby.tmbundle", "TM_INPUT_START_COLUMN" => "1", "TM_SUPPORT_PATH" => "/Library/Application Support/TextMate/Support"})
    assert_equal '\${1:${101:snippet}$100$0}', TextmateCodeCompletion.new(['snippet'], %{${1:snippet}}).to_s
  end
  
  def test_choice_partial_selection
    set_tm_vars({"TM_SELECTED_TEXT" => "selection", "TM_CURRENT_LINE" => "choice_partialselection", "TM_COLUMN_NUMBER" => "24", "TM_BUNDLE_PATH" => "/Users/taylott/Library/Application Support/TextMate/Bundles/Ruby.tmbundle", "TM_INPUT_START_COLUMN" => "15", "TM_SUPPORT_PATH" => "/Library/Application Support/TextMate/Support"})
    assert_equal "choice_partial${0:selection}", TextmateCodeCompletion.new(['test'], %{selection}).to_s, $debug_codecompletion.inspect
  end
  def test_choice_partial_selection_match
    set_tm_vars({"TM_SELECTED_TEXT" => "selection", "TM_CURRENT_LINE" => "choice_partialselection", "TM_COLUMN_NUMBER" => "24", "TM_BUNDLE_PATH" => "/Users/taylott/Library/Application Support/TextMate/Bundles/Ruby.tmbundle", "TM_INPUT_START_COLUMN" => "15", "TM_SUPPORT_PATH" => "/Library/Application Support/TextMate/Support"})
    assert_equal "${101:_match}$100$0", TextmateCodeCompletion.new(['choice_partial_match'], %{selection}).to_s, $debug_codecompletion.inspect
  end
  
  def test_selection_no_context
    set_tm_vars({"TM_SELECTED_TEXT" => "basic_selection", "TM_CURRENT_LINE" => "basic_selection", "TM_COLUMN_NUMBER" => "1", "TM_BUNDLE_PATH" => "/Users/taylott/Library/Application Support/TextMate/Bundles/Ruby.tmbundle", "TM_INPUT_START_COLUMN" => "1", "TM_SUPPORT_PATH" => "/Library/Application Support/TextMate/Support"})
    assert_equal "${101:test_basic_selection}$100$0", TextmateCodeCompletion.new(['test_basic_selection'], %{basic_selection}).to_s, $debug_codecompletion.inspect
  end
  
  def test_snippetize
    set_tm_vars({"TM_SELECTED_TEXT" => nil, "TM_CURRENT_LINE" => "String", "TM_COLUMN_NUMBER" => "7", "TM_BUNDLE_PATH" => "/Users/taylott/Library/Application Support/TextMate/Bundles/Ruby.tmbundle", "TM_INPUT_START_COLUMN" => "1", "TM_SUPPORT_PATH" => "/Library/Application Support/TextMate/Support"})
    assert_equal "${101:String.method(${1:})}$100$0", TextmateCodeCompletion.new(['String.method()'], %{String}).to_s, $debug_codecompletion.inspect
  end
  
  def test_snippetize_methods
    set_tm_vars({"TM_SELECTED_TEXT" => nil, "TM_CURRENT_LINE" => "String", "TM_COLUMN_NUMBER" => "7", "TM_BUNDLE_PATH" => "/Users/taylott/Library/Application Support/TextMate/Bundles/Ruby.tmbundle", "TM_INPUT_START_COLUMN" => "1", "TM_SUPPORT_PATH" => "/Library/Application Support/TextMate/Support"})
    assert_equal "${101:String.method(${1:one},${2:two})(${3:})}$100$0", TextmateCodeCompletion.new(['String.method(one,two)()'], %{String}).to_s, $debug_codecompletion.inspect
  end
  
  private
  def set_tm_vars(env)
    ENV['TM_BUNDLE_PATH']        = env['TM_BUNDLE_PATH']
    ENV['TM_COLUMN_NUMBER']      = env['TM_COLUMN_NUMBER']
    ENV['TM_CURRENT_LINE']       = env['TM_CURRENT_LINE']
    ENV['TM_INPUT_START_COLUMN'] = env['TM_INPUT_START_COLUMN']
    ENV['TM_SELECTED_TEXT']      = env['TM_SELECTED_TEXT']
    ENV['TM_SUPPORT_PATH']       = env['TM_SUPPORT_PATH']
  end
end