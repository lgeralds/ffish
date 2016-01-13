Feature: We can manage our ffish
  As a busy devOp with a lot of things to do
  I want to capture knowledge how to do things
  and automate doing those things
  especially the building of complex software packages

# default working dir created and populated, state file is created
Scenario: Launch ffish app
  Given the directory "~/ffish" doesn't exist
  When I successfully run `ffish list`
  Then the directory "~/ffish" should exist
  And the file "~/ffish/ffish.yaml" should exist

# arbitray working dir created and populated, state file is created
  Given the directory "~/one_deep/ffish" doesn't exist
  When I successfully run `ffish --working_directory=~/one_deep/ffish list`
  Then the directory "~/one_deep/ffish" should exist
  And the file "~/one_deep/ffish/ffish.yaml" should exist

Scenario: Add a new ffish and list ffish
  Given the directory "~/ffish" doesn't exist
  When I successfully run `ffish new my_new_ffish`
  And I successfully run `ffish list`
  Then the file "~/ffish/ffish/my_new_ffish.ffish" should exist
  And the stdout should contain "my_new_ffish"

# Scenario: Set a current ffish, show current ffish
  Given the directory "~/ffish" doesn't exist
  When I successfully run `ffish new tuna carp bass`
  And I successfully run `ffish current bass`
  Then I successfully run `ffish current`
  And the stdout should contain "bass"

  And I successfully run `ffish current tuna`
  Then I successfully run `ffish current`
  And the stdout should contain "tuna"

  And I successfully run `ffish current carp`
  Then I successfully run `ffish current`
  And the stdout should contain "carp"


# set current ffish from existing ffish - stop false ffish
# show unset current ffish
