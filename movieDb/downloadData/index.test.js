const { dependencies, downloadData } = require('./');

describe('downloadData', () => {
  let consoleSpy;
  let mockReporter;

  beforeAll(() => {
    consoleSpy = jest.spyOn(global.console, 'log').mockImplementation(() => null);
  });

  afterAll(() => {
    consoleSpy.mockRestore();
  });

  beforeEach(() => {
    dependencies.downloadGzipFileFromIMDb = jest.fn();
    dependencies.createDownloadPath = jest.fn().mockReturnValue('testPath');

    mockReporter = jest.fn();
    dependencies.createReporter = jest.fn().mockReturnValue(mockReporter);
  });

  it('calls createDownloadPath with movieDbData', () => downloadData()
    .then(() => expect(dependencies.createDownloadPath).toHaveBeenCalledWith('movieDbData')));

  [
    'title.basics.tsv.gz',
    'title.principals.tsv.gz',
    'name.basics.tsv.gz',
  ].forEach((title) => {
    it(`calls downloadGzipFileFromIMDb to download ${title}`, () => downloadData()
      .then(() => {
        expect(dependencies.downloadGzipFileFromIMDb)
          .toBeCalledWith(title, expect.anything(), expect.anything(), expect.anything());
      }));
  });
});
