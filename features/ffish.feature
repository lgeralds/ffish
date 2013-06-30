Feature: We can create new ffish
  As a busy devop with a lot of things to do
  I want to capture the knowledge how to 
  and automate the building of complex software packages

Scenario: Add a new ffish
  Given the directory "/tmp/ffish" doesn't exist
  When I successfully run `ffish new my_new`
  And I successfully run `ffish list`
  Then the file "/tmp/ffish/my_new.ffish" should exist
  And the stdout should contain "my_new"

  