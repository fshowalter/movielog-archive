const {
  createReporter,
  columnLeft,
  columnRight,
  dependencies,
} = require('./');

describe('columnLeft', () => {
  describe('when string is shorter then length', () => {
    it('pads the end of a given string to equal length', () => {
      expect(columnLeft('test', 10)).toEqual('test      ');
    });
  });

  describe('when string is longer then length', () => {
    it('returns string', () => {
      expect(columnLeft('test', 3)).toEqual('test');
    });
  });
});

describe('columnRight', () => {
  describe('when string is shorter then length', () => {
    it('pads the start of a given string to equal length', () => {
      expect(columnRight('test', 10)).toEqual('      test');
    });
  });

  describe('when string is longer then length', () => {
    it('returns string', () => {
      expect(columnRight('test', 3)).toEqual('test');
    });
  });
});

describe('createReporter', () => {
  beforeEach(() => {
    dependencies.DraftLog = jest.fn(() => { global.console.draft = jest.fn(); });
  });

  afterEach(() => {
    delete global.console.draft;
  });

  it('instantiates DraftLog', () => {
    createReporter();
    expect(dependencies.DraftLog).toHaveBeenCalledWith(global.console);
  });

  describe('if DraftLog is alread instantiated', () => {
    let mockDraft;

    beforeEach(() => {
      mockDraft = jest.fn();
      global.console.draft = jest.fn().mockReturnValue(mockDraft);
    });

    it('returns an instance of console.draft', () => {
      expect(createReporter()).toEqual(mockDraft);
    });
  });
});
