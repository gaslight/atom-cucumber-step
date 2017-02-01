StepJumper = require "../lib/step-jumper"

describe "jumping", ->
  beforeEach ->
    @stepJumper = new StepJumper("  Given I have a cheese")
    @interpolatedStepJumper = new StepJumper("  Given I have 2 \"blue\" 'cheeses'")

  describe "stepTypeRegex", ->
    it "should match right step types", ->
      expect("Given(/I have a cheese/)".match(@stepJumper.stepTypeRegex())).toBeTruthy()
    it "should match quoted step types", ->
      expect("Given('I have a cheese')".match(@stepJumper.stepTypeRegex())).toBeTruthy()
    it "should match interpolated step types", ->
      expect("Given('I have $digits \"$color\" '$objectType'')".match(@stepJumper.stepTypeRegex())).toBeTruthy()
    it "should not match wrong step types", ->
      expect("With(/I have a cheese/)".match(@stepJumper.stepTypeRegex())).toBeFalsy()

  describe "checkMatch", ->
    beforeEach ->
      @match1 =
        matchText: "Given(/^some other random crap$/)"
        range: [[10, 0], [15, 0]]
      @match2 =
        matchText: "Given(/^I have a cheese$/)"
        range: [[20, 0], [25, 0]]
      @match3 =
        matchText: "Given(/^an escaped \/ is in this match$/)"
        range: [[10, 0], [15, 0]]
      @scanMatch =
        filePath: "path/to/file"
        matches: [@match1, @match2, @match3]
    it "should return file and line", ->
      expect(@stepJumper.checkMatch(@scanMatch)).toEqual(["path/to/file", 20])

  describe "checkMatch no brackets", ->
    beforeEach ->
      @match =
        matchText: "Given /^I have a cheese$/"
        range: [[20, 0], [25, 0]]
      @scanMatch =
        filePath: "path/to/file"
        matches: [@match]
    it "should return file and line", ->
      expect(@stepJumper.checkMatch(@scanMatch)).toEqual(["path/to/file", 20])

  describe "checkMatch invalid regex", ->
    beforeEach ->
      @match1 =
        matchText: "Given(/invalid regex [/)"
        range: [[10, 0], [15, 0]]
      @match2 =
        matchText: "Given(/^I have a cheese$/)"
        range: [[20, 0], [25, 0]]
      @scanMatch =
        filePath: "path/to/file"
        matches: [@match1, @match2]
    it "should return file and line", ->
      expect(@stepJumper.checkMatch(@scanMatch)).toEqual(["path/to/file", 20])

  describe "checkMatch no match", ->
    beforeEach ->
      @match =
        matchText: "Given(/^I don't have a cheese$/)"
        range: [[20, 0], [25, 0]]
      @scanMatch =
        filePath: "path/to/file"
        matches: [@match]
    it "should return undefined", ->
      expect(@stepJumper.checkMatch(@scanMatch)).toEqual(undefined)

  describe "checkMatch quoted", ->
    beforeEach ->
      @match =
        matchText: "Given('I have $digits \"$color\" '$objectType'')"
        range: [[20,0], [25, 0]]
      @scanMatch =
        filePath: "path/to/file"
        matches: [@match]
    it "should return file and line", ->
      expect(@interpolatedStepJumper.checkMatch(@scanMatch)).toEqual(["path/to/file", 20])
