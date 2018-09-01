const { ensureDownloadPath, dependencies } = require('../ensureDownloadPath');

const testDate = new Date(2018, 7, 25);
const RealDate = Date;

describe('ensureDownloadPath', () => {
  beforeEach(() => {
    dependencies.mkdirSync = jest.fn();

    global.Date.now = jest.fn(() => testDate.getTime());
  });

  afterEach(() => {
    global.Date = RealDate;
  });

  describe('when path does not exist', () => {
    beforeEach(() => {
      dependencies.existsSync = jest.fn().mockReturnValue(false);
    });

    it('creates path based on current date', () => {
      ensureDownloadPath();
      expect(dependencies.mkdirSync).toBeCalledWith('movieDbData/20180825');
    });

    it('returns created path', () => {
      expect(ensureDownloadPath()).toEqual('movieDbData/20180825');
    });
  });

  describe('when path does exist', () => {
    beforeEach(() => {
      dependencies.existsSync = jest.fn().mockReturnValue(true);
    });

    it('does not create path', () => {
      ensureDownloadPath();
      expect(dependencies.mkdirSync).not.toBeCalled();
    });

    it('returns existing path', () => {
      expect(ensureDownloadPath()).toEqual('movieDbData/20180825');
    });
  });
});
